String formatRubles(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  if (value < 0) buffer.write('-');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('\u00A0');
    buffer.write(digits[i]);
  }
  buffer.write('\u00A0₽');
  return buffer.toString();
}

String formatWeight(int grams) {
  if (grams >= 1000) {
    final kilograms = grams / 1000;
    final text = kilograms == kilograms.roundToDouble()
        ? kilograms.toStringAsFixed(0)
        : kilograms.toStringAsFixed(1);
    return '$text кг';
  }
  return '$grams г';
}

String formatDateTime(DateTime value) {
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${two(local.day)}.${two(local.month)}.${local.year} '
      '${two(local.hour)}:${two(local.minute)}';
}

String plural(int count, String one, String few, String many) {
  final mod10 = count.abs() % 10;
  final mod100 = count.abs() % 100;
  final word = mod10 == 1 && mod100 != 11
      ? one
      : (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14))
          ? few
          : many;
  return '$count $word';
}

const skuTextStyleFamily = 'Consolas';
