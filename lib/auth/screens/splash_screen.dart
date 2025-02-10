import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendance2/auth/userdata_bloc/bloc.dart';
import 'package:attendance2/auth/userdata_bloc/event.dart';
import 'package:attendance2/auth/userdata_bloc/state.dart';
import 'package:attendance2/it_admin/navbar/screens/mainscreen.dart';
import 'package:attendance2/admin/navbarr/screens/mainscreen.dart';
import 'package:attendance2/auth/screens/login_screen.dart';
import 'package:attendance2/department/navbar/screens/mainscreen.dart';
import 'package:attendance2/staff/navbar/screens/mainscreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isNavigated = false;

  @override
  void initState() {
    super.initState();

    // Initialize fade-in animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();

    context.read<UserDataBloc>().add(UserDataLoaded());

    // Introduce a delay before navigating
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // Check if the widget is still mounted before navigating
        context.read<UserDataBloc>().add(UserDataLoaded());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserDataBloc, UserDataState>(
      listener: (context, state) {
        if (!_isNavigated) {
          // Prevent multiple navigations
          _isNavigated = true;
          Future.delayed(const Duration(seconds: 3), () {
            if (state is UserDataLoadedState) {
              _navigateToScreen(_getScreenForRole(state.role, state.id));
            } else {
              _navigateToScreen(const LoginPage());
            }
          });
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/logo.png',
                    height: 120,
                    width: 120,
                    fit: BoxFit.contain, // Ensure sharp display
                  ),
                  const SizedBox(height: 20),
                  // App Name
                  const Text(
                    "Easy Attendance",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Tagline
                  const Text(
                    "Simplify your attendance process",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 50),
                  // Loading Indicator
                  const CircularProgressIndicator(color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getScreenForRole(String role, int id) {
    switch (role) {
      case 'staff':
        return MainScreen(userId: id);
      case 'department_head':
        return DMainScreen(userId: id);
      case 'office_admin':
        return AMainScreen(userId: id);
      case 'it_admin':
        return ItMainScreen(userId: id);
      default:
        return const LoginPage();
    }
  }

  void _navigateToScreen(Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
