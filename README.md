# FinControl: Finanças Pessoais

Aplicativo Android de organização financeira pessoal desenvolvido em Flutter.

## Funcionalidades verificadas no código

- Registro e edição de receitas e despesas, por categoria e data.
- Resumo do saldo de lançamentos cadastrados e distribuição de gastos.
- Limites mensais de orçamento por categoria.
- Dados financeiros armazenados localmente, em SQLite.
- Política de Privacidade acessível dentro do app e na web.
- Banner AdMob discreto, com consentimento quando necessário. O projeto compila **com anúncios de teste por padrão**.
- Nesta ramificação 2.0.3, opção **Mais opções → Exportar dados**. O usuário confirma o compartilhamento de arquivo JSON que contém todos os lançamentos e limites existentes no banco local. Não há envio automático para a FluxTools.

## Privacidade e backup

A exportação é manual, não é criptografada e não significa que os dados foram automaticamente salvos fora do celular. O usuário deve escolher e conferir um destino privado. **Não há importação automática neste momento.** A exportação do banco atual não recupera dados perdidos em versões antigas.

Política pública: https://thealbum0207-art.github.io/fincontrol/privacy/

## Versões / testes

- Versão anterior enviada à Play Console: **2.0.2+10003**.
- Esta ramificação é de preparação da **2.0.3+10004**, não publicada em produção.
- Validar na GitHub Actions com `flutter analyze`, `flutter test` e `flutter build apk --debug --dart-define=ADMOB_LIVE_ADS=false`.
- **Não publicar** sem testar migração de dados da versão anterior e verificar as declarações Play Console / AdMob.
- **Não ativar** `ADMOB_LIVE_ADS=true` sem confirmar titularidade dos IDs, aprovação AdMob e `app-ads.txt` na raiz do domínio correspondente.

## Documentação de preparação

- [Auditoria da Play Console](PLAY_CONSOLE_CONFIG_FINCONTROL.md)
- [Monetização AdMob](ADMOB_FINCONTROL.md)
- [Checklist para lançamento](RELEASE_CHECKLIST.md)
- [Marketing fiel às funcionalidades](MARKETING_GOOGLE_PLAY.md)
