import 'package:flutter/material.dart';
import 'app_loading.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.appBar,
    this.actions,
    this.leading,
    this.showAppBar = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.scrollable = false,
    this.safeArea = true,
    this.isLoading = false,
    this.loadingMessage,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
  });

  final Widget body;
  final String? title;
  final PreferredSizeWidget? appBar;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showAppBar;
  final EdgeInsetsGeometry padding;
  final bool scrollable;
  final bool safeArea;
  final bool isLoading;
  final String? loadingMessage;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(padding: padding, child: body);

    if (scrollable) {
      content = SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: content,
      );
    }

    if (safeArea) {
      content = SafeArea(top: !showAppBar && appBar == null, child: content);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar ??
          (showAppBar && (title != null || actions != null || leading != null)
              ? AppBar(
                  title: title != null ? Text(title!) : null,
                  actions: actions,
                  leading: leading,
                )
              : null),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Stack(
          children: [
            Positioned.fill(child: content),
            if (isLoading) AppLoadingOverlay(message: loadingMessage),
          ],
        ),
      ),
    );
  }
}