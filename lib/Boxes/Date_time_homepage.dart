import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';


class Datetime extends StatefulWidget {
  const Datetime({super.key});

  @override
  State<Datetime> createState() => _DatetimeState();
}

class _DatetimeState extends State<Datetime> {
  late Timer _timer;
  String _timeString = '';
  String _dateString = '';
  String _greeting = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) => _updateTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    final DateTime now = DateTime.now();
    final String formattedTime = DateFormat('HH:mm').format(now);
    final String formattedDate = '${now.day}${_getDaySuffix(now.day)} ${DateFormat('MMMM').format(now)}';
    
    setState(() {
      _timeString = formattedTime;
      _dateString = formattedDate;
      _greeting = _getGreeting(now);
    });
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  String _getGreeting(DateTime now) {
    final int hour = now.hour;

    if (hour >= 3 && hour < 5) {
      return 'Why are you awake?';
    } else if (hour >= 5 && hour < 12) {
      return 'Good morning!';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon!';
    } else if (hour >= 17 && hour < 21) {
      return 'Good evening!';
    } else if (hour >= 21 && hour < 24) {
      return 'Good evening!';
    } else if (hour >= 0 && hour < 1) {
      return 'Go to sleep already';
    } else {
      return 'Planning for all-nighter?';
    }
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              _timeString,
              style: TextStyle(
                fontSize: h * 0.05,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF7a9064),
                overflow: TextOverflow.ellipsis
              ),
            ),
            const SizedBox(width: 1),
            Padding(
              padding: const EdgeInsets.only(bottom: 4), // Adjust this value to align perfectly
              child: Text(
                _dateString,
                style: TextStyle(
                  fontSize: h * 0.02,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF7a9064),
                  overflow: TextOverflow.ellipsis
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _greeting,
          style: TextStyle(
            fontSize: h * 0.02,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF7a9064),
            overflow: TextOverflow.ellipsis
          ),
        ),
      ],
    );
  }
}