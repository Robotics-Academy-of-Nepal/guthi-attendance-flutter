import 'package:attendance2/it_admin/department/home/admin_screen.dart';
import 'package:attendance2/it_admin/holidays/create_holiday.dart';
import 'package:attendance2/it_admin/navbar/bloc/navigation.dart';
import 'package:attendance2/it_admin/navbar/screens/bottom_navigation.dart';
import 'package:attendance2/it_admin/profile/profile.dart';
import 'package:attendance2/notification/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItMainScreen extends StatefulWidget {
  final int userId;
  const ItMainScreen({super.key, required this.userId});

  @override
  State<ItMainScreen> createState() => _ItMainScreenState();
}

class _ItMainScreenState extends State<ItMainScreen> {
  NotificationService notificationService = NotificationService();

  @override
  void initState() {
    context.read<ItNavigationCubit>().updateTabIndex(0);
    notificationService.requestNotificationPermission(context);
    notificationService.getDeviceToken();
    notificationService.firebaseInit(context);
    notificationService.setupInteractMessage(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      ItAdminScreen(
        userId: widget.userId,
      ),
      HolidayScreen(),
      ItProfileScreen(userIdd: widget.userId)
    ];

    return BlocBuilder<ItNavigationCubit, int>(
      builder: (context, currentIndex) {
        return Scaffold(
          body: screens[currentIndex],
          bottomNavigationBar: ItCustomBottomNavBar(
            currentIndex: currentIndex,
            onTap: (index) {
              context.read<ItNavigationCubit>().updateTabIndex(index);
            },
          ),
        );
      },
    );
  }
}
