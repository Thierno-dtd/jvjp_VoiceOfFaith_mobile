import '../models/verse_model.dart';
import 'mock_data.dart';
import '../core/services/bible_api_service.dart';

/// Service mock pour simuler l'API Bible
class MockBibleApiService extends BibleApiService {
  @override
  Future<VerseModel> getVerseOfTheDay() async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 800));
    return MockData.verseOfTheDay;
  }

  @override
  Future<VerseModel> getVerse(String reference) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Pour les tests, retourner toujours le même verset
    return MockData.verseOfTheDay;
  }

  @override
  Future<VerseModel> getVerseFromApiBible(String apiKey, String verseId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockData.verseOfTheDay;
  }
}