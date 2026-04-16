import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'staff'; // 'admin' or 'staff'
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  Future<void> _submitForm() async {
    if (!_isFormValid) {
      return;
    }

    final auth = context.read<AuthProvider>();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    await auth.signUpWithRole(email, password, _selectedRole);
    if (mounted && auth.errorMessage == null) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account'), centerTitle: true),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isSmallScreen = screenWidth < 600;

          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isSmallScreen ? screenWidth * 0.9 : 520,
                ),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 20 : 28,
                      vertical: isSmallScreen ? 24 : 32,
                    ),
                    child: Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Create Your Account',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 20 : 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Sign up to access the campus maintenance system.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 20 : 28),
                            // Email field
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email Address',
                                hintText: 'you@example.com',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.email),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            // Password field
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: 'Enter a strong password',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    );
                                  },
                                ),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            // Role dropdown
                            DropdownButtonFormField<String>(
                              initialValue: _selectedRole,
                              decoration: const InputDecoration(
                                labelText: 'Account Type',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'staff',
                                  child: Text('Staff Member'),
                                ),
                                DropdownMenuItem(
                                  value: 'admin',
                                  child: Text('Administrator'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedRole = value ?? 'staff';
                                });
                              },
                            ),
                            SizedBox(height: isSmallScreen ? 16 : 24),
                            // Error message
                            if (auth.errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.red.shade300,
                                  ),
                                ),
                                child: Text(
                                  auth.errorMessage!,
                                  style: TextStyle(color: Colors.red.shade700),
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 12 : 16),
                            ],
                            // Submit button
                            ElevatedButton(
                              onPressed: _isFormValid && !auth.loading
                                  ? _submitForm
                                  : null,
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size.fromHeight(
                                  isSmallScreen ? 48 : 52,
                                ),
                              ),
                              child: auth.loading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Create Account',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 14 : 16,
                                      ),
                                    ),
                            ),
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            // Back to home
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Back to Home'),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
