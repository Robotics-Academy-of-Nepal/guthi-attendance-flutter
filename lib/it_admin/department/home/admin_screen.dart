// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:attendance2/config/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ItAdminScreen extends StatefulWidget {
  final int userId;
  const ItAdminScreen({super.key, required this.userId});

  @override
  State<ItAdminScreen> createState() => _ItAdminScreenState();
}

class _ItAdminScreenState extends State<ItAdminScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _departmentNameController =
      TextEditingController();

  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _staff = [];
  String? _selectedDepartmentId;
  String? _selectedStaffId;
  bool isloading = false;
// State variables for transfer staff
  String? fromDeptId;
  String? toDeptId;
  String? staffId;

  FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController =
        TabController(length: 3, vsync: this); // Change length to 2
    _tabController.addListener(() {
      FocusScope.of(context).unfocus();
      if (_tabController.index == 1 && !_tabController.indexIsChanging) {
        _fetchDepartments();
      }
      if (_tabController.index == 2 && !_tabController.indexIsChanging) {
        _fetchDepartments();
      }
    });
  }

  Future<void> _createDepartment() async {
    FocusScope.of(context).unfocus();
    final token = await secureStorage.read(key: 'auth_token');
    final departmentName = _departmentNameController.text.trim();

    if (departmentName.isEmpty) {
      _showSnackBar('Please enter a department name');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseurl/api/department/'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "name": departmentName,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _departmentNameController.clear();
        _showSnackBar('Department created successfully');
      } else {
        _showSnackBar('Failed to create department');
      }
    } catch (e) {
      _showSnackBar('Error creating department: $e');
    }
  }

  Future<void> _transferStaff(String? toDeptId, String? staffId) async {
    final token = await secureStorage.read(key: 'auth_token');
    if (token == null) {
      _showSnackBar('Authentication token not found. Please log in again.');
      return;
    }

    try {
      final response = await http.patch(
        Uri.parse('$baseurl/api/users/$staffId/'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "department_id": toDeptId,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          fromDeptId = null;
          this.toDeptId = null;
          this.staffId = null;
          _staff.clear();
        });

        _showSnackBar('Staff transferred successfully');
      } else {
        _showSnackBar('Failed to transfer staff. Please try again later.');
      }
    } catch (e) {
      _showSnackBar('Error transferring staff: $e');
    }
  }

  Future<void> _fetchDepartments() async {
    final token = await secureStorage.read(key: 'auth_token');
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseurl/api/department/'),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> data = jsonDecode(response.body);
        print(data); // API returns a list directly

        setState(() {
          _departments = List<Map<String, dynamic>>.from(
              data); // No need to access "departments" key
        });
      } else {
        _showSnackBar('Failed to fetch departments');
      }
    } catch (e) {
      _showSnackBar('Error fetching departments: $e');
    }
  }

  Future<void> _fetchStaff(String departmentId) async {
    final token = await secureStorage.read(key: 'auth_token');
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    try {
      final response = await http.get(
        Uri.parse(
            '$baseurl/api/users/?department_id=$departmentId'), // Fixed URL formatting
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);

        setState(() {
          _staff = (data as List<dynamic>)
              .map((item) => item as Map<String, dynamic>)
              .toList();
          _selectedStaffId =
              null; // Reset staff selection when fetching new staff
        });
      } else {
        _showSnackBar('Failed to fetch staff: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Error fetching staff: $e');
    }
  }

  Future<void> _assignDepartmentHead() async {
    final token = await secureStorage.read(key: 'auth_token');
    if (_selectedDepartmentId == null || _selectedStaffId == null) {
      _showSnackBar('Please select both department and staff');
      return;
    }
    print(_selectedStaffId);
    try {
      final response = await http.patch(
        Uri.parse('$baseurl/api/users/$_selectedStaffId/'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "department_id": ' $_selectedDepartmentId',
          "role": 'department_head',
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _showSnackBar('Department head assigned successfully');
        setState(() {
          _selectedDepartmentId = null;
          _selectedStaffId = null;
          _staff = [];
        });
      } else {
        _showSnackBar('Failed to assign department head');
      }
    } catch (e) {
      _showSnackBar('Error assigning department head: $e');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return; // Prevents using context if the widget is unmounted
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.add), text: 'Create Department'),
            Tab(icon: Icon(Icons.supervisor_account), text: 'Assign Head'),
            Tab(
                icon: Icon(Icons.transfer_within_a_station),
                text: 'Transfer Staff'),
          ],
        ),
      ),
      body: isloading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCreateDepartmentTab(),
                _buildAssignHeadTab(),
                _buildTransferStaffTab(),
              ],
            ),
    );
  }

  Widget _buildTransferStaffTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Transfer Staff"),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "From Department",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded border
                ),
                prefixIcon: Icon(Icons.apartment),
              ),
              menuMaxHeight: 150,
              value: fromDeptId,
              items: _departments
                  .map((dept) => DropdownMenuItem(
                        value: dept['id'].toString(),
                        child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 200.0),
                            child: Text(
                              dept['name'] ?? 'Unnamed Department',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            )),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  fromDeptId = value;
                  _fetchStaff(value!);
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Select Staff",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded border
                ),
                prefixIcon: Icon(Icons.person),
              ),
              menuMaxHeight: 150,
              value: staffId,
              items: _staff
                  .map((staff) => DropdownMenuItem(
                        value: staff['id'].toString(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 200),
                          child: Text(
                            '${staff['first_name']} ${staff['last_name']}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  staffId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "To Department",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded border
                ),
                prefixIcon: Icon(Icons.apartment),
              ),
              menuMaxHeight: 150,
              value: toDeptId,
              items: _departments
                  .map((dept) => DropdownMenuItem(
                        value: dept['id'].toString(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 200),
                          child: Text(
                            dept['name'] ?? 'Unnamed Department',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  toDeptId = value;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (fromDeptId == null || toDeptId == null || staffId == null) {
                  _showSnackBar("Please select all fields");
                  return;
                }
                _transferStaff(toDeptId!, staffId!);
              },
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Colors.blue),
              child: Text(
                "Transfer Staff",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateDepartmentTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _departmentNameController,
            decoration: InputDecoration(
              labelText: 'Department Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(Icons.apartment),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _createDepartment,
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
            label: Text('Create Department'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.blue, // Sets the button's background color to blue
              foregroundColor:
                  Colors.white, // Sets the text and icon color to white
              padding: EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 12.0), // Optional padding
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(8.0), // Optional rounded corners
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignHeadTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String?>(
              value: _selectedDepartmentId,
              items: _departments
                  .map((dept) => DropdownMenuItem<String?>(
                        value: dept['id'].toString(),
                        // Add padding to each dropdown item
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 200.0),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              dept['name'] ?? '',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDepartmentId = value;
                  if (value != null) {
                    _fetchStaff(value);
                  }
                });
              },
              decoration: InputDecoration(
                labelText: 'Select Department',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded border
                ),
                prefixIcon: Icon(Icons.apartment),
              ),
              menuMaxHeight: 200, // Limit the height of the dropdown menu
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStaffId,
              items: _staff
                  .map((staff) => DropdownMenuItem<String>(
                        value: staff['id'].toString(),
                        // Add padding to each dropdown item
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 200),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              '${staff['first_name']} ${staff['last_name']}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStaffId = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Select Staff',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded border
                ),
                prefixIcon: Icon(Icons.person),
              ),
              menuMaxHeight: 200, // Limit the height of the dropdown menu
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _assignDepartmentHead,
              icon: Icon(
                Icons.done,
                color: Colors.white,
              ),
              label: Text('Assign Head'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
