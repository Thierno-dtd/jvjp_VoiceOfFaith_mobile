import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream de l'utilisateur actuel avec logs
  Stream<User?> get authStateChanges {
    print('🔵 AuthService: Initializing authStateChanges stream');
    return _auth.authStateChanges().map((user) {
      print('🔵 AuthService: authStateChanges emitted - User: ${user?.uid ?? "null"}');
      return user;
    });
  }

  // Utilisateur actuel
  User? get currentUser {
    final user = _auth.currentUser;
    print('🔵 AuthService: currentUser getter called - User: ${user?.uid ?? "null"}');
    return user;
  }

  // Inscription
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      print('🔵 AuthService: signUp called for $email');

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('🔵 AuthService: User created with Firebase Auth');

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Erreur lors de la création du compte');
      }

      // Mettre à jour le displayName
      await user.updateDisplayName(displayName);
      print('🔵 AuthService: DisplayName updated');

      // Créer le document utilisateur dans Firestore
      final userModel = UserModel(
        uid: user.uid,
        email: email,
        displayName: displayName,
        role: UserRole.user,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toMap());

      print('🔵 AuthService: User document created in Firestore');
      print('🔵 AuthService: Current auth state - User: ${_auth.currentUser?.uid}');

      return userModel;
    } on FirebaseAuthException catch (e) {
      print('🔴 AuthService: FirebaseAuthException - ${e.code}: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('🔴 AuthService: Unexpected error - $e');
      rethrow;
    }
  }

  // Connexion
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('🔵 AuthService: signIn called for $email');

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('🔵 AuthService: User signed in with Firebase Auth');

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Erreur lors de la connexion');
      }

      print('🔵 AuthService: User UID: ${user.uid}');
      print('🔵 AuthService: Current auth state - User: ${_auth.currentUser?.uid}');

      // Récupérer les données utilisateur depuis Firestore
      final userData = await getUserData(user.uid);
      print('🔵 AuthService: User data retrieved from Firestore');

      return userData;
    } on FirebaseAuthException catch (e) {
      print('🔴 AuthService: FirebaseAuthException - ${e.code}: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('🔴 AuthService: Unexpected error - $e');
      rethrow;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    print('🔵 AuthService: signOut called');
    await _auth.signOut();
    print('🔵 AuthService: User signed out');
  }

  // Récupérer les données utilisateur
  Future<UserModel> getUserData(String uid) async {
    print('🔵 AuthService: Getting user data for $uid');
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      print('🔴 AuthService: User document not found in Firestore');
      throw Exception('Utilisateur introuvable');
    }

    print('🔵 AuthService: User data found in Firestore');
    return UserModel.fromMap(doc.data()!, uid);
  }

  // Stream des données utilisateur
  Stream<UserModel> getUserDataStream(String uid) {
    print('🔵 AuthService: Setting up user data stream for $uid');
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) {
      print('🔵 AuthService: User data stream emitted');
      return UserModel.fromMap(doc.data()!, uid);
    });
  }

  // Mettre à jour le profil
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    if (displayName != null) {
      await user.updateDisplayName(displayName);
      await _firestore.collection('users').doc(user.uid).update({
        'displayName': displayName,
      });
    }

    if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': photoUrl,
      });
    }
  }

  // Mettre à jour le token FCM
  Future<void> updateFcmToken(String token) async {
    final user = currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'fcmToken': token,
    });
  }

  // Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Gestion des erreurs
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'invalid-email':
        return 'Email invalide';
      case 'weak-password':
        return 'Mot de passe trop faible';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard';
      default:
        return e.message ?? 'Une erreur est survenue';
    }
  }
}