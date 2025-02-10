import 'dart:convert';
import 'package:attendance2/config/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class EditScreen extends StatefulWidget {
  final Map<String, dynamic> leaveData;
  const EditScreen({super.key, required this.leaveData});

  @override
  State<EditScreen> createState() => _EditLeaveScreenState();
}

class _EditLeaveScreenState extends State<EditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController leaveTypeController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  bool _isLoading = false;
  DateTime? _startDate;

  @override
  void initState() {
    super.initState();
    // Populate input fields with existing data
    titleController.text = widget.leaveData['title'] ?? '';
    leaveTypeController.text = widget.leaveData['leaveType'] ?? '';
    contactNumberController.text = widget.leaveData['contactNumber'] ?? '';
    startDateController.text = widget.leaveData['startDate'] ?? '';
    endDateController.text = widget.leaveData['endDate'] ?? '';
    reasonController.text = widget.leaveData['leaveReason'] ?? '';
  }

  Future<void> updateLeaveApplication() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop if the form is invalid
    }

    setState(() {
      _isLoading = true;
    });

    final token = await secureStorage.read(key: 'auth_token');
    if (token == null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication token not found')),
      );
      return;
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final body = {
      'title': titleController.text,
      'leave_type': leaveTypeController.text,
      'contact_number': contactNumberController.text,
      'start_date': startDateController.text,
      'end_date': endDateController.text,
      'reason': reasonController.text,
    };

    try {
      final response = await http.patch(
        Uri.parse('$baseurl/api/leave/${widget.leaveData['leaveId']}/'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Navigator.pop(context, true); // Return to the previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to update leave application: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Leave Application'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFieldWidget(
                  label: "Title",
                  controller: titleController,
                ),
                const SizedBox(height: 16),
                DropdownFieldWidget(
                  items: const [
                    DropdownMenuItem(
                        value: "medical", child: Text("Medical Leave")),
                    DropdownMenuItem(
                        value: "casual", child: Text("Casual Leave")),
                    DropdownMenuItem(value: "other", child: Text("Other")),
                  ],
                  label: "Leave Type",
                  selectedValue: leaveTypeController.text,
                  onChanged: (value) {
                    setState(() {
                      leaveTypeController.text = value ?? '';
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFieldWidget(
                  label: "Contact Number",
                  controller: contactNumberController,
                ),
                const SizedBox(height: 16),
                DatePickerFieldWidget(
                  label: "Start Date",
                  controller: startDateController,
                  onDateSelected: (date) {
                    setState(() {
                      _startDate = DateTime.parse(date);
                      startDateController.text = date;
                      endDateController.clear();
                    });
                  },
                ),
                const SizedBox(height: 16),
                DatePickerFieldWidget(
                  label: "End Date",
                  controller: endDateController,
                  firstDate: _startDate,
                  onDateSelected: (date) {
                    setState(() {
                      endDateController.text = date;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFieldWidget(
                  label: "Reason for Leave",
                  maxLines: 3,
                  controller: reasonController,
                ),
                const SizedBox(height: 32),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: updateLeaveApplication,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          "Submit",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Reusable Widgets (Same as in DApplyLeaveScreen)
class TextFieldWidget extends StatelessWidget {
  final String label;
  final int maxLines;
  final TextEditingController controller;

  const TextFieldWidget({
    super.key,
    required this.label,
    this.maxLines = 1,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}

class DropdownFieldWidget extends StatelessWidget {
  final String label;
  final String? selectedValue;
  final List<DropdownMenuItem<String>> items;
  final Function(String?) onChanged;

  const DropdownFieldWidget({
    super.key,
    required this.label,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      value: selectedValue,
      items: items,
      onChanged: onChanged,
    );
  }
}

class DatePickerFieldWidget extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Function(String) onDateSelected;
  final DateTime? firstDate;
  final bool enabled;

  const DatePickerFieldWidget({
    super.key,
    required this.label,
    required this.controller,
    required this.onDateSelected,
    this.firstDate,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_today),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onTap: enabled
          ? () async {
              DateTime initialDate = firstDate ?? DateTime.now();
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: initialDate,
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                String formattedDate =
                    '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
                onDateSelected(formattedDate);
              }
            }
          : null,
    );
  }
}
