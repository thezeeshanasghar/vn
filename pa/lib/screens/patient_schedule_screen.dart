import 'package:flutter/material.dart';

import '../core/services/brand_service.dart';
import '../core/services/clinic_inventory_service.dart';
import '../core/services/patient_schedule_service.dart';
import '../models/assistant.dart';
import '../models/brand.dart';
import '../models/patient.dart';
import '../models/patient_schedule.dart';

class PaPatientScheduleScreen extends StatefulWidget {
  final PaPatient patient;
  final PaAssistant assistant;

  const PaPatientScheduleScreen({
    super.key,
    required this.patient,
    required this.assistant,
  });

  @override
  State<PaPatientScheduleScreen> createState() => _PaPatientScheduleScreenState();
}

class _PaPatientScheduleScreenState extends State<PaPatientScheduleScreen> {
  Future<List<PaPatientSchedule>>? _schedulesFuture;

  @override
  void initState() {
    super.initState();
    _refreshSchedules();
  }

  void _refreshSchedules() {
    setState(() {
      _schedulesFuture = PaPatientScheduleService.getSchedulesByChild(
        widget.patient.patientId!,
      );
    });
  }

  Future<void> _toggleIsDone(PaPatientSchedule schedule) async {
    if (schedule.scheduleId == null) return;
    final newIsDone = !schedule.isDone;

    if (!newIsDone) {
      await _performToggle(schedule, newIsDone, schedule.brandId);
      return;
    }

    final selectedBrandId = await _showBrandSelectionDialog(schedule);
    if (selectedBrandId != null) {
      await _performToggle(schedule, newIsDone, selectedBrandId);
    }
  }

  Future<int?> _showBrandSelectionDialog(PaPatientSchedule schedule) async {
    if (!mounted) return null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final brands = await PaBrandService.getAllBrands();
      final inventory = await PaClinicInventoryService.getInventoryByClinic(
        widget.patient.clinicId,
      );

      if (!mounted) return null;
      Navigator.of(context).pop();

      final Map<int, int> inventoryMap = {};
      for (final item in inventory) {
        final brandId = (item['brandId'] as num).toInt();
        final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
        inventoryMap[brandId] = quantity;
      }

      return await showDialog<int>(
        context: context,
        builder: (context) => _PaBrandSelectionDialog(
          brands: brands,
          inventoryMap: inventoryMap,
          selectedBrandId: schedule.brandId,
        ),
      );
    } catch (e) {
      if (!mounted) return null;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load brands: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return null;
    }
  }

  Future<void> _performToggle(
    PaPatientSchedule schedule,
    bool isDone,
    int? brandId,
  ) async {
    if (!mounted || schedule.scheduleId == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await PaPatientScheduleService.toggleIsDone(
        schedule.scheduleId!,
        isDone,
        brandId: brandId,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      _refreshSchedules();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isDone ? 'Dose marked as completed.' : 'Dose marked as pending.',
          ),
          backgroundColor:
              isDone ? Colors.green.shade600 : Colors.orange.shade600,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update dose status: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  Future<void> _rescheduleDose(PaPatientSchedule schedule) async {
    if (schedule.scheduleId == null) return;

    final initialDate = schedule.planDate != null && schedule.planDate!.isNotEmpty
        ? DateTime.tryParse(schedule.planDate!) ?? DateTime.now()
        : DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade600,
              onPrimary: Colors.white,
              onSurface: Colors.blueGrey.shade700,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final formatted =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      await PaPatientScheduleService.rescheduleDose(
        schedule.scheduleId!,
        formatted,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      _refreshSchedules();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Dose rescheduled successfully'),
          backgroundColor: Colors.green.shade600,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reschedule: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Vaccination Schedule'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshSchedules,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<PaPatientSchedule>>(
        future: _schedulesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading schedule...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          final schedules = snapshot.data ?? [];

          if (schedules.isEmpty) {
            return _buildEmptyState();
          }

          final Map<String?, List<PaPatientSchedule>> grouped = {};
          for (final schedule in schedules) {
            String? key;
            if (schedule.planDate != null && schedule.planDate!.isNotEmpty) {
              key = schedule.planDate;
            } else if (schedule.givenDate != null) {
              final date = schedule.givenDate!;
              key =
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            }
            grouped.putIfAbsent(key, () => []).add(schedule);
          }

          final sortedKeys = grouped.keys.toList()
            ..sort((a, b) {
              if (a == null && b == null) return 0;
              if (a == null) return 1;
              if (b == null) return -1;
              return a.compareTo(b);
            });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PatientHeader(
                  patient: widget.patient,
                  assistant: widget.assistant,
                ),
                const SizedBox(height: 24),
                ...sortedKeys.map((key) {
                  final items = grouped[key]!;
                  return _ScheduleGroup(
                    title: key ?? 'Pending / Not Scheduled',
                    schedules: items,
                    onToggle: _toggleIsDone,
                    onReschedule: _rescheduleDose,
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Schedule Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No vaccination schedule found for this patient',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Failed to Load Schedule',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientHeader extends StatelessWidget {
  final PaPatient patient;
  final PaAssistant assistant;

  const _PatientHeader({required this.patient, required this.assistant});

  String get _clinicName {
    final match = assistant.clinicAccess.firstWhere(
      (c) => c.clinicId == patient.clinicId,
      orElse: () => PaClinicAccess(clinicId: patient.clinicId),
    );
    return match.clinicName ?? 'Clinic ${patient.clinicId}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                patient.name.isNotEmpty
                    ? patient.name[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: Colors.blue.shade900,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.displayName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _clinicName,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  if ((patient.mobileNumber ?? '').isNotEmpty)
                    Text(
                      'Contact: ${patient.mobileNumber}',
                      style: const TextStyle(color: Colors.black45),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleGroup extends StatelessWidget {
  final String title;
  final List<PaPatientSchedule> schedules;
  final Future<void> Function(PaPatientSchedule) onToggle;
  final Future<void> Function(PaPatientSchedule) onReschedule;

  const _ScheduleGroup({
    required this.title,
    required this.schedules,
    required this.onToggle,
    required this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: schedules
                .map(
                  (schedule) => _ScheduleCard(
                    schedule: schedule,
                    onToggle: () => onToggle(schedule),
                    onReschedule: () => onReschedule(schedule),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final PaPatientSchedule schedule;
  final VoidCallback onToggle;
  final VoidCallback onReschedule;

  const _ScheduleCard({
    required this.schedule,
    required this.onToggle,
    required this.onReschedule,
  });

  String get _planDateLabel {
    if (schedule.planDate == null || schedule.planDate!.isEmpty) {
      return 'Plan date not set';
    }
    return schedule.planDate!;
  }

  String get _givenDateLabel {
    if (schedule.givenDate == null) {
      return 'Not given yet';
    }
    final date = schedule.givenDate!;
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDone = schedule.isDone;
    final doseName = schedule.dose?.name ?? 'Dose ${schedule.doseId}';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDone ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? Colors.green.shade300 : Colors.grey.shade200,
          width: isDone ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDone
                ? Colors.green.shade100.withOpacity(0.5)
                : Colors.grey.shade200,
            blurRadius: isDone ? 6 : 4,
            offset: Offset(0, isDone ? 3 : 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDone ? Colors.green.shade600 : Colors.blue.shade600,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Dose ${schedule.doseId}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  doseName,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              Switch.adaptive(
                value: isDone,
                onChanged: (_) => onToggle(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_month, size: 16, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Text(
                'Planned: $_planDateLabel',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                isDone ? Icons.check_circle : Icons.pending_actions,
                size: 16,
                color: isDone ? Colors.green.shade600 : Colors.orange.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                isDone ? 'Given: $_givenDateLabel' : 'Pending',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDone ? Colors.green.shade600 : Colors.orange.shade700,
                ),
              ),
            ],
          ),
          if (schedule.brand?.name != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.medical_services_outlined, size: 16, color: Color(0xFF2563EB)),
                const SizedBox(width: 8),
                Text(
                  'Brand: ${schedule.brand!.name}',
                  style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onReschedule,
                icon: const Icon(Icons.schedule),
                label: const Text('Reschedule'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaBrandSelectionDialog extends StatefulWidget {
  final List<PaBrand> brands;
  final Map<int, int> inventoryMap;
  final int? selectedBrandId;

  const _PaBrandSelectionDialog({
    required this.brands,
    required this.inventoryMap,
    this.selectedBrandId,
  });

  @override
  State<_PaBrandSelectionDialog> createState() => _PaBrandSelectionDialogState();
}

class _PaBrandSelectionDialogState extends State<_PaBrandSelectionDialog> {
  int? _chosenBrandId;

  @override
  void initState() {
    super.initState();
    _chosenBrandId = widget.selectedBrandId;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Select Vaccine Brand'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.brands.isEmpty)
              const Text('No brands found for this clinic.')
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: widget.brands.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final brand = widget.brands[index];
                    final quantity = widget.inventoryMap[brand.brandId] ?? 0;
                    final isSelected = _chosenBrandId == brand.brandId;

                    return ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      tileColor: isSelected ? Colors.blue.shade50 : Colors.grey.shade100,
                      leading: Radio<int>(
                        value: brand.brandId,
                        groupValue: _chosenBrandId,
                        onChanged: (value) => setState(() => _chosenBrandId = value),
                      ),
                      title: Text(brand.name),
                      subtitle: Text('Stock available: $quantity'),
                      onTap: () => setState(() => _chosenBrandId = brand.brandId),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _chosenBrandId == null ? null : () => Navigator.of(context).pop(_chosenBrandId),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
