import 'package:flutter/material.dart';

// your h and w extension
extension SizeExtension on BuildContext {
  double get h => MediaQuery.of(this).size.height;
  double get w => MediaQuery.of(this).size.width;
}

// Not const anymore - use functions that return TextStyle
TextStyle mainHeadingStyle(BuildContext context) => TextStyle(
  fontSize: context.h * 0.03, // 3% of screen height
  fontWeight: FontWeight.bold,
  color: const Color(0xFFccdbdc),
  overflow: TextOverflow.clip,
);

TextStyle subheadingStyle(BuildContext context) => TextStyle(
  fontSize: context.h * 0.02, // 3% of screen height
  fontWeight: FontWeight.w600,
  color: const Color(0xFFccdbdc),
  overflow: TextOverflow.clip,
);

TextStyle normalsize(BuildContext context) => TextStyle(
  fontSize: context.h * 0.015, // 3% of screen height
  color: const Color(0xFFccdbdc),
  overflow: TextOverflow.clip,
);