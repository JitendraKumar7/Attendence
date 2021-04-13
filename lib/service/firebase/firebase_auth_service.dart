import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FirebaseAuthService {
  static FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  static Stream<User> firebaseListner = _firebaseAuth.authStateChanges();

  static void firebaseSignIn(String email, String password) async {
    try {
      final _authResult = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      print(_authResult.user.email);
      Fluttertoast.showToast(
          msg: "SuccessFully Login",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );

      print("aaaaaaaaaaaaaa");
      print(_authResult.user);
    } catch (e) {
      print(e);
      Fluttertoast.showToast(
          msg: "${e.toString()}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );

      print("aaaaaaaaaaaaaa");
    }
  }

  static void firebaseRegistration(String email, String password) async {
    try {
      final _authResult = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      print(_authResult);
    } catch (e) {
      print(e);
    }
  }

  static void firebaseForgetPassword(String email) async {
    try {
      final _authResult = await _firebaseAuth.sendPasswordResetEmail(
          email: email,);


    } catch (e) {
      print(e);
    }
  }

  static Future<User> firebaseUserDetail() async =>
      await _firebaseAuth.currentUser;

  static void firebaseLogout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print(e);
    }
  }
}
