import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../models/sermon_model.dart';

// Provider du service Firestore
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
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