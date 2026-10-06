import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

/// صفحة اختبار مؤقتة للتأكد إن Firebase شغال. امسحها بعد التجربة.
class FirebaseTestPage extends StatefulWidget {
  const FirebaseTestPage({super.key});
  static const String routeName = "/firebaseTest";

  @override
  State<FirebaseTestPage> createState() => _FirebaseTestPageState();
}

class _FirebaseTestPageState extends State<FirebaseTestPage> {
  String _log = 'اضغط على زر لبدء الاختبار';
  bool _loading = false;

  Future<void> _run(Future<String> Function() action) async {
    setState(() {
      _loading = true;
      _log = '...';
    });
    try {
      final result = await action();
      if (mounted) setState(() => _log = result);
    } on FirebaseAuthException catch (e) {
      if (mounted)
        setState(
          () => _log = '❌ FirebaseAuthException\ncode: ${e.code}\n${e.message}',
        );
    } catch (e) {
      if (mounted) setState(() => _log = '❌ Error\n$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // 1) هل Firebase اتهيّأ؟
  Future<String> _checkInit() async {
    final app = Firebase.app();
    return '✅ Firebase initialized\n'
        'App: ${app.name}\n'
        'Project: ${app.options.projectId}\n'
        'App ID: ${app.options.appId}';
  }

  // 2) هل الـ Auth بيتصل بالسيرفر؟
  Future<String> _anonymousSignIn() async {
    final cred = await FirebaseAuth.instance.signInAnonymously();
    return '✅ Auth works\nUID: ${cred.user?.uid}';
  }

  Future<String> _signOut() async {
    await FirebaseAuth.instance.signOut();
    return '✅ Signed out\ncurrentUser: ${FirebaseAuth.instance.currentUser}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _loading ? null : () => _run(_checkInit),
              child: const Text('1) Check Firebase init'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : () => _run(_anonymousSignIn),
              child: const Text('2) Anonymous sign-in'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _loading ? null : () => _run(_signOut),
              child: const Text('Sign out'),
            ),
            const SizedBox(height: 24),
            if (_loading) const LinearProgressIndicator(),
            const SizedBox(height: 12),
            Expanded(child: SingleChildScrollView(child: SelectableText(_log))),
          ],
        ),
      ),
    );
  }
}
