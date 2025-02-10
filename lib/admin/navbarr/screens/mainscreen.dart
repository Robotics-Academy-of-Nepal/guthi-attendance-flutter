import 'package:attendance2/admin/leave/screens/leave_screen.dart';
import 'package:attendance2/admin/navbarr/bloc/navigation_cubit.dart';
import 'package:attendance2/admin/navbarr/screens/bottom_navigation.dart';
import 'package:attendance2/admin/profile/screens/profile_screen.dart';
import 'package:attendance2/notification/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AMainScreen extends StatefulWidget {
  final int userId;
  const AMainScreen({super.key, required this.userId});

  @override
  State<AMainScreen> createState() => _AMainScreenState();
}

class _AMainScreenState extends State<AMainScreen> {
  NotificationService notificationService = NotificationService();

  @override
  void initState() {
    context.read<ANavigationCubit>().updateTabIndex(0);
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
      ALeaveScreen(
        userId: widget.userId,
      ),
      AProfileScreen(
        userIdd: widget.userId,
      )
    ];

    return BlocBuilder<ANavigationCubit, int>(
      builder: (context, currentIndex) {
        return Scaffold(
          body: screens[currentIndex],
          bottomNavigationBar: ACustomBottomNavBar(
            currentIndex: currentIndex,
            onTap: (index) {
              context.read<ANavigationCubit>().updateTabIndex(index);
            },
          ),
        );
      },
    );
  }
}
