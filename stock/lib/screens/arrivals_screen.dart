import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/supplier_service.dart';
import '../core/services/brand_service.dart';
import '../core/services/bill_service.dart';
import '../core/services/clinic_service.dart';

class ArrivalsScreen extends StatefulWidget {
  final VoidCallback? onSaved;
  const ArrivalsScreen({super.key, this.onSaved});

  @override
  State<ArrivalsScreen> createState() => _ArrivalsScreenState();
}

class _ArrivalsScreenState extends State<ArrivalsScreen> {
  int? _doctorId;
  int? _clinicId;
  int? _supplierId;
  DateTime _date = DateTime.now();
  List<Map<String, dynamic>> _suppliers = [];
  List<Map<String, dynamic>> _clinics = [];
  List<Map<String, dynamic>> _brands = [];
  final List<_Line> _lines = [ _Line() ];
  bool _loading = true;
  bool _saving = false;
  bool _paid = false;

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
      final supp = await SupplierService.list(doctorId);
      final clinics = await ClinicService.getClinicsByDoctor(doctorId);
      final br = await BrandService.list();
      setState(() {
        _doctorId = doctorId;
        _suppliers = supp;
        _clinics = clinics;
        _brands = br;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  num get totalQty => _lines.fold<num>(0, (p, e) => p + (e.quantity ?? 0));
  num get totalAmount => _lines.fold<num>(0, (p, e) => p + (e.amount ?? 0));

  Map<String, dynamic>? _brandById(int id) => _brands.firstWhere((b) => (b['brandId'] as num).toInt() == id, orElse: () => {});

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Arrival'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 24),

            // Form Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Supplier and Date
                    _buildFormRow(),
                    const SizedBox(height: 16),

                    // Paid Checkbox
                    _buildPaidCheckbox(),
                    const SizedBox(height: 24),

                    // Items Section
                    _buildItemsSection(),
                    const SizedBox(height: 16),

                    // Total Summary
                    _buildTotalSummary(),
                    const SizedBox(height: 24),

                    // Save Button
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'New Stock Arrival',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Add new stock arrivals from suppliers',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildFormRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          // Desktop/Tablet layout
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildClinicDropdown()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSupplierDropdown()),
                ],
              ),
              const SizedBox(height: 16),
              _buildDatePicker(),
            ],
          );
        } else {
          // Mobile layout
          return Column(
            children: [
              _buildClinicDropdown(),
              const SizedBox(height: 16),
              _buildSupplierDropdown(),
              const SizedBox(height: 16),
              _buildDatePicker(),
            ],
          );
        }
      },
    );
  }

  Widget _buildClinicDropdown() {
    return DropdownButtonFormField<int>(
      value: _clinicId,
      decoration: InputDecoration(
        labelText: 'Clinic',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: _clinics.map<DropdownMenuItem<int>>((c) {
        final id = (c['clinicId'] as num?)?.toInt() ?? 0;
        final name = (c['name'] ?? '') as String;
        return DropdownMenuItem<int>(
          value: id,
          child: Text(name),
        );
      }).toList(),
      onChanged: (v) => setState(() => _clinicId = v),
    );
  }

  Widget _buildSupplierDropdown() {
    return DropdownButtonFormField<int>(
      value: _supplierId,
      decoration: InputDecoration(
        labelText: 'Supplier',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: _suppliers.map<DropdownMenuItem<int>>((s) {
        final id = (s['supplierId'] as num?)?.toInt() ?? 0;
        final name = (s['name'] ?? '') as String;
        return DropdownMenuItem<int>(
          value: id,
          child: Text(name),
        );
      }).toList(),
      onChanged: (v) => setState(() => _supplierId = v),
    );
  }

  Widget _buildDatePicker() {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Date',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      controller: TextEditingController(
        text: '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) setState(() => _date = picked);
      },
    );
  }

  Widget _buildPaidCheckbox() {
    return Card(
      color: _paid ? Colors.green.shade50 : Colors.grey.shade50,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Checkbox(
              value: _paid,
              onChanged: (v) => setState(() => _paid = v ?? false),
              activeColor: Colors.green,
            ),
            const SizedBox(width: 8),
            Text(
              'Mark as Paid',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _paid ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _paid ? 'PAID' : 'UNPAID',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Arrival Items',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => setState(() => _lines.add(_Line())),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._lines.asMap().entries.map((entry) {
          final idx = entry.key;
          final line = entry.value;
          final brand = line.brandId != null ? _brandById(line.brandId!) : null;
          final unit = (brand?['amount'] as num?)?.toDouble() ?? 0;
          line.amount = unit * (line.quantity ?? 0);

          return _buildLineItem(idx, line, brand);
        }).toList(),
      ],
    );
  }

  Widget _buildLineItem(int index, _Line line, Map<String, dynamic>? brand) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Item ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() => _lines.removeAt(index)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Brand Selection
            _buildBrandSelection(line, brand),
            const SizedBox(height: 12),
            // Quantity and Amount
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 400) {
                  return Row(
                    children: [
                      Expanded(child: _buildQuantityInput(line)),
                      const SizedBox(width: 16),
                      _buildAmountDisplay(line),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildQuantityInput(line),
                      const SizedBox(height: 12),
                      _buildAmountDisplay(line),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandSelection(_Line line, Map<String, dynamic>? brand) {
    return InkWell(
      onTap: () => _openBrandPicker(line),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.business, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.brandId != null ? (brand?['name'] ?? '') as String : 'Select Brand',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: line.brandId != null ? Colors.black : Colors.grey,
                    ),
                  ),
                  if (line.brandId != null && brand?['amount'] != null)
                    Text(
                      'PKR ${brand!['amount']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityInput(_Line line) {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Quantity',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      keyboardType: TextInputType.number,
      initialValue: line.quantity?.toString(),
      onChanged: (v) => setState(() => line.quantity = int.tryParse(v) ?? 0),
    );
  }

  Widget _buildAmountDisplay(_Line line) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Amount',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'PKR ${line.amount?.toStringAsFixed(0) ?? '0'}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Summary',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(
                '${_lines.length} item${_lines.length != 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'PKR ${totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Text(
                'Qty: $totalQty',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
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
                  Icon(Icons.save),
                  SizedBox(width: 8),
                  Text(
                    'Save Arrival',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _openBrandPicker(_Line line) async {
    String query = '';
    final result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Brand',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search brands...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() => query = v.toLowerCase()),
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: _brands
                        .where((b) => query.isEmpty || (b['name'] as String).toLowerCase().contains(query))
                        .map((b) => ListTile(
                              leading: const Icon(Icons.business, color: Colors.blue),
                              title: Text('${b['name']}'),
                              subtitle: Text('PKR ${b['amount']}'),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () => Navigator.pop(context, (b['brandId'] as num).toInt()),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
    if (result != null) setState(() => line.brandId = result);
  }

  Future<void> _save() async {
    if (_doctorId == null || _supplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select supplier and date')),
      );
      return;
    }
    if (_lines.isEmpty || _lines.any((l) => l.brandId == null || (l.quantity ?? 0) <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one valid item')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final lines = _lines.map((l) => {'brandId': l.brandId, 'quantity': l.quantity}).toList();
      await BillService.create(doctorId: _doctorId!, clinicId: _clinicId, supplierId: _supplierId!, date: _date, lines: lines, paid: _paid);
      if (mounted) {
        setState(() {
          _lines..clear()..add(_Line());
          _paid = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Arrival saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Trigger callback to refresh inventory
        if (widget.onSaved != null) {
          widget.onSaved!();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _Line {
  int? brandId;
  int? quantity;
  double? amount;
  _Line({this.brandId, this.quantity, this.amount});
}