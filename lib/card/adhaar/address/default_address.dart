import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../adhaar.dart' show gField;

class DefaultAddress extends StatefulWidget {
 final bool hindi;
  const DefaultAddress({super.key,required this.hindi});

  @override
  State<DefaultAddress> createState() => _DefaultAddressState();
}

class _DefaultAddressState extends State<DefaultAddress> {
  bool progress = false;

  @override
  void initState(){
    get();
  }
  get() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String str = "";
    if(widget.hindi){
      str = await prefs.getString('hindi')??"";
    }else{
      str = await prefs.getString('english')??"";
    }
    setState(() {
      addressC.text = str;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Default Address"),
      ),
      body: Column(
        children: [
          progress?LinearProgressIndicator():SizedBox(),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: gField(c: addressC, label: 'Address', maxLines: 3),
          ),
        ],
      ),
      persistentFooterButtons: [
        InkWell(
          onTap: () async {
            setState(() {
              progress=true;
            });
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            if(widget.hindi){
              await prefs.setString('hindi', addressC.text);
            }else{
              await prefs.setString('english', addressC.text);
            }
            Navigator.pop(context, addressC.text);
          },
          child: Container(
            width: MediaQuery.of(context).size.width, height: 55,
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(10)
            ),
            child: Center(child: Text("Yes, Save "+"${widget.hindi?"Hindi":"English"}"+" Default Address",style:
              TextStyle(fontWeight: FontWeight.w900,color: Colors.black),),),
          ),
        ),
      ],
    );
  }
  TextEditingController addressC = TextEditingController();
}
