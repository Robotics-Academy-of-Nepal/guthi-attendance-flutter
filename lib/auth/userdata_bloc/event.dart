abstract class UserDataEvent {}

class UserDataLoaded extends UserDataEvent {}

class UserDataSaved extends UserDataEvent {
  final String token;
  final String role;
  final int id;
  final String firstName;
  final String lastName;
  final String address;
  final String designation;
  final String contactNumber;
  final String image;

  UserDataSaved(
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
