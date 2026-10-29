# FinControl 2.0.7 — atualização em preparação

**Versão:** 2.0.7 (10008)
**Status:** desenvolvimento / validação. Não publicada. AAB só deve ser enviado após testes.

## Melhorias implementadas
- Botão **Exportar meus dados** no topo: exibe aviso e abre o compartilhamento do Android.
- Gera dois arquivos CSV: todos os lançamentos (qualquer mês) e limites de orçamento, com separador `; ` e codificação UTF-8 BOM.
- Dados enviados para outros apps somente mediante a escolha consciente do usuário. Não existe upload automático pela FluxTools.
- Campos CSV do usuário protegidos contra fórmulas em aplicativos de planilhas.
- Ícone de instalação da marca FinControl nas cinco densidades Android e nome visível **FinControl**.
- Tela Sobre sem referência ao protótipo antigo.
- Botão **+ Lançamento** não se sobrepõe aos controles da tela Orçamentos.

## Mantido sem alteração
- Package name: `com.app.fincontrol`.
- Banco SQLite: nome `fincontrol_v2.db`, versão 1, tabelas `transactions` e `budgets`, sem migração.
- Identificadores de publicidade: os IDs comerciais vigentes em 2.0.6; consentimento UMP continua.
- Assinatura de upload: mesmas credenciais do GitHub Actions e cheque SHA-1.
- Regras R8 para proteger o construtor do WorkManager e permissão AD_ID.

## Limitações que devem ficar claras
- **CSV é exportação, não restauração**. O FinControl 2.0.7 ainda não importa arquivos de volta. Mantenha um arquivo salvo de forma segura.
- Nunca envie CSV com finanças pessoais para destinatários desconhecidos. O Android é responsável por oferecer os destinos de compartilhamento.
- Após a exportação, cópias temporárias podem permanecer no cache até que o Android faça sua limpeza normal.
- Não há sincronização, backup automático ou integração bancária.
- Publicidade de teste em dispositivo registrado no AdMob é comportamento esperado.

## Checklist antes de qualquer publicação
- [ ] GitHub CI `flutter analyze`, `flutter test` e APK debug aprovados.
- [ ] GitHub AAB **2.0.7 (10008)** assinado: analisar, testar, conferir assinatura, WorkManager e AD_ID.
- [ ] Instalar por teste interno atualizando **sem desinstalar** o app da versão 2.0.6.
- [ ] Conferir entradas e orçamentos previamente salvos e os mesmos valores ao abrir 2.0.7.
- [ ] Criar e editar lançamentos, revisar saldo/gráficos, definir/remover limite e retornar a cada aba.
- [ ] Testar exportação com 2+ lançamentos em meses distintos e orçamentos; conferir cabeçalhos, números e acentos do CSV num destino escolhido pelo usuário.
- [ ] Testar exportação vazia, cancelamento e ausência de internet.
- [ ] Confirmar o ícone FinControl na tela inicial e nome FinControl em Informações do aplicativo.
- [ ] Conferir os banners após consentimento e confirmar que não sobrepõem botões de ações.
- [ ] Corrigir `Segurança dos dados` na Play Console e retirar promessas de recursos inexistentes da descrição pública, conforme auditoria anterior.
- [ ] Revisar declaração de anúncios e configurações de consentimento na conta AdMob.
- [ ] Realizar lançamento gradual em produção, se disponível, e monitorar Android vitals.

**Política:** não publicar, mesclar em `main` ou substituir AAB existente automaticamente.
