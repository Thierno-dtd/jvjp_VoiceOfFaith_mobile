import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../models/sermon_model.dart';
import '../../../../mockTest/app_config.dart';
import '../../../../mockTest/mock_firestore_service.dart';

final sermonFirestoreServiceProvider = Provider<FirestoreService>((ref) {
  if (AppConfig.useMockData) {
    return MockFirestoreService();
  }
  return FirestoreService();
});

// Provider de la liste des sermons
final sermonsProvider = StreamProvider<List<SermonModel>>((ref) {
  final firestoreService = ref.watch(sermonFirestoreServiceProvider);
  return firestoreService.getSermons();
});

// Provider pour un sermon spécifique
final sermonDetailProvider = FutureProvider.family<SermonModel, String>((ref, id) async {
  final firestoreService = ref.watch(sermonFirestoreServiceProvider);
  return await firestoreService.getSermon(id);
});

// Provider pour la recherche
final sermonSearchProvider = StateProvider<String>((ref) => "");
