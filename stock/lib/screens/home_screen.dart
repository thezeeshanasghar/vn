import 'package:flutter/material.dart';
import '../core/widgets/app_app_bar.dart';
import '../core/services/supplier_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../core/router/app_routes.dart';
import 'arrivals_screen.dart';
import 'bills_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selected = 0; // 0 dashboard, 1 suppliers
  bool _statsLoading = true;
  int _supplierCount = 0;
  Map<String, dynamic>? _recentSupplier;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(title: 'Stock Portal', onLogout: _logout),
      drawer: _buildDrawer(),
      body: _selected == 1 
          ? const SuppliersScreen() 
          : _selected == 2 
          ? const ArrivalsScreen() 
          : _selected == 3 
          ? const BillsScreen() 
          : _buildDashboard(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDrawerHeader(),
            const SizedBox(height: 8),
            _buildDrawerItem(
              index: 0,
              icon: Icons.dashboard_rounded,
              title: 'Dashboard',
            ),
            _buildDrawerItem(
              index: 1,
              icon: Icons.people_outline_rounded,
              title: 'Suppliers',
            ),
            _buildDrawerItem(
              index: 2,
              icon: Icons.inventory_2_outlined,
              title: 'Brand Arrivals',
            ),
            _buildDrawerItem(
              index: 3,
              icon: Icons.receipt_long_outlined,
              title: 'Bills',
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({required int index, required IconData icon, required String title}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _selected == index ? Colors.blue.shade50 : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        selected: _selected == index,
        leading: Icon(icon, color: _selected == index ? Colors.blue : Colors.grey.shade700),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: _selected == index ? FontWeight.w600 : FontWeight.normal,
            color: _selected == index ? Colors.blue : Colors.grey.shade700,
          ),
        ),
        onTap: () {
          setState(() => _selected = index);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snap) {
        String name = 'Doctor';
        if (snap.data != null) {
          final doc = snap.data!.getString('doctor');
          if (doc != null) {
            final map = json.decode(doc) as Map<String, dynamic>;
            name = '${map['firstName'] ?? ''} ${map['lastName'] ?? ''}'.trim();
          }
        }
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade700, Colors.blue.shade900],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Stock Portal',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('doctor');
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          _buildWelcomeHeader(),
          const SizedBox(height: 24),

          // Stats Grid
          _buildStatsGrid(),
          const SizedBox(height: 24),

          // Quick Actions
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snap) {
        String name = 'Doctor';
        if (snap.data != null) {
          final doc = snap.data!.getString('doctor');
          if (doc != null) {
            final map = json.decode(doc) as Map<String, dynamic>;
            name = '${map['firstName'] ?? ''}'.trim();
          }
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, $name! 👋',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Here\'s your stock management overview',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          title: 'Total Suppliers',
          value: _statsLoading ? '--' : '$_supplierCount',
          icon: Icons.people_alt_rounded,
          color: Colors.blue,
          subtitle: 'Active suppliers',
        ),
        _buildStatCard(
          title: 'Recent Supplier',
          value: _recentSupplier?['name']?.toString().split(' ').take(2).join(' ') ?? '--',
          icon: Icons.person_add_alt_1_rounded,
          color: Colors.green,
          subtitle: _recentSupplier?['mobileNumber']?.toString() ?? 'No supplier',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildActionCard(
              title: 'Add Supplier',
              icon: Icons.person_add_rounded,
              color: Colors.blue,
              onTap: () => setState(() => _selected = 1),
            ),
            _buildActionCard(
              title: 'New Arrival',
              icon: Icons.inventory_2_rounded,
              color: Colors.green,
              onTap: () => setState(() => _selected = 2),
            ),
            _buildActionCard(
              title: 'View Bills',
              icon: Icons.receipt_long_rounded,
              color: Colors.orange,
              onTap: () => setState(() => _selected = 3),
            ),
            _buildActionCard(
              title: 'Suppliers',
              icon: Icons.people_rounded,
              color: Colors.purple,
              onTap: () => setState(() => _selected = 1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    setState(() => _statsLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final doc = prefs.getString('doctor');
      if (doc == null) {
        setState(() => _statsLoading = false);
        return;
      }
      final d = json.decode(doc) as Map<String, dynamic>;
      final doctorId = (d['doctorId'] as num).toInt();
      final list = await SupplierService.list(doctorId);
      setState(() {
        _supplierCount = list.length;
        _recentSupplier = list.isNotEmpty ? list.last : null;
      });
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _statsLoading = false);
    }
  }
}

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  bool _saving = false;
  List<Map<String, dynamic>> _items = [];
  int? _doctorId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final doctorJson = prefs.getString('doctor');
      if (doctorJson != null) {
        final map = json.decode(doctorJson) as Map<String, dynamic>;
        setState(() => _doctorId = (map['doctorId'] as num).toInt());
        await _load();
      }
    } catch (_) {}
  }

  Future<void> _load() async {
    try {
      if (_doctorId == null) return;
      final items = await SupplierService.list(_doctorId!);
      setState(() => _items = items);
    } catch (_) {}
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _mobile.text.trim().isEmpty || _doctorId == null) return;
    setState(() => _saving = true);
    try {
      await SupplierService.create(_doctorId!, _name.text.trim(), _mobile.text.trim());
      _name.clear();
      _mobile.clear();
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Supplier saved successfully'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().contains('Duplicate') ? 'Supplier already exists' : e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 16),

            // Suppliers List
            if (_items.isEmpty) _buildEmptyState(),
            if (_items.isNotEmpty) ..._items.map(_buildSupplierCard),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Suppliers',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_items.length} supplier${_items.length != 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.people_rounded, color: Colors.blue.shade700, size: 32),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(40),
        width: double.infinity,
        child: Column(
          children: [
            Icon(Icons.people_outline_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No Suppliers Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first supplier to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _openAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add First Supplier'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierCard(Map<String, dynamic> e) {
    final name = (e['name'] ?? '') as String;
    final initials = name.isNotEmpty 
        ? name.trim().split(RegExp(r"\s+")).map((s) => s[0]).take(2).join().toUpperCase() 
        : 'S';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.blue.shade100,
          foregroundColor: Colors.blue.shade800,
          child: Text(
            initials,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.phone_rounded, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  '${e['mobileNumber'] ?? ''}',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'ID: ${e['supplierId'] ?? ''}',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _openEdit(e),
              icon: Icon(Icons.edit_rounded, color: Colors.blue.shade600),
              tooltip: 'Edit',
            ),
            IconButton(
              onPressed: () => _delete(e),
              icon: Icon(Icons.delete_rounded, color: Colors.red.shade600),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAdd() async {
    _name.clear();
    _mobile.clear();
    await _openForm(title: 'Add Supplier', onSave: () => _save());
  }

  Future<void> _openEdit(Map<String, dynamic> e) async {
    _name.text = '${e['name'] ?? ''}';
    _mobile.text = '${e['mobileNumber'] ?? ''}';
    await _openForm(
      title: 'Edit Supplier',
      onSave: () async {
        final id = (e['supplierId'] as num).toInt();
        try {
          await SupplierService.update(id, _name.text.trim(), _mobile.text.trim());
          if (mounted) Navigator.of(context).pop();
          await _load();
        } catch (err) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(err.toString()),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
          }
        }
      },
    );
  }

  Future<void> _delete(Map<String, dynamic> e) async {
    final id = (e['supplierId'] as num).toInt();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Supplier'),
        content: Text('Are you sure you want to delete "${e['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await SupplierService.remove(id);
        await _load();
      } catch (err) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err.toString()),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      }
    }
  }

  Future<void> _openForm({required String title, required Future<void> Function() onSave}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: 'Supplier Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _mobile,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saving ? null : () async {
                      setState(() => _saving = true);
                      try {
                        await onSave();
                        if (mounted) Navigator.of(context).maybePop();
                      } finally {
                        if (mounted) setState(() => _saving = false);
                      }
                    },
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_rounded),
                              SizedBox(width: 8),
                              Text('Save Supplier'),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}