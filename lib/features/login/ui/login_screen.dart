import 'package:curelink/core/widgets/app_scaffold.dart';
import 'package:curelink/core/widgets/app_text_field.dart';
import 'package:curelink/features/login/cubit/login_cubit.dart';
import 'package:curelink/features/login/cubit/login_states.dart';
import 'package:curelink/features/home/presentation/home_page.dart';
import 'package:curelink/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:emails_validator/emails_validator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailFieldController = TextEditingController();
  final TextEditingController _passwordFieldController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailFieldController.dispose();
    _passwordFieldController.dispose();
    super.dispose();
  }

  void _login(BuildContext context, String email, String password) {
    if (_formKey.currentState!.validate()) {
      context.read<LoginCubit>().login(email: email, password: password);
    }
  }

  void _showSnackbar(BuildContext context, Widget content) {
    final abbr = ScaffoldMessenger.of(context);
    abbr.hideCurrentSnackBar();
    abbr.showSnackBar(SnackBar(content: content));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: AppScaffold(
        appBar: AppBar(toolbarHeight: 20,),
        padding: EdgeInsetsGeometry.zero,
        body: Padding(
          padding: EdgeInsetsGeometry.all(10),
          child: BlocListener<LoginCubit, LoginStates>(
            listener: (context, state) {
              if (state is LoginError) {
                _showSnackbar(context, Text(state.message));
              } else if (state is LoginSuccess) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const HomePage(),
                  ),
                );
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome Back", style: Theme.of(context).textTheme.displayMedium!.copyWith(color: AppTheme.navy, ),),
                Text("Sign in to continue.", style: Theme.of(context).textTheme.titleSmall!.copyWith(color: AppTheme.darkSurface.withAlpha(200)),),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: AppTheme.radiusSmall,),
                      AppTextField(
                        controller: _emailFieldController,
                        keyboardType: TextInputType.emailAddress,
                        label: 'E-mail address',
                        hint: 'example@example.com',
                        validator: (value) {
                          if (value == null || !EmailsValidator.validate(value.trim())) {
                            return "Enter a valid E-mail address";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppTheme.radiusLarge,),
                      AppTextField(
                        controller: _passwordFieldController,
                        isPassword: true,
                        label: 'Password',
                        hint: 'Enter your password',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter a valid password";
                          }
                          return null;
                        },
                      ),
                      TextButton(
                        onPressed: (){}, 
                        child: Text("Forgot password?")
                      ),
                      BlocBuilder<LoginCubit, LoginStates>(
                        builder: (context, state) {
                          if (state is LoginLoading) {
                            return CircularProgressIndicator();
                          } else {
                            return ElevatedButton(
                              onPressed: () => _login(
                                context,
                                _emailFieldController.text.trim(),
                                _passwordFieldController.text.trim(),
                              ),
                              child: Text("Login"),
                            );
                          }
                        },
                      ),
                    ],
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
