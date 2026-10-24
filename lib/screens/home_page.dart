import 'dart:math' as math;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../ads/fin_ad_banner.dart';
import '../core/dates.dart';
import '../core/finance_math.dart';
import '../core/fin_theme.dart';
import '../core/money.dart';
import '../data/finance_db.dart';
import '../data/fin_export.dart';
import '../models/fin_transaction.dart';
import '../widgets/transaction_tile.dart';
import 'transaction_form_page.dart';
import 'privacy_policy_page.dart';

class FinHomePage extends StatefulWidget {
  const FinHomePage({super.key});

  @override
  State<FinHomePage> createState() => _FinHomePageState();
}

class _FinHomePageState extends State<FinHomePage> {
  DateTime _month = firstDayOfMonth(DateTime.now());
  int _tab = 0;
  bool _loading = true;
  String? _error;
  List<FinTransaction> _transactions = [];
  Map<String, int> _budgets = {};
  int _balanceCents = 0;
  String _query = '';
  TransactionKind? _filterKind;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() { _loading = true; _error = null; });
    try {
      final transactions = await FinanceDb.instance.monthTransactions(_month);
      final balance = await FinanceDb.instance.totalBalanceCents();
      final budgets = await FinanceDb.instance.loadBudgets();
      if (!mounted) return;
      setState(() {
        _transactions = transactions;
        _balanceCents = balance;
        _budgets = budgets;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Falha ao carregar os dados locais. Tente novamente.';
      });
    }
  }

  void _changeMonth(int offset) {
    setState(() => _month = DateTime(_month.year, _month.month + offset));
    _reload();
  }

  Future<void> _openForm([FinTransaction? transaction]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => TransactionFormPage(existing: transaction)),
    );
    if (saved == true) await _reload();
  }

  Future<void> _removeTransaction(FinTransaction transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir lançamento?'),
        content: Text('"${transaction.title}" será excluído permanentemente.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmed != true || transaction.id == null) return;
    try {
      await FinanceDb.instance.deleteTransaction(transaction.id!);
      await _reload();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Não foi possível excluir este lançamento.'),
      ));
    }
  }

  Future<void> _editBudget(String category) async {
    final controller = TextEditingController(text: _budgets[category] == null
        ? '' : Money.format(_budgets[category]!).replaceAll('R\$ ', ''));
    String? error;
    final existing = _budgets.containsKey(category);
    final action = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          title: Text('Orçamento: $category'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Defina um limite mensal para esta categoria.'),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Limite em R\$',
                  hintText: 'Ex.: 500,00', errorText: error),
            ),
          ]),
          actions: [
            if (existing) TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'delete'),
              child: const Text('Remover limite')),
            TextButton(onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar')),
            FilledButton(onPressed: () {
              if (Money.parsePositive(controller.text) == null) {
                setDialogState(() => error = 'Informe um valor válido e positivo.');
              } else {
                Navigator.pop(dialogContext, 'save');
              }
            }, child: const Text('Salvar')),
          ],
        );
      }),
    );
    // O diálogo já terminou; o valor do controller ainda está disponível.
    final cents = Money.parsePositive(controller.text);
    controller.dispose();
    if (action == null) return;
    try {
      if (action == 'delete') {
        await FinanceDb.instance.deleteBudget(category);
      } else if (action == 'save' && cents != null) {
        await FinanceDb.instance.setBudget(category, cents);
      }
      await _reload();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Não foi possível salvar o orçamento.'),
      ));
    }
  }

  Future<void> _exportData() async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Exportar dados financeiros?'),
        content: const Text(
          'O arquivo terá todos os lançamentos e limites de orçamento, '
          'incluindo descrições e valores. Ele NÃO é protegido por senha. '
          'Escolha um destino privado e não compartilhe publicamente. '
          'Esta função exporta os registros; ainda não importa arquivos '
          'nem recupera dados de versões antigas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    if (approved != true) return;
    try {
      final data = await FinExport.fromLocalDatabase();
      if (!mounted) return;
      final now = DateTime.now().toUtc();
      String digits(int n) => n.toString().padLeft(2, '0');
      final name = 'fincontrol_dados_${now.year}${digits(now.month)}'
          '${digits(now.day)}_${digits(now.hour)}${digits(now.minute)}.json';
      final result = await SharePlus.instance.share(
        ShareParams(
          title: 'Dados do FinControl',
          files: [XFile.fromData(
            utf8.encode(data),
            mimeType: 'application/json',
          )],
          fileNameOverrides: [name],
        ),
      );
      if (!mounted) return;
      if (result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Exportação compartilhada. Confirme se o arquivo '
              'foi salvo no destino escolhido.'),
        ));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Não foi possível exportar os dados. '
            'Nenhum lançamento foi alterado.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 74,
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: finGreen.withValues(alpha: .16),
                borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.trending_up_rounded, color: finGreen, size: 25),
          ),
          const SizedBox(width: 11),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('FinControl', style: TextStyle(fontWeight: FontWeight.w900,
                fontSize: 22, letterSpacing: -.6)),
            Text('Seu dinheiro sob controle',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400)),
          ]),
        ]),
        actions: [IconButton(
          tooltip: 'Política de Privacidade',
          icon: const Icon(Icons.privacy_tip_outlined),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
                builder: (_) => const PrivacyPolicyPage()),
          ),
        ), PopupMenuButton<String>(
          tooltip: 'Mais opções',
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'export') {
              _exportData();
            } else if (value == 'about') {
              showAboutDialog(
                context: context,
                applicationName: 'FinControl',
                applicationVersion: '2.0.3',
                children: [const Text(
                  'Receitas, despesas e orçamentos ficam neste aparelho, '
                  'em um banco SQLite local. Esta versão não possui '
                  'sincronização ou integração bancária. Use a opção '
                  'Exportar dados para guardar uma cópia externa. '
                  'A exportação não recupera registros de versões antigas.',
                )],
              );
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem<String>(
              value: 'export',
              child: ListTile(
                dense: true,
                leading: Icon(Icons.file_upload_outlined),
                title: Text('Exportar dados'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem<String>(
              value: 'about',
              child: ListTile(
                dense: true,
                leading: Icon(Icons.info_outline_rounded),
                title: Text('Sobre os dados'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ), const SizedBox(width: 8)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _errorView()
              : Center(child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: RefreshIndicator(
                    onRefresh: _reload,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 110),
                      children: [
                        _monthSwitcher(),
                        const SizedBox(height: 21),
                        if (_tab == 0) _overview()
                        else if (_tab == 1) _transactionsPage()
                        else _budgetsPage(),
                      ],
                    ),
                  ),
                )),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FinAdBanner(),
          NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.space_dashboard_outlined),
              selectedIcon: Icon(Icons.space_dashboard), label: 'Resumo'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long), label: 'Lançamentos'),
          NavigationDestination(icon: Icon(Icons.track_changes_outlined),
              selectedIcon: Icon(Icons.track_changes), label: 'Orçamentos'),
        ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading ? null : () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Lançamento',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _errorView() => Center(child: Column(
    mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.error_outline, size: 40),
      const SizedBox(height: 10),
      Text(_error!),
      TextButton(onPressed: _reload, child: const Text('Tentar novamente')),
    ],
  ));

  Widget _monthSwitcher() => Row(children: [
    IconButton(tooltip: 'Mês anterior', icon: const Icon(Icons.chevron_left),
        onPressed: () => _changeMonth(-1)),
    Expanded(child: Column(children: [
      const Text('PERÍODO', style: TextStyle(fontSize: 10,
          letterSpacing: 2, fontWeight: FontWeight.w800)),
      const SizedBox(height: 3),
      Text(monthLabel(_month), style: const TextStyle(fontWeight: FontWeight.w800,
          fontSize: 17)),
    ])),
    IconButton(tooltip: 'Próximo mês', icon: const Icon(Icons.chevron_right),
        onPressed: () => _changeMonth(1)),
  ]);

  Widget _overview() {
    final totals = sumTransactions(_transactions);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27),
          gradient: const LinearGradient(
            colors: [Color(0xFF153D39), Color(0xFF10252B), Color(0xFF0F1924)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .10),
              blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.account_balance_wallet_outlined,
                color: Color(0xFF81E5CE), size: 21),
            SizedBox(width: 9),
            Text('SALDO TOTAL REGISTRADO', style: TextStyle(
                color: Color(0xFFB8D9D1), fontSize: 11,
                letterSpacing: 1.25, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 18),
          FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
              child: Text(Money.format(_balanceCents), style: const TextStyle(
                fontSize: 37, fontWeight: FontWeight.w900,
                color: Colors.white, letterSpacing: -1.5))),
          const SizedBox(height: 17),
          const Text('Soma das movimentações cadastradas',
              style: TextStyle(color: Color(0xFFAFC7C2), fontSize: 12)),
        ]),
      ),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: _miniCard('Receitas', totals.incomeCents,
            Icons.arrow_downward_rounded, const Color(0xFF15AA83))),
        const SizedBox(width: 12),
        Expanded(child: _miniCard('Despesas', totals.expenseCents,
            Icons.arrow_upward_rounded, const Color(0xFFD76B68))),
      ]),
      const SizedBox(height: 26),
      _sectionTitle('Gastos por categoria',
          subtitle: 'Distribuição neste mês'),
      const SizedBox(height: 11),
      _categoryChart(),
      const SizedBox(height: 24),
      _sectionTitle('Últimos lançamentos',
          trailing: TextButton(
              onPressed: () => setState(() => _tab = 1),
              child: const Text('Ver todos'))),
      const SizedBox(height: 9),
      if (_transactions.isEmpty)
        _emptyState('Nada registrado neste mês',
            'Toque em + Lançamento para começar o controle financeiro.')
      else
        ..._transactions.take(5).map(_transactionTile),
    ]);
  }

  Widget _miniCard(String title, int value, IconData icon, Color color) => Card(
    margin: EdgeInsets.zero,
    child: Padding(padding: const EdgeInsets.all(17), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(radius: 18, backgroundColor: color.withValues(alpha: .14),
            child: Icon(icon, color: color, size: 19)),
        const SizedBox(height: 11),
        Text(title, style: TextStyle(fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 5),
        FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
          child: Text(Money.format(value), style: const TextStyle(
              fontSize: 19, fontWeight: FontWeight.w900))),
      ],
    )),
  );

  Widget _categoryChart() {
    final categoryAmounts = expenseByCategory(_transactions);
    if (categoryAmounts.isEmpty) {
      return _emptyState(
          'Sem despesas no período',
          'Os gráficos aparecem quando você registra despesas.');
    }
    final sorted = categoryAmounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxValue = math.max(1, sorted.first.value);
    final colors = [const Color(0xFF23C59E), const Color(0xFF5F9AE8),
      const Color(0xFFE7B95A), const Color(0xFFBE91E5),
      const Color(0xFFE77F9A)];
    return Card(margin: EdgeInsets.zero, child: Padding(
      padding: const EdgeInsets.all(19),
      child: Column(children: [
        for (var i = 0; i < sorted.length; i++) ...[
          if (i != 0) const SizedBox(height: 16),
          Row(children: [
            Expanded(child: Text(sorted[i].key, style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 13))),
            Text(Money.format(sorted[i].value), style: const TextStyle(
                fontWeight: FontWeight.w800, fontSize: 12)),
          ]),
          const SizedBox(height: 7),
          ClipRRect(borderRadius: BorderRadius.circular(10), child:
            LinearProgressIndicator(
              minHeight: 9,
              value: sorted[i].value / maxValue,
              color: colors[i % colors.length],
              backgroundColor: colors[i % colors.length].withValues(alpha: .12),
            )),
        ],
      ]),
    ));
  }

  Widget _transactionsPage() {
    final query = _query.toLowerCase().trim();
    final filtered = _transactions.where((tx) {
      if (_filterKind != null && tx.kind != _filterKind) return false;
      if (query.isEmpty) return true;
      return tx.title.toLowerCase().contains(query) ||
          tx.category.toLowerCase().contains(query) ||
          tx.note.toLowerCase().contains(query);
    }).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle('Lançamentos do mês',
          subtitle: '${_transactions.length} movimentação(ões) registrada(s)'),
      const SizedBox(height: 14),
      TextField(
        onChanged: (text) => setState(() => _query = text),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search), hintText: 'Pesquisar descrição, categoria...'),
      ),
      const SizedBox(height: 12),
      Wrap(spacing: 8, children: [
        ChoiceChip(label: const Text('Todos'), selected: _filterKind == null,
          onSelected: (_) => setState(() => _filterKind = null)),
        ChoiceChip(label: const Text('Receitas'),
          selected: _filterKind == TransactionKind.income,
          onSelected: (_) => setState(() => _filterKind = TransactionKind.income)),
        ChoiceChip(label: const Text('Despesas'),
          selected: _filterKind == TransactionKind.expense,
          onSelected: (_) => setState(() => _filterKind = TransactionKind.expense)),
      ]),
      const SizedBox(height: 15),
      if (filtered.isEmpty)
        _emptyState('Nenhum resultado',
            'Cadastre uma movimentação ou ajuste os filtros.')
      else
        ...filtered.map(_transactionTile),
    ]);
  }

  Widget _budgetsPage() {
    final categoryExpenses = expenseByCategory(_transactions);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle('Orçamentos mensais',
          subtitle: 'Defina limites e acompanhe seus gastos'),
      const SizedBox(height: 9),
      const Text('Os limites são reutilizados a cada mês. Toque em uma categoria para configurar.',
          style: TextStyle(fontSize: 13)),
      const SizedBox(height: 15),
      for (final category in expenseCategories) ...[
        _budgetTile(category, categoryExpenses[category] ?? 0),
        const SizedBox(height: 9),
      ],
    ]);
  }

  Widget _budgetTile(String category, int spent) {
    final budget = _budgets[category];
    final scheme = Theme.of(context).colorScheme;
    final overflow = budget != null && spent > budget;
    return Card(margin: EdgeInsets.zero, child: InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => _editBudget(category),
      child: Padding(padding: const EdgeInsets.all(17), child: Column(children: [
        Row(children: [
          Expanded(child: Text(category,
              style: const TextStyle(fontWeight: FontWeight.w800))),
          Icon(Icons.edit_outlined, size: 17, color: scheme.onSurfaceVariant),
        ]),
        const SizedBox(height: 11),
        Row(children: [
          Expanded(child: Text('Gasto: ${Money.format(spent)}',
              style: const TextStyle(fontSize: 12))),
          Text(budget == null ? 'Definir limite' : 'Limite: ${Money.format(budget)}',
              style: TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: overflow ? scheme.error : scheme.onSurfaceVariant)),
        ]),
        if (budget != null) ...[
          const SizedBox(height: 10),
          ClipRRect(borderRadius: BorderRadius.circular(9),
            child: LinearProgressIndicator(
              value: (spent / budget).clamp(0.0, 1.0).toDouble(),
              minHeight: 9,
              color: overflow ? scheme.error : finGreen,
              backgroundColor: finGreen.withValues(alpha: .10),
            )),
          if (overflow) ...[
            const SizedBox(height: 7),
            Align(alignment: Alignment.centerLeft,
                child: Text('Ultrapassou o limite em ${Money.format(spent - budget)}',
                    style: TextStyle(color: scheme.error, fontSize: 12))),
          ],
        ],
      ])),
    ));
  }

  Widget _transactionTile(FinTransaction transaction) => TransactionTile(
    transaction: transaction,
    onTap: () => _openForm(transaction),
    onDelete: () => _removeTransaction(transaction),
  );

  Widget _sectionTitle(String text, {String? subtitle, Widget? trailing}) => Row(
    children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19)),
            if (subtitle != null) ...[
              const SizedBox(height: 3),
              Text(subtitle, style: TextStyle(fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ])),
      ?trailing,
    ],
  );

  Widget _emptyState(String title, String description) => Card(
    margin: EdgeInsets.zero, child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 27),
      child: Column(children: [
        const Icon(Icons.insights_outlined, size: 39, color: finGreen),
        const SizedBox(height: 10),
        Text(title, textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 7),
        Text(description, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ]),
    ),
  );
}