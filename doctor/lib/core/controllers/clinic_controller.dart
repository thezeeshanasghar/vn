import 'package:get/get.dart';
import '../../models/clinic.dart';
import '../services/clinic_service.dart';
import 'auth_controller.dart';

class ClinicController extends GetxController {
  final ClinicService _clinicService = ClinicService();
  
  // Observable variables
  final RxList<Clinic> clinics = <Clinic>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadClinics();
  }

  Future<void> loadClinics() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final authController = Get.find<AuthController>();
      if (authController.currentDoctor.value != null) {
        final result = await _clinicService.getClinicsByDoctor(
          authController.currentDoctor.value!.id
        );
        
        if (result['success']) {
          clinics.value = result['data'];
        } else {
          errorMessage.value = result['message'] ?? 'Failed to load clinics';
        }
      }
    } catch (e) {
      errorMessage.value = 'An error occurred while loading clinics';
      print('Load clinics error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createClinic(Clinic clinic) async {
    try {
      isLoading.value = true;
      
      final result = await _clinicService.createClinic(clinic);
      
      if (result['success']) {
        clinics.add(result['data']);
        Get.snackbar(
          'Success',
          result['message'] ?? 'Clinic created successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Failed to create clinic',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while creating clinic',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateClinic(String clinicId, Clinic clinic) async {
    try {
      isLoading.value = true;
      
      final result = await _clinicService.updateClinic(clinicId, clinic);
      
      if (result['success']) {
        final index = clinics.indexWhere((c) => c.id == clinicId);
        if (index != -1) {
          clinics[index] = result['data'];
        }
        Get.snackbar(
          'Success',
          result['message'] ?? 'Clinic updated successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Failed to update clinic',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while updating clinic',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteClinic(String clinicId) async {
    try {
      isLoading.value = true;
      
      final result = await _clinicService.deleteClinic(clinicId);
      
      if (result['success']) {
        clinics.removeWhere((c) => c.id == clinicId);
        Get.snackbar(
          'Success',
          result['message'] ?? 'Clinic deleted successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Failed to delete clinic',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while deleting clinic',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> toggleClinicOnline(String clinicId, bool isOnline) async {
    try {
      isLoading.value = true;
      
      final result = await _clinicService.toggleClinicOnline(clinicId, isOnline);
      
      if (result['success']) {
        final index = clinics.indexWhere((c) => c.id == clinicId);
        if (index != -1) {
          clinics[index] = result['data'];
        }
        Get.snackbar(
          'Success',
          result['message'] ?? 'Clinic status updated',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Failed to update clinic status',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while updating clinic status',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> autoSetClinicOnline() async {
    try {
      isLoading.value = true;
      
      final authController = Get.find<AuthController>();
      if (authController.currentDoctor.value != null) {
        final result = await _clinicService.autoSetClinicOnline(
          authController.currentDoctor.value!.id
        );
        
        if (result['success']) {
          if (result['data'] is List) {
            clinics.value = (result['data'] as List)
                .map((json) => Clinic.fromJson(json))
                .toList();
          } else {
            clinics.value = [Clinic.fromJson(result['data'])];
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Auto-set clinic online error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
