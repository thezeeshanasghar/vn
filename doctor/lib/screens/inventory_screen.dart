import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/controllers/auth_controller.dart';
import '../core/controllers/clinic_controller.dart';
import '../core/widgets/loading_widget.dart';
import '../core/widgets/empty_state_widget.dart';
import '../services/clinic_inventory_service.dart';
import '../services/clinic_brand_price_service.dart';
import '../models/clinic.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final ClinicController _clinicController = Get.find<ClinicController>();
  
  List<Map<String, dynamic>> _inventory = [];
  Clinic? _selectedClinic;
  bool _loading = true;
  String? _error;
  Map<int, TextEditingController> _priceControllers = {};
  Map<int, bool> _isEditingPrice = {};
  Map<int, bool> _isSavingPrice = {};

  @override
  void initState() {
    super.initState();
    _selectDefaultClinic();
    
    // Listen to clinic changes
    ever(_clinicController.clinics, (clinics) {
      if (clinics.isNotEmpty && _selectedClinic == null) {
        _selectedClinic = clinics.first;
        _loadInventory();
      } else if (clinics.isNotEmpty && _selectedClinic != null) {
        // Check if selected clinic still exists
        final exists = clinics.any((c) => c.clinicId == _selectedClinic!.clinicId);
        if (!exists) {
          _selectedClinic = clinics.first;
          _loadInventory();
        }
      }
    });
  }

  void _selectDefaultClinic() {
    if (_clinicController.clinics.isNotEmpty) {
      _selectedClinic = _clinicController.clinics.first;
      _loadInventory();
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _loadInventory() async {
    if (_selectedClinic == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final inventory = await ClinicInventoryService.getInventoryByClinic(_selectedClinic!.clinicId!);
      
      // Initialize price controllers
      _priceControllers.clear();
      _isEditingPrice.clear();
      _isSavingPrice.clear();
      
      for (final item in inventory) {
        final brandId = (item['brandId'] as num).toInt();
        final brandAmount = ((item['brandAmount'] as num?) ?? 0).toDouble();
        _priceControllers[brandId] = TextEditingController(
          text: brandAmount.toStringAsFixed(0),
        );
        _isEditingPrice[brandId] = false;
        _isSavingPrice[brandId] = false;
      }
      
      setState(() {
        _inventory = inventory;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _savePrice(int brandId) async {
    if (_selectedClinic == null) return;
    
    final controller = _priceControllers[brandId];
    if (controller == null) return;
    
    final priceText = controller.text.trim();
    if (priceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid price'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final price = double.tryParse(priceText);
    if (price == null || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid positive number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isSavingPrice[brandId] = true;
    });
    
    try {
      final success = await ClinicBrandPriceService.updatePrice(
        clinicId: _selectedClinic!.clinicId!,
        brandId: brandId,
        price: price,
      );
      
      if (success) {
        setState(() {
          _isEditingPrice[brandId] = false;
          // Update the inventory item with new price
          final index = _inventory.indexWhere((item) => (item['brandId'] as num).toInt() == brandId);
          if (index != -1) {
            _inventory[index]['brandAmount'] = price;
          }
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Price updated successfully'),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } else {
        throw Exception('Failed to update price');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update price: ${e.toString()}'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingPrice[brandId] = false;
        });
      }
    }
  }

  void _cancelEditPrice(int brandId) {
    final item = _inventory.firstWhere(
      (item) => (item['brandId'] as num).toInt() == brandId,
      orElse: () => {},
    );
    
    final brandAmount = ((item['brandAmount'] as num?) ?? 0).toDouble();
    _priceControllers[brandId]?.text = brandAmount.toStringAsFixed(0);
    
    setState(() {
      _isEditingPrice[brandId] = false;
    });
  }

  @override
  void dispose() {
    for (final controller in _priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const LoadingWidget(message: 'Loading inventory...');
    }

    if (_error != null) {
      return EmptyStateWidget(
        icon: Icons.error_outline,
        title: 'Error Loading Inventory',
        message: _error!,
        buttonText: 'Retry',
        onButtonTap: _loadInventory,
      );
    }

    return Obx(() {
      if (_clinicController.clinics.isEmpty) {
        return EmptyStateWidget(
          icon: Icons.local_hospital_outlined,
          title: 'No Clinics Found',
          message: 'Please add a clinic first to view inventory',
        );
      }

      return RefreshIndicator(
        onRefresh: _loadInventory,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 400;
            final padding = isSmallScreen ? 16.0 : 20.0;
            final spacing = isSmallScreen ? 16.0 : 24.0;
            
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(),
                  SizedBox(height: spacing),

                  // Clinic Selector - Only wrap this part in Obx
                  if (_clinicController.clinics.length > 1) ...[
                    _buildClinicSelector(),
                    SizedBox(height: spacing),
                  ],

                  // Inventory List
                  _buildInventoryList(),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Brand Inventory',
              style: isSmallScreen 
                  ? AppTextStyles.h3.copyWith(
                      color: AppColors.textPrimary,
                    )
                  : AppTextStyles.h2.copyWith(
                      color: AppColors.textPrimary,
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedClinic != null
                  ? 'Stock quantities for ${_selectedClinic!.name}'
                  : 'Select a clinic to view inventory',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: isSmallScreen ? 13 : null,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }

  Widget _buildClinicSelector() {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Clinic',
              style: AppTextStyles.h6.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Clinic>(
              value: _selectedClinic,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              items: _clinicController.clinics.map((clinic) {
                return DropdownMenuItem<Clinic>(
                  value: clinic,
                  child: Text(
                    clinic.name,
                    style: AppTextStyles.bodyMedium,
                  ),
                );
              }).toList(),
              onChanged: (clinic) {
                setState(() {
                  _selectedClinic = clinic;
                });
                _loadInventory();
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInventoryList() {
    if (_inventory.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.inventory_2_outlined,
        title: 'No Inventory Data',
        message: 'Inventory will appear here when you add stock arrivals in the Stock Portal',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 400;
            
            if (isSmallScreen) {
              // Stacked layout for small screens
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Brands & Quantities',
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit,
                          size: 12,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tap price to edit',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              // Horizontal layout for larger screens
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      'Brands & Quantities',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tap price to edit',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _inventory.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = _inventory[index];
            final brandId = (item['brandId'] as num).toInt();
            final brandName = (item['brandName'] ?? 'Unknown') as String;
            final brandAmount = ((item['brandAmount'] as num?) ?? 0).toDouble();
            final quantity = ((item['quantity'] as num?) ?? 0).toInt();
            final isEditing = _isEditingPrice[brandId] ?? false;
            final isSaving = _isSavingPrice[brandId] ?? false;

            return LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 400;
                final cardPadding = isSmallScreen ? 14.0 : 16.0;
                
                return Container(
                  padding: EdgeInsets.all(cardPadding),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isEditing ? AppColors.primary : AppColors.border,
                      width: isEditing ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isEditing 
                            ? AppColors.primary.withOpacity(0.15)
                            : AppColors.shadow,
                        blurRadius: isEditing ? 8 : 4,
                        offset: Offset(0, isEditing ? 4 : 2),
                      ),
                    ],
                  ),
                  child: isSmallScreen
                      ?
                      // Stack layout for small screens
                      Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Brand Icon
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryDark,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.business,
                                color: AppColors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                brandName,
                                style: AppTextStyles.h6.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Quantity Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: quantity > 0
                                    ? LinearGradient(
                                        colors: [
                                          AppColors.success.withOpacity(0.15),
                                          AppColors.success.withOpacity(0.05),
                                        ],
                                      )
                                    : null,
                                color: quantity > 0 ? null : AppColors.grey100,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: quantity > 0 ? AppColors.success : AppColors.grey300,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.inventory_2,
                                    size: 16,
                                    color: quantity > 0 ? AppColors.success : AppColors.grey500,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    quantity.toString(),
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: quantity > 0 ? AppColors.success : AppColors.grey600,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Price row - takes full width on small screens
                        _buildPriceRow(brandId, brandAmount, isEditing, isSaving),
                      ],
                    )
                      :
                      // Horizontal layout for larger screens
                      Row(
                      children: [
                        // Brand Icon
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryDark,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.business,
                            color: AppColors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Brand Info
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                brandName,
                                style: AppTextStyles.h6.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              _buildPriceRow(brandId, brandAmount, isEditing, isSaving),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Quantity Badge
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: quantity > 0
                                  ? LinearGradient(
                                      colors: [
                                        AppColors.success.withOpacity(0.15),
                                        AppColors.success.withOpacity(0.05),
                                      ],
                                    )
                                  : null,
                              color: quantity > 0 ? null : AppColors.grey100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: quantity > 0 ? AppColors.success : AppColors.grey300,
                                width: 2,
                              ),
                              boxShadow: quantity > 0
                                  ? [
                                      BoxShadow(
                                        color: AppColors.success.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.inventory_2,
                                  size: 18,
                                  color: quantity > 0 ? AppColors.success : AppColors.grey500,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    quantity.toString(),
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: quantity > 0 ? AppColors.success : AppColors.grey600,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildPriceRow(int brandId, double brandAmount, bool isEditing, bool isSaving) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'PKR ',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (isEditing)
          Flexible(
            child: SizedBox(
              width: 90,
              child: TextField(
                controller: _priceControllers[brandId],
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          )
        else
          GestureDetector(
            onTap: () {
              setState(() {
                _isEditingPrice[brandId] = true;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    brandAmount.toStringAsFixed(0),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.edit,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        if (isEditing) ...[
          const SizedBox(width: 6),
          if (isSaving)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            )
          else ...[
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _savePrice(brandId),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.check,
                    size: 20,
                    color: AppColors.success,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _cancelEditPrice(brandId),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    size: 20,
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

