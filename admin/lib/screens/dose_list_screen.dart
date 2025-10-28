import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../models/dose.dart';
import '../core/constants/app_colors.dart';

import 'dose_form_screen.dart';

class DoseListScreen extends StatefulWidget {
  const DoseListScreen({super.key});

  @override
  State<DoseListScreen> createState() => _DoseListScreenState();
}

class _DoseListScreenState extends State<DoseListScreen> {
  List<Dose> doses = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDoses();
  }

  Future<void> _loadDoses() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final loadedDoses = await ApiService.getDoses();
      setState(() {
        doses = loadedDoses;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _deleteDose(String doseId) async {
    try {
      await ApiService.deleteDose(doseId);
      _loadDoses(); // Reload the list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Dose deleted successfully'),
            backgroundColor: AppColors.secondary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting dose: $e'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  void _showDeleteDialog(Dose dose) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Dose'),
          content: Text('Are you sure you want to delete dose "${dose.doseId}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (dose.id != null) {
                  _deleteDose(dose.id!);
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
        title: const Text('Doses'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDoses,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primaryLight,
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
                            'Error loading doses',
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
                            onPressed: _loadDoses,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : doses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.medication_outlined,
                                size: 64,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No doses found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add your first dose to get started',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadDoses,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: doses.length,
                            itemBuilder: (context, index) {
                              final dose = doses[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 4,
                                color: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                    child: Icon(
                                      Icons.medication,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  title: Text(
                                    dose.name ?? 'Unnamed Dose',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        'Vaccine ID: ${dose.vaccineID == null || dose.vaccineID == '' ? 'Not assigned' : (dose.vaccineID is Map ? dose.vaccineID['vaccineID'] : dose.vaccineID)}',
                                        style: TextStyle(color: AppColors.textSecondary),
                                      ),
                                      if (dose.vaccine != null)
                                        Text(
                                          'Vaccine: ${dose.vaccine!.name}',
                                          style: TextStyle(color: AppColors.textSecondary),
                                        ),
                                      Text(
                                        'Age Range: ${dose.minAge}-${dose.maxAge} years',
                                        style: TextStyle(color: AppColors.textSecondary),
                                      ),
                                      Text(
                                        'Min Gap: ${dose.minGap} days',
                                        style: TextStyle(color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DoseFormScreen(
                                              dose: dose,
                                            ),
                                          ),
                                        ).then((_) => _loadDoses());
                                      } else if (value == 'delete') {
                                        _showDeleteDialog(dose);
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
              builder: (context) => const DoseFormScreen(),
            ),
          ).then((_) => _loadDoses());
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }
}
