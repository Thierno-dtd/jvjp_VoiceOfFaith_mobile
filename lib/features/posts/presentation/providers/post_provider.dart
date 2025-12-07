import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../models/post_model.dart';

final postFirestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Provider de la liste des posts
final postsProvider = StreamProvider<List<PostModel>>((ref) {
  final firestoreService = ref.watch(postFirestoreServiceProvider);
  return firestoreService.getPosts();
});

// Provider pour les posts d'un utilisateur
final userPostsProvider = StreamProvider.family<List<PostModel>, String>((ref, userId) {
  final firestoreService = ref.watch(postFirestoreServiceProvider);
  return firestoreService.getUserPosts(userId);
});

// Provider pour le filtre de catégorie
final postCategoryFilterProvider = StateProvider<PostCategory?>((ref) => null);

// Provider pour la recherche
final postSearchProvider = StateProvider<String>((ref) => '');

// Provider pour les actions sur les posts
final postActionsProvider = StateNotifierProvider<PostActionsNotifier, void>((ref) {
  final firestoreService = ref.watch(postFirestoreServiceProvider);
  return PostActionsNotifier(firestoreService);
});

class PostActionsNotifier extends StateNotifier<void> {
  final FirestoreService _firestoreService;

  PostActionsNotifier(this._firestoreService) : super(null);

  Future<void> likePost(String postId) async {
    try {
      await _firestoreService.incrementPostLikes(postId);
    } catch (e) {
      print('Error liking post: $e');
    }
  }

  Future<void> viewPost(String postId) async {
    try {
      await _firestoreService.incrementPostViews(postId);
    } catch (e) {
      print('Error incrementing views: $e');
    }
  }
}