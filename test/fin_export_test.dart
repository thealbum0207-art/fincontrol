import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fincontrol/data/fin_export.dart';

void main() {
  test('exportacao preserva centavos, categorias, datas e observacoes', () {
    const transactions = <Map<String, Object?>>[
      {
        'id': 3,
        'title': 'Aluguel "outubro" e ç',
        'amount_cents': 125099,
        'kind': 'expense',
        'category': 'Moradia',
        'date_key': '2026-10-20',
        'note': 'Pago com transferência\nconfirmada',
      },
      {
        'id': 7,
        'title': 'Salário',
        'amount_cents': 250000,
        'kind': 'income',
        'category': 'Salário',
        'date_key': '2026-10-21',
        'note': '',
      },
    ];
    const budgets = <Map<String, Object?>>[
      {'category': 'Moradia', 'limit_cents': 150000},
    ];
    final json = FinExport.encode(
      transactions: transactions,
      budgets: budgets,
      exportedAt: DateTime.utc(2026, 10, 23, 10, 30),
    );
    final decoded = jsonDecode(json) as Map<String, dynamic>;
    expect(decoded['format'], FinExport.schema);
    expect(decoded['format_version'], 1);
    expect(decoded['currency'], 'BRL');
    expect(decoded['exported_at_utc'], '2026-10-23T10:30:00.000Z');
    final rows = decoded['transactions'] as List;
    expect(rows.length, 2);
    expect(rows[0]['title'], 'Aluguel "outubro" e ç');
    expect(rows[0]['note'], 'Pago com transferência\nconfirmada');
    expect(rows[0]['amount_cents'], 125099);
    expect(rows[1]['amount_cents'], 250000);
    expect((decoded['budgets'] as List).first['limit_cents'], 150000);
  });

  test('exportacao vazia e valida sem inventar movimentos', () {
    final decoded = jsonDecode(FinExport.encode(
      transactions: const [],
      budgets: const [],
      exportedAt: DateTime.utc(2026, 10, 24),
    )) as Map<String, dynamic>;
    expect(decoded['transactions'], isEmpty);
    expect(decoded['budgets'], isEmpty);
  });
}
