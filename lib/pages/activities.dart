import 'package:flutter/material.dart';
import 'package:project/styles/fontstyle.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Activities extends StatefulWidget {
  @override
  _ActivitiesState createState() => _ActivitiesState();
}

class _ActivitiesState extends State<Activities> {
  // Default links
  final List<Map<String, String>> defaultLinks = [
    {'name': 'LMS', 'url': 'https://lms.iitmandi.ac.in/'},
    {'name': 'Samarth', 'url': 'https://iitmandi.samarth.ac.in/index.php/site/login'},
    {'name': 'Guest house booking', 'url': 'https://oas.iitmandi.ac.in/OASGuestHouse/GuestHouse/GuestHouseRequest.aspx'},
    {'name': 'Academic Calendar', 'url': 'https://www.iitmandi.ac.in/calendar'},
    {'name': 'Current Bus Booking', 'url': 'https://oas.iitmandi.ac.in/InstituteProcess/Facility/BusSeatReservation.aspx'},
    {'name': 'IIT Mandi News', 'url': 'https://iitmandi.ac.in/iitinnews'},
  ];

  // List that will contain all links (default + user's custom links)
  List<Map<String, String>> allLinks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadLinks();
  }

  // Load user's custom links from Firestore
  Future<void> loadLinks() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Start with default links
      allLinks = List.from(defaultLinks);
      
      // Get current user
      User? currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser != null) {
        // Fetch user's custom links from Firestore
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.email)
            .get();
            
        if (doc.exists && doc.data() is Map<String, dynamic>) {
          Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
          
          if (userData.containsKey('customLinks') && userData['customLinks'] is List) {
            List<dynamic> customLinks = userData['customLinks'];
            
            for (var link in customLinks) {
              if (link is Map<String, dynamic> && 
                  link.containsKey('name') && 
                  link.containsKey('url')) {
                allLinks.add({
                  'name': link['name'],
                  'url': link['url'],
                });
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error loading links: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showWebViewBottomSheet(BuildContext context, String url, String title) {
    // Create the controller outside the builder
    final controller = WebViewController()
      ..loadRequest(Uri.parse(url))
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            children: [
              // Header with close button
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: subheadingStyle(context)),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // WebView content
              Expanded(
                child: WebViewWidget(
                  controller: controller,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddLinkBottomSheet(BuildContext context) {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Custom Link', style: subheadingStyle(context)),
              SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Link Name',
                  hintText: 'Enter a name for your link',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: urlController,
                decoration: InputDecoration(
                  labelText: 'URL',
                  hintText: 'Enter the URL (https://...)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: normalsize(context),),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF7a9064),
                      foregroundColor: Color(0xFFccdbdc),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      final name = nameController.text.trim();
                      final url = urlController.text.trim();
                      
                      if (name.isNotEmpty && url.isNotEmpty) {
                        String finalUrl = url;
                        if (!url.startsWith('http://') && !url.startsWith('https://')) {
                          finalUrl = 'https://$url';
                        }
                        _saveCustomLink(name, finalUrl);
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Add Link', style: normalsize(context),),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Save a new custom link to Firestore
  Future<void> _saveCustomLink(String name, String url) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser != null) {
        // Reference to the user document
        DocumentReference userRef = FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.email);
            
        // Get current document
        DocumentSnapshot doc = await userRef.get();
        
        List<Map<String, String>> customLinks = [];
        
        // If document exists and has customLinks field
        if (doc.exists && doc.data() is Map<String, dynamic>) {
          Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
          
          if (userData.containsKey('customLinks') && userData['customLinks'] is List) {
            List<dynamic> existingLinks = userData['customLinks'];
            
            for (var link in existingLinks) {
              if (link is Map<String, dynamic> && 
                  link.containsKey('name') && 
                  link.containsKey('url')) {
                customLinks.add({
                  'name': link['name'] as String,
                  'url': link['url'] as String,
                });
              }
            }
          }
        }
        
        // Add new link
        customLinks.add({
          'name': name,
          'url': url,
        });
        
        // Update Firestore
        await userRef.set({
          'customLinks': customLinks.map((link) => {
            'name': link['name'],
            'url': link['url']
          }).toList(),
        }, SetOptions(merge: true));
        
        // Update local list
        if (mounted) {
          setState(() {
            allLinks.add({
              'name': name,
              'url': url,
            });
          });
        }
      }
    } catch (e) {
      print('Error saving custom link: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save link. Please try again.')),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, int index) {
    // Check if this is a default link
    if (index < defaultLinks.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Default links cannot be deleted')),
      );
      return;
    }
    
    final linkName = allLinks[index]['name'];
    
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Delete Link', style: subheadingStyle(context)),
            SizedBox(height: 16),
            Text(
              'Are you sure you want to delete "$linkName"?',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel',style: normalsize(context),),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteCustomLink(index);
                  },
                  child: Text('Delete',style: normalsize(context),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Delete a custom link from Firestore
  Future<void> _deleteCustomLink(int index) async {
    try {
      // Double check if this is a default link (cannot be deleted)
      if (index < defaultLinks.length) {
        return;
      }

      User? currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser != null) {
        // Reference to the user document
        DocumentReference userRef = FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.email);
            
        // First, get all custom links
        List<Map<String, String>> customLinks = [];
        
        for (int i = defaultLinks.length; i < allLinks.length; i++) {
          if (i != index) { // Skip the one to be deleted
            customLinks.add(allLinks[i]);
          }
        }
        
        // Update Firestore with the new list (without the deleted link)
        await userRef.update({
          'customLinks': customLinks.map((link) => {
            'name': link['name'],
            'url': link['url']
          }).toList(),
        });
        
        // Update local list
        if (mounted) {
          setState(() {
            allLinks.removeAt(index);
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Link deleted successfully')),
          );
        }
      }
    } catch (e) {
      print('Error deleting custom link: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete link. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: isLoading 
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: h * 0.05),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Quick Links',
                    style: mainHeadingStyle(context)
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: allLinks.length,
                  itemBuilder: (context, index) {
                    bool isDefaultLink = index < defaultLinks.length;
                    
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: Color(0xFF7a9064),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 30),
                            leading: Icon(Icons.link, color: Color(0xFFccdbdc)),
                            title: Text(
                              allLinks[index]['name'] ?? 'Unnamed Link', 
                              style: subheadingStyle(context),
                            ),
                            onTap: () => _showWebViewBottomSheet(
                              context,
                              allLinks[index]['url'] ?? 'https://example.com',
                              allLinks[index]['name'] ?? 'Unnamed Link',
                            ),
                            trailing: !isDefaultLink 
                              ? IconButton(
                                  icon: Icon(Icons.delete, color: Color(0xFFccdbdc)),
                                  onPressed: () => _showDeleteConfirmation(context, index),
                                )
                              : null,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF283021),
        child: Icon(Icons.add, color: Color(0xFF7a9064)),
        onPressed: () => _showAddLinkBottomSheet(context),
      ),
    );
  }
}