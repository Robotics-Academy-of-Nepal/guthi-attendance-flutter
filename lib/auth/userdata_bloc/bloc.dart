import 'dart:async';
import 'package:attendance2/auth/userdata_bloc/event.dart';
import 'package:attendance2/auth/userdata_bloc/state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserDataBloc extends Bloc<UserDataEvent, UserDataState> {
  final FlutterSecureStorage secureStorage;

  UserDataBloc(this.secureStorage) : super(UserDataInitial()) {
    on<UserDataSaved>(_onUserDataSaved);
    on<UserDataLoaded>(_onUserDataLoaded);
  }

  Future<void> _onUserDataSaved(
      UserDataSaved event, Emitter<UserDataState> emit) async {
    // Save user data to secure storage
    await secureStorage.write(key: 'auth_token', value: event.token);
    await secureStorage.write(key: 'role', value: event.role);
    await secureStorage.write(key: 'id', value: event.id.toString());
    await secureStorage.write(key: 'first_name', value: event.firstName);
    await secureStorage.write(key: 'last_name', value: event.lastName);
    await secureStorage.write(
        key: 'contact_number', value: event.contactNumber);
    await secureStorage.write(key: 'designation', value: event.designation);
    await secureStorage.write(key: 'address', value: event.address);
    await secureStorage.write(key: 'image', value: event.image);

    emit(UserDataLoadedState(
      token: event.token,
      role: event.role,
      id: event.id,
      firstName: event.firstName,
      lastName: event.lastName,
      contactNumber: event.contactNumber,
      designation: event.designation,
      address: event.address,
      image: event.image,
    ));
  }

  Future<void> _onUserDataLoaded(
      UserDataLoaded event, Emitter<UserDataState> emit) async {
    try {
      // Load user data from secure storage
      final token = await secureStorage.read(key: 'auth_token') ?? '';
      final role = await secureStorage.read(key: 'role') ?? '';
      final idString = await secureStorage.read(key: 'id') ?? '';
      final firstName = await secureStorage.read(key: 'first_name') ?? '';
      final lastName = await secureStorage.read(key: 'last_name') ?? '';
      final contactNumber =
          await secureStorage.read(key: 'contact_number') ?? '';
      final designation = await secureStorage.read(key: 'designation') ?? '';
      final address = await secureStorage.read(key: 'address') ?? '';
      final image = await secureStorage.read(key: 'image') ?? '';

      final id = int.tryParse(idString) ?? 0;
      if (token.isNotEmpty && role.isNotEmpty && idString.isNotEmpty) {
        emit(UserDataLoadedState(
            token: token,
            role: role,
            id: id,
            firstName: firstName,
            lastName: lastName,
            contactNumber: contactNumber,
            designation: designation,
            address: address,
            image: image));
      } else {
        emit(UserDataFailure('User data not found.'));
      }
    } catch (e) {
      emit(UserDataFailure('Failed to load user data: $e'));
    }
  }
}
