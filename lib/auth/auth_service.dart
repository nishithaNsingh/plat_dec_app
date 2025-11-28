import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Create user with email and password
  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      await cred.user?.sendEmailVerification();
      log("Verification email sent to $email");

      return cred.user;
    } on FirebaseAuthException catch (e) {
      log("FirebaseAuth Error: ${e.code} - ${e.message}");

      // Handle specific error codes
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('This email is already registered');
        case 'weak-password':
          throw Exception('Password is too weak');
        case 'invalid-email':
          throw Exception('Invalid email address');
        default:
          throw Exception('Registration failed: ${e.message}');
      }
    } catch (e) {
      log("Unexpected error during signup: $e");
      throw Exception('An unexpected error occurred');
    }
  }

  // Login user with email and password
  Future<User?> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      log("User logged in: ${cred.user?.email}");
      return cred.user;
    } on FirebaseAuthException catch (e) {
      log("FirebaseAuth Error: ${e.code} - ${e.message}");

      // Handle specific error codes
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No user found with this email');
        case 'wrong-password':
          throw Exception('Incorrect password');
        case 'invalid-email':
          throw Exception('Invalid email address');
        case 'user-disabled':
          throw Exception('This account has been disabled');
        case 'invalid-credential':
          throw Exception('Invalid email or password');
        default:
          throw Exception('Login failed: ${e.message}');
      }
    } catch (e) {
      log("Unexpected error during login: $e");
      throw Exception('An unexpected error occurred');
    }
  }

  // Sign out
  Future<void> signout() async {
    try {
      await _auth.signOut();
      log("User signed out successfully");
    } catch (e) {
      log("Error during signout: $e");
      throw Exception('Failed to sign out');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      log("Password reset email sent to $email");
    } on FirebaseAuthException catch (e) {
      log("FirebaseAuth Error: ${e.code} - ${e.message}");

      switch (e.code) {
        case 'user-not-found':
          throw Exception('No user found with this email');
        case 'invalid-email':
          throw Exception('Invalid email address');
        default:
          throw Exception('Failed to send reset email: ${e.message}');
      }
    } catch (e) {
      log("Unexpected error during password reset: $e");
      throw Exception('An unexpected error occurred');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({String? displayName, String? photoURL}) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
        await user.reload();
        log("User profile updated");
      }
    } catch (e) {
      log("Error updating profile: $e");
      throw Exception('Failed to update profile');
    }
  }

  // Check if email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      log("Verification email resent");
    } catch (e) {
      log("Error resending verification email: $e");
      throw Exception('Failed to resend verification email');
    }
  }
}