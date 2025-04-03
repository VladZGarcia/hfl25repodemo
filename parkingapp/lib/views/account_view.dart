import 'package:flutter/material.dart';

class AccountView extends StatelessWidget{
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container( // Add a Container for debugging

      color: Colors.red, // Set a different background color

      child: const Center(child: Text('Account View')),

    );

  
  }
}