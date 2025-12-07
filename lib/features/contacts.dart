import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/styles/fontstyle.dart';



class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Contacts', style: mainHeadingStyle(context)),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              style: normalsize(context),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: normalsize(context),
                prefixIcon: Icon(Icons.search, color: const Color(0xFFb8c4ab)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: const Color(0xFFb8c4ab)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: const Color(0xFFb8c4ab)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: const Color(0xFFb8c4ab)),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                fillColor: const Color(0xFF7a9070),
                filled: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          
          // Contacts list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('contacts').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}', style: normalsize(context)),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: const Color(0xFFb8c4ab),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('No contacts found', style: normalsize(context)),
                  );
                }

                // Filter contacts based on search query
                var filteredContacts = snapshot.data!.docs.where((doc) {
                  final name = (doc['name'] ?? '').toString().toLowerCase();
                  final designation = (doc['designation'] ?? '').toString().toLowerCase();
                  
                  return name.contains(_searchQuery) || 
                         designation.contains(_searchQuery);
                }).toList();

                if (filteredContacts.isEmpty) {
                  return Center(
                    child: Text('No matching contacts found', style: normalsize(context)),
                  );
                }

                return ListView.builder(
                  itemCount: filteredContacts.length,
                  itemBuilder: (context, index) {
                    var contact = filteredContacts[index];
                    return ContactTile(
                      name: contact['name'],
                      designation: contact['designation'],
                      contact: contact['contact'],
                      office: contact['office'],
                      email: contact['email'],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ContactTile extends StatelessWidget {
  final String name;
  final String designation;
  final String contact;
  final String office;
  final String email;

  const ContactTile({
    required this.name,
    required this.designation,
    required this.contact,
    required this.office,
    required this.email,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF283021),
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () => _showContactDetails(context),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            height: 70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 6),
                // Designation (bold) + Name
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        designation,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFccdbdc),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                // Name (secondary text)
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFFb8c4ab),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showContactDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF283021),
        title: Text('Contact Details', style: subheadingStyle(context)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(context, 'Name', name),
              _buildDetailRow(context, 'Designation', designation),
              _buildDetailRow(context, 'Contact', contact),
              _buildDetailRow(context, 'Office', office),
              _buildDetailRow(context, 'Email', email),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: normalsize(context)),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFb8c4ab),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: const Color(0xFFccdbdc),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: normalsize(context),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}