import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../models/event_model.dart';

// Provider du service Firestore
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Provider de tous les événements
final allEventsProvider = StreamProvider<List<EventModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getEvents();
});

// Provider des événements à venir
final upcomingEventsProvider = StreamProvider<List<EventModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUpcomingEvents();
});

// Provider pour un événement spécifique
final eventDetailProvider = FutureProvider.family<EventModel, String>((ref, id) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getEvent(id);
});

// Provider pour l'onglet sélectionné
final selectedEventTabProvider = StateProvider<int>((ref) => 0);