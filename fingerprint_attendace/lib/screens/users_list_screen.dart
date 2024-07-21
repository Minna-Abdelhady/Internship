import 'package:flutter/material.dart';
import '../database/dao/user_dao.dart';
import '../models/user.dart';

class UsersListScreen extends StatelessWidget {
  final UserDao userDao = UserDao();

  Future<List<User>> _fetchUsers() async {
    return await userDao.getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users List'),
      ),
      body: FutureBuilder<List<User>>(
        future: _fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No users found'));
          } else {
            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user.username),
                );
              },
            );
          }
        },
      ),
    );
  }
}
