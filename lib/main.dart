import 'package:attendance2/admin/navbarr/bloc/navigation_cubit.dart';
import 'package:attendance2/auth/login_bloc/login_bloc.dart';
import 'package:attendance2/auth/screens/splash_screen.dart';
import 'package:attendance2/auth/userdata_bloc/bloc.dart';
import 'package:attendance2/it_admin/navbar/bloc/navigation.dart';
import 'package:attendance2/notification/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'firebase_options.dart';
import 'package:attendance2/department/navbar/bloc/navigation_cubit.dart';
import 'package:attendance2/staff/navbar/bloc/navigation_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// @pragma('vm:entry-point')
// Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   NotificationService().handleMessage(message);
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  // await initializeDateFormatting('hi_IN', null);
  final flutterSecureStorage = FlutterSecureStorage();

  runApp(MyApp(
    flutterSecureStorage: flutterSecureStorage,
  ));
}

class MyApp extends StatelessWidget {
  final FlutterSecureStorage flutterSecureStorage;

  const MyApp({
    super.key,
    required this.flutterSecureStorage,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UserDataBloc(flutterSecureStorage),
        ),
        BlocProvider(
          create: (context) => LoginBloc(context.read<UserDataBloc>()),
        ),
        BlocProvider(create: (context) => NavigationCubit()),
        BlocProvider(create: (context) => DNavigationCubit()),
        BlocProvider(create: (context) => ANavigationCubit()),
        BlocProvider(create: (context) => ItNavigationCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        home: SplashScreen(),
      ),
    );
  }
}
