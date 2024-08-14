import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthStateProvider extends ChangeNotifier {
   final FirebaseAuth _auth;
  bool _isLoggedIn = false;
  bool _isSignedUp = true;
  bool _hasError = false;
  String? _errorCode;

  User? _currentUser;
  String? _uid;

  bool get signedState => _isSignedUp;
  bool get hasError => _hasError;
  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;
  String? get errorCode => _errorCode;
  String? get uid => _uid;

  AuthStateProvider({FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? FirebaseAuth.instance;

  Future<void> setAuthState(User? user) async {
    _isLoggedIn = true;
    _currentUser = user;
    _uid = _currentUser?.uid;
    notifyListeners();
  }

  void toggleSigned() {
    _isSignedUp = !_isSignedUp;
    notifyListeners();
  }

  Future<void> signUp(
      String userEmail, String userPassword, String userName) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
              email: userEmail, password: userPassword);

      await userCredential.user!.updateDisplayName(userName);
      await userCredential.user!.reload();
      _currentUser = _auth.currentUser;

      if (_currentUser != null) {
        _uid = _currentUser!.uid;
      }

      setAuthState(_currentUser);
    } on FirebaseAuthException catch (e) {
      _hasError = true;
      _errorCode = e.message;
    } finally {
      notifyListeners();
    }
  }

  Future<void> signInWithEmailAndPassword(
      String userEmail, String userPassword) async {
    try {
      _hasError = false; // Reset error state
      _errorCode = null;
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: userEmail, password: userPassword);
      _currentUser = userCredential.user;
      _uid = _currentUser?.uid;
    } on FirebaseAuthException catch (e) {
      _hasError = true;
      _errorCode = e.message;
    } finally {
      notifyListeners();
    }
  }

  Future<void> getUserDataFromFireStore() async {
    try {
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection("users").doc(_uid).get();
      if (snapshot.exists) {
        _uid = snapshot["uid"] as String?;
      }
    } catch (e) {
      return;
    }
  }

  Future<void> saveDataToFireStore() async {
    try {
      await FirebaseFirestore.instance.collection("users").doc(_uid).set({
        "name": _currentUser!.displayName,
        "email": _currentUser!.email,
        "uid": _uid,
      });
    } catch (e) {
      return;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _isLoggedIn = false;
      _uid = null;
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
    } finally {
      notifyListeners();
    }
  }
  //testing:

  
}
