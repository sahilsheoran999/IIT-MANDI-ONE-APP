import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  LatLng? _userLocation;

  static const LatLng _southcampusLocation = LatLng(31.7724, 76.9842);
  static const LatLng _northcampusLocation = LatLng(31.7815, 76.9989);
  static const LatLng _targetLocation = LatLng(31.77695, 76.99155); // Main location
  static const double _radius = 10000; // Radius in meters

  final CameraPosition _initialPosition = CameraPosition(
    target: _targetLocation,
    zoom: 15,
  );

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        print("Location permissions are denied forever.");
        return;
      }
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    LatLng newUserLocation = LatLng(position.latitude, position.longitude);
    print("User Location: ${position.latitude}, ${position.longitude}");

    double distance = Geolocator.distanceBetween(
      _targetLocation.latitude,
      _targetLocation.longitude,
      newUserLocation.latitude,
      newUserLocation.longitude,
    );

    if (distance <= _radius) {
      setState(() {
        _userLocation = newUserLocation;
      });

      // Ensure controller is initialized before animating camera
      if (_controller != null) {
        _controller!.animateCamera(
          CameraUpdate.newLatLngZoom(newUserLocation, 16),
        );
      } else {
        print("Controller is null, cannot animate camera.");
      }
    } else {
      print("User is outside the allowed radius.");
    }
  }

  @override
  Widget build(BuildContext context) {
    var h=MediaQuery.of(context).size.height;
    return Scaffold(
      
      body: GoogleMap(
        initialCameraPosition: _initialPosition,
        mapType: MapType.normal,
        markers: {
          Marker(
            markerId: MarkerId("south campus"),
            position: _southcampusLocation,
            infoWindow: InfoWindow(title: "south Location"),
          ),
          Marker(markerId: MarkerId("north campus"), 
              position: _northcampusLocation,
              infoWindow: InfoWindow(title: "north campus")
            ),
          if (_userLocation != null)
            Marker(
              markerId: MarkerId("user"),
              position: _userLocation!,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              infoWindow: InfoWindow(title: "You are here!"),
            ),
        },
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
          setState(() {}); // Ensure controller is updated
        },
      ),
      floatingActionButton: Padding(
  padding: EdgeInsets.only(bottom: h*0.1), // Adjust this value as needed
  child: FloatingActionButton(
    onPressed: _getUserLocation,
    backgroundColor: Color(0xFF283021),
    child: Icon(Icons.my_location, color: Color(0xFF7a9064)),
  ),
),
    );
  }
}
