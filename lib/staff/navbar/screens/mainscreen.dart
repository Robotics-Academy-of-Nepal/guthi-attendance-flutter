import 'package:attendance2/notification/notification_service.dart';
import 'package:attendance2/staff/activity/screens/activity_screen.dart';
import 'package:attendance2/staff/homepage/screen/homescreen.dart';
import 'package:attendance2/staff/leave/screens/leave_screen.dart';
// import 'package:attendance2/staff/leave/screens/newleave.dart';
import 'package:attendance2/staff/navbar/bloc/navigation_cubit.dart';
import 'package:attendance2/staff/navbar/screens/bottom_navigation.dart';
import 'package:attendance2/staff/profile/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreen extends StatefulWidget {
  final int userId;

  const MainScreen({
    super.key,
    required this.userId,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  NotificationService notificationService = NotificationService();

  @override
  void initState() {
    context.read<NavigationCubit>().updateTabIndex(0);
    notificationService.requestNotificationPermission(context);
    notificationService.getDeviceToken();
    notificationService.firebaseInit(context);
    notificationService.setupInteractMessage(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // List of screens for navigation
    final List<Widget> screens = [
      HomeScreen(),
      // LeavesView(),
      Leaves(),
      MyActivityScreen(userId: widget.userId),
      ProfileScreen(userIdd: widget.userId),
    ];

    return BlocBuilder<NavigationCubit, int>(
      builder: (context, currentIndex) {
        return Scaffold(
          body: screens[currentIndex],
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: currentIndex,
            onTap: (index) {
              context.read<NavigationCubit>().updateTabIndex(index);
            },
          ),
        );
      },
    );
  }
}
