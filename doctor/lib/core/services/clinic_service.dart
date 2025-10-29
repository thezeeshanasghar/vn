import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';
import '../../models/clinic.dart';

class ClinicService {
  Future<Map<String, dynamic>> getClinicsByDoctor(String doctorId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getClinicsByDoctor(doctorId)),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] && responseData['data'] != null) {
          List<dynamic> clinicsJson = responseData['data'];
          return {
            'success': true,
            'data': clinicsJson.map((json) => Clinic.fromJson(json)).toList(),
          };
        }
      }
      return {
        'success': false,
        'message': 'Failed to load clinics',
        'data': <Clinic>[],
      };
    } catch (error) {
      print('Get clinics by doctor error: $error');
      return {
        'success': false,
        'message': 'An error occurred while loading clinics',
        'data': <Clinic>[],
      };
    }
  }

  Future<Map<String, dynamic>> createClinic(Clinic clinic) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.clinicsEndpoint),
        headers: ApiConfig.defaultHeaders,
        body: json.encode(clinic.toCreateJson()),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201 && responseData['success']) {
        return {
          'success': true,
          'data': Clinic.fromJson(responseData['data']),
          'message': responseData['message'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to create clinic',
        };
      }
    } catch (error) {
      print('Create clinic error: $error');
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  Future<Map<String, dynamic>> updateClinic(String clinicId, Clinic clinic) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.updateClinic(clinicId)),
        headers: ApiConfig.defaultHeaders,
        body: json.encode(clinic.toUpdateJson()),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        return {
          'success': true,
          'data': Clinic.fromJson(responseData['data']),
          'message': responseData['message'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update clinic',
        };
      }
    } catch (error) {
      print('Update clinic error: $error');
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  Future<Map<String, dynamic>> deleteClinic(String clinicId) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.deleteClinic(clinicId)),
        headers: ApiConfig.defaultHeaders,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        return {
          'success': true,
          'message': responseData['message'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to delete clinic',
        };
      }
    } catch (error) {
      print('Delete clinic error: $error');
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  Future<Map<String, dynamic>> toggleClinicOnline(String clinicId, bool isOnline) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.toggleClinicOnline(clinicId)),
        headers: ApiConfig.defaultHeaders,
        body: json.encode({'isOnline': isOnline}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        return {
          'success': true,
          'message': responseData['message'],
          'data': Clinic.fromJson(responseData['data']),
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update clinic status',
        };
      }
    } catch (error) {
      print('Toggle clinic online error: $error');
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  Future<Map<String, dynamic>> autoSetClinicOnline(String doctorId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.autoSetClinicOnline(doctorId)),
        headers: ApiConfig.defaultHeaders,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        return {
          'success': true,
          'message': responseData['message'],
          'needsSelection': responseData['needsSelection'] ?? false,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to set clinic online',
        };
      }
    } catch (error) {
      print('Auto-set clinic online error: $error');
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }
}
