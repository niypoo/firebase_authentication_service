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
  final Map<String, bool>? permission;

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
    this.permission,
  });

  Map<String, dynamic> toData();
  bool isAllow(); //has permission
  Set<String> get tokens;
  String get getDisplayName;
}
