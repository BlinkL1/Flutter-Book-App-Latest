import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Screen3 extends StatelessWidget {
  const Screen3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          User? user = snapshot.data;
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 80.0,
                ),
                Center(
                  child: Image.asset(
                    'assets/images/pfp.jpg',
                    width: 100.0,
                    height: 100.0,
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                Center(
                  child: Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: UserProfileWidget(user: user),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          );
        }
      },
    );
  }
}

class UserProfileWidget extends StatelessWidget {
  final User? user;

  const UserProfileWidget({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      return FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            Map<String, dynamic> userData =
                snapshot.data?.data() as Map<String, dynamic>;
            String firstName = userData['firstName'] ?? '';
            String lastName = userData['lastName'] ?? '';
            String email = user!.email ?? '';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'First Name: ',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    '$firstName',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Last Name: ',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    '$lastName',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Email: ',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    '$email',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Location: ',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Davao City, Philippines',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ],
            );
          }
        },
      );
    } else {
      return Center(child: Text('No authenticated user.'));
    }
  }
}
