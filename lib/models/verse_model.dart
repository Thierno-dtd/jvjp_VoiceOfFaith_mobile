class VerseModel {
  final String reference;
  final String text;
  final String version;

  VerseModel({
    required this.reference,
    required this.text,
    required this.version,
  });

  factory VerseModel.fromJson(Map<String, dynamic> json) {
    // Format pour API Bible (bible-api.com)
    return VerseModel(
      reference: json['reference'] ?? '',
      text: json['text'] ?? '',
      version: json['translation_name'] ?? 'LSG',
    );
  }

  // Format alternatif pour autres APIs
  factory VerseModel.fromAlternativeApi(Map<String, dynamic> json) {
    return VerseModel(
      reference: json['verse']['details']['reference'] ?? '',
      text: json['verse']['details']['text'] ?? '',
      version: json['verse']['details']['version'] ?? 'LSG',
    );
  }
}