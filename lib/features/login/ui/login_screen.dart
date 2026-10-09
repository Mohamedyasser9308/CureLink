import 'package:curelink/core/router/routes_names.dart';
import 'package:curelink/core/theme/app_theme.dart';
import 'package:curelink/core/widgets/app_button.dart';
import 'package:curelink/core/widgets/app_scaffold.dart';
import 'package:curelink/core/widgets/app_text_field.dart';
// import 'package:curelink/features/home/patient_home_screen.dart';
import 'package:curelink/features/login/cubit/login_cubit.dart';
import 'package:curelink/features/login/cubit/login_states.dart';
import 'package:curelink/features/shell/presentation/main_shell.dart';
import 'package:curelink/l10n/app_localizations.dart';
import 'package:emails_validator/emails_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailFieldController =
      TextEditingController();

  final TextEditingController _passwordFieldController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailFieldController.dispose();
    _passwordFieldController.dispose();
    super.dispose();
  }

  void _login(BuildContext context) {
    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    final l10n = AppLocalizations.of(context)!;

    context.read<LoginCubit>().login(
          email: _emailFieldController.text.trim(),
          password: _passwordFieldController.text,
          l10n: l10n,
        );
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  void _goToSignup(BuildContext context) {
    Navigator.pushReplacementNamed(
      context,
      RoutesNames.signUpPage,
    );
  }

  void _goToForgotPassword(BuildContext context) {
    Navigator.pushNamed(
      context,
      RoutesNames.forgotPasswordPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final titleColor = theme.brightness == Brightness.light
        ? AppTheme.navy
        : theme.colorScheme.onSurface;

    return BlocProvider(
      create: (_) => LoginCubit(),
      child: AppScaffold(
        showAppBar: false,
        scrollable: true,
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
        body: BlocListener<LoginCubit, LoginStates>(
          listener: (context, state) {
            if (state is LoginError) {
              _showSnackbar(context, state.message);
            } else if (state is LoginSuccess) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const MainShell(),
                ),
              );
            }
          },
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.welcomeBack,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  l10n.signInToContinue,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(160),
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 32),

                _FieldLabel(
                  text: l10n.email,
                  color: titleColor,
                ),

                AppTextField(
                  controller: _emailFieldController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  hint: l10n.loginEmailHint,
                  validator: (value) {
                    if (value == null ||
                        !EmailsValidator.validate(value.trim())) {
                      return l10n.invalidEmail;
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                _FieldLabel(
                  text: l10n.password,
                  color: titleColor,
                ),

                AppTextField(
                  controller: _passwordFieldController,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  hint: l10n.loginPasswordHint,
                  onSubmitted: (_) {
                    _login(context);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.enterPassword;
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      _goToForgotPassword(context);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 40),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      l10n.forgotPassword,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                BlocBuilder<LoginCubit, LoginStates>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: l10n.login,
                        isLoading: state is LoginLoading,
                        onPressed: state is LoginLoading
                            ? null
                            : () => _login(context),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                Center(
                  child: TextButton(
                    onPressed: () => _goToSignup(context),
                    child: RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(170),
                        ),
                        children: [
                          TextSpan(
                            text: '${l10n.dontHaveAccount} ',
                          ),
                          TextSpan(
                            text: l10n.signUp,
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
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({
    required this.text,
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