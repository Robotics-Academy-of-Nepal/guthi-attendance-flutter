// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:attendance2/config/global.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ALeaveService {
  FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<List<Map<String, dynamic>>> fetchLeaveRequests(
      {String? status}) async {
    final String apiUrl = '$baseurl/api/leave/';

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
      print(response.statusCode);
      print(response.body);
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

  // Method to update leave status (Accept/Reject) for a specific leave request
  Future<void> updateLeaveStatus(int leaveId, String status) async {
    String apiUrl =
        '$baseurl/api/leave/$leaveId/approve_or_reject/'; // Use leaveId in the API URL

    try {
      final token = await secureStorage.read(key: 'auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // Create the body with the status
      final body = jsonEncode({
        'action': status,
      });
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode >= 200 && response.statusCode > 300) {}
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }
}
