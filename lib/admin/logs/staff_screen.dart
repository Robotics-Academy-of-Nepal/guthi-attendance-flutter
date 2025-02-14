import 'dart:convert';
import 'package:attendance2/admin/logs/staff_detail.dart';
import 'package:http/http.dart' as http;
import 'package:attendance2/config/global.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class StaffListScreen extends StatefulWidget {
  final int departmentId;
  final String departmentName;

  const StaffListScreen({
    super.key,
    required this.departmentId,
    required this.departmentName,
  });

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  List<Staff> staffList = [];
  List<Staff> filteredStaffs = [];
  bool isLoading = true;
  String departmentHeadName = '';

  @override
  void initState() {
    super.initState();
    fetchStaffMembers(); // Fetch staff members when the screen is initialized
  }

  // Fetch staff members for the selected department
  Future<void> fetchStaffMembers() async {
    if (kDebugMode) {
      print(widget.departmentId);
    }
    try {
      final response = await http.get(
        Uri.parse(
            '$baseurl/api/users/department-all-staff-detail/?department_id=${widget.departmentId}'),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> data = json.decode(response.body);
        if (kDebugMode) {
          print(data); // Print the response for debugging
        }

        setState(() {
          staffList = data
              .map((staff) => Staff(
                    id: staff['id'],
                    name: '${staff['first_name']} ${staff['last_name']}',
                    role: staff['role'],
                  ))
              .toList();

          // Find the department head
          final departmentHead = staffList.firstWhere(
            (staff) => staff.role == 'department_head',
            orElse: () => Staff(id: -1, name: '', role: ''),
          );

          if (departmentHead.id != -1) {
            departmentHeadName = departmentHead.name;
            // Remove the department head from the staff list
            staffList.removeWhere((staff) => staff.role == 'department_head');
          }

          isLoading = false;
        });
      } else {
        throw Exception('Failed to load staff members');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching staff members: $e');
      }
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load staff members: $e');
    }
  }

  void filterStaffs(String query) {
    setState(() {
      filteredStaffs = staffList
          .where(
              (staff) => staff.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          widget.departmentName,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: filterStaffs,
              decoration: InputDecoration(
                hintText: 'Search staff...',
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
          ),

          // Department Head Section
          if (departmentHeadName.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.blue[50], // Light blue background
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.blue,
                        size: 30,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Department Head',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            departmentHeadName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Staff List Section
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredStaffs.isNotEmpty
                        ? filteredStaffs.length
                        : staffList.length,
                    itemBuilder: (context, index) {
                      final staff = filteredStaffs.isNotEmpty
                          ? filteredStaffs[index]
                          : staffList[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.person,
                            color: Colors.blue,
                            size: 30,
                          ),
                          title: Text(
                            staff.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'ID: ${staff.id}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StaffDetailScreen(
                                  staffId: staff.id,
                                  staffName: staff.name,
                                ),
                              ),
                            );
                          },
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

class Staff {
  final int id;
  final String name;
  final String role;

  Staff({required this.id, required this.name, required this.role});
}
