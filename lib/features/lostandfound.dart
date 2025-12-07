import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:project/styles/fontstyle.dart';

class LostAndFoundScreen extends StatefulWidget {
  @override
  _LostAndFoundScreenState createState() => _LostAndFoundScreenState();
}

class _LostAndFoundScreenState extends State<LostAndFoundScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseReference lostDbRef = FirebaseDatabase.instance.ref("lost_items");
  final DatabaseReference foundDbRef = FirebaseDatabase.instance.ref("found_items");
  List<Map<String, dynamic>> lostItems = [];
  List<Map<String, dynamic>> foundItems = [];
  final User? user = FirebaseAuth.instance.currentUser;
  final String defaultImagePath = 'assets/lostandfound.jpg';
  bool _isProcessing = false; // Track if any operation is in progress

  // Cloudinary configuration
  final String cloudName = 'dbq7yi9cg';
  final String uploadPreset = 'Lost_Found';
  final CloudinaryPublic cloudinary = CloudinaryPublic('dbq7yi9cg', 'Lost_Found');
 
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeListeners();
  }

  void _initializeListeners() {
    lostDbRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          lostItems = (event.snapshot.value as Map).entries.map((e) {
            return {
              "id": e.key,
              "name": e.value["name"],
              "description": e.value["description"],
              "imageUrl": e.value["imageUrl"],
              "contact": e.value["contact"],
              "uid": e.value["uid"],
            };
          }).toList();
        });
      } else {
        setState(() => lostItems = []);
      }
    });
    
    foundDbRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          foundItems = (event.snapshot.value as Map).entries.map((e) {
            return {
              "id": e.key,
              "name": e.value["name"],
              "description": e.value["description"],
              "imageUrl": e.value["imageUrl"],
              "contact": e.value["contact"],
              "uid": e.value["uid"],
            };
          }).toList();
        });
      } else {
        setState(() => foundItems = []);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _deleteItem(String itemId, String imageUrl, String itemUid, bool isLost) async {
    if (_isProcessing) return;
    
    if (user != null && user!.uid == itemUid) {
      setState(() => _isProcessing = true);
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CircularProgressIndicator(color: const Color(0xFF7a9064)),
                SizedBox(width: 10),
                Text("Deleting item...", style: normalsize(context)),
              ],
            ),
            backgroundColor: Color(0xFF1E1E1F),
          ),
        );

        await (isLost ? lostDbRef : foundDbRef).child(itemId).remove();

        setState(() {
          if (isLost) {
            lostItems.removeWhere((item) => item["id"] == itemId);
          } else {
            foundItems.removeWhere((item) => item["id"] == itemId);
          }
        });

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Color(0xFF1E1E1F),
            content: Text("Item deleted successfully", style: normalsize(context)),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete item: ${e.toString()}", style: normalsize(context)),
            backgroundColor: Color(0xFF1E1E1F),
            duration: Duration(seconds: 2),
          ),
        );
      } finally {
        setState(() => _isProcessing = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("You can only delete your own items!", style: normalsize(context)),
          backgroundColor: Color(0xFF1E1E1F),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Lost and Found', style: mainHeadingStyle(context)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF7a9064),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF7a9064),
          tabs: [
            Tab(
              text: 'Lost Items',
              icon: Icon(Icons.search_off, color: const Color(0xFF7a9064)),
            ),
            Tab(
              text: 'Found Items',
              icon: Icon(Icons.search, color: const Color(0xFF7a9064)),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildItemList(lostItems, true),
          _buildItemList(foundItems, false),
        ],
      ),
      floatingActionButton: _isProcessing
          ? FloatingActionButton(
              onPressed: null,
              child: CircularProgressIndicator(color: Colors.black),
              backgroundColor: Colors.grey,
            )
          : FloatingActionButton(
              onPressed: () => _showAddItemBottomSheet(),
              child: Icon(Icons.add, color: Colors.black),
              backgroundColor: const Color(0xFF7a9064),
              tooltip: 'Add Item',
            ),
    );
  }

 Widget _buildItemList(List<Map<String, dynamic>> items, bool isLost) {
  if (items.isEmpty) {
    return Center(
      child: Text(
        isLost ? "No lost items yet" : "No found items yet",
        style: normalsize(context),
      ),
    );
  }

  return RefreshIndicator(
    onRefresh: () async {
      // Force a refresh of the data
      final snapshot = await (isLost ? lostDbRef : foundDbRef).get();
      if (snapshot.exists) {
        setState(() {
          items = (snapshot.value as Map).entries.map((e) {
            return {
              "id": e.key,
              "name": e.value["name"],
              "description": e.value["description"],
              "imageUrl": e.value["imageUrl"],
              "contact": e.value["contact"],
              "uid": e.value["uid"],
            };
          }).toList();
        });
      } else {
        setState(() => items = []);
      }
    },
    child: ListView.builder(
      physics: AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
      itemCount: items.length,
      itemBuilder: (context, index) {
        bool isCreator = user != null && user!.uid == items[index]["uid"];
        
        return Dismissible(
          key: Key(items[index]["id"]),
          direction: isCreator ? DismissDirection.endToStart : DismissDirection.none,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF7a9064),
                  title: Text("Confirm Delete", style: subheadingStyle(context)),
                  content: Text("Are you sure you want to delete this item?", style: normalsize(context)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text("Cancel", style: normalsize(context)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text("Delete", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            }
            return false;
          },
          onDismissed: (direction) {
            _deleteItem(
              items[index]["id"],
              items[index]["imageUrl"] ?? "",
              items[index]["uid"],
              isLost,
            );
          },
          child: Card(
            color: const Color(0xFF283021),
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            elevation: 2,
            child: InkWell(
              onTap: () => _showItemDetails(context, items[index], isLost),
              child: Container(
                height: 100,
                child: Row(
                  children: [
                    Container(
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          bottomLeft: Radius.circular(4),
                        ),
                        image: DecorationImage(
                          image: items[index]["imageUrl"] != null && items[index]["imageUrl"].isNotEmpty
                              ? NetworkImage(items[index]["imageUrl"])
                              : AssetImage(defaultImagePath) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              items[index]["name"],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: const Color(0xFFccdbdc),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              items[index]["description"] ?? '',
                              style: normalsize(context),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.phone, size: 14, color: const Color(0xFF7a9064)),
                                SizedBox(width: 4),
                                Text(
                                  items[index]["contact"],
                                  style: normalsize(context),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isCreator)
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: _isProcessing
                            ? null
                            : () => _deleteItem(
                                  items[index]["id"],
                                  items[index]["imageUrl"] ?? "",
                                  items[index]["uid"],
                                  isLost,
                                ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

  void _showItemDetails(BuildContext context, Map<String, dynamic> item, bool isLost) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item["name"] ?? "No Title", style: subheadingStyle(context)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: item["imageUrl"] != null && item["imageUrl"].isNotEmpty
                          ? NetworkImage(item["imageUrl"])
                          : AssetImage(defaultImagePath) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "Description:",
                  style: subheadingStyle(context),
                ),
                Text(item["description"] ?? 'No description provided', style: normalsize(context)),
                SizedBox(height: 16),
                Text(
                  "Contact Information:",
                  style: subheadingStyle(context),
                ),
                Text(item["contact"] ?? "No contact provided", style: normalsize(context)),
                SizedBox(height: 16),
                Text(
                  "Status:",
                  style: subheadingStyle(context),
                ),
                Text(isLost ? "Lost Item" : "Found Item", style: normalsize(context)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close", style: normalsize(context)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddItemBottomSheet() async {
  if (_isProcessing) return;
  
  int selectedTab = _tabController.index;
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  File? pickedImage;
  final _formKey = GlobalKey<FormState>();

  // Keep a reference to the bottom sheet context
  BuildContext? bottomSheetContext;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF283021),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      bottomSheetContext = context; // Store the context
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedTab == 0 ? "Add Lost Item" : "Add Found Item",
                          style: subheadingStyle(context),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: const Color(0xFF7a9064)),
                          onPressed: _isProcessing
                              ? null
                              : () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: nameController,
                      style: normalsize(context),
                      decoration: InputDecoration(
                        hintText: "Item Name",
                        hintStyle: normalsize(context),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: const Color(0xFFb8c4ab)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: const Color(0xFFb8c4ab)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: const Color(0xFFb8c4ab)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter item name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: descController,
                      style: normalsize(context),
                      decoration: InputDecoration(
                        hintText: "Description",
                        hintStyle: normalsize(context),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: const Color(0xFFb8c4ab)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: const Color(0xFFb8c4ab)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: const Color(0xFFb8c4ab)),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: contactController,
                      style: normalsize(context),
                      decoration: InputDecoration(
                        hintText: "Contact Info (Phone/Email)",
                        hintStyle: normalsize(context),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: const Color(0xFFb8c4ab)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: const Color(0xFFb8c4ab)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: const Color(0xFFb8c4ab)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter contact information';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFb8c4ab)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: pickedImage == null
                          ? InkWell(
                              onTap: _isProcessing
                                  ? null
                                  : () async {
                                      final pickedFile = await ImagePicker().pickImage(
                                        source: ImageSource.gallery,
                                      );
                                      if (pickedFile != null) {
                                        setState(() {
                                          pickedImage = File(pickedFile.path);
                                        });
                                      }
                                    },
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image, size: 40, color: const Color(0xFFb8c4ab)),
                                    Text("Tap to select image", style: normalsize(context)),
                                  ],
                                ),
                              ),
                            )
                          : Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(pickedImage!, fit: BoxFit.cover),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.close, color: Colors.white),
                                      onPressed: _isProcessing
                                          ? null
                                          : () {
                                              setState(() {
                                                pickedImage = null;
                                              });
                                            },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isProcessing
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate() && user != null) {
                                      setState(() => _isProcessing = true);
                                      
                                      // Show loading in the bottom sheet
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              CircularProgressIndicator(color: const Color(0xFFb8c4ab)),
                                              SizedBox(width: 10),
                                              Text("Adding item...", style: normalsize(context)),
                                            ],
                                          ),
                                          backgroundColor: Color(0xFF1E1E1F),
                                          duration: Duration(minutes: 1), // Long duration to prevent auto-hide
                                        ),
                                      );

                                      String imageUrl = "";
                                      if (pickedImage != null) {
                                        try {
                                          imageUrl = await _uploadToCloudinary(pickedImage!);
                                        } catch (e) {
                                          setState(() => _isProcessing = false);
                                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Failed to upload image: ${e.toString()}",
                                                style: normalsize(context),
                                              ),
                                              backgroundColor: Color(0xFF1E1E1F),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                          return;
                                        }
                                      }
                                      
                                      try {
                                        DatabaseReference dbRef = selectedTab == 0 ? lostDbRef : foundDbRef;
                                        await dbRef.push().set({
                                          "name": nameController.text,
                                          "description": descController.text,
                                          "contact": contactController.text,
                                          "imageUrl": imageUrl,
                                          "uid": user!.uid,
                                        });
                                        
                                        // Only close after successful addition
                                        if (bottomSheetContext != null && mounted) {
                                          Navigator.of(bottomSheetContext!).pop();
                                        }
                                        
                                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Item added successfully!",
                                              style: normalsize(context),
                                            ),
                                            backgroundColor: Color(0xFF1E1E1F),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Failed to add item: ${e.toString()}",
                                              style: normalsize(context),
                                            ),
                                            backgroundColor: Color(0xFF1E1E1F),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      } finally {
                                        setState(() => _isProcessing = false);
                                      }
                                    }
                                  },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: _isProcessing
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.black,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      "Add Item",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isProcessing 
                                  ? Colors.grey 
                                  : const Color(0xFFb8c4ab),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
    );
  
}

  Future<String> _uploadToCloudinary(File image) async {
    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(image.path, resourceType: CloudinaryResourceType.Image),
      );
      return response.secureUrl;
    } catch (e) {
      print('Cloudinary upload error: $e');
      throw Exception('Failed to upload image to Cloudinary');
    }
  }
}