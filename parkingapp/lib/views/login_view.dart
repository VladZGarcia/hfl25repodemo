import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkingapp/blocs/login/login_bloc.dart';
import 'package:parkingapp/blocs/login/login_event.dart';
import 'package:parkingapp/blocs/login/login_state.dart';

class LoginView extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onSignup;

  LoginView({super.key, required this.onLogin, required this.onSignup});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
        if (state is LoginSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Login successful")));
          
        }
      },
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.symmetric(horizontal: 40),
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 50,
          ),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(context),
              _inputField(context, _emailController, _passwordController),
              _forgotPassword(context),
              _singup(context, onSignup),
              // Optionally show loading indicator here if needed
            ],
          ),
        ),
      ),
    );
  }

  _header(context) {
    return Column(
      children: [
        const SizedBox(height: 60.0),
        const Text(
          "Login",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Text(
          "Enter you credentials to login",
          style: TextStyle(fontSize: 15, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _inputField(
    BuildContext context,
    TextEditingController _emailController,
    TextEditingController _passwordController,
  ) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
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
                fillColor: Color.fromRGBO(
                  128,
                  0,
                  128,
                  0.1,
                ), // 128,0,128 is purple
                filled: true,
                prefixIcon: const Icon(Icons.email),
              ),
              controller: _emailController,
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: "password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                fillColor: Color.fromRGBO(
                  128,
                  0,
                  128,
                  0.1,
                ), // 128,0,128 is purple
                filled: true,
                prefixIcon: const Icon(Icons.lock),
              ),
              controller: _passwordController,
              obscureText: true,
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed:
                  (state is LoginLoading)
                      ? null
                      : () {
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
                          context.read<LoginBloc>().add(
                            LoginSubmitted(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                            ),
                          );
                        }
                      },
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.purple,
              ),
              child:
                  (state is LoginLoading)
                      ? const CircularProgressIndicator()
                      : const Text(
                        "Login",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
            ),
          ],
        );
      },
    );
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account?"),
        TextButton(
          onPressed: () {
            onSignup();
          },
          child: const Text("Sign Up", style: TextStyle(color: Colors.purple)),
        ),
      ],
    );
  }
}
