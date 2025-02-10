// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:attendance2/notification/notification_service.dart';
import 'package:http/http.dart' as http;
import 'package:attendance2/auth/register_bloc/register_event.dart';
import 'package:attendance2/auth/register_bloc/register_state.dart';
import 'package:attendance2/config/global.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(RegisterState()) {
    // Handle field changes
    on<RegisterFieldChanged>((event, emit) {
      switch (event.fieldName) {
        case "firstName":
          emit(state.copyWith(firstName: event.value));
          break;
        case "lastName":
          emit(state.copyWith(lastName: event.value));
          break;
        case "email":
          emit(state.copyWith(email: event.value));
          break;
        case "password":
          emit(state.copyWith(password: event.value));
          break;
        case "confirmPassword":
          emit(state.copyWith(confirmPassword: event.value));
          break;
        case "departmentId":
          emit(state.copyWith(departmentId: event.value));
          break;
        case "designation":
          emit(state.copyWith(designation: event.value));
          break;
        case "address": // Handle new field
          emit(state.copyWith(address: event.value));
          break;
        case "contactNumber": // Handle new field
          emit(state.copyWith(contactNumber: event.value));
          break;
      }
    });
    on<FetchDepartments>((event, emit) async {
      emit(state.copyWith(isFetchingDepartments: true));
      try {
        final response = await http.get(
          Uri.parse('$baseurl/api/department/'),
          headers: {"Content-Type": "application/json"},
        );
        print(response.statusCode);
        print(response.body);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final List<dynamic> data = jsonDecode(response.body);
          print(data);
          // Parse the JSON array directly
          final formattedDepartments = data
              .map((department) => {
                    "id": department['id'].toString(),
                    "name": department['name'].toString(),
                  })
              .toList();

          emit(state.copyWith(
            isFetchingDepartments: false,
            departments: formattedDepartments,
          ));
        } else {
          emit(state.copyWith(
            isFetchingDepartments: false,
            errorMessage: "Failed to fetch departments.",
          ));
        }
      } on SocketException {
        emit(state.copyWith(
          isFetchingDepartments: false,
          errorMessage:
              "No Internet connection. Please check your network and try again.",
        ));
      } catch (e) {
        emit(state.copyWith(
          isFetchingDepartments: false,
          errorMessage: "Something went wrong. Please try again.",
        ));
      }
    });

    // Handle form submission
    on<RegisterSubmitted>((event, emit) async {
      NotificationService notificationService = NotificationService();
      String fcmToken = await notificationService.getDeviceToken();
      if (state.firstName.isEmpty ||
          state.lastName.isEmpty ||
          state.email.isEmpty ||
          state.password.isEmpty ||
          state.confirmPassword.isEmpty ||
          state.departmentId!.isEmpty ||
          state.designation.isEmpty) {
        emit(state.copyWith(errorMessage: "Please fill all the fields."));
        return;
      }
      if (state.password != state.confirmPassword) {
        emit(state.copyWith(errorMessage: "Passwords do not match"));
        return;
      }

      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(state.email)) {
        emit(state.copyWith(
            errorMessage: "Please enter a valid email address."));
        return;
      }
      if (state.contactNumber.isEmpty || state.contactNumber.length < 10) {
        emit(state.copyWith(
            errorMessage: "Please enter a valid contact number."));
        return;
      }
      if (state.address.isEmpty) {
        emit(state.copyWith(errorMessage: "Address cannot be empty."));
        return;
      }

      emit(state.copyWith(isSubmitting: true));
      try {
        // Simulate FCM token fetching

        final response = await http.post(
          Uri.parse('$baseurl/api/register/'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "first_name": state.firstName,
            "last_name": state.lastName,
            "email": state.email,
            "password": state.password,
            "confirm_password": state.confirmPassword,
            "department_id": state.departmentId,
            "designation": state.designation,
            "address": state.address, // Include new field
            "contact_number": state.contactNumber, // Include new field
            "fcmToken": fcmToken,
          }),
        );
        print(response.statusCode);
        print(response.body);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          emit(state.copyWith(isSubmitting: false, isSuccess: true));
        } else {
          final errorBody = jsonDecode(response.body);

          if (errorBody['message'] == "Email is already registered") {
            emit(state.copyWith(
              isSubmitting: false,
              errorMessage: "This email is already registered.",
            ));
          } else {
            emit(state.copyWith(
              isSubmitting: false,
              errorMessage: errorBody['error'] ?? "Registration failed.",
            ));
          }
        }
      } catch (e) {
        emit(state.copyWith(
          isSubmitting: false,
          errorMessage: "An error occurred: $e",
        ));
      }
    });
  }
}
