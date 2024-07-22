import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../database/dao/employee_dao.dart';
import '../models/employee.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AddUserScreen extends StatefulWidget {
  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _directorIdController = TextEditingController();
  final EmployeeDao _employeeDao = EmployeeDao();
  File? _personalPhoto;
  Uint8List? _webImage;
  bool _isAdmin = false; // New field to track if the user is an admin

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
        });
      } else {
        setState(() {
          _personalPhoto = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _addUser() async {
    if (_formKey.currentState!.validate() && (_personalPhoto != null || _webImage != null)) {
      final hashedPassword = _hashPassword(_passwordController.text);
      final employee = Employee(
        id: DateTime.now().millisecondsSinceEpoch,
        companyId: _companyIdController.text,
        name: _nameController.text.toLowerCase(),
        email: _emailController.text,
        password: hashedPassword,
        personalPhoto: kIsWeb ? base64Encode(_webImage!) : base64Encode(await _personalPhoto!.readAsBytes()),
        jobTitle: _jobTitleController.text,
        directorId: _directorIdController.text,
        isAdmin: _isAdmin, // Set the new field
      );

      try {
        await _employeeDao.createEmployee(employee);
        print('User added: ${employee.toMap()}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User added successfully')),
        );

        _companyIdController.clear();
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _jobTitleController.clear();
        _directorIdController.clear();
        setState(() {
          _personalPhoto = null;
          _webImage = null;
          _isAdmin = false; // Reset the admin field
        });
      } catch (e) {
        print('Error adding user: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding user')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete the form and upload a photo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add User',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF930000),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildTextField(_companyIdController, 'Company ID'),
                _buildTextField(_nameController, 'Name'),
                _buildTextField(_emailController, 'Email'),
                _buildTextField(_passwordController, 'Password', obscureText: true),
                _buildTextField(_jobTitleController, 'Job Title'),
                _buildTextField(_directorIdController, 'Director ID'),
                SizedBox(height: 10),
                Text(
                  'Role',
                  style: TextStyle(color: Color(0xFF930000), fontSize: 16),
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: Text('Admin'),
                        value: true,
                        groupValue: _isAdmin,
                        onChanged: (value) {
                          setState(() {
                            _isAdmin = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: Text('Employee'),
                        value: false,
                        groupValue: _isAdmin,
                        onChanged: (value) {
                          setState(() {
                            _isAdmin = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Personal Photo',
                  style: TextStyle(color: Color(0xFF930000), fontSize: 16),
                ),
                SizedBox(height: 10),
                kIsWeb
                    ? _webImage == null
                        ? ElevatedButton(
                            onPressed: _pickImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF930000), // Button color
                            ),
                            child: Text(
                              'Upload Photo',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : Image.memory(
                            _webImage!,
                            height: 150,
                          )
                    : _personalPhoto == null
                        ? ElevatedButton(
                            onPressed: _pickImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF930000), // Button color
                            ),
                            child: Text(
                              'Upload Photo',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : Image.file(
                            _personalPhoto!,
                            height: 150,
                          ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF930000),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: Text(
                    'Add User',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Color(0xFF930000)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        obscureText: obscureText,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
