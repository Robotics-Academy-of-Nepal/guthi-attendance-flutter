import 'package:attendance2/department/activity/activity_page.dart';
import 'package:attendance2/department/homepage/screens/homescreen.dart';
import 'package:attendance2/department/leave/screens/leave_screen.dart';
import 'package:attendance2/department/leave/screens/leaves.dart';
import 'package:attendance2/department/navbar/bloc/navigation_cubit.dart';
import 'package:attendance2/department/navbar/screens/bottom_navigation.dart';
import 'package:attendance2/department/profile/screens/profile_screen.dart';
import 'package:attendance2/notification/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DMainScreen extends StatefulWidget {
  final int userId;
  const DMainScreen({super.key, required this.userId});

  @override
  State<DMainScreen> createState() => _DMainScreenState();
}

class _DMainScreenState extends State<DMainScreen> {
  NotificationService notificationService = NotificationService();

  @override
  void initState() {
    context.read<DNavigationCubit>().updateTabIndex(0);
    notificationService.requestNotificationPermission(context);
    notificationService.getDeviceToken();
    notificationService.firebaseInit(context);
    notificationService.setupInteractMessage(context);
    // FcmService.firebaseInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // List of screens for navigation
    final List<Widget> screens = [
      DHomeScreen(
        userId: widget.userId,
      ),
      DLeaves(userId: widget.userId),
      DLeaveRequestScreen(userId: widget.userId),
      DMyActivityScreen(userId: widget.userId),
      DProfileScreen(
        userIdd: widget.userId,
      )
    ];

    return BlocBuilder<DNavigationCubit, int>(
      builder: (context, currentIndex) {
        return Scaffold(
          body: screens[currentIndex],
          bottomNavigationBar: DCustomBottomNavBar(
            currentIndex: currentIndex,
            onTap: (index) {
              context.read<DNavigationCubit>().updateTabIndex(index);
            },
          ),
        );
      },
    );
  }
}
