class ApiConfig {
  // API Configuration
  static const String baseUrl = 'http://192.168.0.4:3000/api';
  static const int timeoutDuration = 30; // seconds
  
  // API Endpoints
  static const String healthEndpoint = '/health';
  static const String vaccinesEndpoint = '/vaccines';
  static const String brandsEndpoint = '/brands';
  static const String dosesEndpoint = '/doses';
  static const String doctorsEndpoint = '/doctors';
}
