/// Representa valores monetários apenas como centavos inteiros.
/// Não usa double em somas financeiras.
class Money {
  static String format(int cents) {
    final negative = cents < 0;
    final absolute = cents.abs();
    final integer = (absolute ~/ 100).toString();
    final decimals = (absolute % 100).toString().padLeft(2, '0');
    final buffer = StringBuffer();
    for (var i = 0; i < integer.length; i++) {
      if (i > 0 && (integer.length - i) % 3 == 0) buffer.write('.');
      buffer.write(integer[i]);
    }
    return '${negative ? '-' : ''}R\$ ${buffer.toString()},$decimals';
  }

  /// Entrada em formato brasileiro: 1250,50; 1.250,50; 35.
  /// Retorna null quando a entrada é inválida, negativa ou igual a zero.
  static int? parsePositive(String value) {
    final raw = value.trim().replaceAll('R\$', '').replaceAll(' ', '');
    if (!RegExp(r'^\d[\d.]*(,\d{1,2})?$').hasMatch(raw)) {
      return null;
    }
    final pieces = raw.split(',');
    final integer = pieces[0].replaceAll('.', '');
    if (integer.isEmpty) return null;
    final whole = int.tryParse(integer);
    if (whole == null || whole > 9999999999) return null;
    final fraction = pieces.length == 1
        ? 0
        : int.parse(pieces[1].padRight(2, '0'));
    final cents = whole * 100 + fraction;
    return cents > 0 ? cents : null;
  }
}
