import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/auth_service.dart';
import '../models/assistant.dart';
import '../widgets/sidebar.dart';
import 'login_screen.dart';
import 'patient_list_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PaAuthService _authService = PaAuthService();

  PaAssistant? _assistant;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('pa_token');
      final assistantJson = prefs.getString('pa_assistant');

      if (token == null || assistantJson == null) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
        return;
      }

      final verifiedAssistant = await _authService.verify(token);

      if (!mounted) return;
      setState(() {
        _assistant = PaAssistant(
          paId: verifiedAssistant.paId,
          doctorId: verifiedAssistant.doctorId,
          firstName: verifiedAssistant.firstName,
          lastName: verifiedAssistant.lastName,
          email: verifiedAssistant.email,
          mobileNumber: verifiedAssistant.mobileNumber,
          isActive: verifiedAssistant.isActive,
          permissions: verifiedAssistant.permissions,
          clinicAccess: verifiedAssistant.clinicAccess,
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pa_token');
    await prefs.remove('pa_assistant');
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Setting up your workspace...'),
            ],
          ),
        ),
      );
    }

    final assistant = _assistant;

    if (assistant == null) {
      return Scaffold(
        body: Center(
          child: _PlaceholderMessage(
            icon: Icons.support_agent,
            title: 'Assistant profile unavailable',
            subtitle: 'Please sign in again to continue.',
            actionLabel: 'Sign In',
            onAction: () => Navigator.of(context)
                .pushReplacementNamed(LoginScreen.routeName),
          ),
        ),
      );
    }

    final modules = _buildModules(assistant);

    return _PaMainShell(
      assistant: assistant,
      modules: modules,
      onLogout: _logout,
      error: _error,
    );
  }

  List<_ModuleDescriptor> _buildModules(PaAssistant assistant) {
    final modules = <_ModuleDescriptor>[];

    final hasPatientAccess = assistant.permissions.allowPatients &&
        assistant.clinicAccess.any((access) => access.allowPatients);

    if (hasPatientAccess) {
      modules.add(
        _ModuleDescriptor(
          label: 'Patients',
          icon: Icons.people_alt_outlined,
          builder: () => PaPatientListScreen(assistant: assistant),
        ),
      );
    }

    return modules;
  }
}

class _PaMainShell extends StatefulWidget {
  final PaAssistant assistant;
  final List<_ModuleDescriptor> modules;
  final VoidCallback onLogout;
  final String? error;

  const _PaMainShell({
    required this.assistant,
    required this.modules,
    required this.onLogout,
    required this.error,
  });

  @override
  State<_PaMainShell> createState() => _PaMainShellState();
}

class _PaMainShellState extends State<_PaMainShell> {
  int _selectedIndex = 0;

  @override
  void didUpdateWidget(covariant _PaMainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.modules.isEmpty) {
      _selectedIndex = 0;
    } else {
      _selectedIndex = _selectedIndex.clamp(0, widget.modules.length - 1);
    }

    final error = widget.error;
    if (error != null && error.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red.shade600,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final modules = widget.modules;

    if (modules.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Welcome, ${widget.assistant.fullName}'),
          actions: [
            IconButton(
              tooltip: 'Logout',
              onPressed: widget.onLogout,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _PlaceholderMessage(
              icon: Icons.lock_outline,
              title: 'No modules assigned yet',
              subtitle:
                  'Your supervising doctor has not granted you access to the patients module yet. Please contact them to grant access.',
            ),
          ),
        ),
      );
    }

    final isWideLayout = MediaQuery.of(context).size.width >= 1100;
    final entries = modules
        .map((module) => SidebarEntry(title: module.label, icon: module.icon))
        .toList();

    final content = modules[_selectedIndex].builder();

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.assistant.fullName}'),
        automaticallyImplyLeading: !isWideLayout,
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: isWideLayout
          ? null
          : Drawer(
              child: PaSidebar(
                assistant: widget.assistant,
                entries: entries,
                selectedIndex: _selectedIndex,
                onItemSelected: (index) {
                  Navigator.of(context).pop();
                  setState(() => _selectedIndex = index);
                },
              ),
            ),
      body: isWideLayout
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PaSidebar(
                  assistant: widget.assistant,
                  entries: entries,
                  selectedIndex: _selectedIndex,
                  onItemSelected: (index) {
                    setState(() => _selectedIndex = index);
                  },
                ),
                Expanded(child: content),
              ],
            )
          : content,
    );
  }
}

class _ModuleDescriptor {
  final String label;
  final IconData icon;
  final Widget Function() builder;

  const _ModuleDescriptor({
    required this.label,
    required this.icon,
    required this.builder,
  });
}

class _PlaceholderMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _PlaceholderMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue.shade50,
                  child: Icon(icon, size: 28, color: Colors.blue.shade700),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              OutlinedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

