import 'package:flutter/material.dart';

class AppFonts {
  static const String primaryFont = 'Poppins';

  static TextStyle headingStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );

  static TextStyle subheadingStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w600, 
  );

  static TextStyle bodyStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const captionStyle = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );
  
  static TextStyle versionStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

}