import 'package:expense_tracker_mobile_app/providers/auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthProvider Unit Tests', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    tearDown(() {
      authProvider.dispose();
    });

    test('initial state should be unauthenticated or guest', () {
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.errorMessage, isNull);
    });

    test('signInWithEmailAndPassword updates user state in fallback mode', () async {
      final success = await authProvider.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(success, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.userEmail, equals('test@example.com'));
      expect(authProvider.currentUserId, isNotNull);
    });

    test('signInWithGoogle updates user state', () async {
      final success = await authProvider.signInWithGoogle();

      expect(success, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.userDisplayName, equals('Google User'));
    });

    test('signInWithFacebook updates user state', () async {
      final success = await authProvider.signInWithFacebook();

      expect(success, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.userDisplayName, equals('Facebook User'));
    });

    test('signInAnonymously sets guest user state', () async {
      final success = await authProvider.signInAnonymously();

      expect(success, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.isGuest, isTrue);
      expect(authProvider.userDisplayName, equals('Guest User'));
    });

    test('signOut clears user state', () async {
      await authProvider.signIn(
        email: 'test@example.com',
        password: 'password123',
      );
      expect(authProvider.isAuthenticated, isTrue);

      await authProvider.signOut();
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.user, isNull);
    });
  });
}
