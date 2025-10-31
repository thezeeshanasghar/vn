import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';

class BrandService {
  static Future<List<Map<String, dynamic>>> list() async {
    final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/brands'), headers: ApiConfig.defaultHeaders);
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      final list = (data['data'] as List).cast<dynamic>();
      return list.map((e) => (e as Map).cast<String, dynamic>()).toList();
    }
    throw Exception('Failed to load brands');
  }
}


