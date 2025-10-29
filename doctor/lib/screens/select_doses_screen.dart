import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dose.dart';
import '../services/dose_service.dart';
import '../services/doctor_schedule_service.dart';
import '../services/auth_service.dart';

class SelectDosesScreen extends StatefulWidget {
  const SelectDosesScreen({super.key});

  @override
  State<SelectDosesScreen> createState() => _SelectDosesScreenState();
}

class _SelectDosesScreenState extends State<SelectDosesScreen> {
  List<Dose> _allDoses = [];
  Set<int> _selectedDoseIds = {};
  Set<int> _disabledDoseIds = {}; // Already scheduled doses
  bool _loading = true;
  bool _saving = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final doctor = authService.currentDoctor;
      
      if (doctor == null) {
        throw Exception('Doctor not logged in');
      }

      // Load doses and existing schedules in parallel
      final doses = await DoseService.getAllDoses();
      final schedules = await DoctorScheduleService.getSchedulesByDoctor(doctor.doctorId);
      
      // Get dose IDs that are already scheduled
      final scheduledDoseIds = schedules.map((s) => s.doseId).toSet();

      setState(() {
        _allDoses = doses;
        _disabledDoseIds = scheduledDoseIds;
      });
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to Load Data', e.toString());
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Dose> get _filteredDoses {
    if (_searchQuery.isEmpty) return _allDoses;
    return _allDoses.where((dose) {
      final name = (dose.name ?? '').toLowerCase();
      final vaccineName = (dose.vaccine?.name ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || vaccineName.contains(query);
    }).toList();
  }

  void _toggleDose(int? doseId) {
    if (doseId == null) return;
    // Don't allow selection if already scheduled
    if (_disabledDoseIds.contains(doseId)) return;
    
    setState(() {
      if (_selectedDoseIds.contains(doseId)) {
        _selectedDoseIds.remove(doseId);
      } else {
        _selectedDoseIds.add(doseId);
      }
    });
  }

  Future<void> _saveSchedules() async {
    if (_selectedDoseIds.isEmpty) {
      _showErrorDialog('No Selection', 'Please select at least one dose to add to your schedule.');
      return;
    }

    setState(() => _saving = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final doctor = authService.currentDoctor;

      if (doctor == null) {
        throw Exception('Doctor not logged in');
      }

      await DoctorScheduleService.createSchedules(
        doctor.doctorId,
        _selectedDoseIds.toList(),
      );

      if (mounted) {
        // Show simple success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_selectedDoseIds.length} dose${_selectedDoseIds.length > 1 ? 's' : ''} added successfully!',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        
        // Auto-redirect after short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Save Failed', e.toString());
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }


  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.error_outline, color: Colors.red.shade600, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Select Doses',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade700,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search doses by name or vaccine...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.search, color: Colors.blue.shade600),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
            ),
          ),

          // Selection Count Badge
          if (_selectedDoseIds.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.blue.shade600, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedDoseIds.length} dose${_selectedDoseIds.length > 1 ? 's' : ''} selected',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          // Doses List
          Expanded(
            child: _loading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading doses...'),
                      ],
                    ),
                  )
                : _filteredDoses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.medical_services_outlined,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No doses available'
                                  : 'No doses found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Doses will appear here once added by admin'
                                  : 'Try a different search term',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: _filteredDoses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final dose = _filteredDoses[index];
                          final isSelected = dose.doseId != null &&
                              _selectedDoseIds.contains(dose.doseId);
                          final isDisabled = dose.doseId != null &&
                              _disabledDoseIds.contains(dose.doseId);

                          return Opacity(
                            opacity: isDisabled ? 0.6 : 1.0,
                            child: Container(
                            decoration: BoxDecoration(
                              color: isDisabled ? Colors.grey.shade100 : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDisabled
                                    ? Colors.grey.shade300
                                    : isSelected
                                        ? Colors.blue.shade600
                                        : Colors.grey.shade200,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? Colors.blue.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: isDisabled ? null : () => _toggleDose(dose.doseId),
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      // Checkbox or Disabled Badge
                                      isDisabled
                                          ? Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.check_circle,
                                                size: 16,
                                                color: Colors.grey.shade600,
                                              ),
                                            )
                                          : Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: isSelected
                                                      ? Colors.blue.shade600
                                                      : Colors.grey.shade400,
                                                  width: 2,
                                                ),
                                                color: isSelected
                                                    ? Colors.blue.shade600
                                                    : Colors.transparent,
                                              ),
                                              child: isSelected
                                                  ? const Icon(
                                                      Icons.check,
                                                      color: Colors.white,
                                                      size: 16,
                                                    )
                                                  : null,
                                            ),
                                      const SizedBox(width: 16),

                                      // Icon
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.medical_services,
                                          color: Colors.blue.shade600,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),

                                      // Dose Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              dose.name ?? 'Unnamed Dose',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade800,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            if (dose.vaccine?.name != null)
                                              Text(
                                                dose.vaccine!.name!,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                _buildInfoChip(
                                                  Icons.calendar_today,
                                                  'Age: ${dose.minAge}-${dose.maxAge} years',
                                                  Colors.orange.shade700,
                                                ),
                                                if (dose.minGap > 0) ...[
                                                  const SizedBox(width: 8),
                                                  _buildInfoChip(
                                                    Icons.schedule,
                                                    'Gap: ${dose.minGap} days',
                                                    Colors.green.shade700,
                                                  ),
                                                ],
                                                if (isDisabled) ...[
                                                  const SizedBox(width: 8),
                                                  _buildInfoChip(
                                                    Icons.check_circle,
                                                    'Already Scheduled',
                                                    Colors.blue.shade700,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: _selectedDoseIds.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() => _selectedDoseIds.clear());
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear Selection'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                    Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _saveSchedules,
                      icon: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check),
                      label: Text(_saving ? 'Saving...' : 'Finish Selection'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                        shadowColor: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    // Use opacity-based colors for any color
    final lightColor = color.withOpacity(0.1);
    final borderColor = color.withOpacity(0.3);
    final textColor = color;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
