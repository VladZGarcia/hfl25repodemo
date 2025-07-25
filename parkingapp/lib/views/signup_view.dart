import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkingapp/blocs/signup/signup_bloc.dart';
import 'package:parkingapp/blocs/signup/signup_event.dart';
import 'package:parkingapp/blocs/signup/signup_state.dart';

class SignupView extends StatelessWidget {
  final VoidCallback onSignup;

  SignupView({super.key, required this.onSignup});

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignupBloc, SignupState>(
      listener: (context, state) {
        if (state is SignupFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
        if (state is SignupSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Account created successfully")),
          );
          onSignup();
        }
      },
      child: BlocBuilder<SignupBloc, SignupState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.symmetric(horizontal: 40),
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 90,
              ),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      const SizedBox(height: 60.0),
                      const Text(
                        "Sign up",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Create your account",
                        style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
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
                        controller: _usernameController,
                      ),
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          hintText: "password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: Colors.purple.withValues(alpha: 0.1),
                          filled: true,
                          prefixIcon: const Icon(Icons.password),
                        ),
                        controller: _passwordController,
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          hintText: "confirm password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: Colors.purple.withValues(alpha: 0.1),
                          filled: true,
                          prefixIcon: const Icon(Icons.password),
                        ),
                        controller: _confirmPasswordController,
                        obscureText: true,
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 3, left: 3),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_usernameController.text.isEmpty ||
                            _emailController.text.isEmpty ||
                            _passwordController.text.isEmpty ||
                            _confirmPasswordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please fill all fields"),
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          context.read<SignupBloc>().add(
                            SignupSubmitted(
                              username: _usernameController.text,
                              email: _emailController.text,
                              password: _passwordController.text,
                              confirmPassword: _confirmPasswordController.text,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(
                          side: BorderSide(color: Colors.purple),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.purple,
                      ),
                      child: const Text(
                        "Sign up",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                  const Center(child: Text("Or")),
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.purple, width: 1.5),
                    ),
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Google login not implemented yet"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        // Handle login action
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 30.0,
                            width: 30.0,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                  "assets/images/web_neutral_rd_na@4x.png",
                                ),
                                fit: BoxFit.cover,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 18),
                          const Text(
                            "Sign in with Google",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () {
                          onSignup();

                          // Handle login action
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
