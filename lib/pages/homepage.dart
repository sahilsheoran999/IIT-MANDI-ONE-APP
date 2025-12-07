import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:project/Boxes/Date_time_homepage.dart';
import 'package:project/Boxes/Featured_event_homepage.dart';
import 'package:project/Boxes/temperature.dart';
import 'package:project/dine/canteen_page.dart';
import 'package:project/features/busbooking.dart';
import 'package:project/features/buyandsell.dart';
import 'package:project/features/communities.dart';
import 'package:project/features/contacts.dart';
import 'package:project/features/lostandfound.dart';
import 'package:project/features/scheduler.dart';
import 'package:project/pages/login_page.dart';
import 'package:project/pages/ticket.dart';
import 'package:project/styles/fontstyle.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, String>> upcomingClasses = [];
  bool isLoading = true;
  Timer? _timer;
  String displayname = 'User';
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await _checkConnection();
    _fetchUserDetails();
    _fetchUpcomingClasses();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _fetchUpcomingClasses();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<bool> _checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      setState(() => _isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty);
      return _isConnected;
    } on SocketException catch (_) {
      setState(() => _isConnected = false);
      return false;
    }
  }

  bool _isUserLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }

  Future<void> _fetchUserDetails() async {
    if (!_isConnected) {
      setState(() => displayname = "User");
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userEmail = user.email ?? "";
        if (userEmail.isNotEmpty) {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userEmail)
              .get();

          if (userDoc.exists) {
            String name = userDoc.get('name') ?? "User";
            setState(() => displayname = name.split(' ').first);
            return;
          }
        }
      }
      setState(() => displayname = "User");
    } catch (e) {
      print('Error fetching user details: $e');
      setState(() => displayname = "User");
    }
  }

  Future<void> _fetchUpcomingClasses() async {
    if (!_isConnected) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        setState(() => isLoading = false);
        return;
      }

      final now = DateTime.now();
      final currentDay = _getDayName(now.weekday);
      final currentTime = now.hour * 100 + now.minute;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.email)
          .get();

      List<Map<String, String>> classes = [];

      if (doc.exists) {
        final schedule = doc.data()?['attributes']?['schedule'];
        if (schedule != null && schedule[currentDay] != null) {
          final dayClasses = List<Map<String, dynamic>>.from(schedule[currentDay]);

          for (var classItem in dayClasses) {
            String di = classItem['time'].toString();
            String h = di.substring(0, 2) + di.substring(3);
            final classTime = int.parse(h);
            if (classTime >= currentTime) {
              final timeStr = classItem['time'].toString().padLeft(4, '0');
              classes.add({
                'name': classItem['name'].toString(),
                'time': '${timeStr.substring(0, 2)}:${timeStr.substring(3)}',
                'sortKey': classTime.toString(),
              });
            }
          }

          classes.sort((a, b) => int.parse(a['sortKey']!).compareTo(int.parse(b['sortKey']!)));
          classes = [classes.first];
        }
      }

      setState(() {
        upcomingClasses = classes;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching upcoming classes: $e');
      setState(() => isLoading = false);
    }
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'monday';
      case 2: return 'tuesday';
      case 3: return 'wednesday';
      case 4: return 'thursday';
      case 5: return 'friday';
      case 6: return 'saturday';
      case 7: return 'sunday';
      default: return '';
    }
  }

  void _showLoginPrompt() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Color(0xFF1E1E1F),
        content: Text('You need to login first', style: normalsize(context)),
        action: SnackBarAction(
          label: 'Login',
          textColor: const Color(0xFF7a9064),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showConnectionError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No internet connection', style: normalsize(context)),
        backgroundColor: Color(0xFF1E1E1F),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Navigation Methods
  Future<void> _navigateToBuses() async {
    if (!_isUserLoggedIn()) return _showLoginPrompt();
    if (!await _checkConnection()) return _showConnectionError();
    Navigator.push(context, MaterialPageRoute(builder: (context) => const BusBookingScreen()));
  }

  Future<void> _navigateTocanteen() async {
    if (!await _checkConnection()) return _showConnectionError();
    Navigator.push(context, MaterialPageRoute(builder: (context) => const CanteenPage()));
  }

  Future<void> _navigateToContacts() async {
    if (!_isUserLoggedIn()) return _showLoginPrompt();
    if (!await _checkConnection()) return _showConnectionError();
    Navigator.push(context, MaterialPageRoute(builder: (context) => ContactsPage()));
  }

  Future<void> _navigateTotickets() async {
    if (!_isUserLoggedIn()) return _showLoginPrompt();
    if (!await _checkConnection()) return _showConnectionError();
    Navigator.push(context, MaterialPageRoute(builder: (context) => TicketHomePage()));
  }

  Future<void> _navigateToBuySell() async {
    if (!_isUserLoggedIn()) return _showLoginPrompt();
    if (!await _checkConnection()) return _showConnectionError();
    Navigator.push(context, MaterialPageRoute(builder: (context) => BuySellScreen()));
  }

  Future<void> _navigateToLostFound() async {
    if (!_isUserLoggedIn()) return _showLoginPrompt();
    if (!await _checkConnection()) return _showConnectionError();
    Navigator.push(context, MaterialPageRoute(builder: (context) => LostAndFoundScreen()));
  }

  Future<void> _navigateToCommunities() async {
    if (!_isUserLoggedIn()) return _showLoginPrompt();
    if (!await _checkConnection()) return _showConnectionError();
    Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityPage()));
  }

  Future<void> _navigateToScheduler() async {
    if (!_isUserLoggedIn()) return _showLoginPrompt();
    if (!await _checkConnection()) return _showConnectionError();
    Navigator.push(context, MaterialPageRoute(builder: (context) => SchedulePage()));
  }

  Widget _buildSquareButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: const Color(0xFF283021),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: const Color(0xFF7a9064)),
              const SizedBox(height: 8),
              Text(label, style: normalsize(context)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return RefreshIndicator(
      onRefresh: () async {
        await _checkConnection();
        await _fetchUserDetails();
        await _fetchUpcomingClasses();
      },
      color: const Color(0xFF7a9064),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: h * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(width: w * 0.02),
                  Container(
                    height: h * 0.065,
                    child: Text(
                      'Hey, $displayname',
                      style: mainHeadingStyle(context),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(width: w * 0.02),
                  Container(
                    height: h * 0.25,
                    width: w * 0.4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7a9064),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: h * 0.01,
                          bottom: 0,
                          child: WeatherScreen(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: w * 0.03),
                  Container(child: Datetime()),
                ],
              ),
              const SizedBox(height: 30),
              Container(
                height: h * 0.12,
                width: w * 0.94,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: const Color(0xFF7a9064),
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : Container(
                        padding: EdgeInsets.fromLTRB(w * 0.03, 0, w * 0.03, 0),
                        width: w * 0.9,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              upcomingClasses.isNotEmpty
                                  ? 'Upcoming Classes'
                                  : 'Nothing scheduled',
                              style: subheadingStyle(context),
                            ),
                            const SizedBox(height: 8),
                            if (upcomingClasses.isNotEmpty)
                              ...upcomingClasses.map((classInfo) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: GestureDetector(
                                  onTap: _navigateToScheduler,
                                  child: Container(
                                    height: h * 0.05,
                                    width: w * 0.9,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: const Color(0xFF283021),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.fromLTRB(10, 8, 5, 5),
                                      child: Text(
                                        '${classInfo['name']} at ${classInfo['time']}',
                                        style: subheadingStyle(context),
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                            if (upcomingClasses.isEmpty)
                              GestureDetector(
                                onTap: _isUserLoggedIn() ? _navigateToScheduler : _showLoginPrompt,
                                child: Container(
                                  height: h * 0.05,
                                  width: w * 0.9,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: const Color(0xFF283021),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(10, 8, 5, 5),
                                    child: Text(
                                      _isUserLoggedIn() 
                                          ? 'No more classes today' 
                                          : 'Tap to login',
                                      style: subheadingStyle(context),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              Container(
                height: h * 0.31,
                width: w,
                child: Stack(
                  children: [
                    Positioned(
                      left: h * 0.01,
                      top: w * 0.03,
                      child: Text('Featured Events', style: mainHeadingStyle(context)),
                    ),
                    Positioned(
                      top: h * 0.066,
                      child: SizedBox(
                        height: h * 0.25,
                        width: w,
                        child: const FeaturedEvents(),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: h * 0.02),
                    Text('More to Explore', style: mainHeadingStyle(context)),
                    SizedBox(height: h * 0.02),
                    SizedBox(
                      child: Column(
                        children: [
                          Container(
                            height: h * 0.07,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildSquareButton(
                                    icon: Icons.food_bank,
                                    label: 'Mess and Canteens',
                                    onTap: _navigateTocanteen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: h * 0.02),
                          Container(
                            height: h * 0.1,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildSquareButton(
                                    icon: Icons.directions_bus,
                                    label: 'Buses',
                                    onTap: _navigateToBuses,
                                  ),
                                ),
                                SizedBox(width: w * 0.03),
                                Expanded(
                                  child: _buildSquareButton(
                                    icon: Icons.contacts,
                                    label: 'Contacts',
                                    onTap: _navigateToContacts,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: h * 0.02),
                          Container(
                            height: h * 0.1,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildSquareButton(
                                    icon: Icons.shopping_cart,
                                    label: 'Buy/Sell',
                                    onTap: _navigateToBuySell,
                                  ),
                                ),
                                SizedBox(width: w * 0.03),
                                Expanded(
                                  child: _buildSquareButton(
                                    icon: Icons.find_in_page,
                                    label: 'Lost & Found',
                                    onTap: _navigateToLostFound,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: h * 0.02),
                          Container(
                            height: h * 0.1,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildSquareButton(
                                    icon: Icons.people,
                                    label: 'Communities',
                                    onTap: _navigateToCommunities,
                                  ),
                                ),
                                SizedBox(width: w * 0.03),
                                Expanded(
                                  child: _buildSquareButton(
                                    icon: Icons.calendar_today,
                                    label: 'Scheduler',
                                    onTap: _navigateToScheduler,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: h * 0.02),
                          Container(
                            height: h * 0.1,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildSquareButton(
                                    icon: Icons.library_books,
                                    label: 'eLibrary',
                                    onTap: () => showLibraryBottomSheet(context),
                                  ),
                                ),
                                SizedBox(width: w * 0.03),
                                Expanded(
                                  child: _buildSquareButton(
                                    icon: Icons.token,
                                    label: 'Ticket',
                                    onTap: _navigateTotickets,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showLibraryBottomSheet(BuildContext context) {
  final webViewController = WebViewController()
    ..loadRequest(Uri.parse('https://library.iitmandi.ac.in/onlineresources/ebooks.html'));

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'eLibrary',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(child: WebViewWidget(controller: webViewController)),
            ],
          );
        },
      );
    },
  );
}