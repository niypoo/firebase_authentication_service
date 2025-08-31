import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fbAuth;
// import 'package:firebase_authentication_service/abstracts/firebaseAuthenticationServiceRoutingHandler.abstract.dart';
import 'package:firebase_authentication_service/abstracts/firebaseAuthenticationServiceUser.abstract.dart';
import 'package:firebase_authentication_service/enums/authenticationStatus.enum.dart';
import 'package:firebase_authentication_service/models/baseUser.model.dart';
import 'package:get/get.dart';

class FirebaseAuthenticationService extends GetxService {
  //define this controller in static to
  static FirebaseAuthenticationService get to => Get.find();

  //user authentication state properties
  // this value has 3 options
  // [null]  not initialed
  // [false]  is not authenticated
  // [true]  is authenticated
  Rx<bool?> isAuthenticated = Rx<bool?>(null);

  //current authenticated user data
  Rx<fbAuth.User?> firebaseUser = Rx<fbAuth.User?>(null);

  // user from external database
  Rx<BaseUser?> user = Rx<BaseUser?>(null);

  // Authentication Status
  Rx<AuthenticationStatus> status = Rx(AuthenticationStatus.Initializing);

  // Aggregation Relation
  // FirebaseAuthenticationServiceRoutingHandler authenticatedRouting;
  FirebaseAuthenticationServiceUser userFromExternalDatabase;

  FirebaseAuthenticationService({
    // required this.authenticatedRouting,
    required this.userFromExternalDatabase,
  });

  Future<FirebaseAuthenticationService> init() async {
    // to avoid freezing in Initializing state
    await fbAuth.FirebaseAuth.instance.authStateChanges().first;

    //initialization User Stream
    fbAuth.FirebaseAuth.instance.authStateChanges().listen(
      (fbAuth.User? payload) async {
        if (payload != null) {
          // change Authentication status
          status.value = AuthenticationStatus.Authenticating;

          // assign user firebase object
          firebaseUser.value = payload;

          // change Authentication status
          status.value = AuthenticationStatus.Fetching;

          // get user from external database
          await userDataUpdate();

          // Abstract Event Handler Trigger
          await userFromExternalDatabase
              .onAuthenticatedBeforeStatusChanges(user.value!);

          // then make him as authentication
          isAuthenticated.value = true;

          // Abstract Event Handler Trigger
          await userFromExternalDatabase.onFullyAuthenticated(user.value!);
        } else {
          // to trigger  handle Auth State Route
          firebaseUser.value = null;
          user.value = null;
          isAuthenticated.value = false;
        }
      },
    );
    return this;
  }

  // completer to wait stream return user
  Future<void> authenticationCompleter() async {
    Completer<void> _complete = Completer();
    isAuthenticated.listen((event) {
      print('<<<<<isAuthenticated>>>> $event');
      if (event != null) _complete.complete();
    }).onDone(() {
      _complete.complete();
    });
    return _complete.future;
  }

  // get user from external database
  Future<void> userDataUpdate() async {
    // skip
    if (firebaseUser.value == null) return;
    // update user from server
    await userFromExternalDatabase.updateUserData(firebaseUser.value!);

    // sync user data
    await syncUserObject();
  }

  // get user from external database
  Future<void> syncUserObject() async {
    // skip
    if (firebaseUser.value == null) return;

    // update user from server
    user.value =
        await userFromExternalDatabase.syncUserObject(firebaseUser.value!);
  }

  /// Sign Out ///
  Future<void> signOut() async {
    await userFromExternalDatabase.onSignOut(user.value!);
    await fbAuth.FirebaseAuth.instance.signOut();
  }

  // Destroy user data then make him unAuthentication
  Future<void> destroy() async {
    // destroy user from external database first
    await userFromExternalDatabase.onDestroy(user.value!);
    // then delete user data from firebase auth
    await firebaseUser.value!.delete();
  }

  // deprecated
  // /// routing for navigate user to correct route by authentication state
  // Future<void>? routing() async {
  //   // In case initialization and still firebase auth try to figure-out
  //   // user auth status
  //   if (isAuthenticated.value == null) {
  //     return Get.offAllNamed(authenticatedRouting.splashRouteName);
  //   }

  //   // in case firebase has done and figure-out
  //   if (isAuthenticated.value != null) {
  //     // delay to avoid issue that happened coze context-less
  //     await Future.delayed(const Duration(milliseconds: 300));

  //     // in case user has un-authenticated
  //     if (isAuthenticated.isFalse!) {
  //       return Get.offAllNamed(authenticatedRouting.authenticationRouteName);
  //     }

  //     // final case if user has authenticated
  //     Get.offAllNamed(authenticatedRouting.homeRouteName);

  //     // delay
  //     await Future.delayed(const Duration(milliseconds: 300));
  //     // trigger only after authenticated
  //     await userFromExternalDatabase.afterHomeRouteRedirect(user.value!);
  //   }
  // }
}
