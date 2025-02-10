// // ignore_for_file: avoid_print
import 'dart:io';
import 'package:attendance2/admin/navbarr/screens/mainscreen.dart';
import 'package:attendance2/auth/login_bloc/login_bloc.dart';
import 'package:attendance2/auth/login_bloc/login_event.dart';
import 'package:attendance2/auth/login_bloc/login_state.dart';
import 'package:attendance2/auth/screens/forget_password.dart';
import 'package:attendance2/auth/screens/register_screen.dart';
import 'package:attendance2/department/navbar/screens/mainscreen.dart';
import 'package:attendance2/it_admin/navbar/screens/mainscreen.dart';
import 'package:attendance2/staff/navbar/screens/mainscreen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;

  // Helper for platform-specific widgets
  Widget _platformSpecificWidget({
    required Widget iosWidget,
    required Widget androidWidget,
  }) {
    return Platform.isIOS ? iosWidget : androidWidget;
  }

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
      child: _platformSpecificWidget(
        iosWidget: CupertinoPageScaffold(
          resizeToAvoidBottomInset: true,
          navigationBar: CupertinoNavigationBar(middle: Text('Login')),
          child: _buildLoginContent(),
        ),
        androidWidget: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          body: _buildLoginContent(),
        ),
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
        _platformSpecificWidget(
          iosWidget: BlocBuilder<LoginBloc, LoginState>(
            builder: (context, state) {
              return CupertinoTextField(
                onChanged: (value) =>
                    context.read<LoginBloc>().add(EmailChanged(value)),
                placeholder: "Email",
                prefix: const Icon(CupertinoIcons.mail),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                style: TextStyle(color: Colors.black),
                placeholderStyle:
                    TextStyle(color: Colors.black.withValues(alpha: 0.6)),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(18),
                ),
              );
            },
          ),
          androidWidget: BlocBuilder<LoginBloc, LoginState>(
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
                  fillColor: Colors.purple.withValues(alpha: .1),
                  filled: true,
                  prefixIcon: const Icon(Icons.email),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        _platformSpecificWidget(
          iosWidget: BlocBuilder<LoginBloc, LoginState>(
            builder: (context, state) {
              return CupertinoTextField(
                onChanged: (value) =>
                    context.read<LoginBloc>().add(PasswordChanged(value)),
                obscureText: _obscurePassword,
                placeholder: "Password",
                prefix: const Icon(CupertinoIcons.lock),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                style: TextStyle(color: Colors.black),
                placeholderStyle:
                    TextStyle(color: Colors.black.withValues(alpha: .6)),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                suffix: GestureDetector(
                  onTap: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  child: Icon(
                    _obscurePassword
                        ? CupertinoIcons.eye_slash
                        : CupertinoIcons.eye,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                ),
              );
            },
          ),
          androidWidget: BlocBuilder<LoginBloc, LoginState>(
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
                  fillColor: Colors.purple.withValues(alpha: .1),
                  filled: true,
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
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
        ),
      ],
    );
  }

  Widget _forgotPassword() {
    return _platformSpecificWidget(
      iosWidget: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ForgetPasswordScreen(),
            ),
          );
        },
        child: const Text(
          "Forgot password?",
          style: TextStyle(color: CupertinoColors.activeBlue),
        ),
      ),
      androidWidget: Align(
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
      ),
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: _platformSpecificWidget(
        iosWidget: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            return CupertinoButton.filled(
              onPressed: () => context.read<LoginBloc>().add(LoginSubmitted()),
              child: const Text("Login"),
            );
          },
        ),
        androidWidget: BlocBuilder<LoginBloc, LoginState>(
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
