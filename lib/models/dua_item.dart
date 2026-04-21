class DuaItem {
  final String id;
  final String arabic;
  final String transliteration;
  final Map<String, String> translations;
  final String category;

  const DuaItem({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.translations,
    required this.category,
  });

  String translationFor(String langCode) {
    return translations[langCode] ??
        translations['en'] ??
        '';
  }
}