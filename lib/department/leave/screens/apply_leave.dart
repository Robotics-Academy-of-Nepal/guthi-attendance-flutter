// ignore_for_file: avoid_print
import 'package:attendance2/department/leave/services/apply_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

class DApplyLeaveScreen extends StatefulWidget {
  final int userId;
  const DApplyLeaveScreen({super.key, required this.userId});

  @override
  State<DApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<DApplyLeaveScreen> {
  // Controllers for TextField widgets
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();

  // Controllers for DatePicker widgets (store selected date as String)
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();

  String? selectedLeaveType;

  // Controller for Phone Field (used as String)
  String phoneNumber = '';
  final storage = const FlutterSecureStorage();
  DateTime? _startDate;
  bool isEndDateEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply Leave'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 16,
              ),
              TextFieldWidget(
                label: "Title",
                controller: titleController,
              ),
              const SizedBox(height: 20),
              DropdownFieldWidget(
                items: const [
                  DropdownMenuItem(
                      value: "medical", child: Text("Medical Leave")),
                  DropdownMenuItem(
                      value: "casual", child: Text("Casual Leave")),
                  DropdownMenuItem(value: "other", child: Text("Other")),
                ],
                label: "Leave Type",
                selectedValue: selectedLeaveType,
                onChanged: (value) {
                  setState(() {
                    selectedLeaveType = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              PhoneFieldWidget(
                label: "Contact Number",
                onChanged: (phone) {
                  phoneNumber = phone.completeNumber;
                },
              ),
              const SizedBox(height: 16),
              DatePickerFieldWidget(
                label: "Start Date",
                controller: startDateController, // Pass the controller
                onDateSelected: (date) {
                  setState(() {
                    _startDate = DateTime.parse(date);
                    startDateController.text = date;
                    endDateController.clear();
                    isEndDateEnabled = true; // Update the controller text
                  });
                },
              ),
              const SizedBox(height: 16),
              DatePickerFieldWidget(
                label: "End Date",
                controller: endDateController,
                firstDate: _startDate,
                enabled: isEndDateEnabled, // Pass the controller
                onDateSelected: (date) {
                  setState(() {
                    endDateController.text = date; // Update the controller text
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () async {
                  final leaveData = {
                    'title': titleController.text,
                    'leave_type': selectedLeaveType,
                    'contact_number': phoneNumber.toString(),
                    'start_date': startDateController.text,
                    'end_date': endDateController.text,
                    'reason': reasonController.text,
                  };
                  print(leaveData);

                  LeaveService leaveService = LeaveService();
                  await leaveService.submitLeaveApplication(leaveData);
                  _showSuccessBottomSheet(context);
                  titleController.clear();
                  selectedLeaveType = null;
                  phoneNumber = '';
                  startDateController.clear();
                  endDateController.clear();
                  reasonController.clear();
                },
                child: const Text(
                  "Submit",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showSuccessBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height *
              0.6, // Maximum height of 50% of screen height
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom +
                  20, // Adjust for keyboard
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIndicator(),
                const SizedBox(height: 15),
                _buildIcon(),
                const SizedBox(height: 20),
                _buildTitleText(),
                const SizedBox(height: 10),
                _buildSubtitleText(),
                const SizedBox(height: 20),
                _buildDoneButton(context),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildIndicator() {
  return Container(
    width: 50,
    height: 4,
    decoration: BoxDecoration(
      color: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(2),
    ),
  );
}

Widget _buildIcon() {
  return const CircleAvatar(
    radius: 60,
    backgroundColor: Color.fromARGB(255, 233, 242, 250),
    child: CircleAvatar(
        radius: 45,
        backgroundColor: Colors.blue,
        child: CircleAvatar(
            radius: 15,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 13,
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.check,
                size: 20,
                color: Colors.white,
              ),
            ))),
  );
}

Widget _buildTitleText() {
  return const Column(
    children: [
      Text(
        "Leave Applied",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
      Text(
        "Successfully",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

Widget _buildSubtitleText() {
  return const Column(
    children: [
      Text(
        "Your leave has been",
        style: TextStyle(
          fontSize: 14,
          color: Color.fromARGB(255, 32, 32, 32),
        ),
        textAlign: TextAlign.center,
      ),
      Text(
        "applied successfully.",
        style: TextStyle(
          fontSize: 14,
          color: Color.fromARGB(255, 32, 32, 32),
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

Widget _buildDoneButton(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text(
        "Done",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

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

class PhoneFieldWidget extends StatelessWidget {
  final String label;
  final Function(PhoneNumber) onChanged;

  const PhoneFieldWidget(
      {super.key, required this.label, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
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
      initialCountryCode: 'NP', // Nepal
      showDropdownIcon: false, // Disable the dropdown for country selection
      onChanged: onChanged,
    );
  }
}

class DatePickerFieldWidget extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Function(String) onDateSelected;
  final DateTime? firstDate; // Optional: Restrict minimum selectable date
  final bool enabled; // Control whether the field is active

  const DatePickerFieldWidget({
    super.key,
    required this.label,
    required this.controller,
    required this.onDateSelected,
    this.firstDate,
    this.enabled = true, // Default to enabled
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      controller: controller,
      enabled: enabled, // Disable input if not enabled
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
              DateTime initialDate = firstDate ??
                  DateTime.now(); // Default to today if firstDate is null
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: initialDate, // Apply dynamic firstDate restriction
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                String formattedDate =
                    '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
                onDateSelected(formattedDate);
              }
            }
          : null, // Disable tap if not enabled
    );
  }
}
