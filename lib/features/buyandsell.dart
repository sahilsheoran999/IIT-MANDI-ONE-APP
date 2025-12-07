import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:project/styles/fontstyle.dart';

class BuySellScreen extends StatefulWidget {
  @override
  _BuySellScreenState createState() => _BuySellScreenState();
}

class _BuySellScreenState extends State<BuySellScreen> {
  final DatabaseReference itemsDbRef = FirebaseDatabase.instance.ref("buy_sell_items");
  List<Map<String, dynamic>> items = [];
  final User? user = FirebaseAuth.instance.currentUser;
  final String defaultImagePath = 'assets/buy_sell.jpg';
  final Color iconColor = const Color(0xFFb8c4ab);
  final Color itemBackgroundColor = const Color(0xFF7A9064);
  bool _isProcessing = false; // Track if any operation is in progress

  // Cloudinary configuration
  final String cloudName = 'dbq7yi9cg';
  final String uploadPreset = 'Buy_Sell';
  final CloudinaryPublic cloudinary = CloudinaryPublic('dbq7yi9cg', 'Buy_Sell');

  @override
  void initState() {
    super.initState();
    _initializeListener();
  }

  void _initializeListener() {
    itemsDbRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          items = (event.snapshot.value as Map).entries.map((e) {
            return {
              "id": e.key,
              "name": e.value["name"],
              "description": e.value["description"],
              "imageUrl": e.value["imageUrl"],
              "contact": e.value["contact"],
              "price": e.value["price"],
              "uid": e.value["uid"],
            };
          }).toList();
        });
      } else {
        setState(() => items = []);
      }
    });
  }

  Future<void> _deleteItem(String itemId, String imageUrl, String itemUid) async {
    if (_isProcessing) return;
    
    if (user != null && user!.uid == itemUid) {
      setState(() => _isProcessing = true);
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Color(0xFF1E1E1F),
            content: Row(
              children: [
                CircularProgressIndicator(color: iconColor),
                SizedBox(width: 10),
                Text("Deleting item...", style: normalsize(context)),
              ],
            ),
          ),
        );

        await itemsDbRef.child(itemId).remove();

        setState(() {
          items.removeWhere((item) => item["id"] == itemId);
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
            backgroundColor: Color(0xFF1E1E1F),
            content: Text("Failed to delete item: ${e.toString()}", style: normalsize(context)),
            duration: Duration(seconds: 2),
          ),
        );
      } finally {
        setState(() => _isProcessing = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color(0xFF1E1E1F),
          content: Text("You can only delete your own items!", style: normalsize(context)),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buy/Sell Items', style: mainHeadingStyle(context)),
      ),
      body: _buildItemList(),
      floatingActionButton: _isProcessing
          ? FloatingActionButton(
              onPressed: null,
              child: CircularProgressIndicator(color: Colors.white),
              backgroundColor: Colors.grey,
            )
          : FloatingActionButton(
              onPressed: () => _showAddItemDialog(),
              child: Icon(Icons.add, color: Colors.white),
              tooltip: 'Add Item for Sale',
              backgroundColor: Color(0xFF7a9064),
            ),
    );
  }

  Widget _buildItemList() {
    if (items.isEmpty) {
      return Center(
        child: Text(
          "No items for sale yet",
          style: subheadingStyle(context),
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        bool isCreator = user != null && user!.uid == items[index]["uid"];
        double itemHeight = MediaQuery.of(context).size.height * 0.15;
        
        return Dismissible(
          key: Key(items[index]["id"]),
          direction: isCreator ? DismissDirection.endToStart : DismissDirection.none,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.delete, color: iconColor),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Confirm Delete", style: subheadingStyle(context)),
                  content: Text("Are you sure you want to delete this item?", style: normalsize(context)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text("Cancel", style: normalsize(context)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text("Delete", style: TextStyle(color: Colors.red, fontSize: MediaQuery.of(context).size.height * 0.015)),
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
            );
          },
          child: InkWell(
            onTap: () => _showItemDetails(context, items[index]),
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              elevation: 2,
              color: Color(0xFF283021),
              child: Container(
                height: itemHeight,
                child: Row(
                  children: [
                    Container(
                      width: itemHeight * 0.8,
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              items[index]["name"],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: MediaQuery.of(context).size.height * 0.018,
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
                                Icon(Icons.currency_rupee, size: 14, color: iconColor),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    items[index]["price"] ?? 'Price not set',
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.height * 0.015,
                                      color: const Color(0xFFccdbdc),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.phone, size: 14, color: iconColor),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    items[index]["contact"],
                                    style: normalsize(context),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isCreator)
                      IconButton(
                        icon: Icon(Icons.delete, color: iconColor),
                        onPressed: _isProcessing
                            ? null
                            : () => _deleteItem(
                                  items[index]["id"],
                                  items[index]["imageUrl"] ?? "",
                                  items[index]["uid"],
                                ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showItemDetails(BuildContext context, Map<String, dynamic> item) {
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height * 0.018,
                    color: const Color(0xFFccdbdc),
                  ),
                ),
                Text(
                  item["description"] ?? 'No description provided',
                  style: normalsize(context),
                ),
                SizedBox(height: 16),
                Text(
                  "Price:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height * 0.018,
                    color: const Color(0xFFccdbdc),
                  ),
                ),
                Text(item["price"] ?? "Price not set", style: normalsize(context)),
                SizedBox(height: 16),
                Text(
                  "Contact Information:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height * 0.018,
                    color: const Color(0xFFccdbdc),
                  ),
                ),
                Text(item["contact"] ?? "No contact provided", style: normalsize(context)),
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

  Future<void> _showAddItemDialog() async {
    if (_isProcessing) return;
    
    TextEditingController nameController = TextEditingController();
    TextEditingController descController = TextEditingController();
    TextEditingController contactController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    File? pickedImage;
    final _formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: Color(0xFF283021),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Add Item for Sale",
                            style: subheadingStyle(context),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: "Item Name",
                                labelStyle: TextStyle(color: iconColor),
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: iconColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: iconColor, width: 2),
                                ),
                              ),
                              style: normalsize(context),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter item name';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 12),
                            TextFormField(
                              controller: descController,
                              decoration: InputDecoration(
                                labelText: "Description",
                                labelStyle: TextStyle(color: iconColor),
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: iconColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: iconColor, width: 2),
                                ),
                              ),
                              style: normalsize(context),
                            ),
                            SizedBox(height: 12),
                            TextFormField(
                              controller: priceController,
                              decoration: InputDecoration(
                                labelText: "Expected Price",
                                labelStyle: TextStyle(color: iconColor),
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: iconColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: iconColor, width: 2),
                                ),
                              ),
                              style: normalsize(context),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter expected price';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: 12),
                            TextFormField(
                              controller: contactController,
                              decoration: InputDecoration(
                                labelText: "Contact Info (Phone/Email)",
                                labelStyle: TextStyle(color: iconColor),
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: iconColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: iconColor, width: 2),
                                ),
                              ),
                              style: normalsize(context),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter contact information';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 12),
                            GestureDetector(
                              onTap: _isProcessing
                                  ? null
                                  : () async {
                                      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                                      if (pickedFile != null) {
                                        setState(() {
                                          pickedImage = File(pickedFile.path);
                                        });
                                      }
                                    },
                              child: Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: iconColor),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: pickedImage == null
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.image, size: 40, color: iconColor),
                                          Text("Tap to select image", style: normalsize(context)),
                                        ],
                                      )
                                    : Image.file(pickedImage!, fit: BoxFit.cover),
                              ),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _isProcessing
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate() && user != null) {
                                        setState(() => _isProcessing = true);
                                        
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: Color(0xFF1E1E1F),
                                            content: Row(
                                              children: [
                                                CircularProgressIndicator(color: iconColor),
                                                SizedBox(width: 10),
                                                Text("Adding item...", style: normalsize(context)),
                                              ],
                                            ),
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
                                                backgroundColor: Color(0xFF1E1E1F),
                                                content: Text("Failed to upload image: ${e.toString()}", style: normalsize(context)),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                            return;
                                          }
                                        }
                                        
                                        try {
                                          await itemsDbRef.push().set({
                                            "name": nameController.text,
                                            "description": descController.text,
                                            "contact": contactController.text,
                                            "price": priceController.text,
                                            "imageUrl": imageUrl,
                                            "uid": user!.uid,
                                          });
                                          
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              backgroundColor: Color(0xFF1E1E1F),
                                              content: Text("Item added successfully!", style: normalsize(context)),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              backgroundColor: Color(0xFF1E1E1F),
                                              content: Text("Failed to add item: ${e.toString()}", style: normalsize(context)),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        } finally {
                                          setState(() => _isProcessing = false);
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isProcessing ? Colors.grey : iconColor,
                                foregroundColor: Colors.black,
                                minimumSize: Size(double.infinity, 50),
                              ),
                              child: _isProcessing
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.black,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text("Add Item", style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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