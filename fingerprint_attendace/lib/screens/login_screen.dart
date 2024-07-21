// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import '../widgets/login_form.dart';
import 'users_list_screen.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('Building LoginScreen'); // Debug print
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            LoginForm(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UsersListScreen()),
                );
              },
              child: Text('View Users'),
            ),
          ],
        ),
      ),
    );
  }
}
