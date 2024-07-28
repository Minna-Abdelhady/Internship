import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../database/dao/employee_dao.dart';
import '../database/dao/location_dao.dart';
import '../models/employee.dart';
import 'dart:convert'; // For base64 decoding
import 'add_user_screen.dart' as add_user_screen; // Import the Add User screen
import 'users_list_screen.dart'; // Import the Users List screen
import 'login_screen.dart'; // Import the Login screen

class HomeScreen extends StatefulWidget {
  final String email;

  HomeScreen({required this.email});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final EmployeeDao employeeDao = EmployeeDao();
  final LocationDao locationDao = LocationDao();
  DateTime? _loginTime;
  DateTime? _logoutTime;
  bool _isSignInButtonEnabled = true;
  bool _isSignOutButtonEnabled = false;
  bool _isSignedOut = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this); // Set to 6 tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<Employee> _fetchEmployeeData() async {
    final employees = await employeeDao.getAllEmployees();
    return employees.firstWhere((employee) => employee.email.toLowerCase() == widget.email.toLowerCase());
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, y').format(date);
  }

  String _formatTime(DateTime? date) {
    if (date == null) {
      return "00:00";
    }
    return DateFormat('h:mm a').format(date);
  }

  final Map<DateTime, List<String>> _holidays = {
    DateTime.utc(2024, 1, 1): ['New Year\'s Day'],
    DateTime.utc(2024, 1, 25): ['Revolution Day'],
    DateTime.utc(2024, 4, 25): ['Sinai Liberation Day'],
    DateTime.utc(2024, 5, 1): ['Labor Day'],
    DateTime.utc(2024, 6, 30): ['Revolution Day'],
    DateTime.utc(2024, 7, 23): ['Revolution Day'],
    DateTime.utc(2024, 10, 6): ['Armed Forces Day'],
  };

  void _onSignInPressed() {
    setState(() {
      _loginTime = DateTime.now();
      _logoutTime = _loginTime!.add(Duration(hours: 8)); // Update logout time
      _isSignInButtonEnabled = false;
      _isSignOutButtonEnabled = true;
      _isSignedOut = false;
    });
    print('Sign In Time: ${_formatTime(_loginTime!)}');
  }

  void _onSignOutPressed() {
    setState(() {
      _logoutTime = DateTime.now();
      _isSignedOut = true;
      _isSignInButtonEnabled = true;
      _isSignOutButtonEnabled = false;
    });
    print('Sign Out Time: ${_formatTime(_logoutTime!)}');
  }

  void _onFaceIdPressed() {
    // Implement Face ID functionality here
    print('Face ID pressed');
  }

  void _onFingerprintPressed() {
    // Implement Fingerprint functionality here
    print('Fingerprint pressed');
  }

  void _onLogoutPressed() {
    // Implement navigation to login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF930000), // AppBar color to match company theme
        iconTheme: IconThemeData(
          color: Colors.white, // Back arrow color to white
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0), // Remove extra space above the tabs
          child: Container(
            color: Color(0xFF930000),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white, // Set tab text color to white
              unselectedLabelColor: Colors.white, // Set unselected tab text color to white
              indicatorColor: Colors.white, // Set the indicator color to white
              indicator: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white,
                    width: 4.0,
                  ),
                ),
              ),
              tabs: [
                Tab(text: 'Sign In'),
                Tab(text: 'This Week\'s Transactions'),
                Tab(text: 'Calendar'),
                Tab(text: 'Vacations'),
                Tab(text: 'Create User'),
                Tab(text: 'View Users'),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white, // Set the Scaffold background color to white
      body: FutureBuilder<Employee>(
        future: _fetchEmployeeData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.black, fontFamily: 'NotoSans')));
          } else if (!snapshot.hasData) {
            return Center(child: Text('User not found', style: TextStyle(color: Colors.black, fontFamily: 'NotoSans')));
          } else {
            final employee = snapshot.data!;
            return Row(
              children: [
                Flexible(
                  flex: 1,
                  child: _buildProfileSide(employee),
                ),
                Flexible(
                  flex: 3,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSignInView(employee),
                      _buildTransactionsView(employee),
                      _buildCalendarView(),
                      _buildVacationsView(),
                      _buildCreateUserView(),
                      _buildViewUsersView(),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildProfileSide(Employee employee) {
    return Container(
      color: Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100, // Define the width of the square avatar
              height: 100, // Define the height of the square avatar
              decoration: BoxDecoration(
                shape: BoxShape.rectangle, // Ensure the shape is rectangular
                image: DecorationImage(
                  image: MemoryImage(base64Decode(employee.personalPhoto)),
                  fit: BoxFit.cover, // Ensure the image covers the entire container
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Welcome, ${employee.name}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF930000), // Text color to match company theme
                fontFamily: 'NotoSans',
              ),
            ),
            SizedBox(height: 20),
            _buildInfoColumn(employee),
            SizedBox(height: 20), // Add some space before the new text
            Divider(color: Colors.black), // Add a separation line
            Text(
              'Today: ${_formatDate(DateTime.now())}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'NotoSans'),
            ),
            Text(
              'Signed In At: ${_formatTime(_loginTime)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'NotoSans'),
            ),
            Text(
              _isSignedOut
                  ? 'Signed Out At: ${_formatTime(_logoutTime)}'
                  : 'Expected Sign Out Time: ${_formatTime(_logoutTime)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'NotoSans'),
            ),
            Spacer(),
            ElevatedButton.icon(
              onPressed: _onLogoutPressed,
              icon: Icon(Icons.logout),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF930000), // Button color to match company theme
              ),
              label: Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsView(Employee employee) {
    final DateTime now = DateTime.now();
    final DateTime loginTime = DateTime(now.year, now.month, now.day, 9, 43);
    final DateTime logoutTime = loginTime.add(Duration(hours: 8));
    final Map<String, Map<String, DateTime>> weekTransactions = {
      'Sunday': {'login': DateTime(now.year, now.month, now.day - now.weekday + 5, 9, 0), 'logout': DateTime(now.year, now.month, now.day - now.weekday + 5, 17, 0)},
      'Monday': {'login': DateTime(now.year, now.month, now.day - now.weekday + 1, 9, 0), 'logout': DateTime(now.year, now.month, now.day - now.weekday + 1, 17, 0)},
      'Tuesday': {'login': DateTime(now.year, now.month, now.day - now.weekday + 2, 9, 43), 'logout': DateTime(now.year, now.month, now.day - now.weekday + 2, 0, 0)},
      'Wednesday': {'login': DateTime(now.year, now.month, now.day - now.weekday + 3, 0, 0), 'logout': DateTime(now.year, now.month, now.day - now.weekday + 3, 0, 0)},
      'Thursday': {'login': DateTime(now.year, now.month, now.day - now.weekday + 4, 9, 0), 'logout': DateTime(now.year, now.month, now.day - now.weekday + 4, 0, 0)},
    };

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Week\'s Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'NotoSans'),
            ),
            SizedBox(height: 10),
            for (var day in weekTransactions.keys)
              _buildTransactionRow(day, weekTransactions[day]!['login']!, weekTransactions[day]!['logout']!),
          ],
        ),
      ),
    );
  }

Widget _buildCalendarView() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
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
              color: Color(0xFF930000),
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Color.fromARGB(255, 162, 7, 7),
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
                  style: TextStyle(color: Colors.blue),
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
                    style: TextStyle().copyWith(color: Colors.red), // Set weekend text color to red
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
}

Widget _buildColorIndicator(Color color, String label) {
  return Row(
    children: [
      Container(
        width: 20,
        height: 20,
        color: color,
      ),
      SizedBox(width: 8),
      Text(label),
    ],
  );
}

  Widget _buildSignInView(Employee employee) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _isSignInButtonEnabled ? _onSignInPressed : null,
                  icon: Icon(Icons.location_on),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(250, 150), // Set the button size
                  ),
                  label: Text('Sign In'),
                ),
                SizedBox(width: 50),
                ElevatedButton.icon(
                  onPressed: _isSignOutButtonEnabled ? _onSignOutPressed : null,
                  icon: Icon(Icons.location_on),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(250, 150), // Set the button size
                  ),
                  label: Text('Sign Out'),
                ),
              ],
            ),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _onFaceIdPressed,
                  icon: Icon(Icons.face),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(250, 150), // Set the button size
                  ),
                  label: Text('Face ID'),
                ),
                SizedBox(width: 50),
                ElevatedButton.icon(
                  onPressed: _onFingerprintPressed,
                  icon: Icon(Icons.fingerprint),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(250, 150), // Set the button size
                  ),
                  label: Text('Fingerprint'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVacationsView() {
    return Center(
      child: Text('Vacations View'),
    );
  }

  Widget _buildCreateUserView() {
    return Center(
      child: Text('Create User View'),
    );
  }

  Widget _buildViewUsersView() {
    return Center(
      child: Text('View Users View'),
    );
  }

  Widget _buildAppBarButton(BuildContext context, String title, VoidCallback? onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          title,
          style: TextStyle(color: Colors.white, fontFamily: 'NotoSans'),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(Employee employee) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Employee ID:', employee.companyId),
        SizedBox(height: 10),
        _buildInfoRow('Job Title:', employee.jobTitle),
        SizedBox(height: 10),
        _buildInfoRow('Email:', employee.email),
        SizedBox(height: 10),
        _buildInfoRow('Director ID:', employee.directorId),
        SizedBox(height: 10),
        _buildInfoRow('Role:', employee.isAdmin ? 'Admin' : 'Employee'),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'NotoSans'),
        ),
        SizedBox(width: 10), // Adjusted the width to avoid out-of-bounds error
        Flexible(
          child: Text(
            value,
            style: TextStyle(fontSize: 18, color: Colors.black, fontFamily: 'NotoSans'),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionRow(String day, DateTime loginTime, DateTime logoutTime) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$day:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'NotoSans'),
          ),
          SizedBox(width: 10), // Adjusted the width to avoid out-of-bounds error
          Text(
            'Login: ${_formatTime(loginTime)} - Logout: ${_formatTime(logoutTime)}',
            style: TextStyle(fontSize: 18, color: Colors.black, fontFamily: 'NotoSans'),
          ),
        ],
      ),
    );
  }
}
