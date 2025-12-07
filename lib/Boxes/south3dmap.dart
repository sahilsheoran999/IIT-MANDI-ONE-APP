import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class south3dmapPage extends StatelessWidget {
  const south3dmapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Stack(
        children: [
          // 🔥 Draw grid behind the model
          Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(),
            ),
          ),

          // 🔥 3D Model Viewer
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: MediaQuery.of(context).size.width / MediaQuery.of(context).size.height,
              child: ModelViewer(
                src: 'assets/southmodel.glb',
                alt: "A 3D model",
                autoRotate: false,
                cameraControls: true,
                backgroundColor: Colors.transparent,
                cameraOrbit: '0deg -30deg 500m',
                fieldOfView: '20deg',
                minCameraOrbit: '-180deg -60deg 100m',
                maxCameraOrbit: '180deg 90deg 500m',
                minFieldOfView: '10deg',
                maxFieldOfView: '30deg',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🎯 Custom Painter for the grid
class GridPainter extends CustomPainter {
  final double gridSize = 50; // Size of each grid square
  final Paint gridPaint = Paint()
    ..color = Colors.grey.withOpacity(0.2) // White with transparency
    ..strokeWidth = 0.5; // Thin lines

  @override
  void paint(Canvas canvas, Size size) {
    // Draw vertical lines
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
