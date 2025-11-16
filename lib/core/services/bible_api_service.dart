import 'package:dio/dio.dart';
import '../../models/verse_model.dart';

class BibleApiService {
  final Dio _dio = Dio();

  // API 1: Bible-API.com (gratuit, pas de clé requise)
  // Format: https://bible-api.com/john+3:16?translation=kjv
  
  // API 2: API.Bible (nécessite une clé gratuite)
  // https://scripture.api.bible/
  
  // Pour cet exemple, utilisons Bible-API.com car elle est gratuite

  Future<VerseModel> getVerseOfTheDay() async {
    try {
      // Générer un verset aléatoire quotidien
      final verse = _getDailyVerse();
      
      final response = await _dio.get(
        'https://bible-api.com/$verse',
        queryParameters: {
          'translation': 'lsg', // Louis Segond
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Nettoyer le texte
        String cleanText = data['text'] as String;
        cleanText = cleanText.replaceAll(RegExp(r'\s+'), ' ').trim();
        
        return VerseModel(
          reference: data['reference'] as String,
          text: cleanText,
          version: data['translation_name'] as String? ?? 'LSG',
        );
      } else {
        throw Exception('Erreur lors de la récupération du verset');
      }
    } catch (e) {
      print('Erreur API Bible: $e');
      // Retourner un verset par défaut en cas d'erreur
      return _getDefaultVerse();
    }
  }

  // Récupérer un verset spécifique
  Future<VerseModel> getVerse(String reference) async {
    try {
      // Format: "jean 3:16" ou "john 3:16"
      final response = await _dio.get(
        'https://bible-api.com/$reference',
        queryParameters: {
          'translation': 'lsg',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        String cleanText = data['text'] as String;
        cleanText = cleanText.replaceAll(RegExp(r'\s+'), ' ').trim();
        
        return VerseModel(
          reference: data['reference'] as String,
          text: cleanText,
          version: data['translation_name'] as String? ?? 'LSG',
        );
      } else {
        throw Exception('Verset introuvable');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération du verset: $e');
    }
  }

  // Générer une référence de verset basée sur le jour de l'année
  String _getDailyVerse() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays + 1;
    
    // Liste de versets populaires (365 versets différents)
    final verses = [
      'jean 3:16',
      'philippiens 4:13',
      'proverbes 3:5-6',
      'romains 8:28',
      'psaume 23:1',
      'matthieu 6:33',
      'jacques 1:2-3',
      'ephesiens 2:8-9',
      'josue 1:9',
      'jean 14:6',
      'romains 12:2',
      '2 corinthiens 5:17',
      'galates 5:22-23',
      'hebreux 11:1',
      'psaume 46:1',
      'esaie 40:31',
      'matthieu 5:14',
      'jean 1:1',
      '1 jean 4:19',
      'romains 5:8',
      // ... Ajouter 345 versets supplémentaires pour couvrir toute l'année
    ];
    
    final index = (dayOfYear - 1) % verses.length;
    return verses[index];
  }

  // Verset par défaut en cas d'erreur
  VerseModel _getDefaultVerse() {
    return VerseModel(
      reference: 'Jean 3:16',
      text: 'Car Dieu a tant aimé le monde qu\'il a donné son Fils unique, '
          'afin que quiconque croit en lui ne périsse point, mais qu\'il ait la vie éternelle.',
      version: 'LSG',
    );
  }

  // Alternative avec API.Bible (nécessite une clé)
  // Inscrivez-vous sur https://scripture.api.bible/ pour obtenir une clé gratuite
  
  Future<VerseModel> getVerseFromApiBible(String apiKey, String verseId) async {
    try {
      final response = await _dio.get(
        'https://api.scripture.api.bible/v1/bibles/de4e12af7f28f599-02/verses/$verseId',
        options: Options(
          headers: {
            'api-key': apiKey,
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return VerseModel(
          reference: data['reference'] as String,
          text: data['content'] as String,
          version: 'LSG',
        );
      } else {
        throw Exception('Erreur API.Bible');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}