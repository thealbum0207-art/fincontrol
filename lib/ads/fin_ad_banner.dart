import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Teste por padrao, inclusive em builds assinados para testes da Play Store.
/// Para liberar anuncios reais: --dart-define=ADMOB_LIVE_ADS=true
const _liveAds = bool.fromEnvironment('ADMOB_LIVE_ADS', defaultValue: false);
const _bannerUnit = _liveAds
    ? 'ca-app-pub-3964603090393340/4111381146'
    : 'ca-app-pub-3940256099942544/6300978111';

/// Banner discreto, acima da barra de navegacao e fora das areas financeiras.
/// O consentimento UMP e consultado antes de qualquer solicitacao de anuncios.
class FinAdBanner extends StatefulWidget {
  const FinAdBanner({super.key});

  @override
  State<FinAdBanner> createState() => _FinAdBannerState();
}

class _FinAdBannerState extends State<FinAdBanner> {
  BannerAd? _banner;
  bool _showPrivacyOptions = false;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _prepareAds();
  }

  void _prepareAds() {
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        await ConsentForm.loadAndShowConsentFormIfRequired((error) async {
          await _checkPrivacyOptions();
          await _maybeLoadAds();
        });
      },
      (error) async {
        // Nao requisitar anuncio se nao houver consentimento valido em cache.
        await _checkPrivacyOptions();
        await _maybeLoadAds();
      },
    );
  }

  Future<void> _checkPrivacyOptions() async {
    try {
      final status = await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus();
      if (!mounted) return;
      setState(() => _showPrivacyOptions =
          status == PrivacyOptionsRequirementStatus.required);
    } catch (_) {
      // Sem opcao adicional quando a UMP nao informar exigencia.
    }
  }

  Future<void> _maybeLoadAds() async {
    if (!mounted || _started) return;
    bool allowed = false;
    try {
      allowed = await ConsentInformation.instance.canRequestAds();
    } catch (_) {
      return;
    }
    if (!mounted || !allowed || _started) return;
    _started = true;
    try {
      await MobileAds.instance.initialize();
      if (!mounted) return;
      final ad = BannerAd(
        adUnitId: _bannerUnit,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (!mounted) {
              ad.dispose();
              return;
            }
            setState(() => _banner = ad as BannerAd);
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
          },
        ),
      );
      unawaited(ad.load());
    } catch (_) {
      // Falhas na rede de anuncios nao devem impedir uso do FinControl.
    }
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_banner == null && !_showPrivacyOptions) {
      return const SizedBox.shrink();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_showPrivacyOptions)
          TextButton(
            onPressed: () {
              ConsentForm.showPrivacyOptionsForm((error) {});
            },
            child: const Text('Preferencias de anuncios'),
          ),
        if (_banner != null)
          SizedBox(
            height: _banner!.size.height.toDouble(),
            width: _banner!.size.width.toDouble(),
            child: AdWidget(ad: _banner!),
          ),
      ],
    );
  }
}
