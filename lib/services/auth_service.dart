// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream untuk auth state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register dengan Email & Password
  Future<Map<String, dynamic>> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    try {
      // Create user di Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(fullName);

      // Simpan data user ke Realtime Database
      await _db.child('users').child(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'fullName': fullName,
        'phone': phone,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });

      return {
        'success': true,
        'message': 'Registrasi berhasil!',
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Password terlalu lemah';
          break;
        case 'email-already-in-use':
          errorMessage = 'Email sudah terdaftar';
          break;
        case 'invalid-email':
          errorMessage = 'Format email tidak valid';
          break;
        default:
          errorMessage = 'Terjadi kesalahan: ${e.message}';
      }
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Login dengan Email & Password
  Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return {
        'success': true,
        'message': 'Login berhasil!',
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Email tidak terdaftar';
          break;
        case 'wrong-password':
          errorMessage = 'Email/Password salah';
          break;
        case 'invalid-credential':
          errorMessage = 'Email/Password salah';
          break;
        case 'invalid-email':
          errorMessage = 'Format email tidak valid';
          break;
        case 'user-disabled':
          errorMessage = 'Akun telah dinonaktifkan';
          break;
        default:
          errorMessage = 'Email/Password salah';
      }
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Email/Password salah',
      };
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get user data from Realtime Database
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final snapshot = await _db.child('users').child(uid).get();
    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return null;
  }

  // Update user profile
  Future<bool> updateUserProfile({
    required String uid,
    String? fullName,
    String? phone,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (fullName != null) updates['fullName'] = fullName;
      if (phone != null) updates['phone'] = phone;
      
      await _db.child('users').child(uid).update(updates);
      
      // Update display name di Firebase Auth juga
      if (fullName != null) {
        await _auth.currentUser?.updateDisplayName(fullName);
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
}
