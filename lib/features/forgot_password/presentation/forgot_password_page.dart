import 'package:curelink/core/router/routes_names.dart';
import 'package:curelink/core/theme/app_theme.dart';
import 'package:curelink/core/widgets/app_button.dart';
import 'package:curelink/core/widgets/app_scaffold.dart';
import 'package:curelink/core/widgets/app_text_field.dart';
import 'package:curelink/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/forgot_password_cubit.dart';
import 'cubit/forgot_password_state.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetEmail() {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;

    context.read<ForgotPasswordCubit>().sendResetEmail(
          email: _emailController.text.trim(),
          l10n: l10n,
        );
  }

  void _showSnackbar(String message) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final titleColor = theme.brightness == Brightness.light
        ? AppTheme.navy
        : theme.colorScheme.onSurface;

    return BlocProvider(
      create: (_) => ForgotPasswordCubit(),
      child: AppScaffold(
        title: l10n.forgotPassword,
        scrollable: true,
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
        body: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
          listener: (context, state) {
            if (state is ForgotPasswordSuccess) {
              _showSnackbar(state.message);

              Navigator.pushReplacementNamed(
                context,
                RoutesNames.loginPage,
              );
            }

            if (state is ForgotPasswordError) {
              _showSnackbar(state.message);
            }
          },
          builder: (context, state) {
            return Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  Text(
                    l10n.forgotPassword,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: titleColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    l10n.forgotPasswordSubtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(160),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    l10n.email,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: titleColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  AppTextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    hint: l10n.enterYourEmail,
                    onSubmitted: (_) {
                      if (state is! ForgotPasswordLoading) {
                        _sendResetEmail();
                      }
                    },
                    validator: (value) {
                      final email = value?.trim() ?? '';

                      if (email.isEmpty) {
                        return l10n.enterYourEmail;
                      }

                      final validEmail = RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(email);

                      if (!validEmail) {
                        return l10n.invalidEmail;
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: l10n.sendResetLink,
                      isLoading: state is ForgotPasswordLoading,
                      onPressed: state is ForgotPasswordLoading
                          ? null
                          : _sendResetEmail,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Center(
                    child: TextButton(
                      onPressed: state is ForgotPasswordLoading
                          ? null
                          : () {
                              Navigator.pushReplacementNamed(
                                context,
                                RoutesNames.loginPage,
                              );
                            },
                      child: Text(
                        l10n.backToLogin,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}