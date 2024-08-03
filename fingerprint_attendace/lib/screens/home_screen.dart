import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../database/dao/employee_dao.dart';
import '../database/dao/attendance_dao.dart';
import '../models/employee.dart';
import '../models/attendance.dart';
import 'dart:convert'; // For base64 decoding
import 'package:email_validator/email_validator.dart';
import 'login_screen.dart'; // Import the Login screen
import 'package:flutter_map/flutter_map.dart' as flutterMap;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:geolocator/geolocator.dart';
import '../utils/location_utils.dart';

class HomeScreen extends StatefulWidget {
  final String email;

  HomeScreen({required this.email});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final EmployeeDao employeeDao = EmployeeDao();
  final AttendanceDao attendanceDao = AttendanceDao();
  DateTime? _loginTime;
  DateTime? _logoutTime;
  bool _isSignInButtonEnabled = true;
  bool _isSignOutButtonEnabled = false;
  bool _isSignedOut = false;
  late TabController _tabController;
  final Map<DateTime, List<String>> _holidays = {
    DateTime.utc(2024, 1, 1): ['New Year\'s Day'],
    DateTime.utc(2024, 1, 25): ['Revolution Day'],
    DateTime.utc(2024, 4, 25): ['Sinai Liberation Day'],
    DateTime.utc(2024, 5, 1): ['Labor Day'],
    DateTime.utc(2024, 6, 30): ['Revolution Day'],
    DateTime.utc(2024, 7, 23): ['Revolution Day'],
    DateTime.utc(2024, 10, 6): ['Armed Forces Day'],
  };

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _companyIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  File? _personalPhoto;
  Uint8List? _webImage;
  bool _isAdmin = false;
  List<Employee> _employees = [];
  Employee? _selectedDirector;
  bool _isCurrentUserAdmin = false;
  Employee? _currentUser;

  Position? _currentPosition;
  GoogleMapController? _mapController;
  late TabController _tabController1;

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
    _getCurrentLocation();
  }

  Future<void> _loadEmployeeData() async {
    _currentUser = await _fetchEmployeeData();
    _isCurrentUserAdmin = _currentUser!.isAdmin;
    _tabController = TabController(
      length: _isCurrentUserAdmin ? 6 : 4,
      vsync: this,
    );
    _loadEmployees();
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    _employees = await employeeDao.getAllEmployees();
    setState(() {});
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
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

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _currentPosition = position;
      });
    });
  }

  Future<bool> _emailExists(String email) async {
    return await employeeDao.emailExists(email);
  }

  Future<bool> _employeeIdExists(int employeeId) async {
    return await employeeDao.employeeIdExists(employeeId);
  }

  Future<void> _addUser() async {
    if (_formKey.currentState!.validate() &&
        (_personalPhoto != null || _webImage != null)) {
      final companyIdText = _companyIdController.text;
      final companyIdInt = int.tryParse(companyIdText);

      if (companyIdInt == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid Company ID format')),
        );
        return;
      }

      if (await _employeeIdExists(companyIdInt)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Employee ID already exists')),
        );
        return;
      }

      if (await _emailExists(_emailController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email already exists')),
        );
        return;
      }

      if (_selectedDirector == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Director ID does not exist')),
        );
        return;
      }

      final hashedPassword = _hashPassword(_passwordController.text);

      final employee = Employee(
        companyId: companyIdInt,
        name: _nameController.text,
        email: _emailController.text,
        password: hashedPassword,
        personalPhoto: kIsWeb
            ? base64Encode(_webImage!)
            : base64Encode(await _personalPhoto!.readAsBytes()),
        jobTitle: _jobTitleController.text,
        directorId: _selectedDirector!.companyId,
        isAdmin: _isAdmin,
      );

      try {
        await employeeDao.createEmployee(employee);
        print('User added: ${employee.toMap()}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User added successfully')),
        );

        _companyIdController.clear();
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _jobTitleController.clear();
        setState(() {
          _personalPhoto = null;
          _webImage = null;
          _isAdmin = false;
          _selectedDirector = null;
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

  bool _validatePassword(String password) {
    final regex = RegExp(
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$');
    return regex.hasMatch(password);
  }

  Future<Employee> _fetchEmployeeData() async {
    final employees = await employeeDao.getAllEmployees();
    return employees.firstWhere((employee) =>
        employee.email.toLowerCase() == widget.email.toLowerCase());
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, y').format(date);
  }

  bool _isSignedIn = false;

  Future<void> _onSignInPressed() async {
    if (_currentPosition == null ||
        !isWithinCompanyBounds(
            _currentPosition!.latitude, _currentPosition!.longitude)) {
      _showPopupMessage('You are out of the company bounds');
      return;
    }

    setState(() {
      _loginTime = DateTime.now();
      _logoutTime = _loginTime!.add(Duration(hours: 8));
      _isSignInButtonEnabled = false;
      _isSignOutButtonEnabled = true;
      _isSignedOut = false;
      _isSignedIn = true;
    });

    final attendance = Attendance(
      userId: _currentUser!.companyId,
      transactionType: 'Sign In',
      date: DateTime.now(),
      signInTime: _loginTime!,
      signOutTime: _logoutTime!,
    );

    await attendanceDao.createOrUpdateAttendance(attendance);

    print('Sign In Time: ${_formatTime(_loginTime!)}');
    setState(() {});
  }

  Future<void> _onSignOutPressed() async {
    if (_currentPosition == null ||
        !isWithinCompanyBounds(
            _currentPosition!.latitude, _currentPosition!.longitude)) {
      _showPopupMessage('You are out of the company bounds');
      return;
    }

    setState(() {
      _logoutTime = DateTime.now();
      _isSignedOut = true;
      _isSignInButtonEnabled = true;
      _isSignOutButtonEnabled = false;
      _isSignedIn = false;
    });

    final attendances =
        await attendanceDao.getAttendanceByUserId(_currentUser!.companyId);
    final todayAttendance = attendances.lastWhere(
      (attendance) =>
          attendance.date.year == DateTime.now().year &&
          attendance.date.month == DateTime.now().month &&
          attendance.date.day == DateTime.now().day,
      orElse: () => Attendance(
        userId: _currentUser!.companyId,
        transactionType: 'Sign Out',
        date: DateTime.now(),
        signInTime: _loginTime!,
        signOutTime: _logoutTime!,
      ),
    );

    final updatedAttendance = Attendance(
      userId: todayAttendance.userId,
      transactionType: 'Sign Out',
      date: todayAttendance.date,
      signInTime: todayAttendance.signInTime,
      signOutTime: _logoutTime!,
    );

    await attendanceDao.createOrUpdateAttendance(updatedAttendance);

    print('Sign Out Time: ${_formatTime(_logoutTime!)}');
    setState(() {});
  }

  void _showPopupMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _onFaceIdPressed() {
    print('Face ID pressed');
  }

  void _onFingerprintPressed() {
    print('Fingerprint pressed');
  }

  void _onLogoutPressed() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {bool obscureText = false, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle:
              TextStyle(color: Color(0xFFAF2C3F), fontFamily: 'Montserrat'),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        style: TextStyle(fontFamily: 'Montserrat'), // Set default font
        validator: validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $labelText';
              }
              return null;
            },
      ),
    );
  }

Widget _buildAttendanceView(Employee employee) {
  return FutureBuilder<List<Attendance>>(
    future: attendanceDao.getAttendanceByUserId(employee.companyId),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(
            child: Text('Error: ${snapshot.error}',
                style: TextStyle(
                    color: Colors.black, fontFamily: 'Montserrat')));
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return Center(
            child: Text('No attendance records found',
                style: TextStyle(
                    color: Colors.black, fontFamily: 'Montserrat')));
      } else {
        final attendanceRecords = snapshot.data!;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              columnSpacing: 20.0,
              columns: [
                DataColumn(
                  label: Text(
                    'Date',
                    style: TextStyle(
                        color: Colors.black, fontFamily: 'Montserrat'),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Sign In',
                    style: TextStyle(
                        color: Colors.black, fontFamily: 'Montserrat'),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Sign Out',
                    style: TextStyle(
                        color: Colors.black, fontFamily: 'Montserrat'),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Total Hours',
                    style: TextStyle(
                        color: Colors.black, fontFamily: 'Montserrat'),
                  ),
                ),
              ],
              rows: attendanceRecords.map((attendance) {
                final totalHours = attendance.signOutTime
                    .difference(attendance.signInTime)
                    .inHours;
                return DataRow(
                  cells: [
                    DataCell(Text(
                        DateFormat('dd-MM-yyyy').format(attendance.date),
                        style: TextStyle(
                            color: Colors.black, fontFamily: 'Montserrat'))),
                    DataCell(Text(
                        DateFormat('h:mm:ss a').format(attendance.signInTime),
                        style: TextStyle(
                            color: Colors.black, fontFamily: 'Montserrat'))),
                    DataCell(Text(
                        DateFormat('h:mm:ss a').format(attendance.signOutTime),
                        style: TextStyle(
                            color: Colors.black, fontFamily: 'Montserrat'))),
                    DataCell(Text(totalHours.toString(),
                        style: TextStyle(
                            color: Colors.black, fontFamily: 'Montserrat'))),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      }
    },
  );
}

@override
Widget build(BuildContext context) {
  // Define the threshold for switching between mobile and desktop views
  const double desktopWidthThreshold = 1366;
  const double desktopHeightThreshold = 600;

  // Get the current screen size
  final screenSize = MediaQuery.of(context).size;

  // Determine if the view should be mobile or desktop
  bool isMobileView = screenSize.width < desktopWidthThreshold ||
      screenSize.height < desktopHeightThreshold;

  return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Color(0xFFAF2C3F),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      title: isMobileView
          ? Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            )
          : null,
      bottom: !isMobileView
          ? PreferredSize(
              preferredSize: Size.fromHeight(-8.0),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: Color(0xFFAF2C3F),
                  unselectedLabelColor: Color(0xFFAF2C3F),
                  indicatorColor: Color(0xFFAF2C3F),
                  indicator: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFAF2C3F),
                        width: 4.0,
                      ),
                    ),
                  ),
                  tabs: _buildTabs(),
                ),
              ),
            )
          : null,
      actions: isMobileView
          ? [
              Padding(
                padding: const EdgeInsets.only(right: 8.0), // Adjust padding as needed
                child: Image.asset(
                  'assets/arrow_mm.png', // Path to your logo file
                  height: 40, // Adjust the height as needed
                ),
              ),
            ]
          : [],
    ),
    drawer: isMobileView
        ? Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  child: Text(
                    'Menu',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFAF2C3F),
                  ),
                ),
                ..._buildDrawerItems(),
              ],
            ),
          )
        : null,
    backgroundColor: Colors.white,
    body: FutureBuilder<Employee>(
      future: _fetchEmployeeData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: Colors.black, fontFamily: 'Montserrat'),
            ),
          );
        } else if (!snapshot.hasData) {
          return Center(
            child: Text(
              'User not found',
              style: TextStyle(color: Colors.black, fontFamily: 'Montserrat'),
            ),
          );
        } else {
          final employee = snapshot.data!;
          return LayoutBuilder(
            builder: (context, constraints) {
              if (!isMobileView) {
                return Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        color: Color(0xFFAF2C3F),
                        child: _buildDesktopProfileSide(employee),
                      ),
                    ),
                    Flexible(
                      flex: 3,
                      child: TabBarView(
                        controller: _tabController,
                        children: _buildTabViews(employee),
                      ),
                    ),
                  ],
                );
              } else {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildMobileProfile(employee),
                      Container(
                        height: screenSize.height, // Make the TabBarView fill the remaining space
                        child: TabBarView(
                          controller: _tabController,
                          children: _buildTabViews(employee),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        }
      },
    ),
  );
}

Widget _buildDesktopProfileSide(Employee employee) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Image.asset(
              'assets/arrow_mm.png', // Path to your logo file
              height: 60, // Adjust the height as needed
            ),
            SizedBox(width: 16),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(12), // Add rounded corners
                border: Border.all(
                    color: Colors.white, width: 2), // Add a white border
                image: DecorationImage(
                  image: MemoryImage(base64Decode(employee.personalPhoto)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Welcome, ${employee.name}',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: _buildInfoColumn(employee, false), // Pass false for desktop view
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(color: Colors.white),
            _buildInfoRow('Today:', _formatDate(DateTime.now()), true, false),
            _buildInfoRow('Signed In At:', _formatTime(_loginTime), true, false),
            _buildInfoRow(
              _isSignedOut ? 'Signed Out At:' : 'Expected Sign Out Time:',
              _formatTime(_logoutTime),
              true, false,
            ),
          ],
        ),
      ),
      Spacer(),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: _onLogoutPressed,
          icon: Icon(Icons.logout, color: Color(0xFFAF2C3F)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            minimumSize: Size(double.infinity, 50), // Full width button
          ),
          label: Text(
            'Log Out',
            style: TextStyle(
                color: Color(0xFFAF2C3F), fontFamily: 'Montserrat'),
          ),
        ),
      ),
    ],
  );
}

Widget _buildMobileProfile(Employee employee) {
  return Container(
    color: Color(0xFFAF2C3F),
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              children: [
                Container(
                  width: 100,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(12), // Add rounded corners
                    border: Border.all(
                        color: Colors.white, width: 1), // Add a white border
                    image: DecorationImage(
                      image: MemoryImage(base64Decode(employee.personalPhoto)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _onLogoutPressed,
                  icon: Icon(Icons.logout, color: Color(0xFFAF2C3F), size: 16),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(90, 30), // Smaller size
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Adjust padding
                  ),
                  label: Text(
                    'Log Out',
                    style: TextStyle(
                        color: Color(0xFFAF2C3F), fontFamily: 'Montserrat', fontSize: 12),
                  ),
                ),
              ],
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${employee.name}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildInfoColumn(employee, true), // Pass true for mobile view
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        Divider(color: Colors.white),
        Container(
          color: Color(0xFFAF2C3F),
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Today:', _formatDate(DateTime.now()), true, true),
              _buildInfoRow('Signed In At:', _formatTime(_loginTime), true, true),
              _buildInfoRow(
                _isSignedOut ? 'Signed Out At:' : 'Expected Sign Out Time:',
                _formatTime(_logoutTime),
                true, true,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}  
  
  List<Widget> _buildTabs() {
    List<Widget> tabs = [
      Tab(text: 'Sign In'),
      Tab(text: 'This Week\'s Transactions'),
      Tab(text: 'Calendar'),
      Tab(text: 'View Attendance'),
    ];
    if (_isCurrentUserAdmin) {
      tabs.addAll([
        Tab(text: 'Create User'),
        Tab(text: 'View Users'),
      ]);
    }
    return tabs;
  }

  List<Widget> _buildDrawerItems() {
    List<Widget> drawerItems = [
      ListTile(
        title: Text('Sign In'),
        onTap: () {
          Navigator.pop(context);
          _tabController.index = 0;
        },
      ),
      ListTile(
        title: Text('This Week\'s Transactions'),
        onTap: () {
          Navigator.pop(context);
          _tabController.index = 1;
        },
      ),
      ListTile(
        title: Text('Calendar'),
        onTap: () {
          Navigator.pop(context);
          _tabController.index = 2;
        },
      ),
      ListTile(
        title: Text('View Attendance'),
        onTap: () {
          Navigator.pop(context);
          _tabController.index = 3;
        },
      ),
    ];
    if (_isCurrentUserAdmin) {
      drawerItems.addAll([
        ListTile(
          title: Text('Create User'),
          onTap: () {
            Navigator.pop(context);
            _tabController.index = 4;
          },
        ),
        ListTile(
          title: Text('View Users'),
          onTap: () {
            Navigator.pop(context);
            _tabController.index = 5;
          },
        ),
      ]);
    }
    return drawerItems;
  }

  List<Widget> _buildTabViews(Employee employee) {
    List<Widget> tabViews = [
      _buildSignInView(employee),
      _buildTransactionsView(employee),
      _buildCalendarView(),
      _buildAttendanceView(employee),
    ];
    if (_isCurrentUserAdmin) {
      tabViews.addAll([
        _buildCreateUserView(),
        _buildViewUsersView(),
      ]);
    }
    return tabViews;
  }

Widget _buildProfileSide(Employee employee, bool isMobileView) {
  return SingleChildScrollView(
    child: ConstrainedBox(
      constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
      child: Container(
        color: Color(0xFFAF2C3F),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: isMobileView ? 100 : 80, // Adjust width for full screen
              height: isMobileView ? 100 : 80, // Adjust height for full screen
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(12), // Add rounded corners
                border: Border.all(
                    color: Colors.white, width: 1), // Add a white border
                image: DecorationImage(
                  image: MemoryImage(base64Decode(employee.personalPhoto)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Welcome, ${employee.name}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Montserrat',
              ),
            ),
            SizedBox(height: 15),
            _buildInfoColumn(employee, isMobileView),
            SizedBox(height: 15),
            Divider(color: Colors.white),
            Container(
              color: Color(0xFFAF2C3F),
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Today:', _formatDate(DateTime.now()), true, isMobileView),
                  _buildInfoRow('Signed In At:', _formatTime(_loginTime), true, isMobileView),
                  _buildInfoRow(
                    _isSignedOut ? 'Signed Out At:' : 'Expected Sign Out Time:',
                    _formatTime(_logoutTime),
                    true, isMobileView,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _onLogoutPressed,
              icon: Icon(Icons.logout, color: Color(0xFFAF2C3F)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              label: Text(
                'Log Out',
                style: TextStyle(
                    color: Color(0xFFAF2C3F), fontFamily: 'Montserrat'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildInfoColumn(Employee employee, bool isMobileView) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildInfoRow('Employee ID:', employee.companyId.toString(), true, isMobileView),
      SizedBox(height: 3),
      _buildInfoRow('Job Title:', employee.jobTitle, true, isMobileView),
      SizedBox(height: 3),
      _buildInfoRow('Email:', employee.email, true, isMobileView),
      SizedBox(height: 3),
      FutureBuilder<String>(
        future: _getDirectorName(employee.directorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildInfoRow('Director:', 'Loading...', true, isMobileView);
          } else if (snapshot.hasError) {
            return _buildInfoRow('Director:', 'Error', true, isMobileView);
          } else {
            return _buildInfoRow(
                'Director:', snapshot.data ?? 'Unknown', true, isMobileView);
          }
        },
      ),
      SizedBox(height: 3),
      _buildInfoRow('Role:', employee.isAdmin ? 'Admin' : 'Employee', true, isMobileView),
      SizedBox(height: 3),
    ],
  );
}

Widget _buildInfoRow(String label, String value, bool increaseSize, bool isMobileView) {
  return Row(
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: increaseSize ? (isMobileView ? 14 : 18) : (isMobileView ? 12 : 16), // Adjust size for mobile
          fontWeight: FontWeight.bold,
          color: Colors.grey[200], // Set label color to grey
          fontFamily: 'Montserrat',
        ),
      ),
      SizedBox(width: 10),
      Expanded(
        child: Text(
          value,
          style: TextStyle(
            fontSize: increaseSize ? (isMobileView ? 12 : 16) : (isMobileView ? 10 : 14), // Adjust size for mobile
            color: Colors.white, // Set text color to white
            fontFamily: 'Montserrat',
          ),
        ),
      ),
    ],
  );
}  
  
  Widget _buildTransactionsView(Employee employee) {
    return FutureBuilder<List<Attendance>>(
      future: attendanceDao.getAttendanceForWeek(employee.companyId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}',
                style: TextStyle(color: Colors.black)),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text('No attendance records found',
                style: TextStyle(color: Colors.black)),
          );
        } else {
          final attendanceRecords = snapshot.data!;

          // Define weekdays, excluding Fridays and Saturdays
          final weekdays = [
            'Sunday',
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday'
          ];

          // Map to store transactions
          final weekTransactions = <String, Map<String, DateTime>>{};

          // Get today's date
          final today = DateTime.now();

          // Process and group attendance records by date
          for (var record in attendanceRecords) {
            final dateStr = DateFormat('yyyy-MM-dd').format(record.date);
            final day = DateFormat('EEEE').format(record.date);

            // Exclude today's date
            if (record.date.isBefore(today) && weekdays.contains(day)) {
              if (!weekTransactions.containsKey(dateStr)) {
                weekTransactions[dateStr] = {
                  'login': record.signInTime,
                  'logout': record.signOutTime,
                };
              } else {
                final existingRecord = weekTransactions[dateStr]!;
                if (record.signInTime.isBefore(existingRecord['login']!)) {
                  existingRecord['login'] = record.signInTime;
                }
                if (record.signOutTime.isAfter(existingRecord['logout']!)) {
                  existingRecord['logout'] = record.signOutTime;
                }
              }
            }
          }

          // Sort the transactions by date
          final sortedDates = weekTransactions.keys.toList()..sort();

          return LayoutBuilder(
            builder: (context, constraints) {
              bool isLargeScreen = constraints.maxWidth > 600;
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This Week\'s Transactions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'NotoSans',
                        ),
                      ),
                      SizedBox(height: 10),
                      Column(
                        children: sortedDates.map((dateStr) {
                          final transactions = weekTransactions[dateStr]!;
                          final date = DateTime.parse(dateStr);
                          final dayName = DateFormat('EEEE').format(date);
                          return Card(
                            color: Color(0xFFAF2C3F),
                            elevation: 3,
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        dayName,
                                        style: TextStyle(
                                          fontSize: isLargeScreen ? 18 : 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: 'NotoSans',
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        '${DateFormat('dd-MM-yyyy').format(date)}',
                                        style: TextStyle(
                                          fontSize: isLargeScreen ? 18 : 14,
                                          color: Colors.white,
                                          fontFamily: 'NotoSans',
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Signed In At: ${_formatTime(transactions['login'])}',
                                        style: TextStyle(
                                          fontSize: isLargeScreen ? 18 : 14,
                                          color: Colors.white,
                                          fontFamily: 'NotoSans',
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Signed Out At: ${_formatTime(transactions['logout'])}',
                                        style: TextStyle(
                                          fontSize: isLargeScreen ? 18 : 14,
                                          color: Colors.white,
                                          fontFamily: 'NotoSans',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  String _formatTime(DateTime? time) {
    return time != null ? DateFormat('h:mm a').format(time) : 'Not available';
  }

Widget _buildCalendarView() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: LayoutBuilder(
      builder: (context, constraints) {
        bool isMobileView = constraints.maxWidth < 600;
        if (isMobileView) {
          return SingleChildScrollView(
            child: Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2020, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  focusedDay: DateTime.now(),
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.sunday,
                  daysOfWeekVisible: true,
                  calendarStyle: CalendarStyle(
                    isTodayHighlighted: true,
                    selectedDecoration: BoxDecoration(
                      color: Color(0xFFAF2C3F),
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  holidayPredicate: (day) {
                    return _holidays.containsKey(day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    // Handle day selection
                  },
                  calendarBuilders: CalendarBuilders(
                    holidayBuilder: (context, day, focusedDay) {
                      return Center(
                        child: Text(
                          '${day.day}\n${_holidays[day]?.join(", ")}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.blue, fontFamily: 'Montserrat'),
                        ),
                      );
                    },
                    defaultBuilder: (context, day, focusedDay) {
                      if (day.weekday == DateTime.friday || day.weekday == DateTime.saturday) {
                        return Container(
                          margin: const EdgeInsets.all(4.0),
                          alignment: Alignment.center,
                          child: Text(
                            day.day.toString(),
                            style: TextStyle().copyWith(
                              color: Colors.red,
                              fontFamily: 'Montserrat', // Set weekend text color to red
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildColorIndicator(Colors.red, 'Weekend'),
                    SizedBox(width: 16.0),
                    _buildColorIndicator(Colors.blue, 'Holiday'),
                  ],
                ),
              ],
            ),
          );
        } else {
          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: DateTime.now(),
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.sunday,
                daysOfWeekVisible: true,
                calendarStyle: CalendarStyle(
                  isTodayHighlighted: true,
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFFAF2C3F),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                holidayPredicate: (day) {
                  return _holidays.containsKey(day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  // Handle day selection
                },
                calendarBuilders: CalendarBuilders(
                  holidayBuilder: (context, day, focusedDay) {
                    return Center(
                      child: Text(
                        '${day.day}\n${_holidays[day]?.join(", ")}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.blue, fontFamily: 'Montserrat'),
                      ),
                    );
                  },
                  defaultBuilder: (context, day, focusedDay) {
                    if (day.weekday == DateTime.friday || day.weekday == DateTime.saturday) {
                      return Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        child: Text(
                          day.day.toString(),
                          style: TextStyle().copyWith(
                            color: Colors.red,
                            fontFamily: 'Montserrat', // Set weekend text color to red
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildColorIndicator(Colors.red, 'Weekend'),
                  SizedBox(width: 16.0),
                  _buildColorIndicator(Colors.blue, 'Holiday'),
                ],
              ),
            ],
          );
        }
      },
    ),
  );
}

Widget _buildColorIndicator(Color color, String text) {
  return Row(
    children: [
      Container(
        width: 16,
        height: 16,
        color: color,
      ),
      SizedBox(width: 8),
      Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontFamily: 'Montserrat',
        ),
      ),
    ],
  );
}

Widget _buildSignInView(Employee employee) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobileView = constraints.maxWidth < 600;
          if (isMobileView) {
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isSignedIn ? _onSignOutPressed : _onSignInPressed,
                    icon: Icon(Icons.location_on, size: 20),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(200, 60),
                      textStyle: TextStyle(fontSize: 16, fontFamily: 'Montserrat'),
                      backgroundColor: Color(0xFFAF2C3F),
                    ),
                    label: Text(_isSignedIn ? 'Sign Out' : 'Sign In'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _onFaceIdPressed,
                    icon: Icon(Icons.face, size: 20),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(200, 60),
                      textStyle: TextStyle(fontSize: 16, fontFamily: 'Montserrat'),
                      backgroundColor: Color(0xFFAF2C3F),
                    ),
                    label: Text('Face ID'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _onFingerprintPressed,
                    icon: Icon(Icons.fingerprint, size: 20),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(200, 60),
                      textStyle: TextStyle(fontSize: 16, fontFamily: 'Montserrat'),
                      backgroundColor: Color(0xFFAF2C3F),
                    ),
                    label: Text('Fingerprint'),
                  ),
                  SizedBox(height: 20),
                  _buildMapView(),
                ],
              ),
            );
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isSignedIn ? _onSignOutPressed : _onSignInPressed,
                      icon: Icon(Icons.location_on, size: 30),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(250, 150),
                        textStyle: TextStyle(fontSize: 20, fontFamily: 'Montserrat'),
                        backgroundColor: Color(0xFFAF2C3F),
                      ),
                      label: Text(_isSignedIn ? 'Sign Out' : 'Sign In'),
                    ),
                    SizedBox(width: 50),
                    ElevatedButton.icon(
                      onPressed: _onFaceIdPressed,
                      icon: Icon(Icons.face, size: 30),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(250, 150),
                        textStyle: TextStyle(fontSize: 20, fontFamily: 'Montserrat'),
                        backgroundColor: Color(0xFFAF2C3F),
                      ),
                      label: Text('Face ID'),
                    ),
                    SizedBox(width: 50),
                    ElevatedButton.icon(
                      onPressed: _onFingerprintPressed,
                      icon: Icon(Icons.fingerprint, size: 30),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(250, 150),
                        textStyle: TextStyle(fontSize: 20, fontFamily: 'Montserrat'),
                        backgroundColor: Color(0xFFAF2C3F),
                      ),
                      label: Text('Fingerprint'),
                    ),
                  ],
                ),
                SizedBox(height: 50),
                _buildMapView(),
              ],
            );
          }
        },
      ),
    ),
  );
}

Widget _buildMapView() {
  return _currentPosition == null
      ? CircularProgressIndicator()
      : Container(
          height: 300,
          width: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          margin: EdgeInsets.all(10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: flutterMap.FlutterMap(
              options: flutterMap.MapOptions(
                center: latlong.LatLng(_currentPosition!.latitude,
                    _currentPosition!.longitude),
                zoom: 15,
              ),
              children: [
                flutterMap.TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                flutterMap.MarkerLayer(
                  markers: [
                    flutterMap.Marker(
                      point: latlong.LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude),
                      builder: (ctx) => Container(
                        child: Icon(Icons.location_on,
                            size: 40, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
}  
  
  Widget _buildCreateUserView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildTextField(_companyIdController, "Employee's ID"),
              _buildTextField(_nameController, 'Name'),
              _buildTextField(
                _emailController,
                'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Email';
                  } else if (!EmailValidator.validate(value)) {
                    return 'Please enter a valid email address';
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
                    return 'Password must be at least 8 characters long, contain a number, and a special character';
                  }
                  return null;
                },
              ),
              _buildTextField(_jobTitleController, 'Job Title'),
              DropdownButtonFormField<Employee>(
                value: _selectedDirector,
                items: _employees.map((employee) {
                  return DropdownMenuItem<Employee>(
                    value: employee,
                    child: Text(employee.name,
                        style: TextStyle(fontFamily: 'Montserrat')),
                  );
                }).toList(),
                onChanged: (Employee? newValue) {
                  setState(() {
                    _selectedDirector = newValue;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Director',
                  labelStyle: TextStyle(
                      color: Color(0xFFAF2C3F), fontFamily: 'Montserrat'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a director';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              Text(
                'Role',
                style: TextStyle(
                    color: Color(0xFFAF2C3F),
                    fontSize: 16,
                    fontFamily: 'Montserrat'),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: Text('Admin',
                          style: TextStyle(fontFamily: 'Montserrat')),
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
                      title: Text('Employee',
                          style: TextStyle(fontFamily: 'Montserrat')),
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
                style: TextStyle(
                    color: Color(0xFFAF2C3F),
                    fontSize: 16,
                    fontFamily: 'Montserrat'),
              ),
              SizedBox(height: 10),
              kIsWeb
                  ? _webImage == null
                      ? ElevatedButton(
                          onPressed: _pickImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFAF2C3F),
                          ),
                          child: Text(
                            'Upload Photo',
                            style: TextStyle(
                                color: Colors.white, fontFamily: 'Montserrat'),
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
                            backgroundColor: Color(0xFFAF2C3F),
                          ),
                          child: Text(
                            'Upload Photo',
                            style: TextStyle(
                                color: Colors.white, fontFamily: 'Montserrat'),
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
                  backgroundColor: Color(0xFFAF2C3F),
                ),
                child: Text(
                  'Add User',
                  style:
                      TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewUsersView() {
    return FutureBuilder<List<Employee>>(
      future: employeeDao.getAllEmployees(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}',
                style:
                    TextStyle(color: Colors.black, fontFamily: 'Montserrat')),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text('No users found',
                style:
                    TextStyle(color: Colors.black, fontFamily: 'Montserrat')),
          );
        } else {
          final employees = snapshot.data!;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(
                    label: Text('ID',
                        style: TextStyle(
                            color: Colors.black, fontFamily: 'Montserrat'))),
                DataColumn(
                    label: Text('Name',
                        style: TextStyle(
                            color: Colors.black, fontFamily: 'Montserrat'))),
                DataColumn(
                    label: Text('Email',
                        style: TextStyle(
                            color: Colors.black, fontFamily: 'Montserrat'))),
                DataColumn(
                    label: Text('Photo',
                        style: TextStyle(
                            color: Colors.black, fontFamily: 'Montserrat'))),
                DataColumn(
                    label: Text('Job Title',
                        style: TextStyle(
                            color: Colors.black, fontFamily: 'Montserrat'))),
                DataColumn(
                    label: Text('Director',
                        style: TextStyle(
                            color: Colors.black, fontFamily: 'Montserrat'))),
                DataColumn(
                    label: Text('Is Admin',
                        style: TextStyle(
                            color: Colors.black, fontFamily: 'Montserrat'))),
              ],
              rows: employees.map((employee) {
                return DataRow(
                  cells: [
                    DataCell(Text(employee.companyId.toString(),
                        style: TextStyle(
                            color: Colors.black, fontFamily: 'Montserrat'))),
                    DataCell(Text(employee.name,
                        style: TextStyle(
                            color: Colors.black, fontFamily: 'Montserrat'))),
                    DataCell(Text(employee.email,
                        style: TextStyle(
                            color: Colors.black, fontFamily: 'Montserrat'))),
                    DataCell(
                      employee.personalPhoto.isEmpty
                          ? Text('No Photo',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Montserrat'))
                          : Image.memory(
                              base64Decode(employee.personalPhoto),
                              height: 50,
                              width: 50,
                            ),
                    ),
                    DataCell(Text(employee.jobTitle,
                        style: TextStyle(
                            color: Colors.black, fontFamily: 'Montserrat'))),
                    DataCell(FutureBuilder<String>(
                      future: _getDirectorName(employee.directorId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text('Loading...',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Montserrat'));
                        } else if (snapshot.hasError) {
                          return Text('Error',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Montserrat'));
                        } else {
                          return Text(snapshot.data ?? 'Unknown',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Montserrat'));
                        }
                      },
                    )),
                    DataCell(Text(employee.isAdmin ? 'Admin' : 'Employee',
                        style: TextStyle(
                            color: Colors.black, fontFamily: 'Montserrat'))),
                  ],
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }

  Future<String> _getDirectorName(int directorId) async {
    if (directorId == 0) {
      return 'Unknown';
    }
    final director = await employeeDao.getEmployeeByCompanyId(directorId);
    print('Director ID: $directorId, Name: ${director.name}');
    return director.name;
  }

  Widget _buildTransactionRow(
      String day, DateTime loginTime, DateTime logoutTime) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$day:',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Montserrat'),
          ),
          SizedBox(width: 10),
          Text(
            'Login: ${_formatTime(loginTime)} - Logout: ${_formatTime(logoutTime)}',
            style: TextStyle(
                fontSize: 18, color: Colors.black, fontFamily: 'Montserrat'),
          ),
        ],
      ),
    );
  }
}
