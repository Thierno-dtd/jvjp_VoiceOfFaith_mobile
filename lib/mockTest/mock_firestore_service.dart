import 'package:voice_of_faith/models/donation_model.dart';

import '../models/audio_model.dart';
import '../models/sermon_model.dart';
import '../models/post_model.dart';
import '../models/event_model.dart';
import 'mock_data.dart';
import '../core/services/firestore_service.dart';

/// Service mock pour simuler Firestore
/// Implémente les mêmes méthodes que FirestoreService
class MockFirestoreService implements FirestoreService {
  // ============ AUDIOS ============

  Stream<List<AudioModel>> getAudios() async* {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 500));
    yield MockData.audios;
  }

  Future<AudioModel> getAudio(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.audios.firstWhere(
          (audio) => audio.id == id,
      orElse: () => throw Exception('Audio introuvable'),
    );
  }

  Future<void> incrementAudioPlays(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    print('Mock: Incremented plays for audio $id');
  }

  Future<void> incrementAudioDownloads(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    print('Mock: Incremented downloads for audio $id');
  }

  // ============ SERMONS ============

  Stream<List<SermonModel>> getSermons() async* {
    await Future.delayed(const Duration(milliseconds: 500));
    yield MockData.sermons;
  }

  Future<SermonModel> getSermon(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.sermons.firstWhere(
          (sermon) => sermon.id == id,
      orElse: () => throw Exception('Sermon introuvable'),
    );
  }

  Future<void> incrementSermonDownloads(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    print('Mock: Incremented downloads for sermon $id');
  }

  // ============ POSTS (méthodes manquantes) ============

  @override
  Future<String> createPost(PostModel post) async {
    await Future.delayed(const Duration(milliseconds: 300));
    print('Mock: Created post ${post.id}');
    return 'mock_post_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<void> updatePost(String id, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 300));
    print('Mock: Updated post $id');
  }

  @override
  Future<void> deletePost(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    print('Mock: Deleted post $id');
  }

  // ============ POSTS ============

  Stream<List<PostModel>> getPosts() async* {
    await Future.delayed(const Duration(milliseconds: 500));
    yield MockData.posts;
  }

  Stream<List<PostModel>> getUserPosts(String userId) async* {
    await Future.delayed(const Duration(milliseconds: 500));
    yield MockData.posts
        .where((post) => post.authorId == userId)
        .toList();
  }

  Future<void> incrementPostViews(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    print('Mock: Incremented views for post $id');
  }

  Future<void> incrementPostLikes(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    print('Mock: Incremented likes for post $id');
  }

  // ============ EVENTS ============

  Stream<List<EventModel>> getEvents() async* {
    await Future.delayed(const Duration(milliseconds: 500));
    yield MockData.events;
  }

  Stream<List<EventModel>> getUpcomingEvents() async* {
    await Future.delayed(const Duration(milliseconds: 500));
    final now = DateTime.now();
    yield MockData.events
        .where((event) => event.startDate.isAfter(now))
        .toList();
  }

  Future<EventModel> getEvent(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.events.firstWhere(
          (event) => event.id == id,
      orElse: () => throw Exception('Événement introuvable'),
    );
  }

  @override
  Future<String> createEvent(EventModel event) async {
    await Future.delayed(const Duration(milliseconds: 300));
    print('Mock: Created event ${event.id}');
    return 'mock_event_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<void> updateEvent(String id, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 300));
    print('Mock: Updated event $id');
  }

  @override
  Future<void> deleteEvent(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    print('Mock: Deleted event $id');
  }

  // ============ AUDIOS (méthodes manquantes) ============

  @override
  Future<String> createAudio(AudioModel audio) async {
    await Future.delayed(const Duration(milliseconds: 300));
    print('Mock: Created audio ${audio.id}');
    return 'mock_audio_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<void> updateAudio(String id, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 300));
    print('Mock: Updated audio $id');
  }

  @override
  Future<void> deleteAudio(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    print('Mock: Deleted audio $id');
  }

  // ============ SERMONS (méthodes manquantes) ============

  @override
  Future<String> createSermon(SermonModel sermon) async {
    await Future.delayed(const Duration(milliseconds: 300));
    print('Mock: Created sermon ${sermon.id}');
    return 'mock_sermon_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<void> deleteSermon(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    print('Mock: Deleted sermon $id');
  }

  // ============ SETTINGS ============

  Stream<Map<String, dynamic>> getAppSettings() async* {
    await Future.delayed(const Duration(milliseconds: 300));
    yield MockData.appSettings;
  }

  Stream<bool> isLiveActive() async* {
    await Future.delayed(const Duration(milliseconds: 300));
    yield MockData.appSettings['isLive'] ?? false;
  }

  Stream<String?> getLiveUrl() async* {
    await Future.delayed(const Duration(milliseconds: 300));
    yield MockData.appSettings['liveYoutubeUrl'] as String?;
  }

  @override
  Future<void> updateLiveStatus({
    required bool isLive,
    String? youtubeUrl,
    String? title,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    print('Mock: Updated live status - isLive: $isLive');
  }

  @override
  Future<String> createDonation(DonationModel donation) {
    // TODO: implement createDonation
    throw UnimplementedError();
  }

  @override
  Stream<List<DonationModel>> getAllDonations() {
    // TODO: implement getAllDonations
    throw UnimplementedError();
  }

  @override
  Stream<List<DonationModel>> getUserDonations(String userId) {
    // TODO: implement getUserDonations
    throw UnimplementedError();
  }
}