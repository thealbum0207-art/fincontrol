import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'finance_db.dart';

/// Exports exactly the user's local finance records without transmitting them.
/// The caller controls where the JSON file goes through Android's share sheet.
class FinExport {
  static const schema = 'fincontrol.local-export';
  static const schemaVersion = 1;

  static String encode({
    required List<Map<String, Object?>> transactions,
    required List<Map<String, Object?>> budgets,
    required DateTime exportedAt,
  }) {
    final payload = <String, Object?>{
      'format': schema,
      'format_version': schemaVersion,
      'app': 'FinControl',
      'currency': 'BRL',
      'exported_at_utc': exportedAt.toUtc().toIso8601String(),
      'transactions': transactions.map(_transactionFields).toList(),
      'budgets': budgets.map(_budgetFields).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  static Map<String, Object?> _transactionFields(Map<String, Object?> row) =>
      {
        'id': row['id'],
        'title': row['title'],
        'amount_cents': row['amount_cents'],
        'kind': row['kind'],
        'category': row['category'],
        'date_key': row['date_key'],
        'note': row['note'],
      };

  static Map<String, Object?> _budgetFields(Map<String, Object?> row) => {
        'category': row['category'],
        'limit_cents': row['limit_cents'],
      };

  static Future<String> fromLocalDatabase() async {
    final Database db = await FinanceDb.instance.database;
    // Only reads: never deletes, edits or migrates local rows.
    final transactions = await db.query(
      'transactions',
      orderBy: 'date_key ASC, id ASC',
    );
    final budgets = await db.query(
      'budgets',
      orderBy: 'category ASC',
    );
    return encode(
      transactions: transactions,
      budgets: budgets,
      exportedAt: DateTime.now().toUtc(),
    );
  }
}
