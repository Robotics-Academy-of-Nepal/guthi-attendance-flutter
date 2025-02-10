// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:convert';
import 'package:attendance2/config/global.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class LeaveService {
  Future<void> submitLeaveApplication(Map<String, dynamic> leaveData) async {
    final String apiUrl = "$baseurl/api/leave/";
    const storage = FlutterSecureStorage();

    final token = await storage.read(key: 'auth_token');
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(leaveData),
      );
      print(response.statusCode);
      print(response.body);
      // Check for success status codes (200-299)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('successful');
        print("Leave application submitted successfully!");
      } else {
        print("Failed to submit leave application: ${response.body}");
      }
    } catch (e) {
      print("Error occurred while submitting leave application: $e");
    }
  }
}
