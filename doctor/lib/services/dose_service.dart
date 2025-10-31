import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dose.dart';

class DoseService {
  static const String baseUrl = 'http://localhost:3000/api';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Future<List<Dose>> getAllDoses() async {
    final uri = Uri.parse('$baseUrl/doses');
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      final list = (data['data'] as List).cast<dynamic>();
      return list.map((e) => Dose.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load doses: ${res.statusCode}');
  }
}
