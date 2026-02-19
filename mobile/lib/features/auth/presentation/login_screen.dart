import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'login_view_model.dart';

/// Login form screen.
class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.viewModel, super.key});

  final LoginViewModel viewModel;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginViewModel get _vm => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_syncFields);
    _passwordController.addListener(_syncFields);
  }

  void _syncFields() {
    _vm.email = _emailController.text;
    _vm.password = _passwordController.text;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _vm.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final error = await _vm.login();
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
    // GoRouter's refreshListenable handles navigation when currentUser changes.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log in')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'you@example.com',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _onLogin(),
            ),
            const SizedBox(height: 24),
            ListenableBuilder(
              listenable: _vm,
              builder: (context, _) => SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _vm.canSubmit ? _onLogin : null,
                  icon: const Icon(Icons.login),
                  label: const Text('Log in'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => context.go('/register'),
                child: const Text("Don't have an account? Register"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
