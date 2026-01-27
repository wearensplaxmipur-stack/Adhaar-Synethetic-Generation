import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../model/adhaar_model.dart';
import 'package:qr_flutter/qr_flutter.dart';




// ================= A4 CONSTANTS =================
const double a4Ratio = 297 / 210; // height / width

class A4PrintPage extends StatefulWidget {
  final AdhaarModel model;
  const A4PrintPage({super.key, required this.model});

  @override
  State<A4PrintPage> createState() => _A4PrintPageState();
}

class _A4PrintPageState extends State<A4PrintPage> {
  final GlobalKey repaintKey = GlobalKey();

  Future<Uint8List> captureWidget() async {
    RenderRepaintBoundary boundary =
    repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    ui.Image image = await boundary.toImage(pixelRatio: 6.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> printA4() async {
    final bytes = await captureWidget();
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Center(
            child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain,dpi: 600),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }
  Future<void> shareA4Pdf() async {
    final bytes = await captureWidget();
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Center(
            child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain,dpi: 600),
          );
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/adhaar_${DateTime.now().millisecondsSinceEpoch}.pdf');

    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Generated Aadhaar PDF',
    );
  }

// ================= MODEL =================
// ================= GLOBAL TEXT FUNCTION =================
  Widget pText({
    required String text,
    required double top,
    required double left,
    double? right,
    double size = 4.5,
    FontWeight fw = FontWeight.w400,
    Color color = Colors.black,
    int? maxLines,
    String? fontFamily,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: Text(
        text, overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: size, fontWeight: fw, color: color,
          fontFamily: fontFamily,),
      ),
    );
  }

  //For English Text
  Widget epText({
    required String text,
    required double top,
    required double left,
    double? right,
    double size = 4.5,
    FontWeight fw = FontWeight.w400,
    Color color = Colors.black,
    int? maxLines,
    String? fontFamily,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: Text(
        text, overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: size, fontWeight: fw, color: color,
          height: 0.9,
          fontFamily: fontFamily,),
      ),
    );
  }

  Widget denseQR(String data, double size) {
    return QrImageView(
      data: data,
      version: QrVersions.auto, // auto-select highest needed version
      size: size,
      gapless: true,            // no spacing between modules
      errorCorrectionLevel: QrErrorCorrectLevel.H, // HIGH density
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
      ),
    );
  }
  String qrData(AdhaarModel model) {
    return [
      "AADHAAR:${model.adhaarId}",
      "VID:${model.vid}",
      "NAME:${model.name}",
      "FATHER:${model.fatherName}",
      "DOB:1999",
      "GENDER:${model.gender}",
      "ADDRESS:${model.address}",
      "ISSUED:${model.adhaarIssued}",
      "QRID:${model.qrId}",
      "SIGN:INDIA-GOV-AUTH-SECURE-VERIFIED",
      "HASH:${DateTime.now().millisecondsSinceEpoch}",
    ].join("|");
  }

  String breakEvery4(String input) {
    final buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      if (i != 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(input[i]);
    }
    return buffer.toString();
  }


  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width - 20;
    final double h = w * a4Ratio; // auto A4 height

    double x(double v) => w * v; // width based
    double y(double v) => h * v; // height based

    final m = widget.model;

    return Scaffold(
      appBar: AppBar(title: const Text('A4 Stack PDF Generator')),
      persistentFooterButtons: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              onTap: printA4,
              child: Container(
                width: w/2-10,
                height: 50,
                color: Colors.red,
                child: Row(
                  mainAxisAlignment:MainAxisAlignment.center,
                  children: [
                    Icon(Icons.print,color: Colors.white,),
                    SizedBox(width: 10,),
                    Text("Print Pdf",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w900),)
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: shareA4Pdf,
              child: Container(
                width: w/2-10,
                height: 50,
                color: Colors.blue.shade800,
                child: Row(
                  mainAxisAlignment:MainAxisAlignment.center,
                  children: [
                    Icon(Icons.share,color: Colors.white,),
                    SizedBox(width: 10,),
                    Text("Share Pdf",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w900),)
                  ],
                ),
              ),
            ),
          ],
        )
      ],
      body: SingleChildScrollView(
        child: Center(
          child: RepaintBoundary(
            key: repaintKey,
            child: Container(
              width: w,
              height: h,
              color: Colors.white,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset("assets/Atif Aadhar (1) (1)_page_1.jpg",width: w,),
                  ),
                  Positioned(
                    left: w*0.06,top: w*0.085,
                    child: Container(
                      width: w*0.0965,
                      height: w*0.115,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: MemoryImage(widget.model.photo!),
                          fit: BoxFit.cover
                        )
                      ),
                    ),
                  ),
                  Positioned(
                    left: x(0.03),
                    top: y(0.06),
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        "Issued Date : ${m.adhaarIssued}",
                        style: TextStyle(
                          fontSize: 4.8,
                          fontFamily: 'NotoSerif',letterSpacing: 0.1
                        ),
                      ),
                    ),
                  ),
                  pText(text: "${m.hindiName}", top: y(0.06), left: x(0.173),fontFamily: "NotoSansDevanagari"),
                  pText(text: '${m.name}', top: y(0.067), left: x(0.173),fontFamily: "LiberationSerif"),
                  pText(text: m.details, top: y(0.078), left: x(0.253),fontFamily: "NotoSerifTamil"),

                  pText(text: m.gender, top: y(0.088), left: x(0.173),fontFamily: "LiberationSerif"),

                  epText(text: '${m.address}', top: y(0.112), left: x(0.53),fontFamily: "LiberationSerif",size: 4.8),
                  epText(text: '${m.hindiAddress}', top: y(0.072), left: x(0.53),fontFamily: "NotoSansDevanagari",size: 4.8),
                  pText(text: breakEvery4(m.adhaarId), top: y(0.189), left: x(0.173),fw: FontWeight.w900,size: 7.5,fontFamily: "NotoSerif"),
                  Positioned(
                    left: x(0.78),top: y(0.0552),
                    child: Container(
                        width: w*0.18,
                        height: w*0.18,
                        color: Colors.white,
                        child: Container(
                            width: w*0.18,
                            height: w*0.18,
                            child: QrImageView(size: w*0.18, data: qrData(m),
                              errorCorrectionLevel: QrErrorCorrectLevel.Q, // denser than H in many cases
                            ))
                    ),
                  ),
                  pText(text: breakEvery4(m.adhaarId), top: y(0.178), left: x(0.66),fw: FontWeight.w900,size: 7.5,fontFamily: "NotoSerif"),
                  pText(text:"VID : "+ breakEvery4(m.vid), top: y(0.193), left: x(0.62),fw: FontWeight.w400,size: 6.5,fontFamily: "NotoSerif"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
class AadhaarQRWidget extends StatelessWidget {
  final String data;
  final double size;

  const AadhaarQRWidget({
    super.key,
    required this.data,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: Colors.white,
      child: QrImageView(
        data: data,
        version: QrVersions.auto,
        size: size,
        gapless: true,
        errorCorrectionLevel: QrErrorCorrectLevel.H,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
        ),
      ),
    );
  }
}
