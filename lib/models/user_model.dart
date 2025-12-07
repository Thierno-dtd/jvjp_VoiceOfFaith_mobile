import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  user,
  pasteur,
  media,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.user:
        return 'Utilisateur';
      case UserRole.pasteur:
        return 'Pasteur';
      case UserRole.media:
        return 'Équipe Média';
      case UserRole.admin:
        return 'Administrateur';
    }
  }
}

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final bool emailVerified;
  final UserRole role;
  final String? photoUrl;
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime? emailVerifiedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.emailVerified,
    this.photoUrl,
    this.fcmToken,
    required this.createdAt,
    this.emailVerifiedAt,
  });

  // From Firestore
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.user,
      ),
      emailVerified: map['emailVerified'] ?? false,
      photoUrl: map['photoUrl'],
      fcmToken: map['fcmToken'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      emailVerifiedAt: (map['emailVerifiedAt'] as Timestamp?)?.toDate(),
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role.name,
      'emailVerified': emailVerified,
      'photoUrl': photoUrl,
      'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
      'emailVerifiedAt': emailVerifiedAt != null
          ? Timestamp.fromDate(emailVerifiedAt!)
          : null,
    };
  }

  UserModel copyWith({
    String? email,
    String? displayName,
    UserRole? role,
    String? photoUrl,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      emailVerified: emailVerified,
      photoUrl: photoUrl ?? this.photoUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
      emailVerifiedAt: emailVerifiedAt,
    );
  }

  bool get canModerate =>
      role == UserRole.pasteur ||
      role == UserRole.media ||
      role == UserRole.admin;

  bool get isAdmin => role == UserRole.admin;
}