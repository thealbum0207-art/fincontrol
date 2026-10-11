import 'package:flutter_test/flutter_test.dart';
import 'package:fincontrol/core/money.dart';

void main() {
  group('Money', () {
    test('formata centavos no padrão brasileiro', () {
      expect(Money.format(123456789), 'R\$ 1.234.567,89');
      expect(Money.format(5), 'R\$ 0,05');
      expect(Money.format(-1250), '-R\$ 12,50');
      expect(Money.format(0), 'R\$ 0,00');
    });

    test('converte entrada de reais para centavos', () {
      expect(Money.parsePositive('1.250,50'), 125050);
      expect(Money.parsePositive('12,5'), 1250);
      expect(Money.parsePositive('R\$ 19,99'), 1999);
      expect(Money.parsePositive('35'), 3500);
      expect(Money.parsePositive('0,01'), 1);
    });

    test('recusa valores inválidos', () {
      expect(Money.parsePositive('0'), isNull);
      expect(Money.parsePositive('-5,00'), isNull);
      expect(Money.parsePositive('abc'), isNull);
      expect(Money.parsePositive('12,999'), isNull);
      expect(Money.parsePositive(''), isNull);
    });
  });
}
