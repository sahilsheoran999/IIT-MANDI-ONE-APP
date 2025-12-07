import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:project/styles/fontstyle.dart';



class BusBookingScreen extends StatefulWidget {
  const BusBookingScreen({super.key});

  @override
  State<BusBookingScreen> createState() => _BusBookingScreenState();
}

class _BusBookingScreenState extends State<BusBookingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _selectedDate;
  String? _selectedRoute;
  String? _selectedTime;
  final List<int> _selectedSeats = [];
  List<int> _reservedSeats = [];
  List<Map<String, dynamic>> _userBookings = [];
  bool _isLoadingBookings = false;
  final User _user = FirebaseAuth.instance.currentUser!;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  Map<String, dynamic>? _userData;

  final List<String> _routes = [
    'North Campus to Mandi ',
    'Mandi to North Campus ',
  ];

  final Map<String, List<String>> _routeTimes = {
    'North Campus to Mandi ': ['07:00 AM','09:00 AM','11:00 AM','02:00 PM','04:00 PM','05:40 PM','06:00 PM','07:00 PM','08:00 PM'],
    'Mandi to North Campus ': ['07:00 AM','08:00 AM', '10:00 AM','12:00 PM','03:15 PM','05:00 PM','07:00 PM','08:00 PM','09:00 PM'],
  };

  @override
void initState() {
  super.initState();
  _tabController = TabController(length: 2, vsync: this);
  _selectedDate = DateTime.now();
  _loadUserData();
  _loadUserBookings();
}

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null;
        _selectedSeats.clear();
        _loadReservedSeats();
      });
    }
  }

  Future<void> _confirmBooking() async {
  // First check if user already has 2 bookings
  if (_userBookings.length >= 2) {
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(backgroundColor: Color(0xFF1E1E1F),content: Text('You can only have 2 bookings at a time',style: normalsize(context),)),
    );
    return;
  }

  if (_selectedRoute == null ||
      _selectedTime == null ||
      _selectedDate == null ||
      _selectedSeats.isEmpty ||
      _userData == null ||
      _user.email == null) {
    ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(backgroundColor: Color(0xFF1E1E1F),content: Text('Please fill all required fields',style: normalsize(context),)),
    );
    return;
  }

  try {
    final formattedDate = DateFormat('ddMMyyyy').format(_selectedDate!);
    final routeKey =
        '${_selectedRoute!.hashCode}_${_selectedTime!.replaceAll(' ', '')}_$formattedDate';
    final bookingId = _dbRef.child('user_bookings').push().key!;

    final updates = <String, dynamic>{
      'bookings/$routeKey/reservedSeats': {
        _selectedSeats.first.toString(): true, // Only one seat now
      },
      'user_bookings/$bookingId': {
        'userEmail': _user.email!,
        'name': _userData!['name'] ?? 'Unknown',
        'rollNumber': _userData!['rollNumber'] ?? '',
        'role': _userData!['role'] ?? 'student',
        'route': _selectedRoute!,
        'time': _selectedTime!,
        'date': _selectedDate!.millisecondsSinceEpoch,
        'seats': [_selectedSeats.first], // Store as single item array
        'bookingDate': DateTime.now().millisecondsSinceEpoch,
        'status': 'confirmed',
        'bookingId': bookingId,
      },
    };

    await _dbRef.update(updates);
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(backgroundColor: Color(0xFF1E1E1F),content: Text('Booking successful!',style: normalsize(context))),
    );

    setState(() {
      _selectedSeats.clear();
      _loadUserBookings();
      _tabController.animateTo(1);
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Color(0xFF1E1E1F),content: Text('Booking failed: ${e.toString()}',style: normalsize(context))),
    );
  }
}

  Future<void> _loadUserData() async {
    try {
      final emailKey = _user.email!.replaceAll('.', ',');
      final snapshot = await _dbRef.child('users/$emailKey').get();
      if (snapshot.exists) {
        setState(() {
          _userData = Map<String, dynamic>.from(snapshot.value as Map);
        });
      } else {
        await _createDefaultProfile(emailKey);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Color(0xFF1E1E1F),content: Text('Error loading user data: ${e.toString()}',style: normalsize(context))),
      );
    }
  }

  Future<void> _createDefaultProfile(String emailKey) async {
    final defaultData = {
      'name': _user.displayName ?? 'New User',
      'email': _user.email,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'rollNumber': '',
      'role': 'student',
    };
    await _dbRef.child('users/$emailKey').set(defaultData);
    setState(() => _userData = defaultData);
  }

  Future<void> _loadReservedSeats() async {
    if (_selectedRoute == null || _selectedTime == null || _selectedDate == null) return;

    final formattedDate = DateFormat('ddMMyyyy').format(_selectedDate!);
    final path =
        'bookings/${_selectedRoute!.hashCode}_${_selectedTime!.replaceAll(' ', '')}_$formattedDate';

    try {
      final snapshot = await _dbRef.child(path).get();
      if (snapshot.exists) {
        final data = snapshot.value as Map;
        setState(() {
          _reservedSeats = data['reservedSeats'] != null
              ? List<int>.from((data['reservedSeats'] as Map).keys.map((e) => int.parse(e)))
              : [];
        });
      } else {
        setState(() => _reservedSeats = []);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Color(0xFF1E1E1F),content: Text('Error loading seat data: ${e.toString()}',style: normalsize(context))),
      );
    }
  }

 Future<void> _loadUserBookings() async {
  setState(() => _isLoadingBookings = true);
  try {
    // First, check and delete expired bookings
    await _deleteExpiredBookings();
    
    // Then load remaining bookings
    final snapshot = await _dbRef
        .child('user_bookings')
        .orderByChild('userEmail')
        .equalTo(_user.email)
        .get();

    if (snapshot.exists) {
      final bookings = snapshot.value as Map;
      setState(() {
        _userBookings = bookings.values
            .whereType<Map>()
            .map((b) => Map<String, dynamic>.from(b))
            .toList();
        _userBookings.sort((a, b) => (b['date'] ?? 0).compareTo(a['date'] ?? 0));
      });
    } else {
      setState(() => _userBookings = []);
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Color(0xFF1E1E1F),content: Text('Error loading bookings: ${e.toString()}',style: normalsize(context))),
    );
  } finally {
    setState(() => _isLoadingBookings = false);
  }
}

  void _toggleSeatSelection(int seatNumber) {
  if (_reservedSeats.contains(seatNumber)) return;

  setState(() {
    if (_selectedSeats.contains(seatNumber)) {
      _selectedSeats.remove(seatNumber);
    } else if (_selectedSeats.isEmpty) { // Changed from length < 2 to isEmpty
      _selectedSeats.add(seatNumber);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(backgroundColor: Color(0xFF1E1E1F),content: Text('You can select only 1 seat at a time',style: normalsize(context))),
      );
    }
  });
}

  Color _getSeatColor(int seatNumber) {
    return _reservedSeats.contains(seatNumber)
        ? const Color(0xFF283021) // Changed to 7a9064 for reserved seats
        : _selectedSeats.contains(seatNumber)
            ? const Color(0xFF7a9064) // Changed to b8c4ab for selected seats
            : const Color(0xFFccdbdc); // Changed to ccdbdc for available seats
  }

  Widget _buildBookingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: const Color(0xFF283021), // Changed to 7a9064
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Travel Information', style: mainHeadingStyle(context)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: const Color(0xFFb8c4ab)), // Changed to b8c4ab
                      const SizedBox(width: 8),
                      Text('Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}', 
                          style: normalsize(context)),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _selectDate(context),
                        child: Text('Change Date', style: normalsize(context)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Route',
                      labelStyle: normalsize(context),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.route, color: const Color(0xFFb8c4ab)), // Changed to b8c4ab
                    ),
                    value: _selectedRoute,
                    items: _routes.map((route) => DropdownMenuItem(
                      value: route,
                      child: Text(route, overflow: TextOverflow.ellipsis, style: normalsize(context)),
                    )).toList(),
                    onChanged: (value) => setState(() {
                      _selectedRoute = value;
                      _selectedTime = null;
                      _selectedSeats.clear();
                      if (value != null && _selectedDate != null) _loadReservedSeats();
                    }),
                    style: normalsize(context),
                    dropdownColor: const Color(0xFF7a9064), // Changed to 7a9064
                  ),
                  if (_selectedRoute != null) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Time',
                        labelStyle: normalsize(context),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.access_time, color: const Color(0xFFb8c4ab)), // Changed to b8c4ab
                      ),
                      value: _selectedTime,
                      items: _routeTimes[_selectedRoute]!.map((time) => DropdownMenuItem(
                        value: time,
                        child: Text(time, style: normalsize(context)),
                      )).toList(),
                      onChanged: (value) => setState(() {
                        _selectedTime = value;
                        _selectedSeats.clear();
                        if (value != null && _selectedDate != null) _loadReservedSeats();
                      }),
                      style: normalsize(context),
                      dropdownColor: const Color(0xFF7a9064), // Changed to 7a9064
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_selectedRoute != null && _selectedTime != null) ...[
            const SizedBox(height: 24),
            Text('Select Seat (Max 1 at a time)', style: subheadingStyle(context)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SeatLegend(color: const Color(0xFFccdbdc), text: 'Available'),
                _SeatLegend(color: const Color(0xFF7a9064), text: 'Selected'),
                _SeatLegend(color: const Color(0xFF283021), text: 'Booked'),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFb8c4ab)), // Changed to b8c4ab
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SeatButton(
                          seatNumber: 1,
                          color: _getSeatColor(1),
                          onTap: () => _toggleSeatSelection(1),
                          isReserved: _reservedSeats.contains(1),
                        ),
                        Text("Driver seat", style: normalsize(context)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SeatButton(
                              seatNumber: 2,
                              color: _getSeatColor(2),
                              onTap: () => _toggleSeatSelection(2),
                              isReserved: _reservedSeats.contains(2),
                            ),
                            SizedBox(width: 10),
                            SeatButton(
                              seatNumber: 3,
                              color: _getSeatColor(3),
                              onTap: () => _toggleSeatSelection(3),
                              isReserved: _reservedSeats.contains(3),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            SeatButton(
                              seatNumber: 4,
                              color: _getSeatColor(4),
                              onTap: () => _toggleSeatSelection(4),
                              isReserved: _reservedSeats.contains(4),
                            ),
                            SizedBox(width: 10),
                            SeatButton(
                              seatNumber: 5,
                              color: _getSeatColor(5),
                              onTap: () => _toggleSeatSelection(5),
                              isReserved: _reservedSeats.contains(5),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SeatButton(
                              seatNumber: 6,
                              color: _getSeatColor(6),
                              onTap: () => _toggleSeatSelection(6),
                              isReserved: _reservedSeats.contains(6),
                            ),
                            SizedBox(width: 10),
                            SeatButton(
                              seatNumber: 7,
                              color: _getSeatColor(7),
                              onTap: () => _toggleSeatSelection(7),
                              isReserved: _reservedSeats.contains(7),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SeatButton(
                              seatNumber: 8,
                              color: _getSeatColor(8),
                              onTap: () => _toggleSeatSelection(8),
                              isReserved: _reservedSeats.contains(8),
                            ),
                            SizedBox(width: 10),
                            SeatButton(
                              seatNumber: 9,
                              color: _getSeatColor(9),
                              onTap: () => _toggleSeatSelection(9),
                              isReserved: _reservedSeats.contains(9),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SeatButton(
                              seatNumber: 10,
                              color: _getSeatColor(10),
                              onTap: () => _toggleSeatSelection(10),
                              isReserved: _reservedSeats.contains(10),
                            ),
                            SizedBox(width: 10),
                            SeatButton(
                              seatNumber: 11,
                              color: _getSeatColor(11),
                              onTap: () => _toggleSeatSelection(11),
                              isReserved: _reservedSeats.contains(11),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SeatButton(
                              seatNumber: 12,
                              color: _getSeatColor(12),
                              onTap: () => _toggleSeatSelection(12),
                              isReserved: _reservedSeats.contains(12),
                            ),
                            SizedBox(width: 10),
                            SeatButton(
                              seatNumber: 13,
                              color: _getSeatColor(13),
                              onTap: () => _toggleSeatSelection(13),
                              isReserved: _reservedSeats.contains(13),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SeatButton(
                              seatNumber: 14,
                              color: _getSeatColor(14),
                              onTap: () => _toggleSeatSelection(14),
                              isReserved: _reservedSeats.contains(14),
                            ),
                            SizedBox(width: 10),
                            SeatButton(
                              seatNumber: 15,
                              color: _getSeatColor(15),
                              onTap: () => _toggleSeatSelection(15),
                              isReserved: _reservedSeats.contains(15),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SeatButton(
                              seatNumber: 16,
                              color: _getSeatColor(16),
                              onTap: () => _toggleSeatSelection(16),
                              isReserved: _reservedSeats.contains(16),
                            ),
                            SizedBox(width: 10),
                            SeatButton(
                              seatNumber: 17,
                              color: _getSeatColor(17),
                              onTap: () => _toggleSeatSelection(17),
                              isReserved: _reservedSeats.contains(17),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SeatButton(
                              seatNumber: 18,
                              color: _getSeatColor(18),
                              onTap: () => _toggleSeatSelection(18),
                              isReserved: _reservedSeats.contains(18),
                            ),
                            SizedBox(width: 10),
                            SeatButton(
                              seatNumber: 19,
                              color: _getSeatColor(19),
                              onTap: () => _toggleSeatSelection(19),
                              isReserved: _reservedSeats.contains(19),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SeatButton(
                              seatNumber: 20,
                              color: _getSeatColor(20),
                              onTap: () => _toggleSeatSelection(20),
                              isReserved: _reservedSeats.contains(20),
                            ),
                            SizedBox(width: 10),
                            SeatButton(
                              seatNumber: 21,
                              color: _getSeatColor(21),
                              onTap: () => _toggleSeatSelection(21),
                              isReserved: _reservedSeats.contains(21),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SeatButton(
                              seatNumber: 22,
                              color: _getSeatColor(22),
                              onTap: () => _toggleSeatSelection(22),
                              isReserved: _reservedSeats.contains(22),
                            ),
                            SizedBox(width: 10),
                            SeatButton(
                              seatNumber: 23,
                              color: _getSeatColor(23),
                              onTap: () => _toggleSeatSelection(23),
                              isReserved: _reservedSeats.contains(23),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SeatButton(
                              seatNumber: 24,
                              color: _getSeatColor(24),
                              onTap: () => _toggleSeatSelection(24),
                              isReserved: _reservedSeats.contains(24),
                            ),
                            SizedBox(width: 10),
                            SeatButton(
                              seatNumber: 25,
                              color: _getSeatColor(25),
                              onTap: () => _toggleSeatSelection(25),
                              isReserved: _reservedSeats.contains(25),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SeatButton(
                          seatNumber: 26,
                          color: _getSeatColor(26),
                          onTap: () => _toggleSeatSelection(26),
                          isReserved: _reservedSeats.contains(26),
                        ),
                        SeatButton(
                          seatNumber: 27,
                          color: _getSeatColor(27),
                          onTap: () => _toggleSeatSelection(27),
                          isReserved: _reservedSeats.contains(27),
                        ),
                        SeatButton(
                          seatNumber: 28,
                          color: _getSeatColor(28),
                          onTap: () => _toggleSeatSelection(28),
                          isReserved: _reservedSeats.contains(28),
                        ),
                        SeatButton(
                          seatNumber: 29,
                          color: _getSeatColor(29),
                          onTap: () => _toggleSeatSelection(29),
                          isReserved: _reservedSeats.contains(29),
                        ),
                        SeatButton(
                          seatNumber: 30,
                          color: _getSeatColor(30),
                          onTap: () => _toggleSeatSelection(30),
                          isReserved: _reservedSeats.contains(30),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_selectedSeats.isNotEmpty) ...[
              const SizedBox(height: 24),
              Card(
                color: const Color(0xFF283021), // Changed to 7a9064
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Booking Summary', style: subheadingStyle(context)),
                      const SizedBox(height: 8),
                      Text('Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}', 
                          style: normalsize(context)),
                      Text('Route: $_selectedRoute', style: normalsize(context)),
                      Text('Time: $_selectedTime', style: normalsize(context)),
                      const SizedBox(height: 8),
                      Text('Selected Seat: ${_selectedSeats.first}', 
                          style: normalsize(context)),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _confirmBooking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7a9064), // Changed to b8c4ab
                            foregroundColor: Colors.black,
                          ),
                          child: Text('Confirm Booking', style: normalsize(context)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildMyBookingsTab() {
    if (_isLoadingBookings) {
      return Center(child: CircularProgressIndicator(
        color: const Color(0xFFb8c4ab), // Changed to b8c4ab
      ));
    }

    if (_userBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_seat, size: 64, color: const Color(0xFFb8c4ab)), // Changed to b8c4ab
            const SizedBox(height: 16),
            Text('No bookings found', style: normalsize(context)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _tabController.animateTo(0),
              child: Text('Book a seat now', style: normalsize(context)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _userBookings.length,
      itemBuilder: (context, index) {
        final booking = _userBookings[index];
        final date = booking['date'] != null
            ? DateTime.fromMillisecondsSinceEpoch(booking['date'] as int)
            : null;
        final seats = booking['seats'] != null
            ? List<int>.from(booking['seats'] as List)
            : <int>[];

        return Card(
          color: const Color(0xFF7a9064), // Changed to 7a9064
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking['route']?.toString() ?? 'Unknown Route', 
                    style: normalsize(context)),
                const SizedBox(height: 8),
                if (date != null)
                  Text('Date: ${DateFormat('dd/MM/yyyy').format(date)}', 
                      style: normalsize(context)),
                Text('Time: ${booking['time']?.toString() ?? 'Unknown'}', 
                    style: normalsize(context)),
                Text('Seats: ${seats.join(', ')}', style: normalsize(context)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _showCancelDialog(
                        booking['bookingId']?.toString() ?? '', seats),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFccdbdc), // Changed to ccdbdc
                      side: BorderSide(color: const Color(0xFFccdbdc)), // Changed to ccdbdc
                    ),
                    child: Text('Cancel Booking', style: normalsize(context)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCancelDialog(String bookingId, List<dynamic> seats) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF7a9064), // Changed to 7a9064
        title: Text('Confirm Cancellation', style: subheadingStyle(context)),
        content: Text('This booking will be permanently removed. Continue?', 
            style: normalsize(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No', style: normalsize(context)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelBooking(bookingId, seats);
            },
            child: Text('Yes, Remove', style: normalsize(context)),
          ),
        ],
      ),
    );
  }
Future<void> _deleteExpiredBookings() async {
  final now = DateTime.now();
  
  try {
    final snapshot = await _dbRef
        .child('user_bookings')
        .orderByChild('userEmail')
        .equalTo(_user.email)
        .get();

    if (snapshot.exists) {
      final bookings = snapshot.value as Map;
      final expiredBookings = <String, List<dynamic>>{};
      
      // Check each booking for expiry
      bookings.forEach((key, value) {
        final booking = Map<String, dynamic>.from(value as Map);
        final date = booking['date'] != null
            ? DateTime.fromMillisecondsSinceEpoch(booking['date'] as int)
            : null;
        final time = booking['time'] as String?;
        final status = booking['status'] as String?;
        final seats = booking['seats'] != null
            ? List<dynamic>.from(booking['seats'] as List)
            : <dynamic>[];
        
        if (date != null && time != null && status == 'confirmed') {
          // Parse the time (format: "04:00 PM")
          final timeComponents = time.split(':');
          int hour = int.parse(timeComponents[0]);
          final minuteAndPeriod = timeComponents[1].split(' ');
          int minute = int.parse(minuteAndPeriod[0]);
          final period = minuteAndPeriod[1];
          
          // Convert to 24-hour format
          if (period == 'PM' && hour < 12) {
            hour += 12;
          } else if (period == 'AM' && hour == 12) {
            hour = 0;
          }
          
          // Create a DateTime object with the booking date and time
          final bookingDateTime = DateTime(
            date.year, date.month, date.day, hour, minute
          );
          
          // Check if the booking is expired
          if (bookingDateTime.isBefore(now)) {
            expiredBookings[key] = seats;
          }
        }
      });
      
      // Delete expired bookings
      for (final entry in expiredBookings.entries) {
        await _cancelBooking(entry.key, entry.value, true);
      }
      
      if (expiredBookings.isNotEmpty) {
        print('Deleted ${expiredBookings.length} expired bookings');
      }
    }
  } catch (e) {
    print('Error checking expired bookings: $e');
  }
}
  Future<void> _cancelBooking(String bookingId, List<dynamic> seats, [bool isAutomatic = false]) async {
  try {
    final bookingSnapshot = await _dbRef.child('user_bookings/$bookingId').get();
    if (!bookingSnapshot.exists) throw Exception('Booking not found');

    final booking = Map<String, dynamic>.from(bookingSnapshot.value as Map);
    final route = booking['route'] as String?;
    final time = booking['time'] as String?;
    final date = booking['date'] as int?;

    if (route == null || time == null || date == null) {
      throw Exception('Missing required booking fields');
    }

    final formattedDate = DateFormat('ddMMyyyy')
        .format(DateTime.fromMillisecondsSinceEpoch(date));
    final routeKey =
        '${route.hashCode}_${time.replaceAll(' ', '')}_$formattedDate';

    final updates = <String, dynamic>{'user_bookings/$bookingId': null};

    if (booking['status'] == 'confirmed') {
      for (final seat in seats) {
        updates['bookings/$routeKey/reservedSeats/$seat'] = null;
      }
    }

    await _dbRef.update(updates);
    
    if (!isAutomatic) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(backgroundColor: Color(0xFF1E1E1F),content: Text('Booking cancelled and removed',style: normalsize(context))),
      );
    }

    setState(() {
      _userBookings.removeWhere((b) => b['bookingId'] == bookingId);
    });
  } catch (e) {
    if (!isAutomatic) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Color(0xFF1E1E1F),content: Text('Cancellation failed: ${e.toString()}',style: normalsize(context))),
      );
    } else {
      print('Automatic cancellation failed: $e');
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async{
        await _loadReservedSeats();
        await _loadUserBookings();
        await _loadUserData();
        await _buildMyBookingsTab();

      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text('Bus Booking', style: mainHeadingStyle(context)),
          bottom: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFFb8c4ab), // Changed to b8c4ab
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFFb8c4ab), // Changed to b8c4ab
            tabs: [
              Tab(
                icon: Icon(Icons.directions_bus, color: const Color(0xFFb8c4ab)), // Changed to b8c4ab
                text: 'Book Seats',
              ),
              Tab(
                icon: Icon(Icons.list, color: const Color(0xFFb8c4ab)), // Changed to b8c4ab
                text: 'My Bookings',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [_buildBookingTab(), _buildMyBookingsTab()],
        ),
      ),
    );
  }
}

class SeatButton extends StatelessWidget {
  final int seatNumber;
  final Color color;
  final VoidCallback onTap;
  final bool isReserved;

  const SeatButton({
    super.key,
    required this.seatNumber,
    required this.color,
    required this.onTap,
    required this.isReserved,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isReserved ? null : onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFb8c4ab)), // Changed to b8c4ab
        ),
        child: Center(
          child: Text(
            seatNumber.toString(),
            style: TextStyle(
                color: isReserved ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _SeatLegend extends StatelessWidget {
  final Color color;
  final String text;

  const _SeatLegend({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 4),
        Text(text, style: normalsize(context)),
      ],
    );
  }
}