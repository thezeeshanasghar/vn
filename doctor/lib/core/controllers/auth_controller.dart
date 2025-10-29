import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/doctor.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  
  // Observable variables
  final Rx<Doctor?> currentDoctor = Rx<Doctor?>(null);
  final RxString token = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isAuthenticated = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDoctorFromPrefs();
  }

  Future<void> _loadDoctorFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('token');
      final doctorJson = prefs.getString('doctor');

      if (savedToken != null && doctorJson != null) {
        token.value = savedToken;
        currentDoctor.value = Doctor.fromJson(json.decode(doctorJson));
        isAuthenticated.value = true;
      }
    } catch (e) {
      print('Error loading doctor from prefs: $e');
    }
  }

  Future<bool> login(String identifier, String password) async {
    try {
      isLoading.value = true;
      
      final result = await _authService.login(identifier, password);
      
      if (result['success']) {
        token.value = result['token'];
        currentDoctor.value = result['doctor'];
        isAuthenticated.value = true;
        
        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token.value);
        await prefs.setString('doctor', json.encode(currentDoctor.value!.toJson()));
        
        return true;
      } else {
        Get.snackbar(
          'Login Failed',
          result['message'] ?? 'Invalid credentials',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred during login',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('doctor');
      
      token.value = '';
      currentDoctor.value = null;
      isAuthenticated.value = false;
      
      Get.offAllNamed('/login');
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  Future<bool> verifyToken() async {
    if (token.value.isEmpty) return false;

    try {
      final result = await _authService.verifyToken(token.value);
      
      if (result['success']) {
        currentDoctor.value = result['doctor'];
        isAuthenticated.value = true;
        return true;
      } else {
        await logout();
        return false;
      }
    } catch (e) {
      print('Token verification error: $e');
      await logout();
      return false;
    }
  }
}
