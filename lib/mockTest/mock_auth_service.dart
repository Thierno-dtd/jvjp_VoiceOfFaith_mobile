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

  MockAuthService() {
    // simuler un utilisateur connecté
    _authStateController.add(MockUser(uid: "12345", email: "mock@test.com"));
  }

  Stream<UserModel?> getUserDataStream(String uid) {
    return Stream.value(
      UserModel(
        uid: "12345",
        email: "mock@test.com",
        displayName: "Mock User",
        role: UserRole.user,
        createdAt: DateTime.now(),
      ),
    );
  }

  // Inscription
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    print('🔵 Mock SignUp: Starting for $email');
    await Future.delayed(const Duration(seconds: 1));

    _currentUser = UserModel(
      uid: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: displayName,
      role: UserRole.user,
      createdAt: DateTime.now(),
    );

    print('🔵 Mock SignUp: User created - ${_currentUser!.uid}');

    // Émettre le nouvel utilisateur dans le stream
    _authStateController.add(
        MockUser(uid: _currentUser!.uid, email: _currentUser!.email)
    );

    print('🔵 Mock SignUp: Auth state updated');
    return _currentUser!;
  }

  // Connexion
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    print('🔵 Mock SignIn: Starting for $email');
    await Future.delayed(const Duration(seconds: 1));

    // Pour les tests, accepter n'importe quel email/mot de passe
    // et retourner l'utilisateur de test
    _currentUser = MockData.testUser;

    print('🔵 Mock SignIn: User authenticated - ${_currentUser!.uid}');

    // Émettre l'utilisateur dans le stream
    _authStateController.add(
        MockUser(uid: _currentUser!.uid, email: _currentUser!.email)
    );

    print('🔵 Mock SignIn: Auth state updated');
    return _currentUser!;
  }

  // Déconnexion
  Future<void> signOut() async {
    print('🔵 Mock SignOut: Starting');
    await Future.delayed(const Duration(milliseconds: 500));

    _currentUser = null;

    // Émettre null dans le stream
    _authStateController.add(null);

    print('🔵 Mock SignOut: Auth state cleared');
  }

  // Récupérer les données utilisateur
  Future<UserModel> getUserData(String uid) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _currentUser ?? MockData.testUser;
  }

  // Stream des données utilisateur
  /*Stream<UserModel> getUserDataStream(String uid) async* {
    await Future.delayed(const Duration(milliseconds: 300));
    yield _currentUser ?? MockData.testUser;
  }*/

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
          MockUser(uid: _currentUser!.uid, email: _currentUser!.email)
      );
    }
  }

  // Mettre à jour le token FCM
  Future<void> updateFcmToken(String token) async {
    await Future.delayed(const Duration(milliseconds: 200));
    print('🔵 Mock: Updated FCM token');
  }

  // Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    print('🔵 Mock: Password reset email sent to $email');
  }
}

/// Classe mock pour simuler Firebase User
class MockUser {
  final String uid;
  final String? email;

  MockUser({required this.uid, this.email});
}