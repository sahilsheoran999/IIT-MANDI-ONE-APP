import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/styles/fontstyle.dart';


// Text Styles


class TicketHomePage extends StatefulWidget {
  const TicketHomePage({super.key});

  @override
  _TicketHomePageState createState() => _TicketHomePageState();
}

class _TicketHomePageState extends State<TicketHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _userTickets = [];

  @override
  void initState() {
    super.initState();
    _loadUserTickets();
  }

  Future<void> _loadUserTickets() async {
  final user = _auth.currentUser;
  if (user != null && user.email != null) {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(user.email)
        .collection('tickets')
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      _userTickets = querySnapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id; // Include document ID if needed
        return data;
      }).toList();
    });
  }
}

  void _showAddTicketBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF283021),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),),
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: AddTicketForm(onTicketAdded: _loadUserTickets),
        );
      },
  
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hostel Ticket System', style: mainHeadingStyle(context)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          
        ),
        child: _userTickets.isEmpty
            ? Center(
                child: Text(
                  'No tickets generated yet.',
                  style: normalsize(context),
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadUserTickets,
                color: const Color(0xFF7A9064),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _userTickets.length,
                  itemBuilder: (context, index) {
                    final ticket = _userTickets[index];
                    return TicketCard(ticket: ticket);
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7A9064),
        onPressed: _showAddTicketBottomSheet,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

class AddTicketForm extends StatefulWidget {
  final VoidCallback onTicketAdded;

  const AddTicketForm({super.key, required this.onTicketAdded});

  @override
  _AddTicketFormState createState() => _AddTicketFormState();
}

class _AddTicketFormState extends State<AddTicketForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, List<String>> helpTopicsMap = {
    'Classrooms': ['North Campus', 'South Campus'],
    'Finance and Accounts': ['Finance and Accounts'],
    'Hostel Maintenance': [
      'Beas Kund',
      'Chandra Taal',
      'Dashir',
      'Gauri Kund',
      'Manimahesh',
      'Nako',
      'Prashar',
      'Renuka',
      'Suraj Taal',
      'Suvalsar',
    ],
    'Sports': ['Existing Sport Facility'],
    'Student Gymkhana': [
      'Cultural Affairs',
      'General Affairs',
      'Hostel Affairs',
      'Literary Affairs',
      'Research Affairs',
      'Sports Affairs',
      'Technical Affairs',
    ],
  };

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedDepartment;
  String? _selectedHelpTopic;
  List<String> _helpTopics = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null && user.email != null) {
      _emailController.text = user.email!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _updateHelpTopics(String? department) {
    setState(() {
      _selectedDepartment = department;
      _helpTopics = department != null ? helpTopicsMap[department] ?? [] : [];
      _selectedHelpTopic = null;
    });
  }

  Future<void> _submitTicket() async {
  if (_formKey.currentState!.validate()) {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User not authenticated', style: normalsize(context)),
          backgroundColor: Color(0xFF1E1E1F),
        ),
      );
      return;
    }

    final ticketData = {
      'name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'department': _selectedDepartment,
      'helpTopic': _selectedHelpTopic,
      'status': 'Pending',
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      // Add ticket to user's subcollection
      await _firestore
          .collection('users')
          .doc(user.email)
          .collection('tickets')
          .add(ticketData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ticket submitted successfully', style: normalsize(context)),
          backgroundColor: Color(0xFF1E1E1F),
        ),
      );
      widget.onTicketAdded();
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting ticket: $e', style: normalsize(context)),
          backgroundColor: Color(0xFF1E1E1F),
        ),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create New Ticket',
              style: mainHeadingStyle(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              style: normalsize(context),
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: normalsize(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF7A9064)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF7A9064)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF7A9064), width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              style: normalsize(context),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: normalsize(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF7A9064)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF7A9064)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF7A9064), width: 2),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              style: normalsize(context),
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: normalsize(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF7A9064)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF7A9064)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF7A9064), width: 2),
                ),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                  return 'Please enter a valid 10-digit phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDepartment,
              dropdownColor: const Color(0xFF283021),
              style: normalsize(context),
              decoration: InputDecoration(
                labelText: 'Department',
                labelStyle: normalsize(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF7A9064)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF7A9064)),
                ),
              ),
              items: helpTopicsMap.keys
                  .map((department) => DropdownMenuItem(
                        value: department,
                        child: Text(department, style: normalsize(context)),
                      ))
                  .toList(),
              onChanged: _updateHelpTopics,
              validator: (value) {
                if (value == null) {
                  return 'Please select a department';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedHelpTopic,
              dropdownColor: const Color(0xFF283021),
              style: normalsize(context),
              decoration: InputDecoration(
                labelText: 'Help Topic',
                labelStyle: normalsize(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF7A9064)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF7A9064)),
                ),
              ),
              items: _helpTopics
                  .map((topic) => DropdownMenuItem(
                        value: topic,
                        child: Text(topic, style: normalsize(context)),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedHelpTopic = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a help topic';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitTicket,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A9064),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Submit Ticket',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class TicketCard extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const TicketCard({super.key, required this.ticket});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF283021),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ticket['department'] ?? 'No Department',
                  style: subheadingStyle(context),
                ),
                Chip(
                  label: Text(
                    ticket['status'] ?? 'Unknown',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(ticket['status'] ?? ''),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Topic: ${ticket['helpTopic'] ?? 'No Topic'}',
              style: normalsize(context),
            ),
            const SizedBox(height: 8),
            Text(
              'Submitted: ${ticket['timestamp'] != null ? _formatDate(ticket['timestamp'].toDate()) : 'Unknown'}',
              style: normalsize(context)?.copyWith(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}