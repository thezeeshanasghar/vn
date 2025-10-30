import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // Use correct loopback depending on platform (Android emulator cannot reach host via localhost)
  static String get _hostBase {
    if (kIsWeb) return 'http://localhost:3000';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000'; // Android emulator
    return 'http://localhost:3000'; // iOS simulator/macOS
  }

  static String get baseUrl => '$_hostBase/api';
  
  // Auth endpoints
  static String get loginEndpoint => '$baseUrl/auth/login';
  static String get verifyEndpoint => '$baseUrl/auth/verify';
  
  // Clinic endpoints
  static String get clinicsEndpoint => '$baseUrl/clinics';
  static String getClinicsByDoctor(String doctorId) => '$baseUrl/clinics/doctor-mongo/$doctorId';
  static String getClinicById(String clinicId) => '$baseUrl/clinics/$clinicId';
  static String updateClinic(String clinicId) => '$baseUrl/clinics/$clinicId';
  static String deleteClinic(String clinicId) => '$baseUrl/clinics/$clinicId';
  static String toggleClinicOnline(String clinicId) => '$baseUrl/clinics/$clinicId/online';
  static String autoSetClinicOnline(String doctorId) => '$baseUrl/clinics/doctor-mongo/$doctorId/auto-online';
  
  // Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
  };
  
  static Map<String, String> getAuthHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
}
