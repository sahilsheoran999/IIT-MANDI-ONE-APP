import 'package:flutter/material.dart';
import 'package:project/styles/fontstyle.dart';


class SelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    var h=MediaQuery.of(context).size.height;
    // Define our color scheme based on the provided colors
    final Color primaryColor = Color(0xFF7a9064); // Sage green
    final Color secondaryColor = Color(0xFF283021); // Dark forest green
    final Color backgroundColor = Color(0xFF141A12  ); // Light off-white with green tint
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                backgroundColor,
                Color(0xFF1E2419),
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: size.height * 0.06),
                  
                  // Logo and Title
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundColor: primaryColor,
                      radius: size.width * 0.15,
                      child: Icon(Icons.person,size: h*0.08,color: Color(0xFF283021),),
                    ),
                  ),
                  
                  SizedBox(height: size.height * 0.02),
                  Text(
                    "IIT Mandi",
                    style: mainHeadingStyle(context),
                  ),
                  
                  Text(
                    "Campus App",
                    style: TextStyle(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.w500,
                      color: primaryColor,
                      letterSpacing: 2.0,
                    ),
                  ),
                  
                  SizedBox(height: size.height * 0.08),
                  
                  // Student Login Card
                  _buildLoginCard(
                    context: context,
                    icon: Icons.school_rounded,
                    title: "Student Login",
                    description: "Access your student account, courses, and campus resources",
                    buttonText: "Sign In",
                    onTap: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    primaryColor: secondaryColor,
                    secondaryColor: secondaryColor,
                  ),
                  
                  SizedBox(height: size.height * 0.03),
                  
                  // Guest Login Card
                  _buildLoginCard(
                    context: context,
                    icon: Icons.public_rounded,
                    title: "Guest Access",
                    description: "Browse public information and resources",
                    buttonText: "Continue as Guest",
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    primaryColor: secondaryColor,
                    secondaryColor: secondaryColor,
                    
                  ),
                  
                  SizedBox(height: size.height * 0.06),
                  
                  // Footer text
                  Text(
                    "Indian Institute of Technology Mandi",
                    style: subheadingStyle(context),
                  ),
                  Text(
                    "Campus Management System",
                    style: normalsize(context)
                  ),
                  SizedBox(height: size.height * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onTap,
    required Color primaryColor,
    required Color secondaryColor,
    bool isOutlined = false,
  }) {
    final Size size = MediaQuery.of(context).size;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        color: Color(0xFF7a9064),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: primaryColor,
                  size: size.width * 0.07,
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: size.width * 0.045,
                        fontWeight: FontWeight.w800,
                        color: secondaryColor,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: size.width * 0.035,
                        color: secondaryColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: size.height * 0.025),
          InkWell(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
              decoration: BoxDecoration(
                color: isOutlined ? Colors.transparent : primaryColor,
                borderRadius: BorderRadius.circular(12),
                border: isOutlined
                    ? Border.all(color: primaryColor, width: 2)
                    : null,
              ),
              child: Center(
                child: Text(
                  buttonText,
                  style: TextStyle(
                    color: isOutlined ? primaryColor : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: size.width * 0.04,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}