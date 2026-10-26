# FluxTools — hospedagem de app-ads.txt sem custo

Atualizado em 26/10/2026 após a criação do site de usuário GitHub Pages.

## Realmente executado

- Foi publicada no repositório **main/docs** uma página pública de desenvolvedora, com links para FinControl, privacidade e suporte.
- Site de suporte: `docs/support/index.html`.
- Linha de vendedores autorizados preparada em `docs/app-ads.txt`.
- `docs/.nojekyll` para entrega estática.
- Fluxo GitHub Pages do repositório `fincontrol` concluiu implantação **com sucesso** no commit `8c9aaf40` em 26/10/2026. A implantação não comprova, por si só, que o domínio raiz exigido pelo AdMob esteja funcionando.

## Solução executada em 26/10/2026

- Repositório **público** `thealbum0207-art/thealbum0207-art.github.io` criado.
- `index.html`, `privacy/index.html`, `support/index.html`, `app-ads.txt` e `.nojekyll` colocados na **raiz** do novo repositório, na branch `main`.
- O fluxo **pages build and deployment** concluiu **success** no commit `7669d988`, e seus logs registraram `Evaluated environment url: https://thealbum0207-art.github.io/`.
- Endereço planejado para rastreamento: **https://thealbum0207-art.github.io/app-ads.txt**.
- O endereço HTTP ainda precisa ser conferido num navegador externo e o publisher ID comparado com AdMob → Configurações; os testes de acesso público da ferramenta web não conseguiram carregar o endereço no instante da consulta.

## Impedimento identificado (histórico; resolvido com novo repositório)

GitHub Pages deste repositório serve em `https://thealbum0207-art.github.io/fincontrol/`.

O AdMob consulta **`https://thealbum0207-art.github.io/app-ads.txt`** se o site do desenvolvedor for `https://thealbum0207-art.github.io/fincontrol/`. O arquivo em `/fincontrol/app-ads.txt` **não** atende ao caminho da raiz (a menos que exista redirecionamento da raiz, que não está configurado).

O repositório dedicado passou a existir e ficou acessível à integração GitHub após a criação pelo proprietário.

## Pendências mínimas restantes

1. Abrir no navegador o arquivo publicado: https://thealbum0207-art.github.io/app-ads.txt e conferir a linha `google.com, pub-3964603090393340, DIRECT, f08c47fec0942fa0`.
2. Conferir no painel AdMob → Configurações o ID de editor **pub-3964603090393340**. A linha veio do identificador do banner mostrado no painel, mas o ID principal da conta não foi lido.
3. Inserir **https://thealbum0207-art.github.io/** em Google Play Console → FinControl → **Aumentar número de usuários → Presença na loja → Configurações da loja → Detalhes de contato da página Detalhes do app → Site**. Salvar e, se solicitado, enviar as alterações para análise.
4. Depois verificar na ficha pública Google Play a seção **Suporte ao app**, que deve oferecer o link do site.
5. Aguardar rastreamento no AdMob (pode levar até 24 h após atualização do site na loja) e conferir status em app-ads.txt; vincular o FinControl à Google Play pelo URL se ainda estiver sem vínculo.
6. Não alterar AAB/AdMob comercial antes de aprovar o app e testar migração de dados.

## Pontos de cautela

- O site de desenvolvedor público ajuda no app-ads, **mas não substitui a vinculação do app à loja e a análise de prontidão do AdMob**.
- A versão 2.0.2 do FinControl atualmente submetida à Google Play foi compilada com anúncios de teste: isso não gera receita.
- Não faça clique próprio nem produção de impressões artificiais.
- Não altere assinatura, códigos de versão, dados financeiros ou declaração de coleta sem evidências.

Fontes oficiais:
- https://support.google.com/admob/answer/9363762?hl=pt-br
- https://support.google.com/admob/answer/9776740?hl=pt-BR
- https://docs.github.com/en/pages/quickstart
