import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../core/dates.dart';
import '../models/fin_transaction.dart';

class FinanceDb {
  FinanceDb._();
  static final FinanceDb instance = FinanceDb._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final base = await getDatabasesPath();
    final db = await openDatabase(
      p.join(base, 'fincontrol_v2.db'),
      version: 2,
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) await _createV3Tables(database);
      },
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount_cents INTEGER NOT NULL CHECK(amount_cents > 0),
            kind TEXT NOT NULL CHECK(kind IN ('income', 'expense')),
            category TEXT NOT NULL,
            date_key TEXT NOT NULL,
            note TEXT NOT NULL DEFAULT ''
          )
        ''');
        await database.execute(
          'CREATE INDEX idx_transactions_date ON transactions(date_key)');
        await database.execute('''
          CREATE TABLE budgets (
            category TEXT PRIMARY KEY,
            limit_cents INTEGER NOT NULL CHECK(limit_cents > 0)
          )
        ''');
        await _createV3Tables(database);
      },
    );
    _database = db;
    return db;
  }


  /// Schema v2: additive migration. Never drop or rename user finance tables.
  /// Existing rows receive wallet_id=1 (the default wallet).
  static Future<void> _createV3Tables(Database db) async {
    await db.execute("""
      CREATE TABLE IF NOT EXISTS wallets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        type TEXT NOT NULL DEFAULT 'cash'
      )
    """);
    await db.execute("INSERT OR IGNORE INTO wallets(id, name, type) VALUES (1, 'Principal', 'cash')");
    // The original schema did not have a wallet column; the same migration is
    // used for a fresh install so old and new installs have identical schema.
    final columns = await db.rawQuery('PRAGMA table_info(transactions)');
    if (!columns.any((c) => c['name'] == 'wallet_id')) {
      await db.execute('ALTER TABLE transactions ADD COLUMN wallet_id INTEGER NOT NULL DEFAULT 1');
    }
    await db.execute("""
      CREATE TABLE IF NOT EXISTS recurring_rules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount_cents INTEGER NOT NULL CHECK(amount_cents > 0),
        kind TEXT NOT NULL CHECK(kind IN ('income', 'expense')),
        category TEXT NOT NULL,
        wallet_id INTEGER NOT NULL DEFAULT 1,
        next_due_key TEXT NOT NULL,
        repeat_months INTEGER NOT NULL DEFAULT 1 CHECK(repeat_months >= 1),
        day_of_month INTEGER NOT NULL DEFAULT 1 CHECK(day_of_month BETWEEN 1 AND 31),
        enabled INTEGER NOT NULL DEFAULT 1
      )
    """);
    await db.execute("""
      CREATE TABLE IF NOT EXISTS savings_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        target_cents INTEGER NOT NULL CHECK(target_cents > 0),
        saved_cents INTEGER NOT NULL DEFAULT 0 CHECK(saved_cents >= 0)
      )
    """);
    await db.execute("""
      CREATE TABLE IF NOT EXISTS credit_cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        limit_cents INTEGER NOT NULL CHECK(limit_cents > 0),
        due_day INTEGER NOT NULL CHECK(due_day BETWEEN 1 AND 28)
      )
    """);
    await db.execute("""
      CREATE TABLE IF NOT EXISTS card_installments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_id INTEGER NOT NULL,
        description TEXT NOT NULL,
        amount_cents INTEGER NOT NULL CHECK(amount_cents > 0),
        due_key TEXT NOT NULL,
        part INTEGER NOT NULL,
        parts INTEGER NOT NULL,
        posted_transaction_id INTEGER UNIQUE
      )
    """);
    await db.execute('CREATE INDEX IF NOT EXISTS idx_card_installments_due ON card_installments(due_key)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_recurring_due ON recurring_rules(next_due_key)');
  }

  Future<List<FinTransaction>> monthTransactions(DateTime month) async {
    final db = await database;
    final rows = await db.query('transactions',
        where: 'date_key >= ? AND date_key < ?',
        whereArgs: [dateKey(firstDayOfMonth(month)), dateKey(nextMonth(month))],
        orderBy: 'date_key DESC, id DESC');
    return rows.map(FinTransaction.fromMap).toList();
  }

  Future<int> totalBalanceCents() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT COALESCE(SUM(CASE
        WHEN kind = 'income' THEN amount_cents
        ELSE -amount_cents END), 0) AS balance
      FROM transactions
    ''');
    return (rows.first['balance'] as num).toInt();
  }

  Future<void> upsert(FinTransaction transaction) async {
    final db = await database;
    final data = transaction.toMap();
    if (transaction.id == null) {
      await db.insert('transactions', data,
          conflictAlgorithm: ConflictAlgorithm.abort);
    } else {
      final count = await db.update('transactions', data,
          where: 'id = ?', whereArgs: [transaction.id]);
      if (count != 1) throw StateError('Lançamento não encontrado.');
    }
  }

  Future<void> deleteTransaction(int id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, int>> loadBudgets() async {
    final db = await database;
    final rows = await db.query('budgets');
    return {for (final row in rows) row['category'] as String: row['limit_cents'] as int};
  }

  Future<void> setBudget(String category, int limitCents) async {
    final db = await database;
    await db.insert('budgets', {'category': category, 'limit_cents': limitCents},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteBudget(String category) async {
    final db = await database;
    await db.delete('budgets', where: 'category = ?', whereArgs: [category]);
  }
}