import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../database/dao/employee_dao.dart';
import '../models/employee.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:email_validator/email_validator.dart';

class AddUserScreen extends StatefulWidget {
  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _jobTitleController = TextEditingController();
  String? _selectedDirectorId;
  final EmployeeDao _employeeDao = EmployeeDao();
  File? _personalPhoto;
  Uint8List? _webImage;
  bool _isAdmin = false;
  List<Employee> _directors = []; // List to hold director objects

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

  Future<void> _fetchDirectors() async {
    final directors = await _employeeDao.getAllDirectors();
    setState(() {
      _directors = directors;
    });
  }

  Future<bool> _emailExists(String email) async {
    return await _employeeDao.emailExists(email);
  }

  bool _directorExists(String directorId) {
    // Check if the selected director ID is in the list of available directors
    return _directors.any((director) => director.id.toString() == directorId);
  }

  Future<void> _addUser() async {
    if (_formKey.currentState!.validate() && (_personalPhoto != null || _webImage != null)) {
      if (await _emailExists(_emailController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email already exists')),
        );
        return;
      }
      if (_selectedDirectorId != null && _directorExists(_selectedDirectorId!)) {
        final hashedPassword = _hashPassword(_passwordController.text);
        final employee = Employee(
          id: DateTime.now().millisecondsSinceEpoch,
          companyId: _companyIdController.text,
          name: _emailController.text.split('@')[0], // Use the email username part for name
          email: _emailController.text,
          password: hashedPassword,
          personalPhoto: kIsWeb ? base64Encode(_webImage!) : base64Encode(await _personalPhoto!.readAsBytes()),
          jobTitle: _jobTitleController.text,
          directorId: _selectedDirectorId!,
          isAdmin: _isAdmin,
        );

        try {
          await _employeeDao.createEmployee(employee);
          print('User added: ${employee.toMap()}');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User added successfully')),
          );
        } catch (e) {
          print('Error adding user: $e');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected director does not exist')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDirectors(); // Fetch directors when the screen initializes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add User'),
        backgroundColor: Color(0xFF930000),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_companyIdController, 'Company ID'),
              _buildTextField(_emailController, 'Email', validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
                }
                if (!EmailValidator.validate(value)) {
                  return 'Invalid email';
                }
                return null;
              }),
              _buildTextField(_passwordController, 'Password', obscureText: true),
              _buildTextField(_jobTitleController, 'Job Title'),
              DropdownButtonFormField<String>(
                value: _selectedDirectorId,
                hint: Text('Select Director'),
                items: _directors.map((director) {
                  return DropdownMenuItem<String>(
                    value: director.id.toString(),
                    child: Text(director.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDirectorId = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Director ID',
                  labelStyle: TextStyle(color: Color(0xFF930000)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              kIsWeb
                ? _webImage == null
                    ? ElevatedButton(
                        onPressed: _pickImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF930000),
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
                          backgroundColor: Color(0xFF930000),
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
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false, String? Function(String?)? validator}) {
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
        validator: validator ?? (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
