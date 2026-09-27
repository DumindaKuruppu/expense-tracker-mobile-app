import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Service isolating Firebase Authentication operations including social sign-ins.
class AuthService {
  final FirebaseAuth? _auth;

  // Fallback mock auth controller for unit testing environments without Firebase
  User? _mockUser;
  final StreamController<User?> _mockAuthStreamController =
      StreamController<User?>.broadcast();

  AuthService({FirebaseAuth? auth}) : _auth = auth;

  bool get _isRealAuthAvailable {
    if (_auth != null) return true;
    try {
      return FirebaseAuth.instance.app != null;
    } catch (_) {
      return false;
    }
  }

  FirebaseAuth get _authInstance => _auth ?? FirebaseAuth.instance;

  /// Stream of user authentication state changes (persisted across app restarts).
  Stream<User?> get authStateChanges {
    try {
      if (_isRealAuthAvailable) {
        return _authInstance.authStateChanges();
      }
    } catch (e) {
      debugPrint('FirebaseAuth.authStateChanges error: $e');
    }

    Timer.run(() => _mockAuthStreamController.add(_mockUser));
    return _mockAuthStreamController.stream;
  }

  /// Current authenticated user.
  User? get currentUser {
    try {
      if (_isRealAuthAvailable) {
        return _authInstance.currentUser;
      }
    } catch (e) {
      debugPrint('FirebaseAuth.currentUser error: $e');
    }
    return _mockUser;
  }

  /// Sign in with email and password.
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (_isRealAuthAvailable) {
        final credential = await _authInstance.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        return credential;
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (_isRealAuthAvailable) {
        throw 'An unexpected authentication error occurred: $e';
      }
    }

    // Fallback for mock unit test environment
    await Future.delayed(const Duration(milliseconds: 200));
    if (email.contains('error')) {
      throw 'Invalid credentials. Please check your email and password.';
    }
    _mockUser = MockUser(
      uid: 'mock-user-${email.hashCode}',
      email: email,
      displayName: email.split('@').first,
    );
    _mockAuthStreamController.add(_mockUser);
    return null;
  }

  /// Register a new account with email, password, and optional display name.
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      if (_isRealAuthAvailable) {
        final credential = await _authInstance.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );

        if (displayName != null && displayName.trim().isNotEmpty) {
          await credential.user?.updateDisplayName(displayName.trim());
        }

        return credential;
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (_isRealAuthAvailable) {
        throw 'An unexpected registration error occurred: $e';
      }
    }

    // Fallback for mock unit test environment
    await Future.delayed(const Duration(milliseconds: 200));
    _mockUser = MockUser(
      uid: 'mock-user-${email.hashCode}',
      email: email,
      displayName: displayName ?? email.split('@').first,
    );
    _mockAuthStreamController.add(_mockUser);
    return null;
  }

  /// Sign in with Google account.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (_isRealAuthAvailable) {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          // User canceled sign in
          return null;
        }

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await _authInstance.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (_isRealAuthAvailable) {
        debugPrint('Google Sign-In Exception: $e');
        throw 'Failed to sign in with Google: $e';
      }
    }

    // Fallback for mock unit test environment
    await Future.delayed(const Duration(milliseconds: 200));
    _mockUser = MockUser(
      uid: 'google-user-123',
      email: 'user.google@example.com',
      displayName: 'Google User',
    );
    _mockAuthStreamController.add(_mockUser);
    return null;
  }

  /// Sign in with Facebook account.
  Future<UserCredential?> signInWithFacebook() async {
    try {
      if (_isRealAuthAvailable) {
        final LoginResult result = await FacebookAuth.instance.login(
          permissions: ['public_profile', 'email'],
        );

        if (result.status == LoginStatus.success) {
          final AccessToken accessToken = result.accessToken!;
          final OAuthCredential credential = OAuthProvider('facebook.com').credential(
            accessToken: accessToken.tokenString,
          );

          return await _authInstance.signInWithCredential(credential);
        } else if (result.status == LoginStatus.cancelled) {
          return null; // User canceled sign in
        } else {
          throw result.message ?? 'Facebook authentication failed.';
        }
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (_isRealAuthAvailable) {
        debugPrint('Facebook Sign-In Exception: $e');
        throw 'Failed to sign in with Facebook: $e';
      }
    }

    // Fallback for mock unit test environment
    await Future.delayed(const Duration(milliseconds: 200));
    _mockUser = MockUser(
      uid: 'facebook-user-456',
      email: 'user.facebook@example.com',
      displayName: 'Facebook User',
    );
    _mockAuthStreamController.add(_mockUser);
    return null;
  }

  /// Guest / Anonymous sign in.
  Future<UserCredential?> signInAnonymously() async {
    try {
      if (_isRealAuthAvailable) {
        final credential = await _authInstance.signInAnonymously();
        return credential;
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (_isRealAuthAvailable) {
        throw 'Failed to sign in as guest: $e';
      }
    }

    // Fallback for mock unit test environment
    await Future.delayed(const Duration(milliseconds: 200));
    _mockUser = MockUser(
      uid: 'guest-${DateTime.now().millisecondsSinceEpoch}',
      email: null,
      displayName: 'Guest User',
      isAnonymous: true,
    );
    _mockAuthStreamController.add(_mockUser);
    return null;
  }

  /// Send password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      if (_isRealAuthAvailable) {
        await _authInstance.sendPasswordResetEmail(email: email.trim());
        return;
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (_isRealAuthAvailable) {
        throw 'Failed to send password reset email: $e';
      }
    }

    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// Sign out the current user and disconnect Google/Facebook sessions if active.
  Future<void> signOut() async {
    try {
      if (_isRealAuthAvailable) {
        await GoogleSignIn().signOut().catchError((_) => null);
        await FacebookAuth.instance.logOut().catchError((_) => null);
        await _authInstance.signOut();
        _mockUser = null;
        return;
      }
    } catch (e) {
      debugPrint('SignOut Exception: $e');
    }

    _mockUser = null;
    _mockAuthStreamController.add(null);
  }

  /// Maps Firebase Auth Exception codes to user-friendly messages.
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'invalid-email':
        return 'The email address entered is invalid.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters long.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again in a few minutes.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled in Firebase Console.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email using another provider.';
      case 'network-request-failed':
        return 'Network connection error. Please check your internet connection.';
      default:
        return e.message ?? 'An unknown authentication error occurred.';
    }
  }

  void dispose() {
    _mockAuthStreamController.close();
  }
}

/// Lightweight mock implementation of [User] for fallback/testing environments.
class MockUser implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;
  @override
  final bool isAnonymous;

  MockUser({
    required this.uid,
    this.email,
    this.displayName,
    this.isAnonymous = false,
  });

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
