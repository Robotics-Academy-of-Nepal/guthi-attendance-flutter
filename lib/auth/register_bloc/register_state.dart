class RegisterState {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String confirmPassword;
  final String? departmentId;
  final String designation;
  final bool isSubmitting;
  final String address; // New field
  final String contactNumber; // New field
  final bool isFetchingDepartments;
  final List<Map<String, String>> departments;
  final bool isSuccess;
  final String? errorMessage;

  RegisterState({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.departmentId,
    this.address = '', // Initialize new field
    this.contactNumber = '', // Initialize new field

    this.designation = '',
    this.isSubmitting = false,
    this.isFetchingDepartments = false,
    this.departments = const [],
    this.isSuccess = false,
    this.errorMessage,
  });

  RegisterState copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? confirmPassword,
    String? departmentId,
    String? designation,
    bool? isSubmitting,
    String? address, // Add new field
    String? contactNumber, // Add new field
    bool? isFetchingDepartments,
    List<Map<String, String>>? departments,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return RegisterState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      departmentId: departmentId ?? this.departmentId,
      designation: designation ?? this.designation,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isFetchingDepartments:
          isFetchingDepartments ?? this.isFetchingDepartments,
      address: address ?? this.address, // Update field
      contactNumber: contactNumber ?? this.contactNumber, // Update field
      departments: departments ?? this.departments,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }
}
