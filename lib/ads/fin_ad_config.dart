/// FinControl: publicidade demonstrativa por padrao.
///
/// A compilacao para testes nunca deve solicitar anuncios reais.
/// A ativacao comercial exige aprovacao no AdMob, declaracoes de privacidade
/// consistentes e confirmacao de titularidade dos IDs abaixo.
const finLiveAds = bool.fromEnvironment(
  'ADMOB_LIVE_ADS',
  defaultValue: false,
);

/// Unidade de teste oficial do Google para banners fixos no Android.
const finTestBannerId = 'ca-app-pub-3940256099942544/6300978111';

/// ID registrado no projeto. Confirmar titularidade e status no AdMob
/// antes de compilar com ADMOB_LIVE_ADS=true.
const finProductionBannerId = 'ca-app-pub-3964603090393340/4111381146';

const finSelectedBannerId =
    finLiveAds ? finProductionBannerId : finTestBannerId;
