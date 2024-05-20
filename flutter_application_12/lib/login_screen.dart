import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:questquill/HomeScreen.dart';
import 'package:questquill/reset_password_screen.dart';
import 'package:questquill/dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Container(
                  width: double.maxFinite,
                  padding: EdgeInsets.symmetric(horizontal: 7.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 190.0,
                        margin: EdgeInsets.only(left: 4.0),
                        child: Text(
                          "Welcome back! Glad to see you, Again!",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 34.0),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: "Enter your email",
                          errorText: emailController.text.isNotEmpty &&
                                  _formKey.currentState?.validate() == false
                              ? "Email does not exist"
                              : null,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value?.isEmpty == true) {
                            return "Please input your email";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15.0),
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          hintText: "Enter your password",
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                          errorText: passwordController.text.isNotEmpty &&
                                  emailController.text.isNotEmpty &&
                                  _formKey.currentState?.validate() == false
                              ? "Incorrect password"
                              : null,
                        ),
                        obscureText: !isPasswordVisible,
                        validator: (value) {
                          if (value?.isEmpty == true) {
                            return "Please input your password";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24.0),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            onTapLogin(context);
                          },
                          child: Container(
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.lightBlue,
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.0),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResetPasswordScreen(),
                            ),
                          );
                        },
                        child: Center(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Forgot Password? ",
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: "Click here",
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 38.0),
                      _buildOrLoginWithDivider(context),
                      SizedBox(height: 21.0),
                      Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () {
                            onTapTxtDonthaveanaccount(context);
                          },
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Don’t have an",
                                ),
                                TextSpan(
                                  text: " account?",
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                                TextSpan(text: " "),
                                TextSpan(
                                  text: "Register Now",
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5.0),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildOrLoginWithDivider(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 7.0, bottom: 8.0),
          child: SizedBox(width: 100.0, child: Divider()),
        ),
        Text("Quest Quill",
            style: TextStyle(fontSize: 15.0, color: Colors.grey)),
        Padding(
          padding: EdgeInsets.only(top: 7.0, bottom: 8.0),
          child: SizedBox(width: 100.0, child: Divider()),
        ),
      ],
    );
  }

  Future<void> onTapLogin(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      if (_formKey.currentState?.validate() == false) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);

      User? user = userCredential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'unknown-error',
          message: 'User not found or login failed.',
        );
      }

      if (user.emailVerified) {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        bool isAdmin = userData['isAdmin'] ?? false;

        if (isAdmin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Dashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => NavigationScreen()),
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Email Verification Required'),
            content: Text('Please check your email to verify your account.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print(e.toString());

      if (e is FirebaseAuthException) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Login Failed'),
            content: Text(e.message ?? 'Login failed.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}

onTapTxtDonthaveanaccount(BuildContext context) {
  Navigator.pushNamed(context, '/register');
}
