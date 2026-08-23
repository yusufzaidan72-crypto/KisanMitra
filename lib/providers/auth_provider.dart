import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  FirebaseAuth? _auth;
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    try {
      _auth = FirebaseAuth.instance;
      _auth?.authStateChanges().listen((User? user) {
        _user = user;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('FirebaseAuth instance not initialized: $e');
    }
  }


  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    try {
      if (_auth == null) {
        _error = 'Firebase Auth not initialized.';
        return false;
      }
      await _auth!.signInWithEmailAndPassword(email: email, password: password);
      _error = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _handleAuthError(e);
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp(String email, String password) async {
    _setLoading(true);
    try {
      if (_auth == null) {
        _error = 'Firebase Auth not initialized.';
        return false;
      }
      await _auth!.createUserWithEmailAndPassword(email: email, password: password);
      _error = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _handleAuthError(e);
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _auth?.signOut();
  }

  Future<bool> sendPasswordReset(String email) async {
    try {
      if (_auth == null) return false;
      await _auth!.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      _error = 'Failed to send reset email. Check if email is correct.';
      notifyListeners();
      return false;
    }
  }


  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'The password is too weak.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}
