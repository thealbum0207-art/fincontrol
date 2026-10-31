import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:fincontrol/data/finance_db.dart';
import 'package:fincontrol/data/v3_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a versão 3 migra o banco v1 sem apagar dados', () async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final folder = await Directory.systemTemp.createTemp('fincontrol-v3-test-');
    final dbPath = p.join(folder.path, 'fincontrol_v2.db');

    // FinanceDb uses getDatabasesPath; isolate test's global path to temp.
    databaseFactoryFfi.setDatabasesPath(folder.path);
    final previous = await openDatabase(dbPath, version: 1,
      onCreate: (db, v) async {
        await db.execute('''
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
        await db.execute('''
          CREATE TABLE budgets (
            category TEXT PRIMARY KEY,
            limit_cents INTEGER NOT NULL CHECK(limit_cents > 0)
          )
        ''');
      });
    await previous.insert('transactions', {
      'title': 'Salário anterior', 'amount_cents': 245000,
      'kind': 'income', 'category': 'Salário',
      'date_key': '2026-10-02', 'note': 'Preservar',
    });
    await previous.insert('budgets',
      {'category': 'Alimentação', 'limit_cents': 75000});
    await previous.close();

    final upgraded = await FinanceDb.instance.database;
    final rows = await upgraded.query('transactions');
    expect(rows, hasLength(1));
    expect(rows.single['title'], 'Salário anterior');
    expect(rows.single['wallet_id'], 1);
    expect((await upgraded.query('budgets')).single['limit_cents'], 75000);
    expect((await upgraded.query('wallets')).single['name'], 'Principal');
    expect(await FinanceDb.instance.totalBalanceCents(), 245000);
    expect((await V3Store.rows('savings_goals')), isEmpty);
    // Verify that newly created features can safely operate on migrated rows.
    await V3Store.addGoal('Reserva', 100000);
    await V3Store.contribute(1, 12500);
    expect((await V3Store.rows('savings_goals')).single['saved_cents'], 12500);

    await V3Store.addRecurring(title: 'Internet', amountCents: 8990,
      income: false, category: 'Contas', nextDue: DateTime(2020, 1, 31));
    await V3Store.postRecurring(1);
    expect((await V3Store.rows('recurring_rules')).single['next_due_key'],
      '2020-02-29'); // 2020 leap year.
    expect(await FinanceDb.instance.totalBalanceCents(), 236010);

    await V3Store.addCard('Teste', 50000, 15);
    await V3Store.addPurchase(cardId: 1, title: 'Compra', totalCents: 10001,
      parts: 3, firstDue: DateTime(2026, 11, 15));
    final installments = await V3Store.rows('card_installments',
      orderBy: 'part ASC');
    expect(installments.map((p) => p['amount_cents']).toList(), [3334,3334,3333]);
    await V3Store.payInstallment(installments.first['id'] as int);
    await expectLater(V3Store.payInstallment(installments.first['id'] as int),
      throwsStateError);
    expect(await FinanceDb.instance.totalBalanceCents(), 232676);

    await V3Store.addWallet('Reserva extra');
    final beforeTransfer = await FinanceDb.instance.totalBalanceCents();
    await V3Store.transfer(1, 2, 10000);
    expect(await FinanceDb.instance.totalBalanceCents(), beforeTransfer);
    expect(await V3Store.balanceForWallet(2), 10000);
    // The test keeps the DB open until the current isolate exits.
  });

  test('parcelas distribuem centavos sem perdas nem arredondamentos', () {
    expect(V3Store.splitCents(10001, 3), [3334, 3334, 3333]);
    expect(V3Store.splitCents(10000, 3).reduce((a,b) => a + b), 10000);
    expect(() => V3Store.splitCents(1, 2), throwsArgumentError);
  });

  test('recorrência trata corretamente dias no fim do mês', () {
    expect(V3Store.addMonthsClamped(DateTime(2026, 1, 31), 1),
      DateTime(2026, 2, 28));
    expect(V3Store.addMonthsClamped(DateTime(2028, 1, 31), 1),
      DateTime(2028, 2, 29));
  });
}
