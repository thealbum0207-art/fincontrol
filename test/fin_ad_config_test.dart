import 'package:flutter_test/flutter_test.dart';
import 'package:fincontrol/ads/fin_ad_config.dart';

void main() {
  test('anuncios de teste sao o padrao seguro', () {
    // CI sem --dart-define deve ficar isolado de anuncios reais.
    expect(finLiveAds, isFalse);
    expect(finSelectedBannerId, finTestBannerId);
    expect(finTestBannerId, 'ca-app-pub-3940256099942544/6300978111');
  });

  test('IDs comerciais e demonstrativos nao estao misturados', () {
    final pattern = RegExp(r'^ca-app-pub-[0-9]{16}/[0-9]{10}$');
    expect(pattern.hasMatch(finProductionBannerId), isTrue);
    expect(pattern.hasMatch(finTestBannerId), isTrue);
    expect(finProductionBannerId, isNot(finTestBannerId));
    expect(finProductionBannerId.startsWith(
      'ca-app-pub-3940256099942544/'), isFalse);
  });
}
