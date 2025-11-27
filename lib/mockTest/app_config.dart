/// Configuration de l'application
///
/// Pour tester avec les données mock (sans Firebase):
/// Mettez `useMockData = true`
///
/// Pour utiliser Firebase:
/// Mettez `useMockData = false` et configurez Firebase
class AppConfig {
  /// Active ou désactive les données mock
  ///
  /// true = Utilise les données de test (mock_data.dart)
  /// false = Utilise Firebase (nécessite configuration Firebase)
  static const bool useMockData = false;

  /// Affiche des logs de debug
  static const bool debugMode = true;

  /// Configuration Firebase (à remplir quand Firebase est prêt)
  static const String firebaseProjectId = '';
  static const String firebaseApiKey = '';
  static const String firebaseAppId = '';
}