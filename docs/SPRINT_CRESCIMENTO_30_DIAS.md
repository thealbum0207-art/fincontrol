# FinControl — sprint de crescimento e monetização (30 dias)
Atualizado em 28/10/2026. Meta aspiracional: R$ 500/dia; NÃO é projeção de ganhos garantidos. Manter os dados dos usuários seguros.

## Estado comprovado
- Aplicativo FinControl: Finanças Pessoais (com.app.fincontrol), distribuído na Google Play.
- AdMob: status "Pronto" em captura do proprietário, mas 0 solicitações e US$ 0,00 de receita na captura.
- AAB 2.0.6 (10007) de TESTE: assinado e validado. Compilação comercial precisa ser validada, testada e aprovada separadamente.
- Publicação de nova versão: não autorizar sem verificar a Play Console e sem testar a atualização preservando dados locais.
- Nada de compras, cliques ou impressões artificiais.

## Matemática da meta
- R$ 500/dia = ~R$ 15.000/mês (30 dias).
- Receita publicitária = impressões / 1000 × eCPM.
- Exemplo ilustrativo com R$ 3 por mil impressões, 2 impressões/usuário ativo/dia: ~83.334 usuários ativos por dia para R$ 500 apenas com banners.
- Faixas de eCPM R$ 1–5 são HIPÓTESES de cálculo, não benchmarks medidos do app.
- Meta incremental de validação: primeiro R$ 1/dia → R$ 10/dia → R$ 50/dia → R$ 100/dia → R$ 500/dia, sem prometer prazo.

## Plano de execução

### Dias 1–3 — funcionamento e dados reais
1. Conferir IDs exatos do aplicativo e do bloco de anúncios em Configurações do AdMob.
2. Confirmar conta AdMob aprovada, app-ads.txt, política de privacidade, consentimento UMP e Segurança dos Dados na Play Console.
3. Testar atualização da versão instalada 2.0.5 para 2.0.6 em dispositivo/conta de teste com lançamentos locais salvos.
4. Verificar anúncios usando dispositivo de teste, sem clicar em anúncio real.
5. Publicar na Play Console apenas AAB comercial validado; acompanhar resultado da revisão sem fazer atualizações sucessivas.
6. Preparar métricas semanais: usuários ativos/dia, instalações, retenção 7 dias, ANRs/crashes, impressões, eCPM, renda por usuário ativo.

### Dias 4–10 — descoberta orgânica
- Conferir se a ficha Google Play apresenta screenshots REAIS da versão publicada, título correto, descrição clara, botões sem promessas falsas.
- Verificar Search Console: indexação do site FluxTools, sitemap e termos pesquisados; sem presumir posição no Google.
- Divulgar 1 conteúdo útil/dia nos canais próprios; sem spam em grupos ou compra de avaliações.
- Associar cada postagem a 1 função REAL do app, sempre com CTA da Google Play oficial.

### Dias 11–20 — retenção antes de anúncios mais intrusivos
- Examinar primeiro acesso, registro da primeira receita/despesa, tempo até concluir tarefa, travamentos e motivos de abandono.
- Melhorar a clareza da interface e o tratamento da privacidade dos dados, se bugs forem comprovados.
- Preferir banners discretos fora de botões; evitar intersticiais obrigatórios que prejudiquem experiência.
- Só iniciar experimento de capa/capturas na Play Store após dados suficientes.

### Dias 21–30 — receita diversificada
- Testar oferta legítima do Kit FinControl (produto independente do Android, com planilha + PDF) depois de criar checkout oficial e configurar entrega.
- Explorar futuramente um item não consumível "FinControl Plus" via Google Play Billing (remoção de anúncios e recurso implementado e testado), sem alegar que Premium existe hoje.
- Registrar números reais de vendas, taxas e reembolsos; comparar receita por hora investida.

## Roteiros prontos para sete posts — usar apenas telas reais e valores demonstrativos sinalizados

**Dia 1 — vídeo de 20 s**
Gancho: "Você sabe quanto gastou este mês?"
Cena: mostrar Resumo real do FinControl no celular.
Texto: "O FinControl ajuda a registrar receitas, despesas e ver o saldo do período. Conheça na Google Play."
CTA: "FinControl: Finanças Pessoais — procure na Google Play."

**Dia 2 — tutorial de 25 s**
Gancho: "Como registrar uma despesa em poucos passos"
Cena: abrir Lançamentos, tocar no botão +, preencher campos com EXEMPLO fictício e salvar.
Texto: "Separe alimentação, transporte e outras categorias para entender seus registros."
CTA: "Teste o FinControl Android."

**Dia 3 — carrossel de 3 páginas**
P1: "Seu orçamento começa com três anotações." 
P2: "Quanto entrou / quanto saiu / quais gastos são essenciais."
P3: "Confira os totais periodicamente. O FinControl pode ajudar a registrar movimentações."
CTA: "Guia gratuito no site da FluxTools."

**Dia 4 — vídeo de 15 s**
Gancho: "Limite do cartão não é dinheiro que entrou."
Corpo: "Se você considerar crédito como renda, o orçamento pode ficar distorcido. Compare receitas reais com despesas reais."
CTA: "Organize suas movimentações."

**Dia 5 — tutorial de 20 s**
Gancho: "Qual categoria mais pesa no seu mês?"
Cena: abrir Resumo e mostrar distribuição de gastos de um EXEMPLO marcado como simulação.
CTA: "Veja os gastos por categoria no FinControl."

**Dia 6 — vídeo de 20 s**
Gancho: "Definir um orçamento ajuda a criar limites visíveis."
Cena: abrir Orçamentos, escolher uma categoria, mostrar campo de limite. Não prometer metas automáticas que o app não possui.
CTA: "Conheça o FinControl na Google Play."

**Dia 7 — post de texto e imagem**
Gancho: "Revisão financeira de cinco minutos"
Corpo: "Confira os lançamentos da semana, compare com os gastos reais e ajuste o próximo período."
CTA: "Guia gratuito: https://thealbum0207-art.github.io/guia-orcamento/"

## Medições a conferir toda semana
| Métrica | Onde | Ação quando estiver ruim |
|---|---|---|
| Visitas à página do app | Play Console | Revisar descoberta/SEO/links |
| Conversão visita → instalação | Play Console | Melhorar imagens e descrição com testes |
| Usuários ativos e retenção | Analytics/Play, quando disponível | Melhorar primeira experiência e confiabilidade |
| Crashes/ANRs | Android vitals | Priorizar correções |
| Solicitações e impressões | AdMob | Conferir IDs, consentimento, inventário e versão |
| eCPM e ganhos reais | AdMob | Otimizar após dados suficientes, não inventar médias |
| Vendas do kit | Kiwify | Avaliar checkout, preço, suporte e oferta |

Referências:
- https://support.google.com/admob/answer/15337570?hl=pt-BR
- https://support.google.com/admob/answer/3342099?hl=en
- https://support.google.com/admob/answer/9388275?hl=en
- https://support.google.com/googleplay/android-developer/answer/9858738?hl=pt-BR
