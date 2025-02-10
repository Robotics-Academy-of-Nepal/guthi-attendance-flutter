import 'package:attendance2/admin/services/service.dart';
import 'package:attendance2/admin/widgets/acustom_slider.dart';
import 'package:attendance2/admin/widgets/leave_card.dart';
import 'package:flutter/material.dart';

class ALeaveScreen extends StatefulWidget {
  final int userId;
  const ALeaveScreen({super.key, required this.userId});

  @override
  State<ALeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<ALeaveScreen> {
  late Future<List<Map<String, dynamic>>> leaveRequests;
  final ALeaveService leaveService = ALeaveService();
  int selectedTab = 1;

  @override
  void initState() {
    super.initState();
    fetchLeaveRequests();
  }

  void fetchLeaveRequests() {
    String status = selectedTab == 1 ? 'awaiting' : 'history';
    leaveRequests = leaveService.fetchLeaveRequests(status: status);
  }

  void onTabChanged(int value) {
    setState(() {
      selectedTab = value;
      fetchLeaveRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [abuildSegmentedControl(screenWidth, onTabChanged)],
            ),
            const SizedBox(height: 15),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: leaveRequests,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No leave requests found.'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return abuildLeaveCard(
                          snapshot.data![index],
                          isHistory: selectedTab == 2,
                          onStatusChange: () {
                            setState(() {
                              fetchLeaveRequests();
                            });
                          },
                          onShowSuccess: (bool isApproved) {
                            _showSuccessBottomSheet(context,
                                isApproved:
                                    isApproved); // Context available here
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessBottomSheet(BuildContext context,
      {required bool isApproved}) {
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
                  _buildIcon(isApproved: isApproved),
                  const SizedBox(height: 20),
                  _buildTitleText(isApproved: isApproved),
                  const SizedBox(height: 10),
                  _buildSubtitleText(isApproved: isApproved),
                  const SizedBox(height: 20),
                  _buildDoneButton(isApproved: isApproved, context),
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

  Widget _buildIcon({required bool isApproved}) {
    return CircleAvatar(
      radius: 60,
      backgroundColor: Color.fromARGB(255, 233, 242, 250),
      child: CircleAvatar(
          radius: 45,
          backgroundColor: isApproved ? Colors.blue : Colors.red,
          child: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 13,
                backgroundColor: isApproved ? Colors.blue : Colors.red,
                child: Icon(
                  Icons.check,
                  size: 20,
                  color: Colors.white,
                ),
              ))),
    );
  }

  Widget _buildTitleText({required bool isApproved}) {
    return Column(
      children: [
        Text(
          isApproved ? "Leave Approved" : "Leave Rejected",
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

  Widget _buildSubtitleText({required bool isApproved}) {
    return Column(
      children: [
        Text(
          "Leave request has been",
          style: TextStyle(
            fontSize: 14,
            color: Color.fromARGB(255, 32, 32, 32),
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          isApproved ? "approved successfully." : "rejected successfully",
          style: TextStyle(
            fontSize: 14,
            color: Color.fromARGB(255, 32, 32, 32),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDoneButton(BuildContext context, {required bool isApproved}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: isApproved ? Colors.blue : Colors.red,
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
}
