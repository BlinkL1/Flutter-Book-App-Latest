import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class ResetPasswordScreen extends StatefulWidget {
  ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController emailController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
                  padding: EdgeInsets.only(left: 13.0, top: 98.0, right: 13.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Forgot Password?",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 40.0),
                      _buildEmail(context),
                      SizedBox(height: 24.0),
                      _buildOrLoginWithDivider(context),
                      SizedBox(height: 21.0),
                      Center(
                        child: _buildResetButton(context),
                      ),
                      SizedBox(height: 10.0),
                      Center(child: _buildBackToLogin(context)),
                      SizedBox(height: 28.0),
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

  Widget _buildEmail(BuildContext context) {
    return TextFormField(
      controller: emailController,
      decoration: InputDecoration(
        hintText: "Enter your email",
        errorText: _formKey.currentState?.validate() == false
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
    );
  }

  Widget _buildResetButton(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200.0,
        child: ElevatedButton(
          onPressed: () {
            onTapResetButton(context);
          },
          child: Text(
            "Reset Password",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            primary: Colors.lightBlue,
          ),
        ),
      ),
    );
  }

  Widget _buildBackToLogin(BuildContext context) {
    return TextButton(
      onPressed: () {
        onTapBackToLogin(context);
      },
      child: Text("Back to Login"),
    );
  }

  Future<void> onTapResetButton(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      if (_formKey.currentState?.validate() == false) {
        return;
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text,
      );

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Password Reset'),
          content: Text(
            'A password reset email has been sent to ${emailController.text}. Please check your email to reset your password.',
          ),
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
    } catch (e) {
      print(e.toString());

      if (e is PlatformException) {
        if (e.code == 'user-not-found') {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Password Reset Failed'),
              content: Text(
                'This email is not yet registered. Please register first.',
              ),
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
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}

onTapBackToLogin(BuildContext context) {
  Navigator.pop(context);
}
