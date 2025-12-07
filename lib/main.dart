import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:project/pages/home_page.dart';
import 'package:project/pages/login_page.dart';
import 'package:project/pages/selection_page.dart';
import 'package:project/pages/settings_page.dart';
import 'package:project/pages/theme_provider.dart';
import 'package:flutter/services.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase

  // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'IIT Mandi One App',
            theme: ThemeProvider.darkTheme
                 ,
            home: AuthWrapper(), // ✅ Check if user is logged in
            routes: {
              '/home': (context) => MainScreen(),
              '/settings': (context) => SettingsPage(),
              '/login': (context) => LoginPage(),
              '/selection': (context) => SelectionPage(),
            },
          );
        },
      ),
    );
  }
}

// ✅ This widget checks if a user is logged in and redirects accordingly
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Loading state
        }
        if (snapshot.hasData) {
          return MainScreen(); // ✅ If user is logged in, go to Home
        } else {
          return SelectionPage(); // ❌ Otherwise, go to SelectionPage
        }
      },
    );
  }
}
