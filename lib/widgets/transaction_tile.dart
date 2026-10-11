import 'package:flutter/material.dart';

import '../core/dates.dart';
import '../core/money.dart';
import '../models/fin_transaction.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onTap,
    required this.onDelete,
  });

  final FinTransaction transaction;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final income = transaction.kind == TransactionKind.income;
    final color = income ? const Color(0xFF15AA83) : const Color(0xFFD76B68);
    final icon = income ? Icons.south_west_rounded : Icons.north_east_rounded;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: .12),
          foregroundColor: color,
          child: Icon(icon),
        ),
        title: Text(transaction.title,
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${transaction.category}  •  ${prettyDate(transaction.date)}',
            maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('${income ? '+' : '-'}${Money.format(transaction.amountCents)}',
              style: TextStyle(fontWeight: FontWeight.w800, color: color,
                  fontSize: 13)),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 20, color: scheme.onSurfaceVariant),
            tooltip: 'Opções do lançamento',
            onSelected: (selection) {
              if (selection == 'edit') onTap();
              if (selection == 'delete') onDelete();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Editar')),
              PopupMenuItem(value: 'delete', child: Text('Excluir')),
            ],
          ),
        ]),
      ),
    );
  }
}
