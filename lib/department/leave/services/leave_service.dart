// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:attendance2/config/global.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LeaveService {
  FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<List<Map<String, dynamic>>> fetchLeaveRequests(
      {String? status}) async {
    final String apiUrl = '$baseurl/api/leave/department_leaves/';

    try {
      final token = await secureStorage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);

        if (responseData is List) {
          return responseData
              .where((leave) {
                if (status == 'awaiting') {
                  return leave['status'] == 'awaiting';
                } else if (status == 'history') {
                  // History tab should only show approved or rejected requests
                  return leave['status'] == 'approved' ||
                      leave['status'] == 'rejected';
                }
                return true; // Default to returning all if no status is passed
              })
              .map((leave) => {
                    'id': leave['id'],
                    'first_name': leave['first_name'],
                    'startDate': leave['start_date'] ?? '',
                    'endDate': leave['end_date'] ?? '',
                    'status': leave['status'],
                    'leaveType': leave['leave_type'],
                    'profileImage': leave['profile_image'] != null
                        ? '$baseurl${leave['profile_image']}'
                        : null,
                  })
              .toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to fetch leave requests: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  Future<void> updateLeaveStatus(int leaveId, String status) async {
    String apiUrl = '$baseurl/api/leave/$leaveId/approve_or_reject/';

    try {
      final token = await secureStorage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final body = jsonEncode({'action': status});

      print('API URL: $apiUrl');
      print('Headers: $headers');
      print('Request Body: $body');

      final response =
          await http.post(Uri.parse(apiUrl), headers: headers, body: body);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        print('Update response: $responseData');
      } else {
        throw Exception('Failed to update leave status: ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Error occurred: $e');
    }
  }
}
