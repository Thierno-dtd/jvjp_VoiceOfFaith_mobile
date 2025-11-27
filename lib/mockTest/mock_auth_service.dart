import '../models/user_model.dart';
import 'mock_data.dart';
import 'dart:async';


/// Service mock pour simuler l'authentification Firebase
class MockAuthService {
  UserModel? _currentUser;

  final _authStateController = StreamController<MockUser?>.broadcast();

  void dispose() {
    _authStateController.close();
  }

  Stream<MockUser?> get authStateChanges => _authStateController.stream;


  // Utilisateur actuel
  MockUser? get currentUser {
    if (_currentUser != null) {
      return MockUser(uid: _currentUser!.uid, email: _currentUser!.email);
    }
    return null;
  }

  // Inscription
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    _currentUser = UserModel(
      uid: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: displayName,
      role: UserRole.user,
      createdAt: DateTime.now(),
    );

    _authStateController.add(
        _currentUser != null
            ? MockUser(uid: _currentUser!.uid, email: _currentUser!.email)
            : null
    );


    return _currentUser!;
  }

  // Connexion
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    // Pour les tests, accepter n'importe quel email/mot de passe
    // et retourner l'utilisateur de test
    _currentUser = MockData.testUser;
    _authStateController.add(
        _currentUser != null
            ? MockUser(uid: _currentUser!.uid, email: _currentUser!.email)
            : null
    );

    return _currentUser!;
  }

  // Déconnexion
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    _authStateController.add(
        _currentUser != null
            ? MockUser(uid: _currentUser!.uid, email: _currentUser!.email)
            : null
    );

  }

  // Récupérer les données utilisateur
  Future<UserModel> getUserData(String uid) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _currentUser ?? MockData.testUser;
  }

  // Stream des données utilisateur
  Stream<UserModel> getUserDataStream(String uid) async* {
    await Future.delayed(const Duration(milliseconds: 300));
    yield _currentUser ?? MockData.testUser;
  }

  // Mettre à jour le profil
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        displayName: displayName,
        photoUrl: photoUrl,
      );
      _authStateController.add(
          _currentUser != null
              ? MockUser(uid: _currentUser!.uid, email: _currentUser!.email)
              : null
      );

    }
  }

  // Mettre à jour le token FCM
  Future<void> updateFcmToken(String token) async {
    await Future.delayed(const Duration(milliseconds: 200));
    print('Mock: Updated FCM token');
  }

  // Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    print('Mock: Password reset email sent to $email');
  }
}

/// Classe mock pour simuler Firebase User
class MockUser {
  final String uid;
  final String? email;

  MockUser({required this.uid, this.email});

}