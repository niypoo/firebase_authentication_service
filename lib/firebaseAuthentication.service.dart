import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fbAuth;
import 'package:firebase_authentication_service/abstracts/firebaseAuthenticationServiceRoutingHandler.abstract.dart';
import 'package:firebase_authentication_service/abstracts/firebaseAuthenticationServiceUser.abstract.dart';
import 'package:firebase_authentication_service/enums/authenticationStatus.enum.dart';
import 'package:firebase_authentication_service/models/baseUser.model.dart';
import 'package:flutter/scheduler.dart';
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
  FirebaseAuthenticationServiceRoutingHandler authenticatedRouting;
  FirebaseAuthenticationServiceUser userFromExternalDatabase;

  FirebaseAuthenticationService({
    required this.authenticatedRouting,
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

          // // Abstract Event Handler Trigger
          // await userFromExternalDatabase
          //     .onAuthenticatedBeforeStatusChanges(user.value!);

          // then make him as authentication
          isAuthenticated.value = true;

          // Abstract Event Handler Trigger
          // await userFromExternalDatabase.onFullyAuthenticated(user.value!);
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
  Future<BaseUser> userCompleter() async {
    final Completer<BaseUser> completer = Completer();
    user.listen((_) {
      if (_ != null) {
        completer.complete(_);
      }
    });

    return completer.future;
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

  /// routing for navigate user to correct route by authentication state
  Future<void>? routing() async {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // in case user has un-authenticated
      if (isAuthenticated.value == false) {
        print('routing to authentication page +++++++');
        Get.offAllNamed(authenticatedRouting.authenticationRouteName);
      }
      // in case user has un-authenticated
      if (isAuthenticated.value == true) {
        print('routing to Home page +++++++');
        // final case if user has authenticated
        Get.offAllNamed(authenticatedRouting.homeRouteName);
      }
    });
  }
}
