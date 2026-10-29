import '../core/dates.dart';
import '../models/fin_transaction.dart';

/// CSV compatível com planilhas em português (delimitador ;).
/// Protege contra fórmulas injetadas em campos editados por usuários.
String _cell(String value) {
  final check = value.trimLeft();
  final unsafe = check.isNotEmpty && '=+-@\t\r\n'.contains(check[0]);
  final safe = unsafe ? "'$value" : value;
  return '"${safe.replaceAll('"', '""')}"';
}

String _moneyInReais(int cents) {
  final real = cents ~/ 100;
  return '$real,${(cents % 100).toString().padLeft(2, '0')}';
}

String transactionsToCsv(Iterable<FinTransaction> entries) {
  final rows = <String>['Tipo;Descrição;Valor (R$);Categoria;Data;Observação'];
  for (final entry in entries) {
    rows.add([
      _cell(entry.kind.label),
      _cell(entry.title),
      _cell(_moneyInReais(entry.amountCents)),
      _cell(entry.category),
      _cell(dateKey(entry.date)),
      _cell(entry.note),
    ].join(';'));
  }
  return '${rows.join('\r\n')}\r\n';
}

String budgetsToCsv(Map<String, int> budgets) {
  final rows = <String>['Categoria;Limite mensal (R$)'];
  final categories = budgets.keys.toList()..sort();
  for (final category in categories) {
    rows.add('${_cell(category)};${_cell(_moneyInReais(budgets[category]!))}');
  }
  return '${rows.join('\r\n')}\r\n';
}
