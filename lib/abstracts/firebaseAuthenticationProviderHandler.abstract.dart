import 'package:firebase_authentication_service/models/credential.model.dart';

abstract class FirebaseAuthenticationProviderHandler {
  Future<Credential> credential();
  Future<Credential> signIn();
  Future<void> signOut();
}
