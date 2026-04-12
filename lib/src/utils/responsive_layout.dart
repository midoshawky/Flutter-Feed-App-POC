import 'package:flutter/material.dart';

class ResponsiveLayout {
  static const double mobileBreakpoint = 600;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;
      
  static bool isWeb(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint;
}
