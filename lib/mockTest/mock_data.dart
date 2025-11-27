import '../models/audio_model.dart';
import '../models/sermon_model.dart';
import '../models/event_model.dart';
import '../models/post_model.dart';
import '../models/verse_model.dart';
import '../models/user_model.dart';

class MockData {
  // Verset du jour
  static VerseModel get verseOfTheDay => VerseModel(
    reference: 'Jean 3:16',
    text:
    'Car Dieu a tant aimé le monde qu\'il a donné son Fils unique, afin que quiconque croit en lui ne périsse point, mais qu\'il ait la vie éternelle.',
    version: 'LSG',
  );

  // Utilisateur de test
  static UserModel get testUser => UserModel(
    uid: 'test_user_123',
    email: 'test@voiceoffaith.com',
    displayName: 'John Doe',
    role: UserRole.user,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
  );

  // Liste d'audios
  static List<AudioModel> get audios => [
    AudioModel(
      id: 'audio_1',
      title: 'La Puissance de la Foi',
      description:
      'Dans ce message inspirant, découvrez comment la foi peut transformer votre vie quotidienne.',
      audioUrl: 'https://example.com/audio1.mp3',
      thumbnailUrl: 'https://picsum.photos/seed/audio1/800/600',
      duration: 2340, // 39 minutes
      uploadedBy: 'pastor_1',
      uploadedByName: 'Pasteur Jean Martin',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      downloads: 156,
      plays: 423,
      category: AudioCategory.teaching,
    ),
    AudioModel(
      id: 'audio_2',
      title: 'Vivre dans l\'Espérance',
      description:
      'Un message encourageant sur l\'importance de garder espoir dans les moments difficiles.',
      audioUrl: 'https://example.com/audio2.mp3',
      thumbnailUrl: 'https://picsum.photos/seed/audio2/800/600',
      duration: 2820, // 47 minutes
      uploadedBy: 'pastor_1',
      uploadedByName: 'Pasteur Jean Martin',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      downloads: 234,
      plays: 589,
      category: AudioCategory.teaching,
    ),
    AudioModel(
      id: 'audio_3',
      title: 'Radio JVJP - Émission du 20 Nov',
      description:
      'Notre émission radio hebdomadaire avec des témoignages, de la musique et des enseignements.',
      audioUrl: 'https://example.com/audio3.mp3',
      thumbnailUrl: 'https://picsum.photos/seed/audio3/800/600',
      duration: 3600, // 60 minutes
      uploadedBy: 'media_1',
      uploadedByName: 'Équipe Média',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      downloads: 89,
      plays: 312,
      category: AudioCategory.emission,
    ),
    AudioModel(
      id: 'audio_4',
      title: 'L\'Amour de Dieu',
      description:
      'Réflexion profonde sur l\'amour inconditionnel de Dieu pour l\'humanité.',
      audioUrl: 'https://example.com/audio4.mp3',
      thumbnailUrl: 'https://picsum.photos/seed/audio4/800/600',
      duration: 1980, // 33 minutes
      uploadedBy: 'pastor_2',
      uploadedByName: 'Pasteur Marie Dubois',
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
      downloads: 178,
      plays: 467,
      category: AudioCategory.teaching,
    ),
    AudioModel(
      id: 'audio_5',
      title: 'Podcast Jeunesse - Épisode 5',
      description:
      'Discussion sur les défis de la foi chez les jeunes dans le monde moderne.',
      audioUrl: 'https://example.com/audio5.mp3',
      thumbnailUrl: 'https://picsum.photos/seed/audio5/800/600',
      duration: 2640, // 44 minutes
      uploadedBy: 'media_1',
      uploadedByName: 'Équipe Média',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      downloads: 145,
      plays: 356,
      category: AudioCategory.podcast,
    ),
  ];

  // Liste de sermons
  static List<SermonModel> get sermons => [
    SermonModel(
      id: 'sermon_1',
      title: 'La Grâce Transformatrice',
      date: DateTime(2024, 6, 16),
      imageUrl: 'https://picsum.photos/seed/sermon1/800/600',
      pdfUrl: 'https://example.com/sermon1.pdf',
      uploadedBy: 'pastor_1',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      downloads: 89,
    ),
    SermonModel(
      id: 'sermon_2',
      title: 'Marcher dans la Lumière',
      date: DateTime(2024, 6, 9),
      imageUrl: 'https://picsum.photos/seed/sermon2/800/600',
      pdfUrl: 'https://example.com/sermon2.pdf',
      uploadedBy: 'pastor_1',
      createdAt: DateTime.now().subtract(const Duration(days: 17)),
      downloads: 156,
    ),
    SermonModel(
      id: 'sermon_3',
      title: 'Le Fruit de l\'Esprit',
      date: DateTime(2024, 6, 2),
      imageUrl: 'https://picsum.photos/seed/sermon3/800/600',
      pdfUrl: 'https://example.com/sermon3.pdf',
      uploadedBy: 'pastor_2',
      createdAt: DateTime.now().subtract(const Duration(days: 24)),
      downloads: 234,
    ),
    SermonModel(
      id: 'sermon_4',
      title: 'La Prière Efficace',
      date: DateTime(2024, 5, 26),
      imageUrl: 'https://picsum.photos/seed/sermon4/800/600',
      pdfUrl: 'https://example.com/sermon4.pdf',
      uploadedBy: 'pastor_1',
      createdAt: DateTime.now().subtract(const Duration(days: 31)),
      downloads: 178,
    ),
    SermonModel(
      id: 'sermon_5',
      title: 'Vivre en Communauté',
      date: DateTime(2024, 5, 19),
      imageUrl: 'https://picsum.photos/seed/sermon5/800/600',
      pdfUrl: 'https://example.com/sermon5.pdf',
      uploadedBy: 'pastor_2',
      createdAt: DateTime.now().subtract(const Duration(days: 38)),
      downloads: 201,
    ),
    SermonModel(
      id: 'sermon_6',
      title: 'La Sagesse Divine',
      date: DateTime(2024, 5, 12),
      imageUrl: 'https://picsum.photos/seed/sermon6/800/600',
      pdfUrl: 'https://example.com/sermon6.pdf',
      uploadedBy: 'pastor_1',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      downloads: 167,
    ),
  ];

  // Liste d'événements
  static List<EventModel> get events => [
    EventModel(
      id: 'event_1',
      title: 'Convention Annuelle 2024',
      description:
      'Rejoignez-nous pour notre convention annuelle, un moment de louange, d\'enseignement et de communion fraternelle. Trois jours intensifs de rencontres avec Dieu et nos frères et sœurs en Christ.',
      startDate: DateTime.now().add(const Duration(days: 15)),
      endDate: DateTime.now().add(const Duration(days: 17)),
      imageUrl: 'https://picsum.photos/seed/event1/1200/800',
      location: 'Centre de Conférences JVJP',
      dailySummaries: [
        DailySummary(
          day: 1,
          date: DateTime.now().add(const Duration(days: 15)),
          title: 'Jour 1: Ouverture & Louange',
          summary:
          'La convention s\'ouvre avec une soirée de louange et d\'adoration puissante. Témoignages inspirants et message d\'ouverture du Pasteur Jean Martin.',
          youtubeUrl: null,
        ),
        DailySummary(
          day: 2,
          date: DateTime.now().add(const Duration(days: 16)),
          title: 'Jour 2: Enseignements',
          summary:
          'Journée consacrée aux enseignements bibliques approfondis avec plusieurs orateurs invités. Ateliers en après-midi sur divers thèmes spirituels.',
          youtubeUrl: null,
        ),
        DailySummary(
          day: 3,
          date: DateTime.now().add(const Duration(days: 17)),
          title: 'Jour 3: Clôture & Engagement',
          summary:
          'Culte de clôture avec prières d\'engagement et de consécration. Moment de communion et de partage autour d\'un repas fraternel.',
          youtubeUrl: null,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    EventModel(
      id: 'event_2',
      title: 'Camp de Jeunesse',
      description:
      'Un week-end dédié aux jeunes avec des activités, des enseignements adaptés, des moments de louange et de partage. Une opportunité unique de grandir dans la foi avec d\'autres jeunes.',
      startDate: DateTime.now().add(const Duration(days: 8)),
      endDate: DateTime.now().add(const Duration(days: 9)),
      imageUrl: 'https://picsum.photos/seed/event2/1200/800',
      location: 'Camp Bethel, Montagne Sainte',
      dailySummaries: [
        DailySummary(
          day: 1,
          date: DateTime.now().add(const Duration(days: 8)),
          title: 'Samedi: Activités & Enseignements',
          summary:
          'Journée complète avec des jeux en équipe, des enseignements sur l\'identité en Christ, et une veillée de louange autour du feu de camp.',
          youtubeUrl: null,
        ),
        DailySummary(
          day: 2,
          date: DateTime.now().add(const Duration(days: 9)),
          title: 'Dimanche: Culte & Retour',
          summary:
          'Culte matinal en plein air, témoignages des participants, et temps de prière avant le retour.',
          youtubeUrl: null,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    EventModel(
      id: 'event_3',
      title: 'Journée de Jeûne et Prière',
      description:
      'Consacrons une journée entière à la prière et au jeûne pour nos familles, notre communauté et notre nation. Plusieurs sessions de prière tout au long de la journée.',
      startDate: DateTime.now().add(const Duration(days: 5)),
      endDate: DateTime.now().add(const Duration(days: 5)),
      imageUrl: 'https://picsum.photos/seed/event3/1200/800',
      location: 'Église JVJP',
      dailySummaries: [
        DailySummary(
          day: 1,
          date: DateTime.now().add(const Duration(days: 5)),
          title: 'Journée de Prière',
          summary:
          '6h-22h: Sessions de prière toutes les 2 heures. Prière pour les familles (matin), la jeunesse (midi), la guérison (après-midi), et la nation (soir).',
          youtubeUrl: null,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  // Liste de posts
  static List<PostModel> get posts => [
    PostModel(
      id: 'post_1',
      type: PostType.image,
      category: PostCategory.pensee,
      content:
      'La foi ne consiste pas à avoir une carte de toutes les routes, mais à faire confiance au guide à chaque pas.',
      mediaUrl: 'https://picsum.photos/seed/post1/800/800',
      authorId: 'pastor_1',
      authorName: 'Pasteur Jean Martin',
      authorRole: 'Pasteur Principal',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      likes: 234,
      views: 1456,
    ),
    PostModel(
      id: 'post_2',
      type: PostType.image,
      category: PostCategory.media,
      content:
      'Moment de louange incroyable ce dimanche! Merci à tous ceux qui étaient présents. #JVJP #Louange',
      mediaUrl: 'https://picsum.photos/seed/post2/800/800',
      authorId: 'media_1',
      authorName: 'Équipe Média JVJP',
      authorRole: 'Équipe Média',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      likes: 456,
      views: 2134,
    ),
    PostModel(
      id: 'post_3',
      type: PostType.image,
      category: PostCategory.pasteur,
      content:
      'Rappel important: La prière est la clé qui ouvre les portes fermées. Ne cessez jamais de prier!',
      mediaUrl: 'https://picsum.photos/seed/post3/800/800',
      authorId: 'pastor_2',
      authorName: 'Pasteur Marie Dubois',
      authorRole: 'Pasteur Associé',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      likes: 189,
      views: 987,
    ),
  ];

  // Paramètres de l'application
  static Map<String, dynamic> get appSettings => {
    'isLive': true, // Mettre à false pour désactiver le live
    'liveYoutubeUrl': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    'liveTitle': 'Culte du Dimanche Matin',
  };
}