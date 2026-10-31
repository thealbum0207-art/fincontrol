import 'dart:convert';
import 'dart:math' as math;
import 'package:sqflite/sqflite.dart';
import '../core/dates.dart';
import 'finance_db.dart';

/// All sums are stored in integer cents, never floating point.
class V3Store {
  static Future<Database> get _db => FinanceDb.instance.database;

  static Future<List<Map<String, Object?>>> rows(String table,
      {String? orderBy, String? where, List<Object?>? whereArgs}) async {
    const allowed = {
      'wallets', 'savings_goals', 'credit_cards', 'card_installments',
      'recurring_rules', 'transactions', 'budgets',
    };
    if (!allowed.contains(table)) throw ArgumentError('Unknown table');
    return (await (await _db).query(table, orderBy: orderBy,
        where: where, whereArgs: whereArgs)).cast<Map<String, Object?>>();
  }

  static Future<void> addWallet(String name) async {
    if (name.trim().isEmpty) throw ArgumentError('Name required');
    await (await _db).insert('wallets', {'name': name.trim(), 'type': 'cash'});
  }

  static Future<void> addGoal(String title, int targetCents) async {
    if (title.trim().isEmpty || targetCents <= 0) throw ArgumentError('Invalid goal');
    await (await _db).insert('savings_goals', {
      'title': title.trim(), 'target_cents': targetCents, 'saved_cents': 0,
    });
  }

  /// A goal contribution is only a progress marker, not an extra expense.
  /// This avoids changing the account balance without a real transaction.
  static Future<void> contribute(int goalId, int cents) async {
    if (cents <= 0) throw ArgumentError('Invalid amount');
    await (await _db).rawUpdate(
      'UPDATE savings_goals SET saved_cents = saved_cents + ? WHERE id = ?',
      [cents, goalId]);
  }

  static Future<void> addRecurring({
    required String title, required int amountCents, required bool income,
    required String category, required DateTime nextDue, int walletId = 1,
  }) async {
    if (title.trim().isEmpty || amountCents <= 0) throw ArgumentError('Invalid rule');
    await (await _db).insert('recurring_rules', {
      'title': title.trim(), 'amount_cents': amountCents,
      'kind': income ? 'income' : 'expense', 'category': category,
      'wallet_id': walletId, 'next_due_key': dateKey(nextDue),
      'repeat_months': 1, 'day_of_month': nextDue.day, 'enabled': 1,
    });
  }

  static DateTime addMonthsClamped(DateTime day, int months) {
    final first = DateTime(day.year, day.month + months, 1);
    final last = DateTime(first.year, first.month + 1, 0).day;
    return DateTime(first.year, first.month, math.min(day.day, last));
  }

  static DateTime addMonthsWithDay(DateTime date, int months, int day) {
    final first = DateTime(date.year, date.month + months, 1);
    final last = DateTime(first.year, first.month + 1, 0).day;
    return DateTime(first.year, first.month, math.min(day, last));
  }

  /// A manual confirmation posts a recurring entry exactly once and
  /// advances the rule atomically, preventing duplicate balance updates.
  static Future<void> postRecurring(int ruleId) async {
    final db = await _db;
    await db.transaction((txn) async {
      final items = await txn.query('recurring_rules',
          where: 'id = ? AND enabled = 1', whereArgs: [ruleId]);
      if (items.length != 1) throw StateError('Recurring rule missing');
      final r = items.single;
      final due = DateTime.parse(r['next_due_key'] as String);
      if (due.isAfter(DateTime.now())) {
        throw StateError('Este lançamento ainda não venceu.');
      }
      await txn.insert('transactions', {
        'title': r['title'], 'amount_cents': r['amount_cents'],
        'kind': r['kind'], 'category': r['category'],
        'date_key': dateKey(due), 'note': 'Lançamento recorrente',
        'wallet_id': r['wallet_id'],
      });
      final next = addMonthsWithDay(due, r['repeat_months'] as int,
          r['day_of_month'] as int);
      await txn.update('recurring_rules', {'next_due_key': dateKey(next)},
          where: 'id = ?', whereArgs: [ruleId]);
    });
  }

  static Future<void> addCard(String name, int limitCents, int dueDay) async {
    if (name.trim().isEmpty || limitCents <= 0 || dueDay < 1 || dueDay > 28) {
      throw ArgumentError('Invalid card');
    }
    await (await _db).insert('credit_cards',
        {'name': name.trim(), 'limit_cents': limitCents, 'due_day': dueDay});
  }

  /// Split integer cents exactly, including the remainder on the first part.
  static List<int> splitCents(int total, int parts) {
    if (total <= 0 || parts < 1 || parts > 120 || parts > total) {
      throw ArgumentError('Invalid installments');
    }
    final each = total ~/ parts;
    return List.generate(parts, (i) => each + (i < total % parts ? 1 : 0));
  }

  static Future<void> addPurchase({
    required int cardId, required String title,
    required int totalCents, required int parts, required DateTime firstDue,
  }) async {
    if (title.trim().isEmpty) throw ArgumentError('Missing title');
    final amounts = splitCents(totalCents, parts);
    final db = await _db;
    await db.transaction((txn) async {
      final cards = await txn.query('credit_cards',
          where: 'id = ?', whereArgs: [cardId]);
      if (cards.isEmpty) throw StateError('Card no longer exists');
      for (var i = 0; i < parts; i++) {
        await txn.insert('card_installments', {
          'card_id': cardId, 'description': title.trim(),
          'amount_cents': amounts[i],
          'due_key': dateKey(addMonthsClamped(firstDue, i)),
          'part': i + 1, 'parts': parts,
        });
      }
    });
  }

  /// An installment only enters the actual account balance when paid.
  /// The posted_transaction_id uniqueness check prevents a double debit.
  static Future<void> payInstallment(int installmentId,
      {int walletId = 1}) async {
    final db = await _db;
    await db.transaction((txn) async {
      final result = await txn.query('card_installments',
          where: 'id = ?', whereArgs: [installmentId]);
      if (result.length != 1 || result.single['posted_transaction_id'] != null) {
        throw StateError('Installment already paid or unavailable');
      }
      final i = result.single;
      final txId = await txn.insert('transactions', {
        'title': 'Cartão: ${i['description']} (${i['part']}/${i['parts']})',
        'amount_cents': i['amount_cents'],
        'kind': 'expense', 'category': 'Compras',
        'date_key': dateKey(DateTime.now()),
        'note': 'Parcela paga', 'wallet_id': walletId,
      });
      final affected = await txn.update('card_installments',
          {'posted_transaction_id': txId},
          where: 'id = ? AND posted_transaction_id IS NULL',
          whereArgs: [installmentId]);
      if (affected != 1) throw StateError('Could not mark installment paid');
    });
  }

  static Future<void> transfer(int fromWallet, int toWallet, int cents) async {
    if (fromWallet == toWallet || cents <= 0) throw ArgumentError('Invalid transfer');
    final db = await _db;
    await db.transaction((txn) async {
      final available = await txn.query('wallets',
          where: 'id IN (?, ?)', whereArgs: [fromWallet, toWallet]);
      if (available.length != 2) throw StateError('Wallet missing');
      final key = dateKey(DateTime.now());
      for (final income in [false, true]) {
        await txn.insert('transactions', {
          'title': 'Transferência entre carteiras',
          'amount_cents': cents,
          'kind': income ? 'income' : 'expense',
          'category': 'Outros', 'date_key': key,
          'note': 'Transferência interna',
          'wallet_id': income ? toWallet : fromWallet,
        });
      }
    });
  }

  static Future<int> balanceForWallet(int id) async {
    final result = await (await _db).rawQuery(
      '''SELECT COALESCE(SUM(CASE WHEN kind = 'income'
        THEN amount_cents ELSE -amount_cents END), 0) AS amount
        FROM transactions WHERE wallet_id = ?''', [id]);
    return (result.single['amount'] as num).toInt();
  }

  static Future<List<Map<String, Object?>>> allTransactions() =>
      rows('transactions', orderBy: 'date_key DESC, id DESC');

  static Future<Map<String, Object?>> monthlyReport(DateTime date) async {
    final db = await _db;
    final start = dateKey(DateTime(date.year, date.month));
    final end = dateKey(DateTime(date.year, date.month + 1));
    final aggregates = await db.rawQuery('''
      SELECT kind, COALESCE(SUM(amount_cents),0) AS total
      FROM transactions WHERE date_key >= ? AND date_key < ?
        AND note != 'Transferência interna'
      GROUP BY kind
    ''', [start, end]);
    final totals = {for (final r in aggregates)
      r['kind'] as String: (r['total'] as num).toInt()};
    final byCategory = await db.rawQuery('''
      SELECT category, SUM(amount_cents) AS total
      FROM transactions WHERE date_key >= ? AND date_key < ?
        AND kind = 'expense' AND note != 'Transferência interna'
      GROUP BY category ORDER BY total DESC
    ''', [start, end]);
    return {
      'income_cents': totals['income'] ?? 0,
      'expense_cents': totals['expense'] ?? 0,
      'categories': byCategory,
    };
  }

  /// Forecast is an estimate, not the real balance. Recurring and unpaid
  /// installment commitments are counted only in this forecast.
  static Future<Map<String, int>> forecast30Days(DateTime today) async {
    final current = await FinanceDb.instance.totalBalanceCents();
    final end = today.add(const Duration(days: 30));
    var income = 0, expenses = 0;
    final startKey = dateKey(today);
    final endKey = dateKey(end);
    final rules = await rows('recurring_rules',
        where: 'enabled = 1', orderBy: 'next_due_key');
    for (final r in rules) {
      var next = DateTime.parse(r['next_due_key'] as String);
      for (var step = 0; step < 50 && !next.isAfter(end); step++) {
        if (!next.isBefore(today)) {
          if (r['kind'] == 'income') { income += r['amount_cents'] as int; }
          else { expenses += r['amount_cents'] as int; }
        }
        next = addMonthsWithDay(next, r['repeat_months'] as int,
            r['day_of_month'] as int);
      }
    }
    final unpaid = await rows('card_installments',
        where: 'posted_transaction_id IS NULL AND due_key >= ? AND due_key <= ?',
        whereArgs: [startKey, endKey]);
    for (final p in unpaid) { expenses += p['amount_cents'] as int; }
    return {
      'balance_cents': current, 'income_cents': income,
      'expense_cents': expenses,
      'estimate_cents': current + income - expenses,
    };
  }

  /// The backup intentionally excludes credentials and PIN. It is plaintext
  /// and must be stored privately by the person exporting it.
  static Future<String> backupJson() async {
    final db = await _db;
    final data = <String, Object?>{
      'format': 'fincontrol-backup', 'schema_version': 2,
      'exported_at': DateTime.now().toIso8601String(),
    };
    for (final table in [
      'wallets','transactions','budgets','savings_goals','recurring_rules',
      'credit_cards','card_installments',
    ]) {
      data[table] = await db.query(table);
    }
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  static Future<String> transactionsCsv() async {
    final records = await allTransactions();
    String esc(Object? v) => '"${(v ?? '').toString().replaceAll('"', '""')}"';
    final keys = ['id','title','amount_cents','kind','category','date_key',
      'note','wallet_id'];
    return [
      keys.map(esc).join(','),
      for (final row in records) keys.map((k) => esc(row[k])).join(','),
    ].join('\r\n');
  }
}
