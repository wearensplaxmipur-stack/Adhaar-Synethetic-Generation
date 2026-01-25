import 'package:adhaar/main_pages/home.dart';
import 'package:adhaar/model/user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adhaar',
      theme: ThemeData(
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