import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/donation_model.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Provider du service Firestore pour les donations
final donationFirestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Provider pour soumettre une donation
final submitDonationProvider = StateNotifierProvider<SubmitDonationNotifier, AsyncValue<void>>((ref) {
  final firestoreService = ref.watch(donationFirestoreServiceProvider);
  final authService = ref.watch(authServiceProvider);
  return SubmitDonationNotifier(firestoreService, authService);
});

class SubmitDonationNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _firestoreService;
  final dynamic _authService;

  SubmitDonationNotifier(this._firestoreService, this._authService)
      : super(const AsyncValue.data(null));

  Future<void> submitDonation({
    required double amount,
    required DonationType type,
    required PaymentMethod paymentMethod,
    String? message,
    bool isAnonymous = false,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // Récupérer l'utilisateur actuel
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('Vous devez être connecté pour faire un don');
      }

      // Créer le modèle de donation
      final donation = DonationModel(
        id: '', // Sera généré par Firestore
        userId: currentUser.uid,
        userName: currentUser.displayName ?? 'Utilisateur',
        amount: amount,
        type: type,
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
        message: message,
        isAnonymous: isAnonymous,
      );

      // Simuler le traitement du paiement selon la méthode
      await _processPayment(paymentMethod, amount);

      // Enregistrer la donation dans Firestore
      await _firestoreService.createDonation(donation);

      print('✅ Donation enregistrée avec succès');
    });
  }

  Future<void> _processPayment(PaymentMethod method, double amount) async {
    // Simuler le délai de traitement selon la méthode
    switch (method) {
      case PaymentMethod.creditCard:
      // Ici, intégrer Stripe ou autre service de paiement par carte
        await Future.delayed(const Duration(seconds: 2));
        print('💳 Paiement par carte de $amount€ en cours...');
        break;

      case PaymentMethod.paypal:
      // Ici, intégrer PayPal SDK
        await Future.delayed(const Duration(seconds: 2));
        print('💰 Paiement PayPal de $amount€ en cours...');
        break;

      case PaymentMethod.tmoney:
      // Ici, intégrer l'API T-Money
        await Future.delayed(const Duration(seconds: 3));
        print('📱 Paiement T-Money de $amount€ en cours...');
        // Format: Envoyer une requête à l'API T-Money
        // URL: https://api.tmoney.tg/...
        break;

      case PaymentMethod.flooz:
      // Ici, intégrer l'API Flooz (Moov Africa)
        await Future.delayed(const Duration(seconds: 3));
        print('📱 Paiement Flooz de $amount€ en cours...');
        // Format: Envoyer une requête à l'API Moov Money
        // URL: https://api.moov-africa.tg/...
        break;
    }
  }
}

// Provider pour récupérer l'historique des donations d'un utilisateur
final userDonationsProvider = StreamProvider.family<List<DonationModel>, String>((ref, userId) {
  final firestoreService = ref.watch(donationFirestoreServiceProvider);
  return firestoreService.getUserDonations(userId);
});

// Provider pour les statistiques de donations
final donationStatsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final firestoreService = ref.watch(donationFirestoreServiceProvider);
  final donations = await firestoreService.getUserDonations(userId).first;

  // Calculer les statistiques
  double totalAmount = 0;
  int totalDonations = donations.length;
  int monthlyDonations = 0;

  for (var donation in donations) {
    totalAmount += donation.amount;
    if (donation.type == DonationType.monthly) {
      monthlyDonations++;
    }
  }

  return {
    'totalAmount': totalAmount,
    'totalDonations': totalDonations,
    'monthlyDonations': monthlyDonations,
    'averageAmount': totalDonations > 0 ? totalAmount / totalDonations : 0,
  };
});