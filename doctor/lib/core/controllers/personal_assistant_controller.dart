import 'package:get/get.dart';

import '../../models/personal_assistant.dart';
import '../../services/personal_assistant_service.dart';
import 'auth_controller.dart';

class PersonalAssistantController extends GetxController {
  final PersonalAssistantService _service = PersonalAssistantService();

  final RxList<PersonalAssistant> assistants = <PersonalAssistant>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;

  int? get _doctorId => Get.find<AuthController>().currentDoctor.value?.doctorId;

  @override
  void onInit() {
    super.onInit();
    loadAssistants();
  }

  Future<void> loadAssistants() async {
    final doctorId = _doctorId;
    if (doctorId == null) {
      errorMessage.value = 'Doctor not found. Please login again.';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final list = await _service.getAssistantsByDoctor(doctorId);
      assistants.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load personal assistants',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createAssistant({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? mobileNumber,
    PaPermissions? permissions,
    List<PaClinicAccess>? clinicAccess,
  }) async {
    final doctorId = _doctorId;
    if (doctorId == null) {
      Get.snackbar(
        'Error',
        'Doctor information is missing. Please login again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    }

    try {
      isSaving.value = true;

      final assistant = await _service.createAssistant(
        doctorId: doctorId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        mobileNumber: mobileNumber,
        permissions: permissions,
        clinicAccess: clinicAccess,
      );

      assistants.add(assistant);
      Get.snackbar(
        'Success',
        'Personal assistant added successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updatePermissions(PersonalAssistant assistant, PaPermissions permissions) async {
    try {
      isSaving.value = true;
      final updated = await _service.updatePermissions(assistant.paId!, permissions);
      final index = assistants.indexWhere((item) => item.paId == assistant.paId);
      if (index != -1) {
        assistants[index] = updated;
      }
      Get.snackbar(
        'Permissions Updated',
        'Module access updated for ${assistant.fullName}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateClinicAccess(PersonalAssistant assistant, List<PaClinicAccess> access) async {
    try {
      isSaving.value = true;
      final updated = await _service.updateClinicAccess(assistant.paId!, access);
      final index = assistants.indexWhere((item) => item.paId == assistant.paId);
      if (index != -1) {
        assistants[index] = updated;
      }
      Get.snackbar(
        'Clinic Access Updated',
        'Clinic permissions updated for ${assistant.fullName}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deactivateAssistant(PersonalAssistant assistant) async {
    try {
      isSaving.value = true;
      await _service.deactivateAssistant(assistant.paId!);
      assistants.removeWhere((item) => item.paId == assistant.paId);
      Get.snackbar(
        'Assistant Deactivated',
        '${assistant.fullName} can no longer access the portal',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isSaving.value = false;
    }
  }
}

