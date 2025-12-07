import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/bible_api_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../models/verse_model.dart';
import '../../../../models/audio_model.dart';
import '../../../../models/event_model.dart';
import '../../../../models/post_model.dart';

// Provider du service Bible
final bibleApiServiceProvider = Provider<BibleApiService>((ref) {
  return BibleApiService();
});

final homeFirestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Provider du verset du jour
final verseOfTheDayProvider = FutureProvider<VerseModel>((ref) async {
  final service = ref.watch(bibleApiServiceProvider);
  return await service.getVerseOfTheDay();
});

// Provider du dernier audio
final latestAudioProvider = StreamProvider<AudioModel?>((ref) {
  final firestoreService = ref.watch(homeFirestoreServiceProvider);
  return firestoreService.getAudios().map((audios) {
    return audios.isNotEmpty ? audios.first : null;
  });
});

// Provider des événements à venir
final upcomingEventsProvider = StreamProvider<List<EventModel>>((ref) {
  final firestoreService = ref.watch(homeFirestoreServiceProvider);
  return firestoreService.getUpcomingEvents();
});

// Provider de la pensée du jour
final thoughtOfTheDayProvider = StreamProvider<PostModel?>((ref) {
  final firestoreService = ref.watch(homeFirestoreServiceProvider);
  return firestoreService.getPosts().map((posts) {
    // Filtrer pour obtenir la dernière pensée du jour
    final thoughts = posts.where((p) => p.category == PostCategory.pensee).toList();
    return thoughts.isNotEmpty ? thoughts.first : null;
  });
});

// Provider du statut LIVE
final liveStatusProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final firestoreService = ref.watch(homeFirestoreServiceProvider);
  return firestoreService.getAppSettings();
});