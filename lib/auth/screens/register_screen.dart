import 'package:attendance2/auth/register_bloc/register_bloc.dart';
import 'package:attendance2/auth/register_bloc/register_event.dart';
import 'package:attendance2/auth/register_bloc/register_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendance2/auth/screens/login_screen.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterBloc()..add(FetchDepartments()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BlocConsumer<RegisterBloc, RegisterState>(
                listener: (context, state) {
                  if (state.isSuccess) {
                    _showSuccessBottomSheet(context);
                  } else if (state.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage!),
                        backgroundColor: Colors.black,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final bloc = context.read<RegisterBloc>();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        "Sign up",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Create your account",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      _buildCustomTextField(
                        "First Name",
                        state.firstName,
                        (value) =>
                            bloc.add(RegisterFieldChanged("firstName", value)),
                        Icons.person,
                      ),
                      const SizedBox(height: 15),
                      _buildCustomTextField(
                        "Last Name",
                        state.lastName,
                        (value) =>
                            bloc.add(RegisterFieldChanged("lastName", value)),
                        Icons.person_outline,
                      ),
                      const SizedBox(height: 15),
                      _buildCustomTextField(
                        "Email",
                        state.email,
                        (value) =>
                            bloc.add(RegisterFieldChanged("email", value)),
                        Icons.email,
                      ),
                      const SizedBox(height: 15),
                      _buildCustomTextField(
                        "Password",
                        state.password,
                        (value) =>
                            bloc.add(RegisterFieldChanged("password", value)),
                        Icons.lock,
                        isPassword: true,
                      ),
                      const SizedBox(height: 15),
                      _buildCustomTextField(
                        "Confirm Password",
                        state.confirmPassword,
                        (value) => bloc.add(
                            RegisterFieldChanged("confirmPassword", value)),
                        Icons.lock_outline,
                        isPassword: true,
                      ),
                      const SizedBox(height: 15),
                      _buildDropdown(
                        context,
                        state.departments,
                        state.departmentId ?? "",
                        (value) => bloc.add(RegisterFieldChanged(
                            "departmentId", value.toString())),
                      ),
                      const SizedBox(height: 15),
                      _buildCustomTextField(
                        "Designation",
                        state.designation,
                        (value) => bloc
                            .add(RegisterFieldChanged("designation", value)),
                        Icons.work,
                      ),
                      const SizedBox(height: 15),
                      _buildCustomTextField(
                        "Address",
                        state.address,
                        (value) =>
                            bloc.add(RegisterFieldChanged("address", value)),
                        Icons.location_on,
                      ),
                      const SizedBox(height: 15),
                      IntlPhoneField(
                        decoration: InputDecoration(
                          hintText: 'Contact Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: Colors.purple.withValues(alpha: 0.1),
                          filled: true,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                        ),
                        initialCountryCode: 'NP',
                        showDropdownIcon: false,
                        onChanged: (PhoneNumber phone) {
                          bloc.add(RegisterFieldChanged(
                              "contactNumber", phone.completeNumber));
                        },
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () => bloc.add(RegisterSubmitted()),
                        style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text(
                          "Register",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginPage(),
                                ),
                              );
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTextField(
    String hint,
    String value,
    ValueChanged<String> onChanged,
    IconData icon, {
    bool isPassword = false,
  }) {
    return TextField(
      onChanged: onChanged,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        fillColor: Colors.purple.withValues(alpha: 0.1),
        filled: true,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _buildDropdown(
    BuildContext context,
    List<Map<String, String>> departments,
    String value,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value.isEmpty ? null : value,
      items: departments
          .map((department) => DropdownMenuItem<String>(
                value: department['id'],
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: 200.0), // Adjust the maxWidth as needed
                  child: Text(
                    department['name'] ?? "",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: "Select Department",
        prefixIcon: const Icon(Icons.apartment),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        fillColor: Colors.purple.withAlpha(30),
        filled: true,
      ),
      menuMaxHeight: 200.0, // Restricts dropdown height
      isExpanded:
          true, // Ensures the dropdown menu matches the width of the button
    );
  }

  void _showSuccessBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height *
                0.6, // Maximum height of 50% of screen height
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom +
                    20, // Adjust for keyboard
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIndicator(),
                  const SizedBox(height: 15),
                  _buildIcon(),
                  const SizedBox(height: 20),
                  _buildTitleText(),
                  const SizedBox(height: 10),
                  _buildSubtitleText(),
                  const SizedBox(height: 20),
                  _buildDoneButton(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIndicator() {
    return Container(
      width: 50,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildIcon() {
    return const CircleAvatar(
      radius: 60,
      backgroundColor: Color.fromARGB(255, 233, 242, 250),
      child: CircleAvatar(
          radius: 45,
          backgroundColor: Colors.blue,
          child: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 13,
                backgroundColor: Colors.blue,
                child: Icon(
                  Icons.check,
                  size: 20,
                  color: Colors.white,
                ),
              ))),
    );
  }

  Widget _buildTitleText() {
    return const Column(
      children: [
        Text(
          "Registration",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          "Successful",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSubtitleText() {
    return const Column(
      children: [
        Text(
          "You have been",
          style: TextStyle(
            fontSize: 14,
            color: Color.fromARGB(255, 32, 32, 32),
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          "registered successfully.",
          style: TextStyle(
            fontSize: 14,
            color: Color.fromARGB(255, 32, 32, 32),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDoneButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          "Done",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
