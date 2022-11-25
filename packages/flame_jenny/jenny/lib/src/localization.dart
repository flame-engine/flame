class Localization {
  const Localization(
    this.pluralFunction,
    this.pluralMinWordCount, [
    int? pluralMaxWordCount,
  ]) : pluralMaxWordCount = pluralMaxWordCount ?? pluralMinWordCount;

  final PluralFnType pluralFunction;
  final int pluralMinWordCount;
  final int pluralMaxWordCount;
}

typedef PluralFnType = String Function(num, List<String>);

final Map<String, Localization> localizationInfo = {
  'az': const Localization(_plural8, 2),
  'bg': const Localization(_plural8, 2),
  'de': const Localization(_plural4, 2),
  'el': const Localization(_plural8, 2),
  'en': const Localization(_pluralEn, 1, 2),
  'es': const Localization(_plural8, 2),
  'et': const Localization(_plural4, 2),
  'fi': const Localization(_plural4, 2),
  'fr': const Localization(_plural2, 2),
  'haw': const Localization(_plural8, 2),
  'hu': const Localization(_plural8, 2),
  'id': const Localization(_plural0, 1),
  'it': const Localization(_plural4, 2),
  'ja': const Localization(_plural0, 1),
  'ka': const Localization(_plural8, 2),
  'kk': const Localization(_plural8, 2),
  'ko': const Localization(_plural0, 1),
  'ky': const Localization(_plural8, 2),
  'mn': const Localization(_plural8, 2),
  'nl': const Localization(_plural4, 2),
  'no': const Localization(_plural8, 2),
  'pl': const Localization(_plural25, 4),
  'pt': const Localization(_plural2, 2),
  'ru': const Localization(_plural29, 3),
  'sv': const Localization(_plural4, 2),
  'th': const Localization(_plural0, 1),
  'tk': const Localization(_plural8, 2),
  'tr': const Localization(_plural8, 2),
  'uk': const Localization(_plural29, 3),
  'uz': const Localization(_plural8, 2),
  'vi': const Localization(_plural0, 1),
  'yi': const Localization(_plural4, 2),
  'zh': const Localization(_plural0, 1),
};

//------------------------------------------------------------------------------
// Plural functions
//------------------------------------------------------------------------------

/// English (en)
String _pluralEn(num number, List<String> words) {
  assert(words.isNotEmpty);
  if (number == 1.0) {
    return words[0];
  }
  if (words.length == 2) {
    return words[1];
  }
  final singular = words[0];
  final ch1 = singular.isNotEmpty ? singular[singular.length - 1] : '';
  final ch2 = singular.length >= 2 ? singular[singular.length - 2] : '';
  if ((ch2 == 's' && ch1 == 's') ||
      (ch2 == 'c' && ch1 == 'h') ||
      (ch2 == 's' && ch1 == 'h') ||
      ch1 == 'x') {
    return '${singular}es';
  }
  if (ch1 == 'y') {
    return '${singular.substring(0, singular.length - 1)}ies';
  }
  return '${singular}s';
}

/// Indonesian (id), Japanese (ja), Korean (ko), Thai (th), Vietnamese (vi),
/// Chinese (zh)
String _plural0(num number, List<String> words) {
  return words[0];
}

/// French (fr), Portuguese (pt)
String _plural2(num number, List<String> words) {
  final i = number.toInt();
  return (i == 0 || i == 1) ? words[0] : words[1];
}

/// German (de), Estonian (et), Finnish (fi), Italian (it), Dutch (nl),
/// Swedish (sv), Yiddish (yi)
String _plural4(num number, List<String> words) {
  if (number == 1.0) {
    return words[0];
  }
  return words[1];
}

/// Azerbaijani (az), Bulgarian (bg), Greek (el), Spanish (es), Hawaiian (haw),
/// Hungarian (hu), Georgian (ka), Kazakh (kk), Kyrgyz (ky), Mongolian (mn),
/// Norwegian (no), Turkmen (tk), Turkish (tr), Uzbek (uz)
String _plural8(num number, List<String> words) {
  final n = number.abs();
  return (n == 1.0) ? words[0] : words[1];
}

/// Polish (pl)
String _plural25(num number, List<String> words) {
  final i = number.toInt();
  if (i == number) {
    if (i == 1) {
      return words[0];
    }
    if ((i % 10) >= 2 && (i % 10) <= 4 && ((i % 100) < 12 || (i % 100) > 14)) {
      return words[1];
    }
  }
  if (((i != 1) && (i % 10) >= 0 && (i % 10) <= 1) ||
      ((i % 10) >= 5 && (i % 10) <= 9) ||
      ((i % 100) >= 12 && (i % 100) <= 14)) {
    return words[2];
  }
  return words[3];
}

/// Ukrainian (uk), Russian (ru)
String _plural29(num number, List<String> words) {
  final i = number.toInt();
  if (i == number) {
    final iMod10 = i % 10;
    final iMod100 = i % 100;
    if (iMod10 == 1 && iMod100 != 11) {
      return words[1];
    }
    if (iMod10 >= 2 && iMod10 <= 4 && (iMod100 < 12 || iMod100 > 14)) {
      return words[2];
    }
  }
  return words[0];
}
