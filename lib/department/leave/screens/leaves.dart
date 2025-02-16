// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:attendance2/auth/userdata_bloc/bloc.dart';
import 'package:attendance2/auth/userdata_bloc/state.dart';
import 'package:attendance2/config/global.dart';
import 'package:attendance2/department/leave/screens/apply_leave.dart';
import 'package:attendance2/main.dart';
import 'package:attendance2/staff/leave/screens/edit_leavescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DLeaves extends StatefulWidget {
  final int userId;
  const DLeaves({super.key, required this.userId});

  @override
  State<DLeaves> createState() => _DLeavesState();
}

class _DLeavesState extends State<DLeaves> {
  List<Map<String, dynamic>> leaveApplications = [];
  bool isLoading = true;
  FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchLeaveApplications();
  }

  Future<void> fetchLeaveApplications() async {
    final currentState = context.read<UserDataBloc>().state;

    if (currentState is UserDataLoadedState) {
      final token = currentState.token;

      print(token);

      if (token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      try {
        final response = await http.get(
          Uri.parse('$baseurl/api/leave/'),
          headers: headers,
        );

        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = json.decode(response.body);

          // The response is a list of leave applications
          final applications = List<Map<String, dynamic>>.from(data);

          if (mounted) {
            setState(() {
              leaveApplications = applications.map((leave) {
                return {
                  'leaveId': leave['id'], // Use 'id' instead of '_id'
                  'title': leave['title'],
                  'contactNumber':
                      leave['contact_number'], // Use 'contact_number'
                  'startDate': leave['start_date'], // Use 'start_date'
                  'endDate': leave['end_date'], // Use 'end_date'
                  'leaveType': leave['leave_type']['name'], // Use 'leave_type'
                  'status': leave['status'],
                  'leaveReason': leave['reason'],
                  'user_image': leave['user_image'],
                  // Use 'reason'
                };
              }).toList();
            });
          }
        } else {
          print('Failed to load leave applications: ${response.body}');
          if (mounted) {
            ScaffoldMessenger.of(
              navigatorKey.currentContext!,
            ).showSnackBar(
              SnackBar(
                content: Text(
                    "Failed to load leave applications. Please try again."),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } on SocketException catch (e) {
        print('No internet connection: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            navigatorKey.currentContext!,
          ).showSnackBar(
            SnackBar(
              content: Text("No internet connection. Please try again later."),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('Error occurred: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            navigatorKey.currentContext!,
          ).showSnackBar(
            SnackBar(
              content: Text("An error occurred. Please try again."),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            isLoading =
                false; // Set loading state to false after the fetch completes
          });
        }
      }
    } else {
      throw Exception('User is not authenticated or user data is not loaded');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Leaves',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 25,
          ),
        ),
        actions: const [
          Icon(
            Icons.notifications_active,
            size: 30,
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: RefreshIndicator(
                onRefresh: fetchLeaveApplications,
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : leaveApplications.isEmpty
                        ? ListView(
                            children: const [
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 20.0),
                                  child: Text(
                                    "No leave requests found",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            itemCount: leaveApplications.length,
                            itemBuilder: (context, index) {
                              final leave = leaveApplications[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: buildLeaveCard(
                                  leave,
                                  formatDateRange(
                                      leave['startDate'], leave['endDate']),
                                  leave['leaveType'],
                                  leave['status'],
                                  getStatusColor(leave['status']),
                                  leave['leaveId'],
                                ),
                              );
                            },
                          ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DApplyLeaveScreen(
                      userId: widget.userId,
                    ),
                  ),
                );
              },
              child: const Text(
                "Apply Leave",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatDateRange(String? startDate, String? endDate) {
    try {
      if (startDate != null &&
          startDate.isNotEmpty &&
          endDate != null &&
          endDate.isNotEmpty) {
        final startDateTime = DateTime.parse(startDate);
        final endDateTime = DateTime.parse(endDate);

        final formattedStartDate =
            DateFormat('MMMM d, y').format(startDateTime);
        final formattedEndDate = DateFormat('MMMM d, y').format(endDateTime);

        return '$formattedStartDate - $formattedEndDate';
      } else {
        return 'Invalid date range';
      }
    } catch (_) {
      return 'Invalid date format';
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget buildLeaveCard(final Map<String, dynamic> leave, String date,
      String type, String status, Color statusColor, int leaveId) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(
                    date,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    type,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(50), // Lightened status color
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: Icon(Icons.edit,
                  color: status == 'approved' || status == 'rejected'
                      ? Colors.grey
                      : Colors.blue),
              onPressed: status == 'approved' || status == 'rejected'
                  ? null
                  : () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditLeaveScreen(leaveData: leave),
                        ),
                      );
                      if (result == true) {
                        fetchLeaveApplications();
                      }
                    },
            ),
            IconButton(
              icon: Icon(Icons.delete,
                  color: status == 'approved' || status == 'rejected'
                      ? Colors.grey
                      : Colors.red),
              onPressed: status == 'approved' || status == 'rejected'
                  ? null
                  : () async {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Delete Leave Application'),
                            content: const Text(
                                'Are you sure you want to delete this leave application?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close the dialog
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await deleteLeaveApplication(leaveId);
                                  Navigator.pop(
                                    navigatorKey.currentContext!,
                                  ); // Close the dialog
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteLeaveApplication(int leaveId) async {
    final token = await secureStorage.read(key: 'auth_token');
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final response = await http.delete(
      Uri.parse('$baseurl/api/leave/$leaveId/'),
      headers: headers,
    );
    print(response.statusCode);
    print(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      setState(() {
        leaveApplications.removeWhere((leave) => leave['leaveId'] == leaveId);
      });
      ScaffoldMessenger.of(
        navigatorKey.currentContext!,
      ).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior
              .floating, // Ensures the SnackBar floats above the UI
          content: Text('Leave application deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(
        navigatorKey.currentContext!,
      ).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior
              .floating, // Ensures the SnackBar floats above the UI
          content: Text('Failed to delete leave application'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
