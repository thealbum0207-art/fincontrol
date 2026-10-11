# FinControl — Assinatura de AAB para Google Play

O bundle de teste usa uma chave de debug e foi rejeitado pela Play Console.

## Recuperar acesso de assinatura
Se possuir a keystore original, use-a apenas se o SHA-1 coincidir com o certificado de upload na Play Console.

Se perdeu a keystore original e o app usa Play App Signing, solicite **redefinição da chave de upload** em **Testar e lançar → Integridade do app → Assinatura de apps do Google Play** (os nomes podem variar). Gere nova chave privada em ambiente seguro, exporte o certificado público PEM, registre-o na Play Console e espere a ativação antes de compilar AAB para envio.

## GitHub Actions (secrets obrigatórios)
Configure, em Settings → Secrets and variables → Actions, os seguintes segredos:

- FINCONTROL_UPLOAD_KEYSTORE_B64 — keystore JKS codificada em Base64 numa única linha
- FINCONTROL_STORE_PASSWORD — senha da keystore
- FINCONTROL_KEY_ALIAS — alias da chave de upload
- FINCONTROL_KEY_PASSWORD — senha da chave
- FINCONTROL_EXPECTED_UPLOAD_SHA1 — impressão SHA-1 da chave de upload ATIVA na Play Console

Não coloque a keystore privada ou suas senhas neste repositório público e não publique artefatos contendo keystores. O fluxo valida o SHA-1 antes da compilação e é executado apenas manualmente: Actions → FinControl AAB release com assinatura autorizada → Run workflow.

Confirme ainda que o package id com.app.fincontrol está correto, que o versionCode 200 excede o anteriormente publicado e que os dados dos usuários existentes são preservados. Não publique a nova versão sem essas verificações.

Documento oficial: https://developer.android.com/studio/publish/app-signing
