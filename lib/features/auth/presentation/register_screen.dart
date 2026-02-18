import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'register_view_model.dart';

/// Registration form screen.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    required this.viewModel,
    super.key,
  });

  final RegisterViewModel viewModel;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  static final _emailRegex =
      RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  RegisterViewModel get _vm => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_syncFields);
    _passwordController.addListener(_syncFields);
    _confirmController.addListener(_syncFields);
  }

  void _syncFields() {
    _vm.email = _emailController.text;
    _vm.password = _passwordController.text;
    _vm.confirmPassword = _confirmController.text;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _vm.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (!_formKey.currentState!.validate()) return;

    final error = _vm.register();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Registration successful — please log in',
        ),
      ),
    );
    context.go('/login');
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _vm.dateOfBirth ?? now.subtract(const Duration(days: 7300)),
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 13),
    );
    if (picked != null) {
      _vm.setDateOfBirth(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!_emailRegex.hasMatch(value.trim())) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 8) {
                    return 'Must be at least 8 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmController,
                decoration: const InputDecoration(
                  labelText: 'Confirm password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _vm.password) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ListenableBuilder(
                listenable: _vm,
                builder: (context, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DateOfBirthSection(
                      dateOfBirth: _vm.dateOfBirth,
                      onPick: _pickDateOfBirth,
                      onClear: _vm.clearDateOfBirth,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed:
                            _vm.canSubmit ? _onRegister : null,
                        icon: const Icon(Icons.person_add),
                        label: const Text('Register'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateOfBirthSection extends StatelessWidget {
  const _DateOfBirthSection({
    required this.dateOfBirth,
    required this.onPick,
    required this.onClear,
  });

  final DateTime? dateOfBirth;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of birth (optional)',
          style: textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                dateOfBirth != null
                    ? '${dateOfBirth!.day}/'
                        '${dateOfBirth!.month}/'
                        '${dateOfBirth!.year}'
                    : 'Not set',
                style: textTheme.bodyLarge,
              ),
            ),
            FilledButton.tonal(
              onPressed: onPick,
              child: Text(
                dateOfBirth != null ? 'Change' : 'Pick date',
              ),
            ),
            if (dateOfBirth != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.clear),
                tooltip: 'Clear date of birth',
              ),
            ],
          ],
        ),
      ],
    );
  }
}
