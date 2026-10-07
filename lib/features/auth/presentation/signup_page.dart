import 'package:curelink/core/router/routes_names.dart';
import 'package:curelink/core/theme/app_theme.dart';
import 'package:curelink/core/widgets/app_button.dart';
import 'package:curelink/core/widgets/app_scaffold.dart';
import 'package:curelink/core/widgets/app_text_field.dart';
import 'package:curelink/features/auth/presentation/auth_repository.dart';
import 'package:curelink/features/auth/presentation/auth_validators.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _authRepository = AuthRepository();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _authRepository.signUp(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/role');
    } on AuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(e.message),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final titleColor = theme.brightness == Brightness.light
        ? AppTheme.navy
        : theme.colorScheme.onSurface;

    return AppScaffold(
      showAppBar: false,
      scrollable: true,
      isLoading: _isLoading,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create account',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: titleColor,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 24),

            _FieldLabel(
              'Name',
              color: titleColor,
            ),
            AppTextField(
              controller: _nameController,
              hint: 'Enter details',
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              validator: AuthValidators.name,
            ),

            const SizedBox(height: 16),

            _FieldLabel(
              'Phone',
              color: titleColor,
            ),
            AppTextField(
              controller: _phoneController,
              hint: 'Enter details',
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              validator: AuthValidators.phone,
            ),

            const SizedBox(height: 16),

            _FieldLabel(
              'Email',
              color: titleColor,
            ),
            AppTextField(
              controller: _emailController,
              hint: 'Enter details',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: AuthValidators.email,
            ),

            const SizedBox(height: 16),

            _FieldLabel(
              'Password',
              color: titleColor,
            ),
            AppTextField(
              controller: _passwordController,
              hint: 'Enter details',
              isPassword: true,
              textInputAction: TextInputAction.next,
              validator: AuthValidators.password,
            ),

            const SizedBox(height: 16),

            _FieldLabel(
              'Confirm Password',
              color: titleColor,
            ),
            AppTextField(
              controller: _confirmPasswordController,
              hint: 'Enter details',
              isPassword: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              validator: AuthValidators.confirmPassword(
                () => _passwordController.text,
              ),
            ),

            const SizedBox(height: 24),

            AppButton(
              label: 'Create account',
              isLoading: _isLoading,
              onPressed: _submit,
            ),

            const SizedBox(height: 12),

            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    RoutesNames.loginPage,
                  );
                },
                child: const Text(
                  'Already have an account? Login',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(
    this.text, {
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}