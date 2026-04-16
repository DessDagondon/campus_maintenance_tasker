import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isSmallScreen = screenWidth < 600;

          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isSmallScreen ? screenWidth * 0.9 : 600,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.apartment,
                      size: isSmallScreen ? 60 : 80,
                      color: Colors.blueGrey.shade700,
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 24),
                    Text(
                      'Campus Maintenance Tasker',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 24 : 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isSmallScreen ? 8 : 12),
                    Text(
                      'Facility Management System',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    Text(
                      'Manage maintenance tasks, track work orders, and coordinate facility operations efficiently.',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isSmallScreen ? 32 : 48),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(isSmallScreen ? 48 : 52),
                      ),
                      child: Text(
                        'Log In',
                        style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SignupScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size.fromHeight(isSmallScreen ? 48 : 52),
                      ),
                      child: Text(
                        'Create Account',
                        style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
