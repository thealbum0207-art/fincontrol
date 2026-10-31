import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/money.dart';
import '../data/v3_store.dart';
import 'security_page.dart';

const featureNames = [
  'Contas recorrentes', 'Metas financeiras', 'Cartões e parcelas',
  'Relatórios avançados', 'Assistente financeiro', 'Calendário financeiro',
  'Backup e exportação', 'Biometria e PIN', 'Múltiplas carteiras',
  'Previsão de 30 dias',
];
const featureIcons = [
  Icons.repeat_rounded, Icons.flag_rounded, Icons.credit_card_rounded,
  Icons.bar_chart_rounded, Icons.tips_and_updates_rounded,
  Icons.calendar_month_rounded, Icons.file_download_rounded,
  Icons.fingerprint_rounded, Icons.account_balance_wallet_rounded,
  Icons.trending_up_rounded,
];

class V3HubPage extends StatelessWidget {
  const V3HubPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('FinControl 3.0')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Card(child: Padding(padding: const EdgeInsets.all(22), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FINANÇAS MAIS SIMPLES', style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          const Text('Planeje. Acompanhe. Evolua.',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Ferramentas locais, sem anúncios e sem conexão bancária.'),
        ],
      ))),
      const SizedBox(height: 12),
      for (var i = 0; i < featureNames.length; i++)
        Card(child: ListTile(
          leading: Icon(featureIcons[i]),
          title: Text(featureNames[i]),
          subtitle: i == 4 ? const Text('Regras locais, sem envio dos seus dados')
            : null,
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => i == 7
              ? const SecurityPage()
              : V3FeaturePage(feature: i))),
        )),
    ]),
  );
}

class V3FeaturePage extends StatefulWidget {
  const V3FeaturePage({super.key, required this.feature});
  final int feature;

  @override
  State<V3FeaturePage> createState() => _V3FeaturePageState();
}

class _V3FeaturePageState extends State<V3FeaturePage> {
  late Future<Map<String, Object?>> _future;

  @override
  void initState() { super.initState(); _future = _fetch(); }

  void _refresh() => setState(() => _future = _fetch());

  Future<Map<String, Object?>> _fetch() async {
    switch (widget.feature) {
      case 0: return {'rules': await V3Store.rows('recurring_rules',
        orderBy: 'next_due_key')};
      case 1: return {'goals': await V3Store.rows('savings_goals', orderBy: 'id DESC')};
      case 2: return {
        'cards': await V3Store.rows('credit_cards', orderBy: 'id DESC'),
        'parts': await V3Store.rows('card_installments',
          orderBy: 'due_key, id'),
      };
      case 3: return {
        'current': await V3Store.monthlyReport(DateTime.now()),
        'prior': await V3Store.monthlyReport(
          DateTime(DateTime.now().year, DateTime.now().month - 1)),
      };
      case 4: return {'current': await V3Store.monthlyReport(DateTime.now()),
        'prior': await V3Store.monthlyReport(
          DateTime(DateTime.now().year, DateTime.now().month - 1)),
        'budgets': await V3Store.rows('budgets')};
      case 5: return {
        'rules': await V3Store.rows('recurring_rules',
          where: 'enabled = 1', orderBy: 'next_due_key'),
        'parts': await V3Store.rows('card_installments',
          where: 'posted_transaction_id IS NULL', orderBy: 'due_key'),
      };
      case 8:
        final wallets = await V3Store.rows('wallets', orderBy: 'id');
        final balances = <int, int>{};
        for (final wallet in wallets) {
          final id = wallet['id'] as int;
          balances[id] = await V3Store.balanceForWallet(id);
        }
        return {'wallets': wallets, 'balances': balances};
      case 9: return {'forecast': await V3Store.forecast30Days(DateTime.now())};
      default: return {};
    }
  }

  Future<List<String>?> _prompt(String title, List<String> labels) async {
    final controllers = labels.map((_) => TextEditingController()).toList();
    final values = await showDialog<List<String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < labels.length; i++)
              Padding(padding: const EdgeInsets.only(bottom: 12),
                child: TextField(controller: controllers[i],
                  keyboardType: labels[i].contains('R\$') ||
                      labels[i].contains('parcelas') ||
                      labels[i].contains('Dia')
                    ? const TextInputType.numberWithOptions(decimal: true)
                    : TextInputType.text,
                  decoration: InputDecoration(labelText: labels[i]))),
          ],
        )),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx,
            controllers.map((c) => c.text.trim()).toList()),
            child: const Text('Salvar')),
        ],
      ),
    );
    for (final c in controllers) { c.dispose(); }
    return values;
  }

  int? _cents(String input) => Money.parsePositive(input);

  Future<DateTime?> _date() async => showDatePicker(
    context: context, initialDate: DateTime.now(),
    firstDate: DateTime(2020), lastDate: DateTime(2100));

  Future<void> _execute(Future<void> Function() task) async {
    try {
      await task();
      if (!mounted) return;
      _refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Salvo no aparelho.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível concluir: $error')));
    }
  }

  Future<void> _createRecurring(bool income) async {
    final input = await _prompt(income ? 'Nova receita recorrente' :
      'Nova conta recorrente', ['Descrição', 'Valor (R\$)', 'Categoria']);
    if (input == null) return;
    if (!mounted) return;
    final due = await _date();
    final cents = _cents(input[1]);
    if (due == null || cents == null || input[0].isEmpty) return;
    await _execute(() => V3Store.addRecurring(
      title: input[0], amountCents: cents, income: income,
      category: input[2].isEmpty ? 'Outros' : input[2], nextDue: due));
  }

  Future<void> _createGoal() async {
    final input = await _prompt('Nova meta', ['Objetivo', 'Valor alvo (R\$)']);
    if (input == null) return;
    final cents = _cents(input[1]);
    if (cents == null || input[0].isEmpty) return;
    await _execute(() => V3Store.addGoal(input[0], cents));
  }

  Future<void> _contribute(int id) async {
    final input = await _prompt('Registrar progresso da meta', ['Valor (R\$)']);
    if (input == null) return;
    final cents = _cents(input[0]);
    if (cents == null) return;
    await _execute(() => V3Store.contribute(id, cents));
  }

  Future<void> _createCard() async {
    final input = await _prompt('Novo cartão',
        ['Nome do cartão', 'Limite (R\$)', 'Dia de vencimento (1 a 28)']);
    if (input == null) return;
    final cents = _cents(input[1]), day = int.tryParse(input[2]);
    if (cents == null || day == null || input[0].isEmpty) return;
    await _execute(() => V3Store.addCard(input[0], cents, day));
  }

  Future<void> _purchase(int cardId) async {
    final input = await _prompt('Compra parcelada',
        ['Descrição', 'Valor total (R\$)', 'Número de parcelas']);
    if (input == null) return;
    final cents = _cents(input[1]), parts = int.tryParse(input[2]);
    if (cents == null || parts == null || input[0].isEmpty) return;
    if (!mounted) return;
    final firstDue = await _date();
    if (firstDue == null) return;
    await _execute(() => V3Store.addPurchase(cardId: cardId, title: input[0],
        totalCents: cents, parts: parts, firstDue: firstDue));
  }

  Future<void> _pay(int id) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) =>
      AlertDialog(title: const Text('Confirmar pagamento?'),
        content: const Text('Esta parcela será registrada como despesa na carteira Principal.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Paguei')),
        ]));
    if (ok == true) await _execute(() => V3Store.payInstallment(id));
  }

  Future<void> _createWallet() async {
    final input = await _prompt('Nova carteira', ['Nome da carteira']);
    if (input == null || input[0].isEmpty) return;
    await _execute(() => V3Store.addWallet(input[0]));
  }

  Future<void> _transfer(List<Map<String, Object?>> wallets) async {
    if (wallets.length < 2) return;
    var from = wallets.first['id'] as int;
    var to = wallets.last['id'] as int;
    final amount = TextEditingController();
    final result = await showDialog<List<int>>(context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, update) => AlertDialog(
        title: const Text('Transferir entre carteiras'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<int>(initialValue: from,
            decoration: const InputDecoration(labelText: 'Origem'),
            items: wallets.map((w) => DropdownMenuItem<int>(
              value: w['id'] as int, child: Text(w['name'] as String))).toList(),
            onChanged: (v) { if (v != null) update(() => from = v); }),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(initialValue: to,
            decoration: const InputDecoration(labelText: 'Destino'),
            items: wallets.map((w) => DropdownMenuItem<int>(
              value: w['id'] as int, child: Text(w['name'] as String))).toList(),
            onChanged: (v) { if (v != null) update(() => to = v); }),
          const SizedBox(height: 12),
          TextField(controller: amount, keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Valor (R\$)')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx,
            [from, to, _cents(amount.text) ?? 0]), child: const Text('Transferir')),
        ],
      )));
    amount.dispose();
    if (result == null || result[0] == result[1] || result[2] <= 0) return;
    await _execute(() => V3Store.transfer(result[0], result[1], result[2]));
  }

  Future<void> _export(bool json) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) =>
      AlertDialog(title: const Text('Exportar dados financeiros?'),
        content: const Text('O arquivo exportado NÃO é criptografado. '
          'Envie apenas para um local privado e seguro. '
          'Esta etapa cria uma cópia; a importação ainda não está disponível.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Exportar')),
        ]));
    if (ok != true) return;
    try {
      final content = json ? await V3Store.backupJson()
        : await V3Store.transactionsCsv();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/fincontrol_backup.${json ? 'json' : 'csv'}');
      await file.writeAsString(content, flush: true);
      await Share.shareXFiles([XFile(file.path)],
        subject: 'Exportação FinControl');
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro na exportação: $err')));
    }
  }

  Widget _tile(String title, String subtitle, {VoidCallback? onTap,
      IconData icon = Icons.chevron_right}) => Card(
    child: ListTile(title: Text(title), subtitle: Text(subtitle),
      trailing: onTap == null ? null : Icon(icon), onTap: onTap));

  Widget _content(Map<String, Object?> data) {
    switch (widget.feature) {
      case 0:
        final rules = data['rules'] as List<Map<String, Object?>>;
        return Column(children: [
          _tile('Nova despesa mensal', 'Cadastrar aluguel, contas e assinaturas',
            icon: Icons.add, onTap: () => _createRecurring(false)),
          _tile('Nova receita mensal', 'Cadastrar salário ou outras receitas',
            icon: Icons.add, onTap: () => _createRecurring(true)),
          for (final r in rules)
            _tile('${r['title']} • ${Money.format(r['amount_cents'] as int)}',
              'Próximo: ${r['next_due_key']} • ${r['kind'] == 'income' ? 'Receita' : 'Despesa'}'
              ' • Toque para lançar e avançar a data',
              onTap: () => _execute(() => V3Store.postRecurring(r['id'] as int))),
        ]);
      case 1:
        final goals = data['goals'] as List<Map<String, Object?>>;
        return Column(children: [
          _tile('Criar meta', 'Reserve um objetivo, acompanhe o progresso',
            icon: Icons.add, onTap: _createGoal),
          for (final g in goals) ...[
            _tile(g['title'] as String,
              '${Money.format(g['saved_cents'] as int)} de '
              '${Money.format(g['target_cents'] as int)} • Toque para atualizar',
              onTap: () => _contribute(g['id'] as int)),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LinearProgressIndicator(value: ((g['saved_cents'] as int) /
                (g['target_cents'] as int)).clamp(0.0, 1.0))),
          ],
          const SizedBox(height: 12),
          const Text('O progresso da meta não movimenta o saldo.'),
        ]);
      case 2:
        final cards = data['cards'] as List<Map<String, Object?>>;
        final parts = data['parts'] as List<Map<String, Object?>>;
        return Column(children: [
          _tile('Adicionar cartão', 'Definir limite e vencimento',
            icon: Icons.add, onTap: _createCard),
          for (final card in cards)
            _tile(card['name'] as String,
              'Limite: ${Money.format(card['limit_cents'] as int)}'
              ' • Vence dia ${card['due_day']} • Toque para parcelar compra',
              onTap: () => _purchase(card['id'] as int)),
          const ListTile(title: Text('Parcelas cadastradas')),
          for (final p in parts)
            _tile('${p['description']} • ${p['part']}/${p['parts']}',
              '${Money.format(p['amount_cents'] as int)} • ${p['due_key']}'
              ' • ${p['posted_transaction_id'] == null ? 'Pendente' : 'Pago'}',
              onTap: p['posted_transaction_id'] == null
                ? () => _pay(p['id'] as int) : null),
        ]);
      case 3:
        final current = data['current'] as Map<String, Object?>;
        final prior = data['prior'] as Map<String, Object?>;
        final expense = current['expense_cents'] as int;
        final previous = prior['expense_cents'] as int;
        final categories = current['categories'] as List<Map<String, Object?>>;
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _tile('Receitas do mês', Money.format(current['income_cents'] as int)),
          _tile('Despesas do mês', Money.format(expense)),
          _tile('Despesas do mês anterior', Money.format(previous)),
          _tile('Diferença mensal', Money.format(expense - previous)),
          for (final c in categories) ...[
            _tile(c['category'] as String, Money.format((c['total'] as num).toInt())),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 18),
              child: LinearProgressIndicator(value: expense == 0 ? 0 :
                ((c['total'] as num).toDouble() / expense).clamp(0.0, 1.0))),
          ],
        ]);
      case 4:
        final now = data['current'] as Map<String, Object?>;
        final prev = data['prior'] as Map<String, Object?>;
        final expense = now['expense_cents'] as int;
        final income = now['income_cents'] as int;
        final diff = expense - (prev['expense_cents'] as int);
        final categories = now['categories'] as List<Map<String, Object?>>;
        return Column(children: [
          _tile('Análise automática offline',
            'Baseada nos seus registros; não é aconselhamento financeiro.'),
          if (expense > income) _tile('Atenção ao orçamento',
            'As despesas do mês superam as receitas cadastradas.'),
          if (expense <= income) _tile('Balanço mensal',
            'As receitas do mês cobrem as despesas registradas.'),
          _tile('Comparação com o mês anterior',
            diff > 0 ? 'Seus gastos aumentaram ${Money.format(diff)}.'
              : 'Seus gastos caíram ou ficaram iguais: ${Money.format(-diff)}.'),
          if (categories.isNotEmpty)
            _tile('Maior categoria de gastos',
              '${categories.first['category']}: '
              '${Money.format((categories.first['total'] as num).toInt())}'),
          _tile('Privacidade',
            'Nenhum dado foi enviado a uma inteligência artificial externa.'),
        ]);
      case 5:
        final rules = data['rules'] as List<Map<String, Object?>>;
        final parts = data['parts'] as List<Map<String, Object?>>;
        final events = <({String day, String title, int cents})>[
          for (final r in rules)
            (day: r['next_due_key'] as String, title: r['title'] as String,
              cents: r['amount_cents'] as int),
          for (final p in parts)
            (day: p['due_key'] as String, title: '${p['description']} '
              '${p['part']}/${p['parts']}', cents: p['amount_cents'] as int),
        ]..sort((a,b) => a.day.compareTo(b.day));
        return Column(children: [
          _tile('Agenda de pagamentos', 'Eventos previstos; sem lembretes automáticos.'),
          for (final e in events)
            _tile(e.day, '${e.title} • ${Money.format(e.cents)}'),
        ]);
      case 6: return Column(children: [
        _tile('Backup JSON', 'Cópia de todas as tabelas financeiras',
          icon: Icons.share, onTap: () => _export(true)),
        _tile('Exportar CSV', 'Planilha com os lançamentos',
          icon: Icons.share, onTap: () => _export(false)),
        const Padding(padding: EdgeInsets.all(16),
          child: Text('Conserve suas cópias em local privado. '
            'A restauração automática ainda não foi implementada.')),
      ]);
      case 8:
        final wallets = data['wallets'] as List<Map<String, Object?>>;
        final balances = data['balances'] as Map<int, int>;
        return Column(children: [
          _tile('Criar carteira', 'Separe banco, dinheiro e reservas',
            icon: Icons.add, onTap: _createWallet),
          if (wallets.length > 1)
            _tile('Transferir', 'Movimentar valores sem mudar o saldo total',
              icon: Icons.swap_horiz, onTap: () => _transfer(wallets)),
          for (final w in wallets)
            _tile(w['name'] as String,
              'Saldo: ${Money.format(balances[w['id']] ?? 0)}'),
        ]);
      case 9:
        final f = data['forecast'] as Map<String, int>;
        return Column(children: [
          _tile('Saldo registrado', Money.format(f['balance_cents']!)),
          _tile('Receitas recorrentes previstas',
            Money.format(f['income_cents']!)),
          _tile('Contas e parcelas previstas',
            Money.format(f['expense_cents']!)),
          _tile('Estimativa para 30 dias',
            Money.format(f['estimate_cents']!)),
          const Padding(padding: EdgeInsets.all(16),
            child: Text('Projeção estimada a partir das contas recorrentes '
              'e parcelas pendentes. Não inclui despesas futuras não registradas.')),
        ]);
      default: return const Text('Em desenvolvimento');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(featureNames[widget.feature])),
    body: FutureBuilder<Map<String, Object?>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Não foi possível carregar os dados: ${snapshot.error}')));
        if (!snapshot.hasData) return const Center(
          child: CircularProgressIndicator());
        return RefreshIndicator(onRefresh: () async { _refresh(); },
          child: ListView(padding: const EdgeInsets.all(16),
            children: [_content(snapshot.data!)]));
      },
    ),
  );
}
