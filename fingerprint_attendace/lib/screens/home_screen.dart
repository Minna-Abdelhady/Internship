import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../database/dao/employee_dao.dart';
import '../database/dao/location_dao.dart';
import '../models/employee.dart';
import 'dart:convert'; // For base64 decoding
import 'add_user_screen.dart' as add_user_screen; // Import the Add User screen
import 'users_list_screen.dart'; // Import the Users List screen

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
  bool _isSignInButtonEnabled = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<Employee> _fetchEmployeeData() async {
    final employees = await employeeDao.getAllEmployees();
    return employees.firstWhere((employee) => employee.email == widget.email);
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, y').format(date);
  }

  String _formatTime(DateTime date) {
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
      _isSignInButtonEnabled = false;
    });
    print('Login Time: ${_formatTime(_loginTime!)}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Text(
                'Home',
                style: TextStyle(color: Colors.white, fontFamily: 'NotoSans'), // AppBar title color to white
              );
            } else {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/company_logo.jpg',
                    height: kToolbarHeight - 5, // Adjust height to match AppBar height
                  ),
                  Text(
                    'Home',
                    style: TextStyle(color: Colors.white, fontFamily: 'NotoSans'), // AppBar title color to white
                  ),
                ],
              );
            }
          },
        ),
        backgroundColor: Color(0xFF930000), // AppBar color to match company theme
        iconTheme: IconThemeData(
          color: Colors.white, // Back arrow color to white
        ),
        actions: [
          _buildAppBarButton(context, 'Sign In', _isSignInButtonEnabled ? _onSignInPressed : null),
          _buildAppBarButton(context, 'History', () {
            // Navigate to History screen
          }),
          _buildAppBarButton(context, 'Vacations', () {
            // Navigate to Vacations screen
          }),
          _buildAppBarButton(context, 'Create User', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => add_user_screen.AddUserScreen()),
            );
          }),
          _buildAppBarButton(context, 'View Users', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UsersListScreen()),
            );
          }),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white, // Set tab text color to white
          unselectedLabelColor: Colors.white, // Set unselected tab text color to white
          indicatorColor: Colors.white, // Set the indicator color to white
          tabs: [
            Tab(text: 'This Week\'s Transactions'),
            Tab(text: 'Calendar'),
            Tab(text: 'Sign In'),
          ],
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
                      _buildTransactionsView(employee),
                      _buildCalendarView(),
                      _buildSignInView(employee),
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
            CircleAvatar(
              radius: 50,
              backgroundImage: MemoryImage(base64Decode(employee.personalPhoto)),
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
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsView(Employee employee) {
    final DateTime now = DateTime.now();
    final DateTime loginTime = DateTime(now.year, now.month, now.day, 0, 0);
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
      child: TableCalendar(
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
        ),
      ),
    );
  }

  Widget _buildSignInView(Employee employee) {
    final DateTime now = DateTime.now();
    final DateTime loginTime = _loginTime ?? DateTime(now.year, now.month, now.day, 0, 0);
    final DateTime logoutTime = loginTime.add(Duration(hours: 8));
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Today: ${_formatDate(now)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'NotoSans'),
              ),
              SizedBox(width: 20),
              Text(
                'Sign in Time: ${_formatTime(loginTime)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'NotoSans'),
              ),
              SizedBox(width: 20),
              Text(
                'Estimated Sign out Time: ${_formatTime(logoutTime)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'NotoSans'),
              ),
            ],
          ),
          SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _isSignInButtonEnabled ? _onSignInPressed : null,
              child: Text('Sign In'),
            ),
          ),
          if (_loginTime != null)
            Center(
              child: Text(
                'Sign Time: ${_formatTime(_loginTime!)}',
                style: TextStyle(fontSize: 18, color: Colors.black, fontFamily: 'NotoSans'),
              ),
            ),
        ],
      ),
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
            'Sign In : ${_formatTime(loginTime)} - Sign Out : ${_formatTime(logoutTime)}',
            style: TextStyle(fontSize: 18, color: Colors.black, fontFamily: 'NotoSans'),
          ),
        ],
      ),
    );
  }
}
