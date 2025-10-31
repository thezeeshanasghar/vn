import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../models/vaccine.dart';
import '../core/constants/app_colors.dart';

import 'vaccine_form_screen.dart';
import 'vaccine_doses_screen.dart';

class VaccineListScreen extends StatefulWidget {
  const VaccineListScreen({super.key});

  @override
  State<VaccineListScreen> createState() => _VaccineListScreenState();
}

class _VaccineListScreenState extends State<VaccineListScreen> {
  List<Vaccine> vaccines = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVaccines();
  }

  Future<void> _loadVaccines() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final loadedVaccines = await ApiService.getVaccines();
      setState(() {
        vaccines = loadedVaccines;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _deleteVaccine(String vaccineId) async {
    try {
      await ApiService.deleteVaccine(vaccineId);
      _loadVaccines(); // Reload the list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Vaccine deleted successfully'),
            backgroundColor: AppColors.secondary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting vaccine: $e'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  void _showDeleteDialog(Vaccine vaccine) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Vaccine'),
          content: Text('Are you sure you want to delete "${vaccine.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (vaccine.id != null) {
                  _deleteVaccine(vaccine.id!);
                }
              },
              child: Text('Delete', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaccines'),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVaccines,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.secondary,
              AppColors.secondaryLight,
              AppColors.white,
            ],
            stops: const [0.0, 0.1, 0.1],
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
              : errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading vaccines',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            errorMessage!,
                            style: TextStyle(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadVaccines,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : vaccines.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.vaccines_outlined,
                                size: 64,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No vaccines found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add your first vaccine to get started',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadVaccines,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: vaccines.length,
                            itemBuilder: (context, index) {
                              final vaccine = vaccines[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 4,
                                color: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: vaccine.validity
                                                ? AppColors.secondary.withValues(alpha: 0.1)
                                                : AppColors.primary.withValues(alpha: 0.1),
                                            child: Icon(
                                              Icons.vaccines,
                                              color: vaccine.validity
                                                  ? AppColors.secondary
                                                  : AppColors.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  vaccine.name,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'ID: ${vaccine.vaccineID}',
                                                  style: TextStyle(color: AppColors.textSecondary),
                                                ),
                                                Text(
                                                  'Age Range: ${vaccine.minAge}-${vaccine.maxAge} years',
                                                  style: TextStyle(color: AppColors.textSecondary),
                                                ),
                                                Text(
                                                  'Status: ${vaccine.validity ? "Valid" : "Invalid"}',
                                                  style: TextStyle(
                                                    color: vaccine.validity
                                                        ? AppColors.secondary
                                                        : AppColors.primary,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                            onSelected: (value) {
                                              if (value == 'edit') {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => VaccineFormScreen(
                                                      vaccine: vaccine,
                                                    ),
                                                  ),
                                                ).then((_) => _loadVaccines());
                                              } else if (value == 'delete') {
                                                _showDeleteDialog(vaccine);
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit, color: AppColors.primary),
                                                    const SizedBox(width: 8),
                                                    Text('Edit', style: TextStyle(color: AppColors.textPrimary)),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete, color: AppColors.primary),
                                                    const SizedBox(width: 8),
                                                    Text('Delete', style: TextStyle(color: AppColors.textPrimary)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => VaccineDosesScreen(
                                                  vaccine: vaccine,
                                                ),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.medication, size: 18),
                                          label: const Text('Manage Doses'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: AppColors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VaccineFormScreen(),
            ),
          ).then((_) => _loadVaccines());
        },
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }
}
