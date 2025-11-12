import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PaPortalApp());
}

class PaPortalApp extends StatelessWidget {
  const PaPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PA Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routes: {
        '/': (_) => const _StartupGate(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
      },
    );
  }
}

class _StartupGate extends StatefulWidget {
  const _StartupGate();

  @override
  State<_StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<_StartupGate> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('pa_token');
    final assistantJson = prefs.getString('pa_assistant');

    if (!mounted) return;

    if (token != null && assistantJson != null) {
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    } else {
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

