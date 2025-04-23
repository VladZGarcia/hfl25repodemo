import 'package:flutter/material.dart';
import 'package:parkingapp/main.dart';
import 'package:parkingapp/repositories/person_repository.dart';
import 'package:parkingapp/views/settings_view.dart';
import 'package:parkingapp/views/signup_view.dart';
import 'package:shared/shared.dart';

class AccountView extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onSignup;

  AccountView({super.key, required this.onLogin, required this.onSignup});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _header(context),
            _inputField(
              context,
              _emailController,
              _passwordController,
              onLogin,
            ),
            _forgotPassword(context),
            _singup(context, onSignup),
          ],
        ),
      ),
    );
  }
}

_header(context) {
  return const Column(
    children: [
      Text(
        "Login",
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
      Text("Enter you credentials to login"),
    ],
  );
}

_inputField(
  context,
  TextEditingController _emailController,
  TextEditingController _passwordController,
  onLoggout,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextField(
        decoration: InputDecoration(
          hintText: "email",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          fillColor: Colors.purple.withValues(alpha: 0.1),
          filled: true,
          prefixIcon: const Icon(Icons.email),
        ),
        controller: _emailController,
      ),
      const SizedBox(height: 10),
      TextField(
        decoration: InputDecoration(
          hintText: "password",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          fillColor: Colors.purple.withValues(alpha: 0.1),
          filled: true,
          prefixIcon: const Icon(Icons.lock),
        ),
        controller: _passwordController,
        obscureText: true,
      ),
      const SizedBox(height: 10),
      ElevatedButton(
        onPressed: () {
          if (_emailController.text.isEmpty ||
              _passwordController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Please fill in all fields"),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            _handleLogin(
              context,
              _emailController.text,
              _passwordController.text,
              onLoggout,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.purple,
        ),
        child: const Text(
          "Login",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    ],
  );
}

void _handleLogin(
  context,
  String emailInput,
  String passwordInput,
  onLoggout,
) async {
  PersonRepository personRepository = PersonRepository();
  final List<Person> persons = await personRepository.getAll();
  final bool emailExists = persons.any((person) => person.email == emailInput);

  if (emailExists) {
    onLoggout();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Invalid email or password"),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
  }
}

_forgotPassword(context) {
  return TextButton(
    onPressed: () {
      // Handle forgot password action
      // You can navigate to a forgot password screen or show a dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Forgot Password not implemented yet"),
          duration: Duration(seconds: 2),
        ),
      );
    },
    child: const Text(
      "Forgot Password?",
      style: TextStyle(color: Colors.purple),
    ),
  );
}

_singup(context, VoidCallback onSignup) {
  return TextButton(
    onPressed: () {
      onSignup();
      // Handle sign up action
    },
    child: const Text(
      "Don't have an account? Sign Up",
      style: TextStyle(color: Colors.purple),
    ),
  );
}
