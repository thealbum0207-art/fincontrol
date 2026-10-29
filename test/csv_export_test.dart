import 'package:flutter_test/flutter_test.dart';
import 'package:fincontrol/core/csv_export.dart';
import 'package:fincontrol/models/fin_transaction.dart';

void main() {
  test('exporta todos os lançamentos em CSV, com valores em centavos exatos', () {
    final lines = transactionsToCsv([
      FinTransaction(title: 'Padaria', amountCents: 1250,
          kind: TransactionKind.expense, category: 'Alimentação',
          date: DateTime(2026, 10, 29), note: 'Pão e café'),
      FinTransaction(title: 'Salário', amountCents: 250000,
          kind: TransactionKind.income, category: 'Salário',
          date: DateTime(2026, 10, 1)),
    ]);
    expect(lines, contains('"Despesa";"Padaria";"12,50";"Alimentação";"2026-10-29";"Pão e café"'));
    expect(lines, contains('"Receita";"Salário";"2500,00";"Salário";"2026-10-01";""'));
    expect(lines.endsWith('\r\n'), isTrue);
  });

  test('escapa aspas, separador e neutraliza fórmulas em planilhas', () {
    final csv = transactionsToCsv([
      FinTransaction(title: '=HYPERLINK("https://example.test")',
          amountCents: 1, kind: TransactionKind.expense,
          category: 'Outros', date: DateTime(2026, 1, 1),
          note: ' +2; "teste"'),
    ]);
    expect(csv, contains("'=HYPERLINK"));
    expect(csv, contains('""https://example.test""'));
    expect(csv, contains('"\' +2; ""teste"""'));
  });

  test('exporta categorias e limites de orçamento em ordem estável', () {
    final csv = budgetsToCsv({'Saúde': 1000, 'Alimentação': 250});
    expect(csv, contains('"Alimentação";"2,50"'));
    expect(csv, contains('"Saúde";"10,00"'));
    expect(csv.indexOf('Alimentação'), lessThan(csv.indexOf('Saúde')));
  });

  test('arquivo vazio contém somente cabeçalho', () {
    expect(transactionsToCsv([]),
      'Tipo;Descrição;Valor (R$);Categoria;Data;Observação\r\n');
    expect(budgetsToCsv({}), 'Categoria;Limite mensal (R$)\r\n');
  });
}
