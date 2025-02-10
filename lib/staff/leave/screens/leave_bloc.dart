import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:attendance2/auth/userdata_bloc/bloc.dart';
import 'package:attendance2/auth/userdata_bloc/state.dart';
import 'package:attendance2/config/global.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LeavesEvent {}

class FetchLeavesEvent extends LeavesEvent {}

class FilterLeavesEvent extends LeavesEvent {
  final int selectedTab;

  FilterLeavesEvent(this.selectedTab);
}

abstract class LeavesState {}

class LeavesInitial extends LeavesState {}

class LeavesLoading extends LeavesState {}

class LeavesLoaded extends LeavesState {
  final List<Map<String, dynamic>> leaveApplications;
  final List<Map<String, dynamic>> filteredLeaveApplications;

  LeavesLoaded({
    required this.leaveApplications,
    required this.filteredLeaveApplications,
  });
}

class LeavesError extends LeavesState {
  final String message;

  LeavesError(this.message);
}

class LeavesBloc extends Bloc<LeavesEvent, LeavesState> {
  final UserDataBloc userDataBloc;

  LeavesBloc({required this.userDataBloc}) : super(LeavesInitial()) {
    on<FetchLeavesEvent>(_onFetchLeaves);
    on<FilterLeavesEvent>(_onFilterLeaves);
  }

  Future<void> _onFetchLeaves(
      FetchLeavesEvent event, Emitter<LeavesState> emit) async {
    emit(LeavesLoading());

    final currentState = userDataBloc.state;

    if (currentState is UserDataLoadedState) {
      final token = currentState.token;

      if (token.isEmpty) {
        emit(LeavesError('Authentication token not found'));
        return;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      try {
        final response = await http.get(
          Uri.parse('$baseurl/api/leave/'),
          headers: headers,
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = json.decode(response.body);
          final applications = List<Map<String, dynamic>>.from(data);

          final leaveApplications = applications.map((leave) {
            return {
              'leaveId': leave['id'],
              'title': leave['title'],
              'contactNumber': leave['contact_number'],
              'startDate': leave['start_date'],
              'endDate': leave['end_date'],
              'leaveType': leave['leave_type'],
              'status': leave['status'],
              'leaveReason': leave['reason'],
            };
          }).toList();

          emit(LeavesLoaded(
            leaveApplications: leaveApplications,
            filteredLeaveApplications: leaveApplications,
          ));
        } else {
          emit(LeavesError('Failed to load leave applications'));
        }
      } on SocketException {
        emit(LeavesError('No internet connection'));
      } catch (e) {
        emit(LeavesError('An error occurred: $e'));
      }
    } else {
      emit(LeavesError('User is not authenticated'));
    }
  }

  void _onFilterLeaves(FilterLeavesEvent event, Emitter<LeavesState> emit) {
    if (state is LeavesLoaded) {
      final currentState = state as LeavesLoaded;
      List<Map<String, dynamic>> filteredLeaveApplications;

      switch (event.selectedTab) {
        case 1:
          filteredLeaveApplications = currentState.leaveApplications;
          break;
        case 2:
          filteredLeaveApplications = currentState.leaveApplications
              .where((leave) => leave['leaveType'] == 'casual')
              .toList();
          break;
        case 3:
          filteredLeaveApplications = currentState.leaveApplications
              .where((leave) => leave['leaveType'] == 'medical')
              .toList();
          break;
        default:
          filteredLeaveApplications = currentState.leaveApplications;
      }

      emit(LeavesLoaded(
        leaveApplications: currentState.leaveApplications,
        filteredLeaveApplications: filteredLeaveApplications,
      ));
    }
  }
}
