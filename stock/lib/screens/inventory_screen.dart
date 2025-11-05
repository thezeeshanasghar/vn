import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/clinic_inventory_service.dart';
import '../core/services/clinic_service.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  int? _doctorId;
  int? _selectedClinicId;
  List<Map<String, dynamic>> _clinics = [];
  List<Map<String, dynamic>> _inventory = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final docStr = prefs.getString('doctor');
      if (docStr == null) return;
      final doc = json.decode(docStr) as Map<String, dynamic>;
      final doctorId = (doc['doctorId'] as num).toInt();
      
      final clinics = await ClinicService.getClinicsByDoctor(doctorId);
      
      setState(() {
        _doctorId = doctorId;
        _clinics = clinics;
        if (clinics.isNotEmpty) {
          _selectedClinicId = (clinics[0]['clinicId'] as num).toInt();
          _loadInventory();
        } else {
          _loading = false;
        }
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _loadInventory() async {
    if (_selectedClinicId == null) return;
    
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final inventory = await ClinicInventoryService.getInventoryByClinic(_selectedClinicId!);
      setState(() {
        _inventory = inventory;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadInventory,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading inventory',
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadInventory,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _clinics.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'No clinics found',
                            style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please add a clinic first',
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadInventory,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            _buildHeader(),
                            const SizedBox(height: 24),

                            // Clinic Selector
                            if (_clinics.length > 1) ...[
                              _buildClinicSelector(),
                              const SizedBox(height: 24),
                            ],

                            // Inventory List
                            _buildInventoryList(),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildHeader() {
    final clinicName = _clinics.firstWhere(
      (c) => (c['clinicId'] as num).toInt() == _selectedClinicId,
      orElse: () => {'name': 'Unknown'},
    )['name'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Clinic Inventory',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Brand quantities for $clinicName',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }

  Widget _buildClinicSelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Clinic',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _selectedClinicId,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: _clinics.map<DropdownMenuItem<int>>((c) {
                final id = (c['clinicId'] as num).toInt();
                final name = (c['name'] ?? '') as String;
                return DropdownMenuItem<int>(
                  value: id,
                  child: Text(name),
                );
              }).toList(),
              onChanged: (v) {
                setState(() => _selectedClinicId = v);
                _loadInventory();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryList() {
    if (_inventory.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  'No inventory data',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Inventory will appear here when you add stock arrivals',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Brand Inventory',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _inventory.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = _inventory[index];
            // Handle both formats: direct properties or nested brandInfo
            final brandName = item['brandName'] ?? 
                             (item['brandInfo'] as Map<String, dynamic>?)?['name'] ?? 
                             'Unknown Brand';
            final brandAmount = ((item['brandAmount'] as num?) ?? 
                                (item['brandInfo'] as Map<String, dynamic>?)?['amount'] as num? ?? 
                                0).toDouble();
            final quantity = ((item['quantity'] as num?) ?? 0).toInt();
            final brandId = (item['brandId'] as num).toInt();

            return Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Brand Icon
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.business, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),

                    // Brand Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            brandName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'PKR ${brandAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Quantity Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: quantity > 0 ? Colors.green.shade50 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: quantity > 0 ? Colors.green.shade300 : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inventory_2,
                            size: 18,
                            color: quantity > 0 ? Colors.green.shade700 : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            quantity.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: quantity > 0 ? Colors.green.shade700 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

