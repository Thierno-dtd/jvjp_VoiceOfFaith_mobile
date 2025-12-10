import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../models/user_model.dart';

// Provider du service d'authentification
final authServiceProvider = Provider<dynamic>((ref) {

  return AuthService();
});

// Provider du stream d'état d'authentification
final authStateProvider = StreamProvider<dynamic>((ref) {
  final authService = ref.watch(authServiceProvider);
  return (authService as AuthService).authStateChanges;
});

// Provider des données utilisateur actuelles
final currentUserDataProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      final authService = ref.watch(authServiceProvider);
      final realService = authService as AuthService;
      final firebaseUser = user as User;
      return realService.getUserDataStream(firebaseUser.uid);
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
  final dynamic _authService;

  SignUpNotifier(this._authService) : super(const AsyncValue.data(null));

  Future<Map<String, dynamic>> signUpWithVerification({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncValue.loading();

    try {
      print('🔵 SignUp: Starting with verification for $email');

      final result = await (_authService as AuthService).signUpWithVerification(
        email: email,
        password: password,
        displayName: displayName,
      );

      state = const AsyncValue.data(null);

      print('🔵 SignUp: Complete with token');
      return result;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}

// Provider pour la connexion
final signInProvider =
StateNotifierProvider<SignInNotifier, AsyncValue<void>>((ref) {
  return SignInNotifier(ref.watch(authServiceProvider));
});

class SignInNotifier extends StateNotifier<AsyncValue<void>> {
  final dynamic _authService;

  SignInNotifier(this._authService) : super(const AsyncValue.data(null));

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      print('🔵 SignIn: Starting for $email');

      await (_authService as AuthService).signIn(
        email: email,
        password: password,
      );

      print('🔵 SignIn: Success - User authenticated');
      // Ne pas attendre ici, Firebase Auth propagera automatiquement
    });
  }
}

// Provider pour la déconnexion
final signOutProvider = Provider<Future<void> Function()>((ref) {
  final authService = ref.watch(authServiceProvider);
  return () {
    return (authService as AuthService).signOut();
  };
});