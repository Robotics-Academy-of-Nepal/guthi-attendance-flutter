import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class RegisterFieldChanged extends RegisterEvent {
  final String fieldName;
  final String value;

  RegisterFieldChanged(this.fieldName, this.value);

  @override
  List<Object?> get props => [fieldName, value];
}

class RegisterSubmitted extends RegisterEvent {}

class FetchDepartments extends RegisterEvent {}
