









import 'package:adhaar/admin/see_all.dart';
import 'package:adhaar/card/adhaar/adhaar.dart';
import 'package:adhaar/card/print/get_image.dart';
import 'package:adhaar/main.dart';
import 'package:adhaar/passport/passport.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    // ✅ safe to read/write
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

    // Android 12 and below
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text("Home",style: TextStyle(color: Colors.white),),
          actions: [
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
            }, icon: Icon(Icons.login,color: Colors.red,))
          ],
        ),
        body: Column(
          children:[
            Container(
              width: w-20,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage("assets/google.png"))
              ),
            ),
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
                          child: q(context,"assets/images.png","Landscape A4")),
                      widget.username=="Atif5050"?InkWell(
                          onTap: (){
                            Navigator.push(context,MaterialPageRoute(builder: (_)=>SeeAllAdmin(cons: s1,)));
                          },
                          child: q(context,"assets/my.webp","Super Admin")):InkWell(
                          onTap: (){
                            Navigator.push(context,MaterialPageRoute(builder: (_)=>GetImage(full: false)));
                          },
                          child: q(context,"assets/images (1).png","Portrait A4")),
                      InkWell(
                          onTap: () async {
                            final ImagePicker picker = ImagePicker();
                            XFile? file = await picker.pickImage(source: ImageSource.gallery);

                            if (file != null) {
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
                          child: q(context,"assets/human.jpg","Passport Photo")),
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
}
