import 'dart:convert';
import 'dart:io';
import 'package:attendance2/auth/userdata_bloc/bloc.dart';
import 'package:attendance2/auth/userdata_bloc/state.dart';
import 'package:attendance2/config/global.dart';
import 'package:http/http.dart' as http;

class LeaveService {
  final UserDataBloc userDataBloc;

  LeaveService(this.userDataBloc);
  Future<String> submitLeaveApplication(Map<String, dynamic> leaveData) async {
    final String apiUrl = "$baseurl/api/leave/";

    // Access the current state of the BLoC
    final currentState = userDataBloc.state;

    if (currentState is UserDataLoadedState) {
      final token = currentState.token;
      try {
        print('Sending leave data: $leaveData');
        print('Using token: $token');

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(leaveData),
        );

        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          print('successful');
          return "Leave application submitted successfully!";
        } else {
          print('unsuccessful');
          return "Failed to submit leave application: ${response.body}";
        }
      } on SocketException {
        return "Please enable Wi-Fi or mobile data and try again.";
      } catch (e) {
        return "Error occurred while submitting leave application: $e";
      }
    } else {
      return "User data not available. Please log in again.";
    }
  }
}
