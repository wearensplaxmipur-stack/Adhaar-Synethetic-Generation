import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:adhaar/admin/see_all.dart';
import 'package:adhaar/card/adhaar/address/default_address.dart';
import 'package:adhaar/card/adhaar/adhaar.dart';
import 'package:adhaar/card/print/get_image.dart';
import 'package:adhaar/main.dart';
import 'package:adhaar/passport/passport.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../global.dart' show Global;

class Home extends StatefulWidget {
  final String username;
  const Home({super.key,required this.username});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    savePdfToStorage();
    requestStoragePermission();
  }
  Future<void> savePdfToStorage() async {
    bool granted = await requestStoragePermission();

    if (!granted) {
      debugPrint("❌ Storage permission denied");
      return;
    }

    debugPrint("✅ Permission granted, can read/write");
  }


  Future<bool> requestStoragePermission() async {

    if (await Permission.photos.isDenied || await Permission.videos.isDenied) {
      final statuses = await [
        Permission.photos,
        Permission.videos,
      ].request();

      return statuses.values.every((s) => s.isGranted);
    }

    if (await Permission.storage.isDenied) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              title: const Text("Close the App ?"),
              content: const Text("You sure to Close the App"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.red),
                  ),
                  onPressed: () async {
                    Navigator.pop(context, true);
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
        return shouldExit ?? false; // true = allow back
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(
              color: Colors.white
          ),
          title:  Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: InkWell(
              onTap: (){
                Navigator.push(context,MaterialPageRoute(builder: (_)=>AdhaarFormPage()));
              },
              child: Container(
                width: w-100,
                height: 45,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Color(0xff222327)
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Icon(Icons.print_rounded,color: Colors.white,),
                      SizedBox(width: 10),
                      Text("Print Adhaar",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w800,fontSize: 16),)
                    ],
                  ),
                ),
              ),
            ),
          ),
          leading: Builder(
            builder: (context) => Padding(
              padding: const EdgeInsets.only(left: 4.0,top: 4,bottom: 4),
              child: InkWell(
                  onTap: (){
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(image: AssetImage("assets/logo.jpg"))
                    ),
                  )
              ),
            ),
          ),
          actions: [
            IconButton(onPressed: (){
              AdaptiveTheme.of(context).toggleThemeMode();
            }, icon: Icon(Icons.sunny,color: Colors.white,)),
            IconButton(onPressed: (){
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0), // Rectangle (no rounded edges)
                    ),
                    title: const Text("Log out ?"),
                    content: const Text("You sure to Log out from the App"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false), // Cancel
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setString('username', "NA");
                          await prefs.setString('id',"NA");
                          Navigator.pop(context);
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>MyApp()));
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith(
                                (states) => Colors.red,   // your color here
                          ),
                        ),
                        child: const Text("OK",style: TextStyle(color: Colors.white)),
                      )
                    ],
                  );
                },
              );
            }, icon: Icon(Icons.login,color: Colors.red,)),
            SizedBox(width: 15,),
          ],
        ),
        body: Column(
          children:[
            SizedBox(height: 10,),
            CarouselSlider(
              options: CarouselOptions(
                height: 180,
                aspectRatio: 16 / 9,
                viewportFraction: 1,
                initialPage: 0,
                enableInfiniteScroll: true,
                reverse: false,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 3),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
                enlargeFactor: 0.3,
                scrollDirection: Axis.horizontal,
              ),
              items:
              [
                "assets/gif.gif",
                "assets/c28d5780-35fe-467f-a1da-7707a1677634.jpg",
                "assets/1027b856-ff87-4f8d-b16f-f92581bcedb9.jpg"
              ].map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Container(
                        width: w - 15,
                        height:180,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(7),
                          image: DecorationImage(
                            image: AssetImage(i),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 10,),
            Center(
        child: Container(
        width: w-15,
          decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.grey.shade200
              ),
              borderRadius: BorderRadius.circular(10)
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0,bottom: 15),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("    All App Functions",style: TextStyle(fontWeight: FontWeight.w700),textAlign: TextAlign.start,),
                  SizedBox(height: 9,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                          onTap: (){
                            Navigator.push(context,MaterialPageRoute(builder: (_)=>AdhaarFormPage()));
                          },
                          child: q(context,"assets/adhaar-card-free-update-steps.jpg","Adhaar Card ")),
                      InkWell(
                          onTap: (){
                            Navigator.push(context,MaterialPageRoute(builder: (_)=>GetImage(full: true)));
                          },
                          child: q(context,"assets/landscape.gif","Landscape A4")),
                      widget.username=="Atif5050"?InkWell(
                          onTap: (){
                            Navigator.push(context,MaterialPageRoute(builder: (_)=>SeeAllAdmin(cons: s1,)));
                          },
                          child: q(context,"assets/my.webp","Super Admin")):InkWell(
                          onTap: (){
                            Navigator.push(context,MaterialPageRoute(builder: (_)=>GetImage(full: false)));
                          },
                          child: q1(context,"assets/portrait.gif","Portrait A4")),
                      InkWell(
                          onTap: () async {
                            final ImagePicker picker = ImagePicker();
                            XFile? file = await picker.pickImage(source: ImageSource.gallery);

                            if (file != null) {
                              if (kIsWeb) {
                                final bytes = await file.readAsBytes();Navigator.push(context, MaterialPageRoute(builder: (_)=>A4GridPrintPassport(image: bytes)));
                                return;
                              }
                              final croppedFile = await ImageCropper().cropImage(
                                sourcePath: file.path,
                                uiSettings: [
                                  AndroidUiSettings(
                                    toolbarTitle: 'Crop Adhaar Image',
                                    toolbarColor: Colors.deepOrange,
                                    toolbarWidgetColor: Colors.white,
                                    initAspectRatio: CropAspectRatioPreset.original,
                                    lockAspectRatio: false,
                                  ),
                                  IOSUiSettings(title: 'Cropper'),
                                ],
                              );

                              if (croppedFile != null) {
                                final bytes = await croppedFile.readAsBytes();
                                Navigator.push(context, MaterialPageRoute(builder: (_)=>A4GridPrintPassport(image: bytes)));
                                return;
                              }
                            }
                          },
                          child: q(context,"assets/photo.gif","Passport Photo")),
                    ],
                  ),
                  SizedBox(height: 9,),
                ],
              ),
            ),
          ),
        ),
      ),
            SizedBox(height: 15,),
            Center(
              child: Container(
                width: w-15,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.grey.shade200
                    ),
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0,bottom: 15),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("    Settings",style: TextStyle(fontWeight: FontWeight.w700),textAlign: TextAlign.start,),
                        SizedBox(height: 9,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                                onTap: (){
                                  AdaptiveTheme.of(context).toggleThemeMode();
                                },
                                child: q1(context,"assets/toggle.gif","Toggle Theme")),
                            InkWell(
                                onTap: (){
                                  Navigator.push(context,MaterialPageRoute(builder: (_)=>DefaultAddress(hindi: false,)));
                                },
                                child: q(context,"assets/address.png","Address English")),
                           InkWell(
                                onTap: (){
                                  Navigator.push(context,MaterialPageRoute(builder: (_)=>DefaultAddress(hindi: true)));
                                },
                                child: q(context,"assets/address2.png","Address Hindi")),
                            InkWell(
                                onTap: () async {

                                },
                                child: q(context,"assets/setting.gif","Form Setting")),
                          ],
                        ),
                        SizedBox(height: 9,),
                      ],
                    ),
                  ),
                ),
              ),
            )

          ]
        ),
      ),
    );
  }
  Widget q(BuildContext context, String asset, String str) {
    double d = MediaQuery.of(context).size.width / 4 - 35;
    return Column(
      children: [
        Container(
            width: d,
            height: d,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(asset, height: d-50,))),
        SizedBox(height: 7),
        Text(str, style: TextStyle(fontWeight: FontWeight.w400,fontSize: 9)),
      ],
    );
  }
  Widget q1(BuildContext context, String asset, String str) {
    double d = MediaQuery.of(context).size.width / 4 - 35;
    return Column(
      children: [
        Container(
            width: d,
            height: d,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage(asset),fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(10),
            ),),
        SizedBox(height: 7),
        Text(str, style: TextStyle(fontWeight: FontWeight.w400,fontSize: 9)),
      ],
    );
  }
}
