import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/dates.dart';
import '../core/money.dart';
import '../data/finance_db.dart';
import '../data/v3_store.dart';
import '../models/fin_transaction.dart';

class TransactionFormPage extends StatefulWidget {
  const TransactionFormPage({super.key, this.existing});
  final FinTransaction? existing;

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _amount;
  late final TextEditingController _note;
  late TransactionKind _kind;
  late String _category;
  late DateTime _date;
  bool _saving = false;
  int _walletId = 1;
  List<Map<String, Object?>> _wallets = [{'id': 1, 'name': 'Principal'}];

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _title = TextEditingController(text: existing?.title ?? '');
    _amount = TextEditingController(text: existing == null
        ? ''
        : Money.format(existing.amountCents).replaceAll('R\$ ', ''));
    _note = TextEditingController(text: existing?.note ?? '');
    _kind = existing?.kind ?? TransactionKind.expense;
    _category = existing?.category ?? categoriesFor(_kind).first;
    _date = existing?.date ?? DateTime.now();
    _walletId = existing?.walletId ?? 1;
    _loadWallets();
  }

  Future<void> _loadWallets() async {
    try {
      final wallets = await V3Store.rows('wallets', orderBy: 'id');
      if (!mounted) return;
      setState(() { _wallets = wallets; });
    } catch (_) { /* Continue with the default wallet. */ }
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (result != null && mounted) setState(() => _date = result);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    final cents = Money.parsePositive(_amount.text);
    if (cents == null) return;
    setState(() => _saving = true);
    try {
      await FinanceDb.instance.upsert(FinTransaction(
        id: widget.existing?.id,
        title: _title.text.trim(),
        amountCents: cents,
        kind: _kind,
        category: _category,
        date: _date,
        note: _note.text.trim(),
        walletId: _walletId,
      ));
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Não foi possível salvar. Tente novamente.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null
          ? 'Novo lançamento' : 'Editar lançamento')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                children: [
                  const Text('Tipo de movimentação',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  SizedBox(width: double.infinity,
                    child: SegmentedButton<TransactionKind>(
                      showSelectedIcon: false,
                      selected: {_kind},
                      segments: const [
                        ButtonSegment(value: TransactionKind.expense,
                            label: Text('Despesa'), icon: Icon(Icons.arrow_upward)),
                        ButtonSegment(value: TransactionKind.income,
                            label: Text('Receita'), icon: Icon(Icons.arrow_downward)),
                      ],
                      onSelectionChanged: (selection) => setState(() {
                        _kind = selection.first;
                        _category = categoriesFor(_kind).first;
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _title,
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: 80,
                    decoration: const InputDecoration(labelText: 'Descrição',
                      hintText: 'Ex.: Mercado, salário, aluguel',
                      prefixIcon: Icon(Icons.edit_note_rounded)),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Informe uma descrição.' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _amount,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                    decoration: const InputDecoration(labelText: 'Valor (R\$)',
                      hintText: 'Ex.: 59,90', prefixIcon: Icon(Icons.payments_outlined)),
                    validator: (value) => Money.parsePositive(value ?? '') == null
                        ? 'Insira um valor positivo. Ex.: 59,90' : null,
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    key: ValueKey(_kind),
                    initialValue: _category,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Categoria',
                      prefixIcon: Icon(Icons.category_outlined)),
                    items: categoriesFor(_kind)
                        .map((category) => DropdownMenuItem(
                            value: category, child: Text(category))).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _category = value);
                    },
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<int>(
                    key: ValueKey(_walletId),
                    initialValue: _walletId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Carteira',
                      prefixIcon: Icon(Icons.account_balance_wallet_outlined)),
                    items: _wallets.map((wallet) => DropdownMenuItem<int>(
                      value: wallet['id'] as int,
                      child: Text(wallet['name'] as String))).toList(),
                    onChanged: (v) { if (v != null) setState(() => _walletId = v); },
                  ),
                  const SizedBox(height: 18),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.calendar_month_outlined, color: scheme.primary),
                      title: const Text('Data da movimentação'),
                      subtitle: Text(prettyDate(_date)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _selectDate,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _note,
                    maxLines: 3,
                    maxLength: 240,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(labelText: 'Observação (opcional)',
                      alignLabelWithHint: true),
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(height: 16, width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.check_circle_outline),
                    label: Text(_saving ? 'Salvando...' : 'Salvar lançamento'),
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 17)),
                  ),
                  const SizedBox(height: 12),
                  Text('Os dados são armazenados apenas neste aparelho.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}