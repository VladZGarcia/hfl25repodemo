import 'package:flutter/material.dart';
import 'package:parkingapp/repositories/person_repository.dart';
import 'package:shared/shared.dart';
import 'package:uuid/uuid.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      height: MediaQuery.of(context).size.height - 50,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Column(
            children: <Widget>[
              const SizedBox(height: 60.0),
              const Text(
                "Sign Up",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
                  _handleSignup(
                    context,
                    _usernameController.text,
                    _emailController.text,
                    _passwordController.text,
                    _confirmPasswordController.text,
                    onSignup,
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
                    style: TextStyle(fontSize: 16, color: Colors.purple),
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
    );
  }
}

void _handleSignup(
  BuildContext context,
  String usernameInput,
  String emailInput,
  String passwordInput,
  String confirmPasswordInput,
  VoidCallback onSignup,
) async {
  final String username = usernameInput;
  final String email = emailInput;
  final String password = passwordInput;
  final String confirmPassword = confirmPasswordInput;

  if (password != confirmPassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Passwords do not match"),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }
  try {
    PersonRepository personRepository = PersonRepository();
    var uuid = Uuid();

    // Check if the email already exists
    final List<Person> persons = await personRepository.getAll();
    final bool emailExists = persons.any((person) => person.email == email);
    if (emailExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email already exists"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    await personRepository.addPerson(
      Person(id: uuid.v4(), name: username, email: email, password: password),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Account created successfully"),
        duration: Duration(seconds: 2),
      ),
    );
    onSignup();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Error creating account"),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
