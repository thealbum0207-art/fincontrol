# Configuração integral da Google Play Console — FinControl
**Auditoria preparada em 24 de outubro de 2026 — sem acesso autenticado à conta Google.**

> Este documento é um roteiro verificável, não uma afirmação de que todos os itens foram aplicados na Play Console. Os estados refletem prints anteriores e código GitHub. Informações atuais da conta devem ser conferidas antes de publicar. Não editar nem publicar em produção sem validar migração dos dados financeiros.

## Identidade técnica — confirmada no repositório
- Aplicativo: FinControl: Finanças Pessoais
- Desenvolvedor informado: FluxTools
- Package: `com.app.fincontrol`
- AAB submetido à Play Console conforme print anterior: `2.0.2 (10003)` (em revisão no print de 23/10/2026; status atual não verificado).
- Próxima versão em PR rascunho: `2.0.3 (10004)`; **não enviada**.
- Flutter; banco local SQLite `fincontrol_v2.db`; integração Google Mobile Ads com modo de teste padrão.
- Política pública: https://thealbum0207-art.github.io/fincontrol/privacy/

## Ordem de checagem — bloquear novidades até eliminar pendências de produção
| Setor da Console | Situação conhecida | Ação e critério |
|---|---|---|
| Visão geral da publicação | Impressão anterior: lançamento de produção e política enviados à análise; publicação gerenciada ativa | Conferir se aprovados / prontos para publicar / rejeitados. NÃO publicar produção enquanto migração de dados estiver indefinida |
| Status da política | Rejeição de 23/10 por URL manus.space inválida | Novo link GitHub Pages salvo e enviado à análise. Conferir resultado e acessibilidade dentro do app atualmente publicado |
| ID de publicidade | Declaração `Sim`, motivo `Publicidade ou marketing` registrada | Confirmar se SDK inclui permissão AD_ID no manifesto final; marcar finalidades adicionais somente se verdadeiras |
| Contém anúncios | Não confirmado na Play Console | Declarar `Sim` se SDK e banner incluídos. Conferir ficha pública |
| Segurança dos dados | Não validado | Avaliar transferência efetiva pelo AdMob/UMP. Não selecionar 'não coleta dados' por base financeira ser SQLite. Consultar documentação oficial do SDK e declaração atual |
| Política de privacidade | URL pública funcionando no último teste | Texto identifica app e desenvolvedora, armazenamento local, dados de ads, segurança, exclusão e canal de suporte. Testar no Android e no navegador anônimo |
| Público-alvo | Não confirmado | Declarar faixas conforme público real; não classificar infantil sem comprovação. Conferir publicidade/consentimento |
| Acesso ao app | App local sem login no código atual | Informar acesso sem login, se corresponder ao AAB efetivo |
| Categoria | Não verificada | Sugerida: Apps → Finanças |
| Título/descrições | Não verificados | Preparado em `MARKETING_GOOGLE_PLAY.md`; evitar promessas de backup, integração bancária e renda |
| Contato de suporte | Não confirmado | Um e-mail de suporte válido, lido, e site do desenvolvedor (público) |
| Países/regiões | Não verificados | Priorizar Brasil, idioma pt-BR e BRL; expansão somente depois de tradução, suporte e conformidade local |
| Classificação indicativa | Não verificada | Conferir questionário compatível com funções e anúncios |
| Declarações de app financeiro | Não verificado | Conferir telas de recursos financeiros da Play; app é gerenciador financeiro, **não banco, não empréstimo** |
| Integridade / assinatura | Keystore de upload foi testada no Termux, mas status em todas as faixas não revalidado | Manter certificado original, versionCode crescente e Play App Signing |
| Relatório de pré-lançamento | Não consultado | Revisar ANRs/crashes, layout, acessibilidade, avisos críticos |
| Testes fechados / abertos | Prints indicam teste fechado concluído e aberto iniciado | Não significa produção pública; conferir status atual |
| Produção | Último print: versão 10003 enviada à revisão | Validar integridade e dados locais de 1.0.2 → 2.0.2 e 2.0.3 antes de liberar distribuição |
| Monetização AdMob | Status `Requer revisão`; nenhum vínculo à loja no print | Não configurar anúncios comerciais ainda; vincular app após estar publicamente disponível na Play |
| app-ads.txt | Preparado apenas em `admob_assets/app-ads.txt` no PR | Publicar `https://DOMINIO/app-ads.txt` na RAIZ do domínio listado na ficha pública. O GitHub Pages de projeto `/fincontrol/` sozinho NÃO cumpre a localização requerida |

## Loja: textos prontos e honestos

Nome: **FinControl: Finanças Pessoais**

Descrição curta (rascunho):
Controle receitas, despesas e orçamentos em um só aplicativo.

Descrição longa:
Ver `MARKETING_GOOGLE_PLAY.md`.

Notas da versão (somente quando corresponder ao AAB):
```
<pt-BR>
Organize suas receitas, despesas e limites de orçamento.
Consulte seus lançamentos e acompanhe seus gastos por categoria.
</pt-BR>
```

**Não dizer** que anúncios estão monetizados, que existem recursos premium, backups online ou integração com bancos se não estiverem no AAB publicado.

## Formulário Segurança dos dados — NÃO preencher automaticamente com suposições

Dois fluxos distintos:
1. **Lançamentos financeiros**: no código do repositório, persistem localmente em SQLite. Verificar se o AAB submetido é idêntico e se algum SDK recebe estes lançamentos. Coleta fora do dispositivo não está demonstrada.
2. **AdMob/UMP**: pode transmitir IP, identificadores de dispositivo/publicidade, interações e diagnósticos. Reconciliar tipos e finalidades exigidos pelo formulário com a versão instalada e com a documentação Google Mobile Ads.

Conferir também criptografia em trânsito, controle de exclusão, dados compartilhados e consentimento. Não inventar certificações ou selos de segurança.

## Políticas de pagamento
- Gratuito com anúncios é o modelo pretendido.
- Assinaturas e compras únicas não são suportadas atualmente pelo código e pela permissão de faturamento. NÃO cadastrar produtos para venda enquanto Billing não tiver sido implementado, testado e declarado.
- Verificar informações de contato comercial público sem confundir conta pessoal e empresa registrada.

## Próximo bloqueio técnico grave: persistência
A nova implementação usa `fincontrol_v2.db`. Não há migrador conhecido da versão anterior. Teste controlado com backup/dados fictícios antes de promover o app para distribuição ampla. Não pedir ao usuário para desinstalar o app com dados pessoais.

## Fontes oficiais
- https://support.google.com/googleplay/android-developer/answer/10787469
- https://support.google.com/googleplay/android-developer/answer/10144311
- https://support.google.com/admob/answer/10564477
- https://support.google.com/admob/answer/9363762
