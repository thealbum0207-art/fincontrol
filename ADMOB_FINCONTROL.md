# Monetizacao AdMob — FinControl

Esta alteracao prepara **um banner** discreto no FinControl e **nao** muda o banco de dados local. A versao 2.0.6 deve preservar os ajustes da branch fix/workmanager-ad-id-10006 (construtor WorkDatabase, R8 e permissao AD_ID).

IDs comerciais atualizados para os identificadores mostrados no painel AdMob do FinControl. Confirme-os novamente na conta antes de gerar AAB com anuncios reais.

- App ID AdMob: `ca-app-pub-3964603090939340~3759405239`
- Banner unit ID: `ca-app-pub-3964603090939340/4111381146`
- SDK: `google_mobile_ads: 9.1.0` (requer Dart >=3.10 e Flutter >=3.38.1; fluxo validado em Flutter 3.47.7)
- Versao: `2.0.6+10007`. Confirme na Play Console se o versionCode 10007 supera todas as versoes ja enviadas.
- O fluxo cria Android durante o build e executa `tool/configure_admob.py` para incluir o App ID no AndroidManifest.

## Modos de anuncios

Por seguranca, ate o AAB assinado usa **anuncios de teste** como padrao. Em Actions → FinControl AAB release com assinatura autorizada → Run workflow, mantenha `live_ads=false` para testes.

Somente depois da aprovacao e dos ajustes de privacidade, selecione `live_ads=true` para compilar um novo AAB com o bloco real. Nao toque em anuncios reais de seu proprio app.

## Antes de publicar anuncios reais

1. Concluir revisao do app no AdMob e associar a ficha publica da Play Store quando possivel.
2. Em Play Console, declarar **Contem anuncios**, revisar **Seguranca dos dados**, fornecer politica de privacidade atualizada e verificar o uso de dados do SDK.
3. Configurar e publicar o arquivo `app-ads.txt` no dominio de desenvolvedor quando aplicavel.
4. Configurar mensagens de consentimento em Privacidade e mensagens no AdMob; o codigo consulta UMP antes de carregar publicidade e exibe opcao de privacidade quando obrigatoria.
5. Verificar que a chave de upload e o `applicationId` sao os mesmos da versao publicada.
6. Compilar e validar AAB assinado, instalar e verificar a exibicao do banner em dispositivo; executar `flutter analyze` e `flutter test`.
7. Confirmar que `versionCode` 201 e maior que o de todas as faixas da Play.

O usuario continua podendo gerenciar receitas, despesas e orcamentos mesmo sem rede ou carregamento de anuncios. O codigo desta alteracao ainda precisa de build/QA no GitHub Actions antes de publicacao.
