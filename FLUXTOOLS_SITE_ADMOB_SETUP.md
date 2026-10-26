# FluxTools — hospedagem de app-ads.txt sem custo

Atualizado em 26/10/2026.

## Realmente executado

- Foi publicada no repositório **main/docs** uma página pública de desenvolvedora, com links para FinControl, privacidade e suporte.
- Site de suporte: `docs/support/index.html`.
- Linha de vendedores autorizados preparada em `docs/app-ads.txt`.
- `docs/.nojekyll` para entrega estática.
- Fluxo GitHub Pages do repositório `fincontrol` concluiu implantação **com sucesso** no commit `8c9aaf40` em 26/10/2026. A implantação não comprova, por si só, que o domínio raiz exigido pelo AdMob esteja funcionando.

## Impedimento identificado

GitHub Pages deste repositório serve em `https://thealbum0207-art.github.io/fincontrol/`.

O AdMob consulta **`https://thealbum0207-art.github.io/app-ads.txt`** se o site do desenvolvedor for `https://thealbum0207-art.github.io/fincontrol/`. O arquivo em `/fincontrol/app-ads.txt` **não** atende ao caminho da raiz (a menos que exista redirecionamento da raiz, que não está configurado).

A conta GitHub conectada possui apenas o repositório `fincontrol`. A conexão GitHub disponível permite criar arquivos e alterar repos existentes, mas **não inclui a ação de criar repositórios**.

## Próximo passo mínimo

1. Criar um repositório **público** com nome exato `thealbum0207-art.github.io` na conta já conectada. Link: https://github.com/new?name=thealbum0207-art.github.io
2. Assim que existir, copiar com a integração GitHub os arquivos preparados em `fincontrol/docs` para a **raiz** do novo repositório:
   - `index.html`
   - `privacy/index.html`
   - `support/index.html`
   - `app-ads.txt`
   - `.nojekyll`
3. Habilitar GitHub Pages no repositório novo: **Settings → Pages → Deploy from a branch → main → /(root) → Save**, se não for automaticamente habilitado.
4. Testar no navegador (HTTP 200): `https://thealbum0207-art.github.io/app-ads.txt`, conteúdo exibido exatamente:
```text
google.com, pub-3964603090393340, DIRECT, f08c47fec0942fa0
```
5. Confirmar o **Publisher ID oficial** no AdMob → Configurações, antes de considerar o arquivo final (o código acima foi extraído do identificador comercial do banner cadastrado no AdMob).
6. Somente depois, atualizar o campo **Site do desenvolvedor** em Google Play Console → Aumentar número de usuários → Presença na loja → Configurações da loja → Dados de contato da ficha da loja → Site; URL `https://thealbum0207-art.github.io/`. A alteração pode exigir análise.
7. Tentar novamente AdMob → Apps → FinControl → Configurações do aplicativo → Detalhes da app store → Adicionar (usar a URL pública completa do FinControl).
8. Verificar na AdMob → app-ads.txt o status de rastreamento; a detecção pode levar pelo menos 24 h após as mudanças. Não declarar sucesso antes do painel confirmar.

## Pontos de cautela

- O site de desenvolvedor público ajuda no app-ads, **mas não substitui a vinculação do app à loja e a análise de prontidão do AdMob**.
- A versão 2.0.2 do FinControl atualmente submetida à Google Play foi compilada com anúncios de teste: isso não gera receita.
- Não faça clique próprio nem produção de impressões artificiais.
- Não altere assinatura, códigos de versão, dados financeiros ou declaração de coleta sem evidências.

Fontes oficiais:
- https://support.google.com/admob/answer/9363762?hl=pt-br
- https://support.google.com/admob/answer/9776740?hl=pt-BR
- https://docs.github.com/en/pages/quickstart
