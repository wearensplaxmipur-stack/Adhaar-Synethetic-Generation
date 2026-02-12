import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../model/adhaar_model.dart';
import 'package:qr_flutter/qr_flutter.dart';


import 'package:flutter/services.dart' show rootBundle;


const double a4Ratio = 297 / 210; // height / flutterfire configure --project=aadhaar-nsp-2026
class HindiRenderResult {
  final pw.MemoryImage image;
  final double pixelWidth;
  final double pixelHeight;

  HindiRenderResult(this.image, this.pixelWidth, this.pixelHeight);
}

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

    ui.Image image = await boundary.toImage(pixelRatio: 7.5);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
  void chan(bool yu){
    setState(() {
      progress = yu;
    });
  }

  Future<void> printA4() async {
    try {
      chan(true);
      final bytes = await captureWidget();
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.letter,
          build: (context) {
            return pw.Center(
              child: pw.Image(
                  pw.MemoryImage(bytes), fit: pw.BoxFit.contain, dpi: 700,),
            );
          },
        ),
      );

      await Printing.layoutPdf(onLayout: (_) async => pdf.save());
      chan(false);

    }catch(e){
      chan(false);
    }
  }
  Future<void> shareA4Pdf() async {
    try {
      chan(true);

      final bytes = await captureWidget();
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Center(
              child: pw.Image(
                  pw.MemoryImage(bytes), fit: pw.BoxFit.contain, dpi: 600),
            );
          },
        ),
      );

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/adhaar_${DateTime
          .now()
          .millisecondsSinceEpoch}.pdf');

      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Generated Aadhaar PDF',
      );
      chan(false);

    }catch(e){
      chan(false);
    }
  }


  Future<HindiRenderResult> renderHindiToImage(
      String text,
      double pdfFontSize,
      ) async {

    const double dpi = 720; // ULTRA sharp (desktop only)
    const double pdfToPx = dpi / 72;

    final pixelFontSize = pdfFontSize * pdfToPx;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.notoSansDevanagari(
          fontSize: pixelFontSize,
          color: Colors.black,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final extraPadding = pixelFontSize * 0.35;

    final width = textPainter.width.ceilToDouble();
    final height =
    (textPainter.height + extraPadding).ceilToDouble();

    textPainter.paint(canvas, Offset(0, extraPadding / 2));

    final picture = recorder.endRecording();

    final img = await picture.toImage(
      width.toInt(),
      height.toInt(),
    );

    final byteData =
    await img.toByteData(format: ui.ImageByteFormat.png);

    return HindiRenderResult(
      pw.MemoryImage(byteData!.buffer.asUint8List()),
      width,
      height,
    );
  }

  List<pw.TextSpan> buildHindiSpans(String text, pw.Font font, double size) {
    final List<pw.TextSpan> spans = [];

    for (int i = 0; i < text.length; i++) {
      String char = text[i];

      // Detect matras
      if (char == 'ि' && i > 0) {
        // छोटी इ matra should appear before previous char
        String prev = text[i - 1];

        spans.removeLast(); // remove previous consonant
        spans.add(pw.TextSpan(
          text: char,
          style: pw.TextStyle(font: font, fontSize: size),
        ));
        spans.add(pw.TextSpan(
          text: prev,
          style: pw.TextStyle(font: font, fontSize: size),
        ));
      } else {
        spans.add(pw.TextSpan(
          text: char,
          style: pw.TextStyle(font: font, fontSize: size),
        ));
      }
    }

    return spans;
  }



  Future<void> generateTrueAadhaarPdf() async {
    final pageFormat = PdfPageFormat.a4 ;
    final double w = pageFormat.width ;
    final double h = pageFormat.height ;

    double x(double v) => w * v;
    double y(double v) => h * v;
    const double dpi = 720;
    const double pxToPdf = 72 / dpi;
    final pdfFontSize = w * 0.010;

    final hindiNameResult = await renderHindiToImage(widget.model.hindiName, pdfFontSize);

    final pdfImageWidth = hindiNameResult.pixelWidth * pxToPdf;
    final pdfImageHeight = hindiNameResult.pixelHeight * pxToPdf;


    final hindiFont = await loadFont(
      'assets/fonts/NotoSansDevanagari-Regular.ttf',
    );
    final tamil = await loadFont(
      'assets/fonts/NotoSerifTamil-VariableFont_wdth,wght.ttf',
    );
    final engFont = await loadFont(
      'assets/fonts/LiberationSans-Regular.ttf',
    );
    final noto = await loadFont(
      'assets/fonts/liberation-sans.bold.ttf',
    );
    final bgBytes = (await rootBundle.load(
      'assets/adhaar.jpg',
    ))
        .buffer
        .asUint8List();
    final photoImage = pw.MemoryImage(widget.model.photo!);

    final bgImage = pw.MemoryImage(bgBytes);
    final qrDataString = qrData(widget.model);

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Stack(
            children: [
              // Background image
              pw.Positioned.fill(
                child: pw.Image(
                  bgImage,
                  fit: pw.BoxFit.cover,
                ),
              ),

              // PHOTO ===============================>
              pw.Positioned(
                left: x(0.0417),
                top: y(0.663),
                child: pw.Container(
                  width: w * 0.083,
                  height: w * 0.10,
                  decoration: pw.BoxDecoration(
                    image: pw.DecorationImage(
                      image: photoImage,
                      fit: pw.BoxFit.cover,
                    ),
                  ),
                ),
              ),
              //QR CODE ---------------------------------------->
              pw.Positioned(
                left: x(0.647),
                top: y(0.658),
                child: pw.Container(
                  width: w * 0.145,
                  height: w * 0.145,
                  color: PdfColors.white,
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(
                      errorCorrectLevel: pw.BarcodeQRCorrectionLevel.low,
                    ),
                    data: qrDataString,
                    width: w * 0.18,
                    height: w * 0.18,
                  ),
                ),
              ),
              /*pw.Positioned(
                left: x(0.137),
                top: y(0.666),
                child: pw.Image(
                  hindiNameResult.image,
                  width: pdfImageWidth,
                  height: pdfImageHeight,
                ),
              ),


              pw.Positioned(
                left: x(0.137),
                top: y(0.665),
                child: pw.Text(
                  widget.model.hindiName,
                  style: pw.TextStyle(
                    font: hindiFont,
                    fontSize: w*0.011,
                  ),
                ),
              ),*/
              pw.Positioned(
                left: x(0.137),
                top: y(0.666),
                child: pw.RichText(
                  text: pw.TextSpan(
                    children: buildHindiSpans(
                      widget.model.hindiName,
                      hindiFont,
                      w * 0.011,
                    ),
                  ),
                ),
              ),


              pw.Positioned(
                left: x(0.137),
                top: y(0.676),
                child: pw.Text(
                  widget.model.name,
                  style: pw.TextStyle(
                    font: engFont,
                    fontSize: w*0.011,
                  ),
                ),
              ),

              // DOB ------------------------------------------------>
              pw.Positioned(
                left: x(0.20),
                top: y(0.6856),
                child: pw.Text(
                  widget.model.adhaarIssued,
                  style: pw.TextStyle(
                    font: tamil,
                    fontSize: w*0.0096,
                  ),
                ),
              ),

              //GENDER -------------------------------------->
              pw.Positioned(
                left: x(0.137),
                top: y(0.695),
                child: pw.Text(
                  "${widget.model.gender.substring(0,5)} / ",
                  style: pw.TextStyle(
                    font: hindiFont,
                    fontSize: w*0.010,
                  ),
                ),
              ),
              pw.Positioned(
                left: x(0.165),
                top: y(0.695),
                child: pw.Text(
                  "MALE",
                  style: pw.TextStyle(
                    font: engFont,
                    fontSize: w*0.011,
                  ),
                ),
              ),

              //Addresss--------------------------------------->

              pw.Positioned(
                left: x(0.431),
                top:y(0.6692),
                child: pw.Text(
                  "         "+widget.model.hindiAddress,
                  style: pw.TextStyle(
                    font: hindiFont,
                    fontSize: w*0.009,
                  ),
                ),
              ),
              pw.Positioned(
                left: x(0.431),
                top:  y(0.7025),
                child: pw.Text(
                  "        "+widget.model.address,
                  style: pw.TextStyle(
                    font: engFont,
                    fontSize: w*0.009,
                  ),
                ),
              ),

              // VID & ADHAAR ID FRONT
              pw.Positioned(
                left: x(0.127),
                top:y(0.773),
                child: pw.Text(
                  breakEvery4(widget.model.adhaarId),
                  style: pw.TextStyle(
                    font: noto,
                    fontSize: w*0.018,
                  ),
                ),
              ),

              //VID & ADHAAR BACK
              pw.Positioned(
                left: x(0.539),
                top:y(0.765),
                child: pw.Text(
                  breakEvery4(widget.model.adhaarId),
                  style: pw.TextStyle(
                    font: noto,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: w*0.018,
                  ),
                ),
              ),
              /*pw.Positioned(
                left: x(0.536),
                top: y(0.7684),
                child: pw.Container(
                  width: w * 0.137,
                  child: pw.Divider(
                    thickness: 0.1,
                    color: PdfColors.black,
                  ),
                ),
              ),*/

              pw.Positioned(
                left: x(0.538),
                top:y(0.778),
                child: pw.Text(
                  "VID : "+breakEvery4(widget.model.vid),
                  style: pw.TextStyle(
                    font: noto,
                    fontSize: w*0.011,
                  ),
                ),
              ),

              //Roated for LEFT FRONT
              pw.Positioned(
                left: x(0.0067),
                top: y(0.674),
                child: pw.Transform.rotate(
                  angle: 3.1416 / 2,
                  child: pw.Text(
                    widget.model.details,
                    style: pw.TextStyle(
                      fontSize:w*0.008 ,
                      font: noto,
                    ),
                  ),
                ),
              ),

            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
    );
  }



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
  Future<pw.Font> loadFont(String path) async {
    final data = await rootBundle.load(path);
    return pw.Font.ttf(data);
  }

  String qrData2(AdhaarModel model) { return [ "AADHAAR:${model.adhaarId}", "VID:${model.vid}", "NAME:${model.name}", "FATHER:${model.fatherName}", "DOB:1999", "GENDER:${model.gender}", "ADDRESS:${model.address}", "ISSUED:${model.adhaarIssued}", "QRID:${model.qrId}", "SIGN:INDIA-GOV-AUTH-SECURE-VERIFIED", "HASH:${DateTime.now().millisecondsSinceEpoch}", ].join("|"); }

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
  String randomHex(int length) {
    const chars = 'abcdef0123456789';
    final rand = Random();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)]).join();
  }

  String randomBase64(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    final rand = Random();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)]).join();
  }
  String qrData(AdhaarModel model) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random();

    return [
      // Core Identity
      "AADHAAR:${model.adhaarId}",
      "VID:${model.vid}",
      "NAME:${model.name}",
      "FATHER:${model.fatherName}",
      "MOTHER:${model.fatherName ?? "N/A"}",
      "DOB:${model.adhaarIssued ?? "1999"}",
      "AGE:${random.nextInt(60) + 18}",
      "GENDER:${model.gender}",
      "ADDRESS:${model.address}",
      "PINCODE:${random.nextInt(899999) + 100000}",
      "STATE:INDIA",
      "COUNTRY:IN",
      "NATIONALITY:INDIAN",

      // Government-like Metadata
      "ISSUED:${model.adhaarIssued}",
      "EXPIRY:NEVER",
      "STATUS:ACTIVE",
      "AUTH_LEVEL:LEVEL-3",
      "VERIFIED:YES",
      "BIOMETRIC:ENABLED",
      "IRIS_HASH:${randomHex(64)}",
      "FINGERPRINT_HASH:${randomHex(64)}",
      "FACE_HASH:${randomHex(64)}",

      // Device & Scan Metadata
      "SCAN_TIME:$timestamp",
      "DEVICE_ID:${randomHex(32)}",
      "TERMINAL_ID:IND-GOV-${random.nextInt(999999)}",
      "LAT:${20 + random.nextDouble()}",
      "LONG:${85 + random.nextDouble()}",
      "ALT:${random.nextInt(500)}",




      "END_OF_RECORD",
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

  Future<void> printA4Web() async {
    chan(true);
    final bytes = await captureWidget();

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Image(
          pw.MemoryImage(bytes),
          fit: pw.BoxFit.contain,
        ),
      ),
    );

    await Printing.layoutPdf(
      format: PdfPageFormat.a4,
      onLayout: (_) async => pdf.save(),
    );

    chan(false);
  }
  Future<void> sharePdfWeb() async {
    chan(true);
    final bytes = await captureWidget();

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Image(
          pw.MemoryImage(bytes),
          fit: pw.BoxFit.contain,
        ),
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'aadhaar.pdf',
    );

    chan(false);
  }
  bool progress = false ;
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
        progress?Center(child: CircularProgressIndicator()): Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(

                onTap: () async {
                  if (kIsWeb) {
                    await printA4Web();
                  } else {
                    await printA4(); // your mobile share_plus code
                  }
              },
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
              onTap: () async {
                if (kIsWeb) {
                  await sharePdfWeb();
                } else {
                  await shareA4Pdf(); // your mobile share_plus code
                }
              },
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
      floatingActionButton: FloatingActionButton(onPressed: generateTrueAadhaarPdf),
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
                    child: Image.asset("assets/adhaar.jpg",width: w,),
                  ),
                  // Photo-===============================
                  Positioned(
                    left: w*0.13,
                    top: w*0.97,
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
                  //Issued date=======================
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
                  Positioned(
                    top: y(0.69),
                    left: x(0.23),
                    child: Text(
                      m.hindiName,
                      style: GoogleFonts.notoSansDevanagari(
                        textStyle: const TextStyle(
                          fontSize: 4,
                          height: 1.2,
                          color: Colors.black,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                  // pText(text: "${m.hindiName}", top: y(0.06), left: x(0.173),fontFamily: "NotoSansDevanagari"),
                  pText(text: '${m.name}', top: y(0.695), left: x(0.23),fontFamily: "LiberationSerif"),

                  // dob
                  pText(text: m.details, top: y(0.707), left: x(0.29),fontFamily: "NotoSerifTamil"),

                  pText(text: m.gender, top: y(0.72), left: x(0.23),fontFamily: "LiberationSerif"),

                  epText(text: '${m.address}', top: y(0.701), left: x(0.53),fontFamily: "LiberationSerif",size: 3.8),
                  epText(text: '${m.hindiAddress}', top: y(0.735), left: x(0.53),fontFamily: "NotoSansDevanagari",size: 3.8),
                  pText(text: breakEvery4(m.adhaarId), top: y(0.795), left: x(0.21),fw: FontWeight.w900,size: 7.5,fontFamily: "NotoSerif"),


                  //qr
               Positioned(
                    left: x(0.745),top: y(0.68),
                    child: Container(
                        width: w*0.15,
                        height: w*0.15,
                        color: Colors.white,
                        child: Container(
                            width: w*0.20,
                            height: w*0.20,
                            child: QrImageView( data: qrData2(m),
                              gapless: true,
                              version: 11,
                              errorCorrectionLevel: QrErrorCorrectLevel.L, // denser than H in many cases
                            ))
                    ),
                  ),

                  pText(text: breakEvery4(m.adhaarId), top: y(0.783), left: x(0.62),fw: FontWeight.w900,size: 7.5,fontFamily: "NotoSerif"),
                  pText(text:"VID : "+ breakEvery4(m.vid), top: y(0.797), left: x(0.61),fw: FontWeight.w400,size: 5,fontFamily: "NotoSerif"),
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
