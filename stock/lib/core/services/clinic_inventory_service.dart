import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';

class ClinicInventoryService {
  // Get inventory for a specific clinic
  static Future<List<Map<String, dynamic>>> getInventoryByClinic(int clinicId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/clinic-inventory/clinic/$clinicId');
    final res = await http.get(uri, headers: ApiConfig.defaultHeaders);
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        final list = (data['data'] as List).cast<dynamic>();
        return list.map((e) => (e as Map).cast<String, dynamic>()).toList();
      }
    }
    throw Exception('Failed to load clinic inventory');
  }

  // Get inventory for all clinics of a doctor
  static Future<List<Map<String, dynamic>>> getInventoryByDoctor(int doctorId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/clinic-inventory/doctor/$doctorId');
    final res = await http.get(uri, headers: ApiConfig.defaultHeaders);
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        final list = (data['data'] as List).cast<dynamic>();
        return list.map((e) => (e as Map).cast<String, dynamic>()).toList();
      }
    }
    throw Exception('Failed to load doctor inventory');
  }
}

