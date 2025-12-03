import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/audio_model.dart';
import '../../models/sermon_model.dart';
import '../../models/post_model.dart';
import '../../models/event_model.dart';
import '../../models/donation_model.dart';


class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ AUDIOS ============

  // Créer un audio
  Future<String> createAudio(AudioModel audio) async {
    final docRef = await _firestore.collection('audios').add(audio.toMap());
    return docRef.id;
  }

  // Récupérer tous les audios
  Stream<List<AudioModel>> getAudios() {
    return _firestore
        .collection('audios')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AudioModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Récupérer un audio
  Future<AudioModel> getAudio(String id) async {
    final doc = await _firestore.collection('audios').doc(id).get();
    if (!doc.exists) throw Exception('Audio introuvable');
    return AudioModel.fromMap(doc.data()!, id);
  }

  // Mettre à jour un audio
  Future<void> updateAudio(String id, Map<String, dynamic> data) async {
    await _firestore.collection('audios').doc(id).update(data);
  }

  // Supprimer un audio
  Future<void> deleteAudio(String id) async {
    await _firestore.collection('audios').doc(id).delete();
  }

  // Incrémenter les plays
  Future<void> incrementAudioPlays(String id) async {
    await _firestore.collection('audios').doc(id).update({
      'plays': FieldValue.increment(1),
    });
  }

  // Incrémenter les downloads
  Future<void> incrementAudioDownloads(String id) async {
    await _firestore.collection('audios').doc(id).update({
      'downloads': FieldValue.increment(1),
    });
  }

  // ============ SERMONS ============

  // Créer un sermon
  Future<String> createSermon(SermonModel sermon) async {
    final docRef = await _firestore.collection('sermons').add(sermon.toMap());
    return docRef.id;
  }

  // Récupérer tous les sermons
  Stream<List<SermonModel>> getSermons() {
    return _firestore
        .collection('sermons')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SermonModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Récupérer un sermon
  Future<SermonModel> getSermon(String id) async {
    final doc = await _firestore.collection('sermons').doc(id).get();
    if (!doc.exists) throw Exception('Sermon introuvable');
    return SermonModel.fromMap(doc.data()!, id);
  }

  // Supprimer un sermon
  Future<void> deleteSermon(String id) async {
    await _firestore.collection('sermons').doc(id).delete();
  }

  // Incrémenter les downloads
  Future<void> incrementSermonDownloads(String id) async {
    await _firestore.collection('sermons').doc(id).update({
      'downloads': FieldValue.increment(1),
    });
  }

  // ============ POSTS ============

  // Créer un post
  Future<String> createPost(PostModel post) async {
    final docRef = await _firestore.collection('posts').add(post.toMap());
    return docRef.id;
  }

  // Récupérer tous les posts
  Stream<List<PostModel>> getPosts() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Récupérer les posts d'un utilisateur
  Stream<List<PostModel>> getUserPosts(String userId) {
    return _firestore
        .collection('posts')
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Mettre à jour un post
  Future<void> updatePost(String id, Map<String, dynamic> data) async {
    await _firestore.collection('posts').doc(id).update(data);
  }

  // Supprimer un post
  Future<void> deletePost(String id) async {
    await _firestore.collection('posts').doc(id).delete();
  }

  // Incrémenter les vues
  Future<void> incrementPostViews(String id) async {
    await _firestore.collection('posts').doc(id).update({
      'views': FieldValue.increment(1),
    });
  }

  // Incrémenter les likes
  Future<void> incrementPostLikes(String id) async {
    await _firestore.collection('posts').doc(id).update({
      'likes': FieldValue.increment(1),
    });
  }

  // ============ EVENTS ============

  // Créer un événement
  Future<String> createEvent(EventModel event) async {
    final docRef = await _firestore.collection('events').add(event.toMap());
    return docRef.id;
  }

  // Récupérer tous les événements
  Stream<List<EventModel>> getEvents() {
    return _firestore
        .collection('events')
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Récupérer les événements à venir
  Stream<List<EventModel>> getUpcomingEvents() {
    return _firestore
        .collection('events')
        .where('startDate', isGreaterThan: Timestamp.now())
        .orderBy('startDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Récupérer un événement
  Future<EventModel> getEvent(String id) async {
    final doc = await _firestore.collection('events').doc(id).get();
    if (!doc.exists) throw Exception('Événement introuvable');
    return EventModel.fromMap(doc.data()!, id);
  }

  // Mettre à jour un événement
  Future<void> updateEvent(String id, Map<String, dynamic> data) async {
    await _firestore.collection('events').doc(id).update(data);
  }

  // Supprimer un événement
  Future<void> deleteEvent(String id) async {
    await _firestore.collection('events').doc(id).delete();
  }

  // ============ SETTINGS ============

  // Récupérer les paramètres de l'app
  Stream<Map<String, dynamic>> getAppSettings() {
    return _firestore
        .collection('settings')
        .doc('app_settings')
        .snapshots()
        .map((doc) => doc.data() ?? {});
  }

  // Vérifier si un live est en cours
  Stream<bool> isLiveActive() {
    return getAppSettings().map((settings) => settings['isLive'] ?? false);
  }

  // Récupérer l'URL du live
  Stream<String?> getLiveUrl() {
    return getAppSettings()
        .map((settings) => settings['liveYoutubeUrl'] as String?);
  }

  // Mettre à jour le statut du live
  Future<void> updateLiveStatus({
    required bool isLive,
    String? youtubeUrl,
    String? title,
  }) async {
    await _firestore.collection('settings').doc('app_settings').update({
      'isLive': isLive,
      if (youtubeUrl != null) 'liveYoutubeUrl': youtubeUrl,
      if (title != null) 'liveTitle': title,
    });
  }

  // ============ DONATIONS ============

  // Créer une donation
  Future<String> createDonation(DonationModel donation) async {
    final docRef = await _firestore.collection('donations').add(donation.toMap());
    return docRef.id;
  }

  // Récupérer les donations d'un utilisateur
  Stream<List<DonationModel>> getUserDonations(String userId) {
    return _firestore
        .collection('donations')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => DonationModel.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  // (Optionnel) Récupérer toutes les donations — utile pour dashboard admin
  Stream<List<DonationModel>> getAllDonations() {
    return _firestore
        .collection('donations')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => DonationModel.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

}