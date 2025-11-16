import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'auth_service.dart';

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final AuthService _authService = AuthService();

  Future<void> initialize() async {
    // Demander la permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Notifications autorisées');
      
      // Récupérer le token
      String? token = await _messaging.getToken();
      if (token != null) {
        print('FCM Token: $token');
        await _authService.updateFcmToken(token);
      }

      // Écouter les changements de token
      _messaging.onTokenRefresh.listen((newToken) {
        _authService.updateFcmToken(newToken);
      });

      // Initialiser les notifications locales
      await _initializeLocalNotifications();

      // Gérer les messages en foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Gérer les clics sur notifications
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Vérifier si l'app a été ouverte depuis une notification
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('Message reçu en foreground: ${message.messageId}');

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    // Afficher une notification locale
    if (notification != null && android != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'church_app_channel',
            'Church App Notifications',
            channelDescription: 'Notifications de l\'application église',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: message.data.toString(),
      );
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message ouvert: ${message.messageId}');
    
    // Navigation basée sur les données du message
    final data = message.data;
    if (data.containsKey('type')) {
      switch (data['type']) {
        case 'audio':
          // Naviguer vers la page audio
          break;
        case 'post':
          // Naviguer vers le post
          break;
        case 'event':
          // Naviguer vers l'événement
          break;
        case 'live':
          // Ouvrir le live
          break;
      }
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // Gérer le tap sur notification locale
  }

  // S'abonner à un topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    print('Abonné au topic: $topic');
  }

  // Se désabonner d'un topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    print('Désabonné du topic: $topic');
  }

  // Topics par défaut selon le rôle
  Future<void> subscribeToRoleTopics(String role) async {
    await subscribeToTopic('all_users');
    
    switch (role) {
      case 'pasteur':
        await subscribeToTopic('pasteurs');
        break;
      case 'media':
        await subscribeToTopic('media_team');
        break;
      case 'admin':
        await subscribeToTopic('admins');
        break;
    }
  }
}