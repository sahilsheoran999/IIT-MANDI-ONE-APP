import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/pages/login_page.dart';
import 'package:project/styles/fontstyle.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String displayName = "Loading...";
  String rollNumber = "Loading...";
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  final _helpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _helpController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userEmail = user.email ?? "";
      if (userEmail.isNotEmpty) {
        try {
          DocumentSnapshot userDoc =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userEmail)
                  .get();

          if (userDoc.exists) {
            setState(() {
              displayName = userDoc.get('name') ?? "Unknown";
              rollNumber = userDoc.get('rollNumber') ?? "BXXXXX";
            });
          } else {
            setState(() {
              displayName = "Unknown User";
              rollNumber = "BXXXXX";
            });
          }
        } catch (e) {
          setState(() {
            displayName = "Error loading name";
            rollNumber = "Error";
          });
        }
      }
    }
  }

  void _showFeedbackBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Send Feedback', style: subheadingStyle(context)),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _feedbackController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Describe your feedback or issue...',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your feedback';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          await FirebaseFirestore.instance
                              .collection('feedback')
                              .add({
                                'userEmail':
                                    FirebaseAuth.instance.currentUser?.email ??
                                    'anonymous',
                                'userName': displayName,
                                'feedback': _feedbackController.text,
                                'timestamp': FieldValue.serverTimestamp(),
                              });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Feedback submitted successfully!'),
                            ),
                          );
                          _feedbackController.clear();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error submitting feedback: $e'),
                            ),
                          );
                        }
                      }
                    },
                    child: Text('Submit Feedback'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF7a9064),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAboutBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('About IIT Mandi App', style: subheadingStyle(context)),
              SizedBox(height: 20),
              Text(
                'The IIT Mandi App is developed to provide students, faculty, and staff with easy and quick access to campus resources, updates, and essential services. Whether it’s checking announcements, navigating campus, or staying informed about events, the app brings everything together in one place for a smooth and connected experience.\n'
                'Version: 1.0.0\n'
                'Developed by:\n'
                'Aryan Prakash\n'
                'Veedhee Channey\n'
                'Kartavya Sandhu\n'
                'Piyushh Ujjwal\n'
                'Yash Sheoron\n'
                '© 2023 IIT Mandi. All rights reserved',
                style: normalsize(context),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close', style: normalsize(context),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF7a9064),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHelpBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Help and Support', style: subheadingStyle(context)),
                  SizedBox(height: 20),
                  Text(
                    'If you\'re experiencing issues with the app or have complaints, please describe your problem below:',
                    style: normalsize(context),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _helpController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Describe your problem...',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please describe your problem';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_helpController.text.isNotEmpty) {
                        try {
                          await FirebaseFirestore.instance
                              .collection('help_requests')
                              .add({
                                'userEmail':
                                    FirebaseAuth.instance.currentUser?.email ??
                                    'anonymous',
                                'userName': displayName,
                                'issue': _helpController.text,
                                'status': 'pending',
                                'timestamp': FieldValue.serverTimestamp(),
                              });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Your request has been submitted!'),
                            ),
                          );
                          _helpController.clear();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error submitting request: $e'),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please describe your problem'),
                          ),
                        );
                      }
                    },
                    child: Text('Submit Request'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF7a9064),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: h * 0.05),
            Padding(
              padding: const EdgeInsets.all(0),
              child: Text('Settings', style: mainHeadingStyle(context)),
            ),
            SizedBox(height: h * 0.01),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFF7a9064),
                  child: Icon(Icons.person, size: 40, color: Colors.black),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: subheadingStyle(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text("Roll No: $rollNumber", style: normalsize(context)),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),
            Text("App settings", style: subheadingStyle(context)),
            SizedBox(height: 15),

            _settingsOption(
              Icons.feedback,
              "Feedback",
              "Report technical issues or suggest new features",
              _showFeedbackBottomSheet,
            ),
            _settingsOption(
              Icons.info,
              "About",
              "The IIT Mandi app",
              _showAboutBottomSheet,
            ),
            _settingsOption(
              Icons.help,
              "Help and Support",
              "Report a problem or register complaints",
              _showHelpBottomSheet,
            ),

            Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (FirebaseAuth.instance.currentUser != null) {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      "/login",
                      (route) => false,
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  }
                },
                icon: Icon(
                  FirebaseAuth.instance.currentUser != null
                      ? Icons.logout
                      : Icons.login,
                  color: Color(0xFF283021),
                ),
                label: Text(
                  FirebaseAuth.instance.currentUser != null
                      ? "Log Out"
                      : "Login",
                  style: TextStyle(color: Color(0xFF283021)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF7a9064),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _settingsOption(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, size: 28, color: Color(0xFF7a9064)),
      title: Text(title, style: subheadingStyle(context)),
      subtitle: Text(subtitle, style: normalsize(context)),
      onTap: onTap,
    );
  }
}
