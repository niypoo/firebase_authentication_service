abstract class BaseUser {
  final String id;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final String? provider;
  final bool isAnonymous;
  final bool primary;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? fcmToken;

  BaseUser({
    required this.id,
    this.displayName,
    this.photoUrl,
    this.email,
    this.provider,
    this.isAnonymous = false,
    this.primary = false,
    this.fcmToken,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toData();
  Set<String> get tokens;
  String get getDisplayName;
}
