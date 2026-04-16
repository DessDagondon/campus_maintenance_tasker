import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
    if (!_isFormValid) return;

    final auth = context.read<AuthProvider>();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final success = await auth.signInWithEmail(email, password);
    if (success && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _signInWithGoogle() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithGoogle();
    if (success && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log In'), centerTitle: true),
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
                              'Welcome Back',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 20 : 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Log in to your account to continue.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 20 : 28),
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
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: 'Enter your password',
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
                            SizedBox(height: isSmallScreen ? 16 : 24),
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
                                      'Log In',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 14 : 16,
                                      ),
                                    ),
                            ),
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(color: Colors.grey.shade300),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    'or',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: Colors.grey.shade300),
                                ),
                              ],
                            ),
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            OutlinedButton(
                              onPressed: auth.loading
                                  ? null
                                  : _signInWithGoogle,
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size.fromHeight(
                                  isSmallScreen ? 48 : 52,
                                ),
                              ),
                              child: const Text('Log in with Google'),
                            ),
                            SizedBox(height: isSmallScreen ? 12 : 16),
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
