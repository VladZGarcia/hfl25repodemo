import 'package:flutter/material.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _header(context),
          _inputField(context),
          _forgotPassword(context),
          _singup(context),
        ],
      ),
    );
  }
}

_header(context) {
  return const Column(
    children: [
      Text(
        "Login",
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      Text("Enter you credentials to login"),
    ],
  );
}

_inputField(context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextField(
        decoration: InputDecoration(
          hintText: "username",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          fillColor: Colors.purple.withValues(alpha: 0.1),
          filled: true,
          prefixIcon: const Icon(Icons.person),
        ),
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
        obscureText: true,
      ),
      const SizedBox(height: 10),
      ElevatedButton(
        onPressed: () {
          // Handle login action
        },
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.purple,
        ),
        child: const Text("Login", style: TextStyle(fontSize: 20)),
      ),
    ],
  );
}

_forgotPassword(context) {
  return TextButton(
    onPressed: () {
      // Handle forgot password action
    },
    child: const Text(
      "Forgot Password?",
      style: TextStyle(color: Colors.purple),
    ),
  );
}

_singup(context) {
  return TextButton(
    onPressed: () {
      // Handle sign up action
    },
    child: const Text(
      "Don't have an account? Sign Up",
      style: TextStyle(color: Colors.purple),
    ),
  );
}
