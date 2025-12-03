import 'package:cloud_firestore/cloud_firestore.dart';

enum DonationType {
  oneTime,
  monthly;

  String get displayName {
    switch (this) {
      case DonationType.oneTime:
        return 'Don ponctuel';
      case DonationType.monthly:
        return 'Don mensuel';
    }
  }
}

enum PaymentMethod {
  creditCard,
  paypal,
  tmoney,
  flooz;

  String get displayName {
    switch (this) {
      case PaymentMethod.creditCard:
        return 'Carte de crédit';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.tmoney:
        return 'T-Money';
      case PaymentMethod.flooz:
        return 'Flooz';
    }
  }

  String get description {
    switch (this) {
      case PaymentMethod.creditCard:
        return 'Visa, Mastercard, etc.';
      case PaymentMethod.paypal:
        return 'Paiement sécurisé PayPal';
      case PaymentMethod.tmoney:
        return 'Mobile Money Togo';
      case PaymentMethod.flooz:
        return 'Mobile Money Moov Africa';
    }
  }
}

class DonationModel {
  final String id;
  final String userId;
  final String userName;
  final double amount;
  final DonationType type;
  final PaymentMethod paymentMethod;
  final DateTime createdAt;
  final String? message;
  final bool isAnonymous;

  DonationModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.amount,
    required this.type,
    required this.paymentMethod,
    required this.createdAt,
    this.message,
    this.isAnonymous = false,
  });

  factory DonationModel.fromMap(Map<String, dynamic> map, String id) {
    return DonationModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      type: DonationType.values.firstWhere(
            (e) => e.name == map['type'],
        orElse: () => DonationType.oneTime,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
            (e) => e.name == map['paymentMethod'],
        orElse: () => PaymentMethod.creditCard,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      message: map['message'],
      isAnonymous: map['isAnonymous'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'amount': amount,
      'type': type.name,
      'paymentMethod': paymentMethod.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'message': message,
      'isAnonymous': isAnonymous,
    };
  }
}