import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants/app_colors.dart';
import '../core/controllers/auth_controller.dart';
import '../core/controllers/clinic_controller.dart';
import '../core/widgets/app_app_bar.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/app_text_field.dart';
import '../core/widgets/app_button.dart';
import '../models/clinic.dart';

class ClinicFormScreen extends StatefulWidget {
  final Clinic? clinic;
  final bool isEditMode;

  const ClinicFormScreen({
    super.key,
    this.clinic,
    this.isEditMode = false,
  });

  @override
  State<ClinicFormScreen> createState() => _ClinicFormScreenState();
}

class _ClinicFormScreenState extends State<ClinicFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _regNoController = TextEditingController();
  final _phoneController = TextEditingController();
  final _feeController = TextEditingController();
  final _logoController = TextEditingController();

  final AuthController _authController = Get.find<AuthController>();
  final ClinicController _clinicController = Get.find<ClinicController>();

  @override
  void initState() {
    super.initState();
    if (widget.isEditMode && widget.clinic != null) {
      _nameController.text = widget.clinic!.name;
      _addressController.text = widget.clinic!.address;
      _regNoController.text = widget.clinic!.regNo;
      _phoneController.text = widget.clinic!.phoneNumber;
      _feeController.text = widget.clinic!.clinicFee.toString();
      _logoController.text = widget.clinic!.logo ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _regNoController.dispose();
    _phoneController.dispose();
    _feeController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  Future<void> _saveClinic() async {
    if (!_formKey.currentState!.validate()) return;

    final doctor = _authController.currentDoctor.value;
    if (doctor == null) {
      Get.snackbar('Error', 'Doctor not found. Please login again.');
      return;
    }

    final clinic = Clinic(
      id: widget.clinic?.id ?? '',
      clinicId: widget.clinic?.clinicId ?? 0,
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      regNo: _regNoController.text.trim(),
      logo: _logoController.text.trim().isEmpty ? null : _logoController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      clinicFee: double.parse(_feeController.text.trim()),
      doctorId: doctor.id,
      isActive: true,
      isOnline: false,
      createdAt: widget.clinic?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    bool success;
    if (widget.isEditMode) {
      success = await _clinicController.updateClinic(clinic.id, clinic);
    } else {
      success = await _clinicController.createClinic(clinic);
    }

    if (success) {
      Get.back(result: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        title: widget.isEditMode ? 'Edit Clinic' : 'Add Clinic',
        actions: [
          Obx(() => _clinicController.isLoading.value
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                AppCard(
                  child: AppCardHeader(
                    title: widget.isEditMode ? 'Update Clinic Information' : 'Add Your Clinic',
                    subtitle: widget.isEditMode 
                        ? 'Update your clinic details below'
                        : 'Fill in your clinic information to get started',
                    icon: Icons.local_hospital,
                    iconColor: AppColors.primary,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                  ),
                ),

                const SizedBox(height: 24),

                // Form Fields
                AppTextField(
                  controller: _nameController,
                  label: 'Clinic Name',
                  hint: 'Enter your clinic name',
                  prefixIcon: Icons.business,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter clinic name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                AppTextField(
                  controller: _addressController,
                  label: 'Address',
                  hint: 'Enter complete clinic address',
                  prefixIcon: Icons.location_on,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter clinic address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _regNoController,
                        label: 'Registration Number',
                        hint: 'Enter registration number',
                        prefixIcon: Icons.assignment,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter registration number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hint: 'Enter phone number',
                        prefixIcon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter phone number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                AppTextField(
                  controller: _feeController,
                  label: 'Consultation Fee',
                  hint: 'Enter consultation fee',
                  prefixIcon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter consultation fee';
                    }
                    if (double.tryParse(value.trim()) == null) {
                      return 'Please enter a valid amount';
                    }
                    if (double.parse(value.trim()) < 0) {
                      return 'Fee cannot be negative';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                AppTextField(
                  controller: _logoController,
                  label: 'Logo URL (Optional)',
                  hint: 'Enter logo image URL',
                  prefixIcon: Icons.image,
                  validator: (value) {
                    return null; // Optional field
                  },
                ),

                const SizedBox(height: 32),

                // Save Button
                Obx(() => AppButton(
                  text: widget.isEditMode ? 'Update Clinic' : 'Create Clinic',
                  onPressed: _clinicController.isLoading.value ? null : _saveClinic,
                  isLoading: _clinicController.isLoading.value,
                  type: AppButtonType.primary,
                  size: AppButtonSize.large,
                  width: double.infinity,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}