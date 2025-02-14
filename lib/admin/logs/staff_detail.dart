import 'package:attendance2/config/global.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';

class StaffDetailScreen extends StatefulWidget {
  final int staffId;
  final String staffName;

  const StaffDetailScreen({
    super.key,
    required this.staffId,
    required this.staffName,
  });

  @override
  State<StaffDetailScreen> createState() => _StaffDetailScreenState();
}

class _StaffDetailScreenState extends State<StaffDetailScreen> {
  Map<String, dynamic>? staffDetails;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchStaffDetails(); // Fetch staff details from the API
  }

  // Fetch staff details from the API
  Future<void> _fetchStaffDetails() async {
    final currentDate = DateTime.now();
    final month = currentDate.month;
    final year = currentDate.year;

    final url = Uri.parse(
      '$baseurl/api/accesslog/monthly-attendance-summary/?user_id=${widget.staffId}&month=$month&year=$year',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        setState(() {
          staffDetails = data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load data: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data: $e';
        isLoading = false;
      });
    }
  }

  Widget _buildLoadingEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: Text(
          widget.staffName,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? _buildLoadingEffect()
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 18),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade700,
                              Colors.blue.shade400
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Attendance Summary',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Current Month: ${DateTime.now().month}/${DateTime.now().year}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          children: [
                            _buildInfoCard(
                              'Total Days in Month',
                              '${staffDetails!['total_days_in_month']}',
                              Icons.calendar_today,
                              Colors.blue,
                            ),
                            _buildInfoCard(
                              'Total Office Days',
                              '${staffDetails!['total_office_days']}',
                              Icons.business,
                              Colors.teal,
                            ),
                            _buildInfoCard(
                              'Total Present Days',
                              '${staffDetails!['total_present_days']}',
                              Icons.check_circle,
                              Colors.green,
                            ),
                            _buildInfoCard(
                              'Total Leave Days',
                              '${staffDetails!['total_leave_days']}',
                              Icons.event_busy,
                              Colors.orange,
                            ),
                            _buildInfoCard(
                              'Total Absent Days',
                              '${staffDetails!['total_absent_days']}',
                              Icons.cancel,
                              Colors.red,
                            ),
                            _buildInfoCard(
                              'Total Holidays',
                              '${staffDetails!['total_holidays']}',
                              Icons.beach_access,
                              Colors.purple,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
