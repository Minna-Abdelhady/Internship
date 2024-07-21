import 'package:flutter/material.dart';
import '../database/dao/user_dao.dart';
import '../models/user.dart';

class AddUserScreen extends StatefulWidget {
  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final UserDao _userDao = UserDao();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final hashedPassword = _userDao.hashPassword(_passwordController.text);
                    final user = User(
                      username: _usernameController.text,
                      passwordHash: hashedPassword,
                    );
                    await _userDao.createUser(user);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('User added successfully')),
                    );

                    _usernameController.clear();
                    _passwordController.clear();
                  }
                },
                child: Text('Add User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
