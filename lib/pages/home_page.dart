import 'package:flutter/material.dart';
import 'package:project/pages/homepage.dart';
import 'package:project/pages/activities.dart'; // Import the Activities page
import 'package:project/pages/maps.dart';
import 'settings_page.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black, 
      
      body: Container(
         width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black,
                Color(0xFF1E2419),
              ],
            ),
          ),
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics: NeverScrollableScrollPhysics(), // Disable swipe navigation
          children: [
            HomePage(),
            PageViewExample(),
            Activities(), // Added the Activities page here
            SettingsPage(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor:  Colors.black ,
        selectedItemColor:  Colors.white ,
        unselectedItemColor:  Colors.grey ,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_sharp, color: Color(0xFFccdbdc),),  label: "Home", ),
          BottomNavigationBarItem(icon: Icon(Icons.map_sharp,color: Color(0xFFccdbdc)), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.link_sharp,color: Color(0xFFccdbdc)), label: "Quick links"), // Added Activities icon
          BottomNavigationBarItem(icon: Icon(Icons.settings_sharp,color: Color(0xFFccdbdc)), label: "Settings"),
        ],
      ),
    );
  }
}
