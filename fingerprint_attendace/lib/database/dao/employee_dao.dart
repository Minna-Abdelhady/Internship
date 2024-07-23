import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../models/employee.dart';
import 'package:email_validator/email_validator.dart';

class EmployeeDao {
  static const String _employeeBoxName = 'employeeBox';

  Future<void> createEmployee(Employee employee) async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);
    print('Adding employee: ${employee.toMap()}');
    await box.add(employee); // Use add to let Hive manage the key
    print('Employee added');
  }

  Future<List<Employee>> getAllEmployees() async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);
    return box.values.toList();
  }

  Future<void> updateEmployee(int id, Employee updatedEmployee) async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);
    final key = box.keys.firstWhere((k) => (box.get(k) as Employee).id == id);
    await box.put(key, updatedEmployee);
  }

  Future<void> deleteEmployee(int id) async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);
    final key = box.keys.firstWhere((k) => (box.get(k) as Employee).id == id);
    await box.delete(key);
  }

  Future<bool> authenticateUser(String name, String password) async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);
    final hashedPassword = _hashPassword(password);
    try {
      final employee = box.values.firstWhere(
        (employee) => employee.name == name.toLowerCase() && employee.password == hashedPassword,
      );
      return employee != null;
    } catch (e) {
      return false;
    }
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  Future<void> insertDummyData() async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);

    // Load the image from assets and convert it to base64
    final byteData = await rootBundle.load('assets/Apartments.PNG');
    final imageBytes = byteData.buffer.asUint8List();
    final base64Image = base64Encode(imageBytes);

    final byteData1 = await rootBundle.load('assets/Nouna.jpg');
    final imageBytes1 = byteData1.buffer.asUint8List();
    final base64Image1 = base64Encode(imageBytes1);

    final dummyEmployees = [
      Employee(
        id: 1,
        companyId: '123456',
        name: 'nouna',
        email: 'nouna@example.com',
        password: _hashPassword('123'),
        personalPhoto: base64Image1,
        jobTitle: 'Software Engineer',
        directorId: '456',
        isAdmin: true,
      ),
      Employee(
        id: 2,
        companyId: '654321',
        name: 'minna',
        email: 'minna@example.com',
        password: _hashPassword('123'),
        personalPhoto: base64Image,
        jobTitle: 'Product Manager',
        directorId: '123',
        isAdmin: true,
      ),
      Employee(
        id: 3,
        companyId: '789012',
        name: 'mike johnson',
        email: 'mike.johnson@example.com',
        password: _hashPassword('password3'),
        personalPhoto: base64Image,
        jobTitle: 'UX Designer',
        directorId: '789',
        isAdmin: false,
      ),
    ];

    for (var employee in dummyEmployees) {
      await box.add(employee); // Use add to let Hive manage the key
      print('Dummy employee added: ${employee.name}');
    }
  }

  Future<bool> emailExists(String email) async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);
    return box.values.any((employee) => employee.email == email);
  }
}

// AddUserScreen widget implementation
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
  bool _isAdmin = false;

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

  Future<bool> _emailExists(String email) async {
    return await _employeeDao.emailExists(email);
  }

  Future<bool> _directorExists(String directorId) async {
    // Placeholder function. Replace with actual implementation.
    return Future.delayed(Duration(seconds: 2), () => true);
  }

  Future<void> _addUser() async {
    if (_formKey.currentState!.validate() && (_personalPhoto != null || _webImage != null)) {
      if (await _emailExists(_emailController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email already exists')),
        );
        return;
      }
      if (await _directorExists(_directorIdController.text)) {
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
          isAdmin: _isAdmin,
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
            _isAdmin = false;
          });
        } catch (e) {
          print('Error adding user: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding user')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Director ID does not exist')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete the form and upload a photo')),
      );
    }
  }

  bool _validatePassword(String password) {
    // Password must be at least 8 characters, contain a number and a special character
    final regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$');
    return regex.hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/company_logo.jpg',
              height: 40,
              width: 40,
            ),
            SizedBox(width: 10),
            Text('Add User'),
          ],
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
                _buildTextField(
                  _emailController,
                  'Email',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Email';
                    } else if (!EmailValidator.validate(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  _passwordController,
                  'Password',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Password';
                    } else if (!_validatePassword(value)) {
                      return 'Password must be at least 8 characters, contain a number and a special character';
                    }
                    return null;
                  },
                ),
                _buildTextField(_jobTitleController, 'Job Title'),
                _buildTextField(_directorIdController, 'Director ID'),
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
