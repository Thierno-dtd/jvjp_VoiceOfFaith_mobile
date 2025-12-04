import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/verse_model.dart';

class BibleApiService {
  final Dio _dio = Dio();

  /// Obtenir le verset du jour depuis OurManna API (gratuit, français)
  Future<VerseModel> getVerseOfTheDay() async {
    try {
      final response = await _dio.get(
        'https://bible-api.com/?random=verse&translation=ls1910',
      );

      if (response.statusCode == 200) {
        final data = response.data;

        return VerseModel(
          reference: data['reference'],
          text: data['verses'][0]['text'].trim(),
          version: 'LS1910', // Louis Segond Français
        );
      }
    } catch (e) {
      print('Erreur : $e');
    }

    return _getDefaultVerse();
  }


  /// Ouvrir la Bible en ligne au verset spécifié
  /// Utilise BibleGateway.com qui est gratuit et supporte le français
  Future<void> openVerseInBrowser(String reference) async {
    final encoded = Uri.encodeComponent(reference);
    final url = Uri.parse(
      'https://www.biblegateway.com/passage/?search=$encoded&version=LSG',
    );

    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw('Aucun navigateur n’a été trouvé pour ouvrir l’URL.');
    }
  }


  /// Alternative : Ouvrir sur YouVersion Bible (application populaire)
  Future<void> openVerseInYouVersion(String reference) async {
    try {
      // YouVersion supporte le deep linking
      // Format: bible.com/bible/93/JHN.3.16.LSG
      final encodedReference = Uri.encodeComponent(reference);
      final url = Uri.parse(
          'https://www.bible.com/fr/bible/93/$encodedReference.LSG'
      );

      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw Exception('Impossible d\'ouvrir le lien');
      }
    } catch (e) {
      print('Erreur ouverture YouVersion: $e');
      rethrow;
    }
  }

  /// Verset par défaut en cas d'erreur réseau
  VerseModel _getDefaultVerse() {
    // Choisir un verset basé sur le jour de la semaine
    final versets = [
      VerseModel(
        reference: 'Jean 3:16',
        text: 'Car Dieu a tant aimé le monde qu\'il a donné son Fils unique, '
            'afin que quiconque croit en lui ne périsse point, mais qu\'il ait la vie éternelle.',
        version: 'LSG',
      ),
      VerseModel(
        reference: 'Philippiens 4:13',
        text: 'Je puis tout par celui qui me fortifie.',
        version: 'LSG',
      ),
      VerseModel(
        reference: 'Psaume 23:1',
        text: 'L\'Éternel est mon berger: je ne manquerai de rien.',
        version: 'LSG',
      ),
      VerseModel(
        reference: 'Proverbes 3:5-6',
        text: 'Confie-toi en l\'Éternel de tout ton cœur, et ne t\'appuie pas sur ta sagesse; '
            'reconnais-le dans toutes tes voies, et il aplanira tes sentiers.',
        version: 'LSG',
      ),
      VerseModel(
        reference: 'Romains 8:28',
        text: 'Nous savons, du reste, que toutes choses concourent au bien de ceux qui aiment Dieu, '
            'de ceux qui sont appelés selon son dessein.',
        version: 'LSG',
      ),
      VerseModel(
        reference: 'Matthieu 11:28',
        text: 'Venez à moi, vous tous qui êtes fatigués et chargés, et je vous donnerai du repos.',
        version: 'LSG',
      ),
      VerseModel(
        reference: 'Josué 1:9',
        text: 'Ne t\'ai-je pas donné cet ordre: Fortifie-toi et prends courage? '
            'Ne t\'effraie point et ne t\'épouvante point, car l\'Éternel, ton Dieu, est avec toi dans tout ce que tu entreprendras.',
        version: 'LSG',
      ),
    ];

    // Utiliser le jour de la semaine pour varier (0-6)
    final dayOfWeek = DateTime.now().weekday % versets.length;
    return versets[dayOfWeek];
  }
}