import '../core/dates.dart';

enum TransactionKind { income, expense }

extension KindLabels on TransactionKind {
  String get label => this == TransactionKind.income ? 'Receita' : 'Despesa';
  String get dbValue => this == TransactionKind.income ? 'income' : 'expense';
}

class FinTransaction {
  const FinTransaction({
    this.id,
    required this.title,
    required this.amountCents,
    required this.kind,
    required this.category,
    required this.date,
    this.note = '',
    this.walletId = 1,
  });

  final int? id;
  final String title;
  final int amountCents;
  final TransactionKind kind;
  final String category;
  final DateTime date;
  final String note;
  final int walletId;

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'amount_cents': amountCents,
        'kind': kind.dbValue,
        'category': category,
        'date_key': dateKey(date),
        'note': note,
        'wallet_id': walletId,
      };

  factory FinTransaction.fromMap(Map<String, Object?> row) => FinTransaction(
        id: row['id'] as int,
        title: row['title'] as String,
        amountCents: row['amount_cents'] as int,
        kind: row['kind'] == 'income'
            ? TransactionKind.income
            : TransactionKind.expense,
        category: row['category'] as String,
        date: DateTime.parse(row['date_key'] as String),
        note: (row['note'] as String?) ?? '',
        walletId: (row['wallet_id'] as int?) ?? 1,
      );
}

const incomeCategories = [
  'Salário', 'Freelance', 'Vendas', 'Rendimentos', 'Presentes', 'Outros',
];
const expenseCategories = [
  'Alimentação', 'Moradia', 'Transporte', 'Saúde', 'Educação',
  'Lazer', 'Compras', 'Contas', 'Outros',
];

List<String> categoriesFor(TransactionKind kind) =>
    kind == TransactionKind.income ? incomeCategories : expenseCategories;
