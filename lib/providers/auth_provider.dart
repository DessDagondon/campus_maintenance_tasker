import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? errorMessage;
  bool loading = false;
  String? role;

  // DEVELOPMENT MODE: Set to true to allow test admin login without Firebase setup.
  // Change this to false to require proper Firebase authentication.
  static const bool devMode = false;

  // A small admin allowlist for fallback/testing if no Firestore role is available.
  static const adminEmails = ['admin@campusmaintenance.app'];

  AuthProvider() {
    // Listen for auth state changes so we can load the Firestore role when a user signs in.
    _auth.authStateChanges().listen(_updateRoleFromFirestore);
  }

  User? get user => _auth.currentUser;

  bool get isAdmin => role == 'admin';

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Load the current user's role from Firestore.
  ///
  /// The expected Firestore structure is:
  /// users/{uid} -> { role: 'admin' | 'user' }
  ///
  /// If no document exists, we fall back to a hardcoded allowlist for early testing.
  Future<void> _updateRoleFromFirestore(User? user) async {
    if (user == null) {
      role = null;
      notifyListeners();
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        role = data?['role']?.toString().toLowerCase() ?? 'user';
      } else {
        // If the Firestore document does not exist yet, use the email allowlist.
        role = adminEmails.contains(user.email?.toLowerCase())
            ? 'admin'
            : 'user';
      }
    } catch (e) {
      // If Firestore fails, keep the fallback role behavior.
      role = adminEmails.contains(user.email?.toLowerCase()) ? 'admin' : 'user';
      errorMessage = 'Role lookup failed: $e';
    }

    notifyListeners();
  }

  Future<bool> signInWithEmail(
    String email,
    String password, {
    bool allowAdminFallback = true,
  }) async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      if (allowAdminFallback &&
          e.code == 'user-not-found' &&
          email.toLowerCase() == adminEmails.first &&
          password == 'firebaseadmin') {
        final created = await registerAdminUser();
        if (created) {
          return await signInWithEmail(
            email,
            password,
            allowAdminFallback: false,
          );
        }
      }
      errorMessage = e.message ?? 'Email sign-in failed.';
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    return signUpWithRole(email, password, 'user');
  }

  Future<bool> signUpWithRole(
    String email,
    String password,
    String role,
  ) async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create a Firestore record for the new user with the specified role.
      await _firestore.collection('users').doc(credential.user?.uid).set({
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message ?? 'Registration failed.';
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final googleProvider = GoogleAuthProvider();
      final credential = await _auth.signInWithPopup(googleProvider);

      // Ensure the Firestore user document exists after Google login.
      final uid = credential.user?.uid;
      if (uid != null) {
        final docRef = _firestore.collection('users').doc(uid);
        final doc = await docRef.get();
        if (!doc.exists) {
          await docRef.set({
            'email': credential.user?.email,
            'role': adminEmails.contains(credential.user?.email?.toLowerCase())
                ? 'admin'
                : 'user',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message ?? 'Google sign-in failed.';
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> get usersStream {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<bool> removeNonAdminUser(String uid) async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final docRef = _firestore.collection('users').doc(uid);
      final doc = await docRef.get();
      final data = doc.data();
      if (!doc.exists) {
        errorMessage = 'User record not found.';
        return false;
      }
      if (data?['role'] == 'admin') {
        errorMessage = 'Admin users cannot be removed.';
        return false;
      }
      await docRef.delete();
      return true;
    } catch (e) {
      errorMessage = 'Failed to remove user: $e';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> forceEnableUser(String uid) async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final docRef = _firestore.collection('users').doc(uid);
      final doc = await docRef.get();
      if (!doc.exists) {
        errorMessage = 'User record not found.';
        return false;
      }
      await docRef.update({
        'disabled': FieldValue.delete(),
        'deletedAt': FieldValue.delete(),
      });
      return true;
    } catch (e) {
      errorMessage = 'Failed to enable user: $e';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> disableUser(String uid) async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final docRef = _firestore.collection('users').doc(uid);
      final doc = await docRef.get();
      if (!doc.exists) {
        errorMessage = 'User record not found.';
        return false;
      }
      final data = doc.data();
      if (data?['role'] == 'admin') {
        errorMessage = 'Admin users cannot be disabled.';
        return false;
      }
      await docRef.update({'disabled': true});
      return true;
    } catch (e) {
      errorMessage = 'Failed to disable user: $e';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Streams for dashboard data
  Stream<QuerySnapshot<Map<String, dynamic>>> get facilitiesStream {
    return _firestore
        .collection('facilities')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> get assignmentsStream {
    return _firestore
        .collection('work_orders')
        .where('type', isEqualTo: 'assignment')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> get reportsStream {
    return _firestore
        .collection('work_orders')
        .where('type', isEqualTo: 'report')
        .snapshots();
  }

  // Get staff stream
  Stream<QuerySnapshot<Map<String, dynamic>>> get staffStream {
    return _firestore.collection('staff').orderBy('name').snapshots();
  }

  // For backward compatibility
  Stream<QuerySnapshot<Map<String, dynamic>>> get employeesStream {
    return staffStream;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {}
    role = null;
    notifyListeners();
  }

  /// PRODUCTION: Register the admin user with Firebase.
  ///
  /// Call this method once to create the admin account:
  /// Email: admin@campusmaintenance.app
  /// Password: firebaseadmin
  ///
  /// This creates both the Firebase Auth account and the Firestore user document with admin role.
  Future<bool> registerAdminUser() async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Create Firebase Auth account for admin
      final credential = await _auth.createUserWithEmailAndPassword(
        email: 'admin@campusmaintenance.app',
        password: 'firebaseadmin',
      );

      final uid = credential.user?.uid;
      if (uid != null) {
        // Create Firestore user document with admin role
        await _firestore.collection('users').doc(uid).set({
          'email': 'admin@campusmaintenance.app',
          'role': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
        });
        errorMessage = '✅ Admin user created successfully! You can now log in.';
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        errorMessage = '⚠️ Admin user already exists. You can log in with it.';
      } else {
        errorMessage = 'Failed to create admin user: ${e.message}';
      }
      return false;
    } catch (e) {
      errorMessage = 'Error: $e';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void setError(String? message) {
    errorMessage = message;
    notifyListeners();
  }

  /// DEVELOPMENT MODE: Force admin authentication without Firebase setup.
  ///
  /// This allows testing the admin dashboard without Firebase Console configuration.
  /// Call this on app startup for dev testing, then set devMode = false for production.
  ///
  /// In production, users must:
  ///   1. Sign up / log in with valid Firebase credentials
  ///   2. Have role: 'admin' set in Firestore users/{uid} document
  Future<void> forceAdminLogin() async {
    if (!devMode) {
      setError('Dev mode is disabled. Use regular authentication.');
      return;
    }

    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Create a virtual user for testing (bypasses Firebase Auth).
      role = 'admin';
      errorMessage = null;
      debugPrint(
        '⚠️  DEV MODE: Admin access forced. This is for development only!',
      );
    } catch (e) {
      errorMessage = 'Failed to force admin login: $e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
