# FinControl — Monetização AdMob: plano de lançamento

Atualizado: **23/10/2026**. Este documento separa o que está pronto em código do que depende de aprovação externa e prova de titularidade. **Não significa que anúncios estejam pagando.**

## Configuração existente no código

- App Android: `com.app.fincontrol`
- SDK: `google_mobile_ads: 9.1.0`
- ID de aplicativo AdMob configurado no manifesto gerado: `ca-app-pub-3964603090393340~3759405239`
- ID de banner **comercial cadastrado no código**: `ca-app-pub-3964603090393340/4111381146`
- ID de banner de **teste oficial do Google**: `ca-app-pub-3940256099942544/6300978111`
- O publisher extraído desses IDs é `pub-3964603090393340` — **a titularidade e o status desse publisher ainda não foram confirmados diretamente no painel AdMob**.
- Código da versão preparada na branch: `2.0.3+10004`; não foi compilado AAB de produção nesta branch.
- Versão submetida à Play: `2.0.2+10003`, com **anúncios de teste**. Nenhuma receita real provém desses banners de teste.

## Medidas preparadas na versão 2.0.3

- `lib/ads/fin_ad_config.dart` centraliza os IDs e deixa anúncios de teste ativados por padrão.
- `test/fin_ad_config_test.dart` protege a configuração demonstrativa durante CI e verifica a sintaxe dos IDs.
- Banner com rótulo visível **Publicidade** e espaçamento até a barra de navegação, para reduzir toques acidentais.
- UMP pede/consulta as informações de consentimento antes de requisitar banners. Se não houver consentimento válido, o banner não é solicitado.
- Sem intersticiais, vídeos obrigatórios, incentivos a cliques ou bloqueio de recursos financeiros se o banner falhar.
- Política pública: https://thealbum0207-art.github.io/fincontrol/privacy/
- Política acessível dentro do app pela tela inicial (nova branch).

## app-ads.txt — preparado, **não publicado no local correto**

Arquivo preparado: `admob_assets/app-ads.txt`:
```text
google.com, pub-3964603090393340, DIRECT, f08c47fec0942fa0
```

**Confirme que `pub-3964603090393340` é o Publisher ID correto em AdMob → Configurações.** Não publique uma declaração de vendas autorizadas com ID de outro titular.

**Atenção:** GitHub Pages do repositório publica em `https://thealbum0207-art.github.io/fincontrol/`. O rastreador do AdMob procura `https://thealbum0207-art.github.io/app-ads.txt` **na raiz do domínio, não em `/fincontrol/app-ads.txt`**. Portanto copiar o arquivo para `docs/` deste repositório **não basta**. É necessário configurar uma hospedagem com controle da raiz (por exemplo, um repositório de páginas do usuário `thealbum0207-art.github.io`, ou outro domínio com `/app-ads.txt` na raiz).

Em seguida, publicar esse domínio exato no campo **website do desenvolvedor** da ficha do app na Google Play. Após publicação e associação, AdMob pode levar 24 horas ou mais para localizar/validar o arquivo.

## Condições para anúncios reais

1. Confirmar conta AdMob ativa e propriedade dos IDs de App e bloco comercial; verificar status de prontidão do **FinControl** no painel.
2. Confirmar que o app existe/publicou no Google Play, vinculado no AdMob, onde exigido.
3. Confirmar que políticas Play: privacidade, segurança dos dados, declaração contém anúncios, ID de publicidade e público-alvo descrevem corretamente dados tratados pelo SDK.
4. Publicar e validar `app-ads.txt` no **domínio raiz** vinculado à ficha do app.
5. Testar banner e consentimento em aparelhos/configurações diferentes **em modo de teste**, sem cliques próprios em publicidade real.
6. Confirmar migração de dados de 1.0.2 para a futura 2.0.3 antes de lançar — a nova versão usa banco local `fincontrol_v2.db`.
7. Apenas com tudo acima validado, executar workflow `build-release-signed.yml` com `live_ads=true`, usar certificado autorizado e novo `versionCode`, e enviar AAB para revisão Play.

## Segurança do publisher

- **Impressões válidas** podem gerar receita sem clique, mas abrir/fechar artificialmente o app, pedir cliques ou automatizar impressões é tráfego inválido.
- Não solicitar banners em loop para aumentar faturamento, não fazer refresh agressivo, nem colocar o banner adjacente a controles de ação de maneira a induzir toque.
- Testes devem usar a unidade oficial demonstrativa (`live_ads=false`) ou dispositivos declarados de teste no AdMob.
- A aprovação de versão pela Google Play e a prontidão de anúncios AdMob são processos diferentes.

## Fontes oficiais

- https://developers.google.com/admob/android/test-ads?hl=pt-br
- https://developers.google.com/admob/android/app-ads?hl=pt-BR
- https://support.google.com/admob/answer/9675354?hl=pt-br
