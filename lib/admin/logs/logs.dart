import 'package:attendance2/admin/logs/staff_screen.dart';
import 'package:attendance2/config/global.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON parsing

class Logs extends StatefulWidget {
  const Logs({super.key});

  @override
  State<Logs> createState() => _LogsState();
}

class _LogsState extends State<Logs> {
  List<Department> departments = [];
  List<Department> filteredDepartments = [];
  bool isLoading = true; // To show a loading indicator

  @override
  void initState() {
    super.initState();
    fetchDepartments(); // Fetch departments when the widget is initialized
  }

  // Fetch departments from the API
  Future<void> fetchDepartments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseurl/api/department/'), // Replace with your API URL
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // If the API call is successful, parse the JSON
        final List<dynamic> data = json.decode(response.body);
        if (kDebugMode) {
          print(data); // Print the response for debugging
        }

        if (mounted) {
          setState(() {
            departments = data
                .map((dept) => Department(
                      id: dept[
                          'id'], // Ensure 'id' is included in the JSON response
                      name: dept[
                          'name'], // Ensure 'name' is included in the JSON response
                      icon: Icons.apartment, // Default icon
                    ))
                .toList();
            filteredDepartments = departments;
            isLoading = false; // Hide loading indicator
          });
        }
      } else {
        // If the API call fails, throw an error
        throw Exception('Failed to load departments');
      }
    } catch (e) {
      // Handle any errors during the API call or JSON parsing
      if (kDebugMode) {
        print('Error fetching departments: $e');
      }
      if (mounted) {
        setState(() {
          isLoading = false; // Ensure loading indicator is hidden even on error
        });
      }
      throw Exception('Failed to load departments: $e');
    }
  }

  void filterDepartments(String query) {
    setState(() {
      filteredDepartments = departments
          .where(
              (dept) => dept.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _navigateToStaffList(int departmentId, String departmentName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StaffListScreen(
          departmentId: departmentId,
          departmentName: departmentName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Departments',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: filterDepartments,
              decoration: InputDecoration(
                hintText: 'Search departments...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: filteredDepartments.length,
                    itemBuilder: (context, index) {
                      final department = filteredDepartments[index];
                      return DepartmentCard(
                        department: department,
                        onTap: () => _navigateToStaffList(
                            department.id, department.name),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class Department {
  final int id;
  final String name;
  final IconData icon;

  Department({required this.id, required this.name, required this.icon});
}

class DepartmentCard extends StatelessWidget {
  final Department department;
  final VoidCallback onTap;

  const DepartmentCard({
    super.key,
    required this.department,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          department.icon,
          size: 30,
          color: Colors.blue,
        ),
        title: Text(
          department.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
        onTap: onTap,
      ),
    );
  }
}
