import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/services/patient_service.dart';
import '../models/assistant.dart';
import '../models/patient.dart';
import 'patient_form_screen.dart';
import 'patient_schedule_screen.dart';

class PaPatientListScreen extends StatefulWidget {
  final PaAssistant assistant;

  const PaPatientListScreen({super.key, required this.assistant});

  @override
  State<PaPatientListScreen> createState() => _PaPatientListScreenState();
}

class _PaPatientListScreenState extends State<PaPatientListScreen> {
  final _service = PaPatientService();
  final _searchController = TextEditingController();

  List<PaPatient> _patients = [];
  bool _loading = true;
  int? _selectedClinicId;
  bool? _activeFilter;

  final DateFormat _dateFormat = DateFormat('d MMM, yyyy');

  List<PaClinicAccess> get _patientClinicAccess => widget.assistant.clinicAccess
      .where((access) => access.allowPatients)
      .toList();

  @override
  void initState() {
    super.initState();
    if (_patientClinicAccess.length == 1) {
      _selectedClinicId = _patientClinicAccess.first.clinicId;
    }
    _fetchPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPatients() async {
    setState(() => _loading = true);
    try {
      final results = await _service.getPatients(
        paId: widget.assistant.paId!,
        clinicId: _selectedClinicId,
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
        isActive: _activeFilter,
      );
      if (mounted) {
        setState(() => _patients = results);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load patients: $e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openForm({PaPatient? existing}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaPatientFormScreen(
          assistant: widget.assistant,
          patientClinics: _patientClinicAccess,
          existing: existing,
          initialClinicId: existing?.clinicId ?? _selectedClinicId,
        ),
      ),
    );

    if (result == true) {
      _fetchPatients();
    }
  }

  Future<void> _openSchedule(PaPatient patient) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaPatientScheduleScreen(
          assistant: widget.assistant,
          patient: patient,
        ),
      ),
    );
    _fetchPatients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _fetchPatients,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _patientClinicAccess.isEmpty ? null : () => _openForm(),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Patient'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildFilters(),
              const SizedBox(height: 16),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _patients.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _fetchPatients,
                            child: ListView.separated(
                              itemCount: _patients.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final patient = _patients[index];
                                return _buildPatientCard(patient);
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name, CNIC, phone or email',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (_) => _fetchPatients(),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 150,
                  child: DropdownButtonFormField<bool?>(
                    value: _activeFilter,
                    items: const [
                      DropdownMenuItem<bool?>(
                        value: null,
                        child: Text('All'),
                      ),
                      DropdownMenuItem<bool?>(
                        value: true,
                        child: Text('Active'),
                      ),
                      DropdownMenuItem<bool?>(
                        value: false,
                        child: Text('Inactive'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _activeFilter = value);
                      _fetchPatients();
                    },
                    decoration: InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int?>(
              value: _selectedClinicId,
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('All Clinics'),
                ),
                ..._patientClinicAccess.map(
                  (access) => DropdownMenuItem<int?>(
                    value: access.clinicId,
                    child: Text(access.clinicName ?? 'Clinic ${access.clinicId}'),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedClinicId = value);
                _fetchPatients();
              },
              decoration: InputDecoration(
                labelText: 'Clinic',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.local_hospital_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.people_outline, size: 64, color: Colors.blueGrey),
          SizedBox(height: 16),
          Text(
            'No patients found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Use the Add button below to create a new patient.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(PaPatient patient) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openSchedule(patient),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.blueGrey.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade400,
                          Colors.blue.shade600,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        patient.name.isNotEmpty
                            ? patient.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    patient.displayName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined, size: 14),
                                      const SizedBox(width: 6),
                                      Text(
                                        'DOB: ${_dateFormat.format(patient.dateOfBirth)}',
                                        style: TextStyle(color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                  if (patient.cnic != null && patient.cnic!.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.badge_outlined, size: 14),
                                        const SizedBox(width: 6),
                                        Text(
                                          patient.cnic!,
                                          style: TextStyle(color: Colors.grey.shade600),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Chip(
                                  label: Text(patient.isActive ? 'Active' : 'Inactive'),
                                  backgroundColor: patient.isActive
                                      ? Colors.green.shade50
                                      : Colors.red.shade50,
                                  labelStyle: TextStyle(
                                    color: patient.isActive
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _openForm(existing: patient);
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Text('Edit patient'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (patient.mobileNumber != null && patient.mobileNumber!.isNotEmpty)
                    _buildInfoChip(
                      icon: Icons.phone_outlined,
                      label: patient.mobileNumber!,
                    ),
                  if (patient.email != null && patient.email!.isNotEmpty)
                    _buildInfoChip(
                      icon: Icons.email_outlined,
                      label: patient.email!,
                    ),
                  _buildInfoChip(
                    icon: Icons.local_hospital_outlined,
                    label: _clinicName(patient.clinicId),
                  ),
                  if (patient.city != null && patient.city!.isNotEmpty)
                    _buildInfoChip(
                      icon: Icons.location_on_outlined,
                      label: patient.city!,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: () => _openSchedule(patient),
                    icon: const Icon(Icons.schedule),
                    label: const Text('View Schedule'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _openForm(existing: patient),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Details'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.blue.shade700),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _clinicName(int clinicId) {
    final access = _patientClinicAccess.firstWhere(
      (clinic) => clinic.clinicId == clinicId,
      orElse: () => PaClinicAccess(clinicId: clinicId),
    );
    return access.clinicName ?? 'Clinic $clinicId';
  }
}

