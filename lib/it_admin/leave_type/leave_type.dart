import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:attendance2/config/global.dart'; // Ensure this import points to your global configuration file

class LeaveType extends StatefulWidget {
  const LeaveType({super.key});

  @override
  State<LeaveType> createState() => _LeaveTypeState();
}

class _LeaveTypeState extends State<LeaveType> {
  final TextEditingController _leaveTypeController =
      TextEditingController(); // Controller for leave type input

  Future<void> _saveLeaveType(String leaveType) async {
    final url =
        Uri.parse('$baseurl/api/leave-type/'); // Replace with your API endpoint

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': leaveType,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Leave type "$leaveType" saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _leaveTypeController.clear(); // Clear the input field
      } else {
        _handleErrorResponse(response);
      }
    } on SocketException catch (e) {
      _showUserFriendlyMessage(
          'No internet connection. Please check your network and try again.');
      debugPrint('Network error: ${e.message}');
    } on FormatException catch (e) {
      _showUserFriendlyMessage(
          'Failed to process data. Please try again later.');
      debugPrint('JSON encoding error: ${e.message}');
    } on HttpException catch (e) {
      _showUserFriendlyMessage(
          'Failed to save leave type. Please try again later.');
      debugPrint('HTTP error: ${e.message}');
    } on Exception catch (e) {
      _showUserFriendlyMessage('Something went wrong. Please try again later.');
      debugPrint('Unexpected error: ${e.toString()}');
    }
  }

  void _handleErrorResponse(http.Response response) {
    // Log the raw error for debugging
    debugPrint(
        'Failed to save leave type. Status code: ${response.statusCode}, Response: ${response.body}');

    // Show a user-friendly message based on the status code
    if (response.statusCode >= 500) {
      _showUserFriendlyMessage('Server error. Please try again later.');
    } else if (response.statusCode == 404) {
      _showUserFriendlyMessage('Resource not found. Please check the URL.');
    } else if (response.statusCode == 400) {
      _showUserFriendlyMessage('leave type with this name already exists.');
    } else {
      _showUserFriendlyMessage(
          'Failed to save leave type. Please try again later.');
    }
  }

  void _showUserFriendlyMessage(String message) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Leave Type',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () {
          // Close the keyboard when tapping outside the text field
          FocusScope.of(context).unfocus();
        },
        behavior:
            HitTestBehavior.opaque, // Ensures the entire screen is tappable
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Leave Type Input Field
              TextField(
                controller: _leaveTypeController,
                decoration: InputDecoration(
                  labelText: 'Enter Leave Type',
                  hintText: 'e.g., Sick Leave, Casual Leave',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  prefixIcon: Icon(Icons.edit, color: Colors.blue),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
              ),

              const SizedBox(height: 20),
              // Save Button for Leave Type
              ElevatedButton.icon(
                onPressed: () {
                  final leaveType = _leaveTypeController.text.trim();
                  if (leaveType.isNotEmpty) {
                    FocusScope.of(context).unfocus(); // Close the keyboard
                    _saveLeaveType(leaveType);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Please enter a leave type!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.save, color: Colors.white), // Save icon
                label: const Text(
                  'Save Leave Type',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _leaveTypeController.dispose(); // Dispose the controller
    super.dispose();
  }
}
