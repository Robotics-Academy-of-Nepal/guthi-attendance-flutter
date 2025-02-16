import 'package:attendance2/auth/userdata_bloc/bloc.dart';
import 'package:attendance2/auth/userdata_bloc/event.dart';
import 'package:attendance2/auth/userdata_bloc/state.dart';
import 'package:attendance2/config/global.dart';
import 'package:attendance2/department/navbar/bloc/navigation_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DHomeScreen extends StatefulWidget {
  final int userId;
  const DHomeScreen({
    required this.userId,
    super.key,
  });

  @override
  State<DHomeScreen> createState() => _DHomeScreenState();
}

class _DHomeScreenState extends State<DHomeScreen> {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  List<Map<String, String>> attendanceData = [];
  bool isLoading = true;
  bool isError = false;
  String? selectedStudent;
  List<Map<String, String>> filteredActivities = [];
  String? profileImage;
  String? yesterdayCheckIn;
  String? yesterdayCheckOut;
  String? Image;

  @override
  void initState() {
    super.initState();
    context.read<UserDataBloc>().add(UserDataLoaded());
    fetchAttendanceData();
  }

  Future<void> fetchAttendanceData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      String startDate = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 7)));
      String yesterdayDate = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 1)));

      String apiUrl =
          '$baseurl/api/accesslog/?user_id=${widget.userId}&start_time=$startDate&end_time=$yesterdayDate';

      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        List<dynamic> data = json.decode(response.body);

        // Create a map to store check-in and check-out times for each date
        Map<String, Map<String, String?>> attendanceMap = {};
        for (var log in data) {
          String date = log['time'].split('T')[0];
          String eventType = log['attendance_events'];
          String time = log['time'].split('T')[1].split('+')[0];

          // Initialize the date entry if it doesn't exist
          if (!attendanceMap.containsKey(date)) {
            attendanceMap[date] = {"checkIn": null, "checkOut": null};
          }

          // Update check-in or check-out time based on the event type
          if (eventType == 'Check In') {
            attendanceMap[date]!["checkIn"] = time;
          } else if (eventType == 'Check Out') {
            attendanceMap[date]!["checkOut"] = time;
          }

          // Extract check-in and check-out times for yesterday
          if (date == yesterdayDate) {
            if (eventType == 'Check In') {
              yesterdayCheckIn = time;
            } else if (eventType == 'Check Out') {
              yesterdayCheckOut = time;
            }
          }
        }

        // Generate attendance records for each day from the start date to yesterday
        DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
        DateTime endDate = DateTime.now().subtract(const Duration(days: 1));

        List<Map<String, String>> updatedActivities = [];
        for (DateTime date = startDate;
            date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
            date = date.add(const Duration(days: 1))) {
          String dateStr = DateFormat('yyyy-MM-dd').format(date);

          // Check if both check-in and check-out times exist for the date
          bool isPresent = attendanceMap.containsKey(dateStr) &&
              attendanceMap[dateStr]!["checkIn"] != null &&
              attendanceMap[dateStr]!["checkOut"] != null;

          updatedActivities.add({
            "date": dateStr,
            "status": isPresent ? "Present" : "Absent",
          });
        }

        // Reverse the order to display the most recent date at the top
        updatedActivities = updatedActivities.reversed.toList();

        if (mounted) {
          setState(() {
            filteredActivities = updatedActivities;
            isLoading = false;
          });
        }
      } else {
        throw Exception("Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
      if (kDebugMode) {
        print("Error fetching data: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final currentState = context.read<UserDataBloc>().state;
    if (currentState is UserDataLoadedState) {
      selectedStudent = currentState.firstName;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(screenWidth * 0.02),
          child: BlocBuilder<UserDataBloc, UserDataState>(
            builder: (context, state) {
              if (state is UserDataLoadedState) {
                // Check if the image already contains the base URL
                if (!state.image.startsWith('http')) {
                  Image = '$baseurl${state.image}';
                } else {
                  Image = state.image;
                }

                return CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: Image != null ? NetworkImage(Image!) : null,
                  child: Image == null
                      ? Icon(Icons.person, size: 40, color: Colors.white)
                      : null,
                );
              }
              return CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              );
            },
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<UserDataBloc, UserDataState>(
              builder: (context, state) {
                if (state is UserDataLoadedState) {
                  return Text(
                    state.firstName,
                    style: TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                } else if (state is UserDataFailure) {
                  return Center(
                    child: Text(
                      state.errorMessage,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: screenWidth * 0.04,
                      ),
                    ),
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
              ? const Center(child: Text("Failed to load data. Try again."))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Text(
                        'Today Attendance',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.02,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Container(
                              margin:
                                  EdgeInsets.only(right: screenWidth * 0.02),
                              padding: EdgeInsets.symmetric(
                                horizontal: screenHeight * 0.02,
                                vertical: screenHeight * 0.02,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.login,
                                    color: Colors.blue,
                                    size: screenWidth * 0.08,
                                  ),
                                  SizedBox(width: screenHeight * 0.01),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Check In",
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.035,
                                        ),
                                      ),
                                      if (yesterdayCheckIn != null)
                                        Text(
                                          yesterdayCheckIn!,
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.03,
                                            color: Colors.grey,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 70,
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(left: screenWidth * 0.02),
                              padding: EdgeInsets.symmetric(
                                horizontal: screenHeight * 0.02,
                                vertical: screenHeight * 0.02,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.logout,
                                    color: Colors.blue,
                                    size: screenWidth * 0.08,
                                  ),
                                  SizedBox(width: screenHeight * 0.01),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Check Out",
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.035,
                                        ),
                                      ),
                                      if (yesterdayCheckOut != null)
                                        Text(
                                          yesterdayCheckOut!,
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.03,
                                            color: Colors.grey,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: Text(
                            "$selectedStudent's Activity",
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            context.read<DNavigationCubit>().updateTabIndex(2);
                          },
                          child: Text(
                            'View more',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
