// ignore_for_file: avoid_print
import 'package:attendance2/admin/services/service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget abuildLeaveCard(
  Map<String, dynamic> leave, {
  bool isHistory = false,
  VoidCallback? onStatusChange,
  required Function(bool isApproved) onShowSuccess,
}) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: leave['profileImage'] != null
                ? NetworkImage(leave['profileImage']) as ImageProvider
                : const AssetImage('assets/images/demo profile.jpg'),
            radius: 25,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leave['first_name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatDateRange(leave['startDate'], leave['endDate']),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                if (isHistory)
                  // Display status for history tab
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: leave['status'] == 'approved'
                          ? Colors.lightBlueAccent
                          : Color.fromARGB(255, 244, 138, 130),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      leave['status'].toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  )
                else
                  // Buttons for pending tab
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await ALeaveService().updateLeaveStatus(
                              leave['id'],
                              'reject',
                            );
                            onStatusChange?.call();
                            onShowSuccess(false); // Pass the action here

                            print('Leave rejected successfully');
                          } catch (e) {
                            print('Error rejecting leave: $e');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 244, 138, 130),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(70, 36),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.close, color: Colors.white, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Reject',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await ALeaveService().updateLeaveStatus(
                              leave['id'],
                              'approve',
                            );
                            onStatusChange?.call();
                            onShowSuccess(true);
                            print('Leave approved successfully');
                          } catch (e) {
                            print('Error approving leave: $e');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(70, 36),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check, color: Colors.white, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Accept',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

String formatDateRange(String? startDate, String? endDate) {
  try {
    if (startDate != null &&
        startDate.isNotEmpty &&
        endDate != null &&
        endDate.isNotEmpty) {
      final startDateTime = DateTime.parse(startDate);
      final endDateTime = DateTime.parse(endDate);

      final formattedStartDate = DateFormat('MMMM d, y').format(startDateTime);
      final formattedEndDate = DateFormat('MMMM d, y').format(endDateTime);

      return '$formattedStartDate - $formattedEndDate';
    } else {
      return 'Invalid date range';
    }
  } catch (_) {
    return 'Invalid date format';
  }
}
