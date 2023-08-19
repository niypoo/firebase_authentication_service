import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_authentication_service/enums/authenticationProvider.enum.dart';

class Credential {
  final AuthCredential? providerCredential;
  final AuthenticationProvider provider;
  final UserCredential? firebaseCredential;
  final String? displayName;

  Credential({
    required this.provider,
    this.firebaseCredential,
    this.providerCredential,
    this.displayName,
  });
}
