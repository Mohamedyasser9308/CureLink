import 'package:flutter/material.dart';

/// Handy navigation helpers: AppNavigator.push(context, HomePage.routeName)
class AppNavigator {
  AppNavigator._();

  static Future<T?> push<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) => Navigator.of(context).pushNamed<T>(routeName, arguments: arguments);

  static Future<T?> replace<T extends Object?, R extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) => Navigator.of(
    context,
  ).pushReplacementNamed<T, R>(routeName, arguments: arguments);

  static Future<T?> pushAndClear<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) => Navigator.of(context).pushNamedAndRemoveUntil<T>(
    routeName,
    (route) => false,
    arguments: arguments,
  );

  static void pop<T extends Object?>(BuildContext context, [T? result]) =>
      Navigator.of(context).pop<T>(result);
}
