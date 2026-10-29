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
      version: 1,
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
      },
    );
    _database = db;
    return db;
  }

  Future<List<FinTransaction>> monthTransactions(DateTime month) async {
    final db = await database;
    final rows = await db.query('transactions',
        where: 'date_key >= ? AND date_key < ?',
        whereArgs: [dateKey(firstDayOfMonth(month)), dateKey(nextMonth(month))],
        orderBy: 'date_key DESC, id DESC');
    return rows.map(FinTransaction.fromMap).toList();
  }

  /// Leitura integral apenas para exportação solicitada pelo usuário.
  /// Não modifica o banco local.
  Future<List<FinTransaction>> allTransactions() async {
    final db = await database;
    final rows = await db.query('transactions',
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