import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ImageCarousel extends StatefulWidget {
  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final List<String> assetImages = [
    'assets/campus2.jpg',
    'assets/campus1.jpg',
    'assets/campus4.jpg',
    'assets/campus3.jpg',
    'assets/campus5.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      height: h * 0.61,
      child: CarouselSlider(
        options: CarouselOptions(
          height: h * 0.61,
          autoPlay: true,
          autoPlayInterval: Duration(seconds: 3),
          autoPlayAnimationDuration: Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: false,
          viewportFraction: 1.0,
        ),
        items: assetImages.map((path) {
          return Stack(
            children: [
              // Background image
              Container(
                width: double.infinity,
                height: h * 0.61,
                child: Image.asset(
                  path,
                  fit: BoxFit.cover,
                ),
              ),
              // Gradient overlay (bottom to top fade)
              Container(
                width: double.infinity,
                height: h * 0.61,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.white.withOpacity(0.7), // Stronger at the bottom
                      Colors.white.withOpacity(0.0), // Fades to transparent at the top
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: ImageCarousel()));
