# FinControl — prontidão para monetização AdMob (27/10/2026)

> Documento preparatório. **Nenhuma mudança de código, versão, publicação, conta AdMob ou faturamento é efetuada por este documento.**
> Não habilitar anúncios comerciais enquanto existirem pendências de verificação, privacidade ou testes.

## Resumo comprovado

- **Pacote Android:** `com.app.fincontrol`.
- **Google Play pública:** https://play.google.com/store/apps/details?id=com.app.fincontrol — página acessível em 27/10/2026, listando versão pública 2.0.2 e desenvolvedora FluxTools.
- **Site do desenvolvedor:** https://thealbum0207-art.github.io/ — acessível, e presente no campo *Site* da ficha pública da loja.
- **Arquivo app-ads.txt:** https://thealbum0207-art.github.io/app-ads.txt — acessível publicamente com:
  `google.com, pub-3964603090393340, DIRECT, f08c47fec0942fa0`
  Esta é **somente a verificação de hospedagem e conteúdo**; não comprova o status 'Verificado' no painel AdMob.
- **Política pública:** https://thealbum0207-art.github.io/fincontrol/privacy/ — reconhece o tratamento de dados técnicos pelo Google Mobile Ads SDK.
- **Código da 2.0.5 na branch de hotfix:** usa `google_mobile_ads: 9.1.0`, `APPLICATION_ID` `ca-app-pub-3964603090393340~3759405239`, banner comercial `ca-app-pub-3964603090393340/4111381146`, mas **o build 2.0.5 (10006) foi gerado com `ADMOB_LIVE_ADS=false`**, por isso mostra banners de teste. A tela observada pelo usuário comprova exibição de demo banner 320x50.
- A integração chama UMP `requestConsentInfoUpdate`, `loadAndShowConsentFormIfRequired`, `canRequestAds` antes de solicitar anúncios. **A existência do código não confirma mensagens ou configurações publicadas no painel AdMob.**

## Pendências com prioridade máxima

### 1. Corrigir *Segurança dos dados* da Play Console (ANTES de anúncios reais)

A ficha **pública** da Play Store, consultada em 27/10/2026, exibe:
- "Os dados não são compartilhados com terceiros";
- "Nenhum dado foi coletado".

A política pública do próprio FinControl e a documentação do Google Mobile Ads SDK indicam **possível/integrada coleta e compartilhamento de dados técnicos pela biblioteca de anúncios**. Essas declarações precisam ser reconciliadas com a versão efetivamente distribuída.

**Não marcar respostas automaticamente:** o formulário depende das práticas reais do app, da biblioteca e do modelo de tratamento (inclusive exceções de prestador de serviço). Conferir no Play Console → Política e programas → Conteúdo do app → Segurança dos dados. Tipos a verificar segundo documentação da Google: endereço IP/localização aproximada inferida, atividade/interações, desempenho/diagnósticos, identificadores de dispositivo e publicidade. Finalidades possíveis: publicidade, mensuração/análise, prevenção de fraude. Conferir coleta, compartilhamento, obrigatoriedade, exclusão e criptografia de ponta a ponta ou trânsito **somente com evidências**. A seção sobre dados financeiros locais pode continuar distinta dos dados técnicos do SDK: não dizer que transações locais são enviadas ao Google sem evidência.

Fontes:
- https://developers.google.com/admob/android/privacy/play-data-disclosure
- https://support.google.com/googleplay/android-developer/answer/10787469

### 2. Associar corretamente o app publicado ao AdMob

No AdMob → Apps → FinControl → Configurações do aplicativo:
- Conferir se *Detalhes da app store* contém a **Google Play** com pacote `com.app.fincontrol` e URL pública.
- Em 26/10/2026 o painel do usuário mostrava 'Detalhes da app store' vazios e estado **Requer revisão**. Isso é evidência passada, não uma leitura atual da conta.
- Se ainda estiver vazia, escolher **Adicionar** e localizar pelo título ou URL pública; não adicionar como loja alternativa inexistente, nem duplicar o app AdMob.
- Depois confirmar **Verificar app / Verificar se há atualizações** se for solicitado.
- O app só fica pronto para anúncios comerciais após app-ads.txt *verificado* e análise de prontidão AdMob *Pronto*. Aprovação não é automática.

Fontes:
- https://support.google.com/admob/answer/14538460?hl=pt-BR
- https://support.google.com/admob/answer/10564477?hl=pt-BR

### 3. Conferir app-ads.txt dentro do painel

No AdMob → Apps → Todos os aplicativos → aba app-ads.txt, conferir status *Verificado*. Se disponível, solicitar *Verificar se há atualizações*. A simples visualização do texto no navegador não prova verificação. Depois de atualizar o site da loja, a detecção pode levar até 24 horas ou mais conforme caso.

Fonte: https://support.google.com/admob/answer/9363762?hl=pt-BR

### 4. Mensagens de privacidade e UMP

AdMob → Privacidade e mensagens:
- Verificar publicação de mensagens e seleção do aplicativo, em especial para EEE, Reino Unido e Suíça.
- Confirmar que o usuário consegue revisar opções quando o SDK informar que o controle é obrigatório.
- Conferir atendimento a exigências adicionais dos países efetivamente atingidos; configuração do SDK sozinha não comprova conformidade.
- Registrar **status verificado** antes de gerar um pacote comercial.

Fonte: https://support.google.com/admob/answer/10113207?hl=pt-BR

### 5. Pagamentos, conta e aprovação

AdMob → Pagamentos: conferir se o cadastro da conta, identidade/dados necessários e recebimento estão completos. Não presumir que o perfil da Google Play ou de outros produtos Google supre todas as verificações. AdMob → Apps: estado do FinControl deve ser **Pronto** antes de tratar banners como produção. AdMob → Central de políticas: sem problemas impeditivos.

### 6. Confirmar segurança funcional antes do lançamento

- Versão 2.0.5 (10006): teste interno mostra app abrindo e banner de teste, mas **migração/preservação de dados financeiros existentes não foi comprovada**; o usuário viu zero lançamentos.
- Testar em Android real: criar registros fictícios, encerrar, reabrir, navegar de mês e, quando possível, atualizar por cima de instalação já existente, mantendo dados. Não desinstalar/limpar dados de usuários para testar.
- Confirmar que o banner permanece fora dos botões e não causa cliques acidentais; as capturas mostraram botão flutuante sobre conteúdo.
- Sem cliques próprios nos anúncios de produção: usar IDs de demonstração/dispositivos de teste nos testes.

Fonte: https://support.google.com/admob/answer/9388275

## Como ativar banners reais depois de todas as aprovações

**Não executar ainda.** A implementação tem chave de build:
```sh
flutter build appbundle --release --dart-define=ADMOB_LIVE_ADS=true
```
A compilação precisa usar assinatura de upload autorizada, código de versão **maior do que 10006**, manter verificações WorkDatabase / AD_ID e passar por testes antes de qualquer publicação. Não criar build comercial usando IDs de demonstração. Manter testes e revisão controlada antes de expandir a distribuição. Nunca clicar no próprio anúncio real ou estimular cliques inválidos.

## Definição objetiva de "pronto para começar a ganhar"

1. Site Google Play corretamente vinculado ao AdMob;
2. `app-ads.txt` verificado pela própria interface;
3. AdMob: **Pronto** e conta apta a receber pagamentos;
4. Segurança dos dados e mensagens de consentimento revisadas conforme fatos;
5. AAB com `ADMOB_LIVE_ADS=true`, versão nova assinada, validada em teste;
6. Publicação da versão comercial aprovada na Google Play, sem gerar tráfego inválido.

**Os valores de receitas dependem de impressões válidas e demanda dos anunciantes. Abrir e fechar o app por conta própria não garante pagamento e pode ser considerado tráfego inválido se manipulado.**
