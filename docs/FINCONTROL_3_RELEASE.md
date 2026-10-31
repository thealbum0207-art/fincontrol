# FinControl 3.0 — release seguro (rascunho)

## Escopo
- App Android Flutter: `com.app.fincontrol`, `3.0.0+10004` **provisório**. Conferir na Play Console se o `versionCode` supera TODOS os bundles anteriores antes de publicar.
- Sem anúncios: `google_mobile_ads` e banner removidos, nenhuma configuração de AdMob é injetada na build.
- Interface refinada e hub com: recorrências, metas, cartões/parcelas, relatórios, assistente de regras locais, agenda, exportação JSON/CSV, PIN/biometria, carteiras, projeção.
- Recursos iniciais sem sincronização de contas bancárias ou IA remota.

## Proteção de dados
- O app antigo usa `fincontrol_v2.db` e SQLite schema 1.
- O app 3 usa o **mesmo arquivo**, com schema 2 e somente novas tabelas e coluna `wallet_id`; nenhuma tabela `transactions` ou `budgets` é descartada ou renomeada.
- As movimentações antigas pertencem à carteira Principal (`wallet_id=1`).
- Pagamentos de parcelas e postagem de recorrências usam transações de banco para prevenir contagem duplicada.
- Transferências entre carteiras têm lançamentos compensatórios que não entram nos gráficos de receitas/despesas.
- Backups JSON e exportações CSV são **arquivos sem criptografia**. A opção de importar/restaurar um backup ainda NÃO foi implementada.
- PIN opcional armazenado em forma de verificador derivado + salt em armazenamento criptografado; biometria fica no próprio aparelho. Perder PIN pode impedir acesso.
- Não remova o aplicativo, não limpe os dados nem instale uma build debug por cima de uma build assinada da Play Store.

## Testes obrigatórios antes de publicar
1. `flutter analyze` e `flutter test` verdes, incluindo migração de SQLite v1 para v2.
2. Compilação Android debug funcionando em aparelho físico; testar app já instalado **com dados reais não sensíveis de teste**, atualizando-o sem desinstalar.
3. Comparar saldos, lançamentos e limites antes/depois da atualização.
4. Testar criação, edição, cartões, parcelas, recorrências, PIN, falha de biometria, background/resume e comportamento offline.
5. Verificar exportações e armazenamento seguro; não restaurar automaticamente (ainda não suportado).
6. Confirmar `com.app.fincontrol`, `versionCode` maior que o publicado, minSdk, permissões e ausência real do SDK de anúncios.
7. Configurar os cinco GitHub Actions secrets de assinatura na área segura do repositório (NUNCA em arquivos ou no chat).
8. Rodar o workflow manual `FinControl 3 AAB assinado sem anuncios`; ele deve comparar SHA-1 da keystore com o certificado de upload da Play Console.
9. Enviar o AAB assinado a uma faixa de teste antes de solicitar produção. Atualizar declarações de publicidade na Play Console **após** ter certeza da build.

## Fluxos GitHub Actions
- `Testar FinControl 3 e compilar APK mais AAB`: push na branch de desenvolvimento produz APK debug e AAB de verificação com **assinatura provisória; NÃO publicar**.
- `FinControl 3 AAB assinado sem anuncios`: disparo manual, só com segredos de assinatura, build de release + validação de `jarsigner`.

## Limites conhecidos
- A migração SQLite ainda precisa ser validada no CI e em uma atualização real de aparelho.
- Metas indicam progresso declarado: não representam saque ou depósito automático.
- Compras de cartão são compromissos previstos; afetam o saldo realizado quando marcadas como pagas.
- Agenda é lista de vencimentos, sem alarmes de notificação.
- Assistente é baseado em regras financeiras locais, não um modelo de IA generativa.
- Projeção de 30 dias não é garantia de saldo futuro.
- A área Premium/Google Play Billing não faz parte deste incremento, e nenhuma cobrança é ativada.
