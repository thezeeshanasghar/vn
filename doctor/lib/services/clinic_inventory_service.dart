import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_config.dart';

class ClinicInventoryService {
  // Get inventory for a specific clinic
  static Future<List<Map<String, dynamic>>> getInventoryByClinic(int clinicId) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/clinic-inventory/clinic/$clinicId');
      final response = await http.get(uri, headers: ApiConfig.defaultHeaders);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          final list = (data['data'] as List).cast<dynamic>();
          return list.map((e) => (e as Map).cast<String, dynamic>()).toList();
        }
      }
      return [];
    } catch (error) {
      print('Get clinic inventory error: $error');
      return [];
    }
  }

  // Get inventory for all clinics of a doctor
  static Future<List<Map<String, dynamic>>> getInventoryByDoctor(int doctorId) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/clinic-inventory/doctor/$doctorId');
      final response = await http.get(uri, headers: ApiConfig.defaultHeaders);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          final list = (data['data'] as List).cast<dynamic>();
          return list.map((e) => (e as Map).cast<String, dynamic>()).toList();
        }
      }
      return [];
    } catch (error) {
      print('Get doctor inventory error: $error');
      return [];
    }
  }
}

