import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersTab extends StatefulWidget {
  @override
  _UsersTabState createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  final List<String> paymentOptions = [
    "Credit Card",
    "Debit Card",
    "PayPal",
    "GCash"
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Users',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('isAdmin', isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  var users = snapshot.data?.docs ?? [];
                  return Column(
                    children: users.map((doc) {
                      var user = doc.data() as Map<String, dynamic>;

                      return Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        margin: EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'First Name: ${user['firstName'] ?? 'N/A'}'),
                                  Text(
                                      'Last Name: ${user['lastName'] ?? 'N/A'}'),
                                  Text('Email: ${user['email'] ?? 'N/A'}'),
                                  Text(
                                      'Selected Payment Method: ${user['selectedPaymentMethod'] ?? 'N/A'}'),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _editUser(context, doc.id, user);
                              },
                              child: Text('Edit'),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }

  void _editUser(
      BuildContext context, String userId, Map<String, dynamic> user) {
    String firstName = user['firstName'] ?? '';
    String lastName = user['lastName'] ?? '';
    String email = user['email'] ?? '';
    String selectedPaymentMethod = user['selectedPaymentMethod'] ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'First Name',
                  hintText: firstName,
                ),
                onChanged: (value) {
                  firstName = value;
                },
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  hintText: lastName,
                ),
                onChanged: (value) {
                  lastName = value;
                },
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: email,
                ),
                onChanged: (value) {
                  email = value;
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedPaymentMethod,
                decoration:
                    InputDecoration(labelText: 'Selected Payment Method'),
                items: paymentOptions.map((option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedPaymentMethod = newValue!;
                  });
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                var updatedUser = {
                  'firstName': firstName,
                  'lastName': lastName,
                  'email': email,
                  'selectedPaymentMethod': selectedPaymentMethod,
                };

                FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .update(updatedUser)
                    .then((value) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('User updated successfully!'),
                    ),
                  );
                }).catchError((error) {
                  print('Error updating user: $error');
                });
              },
              child: Text('Save'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
