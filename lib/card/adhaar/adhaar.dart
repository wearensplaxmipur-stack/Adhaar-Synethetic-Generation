import 'dart:io';
import 'dart:typed_data';

import 'package:adhaar/card/adhaar/card.dart';
import 'package:adhaar/global.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../../model/adhaar_model.dart';
import 'package:step_progress/step_progress.dart';

import 'address/default_address.dart';


Widget gField({
  required TextEditingController c,
  required String label,
  int maxLines = 1,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: c,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
    ),
  );
}

// ================= PAGE =================
class AdhaarFormPage extends StatefulWidget {
  const AdhaarFormPage({super.key});

  @override
  State<AdhaarFormPage> createState() => _AdhaarFormPageState();
}

class _AdhaarFormPageState extends State<AdhaarFormPage> {
  final formKey = GlobalKey<FormState>();

  final nameC = TextEditingController();
  final fatherC = TextEditingController();
  final hNameC = TextEditingController();
  final hFatherC = TextEditingController();
  final addressC = TextEditingController();
  final hAddressC = TextEditingController();
  final issuedC = TextEditingController();
  final detailsC = TextEditingController();
  final genderC = TextEditingController();
  final vidC = TextEditingController();
  final adhaarIdC = TextEditingController();
  late StepProgressController stepProgressController;

  @override
  void initState(){
    stepProgressController = StepProgressController(totalSteps: 3);
    super.initState();
    genderC.text = "पुरुष/ MALE";
  }
  AdhaarModel? savedModel;

  pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: source);

    if (file != null) {
      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        setState(() {
          mypic = bytes;
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
          mypic = bytes;
        });
        return;
      }
    }
  }
  @override
  void dispose() {
    nameC.dispose();
    vidC.dispose();
    adhaarIdC.dispose();
    fatherC.dispose();
    hNameC.dispose();
    hFatherC.dispose();
    addressC.dispose();
    hAddressC.dispose();
    issuedC.dispose();
    detailsC.dispose();
    genderC.dispose();
    super.dispose();
    stepProgressController.dispose();
  }

  bool done = false;
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              title: const Text("Close the Generator ?"),
              content: const Text("Your Entries may not be Saved"),
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
        appBar: AppBar(title: const Text('Adhaar Form'),actions: [
        ],),
        body: Form(
          key: formKey,
          child: Column(
            children: [
              Container(
                width: w,
                height: 80,
                child: StepProgress(
                  totalSteps: 3,
                  padding: const EdgeInsets.all(10),
                  controller: stepProgressController,
                  lineSubTitles: const [
                    'Front',
                    'Back',
                    "Confirm"
                  ],
                  theme: const StepProgressThemeData(
                    stepLineSpacing: 28,
                    stepLineStyle: StepLineStyle(
                      lineThickness: 10,
                      isBreadcrumb: true,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                  width: w,
                  height: h-250,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: colum(w),
                    ),
                  )
              ),
            ],
          ),
        ),
        persistentFooterButtons: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap: (){
                  stepProgressController.previousStep();
                  if(i==0){
                    return ;
                  }
                  setState(() {
                    i--;
                  });
                },
                child: CircleAvatar(
                  backgroundColor: i==0?Colors.grey.shade400:Colors.yellow,
                  radius: 25,
                  child: Icon(Icons.arrow_back,color: Colors.black,),
                ),
              ),
              InkWell(
                onTap: (){
                  if(i !=2){
                    stepProgressController.nextStep();
                    setState(() {
                      i++;
                    });
                    return ;
                  }
                  if(mypic==null){
                    const snackBar = SnackBar(content: Text('Please put Picture'));
                    
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    return ;
                  }
                  if (!formKey.currentState!.validate()){
                    const snackBar = SnackBar(content: Text('Please fill all form data'));

                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    return ;
                  }
                  AdhaarModel model = AdhaarModel(
                    name: nameC.text.trim(),
                    fatherName: fatherC.text.trim(),
                    hindiName: hNameC.text.trim(),
                    hindiFatherName: hFatherC.text.trim(),
                    address: addressC.text.trim(),
                    hindiAddress: hAddressC.text.trim(),
                    adhaarIssued: issuedC.text.trim(),
                    details: detailsC.text.trim(),
                    gender: genderC.text.trim(),
                    vid: vidC.text.trim(),
                    adhaarId: adhaarIdC.text.trim(),
                    qrId:"",
                    photo: mypic,
                  );

                  setState(() => savedModel = model);

                  Navigator.push(context, MaterialPageRoute(builder: (_)=>A4PrintPage(model: model)));
                  debugPrint("SAVED ADHAADEL => ${model.toJson()}");

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Adhaar  Saved")),
                  );

                },
                child: Global.button(w-70, "Continue"),
              ),
            ],
          ),
        ],
      ),
    );
  }
  int  i = 0;
  bool english = false, hindi = false;
  Widget colum(double w){
    if(i==0){
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: InkWell(
              onTap: () async {
                await pickImage(ImageSource.gallery);
              },
              child: Container(
                width: w / 4,
                height: w / 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade500,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                  image: mypic == null
                      ? null
                      : DecorationImage(
                    image: MemoryImage(mypic!),
                    fit: BoxFit.cover,
                  ),
                ),
                child: mypic == null
                    ? const Center(child: Icon(Icons.add_a_photo, size: 30))
                    : null,
              ),
            ),
          ),
          gField(c: nameC, label: 'Name'),
          gField(c: fatherC, label: 'Father Name'),
          gField(c: hNameC, label: 'Hindi Name'),
          gField(c: hFatherC, label: 'Hindi Father Name'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: (){
                  setState(() {
                    genderC.text = "पुरुष/ MALE";
                    full=!full;
                  });
                },
                child: Container(
                  width: w/2-18,
                  height: 100,
                  decoration: BoxDecoration(
                      border:Border.all(
                        color:full?Colors.blue:Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.male_outlined),
                      Text("पुरुष/ MALE",style: TextStyle(fontWeight: FontWeight.w900),),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: (){
                  setState(() {
                    genderC.text = "महिला/ FEMALE";
                    full=!full;
                  });
                },
                child: Container(
                  width: w/2-17,
                  height: 100,
                  decoration: BoxDecoration(
                      border:Border.all(
                        color:!full ?Colors.blue:Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.female),
                      Text("महिला/ FEMALE",style: TextStyle(fontWeight: FontWeight.w900),),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      );
    }else if(i==1){
      return Column(
        children: [
              Row(
                children: [
                  Container(
                    width: w-60,
                    height: 50,
                    child: CheckboxListTile(
                      title: Text("Use Default English Address"),
                      value: english,
                      onChanged: (newValue) {
                        setState(() async {
                          if(newValue==null){
                            return ;
                          }
                          if(newValue){
                            final SharedPreferences prefs = await SharedPreferences.getInstance();
                            String str = await prefs.getString('english')??"";
                            setState(() {
                              english=newValue;
                              addressC.text = str;
                            });
                          }else{
                            setState(() {
                              english=newValue;
                              addressC.text="";
                            });
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                    ),
                  ),Spacer(),
                  InkWell(
                      onTap: () async {
                        String? str = await Navigator.push(context,MaterialPageRoute(builder: (_)=>DefaultAddress(hindi: false,)));
                        if(str==null){
                          return ;
                        }
                        setState(() {
                          addressC.text = str;
                          english=true;
                        });},
                      child: Icon(Icons.edit_note_sharp,color: Colors.deepOrange,size: 30,)),
                ],
              ),
          SizedBox(
            height: 10,
          ),
          gField(c: addressC, label: 'Address', maxLines: 3),
          Row(
            children: [
              Container(
                width: w-60,
                height: 50,
                child: CheckboxListTile(
                  title: Text("Use Default Hindi Address"),
                  value: hindi,
                  onChanged: (newValue) {
                    setState(() async {
                      if(newValue==null){
                        return ;
                      }
                      if(newValue){
                        final SharedPreferences prefs = await SharedPreferences.getInstance();
                        String str = await prefs.getString('hindi')??"";
                        setState(() {
                          hindi=newValue;
                          hAddressC.text = str;
                        });
                      }else{
                        setState(() {
                          hindi=newValue;
                          hAddressC.text="";
                        });
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                ),
              ),Spacer(),
              InkWell(
                  onTap: () async {
                    String? str = await Navigator.push(context,MaterialPageRoute(builder: (_)=>DefaultAddress(hindi: true,)));
                    if(str==null){
                      return ;
                    }
                    setState(() {
                      hAddressC.text = str;
                      hindi=true;
                    });},
                  child: Icon(Icons.edit_note_sharp,color: Colors.deepOrange,size: 30,)),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          gField(c: hAddressC, label: 'Hindi Address', maxLines: 3),
        ],
      );
    }
    return Column(
      children: [
        const SizedBox(height: 15),
        gField(c: issuedC, label: 'Adhaar Issued Date ( DD/MM/YYY)'),
        gField(c: detailsC, label: 'Dob as ( DD/MM/ YYYY )', maxLines: 2),
        gField(c: adhaarIdC, label: 'Adhaar Number'),
        gField(c: vidC, label: 'VID (Virtual ID)'),
        const SizedBox(height: 40),
      ],
    );
  }

  bool full = true;



  Uint8List? mypic;
  Widget _buildImageContainer(XFile? imageFile, double w, {bool square = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0, bottom: 15),
      child: Container(
        width: square ? w / 4 : w / 3,
        height: square ? w / 4 : (w / 3) * 9 / 16,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey.shade400),
          image: imageFile == null
              ? null : DecorationImage(
            image: FileImage(File(imageFile.path)),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
  Future<String> uploadpic(XFile file)async{
    try {
      final File imageFile = File(file.path);
      final String fileName = 'public/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      return "";
    }catch(e){
      return e.toString();
    }
  }


}
