import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Screen4 extends StatefulWidget {
  const Screen4({Key? key}) : super(key: key);

  @override
  _Screen4State createState() => _Screen4State();
}

class _Screen4State extends State<Screen4> {
  bool isDarkModeEnabled = false;
  bool areNotificationsEnabled = false;

  String? donationAmount;
  String selectedPaymentMethod = 'Debit Card';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            SettingItem(
              title: 'Dark Mode',
              subtitle: 'Toggle dark mode',
              icon: Icons.nightlight_round,
              child: Switch(
                value: isDarkModeEnabled,
                onChanged: (value) {
                  _showFeatureNotImplementedSnackbar('Dark Mode');
                  setState(() {
                    isDarkModeEnabled = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16.0),
            SettingItem(
              title: 'Notifications',
              subtitle: 'Manage notification settings',
              icon: Icons.notifications,
              child: Switch(
                value: areNotificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    areNotificationsEnabled = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Others',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            SettingItem(
              title: 'Support the App!',
              subtitle: 'You can donate to the creator to support them',
              icon: Icons.send,
              child: ElevatedButton(
                onPressed: () {
                  _showSupportScreen(context);
                },
                child: Text('Support'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSupportScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DonationScreen()),
    );
  }

  void _showFeatureNotImplementedSnackbar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sorry, $feature is not implemented yet.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class DonationScreen extends StatefulWidget {
  @override
  _DonationScreenState createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  String? donationAmount;
  String selectedPaymentMethod = 'Debit Card';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donate'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter the amount to donate (PHP):'),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    donationAmount = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              Text('Choose the payment method:'),
              _buildPaymentMethodRadioButtons(),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _showDonationConfirmationDialog();
                },
                child: Text('Donate'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodRadioButtons() {
    List<String> paymentOptions = [
      'Debit Card',
      'Credit Card',
      'PayPal',
      'GCash'
    ];

    return Column(
      children: paymentOptions.map<Widget>((String option) {
        return RadioListTile<String>(
          title: Text(option),
          value: option,
          groupValue: selectedPaymentMethod,
          onChanged: (String? value) {
            if (value != null) {
              setState(() {
                selectedPaymentMethod = value;
              });
            }
          },
        );
      }).toList(),
    );
  }

  void _showDonationConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Donation'),
          content: Text('Are you sure you want to proceed with the donation?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _proceedWithDonation();
              },
              child: Text('Proceed'),
            ),
          ],
        );
      },
    );
  }

  void _proceedWithDonation() {
    if (_validateForm()) {
      _saveDonation();
      _showDonationConfirmationScreen();
    }
  }

  bool _validateForm() {
    if (donationAmount == null || donationAmount!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter the donation amount.'),
      ));
      return false;
    }

    return true;
  }

  void _saveDonation() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        int amount = int.parse(donationAmount!);

        await FirebaseFirestore.instance.collection('donations').add({
          'userId': user.uid,
          'donationAmount': amount,
          'selectedPaymentMethod': selectedPaymentMethod,
        });

        print('Donation saved successfully');
      } catch (e) {
        print('Error parsing donationAmount: $e');
      }
    } else {
      print('User not authenticated');
    }
  }

  void _showDonationConfirmationScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DonationConfirmationScreen()),
    );
  }
}

class DonationConfirmationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donation Successful'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 64.0,
              color: Colors.green,
            ),
            SizedBox(height: 16.0),
            Text(
              'Thank you for your donation!',
              style: TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? child;

  const SettingItem({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: child == null ? null : () {},
      trailing: child,
    );
  }
}
