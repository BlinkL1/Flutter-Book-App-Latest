import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:questquill/login_screen.dart';
import 'package:email_validator/email_validator.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isAdmin = false;

  String? selectedPaymentMethod;
  static const double membershipFee = 250.0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Container(
                    width: double.maxFinite,
                    padding:
                        EdgeInsets.only(left: 13.0, top: 98.0, right: 13.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello! Register to get started",
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 40.0),
                        _buildFirstName(context),
                        SizedBox(height: 12.0),
                        _buildLastName(context),
                        SizedBox(height: 12.0),
                        _buildEmail(context),
                        SizedBox(height: 12.0),
                        _buildPassword(context),
                        SizedBox(height: 24.0),
                        _buildPaymentMethodSelection(),
                        Center(
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                onTapRegisterButton(context);
                              },
                              child: Text(
                                "Register (250 PHP)",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.lightBlue,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        _buildOrLoginWithDivider(context),
                        SizedBox(height: 21.0),
                        Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: () {
                              onTapTxtAlreadyhavean(context);
                            },
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Already have an account?",
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                  TextSpan(text: " "),
                                  TextSpan(
                                    text: "Login Now",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildFirstName(BuildContext context) {
    return TextFormField(
      controller: firstNameController,
      decoration: InputDecoration(
        hintText: "First Name",
        errorText: _formKey.currentState?.validate() == false &&
                firstNameController.text.isEmpty
            ? "Please input your first name"
            : null,
      ),
      validator: (value) {
        if (value?.isEmpty == true) {
          return "Please input your first name";
        }
        return null;
      },
    );
  }

  Widget _buildLastName(BuildContext context) {
    return TextFormField(
      controller: lastNameController,
      decoration: InputDecoration(
        hintText: "Last Name",
        errorText: _formKey.currentState?.validate() == false &&
                lastNameController.text.isEmpty
            ? "Please input your last name"
            : null,
      ),
      validator: (value) {
        if (value?.isEmpty == true) {
          return "Please input your last name";
        }
        return null;
      },
    );
  }

  Widget _buildEmail(BuildContext context) {
    return TextFormField(
      controller: emailController,
      decoration: InputDecoration(
        hintText: "Email",
        errorText: _formKey.currentState?.validate() == false &&
                !EmailValidator.validate(emailController.text)
            ? "Please input a valid email"
            : null,
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value?.isEmpty == true) {
          return "Please input your email";
        }
        if (!EmailValidator.validate(value!)) {
          return "Please input a valid email";
        }
        return null;
      },
    );
  }

  Widget _buildPassword(BuildContext context) {
    return TextFormField(
      controller: passwordController,
      decoration: InputDecoration(
        hintText: "Password",
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              isPasswordVisible = !isPasswordVisible;
            });
          },
        ),
        errorText: (passwordController.text.isNotEmpty &&
                passwordController.text.length < 6)
            ? "Password must be at least 6 characters"
            : null,
      ),
      obscureText: !isPasswordVisible,
      validator: (value) {
        if (value?.isEmpty == true) {
          return "Please input your password";
        } else if (value!.length < 6) {
          return "Password must be at least 6 characters";
        }
        return null;
      },
    );
  }

  Widget _buildOrLoginWithDivider(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 7.0, bottom: 8.0),
          child: SizedBox(width: 112.0, child: Divider()),
        ),
        Text(
          "Quest Quill",
          style: TextStyle(fontSize: 15.0, color: Colors.grey),
        ),
        Padding(
          padding: EdgeInsets.only(top: 7.0, bottom: 8.0),
          child: SizedBox(width: 111.0, child: Divider()),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Column(
      children: [
        RadioListTile<String>(
          title: Text('Debit Card'),
          value: 'Debit Card',
          groupValue: selectedPaymentMethod,
          onChanged: (value) {
            setState(() {
              selectedPaymentMethod = value;
            });
          },
        ),
        RadioListTile<String>(
          title: Text('Credit Card'),
          value: 'Credit Card',
          groupValue: selectedPaymentMethod,
          onChanged: (value) {
            setState(() {
              selectedPaymentMethod = value;
            });
          },
        ),
        RadioListTile<String>(
          title: Text('PayPal'),
          value: 'PayPal',
          groupValue: selectedPaymentMethod,
          onChanged: (value) {
            setState(() {
              selectedPaymentMethod = value;
            });
          },
        ),
        RadioListTile<String>(
          title: Text('GCash'),
          value: 'GCash',
          groupValue: selectedPaymentMethod,
          onChanged: (value) {
            setState(() {
              selectedPaymentMethod = value;
            });
          },
        ),
      ],
    );
  }

  Future<void> onTapRegisterButton(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      if (_formKey.currentState?.validate() == false) {
        return;
      }

      if (!isAdmin && selectedPaymentMethod == null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Payment Option Required'),
            content: Text(
              'Please select a payment option.',
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
        return;
      }

      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      User? user = userCredential.user;

      if (user != null) {
        await user.updateDisplayName(
            "${firstNameController.text} ${lastNameController.text}");

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'email': user.email,
          'isAdmin': isAdmin,
          'selectedPaymentMethod': isAdmin ? null : selectedPaymentMethod,
          'membershipFeePaid': isAdmin ? null : membershipFee,
          'timestamp': FieldValue.serverTimestamp(),
        });

        await user.sendEmailVerification();

        print('Registration successful. Verification email sent.');

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Email Verification Required'),
            content: Text(
              'Please check your email to verify your account.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text('OK'),
              ),
            ],
          ),
        );

        if (!isAdmin) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Payment Successful'),
              content: Text(
                'Thank you for your payment! You can now access additional features.',
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
      } else {
        print('Error: User is null after registration.');
      }
    } catch (e) {
      print('Error during registration: $e');
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Email Already in Use'),
              content: Text(
                'This email is already used.',
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
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Registration Failed'),
              content: Text(
                'An error existed during registration. Please try again later.',
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

  onTapTxtAlreadyhavean(BuildContext context) {
    Navigator.pushNamed(context, '/login');
  }
}
