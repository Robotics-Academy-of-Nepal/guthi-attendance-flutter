import 'dart:io';
import 'package:attendance2/config/global.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HolidayScreen extends StatefulWidget {
  const HolidayScreen({super.key});

  @override
  State<HolidayScreen> createState() => _HolidayScreenState();
}

class _HolidayScreenState extends State<HolidayScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  final List<DateTime> _selectedDates = [];
  final List<DateTime> _disabledDates = [];

  @override
  void initState() {
    super.initState();
    _fetchHolidays();
  }

  // Function to fetch already selected holidays

  Future<void> _fetchHolidays() async {
    final url = Uri.parse('$baseurl/api/holiday/');

    try {
      final response = await http.get(url);
      print(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _disabledDates.clear();
          for (var item in data) {
            // Normalize the DateTime by stripping the time component
            final date = DateTime.parse(item['date']);
            _disabledDates.add(DateTime(date.year, date.month, date.day));
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch holidays'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on SocketException catch (e) {
      // Handle network-related errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error'),
          backgroundColor: Colors.red,
        ),
      );
    } on FormatException catch (e) {
      // Handle JSON parsing errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data parsing error'),
          backgroundColor: Colors.red,
        ),
      );
    } on HttpException catch (e) {
      // Handle HTTP-specific errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('HTTP error:'),
          backgroundColor: Colors.red,
        ),
      );
    } on Exception catch (e) {
      // Handle all other exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveHoliday(List<DateTime> selectedDates) async {
    final url = Uri.parse('$baseurl/api/holiday/');

    try {
      // Format the dates as a list of strings
      final formattedDates = selectedDates.map((selectedDate) {
        return "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
      }).toList();

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, List<String>>{
          'dates': formattedDates,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Holidays saved for $formattedDates'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchHolidays(); // Refresh the list of disabled dates
      } else {
        // Handle non-success status codes
        _handleErrorResponse(response);
      }
    } on SocketException catch (e) {
      // Handle network errors
      _showUserFriendlyMessage(
          'No internet connection. Please check your network and try again.');
      debugPrint('Network error: ${e.message}');
    } on FormatException catch (e) {
      // Handle JSON encoding/decoding errors
      _showUserFriendlyMessage(
          'Failed to process data. Please try again later.');
      debugPrint('JSON encoding error: ${e.message}');
    } on HttpException catch (e) {
      // Handle HTTP-specific errors
      _showUserFriendlyMessage(
          'Failed to save holidays. Please try again later.');
      debugPrint('HTTP error: ${e.message}');
    } on Exception catch (e) {
      // Handle all other exceptions
      _showUserFriendlyMessage('Something went wrong. Please try again later.');
      debugPrint('Unexpected error: ${e.toString()}');
    }
  }

  void _handleErrorResponse(http.Response response) {
    // Log the raw error for debugging
    debugPrint(
        'Failed to save holidays. Status code: ${response.statusCode}, Response: ${response.body}');

    // Show a user-friendly message based on the status code
    if (response.statusCode >= 500) {
      _showUserFriendlyMessage('Server error. Please try again later.');
    } else if (response.statusCode == 404) {
      _showUserFriendlyMessage('Resource not found. Please check the URL.');
    } else if (response.statusCode == 400) {
      _showUserFriendlyMessage(
          'Invalid data. Please check your input and try again.');
    } else {
      _showUserFriendlyMessage(
          'Failed to save holidays. Please try again later.');
    }
  }

  void _showUserFriendlyMessage(String message) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Holiday Planner',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Calendar
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  final normalizedDay = DateTime(day.year, day.month, day.day);
                  return _selectedDates.contains(normalizedDay);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  final normalizedDay = DateTime(
                      selectedDay.year, selectedDay.month, selectedDay.day);
                  if (!_disabledDates.contains(normalizedDay) &&
                      normalizedDay.weekday != DateTime.saturday) {
                    setState(() {
                      if (_selectedDates.contains(normalizedDay)) {
                        _selectedDates.remove(normalizedDay);
                      } else {
                        _selectedDates.add(normalizedDay);
                      }
                      _focusedDay = focusedDay;
                    });
                  }
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                  disabledTextStyle: TextStyle(color: Colors.red),
                  outsideDaysVisible: false,
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekendStyle: TextStyle(
                    color: Colors.red,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  formatButtonDecoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  formatButtonTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  leftChevronVisible: true,
                  rightChevronVisible: true,
                  leftChevronIcon: const Icon(
                    Icons.chevron_left,
                    color: Colors.deepPurple,
                  ),
                  rightChevronIcon: const Icon(
                    Icons.chevron_right,
                    color: Colors.deepPurple,
                  ),
                ),
                enabledDayPredicate: (day) {
                  final normalizedDay = DateTime(day.year, day.month, day.day);
                  return day.weekday != DateTime.saturday &&
                      !_disabledDates.contains(normalizedDay);
                },
              ),

              const SizedBox(height: 20),
              // Save Button
              ElevatedButton(
                onPressed: () {
                  if (_selectedDates.isNotEmpty) {
                    _saveHoliday(_selectedDates); // Pass the list of dates
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Please select at least one date!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Save Holiday',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
