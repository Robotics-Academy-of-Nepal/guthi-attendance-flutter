import 'package:attendance2/staff/leave/screens/apply_leave.dart';
import 'package:attendance2/staff/leave/screens/leave_bloc.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class LeavesView extends StatefulWidget {
  const LeavesView({super.key});

  @override
  State<LeavesView> createState() => _LeavesViewState();
}

class _LeavesViewState extends State<LeavesView> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Leaves',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 25,
          ),
        ),
        actions: const [
          Icon(
            Icons.notifications_active,
            size: 30,
          ),
          SizedBox(width: 10),
        ],
      ),
      body: BlocBuilder<LeavesBloc, LeavesState>(
        builder: (context, state) {
          // if (state is LeavesLoading || state is LeavesInitial) {
          //   return const Center(child: CircularProgressIndicator());
          // }
          if (state is LeavesError) {
            return Center(child: Text(state.message));
          } else if (state is LeavesLoaded) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomSlidingSegmentedControl<int>(
                      fixedWidth: screenWidth * 0.3,
                      initialValue: 1,
                      children: const {
                        1: Text('All'),
                        2: Text('Casual'),
                        3: Text('Medical'),
                      },
                      decoration: BoxDecoration(
                        color: CupertinoColors.lightBackgroundGray,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      thumbDecoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(30),
                            blurRadius: 4.0,
                            spreadRadius: 1.0,
                            offset: const Offset(0.0, 2.0),
                          )
                        ],
                      ),
                      curve: Curves.easeInToLinear,
                      onValueChanged: (v) {
                        context.read<LeavesBloc>().add(FilterLeavesEvent(v));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<LeavesBloc>().add(FetchLeavesEvent());
                    },
                    child: state.filteredLeaveApplications.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 20.0),
                              child: Text(
                                "No leave requests found",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: state.filteredLeaveApplications.length,
                            itemBuilder: (context, index) {
                              final leave =
                                  state.filteredLeaveApplications[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: buildLeaveCard(
                                  leave,
                                  formatDateRange(
                                      leave['startDate'], leave['endDate']),
                                  leave['leaveType'],
                                  leave['status'],
                                  getStatusColor(leave['status']),
                                  leave['leaveId'],
                                ),
                              );
                            },
                          ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ApplyLeaveScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Apply Leave",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('Unknown state'));
          }
        },
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

        final formattedStartDate =
            DateFormat('MMMM d, y').format(startDateTime);
        final formattedEndDate = DateFormat('MMMM d, y').format(endDateTime);

        return '$formattedStartDate - $formattedEndDate';
      } else {
        return 'Invalid date range';
      }
    } catch (_) {
      return 'Invalid date format';
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget buildLeaveCard(final Map<String, dynamic> leave, String date,
      String type, String status, Color statusColor, int leaveId) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(
                    date,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    type,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(50), // Lightened status color
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // IconButton(
            //   icon: Icon(Icons.edit,
            //       color: status == 'approved' || status == 'rejected'
            //           ? Colors.grey
            //           : Colors.blue),
            //   onPressed: status == 'approved' || status == 'rejected'
            //       ? null
            //       : () async {
            //           final result = await Navigator.push(
            //             context,
            //             MaterialPageRoute(
            //               builder: (context) =>
            //                   EditLeaveScreen(leaveData: leave),
            //             ),
            //           );
            //           if (result == true) {
            //             fetchLeaveApplications();
            //           }
            //         },
            // ),
            // IconButton(
            //   icon: Icon(Icons.delete,
            //       color: status == 'approved' || status == 'rejected'
            //           ? Colors.grey
            //           : Colors.red),
            //   onPressed: status == 'approved' || status == 'rejected'
            //       ? null
            //       : () async {
            //           showDialog(
            //             context: context,
            //             builder: (context) {
            //               return AlertDialog(
            //                 title: const Text('Delete Leave Application'),
            //                 content: const Text(
            //                     'Are you sure you want to delete this leave application?'),
            //                 actions: [
            //                   TextButton(
            //                     onPressed: () {
            //                       Navigator.pop(context); // Close the dialog
            //                     },
            //                     child: const Text('Cancel'),
            //                   ),
            //                   TextButton(
            //                     onPressed: () async {
            //                       await deleteLeaveApplication(leaveId);
            //                       Navigator.pop(
            //                         navigatorKey.currentContext!,
            //                       ); // Close the dialog
            //                     },
            //                     child: const Text('Delete'),
            //                   ),
            //                 ],
            //               );
            //             },
            //           );
            //         },
            // ),
          ],
        ),
      ),
    );
  }
}
