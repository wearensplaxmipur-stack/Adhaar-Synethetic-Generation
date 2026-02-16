import 'dart:typed_data';

import 'package:adhaar/card/print/a4_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class GetImage extends StatefulWidget {
 final bool full;
  const GetImage({super.key,required this.full});

  @override
  State<GetImage> createState() => _GetImageState();
}

class _GetImageState extends State<GetImage> {
  pickImage(ImageSource source,bool thisone) async {
    final ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: source);

    if (file != null) {
      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        setState(() {
          if(thisone){
            mypic = bytes;
          }else{
            mypic2 = bytes;
          }
        });
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
        setState(() {
          if(thisone){
            mypic = bytes;
          }else{
            mypic2 = bytes;
          }
        });
        return;
      }
    }
  }
  Uint8List? mypic, mypic2;


  void initState(){
    full = widget.full;
  }
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar:AppBar(
        title: Text("A4 Image"),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: (){
                  setState(() {
                    full = !full;
                  });
                },
                child: Container(
                  width: w/2-15,
                  height: 100,
                  decoration: BoxDecoration(
                    border:Border.all(
                      color:full ?Colors.blue:Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.stacked_line_chart),
                      Text("Full Length",style: TextStyle(fontWeight: FontWeight.w900),),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: (){
                  setState(() {
                    full = !full;
                  });
                },
                child: Container(
                  width: w/2-15,
                  height: 100,
                  decoration: BoxDecoration(
                      border:Border.all(
                        color:!full ?Colors.blue:Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.stacked_line_chart),
                      Text("Half Length",style: TextStyle(fontWeight: FontWeight.w900),),
                    ],
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 20,),
          InkWell(
            onTap: () async {
              await pickImage(ImageSource.gallery, false);
            },
            child: Container(
              width: w-20,
              height: 230,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
                image: mypic2 == null
                    ? null
                    : DecorationImage(
                  image: MemoryImage(mypic2!),
                  fit: BoxFit.cover,
                ),
              ),
              child: mypic2!=null?SizedBox():Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_size_select_actual,size: 35,),
                  SizedBox(height: 5,),
                  Text("Select Front Page",style: TextStyle(fontWeight: FontWeight.w900),),
                ],
              ),
            ),
          ),
          SizedBox(height: 10,),
          InkWell(
            onTap: () async {
              await pickImage(ImageSource.gallery, true);
            },
            child: Container(
              width: w-20,
              height: 230,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
                image: mypic == null
                    ? null
                    : DecorationImage(
                  image: MemoryImage(mypic!),
                  fit: BoxFit.cover,
                ),
              ),
              child: mypic!=null?SizedBox():Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_size_select_actual,size: 35,),
                  SizedBox(height: 5,),
                  Text("Select Back Page",style: TextStyle(fontWeight: FontWeight.w900),),
                ],
              ),
            ),
          ),
        ],
      ),
      persistentFooterButtons: [
        InkWell(
          onTap: (){
            if(mypic==null||mypic2==null){
              return ;
            }
            Navigator.push(context, MaterialPageRoute(builder: (_)=>A4PrintPage(full:full,mypic: mypic!, mypic2: mypic2!)));
          },
          child: Container(
            width: w-10,
            height: 55,
            color: (mypic==null||mypic2==null)?Colors.grey:Colors.red,
            child: Center(child: Text("Yes, Continue"
              ,style: TextStyle(fontWeight: FontWeight.w900,color: Colors.white),)),
          ),
        )
      ],
    );
  }
  bool full = false;
}
