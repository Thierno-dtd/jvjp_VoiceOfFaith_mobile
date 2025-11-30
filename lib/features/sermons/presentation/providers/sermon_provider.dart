import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../models/sermon_model.dart';
import '../../../../mockTest/app_config.dart';
import '../../../../mockTest/mock_firestore_service.dart';

// Provider du service Firestore
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  if (AppConfig.useMockData) {
    return MockFirestoreService();
  }
  return FirestoreService();
});

// Provider de la liste des sermons
final sermonsProvider = StreamProvider<List<SermonModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getSermons();
});

// Provider pour un sermon spécifique
final sermonDetailProvider = FutureProvider.family<SermonModel, String>((ref, id) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getSermon(id);
});

final sermonSearchProvider = StateProvider<String>((ref) => "");

final filteredSermonsProvider = Provider<List<SermonModel>>((ref) {
  final search = ref.watch(sermonSearchProvider).toLowerCase();
  final asyncSermons = ref.watch(sermonsProvider);

  return asyncSermons.when(
    data: (sermons) {
      if (search.isEmpty) return sermons;

      return sermons.where((sermon) {
        final title = sermon.title.toLowerCase();
        //final description = sermon.description.toLowerCase();
        //return title.contains(search) || description.contains(search);
        return title.contains(search);

      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
