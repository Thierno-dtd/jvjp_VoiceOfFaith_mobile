import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../models/user_model.dart';

// Provider du service d'authentification
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Provider du stream d'état d'authentification Firebase
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Provider des données utilisateur actuelles
final currentUserDataProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      final authService = ref.watch(authServiceProvider);
      return authService.getUserDataStream(user.uid);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// Provider pour l'inscription
final signUpProvider =
    StateNotifierProvider<SignUpNotifier, AsyncValue<void>>((ref) {
  return SignUpNotifier(ref.watch(authServiceProvider));
});

class SignUpNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;

  SignUpNotifier(this._authService) : super(const AsyncValue.data(null));

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
    });
  }
}

// Provider pour la connexion
final signInProvider =
    StateNotifierProvider<SignInNotifier, AsyncValue<void>>((ref) {
  return SignInNotifier(ref.watch(authServiceProvider));
});

class SignInNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;

  SignInNotifier(this._authService) : super(const AsyncValue.data(null));

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authService.signIn(
        email: email,
        password: password,
      );
    });
  }
}

// Provider pour la déconnexion
final signOutProvider = Provider<Future<void> Function()>((ref) {
  final authService = ref.watch(authServiceProvider);
  return () => authService.signOut();
});