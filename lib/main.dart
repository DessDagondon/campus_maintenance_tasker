// Desiree S. Dagondon

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'config/firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';

// =============================================================================
// FALLBACK ADMIN LOGIN CREDENTIALS (for development/testing only)
// =============================================================================
// Email: new@new.app
// Password: firebaseadmin

// admin@campusmaintenance.app
// example@campusmaintenance.app

// new@new.app

// staffer@example.com
// 123456

// =============================================================================

//package com.arisenlab.campusmaintenancetasker
//SHA1 Certificate: 27:2E:93:95:DF:DA:49:69:86:E7:BD:94:51:96:B2:9F:AD:0D:1B:52
//
// TEST ADMIN CREDENTIALS (for development/testing):
// Email: admin@campusmaintenance.app
// Password: firebaseadmin
//
// NOTE: For production, create admin users in Firebase and set role: 'admin' in Firestore collection 'users'.
// Users can log in with any valid email/password or Google account.
// After login, the Firestore role determines admin vs user access:
//   - role: 'admin'  -> full admin dashboard, user management, work order creation
//   - role: 'user'   -> limited dashboard, view-only analytics
//
// The role is automatically fetched from Firestore users/{uid} document on login.
// If no document exists, the system checks a fallback hardcoded admin allowlist.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully.');
  } catch (error, stack) {
    debugPrint('Firebase initialization failed: $error');
    debugPrint('$stack');
    return;
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Campus Maintenance Tasker',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          scaffoldBackgroundColor: Colors.grey.shade50,
          cardTheme: const CardThemeData(elevation: 3),
        ),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return StreamBuilder<User?>(
      stream: authProvider.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is logged in, show dashboard
        if (snapshot.hasData) {
          return const DashboardScreen();
        }

        // Otherwise show home screen
        return const HomeScreen();
      },
    );
  }
}
