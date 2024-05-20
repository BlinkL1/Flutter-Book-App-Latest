import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'books_tab.dart';
import 'users_tab.dart';

void main() {
  runApp(MaterialApp(
    home: Dashboard(),
  ));
}

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;

  Future<void> _showLogoutConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout Confirmation'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/splashScreen');
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QuestQuill Dashboard'),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _showLogoutConfirmationDialog();
            },
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomePage(),
          BooksTab(),
          UsersTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Books',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Users',
          ),
        ],
        backgroundColor: Colors.white,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int totalUsers = 0;
  int totalMembershipFeePaid = 0;
  int usersRegisteredThisMonth = 0;
  int totalBooks = 0;
  int totalDonations = 0;
  int totalRevenue = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> usersSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('isAdmin', isEqualTo: false)
              .get();

      QuerySnapshot<Map<String, dynamic>> booksSnapshot =
          await FirebaseFirestore.instance.collection('books').get();

      QuerySnapshot<Map<String, dynamic>> donationsSnapshot =
          await FirebaseFirestore.instance.collection('donations').get();

      num totalDonationsCount = donationsSnapshot.docs.fold(
          0, (total, doc) => total + ((doc['donationAmount'] as int?) ?? 0));

      int totalUsersCount = usersSnapshot.size;
      int totalMembershipFee = 0;
      int usersRegisteredThisMonthCount = 0;
      int totalBooksCount = booksSnapshot.size;

      DateTime now = DateTime.now();
      int currentMonth = now.month;

      usersSnapshot.docs.forEach((userDoc) {
        totalMembershipFee += (userDoc['membershipFeePaid'] as int?) ?? 0;

        DateTime registrationDate =
            (userDoc['timestamp'] as Timestamp).toDate();
        if (registrationDate.month == currentMonth) {
          usersRegisteredThisMonthCount++;
        }
      });

      int totalRevenueCount = totalMembershipFee + totalDonationsCount.toInt();

      setState(() {
        totalUsers = totalUsersCount;
        totalMembershipFeePaid = totalMembershipFee;
        usersRegisteredThisMonth = usersRegisteredThisMonthCount;
        totalBooks = totalBooksCount;
        totalDonations = totalDonationsCount.toInt();
        totalRevenue = totalRevenueCount;
      });
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildInfoBox('Total Users', '$totalUsers'),
            _buildInfoBox(
                'Total Membership Fee Paid', '$totalMembershipFeePaid'),
            _buildInfoBox(
              'Total Donations',
              '$totalDonations',
            ),
            _buildInfoBox('Total Revenue', '$totalRevenue'),
            _buildInfoBox(
              'Total Books',
              '$totalBooks',
            ),
            _buildInfoBox(
              'Users Registered This Month',
              '$usersRegisteredThisMonth',
            ),
            ElevatedButton(
              onPressed: () {
                _fetchData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
              ),
              child: Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(String title, String value) {
    return Container(
      margin: EdgeInsets.all(16.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardCounter extends StatelessWidget {
  final String label;
  final int value;

  const DashboardCounter({
    required this.label,
    required this.value,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$label:'),
          SizedBox(width: 8),
          Text('$value'),
        ],
      ),
    );
  }
}
