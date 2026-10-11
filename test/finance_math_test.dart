import 'package:flutter_test/flutter_test.dart';
import 'package:fincontrol/core/dates.dart';
import 'package:fincontrol/core/finance_math.dart';
import 'package:fincontrol/models/fin_transaction.dart';

void main() {
  final transactions = [
    FinTransaction(title: 'Salário', amountCents: 200000,
      kind: TransactionKind.income, category: 'Salário', date: DateTime(2026, 10, 2)),
    FinTransaction(title: 'Almoço', amountCents: 1800,
      kind: TransactionKind.expense, category: 'Alimentação', date: DateTime(2026, 10, 3)),
    FinTransaction(title: 'Jantar', amountCents: 3500,
      kind: TransactionKind.expense, category: 'Alimentação', date: DateTime(2026, 10, 4)),
    FinTransaction(title: 'Ônibus', amountCents: 550,
      kind: TransactionKind.expense, category: 'Transporte', date: DateTime(2026, 10, 4)),
  ];

  test('soma receitas e despesas sem usar ponto flutuante', () {
    final totals = sumTransactions(transactions);
    expect(totals.incomeCents, 200000);
    expect(totals.expenseCents, 5850);
    expect(totals.resultCents, 194150);
  });

  test('agrega despesas por categoria', () {
    expect(expenseByCategory(transactions), {
      'Alimentação': 5300, 'Transporte': 550,
    });
  });

  test('gera chaves de data estáveis, inclusive entre anos', () {
    expect(dateKey(DateTime(2026, 1, 5)), '2026-01-05');
    expect(dateKey(nextMonth(DateTime(2026, 12, 20))), '2027-01-01');
    expect(monthLabel(DateTime(2026, 10, 10)), 'Outubro 2026');
  });

  test('registro gera mapa serializável sem id antes da persistência', () {
    final row = transactions.first.toMap();
    expect(row.containsKey('id'), false);
    expect(row['amount_cents'], 200000);
    expect(row['date_key'], '2026-10-02');
  });
}
