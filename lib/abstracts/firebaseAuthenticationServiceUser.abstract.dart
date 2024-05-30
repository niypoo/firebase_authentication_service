import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_authentication_service/models/baseUser.model.dart';

abstract class FirebaseAuthenticationServiceUser {
  // [GET/SET] user from external database
  // Set in case user register as first time
  // Get in case user has already registered
  Future<void> updateUserData(User firebaseUserId);
  // Credential credential

  // refresh user object data from external backend
  Future<BaseUser> syncUserObject(User firebaseUserId);

  // function that trigger only after authenticated and home route REDIRECTED
  // usually used for trigger som functions that sure user is authenticated
  // such as local notification init or disclaimers
  Future<void> afterHomeRouteRedirect(BaseUser user);

  // function that trigger after listen function trigger
  // and user object created
  Future<void> onAuthenticatedBeforeStatusChanges(BaseUser user);

  Future<void> onFullyAuthenticated(BaseUser user);

  // function that trigger only in logged-out
  Future<void> onSignOut(BaseUser user);

  // destroy user from external database
  Future<void> onDestroy(BaseUser user);
}
