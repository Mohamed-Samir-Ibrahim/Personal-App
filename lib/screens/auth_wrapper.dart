import 'package:flutter/material.dart';
import 'package:personal_app/models/user_model.dart';
import 'package:personal_app/screens/auth_screen.dart';
import 'package:personal_app/screens/home_screen.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);

    if (user == null) {
      return AuthScreen();
    } else {
      return HomeScreen();
    }
  }
}