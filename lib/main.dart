import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:adhaar/main_pages/home.dart';
import 'package:adhaar/model/user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'login/function.dart';
import 'login/login.dart' show Login;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF6F7F9), // Light background
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0E0E0E),
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          systemOverlayStyle: SystemUiOverlayStyle.light,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      dark: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        scaffoldBackgroundColor: const Color(0xFF0B0B0B), // Dark background

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0E0E0E),
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          systemOverlayStyle: SystemUiOverlayStyle.light,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      initial: AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: darkTheme,
        home: const MyHomePage(title: "",),
      ),
    );
    return MaterialApp(
      title: 'Adhaar',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D47A1), // AppBar color
          foregroundColor: Colors.white,      // Icons + back button + title color
          iconTheme: IconThemeData(
            color: Colors.white,              // Action icons
            size: 22,
          ),
          titleTextStyle: TextStyle(
            color: Colors.white,              // Title text
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          toolbarTextStyle: TextStyle(
            color: Colors.white,              // Subtitle / actions text
            fontSize: 16,
          ),
          elevation: 0,                       // Shadow
          centerTitle: true,                  // Global title alignment
        ),
       fontFamily: "NotoSerif",
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
String s1 = "ADHAARLOGIN";

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState(){
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String s = await prefs.getString('username')??"NA";
    if(s!="NA"){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Home(username: s,),
        ),
      );
    }else{
      Future.delayed(const Duration(seconds: 3), () async {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>  Login(str: s1),
          ),
        );
      });
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xffF5F4F0),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Image(
            image: AssetImage('assets/logo.jpg'),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}