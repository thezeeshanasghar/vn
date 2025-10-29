class ApiConfig {
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Auth endpoints
  static const String loginEndpoint = '$baseUrl/auth/login';
  static const String verifyEndpoint = '$baseUrl/auth/verify';
  
  // Clinic endpoints
  static const String clinicsEndpoint = '$baseUrl/clinics';
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
