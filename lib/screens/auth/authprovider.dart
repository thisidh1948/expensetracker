import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  GoogleSignInAccount? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  GoogleSignInAccount? get user => _user;
  bool get isSignedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _checkSignIn();
  }

  Future<void> _checkSignIn() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final signedIn = prefs.getBool('signedIn') ?? false;
      if (signedIn) {
        _user = await _googleSignIn.signInSilently();
        if (_user != null) {
          await _saveUserData();
        }
      }
    } catch (e) {
      _setError('Failed to check sign in status: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signIn() async {
    _setLoading(true);
    _clearError();
    try {
      _user = await _googleSignIn.signIn();
      if (_user != null) {
        await _saveUserData();
      } else {
        throw Exception('Sign in cancelled by user');
      }
    } catch (e) {
      _setError('Sign in failed: $e');
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    _clearError();
    try {
      await _googleSignIn.signOut();
      await _clearUserData();
      _user = null;
    } catch (e) {
      _setError('Sign out failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _saveUserData() async {
    if (_user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('signedIn', true);
      await prefs.setString('userName', _user!.displayName ?? '');
      await prefs.setString('userEmail', _user!.email);
      await prefs.setString('userPhotoUrl', _user!.photoUrl ?? '');
    }
  }

  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('signedIn');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('userPhotoUrl');
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('userName') ?? '',
      'email': prefs.getString('userEmail') ?? '',
      'photoUrl': prefs.getString('userPhotoUrl') ?? '',
    };
  }

  Future<bool> validateSession() async {
    if (_user == null) return false;
    try {
      final isSignedIn = await _googleSignIn.isSignedIn();
      if (!isSignedIn) {
        await signOut();
        return false;
      }
      return true;
    } catch (e) {
      _setError('Session validation failed: $e');
      return false;
    }
  }

  // Modified refreshUserData method
  Future<void> refreshUserData() async {
    if (_user != null) {
      try {
        // Sign in silently to refresh the user data
        final refreshedUser = await _googleSignIn.signInSilently();
        if (refreshedUser != null) {
          _user = refreshedUser;
          await _saveUserData();
        } else {
          throw Exception('Failed to refresh user data');
        }
      } catch (e) {
        _setError('Failed to refresh user data: $e');
      }
    }
  }

  @override
  void dispose() {
    _googleSignIn.disconnect();
    super.dispose();
  }
}
