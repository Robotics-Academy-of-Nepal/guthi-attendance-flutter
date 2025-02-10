abstract class UserDataState {}

class UserDataInitial extends UserDataState {}

class UserDataLoadedState extends UserDataState {
  final String token;
  final String role;
  final int id;
  final String firstName;
  final String lastName;
  final String address;
  final String designation;
  final String contactNumber;
  final String image;

  UserDataLoadedState(
      {required this.token,
      required this.role,
      required this.id,
      required this.firstName,
      required this.lastName,
      required this.address,
      required this.designation,
      required this.contactNumber,
      required this.image});
}

class UserDataFailure extends UserDataState {
  final String errorMessage;

  UserDataFailure(this.errorMessage);
}
