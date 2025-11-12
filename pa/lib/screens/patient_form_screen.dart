import 'package:flutter/material.dart';

import '../core/services/patient_service.dart';
import '../models/assistant.dart';
import '../models/patient.dart';
import '../utils/pakistani_cities.dart';

class PaPatientFormScreen extends StatefulWidget {
  final PaAssistant assistant;
  final List<PaClinicAccess> patientClinics;
  final PaPatient? existing;
  final int? initialClinicId;

  const PaPatientFormScreen({
    super.key,
    required this.assistant,
    required this.patientClinics,
    this.existing,
    this.initialClinicId,
  });

  @override
  State<PaPatientFormScreen> createState() => _PaPatientFormScreenState();
}

class _PaPatientFormScreenState extends State<PaPatientFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _fatherName = TextEditingController();
  final _email = TextEditingController();
  final _cnic = TextEditingController();
  final _mobile = TextEditingController();
  final _address = TextEditingController();
  final _medicalHistory = TextEditingController();
  final _allergies = TextEditingController();
  final _emergencyName = TextEditingController();
  final _emergencyRelation = TextEditingController();
  final _emergencyPhone = TextEditingController();

  String _gender = 'Male';
  DateTime? _dob;
  String? _selectedCity;
  String? _selectedBloodGroup;
  int? _selectedClinicId;
  bool _isActive = true;
  bool _saving = false;

  final PaPatientService _service = PaPatientService();

  List<PaClinicAccess> get _availableClinicAccess => widget.patientClinics
      .where((access) => access.allowPatients)
      .toList();

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _name.text = existing.name;
      _fatherName.text = existing.fatherName ?? '';
      _email.text = existing.email ?? '';
      _cnic.text = existing.cnic ?? '';
      _mobile.text = existing.mobileNumber ?? '';
      _address.text = existing.address ?? '';
      _medicalHistory.text = existing.medicalHistory ?? '';
      _allergies.text = existing.allergies ?? '';
      _emergencyName.text = existing.emergencyContact?.name ?? '';
      _emergencyRelation.text = existing.emergencyContact?.relation ?? '';
      _emergencyPhone.text = existing.emergencyContact?.phone ?? '';
      _gender = existing.gender;
      _dob = existing.dateOfBirth;
      _selectedCity = existing.city;
      _selectedBloodGroup = existing.bloodGroup;
      _isActive = existing.isActive;
      _selectedClinicId = existing.clinicId;
    } else {
      _selectedClinicId = widget.initialClinicId ??
          (_availableClinicAccess.isNotEmpty
              ? _availableClinicAccess.first.clinicId
              : null);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _fatherName.dispose();
    _email.dispose();
    _cnic.dispose();
    _mobile.dispose();
    _address.dispose();
    _medicalHistory.dispose();
    _allergies.dispose();
    _emergencyName.dispose();
    _emergencyRelation.dispose();
    _emergencyPhone.dispose();
    super.dispose();
  }

  bool _isValidCnic(String value) {
    final clean = value.replaceAll(RegExp(r'[^0-9]'), '');
    return clean.length == 13;
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initial = _dob ?? DateTime(now.year - 1, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    if (picked != null) {
      setState(() => _dob = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dob == null) {
      _showSnack('Select Date of Birth', true);
      return;
    }
    if (_selectedCity == null || _selectedCity!.isEmpty) {
      _showSnack('Select a city', true);
      return;
    }
    if (_selectedClinicId == null) {
      _showSnack('Select a clinic to continue', true);
      return;
    }

    setState(() => _saving = true);

    try {
      final patient = PaPatient(
        patientId: widget.existing?.patientId,
        name: _name.text.trim(),
        fatherName: _fatherName.text.trim().isEmpty ? null : _fatherName.text.trim(),
        gender: _gender,
        dateOfBirth: _dob!,
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        cnic: _cnic.text.trim(),
        mobileNumber: _mobile.text.trim().isEmpty ? null : _mobile.text.trim(),
        city: _selectedCity,
        address: _address.text.trim().isEmpty ? null : _address.text.trim(),
        medicalHistory:
            _medicalHistory.text.trim().isEmpty ? null : _medicalHistory.text.trim(),
        allergies: _allergies.text.trim().isEmpty ? null : _allergies.text.trim(),
        bloodGroup: _selectedBloodGroup,
        clinicId: _selectedClinicId!,
        doctorId: widget.assistant.doctorId,
        isActive: _isActive,
        emergencyContact: (_emergencyName.text.trim().isEmpty &&
                _emergencyPhone.text.trim().isEmpty)
            ? null
            : PaEmergencyContact(
                name: _emergencyName.text.trim().isEmpty
                    ? null
                    : _emergencyName.text.trim(),
                relation: _emergencyRelation.text.trim().isEmpty
                    ? null
                    : _emergencyRelation.text.trim(),
                phone: _emergencyPhone.text.trim().isEmpty
                    ? null
                    : _emergencyPhone.text.trim(),
              ),
      );

      if (widget.existing == null) {
        await _service.createPatient(patient);
        if (mounted) {
          _showSnack('Patient created successfully', false);
          Navigator.of(context).pop(true);
        }
      } else {
        await _service.updatePatient(widget.existing!.patientId!, patient);
        if (mounted) {
          _showSnack('Patient updated successfully', false);
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString(), true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clinicOptions = _availableClinicAccess;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Add Patient' : 'Edit Patient'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Basic Information'),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _name,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _fatherName,
                  label: 'Father/Guardian Name',
                  icon: Icons.family_restroom_outlined,
                ),
                const SizedBox(height: 16),
                _buildGenderSelector(),
                const SizedBox(height: 16),
                _buildDobPicker(),
                const SizedBox(height: 16),
                _buildCityDropdown(),
                const SizedBox(height: 16),
                _buildClinicDropdown(clinicOptions),
                const SizedBox(height: 24),
                _buildSectionTitle('Contact Details'),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _email,
                  label: 'Email (optional)',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _mobile,
                  label: 'Mobile Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _cnic,
                  label: 'CNIC',
                  icon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'CNIC is required';
                    }
                    if (!_isValidCnic(value)) {
                      return 'Enter a valid 13-digit CNIC';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _address,
                  label: 'Address',
                  icon: Icons.home_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Medical Details'),
                const SizedBox(height: 12),
                _buildBloodGroupDropdown(),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _medicalHistory,
                  label: 'Medical History',
                  icon: Icons.description_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _allergies,
                  label: 'Allergies',
                  icon: Icons.warning_amber_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Emergency Contact'),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _emergencyName,
                  label: 'Contact Name',
                  icon: Icons.person_pin_circle_outlined,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emergencyRelation,
                  label: 'Relation',
                  icon: Icons.group_outlined,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emergencyPhone,
                  label: 'Phone Number',
                  icon: Icons.phone_in_talk_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                SwitchListTile.adaptive(
                  value: _isActive,
                  title: const Text('Mark as Active'),
                  subtitle: const Text('Inactive patients will be hidden from everyday lists'),
                  onChanged: (value) => setState(() => _isActive = value),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.save_rounded),
                    label: Text(widget.existing == null ? 'Save Patient' : 'Update Patient'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildGenderSelector() {
    final genders = ['Male', 'Female', 'Other'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          children: genders.map((gender) {
            final selected = _gender == gender;
            return ChoiceChip(
              label: Text(gender),
              selected: selected,
              onSelected: (value) {
                if (value) setState(() => _gender = gender);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDobPicker() {
    final label = _dob == null
        ? 'Select Date of Birth'
        : '${_dob!.day.toString().padLeft(2, '0')}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.year}';
    return OutlinedButton.icon(
      onPressed: _pickDob,
      icon: const Icon(Icons.cake_outlined),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget _buildCityDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCity,
      items: pakistaniCities
          .map((city) => DropdownMenuItem(value: city, child: Text(city)))
          .toList(),
    onChanged: (value) => setState(() => _selectedCity = value),
      decoration: InputDecoration(
        labelText: 'City',
        prefixIcon: const Icon(Icons.location_city_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildBloodGroupDropdown() {
    const groups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    return DropdownButtonFormField<String>(
      value: _selectedBloodGroup,
      items: groups
          .map((group) => DropdownMenuItem(value: group, child: Text(group)))
          .toList(),
      onChanged: (value) => setState(() => _selectedBloodGroup = value),
      decoration: InputDecoration(
        labelText: 'Blood Group',
        prefixIcon: const Icon(Icons.bloodtype_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildClinicDropdown(List<PaClinicAccess> clinics) {
    return DropdownButtonFormField<int>(
      value: _selectedClinicId,
      hint: const Text('Select Clinic'),
      items: clinics
          .map(
            (clinic) => DropdownMenuItem<int>(
              value: clinic.clinicId,
              child: Text(clinic.clinicName ?? 'Clinic ${clinic.clinicId}'),
            ),
          )
          .toList(),
      onChanged: (value) => setState(() => _selectedClinicId = value),
      decoration: InputDecoration(
        labelText: 'Clinic',
        prefixIcon: const Icon(Icons.local_hospital_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) => value == null ? 'Please select a clinic' : null,
    );
  }
}


