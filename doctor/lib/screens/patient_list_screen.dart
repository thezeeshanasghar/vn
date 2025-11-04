import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/patient_service.dart';
import 'patient_form_screen.dart';
import 'patient_schedule_screen.dart';

class PatientListScreen extends StatefulWidget {
  final int doctorId;
  final int clinicId;
  const PatientListScreen({super.key, required this.doctorId, required this.clinicId});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  List<Patient> _patients = [];
  bool _loading = true;
  String _search = '';
  bool? _activeOnly = null;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final list = await PatientService.getPatients(
        doctorId: widget.doctorId,
        clinicId: widget.clinicId,
        search: _search.isEmpty ? null : _search,
        isActive: _activeOnly,
      );
      setState(() => _patients = list);
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to Load Patients', 'Unable to fetch patients: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _openForm({Patient? patient}) async {
    final saved = await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PatientFormScreen(
        doctorId: widget.doctorId,
        clinicId: widget.clinicId,
        existing: patient,
      ),
    ));
    if (saved == true) {
      _fetch();
      // Notify parent to refresh patient counts
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient list updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Patients',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade700,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _fetch,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Patient'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 8,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12.0 : 16.0,
            vertical: 12.0,
          ),
          child: Column(
            children: [
              // Search and Filter Card
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 14.0 : 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.search, color: Colors.blue.shade600, size: 20),
                        SizedBox(width: isSmallScreen ? 8 : 12),
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              setState(() => _search = value);
                              _fetch();
                            },
                            decoration: InputDecoration(
                              hintText: 'Search patients...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 10 : 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 12 : 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButton<bool?>(
                              value: _activeOnly,
                              underline: const SizedBox(),
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem<bool?>(value: null, child: Text('All Patients')),
                                DropdownMenuItem<bool?>(value: true, child: Text('Active Only')),
                                DropdownMenuItem<bool?>(value: false, child: Text('Inactive Only')),
                              ],
                              onChanged: (v) {
                                setState(() => _activeOnly = v);
                                _fetch();
                              },
                              style: TextStyle(
                                fontSize: isSmallScreen ? 13 : 14,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: isSmallScreen ? 12 : 16),
              
              // Patients List
              Expanded(
                child: _loading
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Loading patients...'),
                          ],
                        ),
                      )
                    : _patients.isEmpty
                        ? Center(
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
                                    Icons.people_outline,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'No patients found',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add your first patient to get started',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: _patients.length,
                            separatorBuilder: (_, __) => SizedBox(height: isSmallScreen ? 10 : 12),
                            padding: EdgeInsets.only(bottom: 80), // Space for FAB
                            itemBuilder: (context, i) {
                              final p = _patients[i];
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.08),
                                      blurRadius: 15,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(isSmallScreen ? 14.0 : 16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Top Row: Avatar, Info, Menu
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Avatar
                                          Container(
                                            width: isSmallScreen ? 60 : 64,
                                            height: isSmallScreen ? 60 : 64,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [Colors.blue.shade400, Colors.blue.shade600],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.blue.withOpacity(0.3),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                              size: 28,
                                            ),
                                          ),
                                          SizedBox(width: isSmallScreen ? 12 : 14),
                                          
                                          // Patient Info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Name
                                                Text(
                                                  p.name,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: isSmallScreen ? 16 : 17,
                                                    color: Colors.grey.shade800,
                                                    letterSpacing: -0.3,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: isSmallScreen ? 6 : 8),
                                                
                                                // Gender and City
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.badge_outlined,
                                                      size: 14,
                                                      color: Colors.grey.shade600,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Flexible(
                                                      child: Text(
                                                        p.gender,
                                                        style: TextStyle(
                                                          fontSize: isSmallScreen ? 12 : 13,
                                                          color: Colors.grey.shade600,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    if (p.city != null && p.city!.isNotEmpty) ...[
                                                      SizedBox(width: 6),
                                                      Container(
                                                        width: 3,
                                                        height: 3,
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey.shade400,
                                                          shape: BoxShape.circle,
                                                        ),
                                                      ),
                                                      SizedBox(width: 6),
                                                      Icon(
                                                        Icons.location_on_outlined,
                                                        size: 13,
                                                        color: Colors.grey.shade600,
                                                      ),
                                                      SizedBox(width: 3),
                                                      Flexible(
                                                        child: Text(
                                                          p.city!,
                                                          style: TextStyle(
                                                            fontSize: isSmallScreen ? 12 : 13,
                                                            color: Colors.grey.shade600,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                SizedBox(height: isSmallScreen ? 6 : 8),
                                                
                                                // Status Badge
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: isSmallScreen ? 8 : 10,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: p.isActive ? Colors.green.shade50 : Colors.red.shade50,
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(
                                                      color: p.isActive ? Colors.green.shade200 : Colors.red.shade200,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        width: 6,
                                                        height: 6,
                                                        decoration: BoxDecoration(
                                                          color: p.isActive ? Colors.green.shade600 : Colors.red.shade600,
                                                          shape: BoxShape.circle,
                                                        ),
                                                      ),
                                                      SizedBox(width: 5),
                                                      Text(
                                                        p.isActive ? 'Active' : 'Inactive',
                                                        style: TextStyle(
                                                          color: p.isActive ? Colors.green.shade700 : Colors.red.shade700,
                                                          fontSize: isSmallScreen ? 11 : 12,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          
                                          SizedBox(width: 8),
                                          
                                          // Menu Button
                                          PopupMenuButton<String>(
                                            icon: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade50,
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(color: Colors.grey.shade200),
                                              ),
                                              child: Icon(
                                                Icons.more_vert,
                                                color: Colors.grey.shade600,
                                                size: 18,
                                              ),
                                            ),
                                            onSelected: (value) async {
                                              if (value == 'edit') {
                                                await _openForm(patient: p);
                                              } else if (value == 'delete' && p.patientId != null) {
                                                final ok = await showDialog<bool>(
                                                  context: context,
                                                  builder: (_) => AlertDialog(
                                                    title: const Text('Delete Patient'),
                                                    content: Text('Are you sure you want to delete ${p.name}?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context, false),
                                                        child: const Text('Cancel'),
                                                      ),
                                                      FilledButton(
                                                        onPressed: () => Navigator.pop(context, true),
                                                        style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                                        child: const Text('Delete'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (ok == true) {
                                                  try {
                                                    await PatientService.deletePatient(p.patientId!);
                                                    _fetch();
                                                    if (mounted) {
                                                      _showSuccessDialog(
                                                        'Patient Deleted Successfully!',
                                                        '${p.name} has been removed from your patient list.',
                                                      );
                                                    }
                                                  } catch (e) {
                                                    if (mounted) {
                                                      _showErrorDialog(
                                                        'Delete Failed',
                                                        'Failed to delete patient: ${e.toString()}',
                                                      );
                                                    }
                                                  }
                                                }
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit, size: 20),
                                                    SizedBox(width: 8),
                                                    Text('Edit'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                                    SizedBox(width: 8),
                                                    Text('Delete', style: TextStyle(color: Colors.red)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      
                                      SizedBox(height: isSmallScreen ? 12 : 14),
                                      
                                      // Divider
                                      Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: Colors.grey.shade200,
                                      ),
                                      
                                      SizedBox(height: isSmallScreen ? 12 : 14),
                                      
                                      // Schedule Button
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) => PatientScheduleScreen(
                                                  patient: p,
                                                  doctorId: widget.doctorId,
                                                ),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.medical_services, size: 18),
                                          label: Text(
                                            'View Vaccine Schedule',
                                            style: TextStyle(
                                              fontSize: isSmallScreen ? 13 : 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue.shade600,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                              vertical: isSmallScreen ? 12 : 14,
                                              horizontal: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


