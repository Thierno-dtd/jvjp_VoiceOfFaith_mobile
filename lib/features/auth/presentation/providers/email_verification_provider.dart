import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/services/auth_service.dart';

final authServiceProvider = Provider<dynamic>((ref) {
  return AuthService();
});

final emailVerificationProvider = StateNotifierProvider<EmailVerificationNotifier, AsyncValue<void>>((ref) {
  return EmailVerificationNotifier(ref.watch(authServiceProvider));
});

class EmailVerificationNotifier extends StateNotifier<AsyncValue<void>> {
  final dynamic _authService;
  final Dio _dio = Dio();

  static const String _baseUrl = 'http://localhost:3000';

  EmailVerificationNotifier(this._authService) : super(const AsyncValue.data(null));

  /// Envoyer l'email de vérification
  Future<void> sendVerificationEmail(String verificationToken) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      try {
        print('📧 Envoi de l\'email de vérification avec token: $verificationToken');

        final response = await _dio.get(
          '$_baseUrl/api/auth/send-verification-email',
          queryParameters: {'token': verificationToken},
        );

        if (response.statusCode != 200) {
          throw Exception('Erreur lors de l\'envoi de l\'email');
        }

        print('✅ Email de vérification envoyé avec succès');
      } catch (e) {
        print('❌ Erreur envoi email: $e');
        throw Exception('Impossible d\'envoyer l\'email de vérification');
      }
    });
  }

  /// Renvoyer l'email de vérification
  Future<void> resendVerificationEmail(String verificationToken) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      try {
        print('🔄 Renvoi de l\'email de vérification');

        final response = await _dio.get(
          '$_baseUrl/api/auth/send-verification-email',
          queryParameters: {'token': verificationToken},
        );

        if (response.statusCode != 200) {
          throw Exception('Erreur lors du renvoi de l\'email');
        }

        print('✅ Email de vérification renvoyé avec succès');
      } catch (e) {
        print('❌ Erreur renvoi email: $e');
        throw Exception('Impossible de renvoyer l\'email');
      }
    });
  }

  /// Vérifier le statut de vérification de l'email
  Future<bool> checkEmailVerification() async {
    try {
      final authService = _authService as AuthService;
      final currentUser = authService.currentUser;

      if (currentUser == null) {
        print('❌ Aucun utilisateur connecté');
        return false;
      }

      print('🔍 Vérification du statut email pour: ${currentUser.uid}');

      // Recharger les données utilisateur depuis Firestore
      final userData = await authService.getUserData(currentUser.uid);

      print('📊 EmailVerified: ${userData.emailVerified}');

      return userData.emailVerified;
    } catch (e) {
      print('❌ Erreur vérification: $e');
      return false;
    }
  }
}