


import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';


class Global {


  static button(double w, String str)=> Container(
    width: w-20,height: 50,
    decoration: BoxDecoration(
        color: Colors.yellow,
        borderRadius: BorderRadius.circular(5)
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(str,style: TextStyle(fontWeight: FontWeight.w800),),
        SizedBox(width: 9,),
        Icon(Icons.arrow_forward,color: Colors.black,)
      ],
    ),
  );
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