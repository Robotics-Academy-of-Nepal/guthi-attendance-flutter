// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:attendance2/auth/userdata_bloc/bloc.dart';
import 'package:attendance2/auth/userdata_bloc/event.dart';
import 'package:attendance2/config/global.dart';
import 'package:attendance2/notification/notification_service.dart';
import 'package:http/http.dart' as http;
import 'package:attendance2/auth/login_bloc/login_event.dart';
import 'package:attendance2/auth/login_bloc/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserDataBloc userDataBloc;

  String email = '';
  String password = '';

  LoginBloc(this.userDataBloc) : super(LoginInitial()) {
    on<EmailChanged>((event, emit) {
      email = event.email;
      print('Email changed: $email'); // Debug statement
    });

    on<PasswordChanged>((event, emit) {
      password = event.password;
      print('Password changed: $password'); // Debug statement
    });

    on<LoginSubmitted>((event, emit) async {
      NotificationService notificationService = NotificationService();
      String fcmToken = await notificationService.getDeviceToken();
      print('FCM Token: $fcmToken'); // Debug statement

      emit(LoginLoading());
      print('Login process started...'); // Debug statement
      try {
        final apiUrl = '$baseurl/api/login/';
        print('API URL: $apiUrl'); // Debug statement

        final body = jsonEncode({
          'email': email,
          'password': password,
          'fcmToken': fcmToken,
        });
        print('Request body: $body'); // Debug statement

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: body,
        );

        print(
            'Response status code: ${response.statusCode}'); // Debug statement
        print('Response body: ${response.body}'); // Debug statement

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final responseData = jsonDecode(response.body);
          print('Response data: $responseData'); // Debug statement

          final token = responseData['access_token'] ?? '';
          final role = responseData['role'] ?? '';
          final id = responseData['id'] ?? '';
          final firstName = responseData['first_name'] ?? '';
          final lastName = responseData['lastName'] ?? '';
          final contactNumber = responseData['contract_number'] ?? '';
          final designation = responseData['designation'] ?? '';
          final address = responseData['address'] ?? '';
          final image = responseData['image'] ?? '';

          print('Token: $token, Role: $role, ID: $id');

          // Trigger UserDataBloc event to save the data
          userDataBloc.add(UserDataSaved(
            token: token,
            role: role,
            id: id,
            firstName: firstName,
            lastName: lastName,
            contactNumber: contactNumber,
            designation: designation,
            address: address,
            image: image,
          ));

          emit(LoginSuccess(token, role, id));
          print('Login success'); // Debug statement
        } else {
          final errorMessage =
              jsonDecode(response.body)['message'] ?? 'Login failed.';
          print('Error message: $errorMessage'); // Debug statement
          emit(LoginFailure(errorMessage));
        }
      } catch (e) {
        print('Exception occurred: $e'); // Debug statement
        emit(LoginFailure('Failed to connect to the server.'));
      }
    });
  }
}
