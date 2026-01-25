import 'dart:io';
import 'dart:typed_data';

import 'package:adhaar/card/adhaar/card.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../model/adhaar_model.dart';


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
  final qrIdC = TextEditingController();

  AdhaarModel? savedModel;

  pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: source);

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
    qrIdC.dispose();
    fatherC.dispose();
    hNameC.dispose();
    hFatherC.dispose();
    addressC.dispose();
    hAddressC.dispose();
    issuedC.dispose();
    detailsC.dispose();
    genderC.dispose();
    super.dispose();
  }

  bool done = false;
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('Adhaar Form'),actions: [
      ],),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              InkWell(
                onTap: () async {
                  await pickImage(ImageSource.gallery);
                },
                child: Container(
                  width: w / 4,
                  height: w / 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
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
              gField(c: nameC, label: 'Name'),
              gField(c: fatherC, label: 'Father Name'),
              gField(c: hNameC, label: 'Hindi Name'),
              gField(c: hFatherC, label: 'Hindi Father Name'),
              gField(c: addressC, label: 'Address', maxLines: 2),
              gField(c: hAddressC, label: 'Hindi Address', maxLines: 2),
              gField(c: issuedC, label: 'Adhaar Issued Date ( DD/MM/YYY)'),
              gField(c: detailsC, label: 'Dob as ( DD/MM/ YYYY )', maxLines: 2),
              gField(c: genderC, label: 'Gender ( to be pinted )'),
              gField(c: adhaarIdC, label: 'Adhaar Number'),
              gField(c: vidC, label: 'VID (Virtual ID)'),
              gField(c: qrIdC, label: "Optional ( Just write anything )"),
              const SizedBox(height: 20),
              if (savedModel != null) ...[
                const SizedBox(height: 20),
                const Divider(),
                Text("Saved Data Preview", style: Theme.of(context).textTheme.titleMedium),
                Text(savedModel!.toJson().toString()),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      persistentFooterButtons: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: (){
              if(mypic==null){
                return ;
              }
                if (!formKey.currentState!.validate()) return;
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
                  qrId: qrIdC.text.trim(),
                  photo: mypic,
                );

                setState(() => savedModel = model);

                Navigator.push(context, MaterialPageRoute(builder: (_)=>A4PrintPage(model: model)));
                debugPrint("SAVED ADHAADEL => ${model.toJson()}");

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Adhaar  Saved")),
                );

            },
            child: const Text('SAVE'),
          ),
        ),
      ],
    );
  }
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
