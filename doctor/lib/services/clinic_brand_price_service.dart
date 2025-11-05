import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_config.dart';

class ClinicBrandPriceService {
  // Get all brand prices for a specific clinic
  static Future<List<Map<String, dynamic>>> getPricesByClinic(int clinicId) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/clinic-brand-price/clinic/$clinicId');
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
      print('Get clinic brand prices error: $error');
      return [];
    }
  }

  // Update brand price for a clinic
  static Future<bool> updatePrice({
    required int clinicId,
    required int brandId,
    required double price,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/clinic-brand-price');
      final response = await http.put(
        uri,
        headers: ApiConfig.defaultHeaders,
        body: json.encode({
          'clinicId': clinicId,
          'brandId': brandId,
          'price': price,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data['success'] == true;
      }
      return false;
    } catch (error) {
      print('Update clinic brand price error: $error');
      return false;
    }
  }
}

