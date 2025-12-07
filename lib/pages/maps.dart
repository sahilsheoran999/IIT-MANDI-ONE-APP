import 'package:flutter/material.dart';
import 'package:project/Boxes/map.dart';
import 'package:project/Boxes/south3dmap.dart';
import 'package:project/pages/campus_map.dart';

class PageViewExample extends StatefulWidget {
  @override
  _PageViewExampleState createState() => _PageViewExampleState();
}

class _PageViewExampleState extends State<PageViewExample> {
  PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            physics: NeverScrollableScrollPhysics(), // Disables swipe gestures
            children: [
              MapScreen(),
              ModelViewerPage(),
              south3dmapPage(),
            ],
          ),
          // Buttons positioned at bottom-left
          Positioned(
            bottom: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  
                  onPressed: () => _controller.jumpToPage(0), // Show Google Maps
                  icon: Icon(Icons.map, color: Color(0xFF7a9064),),
                  label: Text("General Map", style: TextStyle(color: Color(0xFF7a9064)),),
                
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => _controller.jumpToPage(1), // Show 3D Model
                  icon: Icon(Icons.threed_rotation, color: Color(0xFF7a9064),),
                  label: Text("3D North Map",style: TextStyle(color: Color(0xFF7a9064))),
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => _controller.jumpToPage(2), // Show 3D Model
                  icon: Icon(Icons.threed_rotation, color: Color(0xFF7a9064),),
                  label: Text("3D south Map",style: TextStyle(color: Color(0xFF7a9064))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Replace these with your actual pages
class GoogleMapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Google Map Page"));
  }
}

class ThreeDModelScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("3D Model Page"));
  }
}

class southModelScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("3D south Page"));
  }
}
