import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app.dart';
import 'core/services/fcm_service.dart';
import 'mockTest//app_config.dart';

// Handler pour messages en arrière-plan
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!AppConfig.useMockData) {
    await Firebase.initializeApp();
    print('Handling background message: ${message.messageId}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Firebase seulement si on n'utilise pas les données mock
  if (!AppConfig.useMockData) {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    final fcmService = FcmService();
    await fcmService.initialize();
  } else {
    print('🧪 Mode Mock activé - Firebase désactivé');
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}