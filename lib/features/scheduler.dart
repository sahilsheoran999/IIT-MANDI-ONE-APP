import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/styles/fontstyle.dart';

// 1. Model Class - Unchanged
class ScheduleItem {
  final String name;
  final String time;
  final String day;

  ScheduleItem({
    required this.name,
    required this.time,
    required this.day,
  });

  factory ScheduleItem.fromMap(Map<String, dynamic> map, String day) {
    return ScheduleItem(
      name: map['name'],
      time: map['time'],
      day: day,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'time': time,
    };
  }

  TimeOfDay get timeOfDay {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}

// 2. Repository Class - Unchanged
class ScheduleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String get _userEmail => FirebaseAuth.instance.currentUser?.email ?? '';
  
  DocumentReference get _userDoc => 
      _firestore.collection('users').doc(_userEmail);
  
  Future<void> addScheduleItem(ScheduleItem item) async {
    await _userDoc.update({
      'attributes.schedule.${item.day}': FieldValue.arrayUnion([item.toMap()])
    });
  }

  Future<void> removeScheduleItem(ScheduleItem item) async {
    await _userDoc.update({
      'attributes.schedule.${item.day}': FieldValue.arrayRemove([item.toMap()])
    });
  }

  Stream<List<ScheduleItem>> getDaySchedule(String day) {
    return _userDoc.snapshots().map((snapshot) {
      final scheduleData = (snapshot.data() as Map<String, dynamic>?)?['attributes']?['schedule'] ?? {};
      final dayItems = (scheduleData[day] as List? ?? [])
          .map((e) => ScheduleItem.fromMap(e, day))
          .toList();
      
      dayItems.sort((a, b) => a.time.compareTo(b.time));
      return dayItems;
    });
  }

  Stream<List<ScheduleItem>> getUpcomingClasses() {
    return _userDoc.snapshots().map((snapshot) {
      final scheduleData = (snapshot.data() as Map<String, dynamic>?)?['attributes']?['schedule'] ?? {};

      final now = DateTime.now();
      final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      final currentDayIndex = now.weekday - 1;
      
      const days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
      final upcomingItems = <ScheduleItem>[];
      
      for (int i = 0; i < 7; i++) {
        final dayIndex = (currentDayIndex + i) % 7;
        final day = days[dayIndex];
        final dayItems = (scheduleData[day] as List? ?? [])
            .map((e) => ScheduleItem.fromMap(e, day))
            .toList();
            
        dayItems.sort((a, b) => a.time.compareTo(b.time));
        
        if (i == 0) {
          upcomingItems.addAll(dayItems.where((item) => item.time.compareTo(currentTime) >= 0));
        } else {
          upcomingItems.addAll(dayItems);
        }
        
        if (upcomingItems.length >= 3) break;
      }
      
      return upcomingItems.take(3).toList();
    });
  }
}

// 3. Updated Schedule View Page with Bottom Sheet
class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final ScheduleRepository _repo = ScheduleRepository();
  final List<String> days = [
    'sunday', 'monday', 'tuesday', 'wednesday', 
    'thursday', 'friday', 'saturday',
  ];
  
  late int _selectedDayIndex;
  late DateTime _currentDate;
  late List<DateTime> _weekDates;
  late List<String> _orderedDays;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize with current date
    _currentDate = DateTime.now();
    // Current day index in days list (0-6, where 0 is Sunday)
    int currentDayIndex = _currentDate.weekday % 7;
    
    // Re-order days to start from current day
    _orderedDays = [];
    for (int i = 0; i < 7; i++) {
      _orderedDays.add(days[(currentDayIndex + i) % 7]);
    }
    
    // Set selected day to first day (current day)
    _selectedDayIndex = 0;
    
    // Generate 7 dates starting from today
    _generateWeekDates();
  }
  
  void _generateWeekDates() {
    // Start from current date
    _weekDates = List.generate(7, (index) => _currentDate.add(Duration(days: index)));
  }
  
  String _getDayNameFromIndex(int index) {
    return _orderedDays[index].substring(0, 3).capitalize();
  }
  
  // New method to show bottom sheet for adding a class
  void _showAddClassBottomSheet() {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    TimeOfDay? _selectedTime;
    String _selectedDay = _orderedDays[_selectedDayIndex]; // Default to currently selected day
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF283021),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
                            'Add Class',
                            style: subheadingStyle(context),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Color(0xFF7a9064)),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        style: normalsize(context),
                        decoration: InputDecoration(
                          labelText: 'Class Name',
                          labelStyle: normalsize(context),
                          hintText: 'Enter class name',
                          hintStyle: normalsize(context),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF7a9064)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF7a9064)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF7a9064)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a class name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedDay,
                        dropdownColor: Color(0xFF283021),
                        style: normalsize(context),
                        decoration: InputDecoration(
                          labelText: 'Day',
                          labelStyle: normalsize(context),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF7a9064)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF7a9064)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF7a9064)),
                          ),
                        ),
                        items: days.map((day) {
                          return DropdownMenuItem(
                            value: day,
                            child: Text(
                              day.capitalize(),
                              style: normalsize(context),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDay = value!;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime ?? TimeOfDay.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.dark(
                                    primary: Color(0xFF7a9064),
                                    onPrimary: Colors.white,
                                    surface: Color(0xFF283021),
                                    onSurface: Colors.white,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          
                          if (pickedTime != null) {
                            setState(() {
                              _selectedTime = pickedTime;
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFF7a9064)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedTime == null
                                    ? 'Select Time'
                                    : 'Time: ${_selectedTime!.format(context)}',
                                style: normalsize(context),
                              ),
                              Icon(Icons.access_time, color: Color(0xFF7a9064)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate() && _selectedTime != null) {
                                  Navigator.pop(context); // Close bottom sheet first
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          CircularProgressIndicator(color: Color(0xFF7a9064)),
                                          SizedBox(width: 10),
                                          Text("Adding class...", style: normalsize(context)),
                                        ],
                                      ),
                                      duration: Duration(seconds: 2),
                                      backgroundColor: Color(0xFF1E1E1F),
                                    ),
                                  );
                                  
                                  final timeStr = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
                                  
                                  final newItem = ScheduleItem(
                                    name: _nameController.text,
                                    time: timeStr,
                                    day: _selectedDay,
                                  );
                                  
                                  try {
                                    await _repo.addScheduleItem(newItem);
                                    
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      
                                      SnackBar(
                                        content: Text("Class added successfully!", style: normalsize(context)),
                                        backgroundColor: Color(0xFF1E1E1F),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Failed to add class: ${e.toString()}", style: normalsize(context)),
                                        backgroundColor: Color(0xFF1E1E1F),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                child: Text(
                                  "Add Class",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF7a9064),
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
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Timetable',
          style: mainHeadingStyle(context),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // This will navigate back
          },
        ),
      ),
      body: Column(
        children: [
          // Date selector buttons
          Container(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7, // Explicitly set to 7 days
              itemBuilder: (context, index) {
                final isSelected = index == _selectedDayIndex;
                final dayIndex = index % 7; // Ensure we stay within 0-6 range
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDayIndex = index;
                    });
                  },
                  child: Container(
                    width: 60,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? Color(0xFF7a9064) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getDayNameFromIndex(dayIndex),
                          style: subheadingStyle(context)
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _weekDates[dayIndex].day.toString().padLeft(2, '0'),
                          style: subheadingStyle(context)
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Schedule content
          Expanded(
            child: StreamBuilder<List<ScheduleItem>>(
              stream: _repo.getDaySchedule(_orderedDays[_selectedDayIndex]),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: subheadingStyle(context)));
                }
                
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator(color: Color(0xFF7a9064)));
                }
                
                final items = snapshot.data!;
                
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 100,
                          color: Color(0xFF7a9064),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Add Your Class Schedule To Get Started',
                          style: normalsize(context),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      color: Color(0xFF283021),
                      child: ListTile(
                        title: Text(item.name, style: subheadingStyle(context)),
                        subtitle: Text(item.time, style: normalsize(context)),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Color(0xFF7a9064)),
                          onPressed: () => _repo.removeScheduleItem(item),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF7a9064),
        child: Icon(Icons.add),
        onPressed: () => _showAddClassBottomSheet(),
      ),
    );
  }
}

// 5. Home Page with Upcoming Classes - No changes needed
class ScheduleHomeWidget extends StatelessWidget {
  final ScheduleRepository _repo = ScheduleRepository();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Upcoming Classes',
            style: subheadingStyle(context)
          ),
        ),
        StreamBuilder<List<ScheduleItem>>(
          stream: _repo.getUpcomingClasses(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error loading schedule', style: subheadingStyle(context)));
            }
            
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator(color: Colors.white));
            }
            
            final items = snapshot.data!;
            
            if (items.isEmpty) {
              return Center(child: Text('No upcoming classes', style: subheadingStyle(context)));
            }
            
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  color: Color(0xFF283021),
                  child: ListTile(
                    title: Text(item.name, style: subheadingStyle(context)),
                    subtitle: Text(
                      '${item.day.capitalize()} at ${item.time}',
                      style: normalsize(context),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

// Extension for String capitalization
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}