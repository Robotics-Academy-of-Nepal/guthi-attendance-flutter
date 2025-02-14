// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:attendance2/config/global.dart';
import 'package:attendance2/staff/activity/widgets/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class DMyActivityScreen extends StatefulWidget {
  final int userId;
  const DMyActivityScreen({super.key, required this.userId});

  @override
  State<DMyActivityScreen> createState() => _DMyActivityScreenState();
}

class _DMyActivityScreenState extends State<DMyActivityScreen> {
  FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  List<Map<String, String>> filteredActivities = [];
  bool isLoading = true;
  bool isError = false;
  String? selectedStudent;

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
  }

  Future<void> fetchAttendanceData() async {
    selectedStudent = await secureStorage.read(key: 'first_name');
    if (mounted) {
      setState(() {
        isLoading = true;
        isError = false;
      });
    }

    String startDate = DateFormat('yyyy-MM-dd')
        .format(DateTime.now().subtract(const Duration(days: 30)));
    String yesterdayDate = DateFormat('yyyy-MM-dd')
        .format(DateTime.now().subtract(const Duration(days: 1)));
    String apiUrl =
        '$baseurl/api/accesslog/?user_id=${widget.userId}&start_time=$startDate&end_time=$yesterdayDate';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      print(response.statusCode);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        List<dynamic> data = json.decode(response.body);
        print(data);
        // Process API response
        Map<String, bool> attendanceMap = {};
        for (var log in data) {
          String date =
              log['time'].split('T')[0]; // Extract date from timestamp
          attendanceMap[date] = true; // Mark the date as present
        }

        // Generate attendance records for each day from the first recorded date
        DateTime startDate =
            DateTime(2025, 1, 1); // Start tracking from Jan 1, 2025
        DateTime endDate = DateTime.now().subtract(const Duration(days: 1));

        List<Map<String, String>> updatedActivities = [];
        for (DateTime date = startDate;
            date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
            date = date.add(const Duration(days: 1))) {
          String dateStr = DateFormat('yyyy-MM-dd').format(date);
          updatedActivities.add({
            "date": dateStr,
            "status": attendanceMap.containsKey(dateStr) ? "Present" : "Absent",
          });
        }

        if (mounted) {
          setState(() {
            filteredActivities = updatedActivities;
            isLoading = false;
          });
        }
      } else {
        throw Exception("Failed to fetch data");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final int totalDays = filteredActivities.length;
    final int totalPresentDays = filteredActivities
        .where((activity) => activity['status'] == 'Present')
        .length;
    final int totalAbsentDays = totalDays - totalPresentDays;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('My Activity',
              style: TextStyle(fontWeight: FontWeight.bold))),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
              ? const Center(child: Text("Failed to load data. Try again."))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildStatCard('Total Days', Colors.grey.shade100,
                              totalDays, Colors.grey, Icons.calendar_month),
                          buildStatCard(
                              'Present Days',
                              Colors.green.shade50,
                              totalPresentDays,
                              Colors.green,
                              Icons.check_circle),
                          buildStatCard('Absent Days', Colors.red.shade50,
                              totalAbsentDays, Colors.red, Icons.cancel),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: Text("$selectedStudent's Activity",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: filteredActivities.isEmpty
                          ? const Center(
                              child: Text(
                                  'No activities found for the selected range.'))
                          : ListView.builder(
                              itemCount: filteredActivities.length,
                              itemBuilder: (context, index) {
                                final activity = filteredActivities[index];
                                final activityDate = DateFormat.yMMMMd()
                                    .format(DateTime.parse(activity['date']!));

                                return Container(
                                  margin: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.01,
                                    horizontal: screenWidth * 0.04,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade200,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: screenWidth * 0.02,
                                        height: screenHeight * 0.08,
                                        decoration: BoxDecoration(
                                          color: activity['status'] == 'Absent'
                                              ? Colors.red
                                              : Colors.green,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            bottomLeft: Radius.circular(8),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: screenHeight * 0.01,
                                            horizontal: screenWidth * 0.03,
                                          ),
                                          child: ListTile(
                                            leading: Icon(
                                              activity['status'] == 'Absent'
                                                  ? Icons.cancel
                                                  : Icons.check_circle,
                                              color:
                                                  activity['status'] == 'Absent'
                                                      ? Colors.red
                                                      : Colors.green,
                                            ),
                                            title: Text(
                                              activity['status'] ?? '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: activity['status'] ==
                                                        'Absent'
                                                    ? Colors.red
                                                    : Colors.green,
                                              ),
                                            ),
                                            subtitle: Text(activityDate),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
