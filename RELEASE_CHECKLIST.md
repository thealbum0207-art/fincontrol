# FinControl — revisão de lançamento e monetização

Revisado em 23/10/2026, com base no código-fonte do repositório e nos avisos relatados da Play Console. Documento de trabalho, não comprova aprovação nas plataformas.

## Confirmado no código

- package Android gerado com `flutter create --org com.app --project-name fincontrol`: `com.app.fincontrol`;
- versão proposta **2.0.3+10004** nesta ramificação, **sem AAB publicado**;
- lançamentos, receitas/despesas e limites em banco SQLite local `fincontrol_v2.db`;
- versão atual enviada à Play: **2.0.2+10003**, compilada com `live_ads=false`;
- banner no aplicativo, utilizando unidade demonstrativa quando `ADMOB_LIVE_ADS=false`, sem gerar receita;
- UMP consultado antes de tentar requisitar anúncio;
- política de privacidade pública: https://thealbum0207-art.github.io/fincontrol/privacy/ ;
- nesta ramificação, política de privacidade também disponível na interface do aplicativo.

## Bloqueios importantes antes de publicar outra atualização

1. **Migração de dados não confirmada**. A versão recriada usa um arquivo local SQLite chamado `fincontrol_v2.db`. Não há no repositório um migrador conhecido para a base do app anterior. Testar uma atualização real de 1.0.2 para a futura versão 2.0.3, com registros de exemplo, antes de publicar. NÃO desinstalar o app com dados reais para testar; isso pode apagá-los.
2. Conferir o status da política de privacidade na Play Console, além da URL pública; reenvio não significa aprovação.
3. Conferir as declarações **Segurança dos dados**, **Contém anúncios**, **ID de publicidade** e público-alvo contra o código e as práticas do SDK AdMob. Registros financeiros no dispositivo não significam ausência de coleta por SDKs.
4. Conferir status do app em **AdMob → Apps → Ver todos**. Só usar anúncios reais após aprovação do app, consentimento, revisão de privacidade, configuração de `app-ads.txt` aplicável e QA.
5. Não clicar em anúncios próprios, não abrir/fechar o app artificialmente para simular impressões nem estimular cliques.
6. Rever acessibilidade e posicionamento do banner em aparelhos pequenos. O banner não pode encobrir funcionalidades, nem induzir toques acidentais.
7. Reforçar transparência: o FinControl **não é banco** e não sincroniza movimentações automaticamente. Não prometer backup, importação bancária ou ganhos financeiros.
8. Revisar o canal de contato de suporte da ficha Google Play e da política, usando um meio efetivamente monitorado. Não usar uma conta de e-mail inventada.
9. Testar `flutter analyze`, `flutter test` e `flutter build apk --debug` por CI antes de gerar versão assinada.
10. Validar `versionCode` maior que todas as versões de todas as faixas e certificado de upload autorizado.

## Gate de liberação AdMob

- `live_ads=false` para builds internos e testes;
- `live_ads=true` apenas com todos os pré-requisitos validados;
- jamais usar o modo real para testar cliques próprios;
- aprovação da Play Console **não** equivale a aprovação do AdMob;
- receita ocorre com impressões válidas e não é garantida por abertura do app.

## Proteção adicional dos dados (nova, ainda sem AAB de produção)

- Usuário pode abrir **Mais opções → Exportar dados** e gerar um arquivo JSON com **todos** os lançamentos e orçamentos armazenados nesta versão do banco. Requer confirmação explícita; escolhe aplicativo/destino no compartilhamento do Android; nenhuma transmissão automática para a FluxTools.
- Arquivo **não é criptografado**: avisar para guardar em local privado. O compartilhamento não garante que a cópia foi salva; verificar no destino escolhido.
- A exportação **não** fornece importação automática e **não** recupera dados de versões anteriores nem substitui teste de migração. Não publicar sem validar a passagem 1.0.2 → versão nova.

## Entregas desta ramificação

- Página interna de Política de Privacidade visível no cabeçalho;
- texto de versão desatualizado removido do diálogo Sobre;
- versionCode reservado 10004;
- teste widget de abertura da página de privacidade.

Nenhuma mudança desta ramificação altera o AAB já submetido (2.0.2/10003). Fazer merge, validar e gerar novo AAB somente quando necessário.
