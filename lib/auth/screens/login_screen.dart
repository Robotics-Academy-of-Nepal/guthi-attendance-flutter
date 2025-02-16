import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendance2/admin/navbarr/screens/mainscreen.dart';
import 'package:attendance2/auth/login_bloc/login_bloc.dart';
import 'package:attendance2/auth/login_bloc/login_event.dart';
import 'package:attendance2/auth/login_bloc/login_state.dart';
import 'package:attendance2/auth/screens/forget_password.dart';
import 'package:attendance2/auth/screens/register_screen.dart';
import 'package:attendance2/department/navbar/screens/mainscreen.dart';
import 'package:attendance2/it_admin/navbar/screens/mainscreen.dart';
import 'package:attendance2/staff/navbar/screens/mainscreen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          if (state.role == 'office_admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => AMainScreen(
                        userId: state.id,
                      )),
            );
          } else if (state.role == 'staff') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => MainScreen(
                        userId: state.id,
                      )),
            );
          } else if (state.role == 'it_admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ItMainScreen(
                        userId: state.id,
                      )),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => DMainScreen(
                        userId: state.id,
                      )),
            );
          }
        } else if (state is LoginFailure) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.errorMessage)));
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: _buildLoginContent(),
      ),
    );
  }

  Widget _buildLoginContent() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(height: screenHeight * 0.1),
          _header(screenHeight),
          SizedBox(height: screenHeight * 0.05),
          _inputFields(),
          SizedBox(height: screenHeight * 0.01),
          _forgotPassword(),
          SizedBox(height: screenHeight * 0.02),
          _loginButton(),
          SizedBox(height: screenHeight * 0.03),
          _signup(context),
        ],
      ),
    );
  }

  Widget _header(double screenHeight) {
    return Column(
      children: [
        SizedBox(height: screenHeight * 0.05),
        Image.asset(
          'assets/logo.png',
          height: screenHeight * 0.2,
        ),
        SizedBox(height: screenHeight * 0.01),
        Text(
          "Welcome 👋",
          style: TextStyle(
              fontSize: screenHeight * 0.04, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: screenHeight * 0.01),
        Text(
          "Enter your credentials to login",
          style: TextStyle(fontSize: screenHeight * 0.02, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _inputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            return TextField(
              onChanged: (value) =>
                  context.read<LoginBloc>().add(EmailChanged(value)),
              decoration: InputDecoration(
                hintText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.purple.withOpacity(0.1),
                filled: true,
                prefixIcon: const Icon(Icons.email),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            return TextField(
              onChanged: (value) =>
                  context.read<LoginBloc>().add(PasswordChanged(value)),
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: "Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.purple.withOpacity(0.1),
                filled: true,
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _forgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ForgetPasswordScreen(),
            ),
          );
        },
        child: const Text(
          "Forgot password?",
          style: TextStyle(color: Colors.blue),
        ),
      ),
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return ElevatedButton(
            onPressed: () => context.read<LoginBloc>().add(LoginSubmitted()),
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              backgroundColor: Colors.blue,
            ),
            child: const Text(
              "Login",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _signup(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? "),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RegisterPage(),
              ),
            );
          },
          child: const Text(
            "Register here",
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
