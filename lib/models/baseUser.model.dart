abstract class BaseUser {
  final String id;
  final String uid;
  final String? displayName;
  final String? email;
  final String? phone;
  final String? photoUrl;
  final String? provider;
  final bool isAnonymous;
  final dynamic type;
  final bool primary;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? fcmToken;

  BaseUser({
    required this.id,
    required this.uid,
    this.displayName,
    this.phone,
    this.photoUrl,
    this.email,
    this.provider,
    this.isAnonymous = false,
    this.primary = false,
    this.type,
    this.fcmToken,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toData();
  Set<String> get getFCMTokens;
  String get getDisplayName;
}
