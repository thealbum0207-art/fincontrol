import '../models/fin_transaction.dart';

class FinanceTotals {
  const FinanceTotals({required this.incomeCents, required this.expenseCents});
  final int incomeCents;
  final int expenseCents;
  int get resultCents => incomeCents - expenseCents;
}

FinanceTotals sumTransactions(Iterable<FinTransaction> transactions) {
  var income = 0;
  var expense = 0;
  for (final transaction in transactions) {
    if (transaction.kind == TransactionKind.income) {
      income += transaction.amountCents;
    } else {
      expense += transaction.amountCents;
    }
  }
  return FinanceTotals(incomeCents: income, expenseCents: expense);
}

Map<String, int> expenseByCategory(Iterable<FinTransaction> transactions) {
  final result = <String, int>{};
  for (final transaction in transactions) {
    if (transaction.kind != TransactionKind.expense) continue;
    result.update(transaction.category, (value) => value + transaction.amountCents,
        ifAbsent: () => transaction.amountCents);
  }
  return result;
}
