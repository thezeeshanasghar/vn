import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/controllers/clinic_controller.dart';
import '../core/controllers/personal_assistant_controller.dart';
import '../core/widgets/app_button.dart';
import '../core/widgets/empty_state_widget.dart';
import '../core/widgets/loading_widget.dart';
import '../models/personal_assistant.dart';
import '../models/clinic.dart';

class _ModuleSpec {
  final String field;
  final String label;
  final IconData icon;
  final Color color;

  const _ModuleSpec({
    required this.field,
    required this.label,
    required this.icon,
    required this.color,
  });
}

const List<_ModuleSpec> _moduleSpecs = [
  _ModuleSpec(
    field: 'allowPatients',
    label: 'Patients',
    icon: Icons.people_alt_rounded,
    color: AppColors.primary,
  ),
  _ModuleSpec(
    field: 'allowSchedules',
    label: 'Schedules',
    icon: Icons.event_available_rounded,
    color: Color(0xFF7C3AED),
  ),
  _ModuleSpec(
    field: 'allowInventory',
    label: 'Inventory',
    icon: Icons.inventory_2_outlined,
    color: Color(0xFF0EA5E9),
  ),
  _ModuleSpec(
    field: 'allowAlerts',
    label: 'Alerts',
    icon: Icons.notifications_active_outlined,
    color: Color(0xFFF59E0B),
  ),
  _ModuleSpec(
    field: 'allowBilling',
    label: 'Billing',
    icon: Icons.receipt_long_outlined,
    color: Color(0xFF22C55E),
  ),
];

bool _permissionValue(PaPermissions permissions, String field) {
  switch (field) {
    case 'allowPatients':
      return permissions.allowPatients;
    case 'allowSchedules':
      return permissions.allowSchedules;
    case 'allowInventory':
      return permissions.allowInventory;
    case 'allowAlerts':
      return permissions.allowAlerts;
    case 'allowBilling':
      return permissions.allowBilling;
    default:
      return false;
  }
}

bool _clinicAccessValue(PaClinicAccess access, String field) {
  switch (field) {
    case 'allowPatients':
      return access.allowPatients;
    case 'allowSchedules':
      return access.allowSchedules;
    case 'allowInventory':
      return access.allowInventory;
    case 'allowAlerts':
      return access.allowAlerts;
    case 'allowBilling':
      return access.allowBilling;
    default:
      return false;
  }
}

PaPermissions _buildPermissionsFromToggles(Map<String, bool> toggles) {
  return PaPermissions(
    allowPatients: toggles['allowPatients'] ?? false,
    allowSchedules: toggles['allowSchedules'] ?? false,
    allowInventory: toggles['allowInventory'] ?? false,
    allowAlerts: toggles['allowAlerts'] ?? false,
    allowBilling: toggles['allowBilling'] ?? false,
  );
}

Map<String, bool> _emptyPermissionFlags() {
  return {
    'allowPatients': false,
    'allowSchedules': false,
    'allowInventory': false,
    'allowAlerts': false,
    'allowBilling': false,
  };
}

class PersonalAssistantScreen extends StatefulWidget {
  const PersonalAssistantScreen({super.key});

  @override
  State<PersonalAssistantScreen> createState() => _PersonalAssistantScreenState();
}

class _PersonalAssistantScreenState extends State<PersonalAssistantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();

  final Map<String, bool> _createModuleToggles = {
    for (final module in _moduleSpecs) module.field: false,
  };

  final Map<String, Set<int>> _createModuleClinicSelections = {
    for (final module in _moduleSpecs) module.field: <int>{},
  };

  PersonalAssistantController get _paController => Get.find<PersonalAssistantController>();
  ClinicController get _clinicController => Get.find<ClinicController>();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _resetCreateFormFields() {
    _formKey.currentState?.reset();
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _mobileController.clear();
    _passwordController.clear();
    _resetCreateModuleControls();
  }

  void _resetCreateModuleControls() {
    for (final module in _moduleSpecs) {
      _createModuleToggles[module.field] = false;
      _createModuleClinicSelections[module.field] = <int>{};
    }
  }

  bool _validateModuleSelections(Map<String, bool> toggles, Map<String, Set<int>> selections) {
    for (final module in _moduleSpecs) {
      if (toggles[module.field] == true) {
        final chosen = selections[module.field] ?? <int>{};
        if (chosen.isEmpty) {
          Get.snackbar(
            'Clinic selection required',
            'Select at least one clinic for ${module.label} access.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.error.withOpacity(0.1),
            colorText: AppColors.error,
          );
          return false;
        }
      }
    }
    return true;
  }

  List<PaClinicAccess> _buildClinicAccessFromSelections(
    Map<String, bool> toggles,
    Map<String, Set<int>> selections,
  ) {
    final Map<int, Map<String, bool>> byClinic = {};

    for (final module in _moduleSpecs) {
      if (toggles[module.field] != true) continue;
      final clinics = selections[module.field] ?? <int>{};
      for (final clinicId in clinics) {
        final entry = byClinic.putIfAbsent(
          clinicId,
          () => Map<String, bool>.from(_emptyPermissionFlags()),
        );
        entry[module.field] = true;
      }
    }

    return byClinic.entries.map((entry) {
      final flags = entry.value;
      return PaClinicAccess(
        clinicId: entry.key,
        allowPatients: flags['allowPatients'] ?? false,
        allowSchedules: flags['allowSchedules'] ?? false,
        allowInventory: flags['allowInventory'] ?? false,
        allowAlerts: flags['allowAlerts'] ?? false,
        allowBilling: flags['allowBilling'] ?? false,
      );
    }).toList();
  }

  Widget _buildModuleAccessTile({
    required _ModuleSpec module,
    required List<Clinic> clinics,
    required Map<String, bool> toggles,
    required Map<String, Set<int>> selections,
    required void Function(void Function()) updateState,
  }) {
    final isEnabled = toggles[module.field] ?? false;
    final selectedClinics = selections[module.field] ?? <int>{};

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEnabled ? module.color.withOpacity(0.08) : AppColors.grey50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEnabled ? module.color.withOpacity(0.4) : AppColors.grey200,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: module.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(module.icon, color: module.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Grant ability to manage ${module.label.toLowerCase()} module.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: isEnabled,
                activeColor: module.color,
                onChanged: (value) {
                  updateState(() {
                    toggles[module.field] = value;
                    if (!value) {
                      selections[module.field] = <int>{};
                    }
                  });
                },
              ),
            ],
          ),
          if (isEnabled) ...[
            const SizedBox(height: 14),
            if (clinics.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'No clinics available yet. Create a clinic to assign access.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: clinics.map((clinic) {
                  final isSelected = selectedClinics.contains(clinic.clinicId);
                  return FilterChip(
                    label: Text(clinic.name),
                    selected: isSelected,
                    selectedColor: module.color.withOpacity(0.18),
                    checkmarkColor: module.color,
                    onSelected: (value) {
                      updateState(() {
                        final updated = Set<int>.from(selectedClinics);
                        if (value) {
                          updated.add(clinic.clinicId);
                        } else {
                          updated.remove(clinic.clinicId);
                        }
                        selections[module.field] = updated;
                      });
                    },
                  );
                }).toList(),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    final clinics = _clinicController.clinics;
    if (clinics.isEmpty) {
      Get.snackbar(
        'Add a clinic first',
        'Create at least one clinic before assigning a personal assistant.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.warning.withOpacity(0.15),
        colorText: AppColors.warning,
      );
      return;
    }

    final hasAnyModule = _createModuleToggles.values.any((value) => value);
    if (!hasAnyModule) {
      Get.snackbar(
        'Module access required',
        'Select at least one module to grant access to the assistant.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.warning.withOpacity(0.15),
        colorText: AppColors.warning,
      );
      return;
    }

    if (!_validateModuleSelections(_createModuleToggles, _createModuleClinicSelections)) {
      return;
    }

    final permissions = _buildPermissionsFromToggles(_createModuleToggles);
    final clinicAccess = _buildClinicAccessFromSelections(
      _createModuleToggles,
      _createModuleClinicSelections,
    );

    if (clinicAccess.isEmpty) {
      Get.snackbar(
        'Clinic selection required',
        'Assign at least one clinic to the assistant.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
      return;
    }

    final success = await _paController.createAssistant(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      mobileNumber: _mobileController.text.trim().isEmpty ? null : _mobileController.text.trim(),
      permissions: permissions,
      clinicAccess: clinicAccess,
    );

    if (success) {
      setState(_resetCreateFormFields);
    }
  }

  Future<void> _openClinicAccessDialog(PersonalAssistant assistant) async {
    final clinics = _clinicController.clinics.toList();
    if (clinics.isEmpty) {
      Get.snackbar(
        'No Clinics',
        'Please create a clinic before assigning access to personal assistants.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    final Map<String, bool> moduleToggles = {
      for (final module in _moduleSpecs)
        module.field: _permissionValue(assistant.permissions, module.field),
    };

    final Map<String, Set<int>> moduleClinicSelections = {
      for (final module in _moduleSpecs)
        module.field: assistant.clinicAccess
            .where((access) => _clinicAccessValue(access, module.field))
            .map((access) => access.clinicId)
            .toSet(),
    };

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configure Module Access',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    assistant.fullName,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _moduleSpecs
                        .map((module) => _buildModuleAccessTile(
                              module: module,
                              clinics: clinics,
                              toggles: moduleToggles,
                              selections: moduleClinicSelections,
                              updateState: setState,
                            ))
                        .toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final hasAnyModule = moduleToggles.values.any((value) => value);
                    if (hasAnyModule &&
                        !_validateModuleSelections(moduleToggles, moduleClinicSelections)) {
                      return;
                    }

                    final permissions = _buildPermissionsFromToggles(moduleToggles);
                    final clinicAccess = _buildClinicAccessFromSelections(
                      moduleToggles,
                      moduleClinicSelections,
                    );

                    Navigator.of(context).pop();

                    await _paController.updatePermissions(assistant, permissions);
                    await _paController.updateClinicAccess(assistant, clinicAccess);
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCreationForm(BoxConstraints constraints) {
    final isWideLayout = constraints.maxWidth > 900;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add Personal Assistant', style: AppTextStyles.h3),
                    const SizedBox(height: 4),
                    Text(
                      'Invite your personal assistant and control their access permissions.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Obx(() => _paController.isSaving.value
                    ? const CircularProgressIndicator()
                    : const SizedBox(width: 0, height: 0)),
              ],
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, size) {
                final double fieldWidth = size.maxWidth;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: isWideLayout ? (fieldWidth - 16) / 2 : fieldWidth,
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'First name is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: isWideLayout ? (fieldWidth - 16) / 2 : fieldWidth,
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Last name is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: isWideLayout ? (fieldWidth - 16) / 2 : fieldWidth,
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!GetUtils.isEmail(value.trim())) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: isWideLayout ? (fieldWidth - 16) / 2 : fieldWidth,
                      child: TextFormField(
                        controller: _mobileController,
                        decoration: const InputDecoration(
                          labelText: 'Mobile Number (optional)',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: isWideLayout ? (fieldWidth - 16) / 2 : fieldWidth,
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Temporary Password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Password is required';
                          }
                          if (value.trim().length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Obx(() {
              final clinics = _clinicController.clinics.toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Module Access & Clinics',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose the modules you want to delegate and map them to specific clinics.',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ..._moduleSpecs.map((module) {
                    return _buildModuleAccessTile(
                      module: module,
                      clinics: clinics,
                      toggles: _createModuleToggles,
                      selections: _createModuleClinicSelections,
                      updateState: setState,
                    );
                  }).toList(),
                ],
              );
            }),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: Obx(() => AppButton(
                    text: 'Add Assistant',
                    onPressed: _handleCreate,
                    type: AppButtonType.primary,
                    icon: Icons.person_add_alt_1,
                    isLoading: _paController.isSaving.value,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssistantsList() {
    return Obx(() {
      if (_paController.isLoading.value) {
        return const LoadingWidget(message: 'Loading personal assistants...');
      }

      if (_paController.assistants.isEmpty) {
        return const EmptyStateWidget(
          title: 'No Personal Assistants Yet',
          message: 'Add your first personal assistant using the form above.',
          icon: Icons.group_add_outlined,
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _paController.assistants.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final assistant = _paController.assistants[index];
          return _AssistantCard(
            assistant: assistant,
            onManageAccess: () => _openClinicAccessDialog(assistant),
            onDeactivate: () async {
              final confirm = await Get.dialog<bool>(
                AlertDialog(
                  title: const Text('Deactivate Assistant'),
                  content: Text('Are you sure you want to deactivate ${assistant.fullName}?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Get.back(result: true),
                      style: TextButton.styleFrom(foregroundColor: AppColors.error),
                      child: const Text('Deactivate'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await _paController.deactivateAssistant(assistant);
              }
            },
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideLayout = constraints.maxWidth > 1100;

        if (isWideLayout) {
          final creationWidth = constraints.maxWidth * 0.34;
          final creationConstraints = BoxConstraints(maxWidth: creationWidth);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Personal Assistant Management', style: AppTextStyles.h2),
                const SizedBox(height: 6),
                Text(
                  'Add, manage, and control access for your personal assistants across clinics.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: creationWidth,
                      child: _buildCreationForm(creationConstraints),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your Personal Assistants', style: AppTextStyles.h3),
                          const SizedBox(height: 16),
                          _buildAssistantsList(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Personal Assistant Management', style: AppTextStyles.h2),
              const SizedBox(height: 6),
              Text(
                'Add, manage, and control access for your personal assistants across clinics.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              _buildCreationForm(constraints),
              const SizedBox(height: 32),
              Text('Your Personal Assistants', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              _buildAssistantsList(),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

class _AssistantCard extends StatelessWidget {
  final PersonalAssistant assistant;
  final VoidCallback onManageAccess;
  final VoidCallback onDeactivate;

  const _AssistantCard({
    required this.assistant,
    required this.onManageAccess,
    required this.onDeactivate,
  });

  @override
  Widget build(BuildContext context) {
    final enabledModules = _moduleSpecs
        .where((module) => _permissionValue(assistant.permissions, module.field))
        .toList();
    final hasModules = enabledModules.isNotEmpty;

    final clinicEntries = assistant.clinicAccess
        .where((access) => _moduleSpecs.any((module) => _clinicAccessValue(access, module.field)))
        .toList();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFF9FBFF), Color(0xFFE3ECFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    assistant.firstName.isNotEmpty
                        ? assistant.firstName[0].toUpperCase()
                        : assistant.email.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              assistant.fullName,
                              style: AppTextStyles.h4,
                            ),
                          ),
                          Chip(
                            avatar: Icon(
                              assistant.isActive ? Icons.verified : Icons.pause_circle_outline,
                              size: 16,
                              color: assistant.isActive ? Colors.green : Colors.orange,
                            ),
                            label: Text(
                              assistant.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color: assistant.isActive ? Colors.green.shade700 : Colors.orange.shade700,
                              ),
                            ),
                            backgroundColor: assistant.isActive
                                ? Colors.green.shade50
                                : Colors.orange.shade50,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(assistant.email, style: AppTextStyles.bodySmall),
                      if ((assistant.mobileNumber ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            assistant.mobileNumber!,
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Module Access',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (hasModules)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: enabledModules
                          .map(
                            (module) => Chip(
                              label: Text(module.label),
                              avatar: Icon(module.icon, size: 16, color: module.color),
                              backgroundColor: module.color.withOpacity(0.12),
                              labelStyle: TextStyle(
                                color: module.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                          .toList(),
                    )
                  else
                    Text(
                      'No modules granted yet.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'Clinic Permissions',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (clinicEntries.isEmpty)
                    Text(
                      'No clinics assigned yet. Use "Manage Access" to map modules to clinics.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    )
                  else
                    Column(
                      children: clinicEntries.map((access) {
                        final clinicModules = _moduleSpecs
                            .where((module) => _clinicAccessValue(access, module.field))
                            .toList();
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.grey50,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.grey200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      access.clinicName ?? 'Clinic ${access.clinicId}',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    if (clinicModules.isEmpty)
                                      Text(
                                        'No modules assigned for this clinic.',
                                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                      )
                                    else
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: clinicModules
                                              .map(
                                                (module) => Chip(
                                                  label: Text(module.label),
                                                  backgroundColor: module.color.withOpacity(0.15),
                                                  labelStyle: TextStyle(
                                                  color: module.color,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: onManageAccess,
                    icon: const Icon(Icons.tune, size: 18),
                    label: const Text('Manage Access'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onDeactivate,
                icon: const Icon(Icons.person_off_outlined),
                label: const Text('Deactivate Assistant'),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

