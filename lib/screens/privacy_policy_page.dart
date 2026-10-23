import 'package:flutter/material.dart';

/// Politica de privacidade acessivel sem abrir navegador ou criar uma conta.
/// A versao publica atualizada fica em:
/// https://thealbum0207-art.github.io/fincontrol/privacy/
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const publicUrl =
      'https://thealbum0207-art.github.io/fincontrol/privacy/';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Política de Privacidade')),
      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 42),
          children: [
            Text('FinControl: Finanças Pessoais',
                style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('FluxTools • com.app.fincontrol'),
            const SizedBox(height: 4),
            const Text('Atualizada em 23 de outubro de 2026'),
            _section(context, '1. Dados financeiros no aparelho',
                'O FinControl permite cadastrar receitas, despesas, categorias, '
                'datas, observações e limites de orçamento. Essas informações '
                'são guardadas localmente, em um banco SQLite no dispositivo. '
                'O aplicativo não oferece integração bancária, conta de usuário '
                'ou sincronização com servidores da FluxTools. O conteúdo dos '
                'lançamentos não é enviado intencionalmente ao sistema de anúncios.'),
            _section(context, '2. Publicidade e dados técnicos',
                'O aplicativo integra o Google Mobile Ads SDK (AdMob) e uma '
                'plataforma de consentimento para anúncios. Conforme a '
                'configuração, a região e as escolhas do usuário, o SDK '
                'pode tratar endereço IP, localização aproximada derivada '
                'dele, identificadores do dispositivo ou de publicidade, '
                'interações com anúncios e dados de diagnóstico e desempenho. '
                'O Google e parceiros envolvidos na publicidade podem tratar '
                'esses dados para exibição de anúncios, mensuração, análise '
                'e prevenção de fraudes.'),
            _section(context, '3. Consentimento e controle',
                'Quando necessário, o FinControl consulta o consentimento '
                'antes de solicitar anúncios. Opções para revisar preferências '
                'podem aparecer conforme as regras da região. O Android também '
                'oferece controles para o identificador de publicidade.'),
            _section(context, '4. Compartilhamento',
                'A FluxTools não envia intencionalmente a terceiros o conteúdo '
                'dos registros financeiros locais. Dados técnicos de '
                'publicidade são tratados pelos provedores do SDK '
                'conforme suas próprias políticas.'),
            _section(context, '5. Segurança',
                'Os lançamentos ficam no armazenamento privado do aplicativo '
                'e estão sujeitos à segurança do dispositivo. O SDK de anúncios '
                'usa as medidas de proteção e transporte de dados declaradas '
                'pelo seu fornecedor. Nenhum sistema é totalmente imune a riscos.'),
            _section(context, '6. Retenção e exclusão',
                'Você pode excluir lançamentos e limites pelo próprio '
                'FinControl. Para apagar todos os registros locais, utilize '
                'Configurações do Android > Aplicativos > FinControl > '
                'Armazenamento > Limpar dados. A desinstalação também pode '
                'remover os dados locais, ressalvado eventual backup do Android. '
                'Não há restauração em nuvem oferecida pela FluxTools. '
                'A retenção de dados técnicos pelo Google segue as políticas '
                'desse fornecedor.'),
            _section(context, '7. Público e alterações',
                'O FinControl não foi projetado especificamente para crianças. '
                'Esta política pode ser atualizada se as funcionalidades ou '
                'integrações mudarem. A versão pública registra as alterações.'),
            _section(context, '8. Contato',
                'Desenvolvedora: FluxTools. Utilize o contato de suporte '
                'indicado na ficha do FinControl na Google Play, ou o canal '
                'público de questões do projeto no GitHub. Não compartilhe '
                'dados financeiros ou pessoais em questões públicas.'),
            const SizedBox(height: 22),
            Text('Política pública completa:',
                style: theme.textTheme.titleSmall),
            const SizedBox(height: 5),
            const SelectableText(publicUrl),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, String content) =>
      Padding(
        padding: const EdgeInsets.only(top: 23),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(content),
          ],
        ),
      );
}
