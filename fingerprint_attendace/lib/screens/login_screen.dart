import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../database/dao/employee_dao.dart';
import 'dart:math';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();
  final EmployeeDao _employeeDao = EmployeeDao();

  bool _isCodeSent = false;
  String? _verificationCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/arrow_mm.png',
              height: 40,
              width: 40,
            ),
            SizedBox(width: 10),
            Text(
              'Login',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Color(0xFF930000),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.white, // Set the Scaffold background color to white
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 600;

          return isWideScreen
              ? Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              if (!_isCodeSent) ...[
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(labelText: 'Email'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(labelText: 'Password'),
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 20),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        bool authenticated = await _employeeDao.authenticateUser(
                                          _emailController.text.toLowerCase(),
                                          _passwordController.text,
                                        );
                                        if (authenticated) {
                                          // Generate and send verification code
                                          _verificationCode = _generateVerificationCode();
                                          await _sendVerificationCode(_emailController.text, _verificationCode!);

                                          setState(() {
                                            _isCodeSent = true;
                                          });
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Invalid email or password')),
                                          );
                                        }
                                      }
                                    },
                                    child: Text('Login'),
                                  ),
                                ),
                              ] else ...[
                                TextFormField(
                                  controller: _codeController,
                                  decoration: InputDecoration(labelText: 'Verification Code'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the verification code';
                                    }
                                    if (value != _verificationCode) {
                                      return 'Invalid verification code';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 20),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => HomeScreen(email: _emailController.text),
                                          ),
                                        );
                                      }
                                    },
                                    child: Text('Verify and Login'),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/logo.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/logo.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              if (!_isCodeSent) ...[
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(labelText: 'Email'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(labelText: 'Password'),
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 20),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        bool authenticated = await _employeeDao.authenticateUser(
                                          _emailController.text.toLowerCase(),
                                          _passwordController.text,
                                        );
                                        if (authenticated) {
                                          _verificationCode = _generateVerificationCode();
                                          await _sendVerificationCode(_emailController.text, _verificationCode!);

                                          setState(() {
                                            _isCodeSent = true;
                                          });
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Invalid email or password')),
                                          );
                                        }
                                      }
                                    },
                                    child: Text('Login'),
                                  ),
                                ),
                              ] else ...[
                                TextFormField(
                                  controller: _codeController,
                                  decoration: InputDecoration(labelText: 'Verification Code'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the verification code';
                                    }
                                    if (value != _verificationCode) {
                                      return 'Invalid verification code';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 20),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => HomeScreen(email: _emailController.text),
                                          ),
                                        );
                                      }
                                    },
                                    child: Text('Verify and Login'),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }

  String _generateVerificationCode() {
    final random = Random();
    final code = random.nextInt(900000) + 100000;
    return code.toString();
  }

  Future<void> _sendVerificationCode(String email, String code) async {
    // Implement your email sending logic here
    print('Sending verification code $code to $email');
  }
}
