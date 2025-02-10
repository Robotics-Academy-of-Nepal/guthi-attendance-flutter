import 'package:attendance2/auth/userdata_bloc/bloc.dart';
import 'package:attendance2/auth/userdata_bloc/state.dart';
import 'package:attendance2/config/global.dart';
import 'package:attendance2/staff/navbar/bloc/navigation_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  List<Map<String, String>> attendanceData = [];
  bool isLoading = true;
  bool isError = false;
  String? selectedStudent;
  String? checkInTime;
  String? checkOutTime;
  String? profileImage;

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
    fetchProfileImage();
  }

  Future<void> fetchProfileImage() async {
    // Retrieve the profile image from secure storage
    String? imageData = await secureStorage.read(key: 'profile_image');
    if (imageData != null) {
      setState(() {
        profileImage = imageData; // Store the image data
      });
    }
  }

  Future<void> fetchAttendanceData() async {
    selectedStudent = await secureStorage.read(key: 'first_name');

    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      // Retrieve user ID or other necessary data from secure storage
      String? userId = await secureStorage.read(key: 'id');
      if (userId == null) {
        throw Exception("User ID not found");
      }

      // Define date range (e.g., last 7 days)
      String startDate = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 7)));
      String endDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Construct API URL
      String apiUrl =
          '$baseurl/api/accesslog/?user_id=$userId&start_time=$startDate&end_time=$endDate';

      // Make API call
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        List<dynamic> data = json.decode(response.body);

        // Process API response
        List<Map<String, String>> processedData = [];
        for (var log in data) {
          String date =
              log['time'].split('T')[0]; // Extract date from timestamp
          processedData.add({
            "date": date,
            "status": "Present", // Assuming all logs indicate presence
          });
        }

        // Extract Check In and Check Out times for today
        String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        List<dynamic> todayLogs = data.where((log) {
          String logDate = log['time'].split('T')[0];
          return logDate == today;
        }).toList();

        String? checkIn;
        String? checkOut;
        for (var log in todayLogs) {
          if (log['attendance_events'] == "Check In") {
            checkIn = log['time']
                .split('T')[1]
                .substring(0, 5); // Extract time (HH:mm)
          } else if (log['attendance_events'] == "Check Out") {
            checkOut = log['time']
                .split('T')[1]
                .substring(0, 5); // Extract time (HH:mm)
          }
        }

        setState(() {
          attendanceData = processedData;
          checkInTime = checkIn ?? "--:--";
          checkOutTime = checkOut ?? "--:--";
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isError = true;
        isLoading = false;
      });
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(screenWidth * 0.02),
          child: CircleAvatar(
            backgroundColor: Colors.blue,
            backgroundImage: profileImage != null
                ? MemoryImage(
                    base64Decode(profileImage!)) // Decode base64 image
                : const AssetImage('assets/images/demo profile.jpg')
                    as ImageProvider, // Fallback image
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
                                      Text(
                                        checkInTime ?? "--:--",
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
                                      Text(
                                        checkOutTime ?? "--:--",
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
                            context.read<NavigationCubit>().updateTabIndex(2);
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
                  ],
                ),
    );
  }
}
