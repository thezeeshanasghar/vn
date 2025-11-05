import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';

class ClinicService {
  static Future<List<Map<String, dynamic>>> getClinicsByDoctor(int doctorId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/clinics/doctor/$doctorId');
    final res = await http.get(uri, headers: ApiConfig.defaultHeaders);
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        final list = (data['data'] as List).cast<dynamic>();
        return list.map((e) => (e as Map).cast<String, dynamic>()).toList();
      }
    }
    throw Exception('Failed to load clinics');
  }
}
