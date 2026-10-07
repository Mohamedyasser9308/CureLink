
import 'package:curelink/core/router/routes_names.dart';
import 'package:curelink/core/theme/app_theme.dart';
import 'package:curelink/core/widgets/app_button.dart';
import 'package:curelink/core/widgets/app_scaffold.dart';
import 'package:curelink/core/widgets/app_text_field.dart';
import 'package:curelink/features/auth/presentation/auth_repository.dart';
import 'package:curelink/features/auth/presentation/auth_validators.dart';
import 'package:curelink/l10n/app_localizations.dart';
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

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isLoading = true;
    });

    try {
      await _authRepository.signUp(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        l10n: l10n,
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        RoutesNames.ageGroupPage,
        arguments: _nameController.text.trim(),
      );
    } on AuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(e.message),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.somethingWentWrong),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
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

  void _goToLogin() {
    Navigator.pushReplacementNamed(
      context,
      RoutesNames.loginPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final titleColor = theme.brightness == Brightness.light
        ? AppTheme.navy
        : theme.colorScheme.onSurface;

    return AppScaffold(
      showAppBar: false,
      scrollable: true,
      isLoading: false,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.createAccount,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: titleColor,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              l10n.createAccountSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(160),
                height: 1.4,
              ),
            ),

            const SizedBox(height: 30),

            _FieldLabel(l10n.name),

            AppTextField(
              controller: _nameController,
              hint: l10n.enterYourName,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              validator: (value) => AuthValidators.name(
                value,
                l10n,
              ),
            ),

            const SizedBox(height: 18),

            _FieldLabel(l10n.phone),

            AppTextField(
              controller: _phoneController,
              hint: l10n.enterYourPhone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              validator: (value) => AuthValidators.phone(
                value,
                l10n,
              ),
            ),

            const SizedBox(height: 18),

            _FieldLabel(l10n.email),

            AppTextField(
              controller: _emailController,
              hint: l10n.enterYourEmail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) => AuthValidators.email(
                value,
                l10n,
              ),
            ),

            const SizedBox(height: 18),

            _FieldLabel(l10n.password),

            AppTextField(
              controller: _passwordController,
              hint: l10n.createPassword,
              isPassword: true,
              textInputAction: TextInputAction.next,
              validator: (value) => AuthValidators.password(
                value,
                l10n,
              ),
            ),

            const SizedBox(height: 18),

            _FieldLabel(l10n.confirmPassword),

            AppTextField(
              controller: _confirmPasswordController,
              hint: l10n.reEnterPassword,
              isPassword: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              validator: AuthValidators.confirmPassword(
                () => _passwordController.text,
                l10n,
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: l10n.createAccount,
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ),

            const SizedBox(height: 14),

            Center(
              child: TextButton(
                onPressed: _isLoading ? null : _goToLogin,
                child: RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(170),
                    ),
                    children: [
                      TextSpan(
                        text: '${l10n.alreadyHaveAccount} ',
                      ),
                      TextSpan(
                        text: l10n.login,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
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
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final color = theme.brightness == Brightness.light
        ? AppTheme.navy
        : theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
