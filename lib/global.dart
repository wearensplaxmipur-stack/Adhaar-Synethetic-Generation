


import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';


class Global {


  static Color grey = Colors.white;

  static bool themebool(BuildContext context) {
    switch (AdaptiveTheme.of(context).mode) {
      case AdaptiveThemeMode.light:
        return true;
      case AdaptiveThemeMode.dark:
        return false;
      default:
        return false;
    }
  }

}
class CacheState {
  static bool usingHive = false;
  static bool usingFirestore = false;

  static void setHive() {
    usingHive = true;
    usingFirestore = false;
  }

  static void setFirestore() {
    usingHive = false;
    usingFirestore = true;
  }
}