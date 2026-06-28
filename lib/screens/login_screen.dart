import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/chat_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_app_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.isAdminLogin = false});

  final bool isAdminLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isSubmitting = true;
    });

    final authProvider = context.read<AuthProvider>();
    // Ensure auth service is initialized so the users database and default
    // admin user exist before attempting to login.
    await authProvider.initialize();
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() {
      _isSubmitting = false;
    });

    if (!mounted) return;

    if (success) {
      final user = authProvider.currentUser;

      if (user?.isAdmin == true) {
        Navigator.of(context).pushReplacementNamed('/admin-dashboard');
        return;
      }

      if (widget.isAdminLogin && user?.isAdmin != true) {
        await authProvider.logout();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Regular users must use the standard login flow.'),
          ),
        );
        return;
      }

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const ChatScreen()));
    } else {
      final error = authProvider.error ?? 'Login failed. Please try again.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Responsive padding based on screen width
    final horizontalPadding = screenWidth < 600 ? 16.0 : 20.0;

    return Scaffold(
      // Responsive AppBar with adaptive title sizing
      appBar: ResponsiveAppBar(
        title: widget.isAdminLogin ? 'Admin Login' : 'Login',
        showLogo: false,
      ),
      body: Padding(
        // Responsive horizontal padding
        padding: EdgeInsets.all(horizontalPadding),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              // Limit max width on large screens for better UX
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    widget.isAdminLogin
                        ? Icons.admin_panel_settings
                        : Icons.login,
                    // Responsive icon size
                    size: screenWidth < 600 ? 80 : 96,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.isAdminLogin
                        ? 'Sign in as administrator to manage users.'
                        : 'Sign in with your email and password.',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isAdminLogin
                        ? 'Only authorized admins should use this screen.'
                        : 'Use this screen to sign in as a regular user or administrator.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _login,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Login'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Use admin@admin.com / Admin123 if no administrator account exists.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
