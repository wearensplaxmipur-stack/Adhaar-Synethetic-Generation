import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:adhaar/utils/helper.dart';
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
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;
import 'package:printing/printing.dart';

import 'package:flutter/services.dart' show rootBundle;

const double a4Ratio = 297 / 210; // height / flutterfire configure --project=aadhaar-nsp-2026
class HindiRenderResult {
  final pw.MemoryImage image;
  final double pixelWidth;
  final double pixelHeight;

  HindiRenderResult(this.image, this.pixelWidth, this.pixelHeight);
}

class A4PrintPage extends StatefulWidget {
  final AdhaarModel model; final String addressso;final bool gender;
  const A4PrintPage({super.key, required this.model,this.addressso="C/O",required this.gender});

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


  Future<pw.Widget> hindiImageWidget(
      String text,
      double pdfFontSize,
      double pdfLeft,
      double pdfTop,
      double pageWidth,
      double pageHeight,
      ) async {
    const double dpi = 1200;
    const double pxToPdf = 72 / dpi;

    final result = await renderHindiToImage(text, pdfFontSize);

    final pdfWidth = result.pixelWidth * pxToPdf;
    final pdfHeight = result.pixelHeight * pxToPdf;

    double x(double v) => pageWidth * v;
    double y(double v) => pageHeight * v;

    return pw.Positioned(
      left: x(pdfLeft),
      top: y(pdfTop),
      child: pw.Image(
        result.image,
        width: pdfWidth,
        height: pdfHeight,
      ),
    );
  }
  Future<pw.Widget> hindiImageWidget2(
      String text,
      double pdfFontSize,
      double pdfLeft,
      double pdfTop,
      double pageWidth,
      double pageHeight,
      ) async {
    const double dpi = 1200;
    const double pxToPdf = 72 / dpi;

    final result = await renderHindiToImage(text, pdfFontSize);

    final pdfWidth = result.pixelWidth * pxToPdf;
    final pdfHeight = result.pixelHeight * pxToPdf;

    double x(double v) => pageWidth * v;
    double y(double v) => pageHeight * v;

    return pw.Positioned(
      left: x(pdfLeft),
      top: y(pdfTop),
      child: pw.Image(
        result.image,
        width: pdfWidth,
        height: pdfHeight,
      ),
    );
  }

  Future<HindiRenderResult> renderHindiToImage(
      String text,
      double pdfFontSize,
      ) async {
    const double dpi = 1200;
    const double pdfToPx = dpi / 72;

    final pixelFontSize = (pdfFontSize * pdfToPx);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.notoSansDevanagari(
          fontSize: pixelFontSize,
          color: Colors.black,
          height: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Better padding for Devanagari
    final topPadding = pixelFontSize * 0.25;
    final bottomPadding = pixelFontSize * 0.25;

    final width = textPainter.width.ceilToDouble();
    final height =
    (textPainter.height + topPadding + bottomPadding).ceilToDouble();

    // White background
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      bgPaint,
    );

    // Paint text
    textPainter.paint(canvas, Offset(0, topPadding));

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



  String breakTextByWords(String text, {int maxChars = 60}) {
    List<String> words = text.split(' ');
    StringBuffer buffer = StringBuffer();
    String currentLine = '';

    for (var word in words) {
      if ((currentLine + word).length > maxChars) {
        buffer.writeln(currentLine.trim());
        currentLine = '';
      }
      currentLine += '$word ';
    }

    if (currentLine.isNotEmpty) {
      buffer.writeln(currentLine.trim());
    }

    return buffer.toString().trim();
  }

  Future<HindiRenderResult> renderHindiAddressToImage(
      String text,
      double pdfFontSize,
      ) async {
    const double dpi = 1200;
    const double pdfToPx = dpi / 72;

    final pixelFontSize = (pdfFontSize * pdfToPx);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.notoSansDevanagari(
          fontSize: pixelFontSize,
          color: Colors.black,
          height: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final smallTopPadding = pixelFontSize * 0.18; // very small padding

    final width = textPainter.width.ceilToDouble();
    final height =
    (textPainter.height + smallTopPadding).ceilToDouble();

    textPainter.paint(canvas, Offset(0, smallTopPadding));


    // NO background
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
  Future<pw.Widget> hindiAddressImageWidget(
      String text,
      double pdfFontSize,
      double pdfLeft,
      double pdfTop,
      double pageWidth,
      double pageHeight,
      ) async {
    const double dpi = 1200;
    const double pxToPdf = 72 / dpi;

    final result = await renderHindiAddressToImage(text, pdfFontSize);

    final pdfWidth = result.pixelWidth * pxToPdf;
    final pdfHeight = result.pixelHeight * pxToPdf;

    double x(double v) => pageWidth * v;
    double y(double v) => pageHeight * v;

    return pw.Positioned(
      left: x(pdfLeft),
      top: y(pdfTop),
      child: pw.Image(
        result.image,
        width: pdfWidth,
        height: pdfHeight,
      ),
    );
  }


  Future<void> generateTrueAadhaarPdf(bool share) async {
    changep(true);
    final pageFormat = PdfPageFormat.a4 ;
    final double w = pageFormat.width ;
    final double h = pageFormat.height ;

    double x(double v) => w * v;
    double y(double v) => h * v;
    const double dpi = 1200;
    const double pxToPdf = 72 / dpi;
    final pdfFontSize = w * 0.0105;
    final hindiNameResult = await renderHindiToImage(widget.model.hindiName, pdfFontSize);
    final hindiAddressWidget = await hindiAddressImageWidget(
      "       " + breakTextByWords(widget.model.hindiAddress),
      w * 0.010,
      0.432,
      0.668,
      w,
      h,
    );


    final pdfImageWidth = hindiNameResult.pixelWidth * pxToPdf;
    final pdfImageHeight = hindiNameResult.pixelHeight * pxToPdf;


    final hindiGenderWidget = await hindiImageWidget(
      widget.model.gender.substring(0, 5),
      w * 0.011,
      0.137,
      0.6946,
      w,
      h,
    );
    // LEFT                    TOP
    final gender = await hindiImageWidget(
      "जन्म तिथि",
      w * 0.011,
      0.137,
      0.685,
      w,
      h,
    );


    final hindiFont = pw.Font.ttf(
      await rootBundle.load(
        'assets/fonts/NotoSansDevanagari-Regular.ttf',
      ),
    );

    final tamilFont = pw.Font.ttf(
      await rootBundle.load(
        'assets/fonts/NotoSerifTamil-VariableFont_wdth,wght.ttf',
      ),
    );

    final engFont = pw.Font.ttf(
      await rootBundle.load(
        'assets/fonts/LiberationSans-Regular.ttf',
      ),
    );

    final notoBold = pw.Font.ttf(
      await rootBundle.load(
        'assets/fonts/liberation-sans.bold.ttf',
      ),
    );
    final notoRegular = pw.Font.ttf(
      await rootBundle.load(
        'assets/fonts/LiberationSans-Regular.ttf',
      ),
    );

    final bgBytes = (await rootBundle.load(
      'assets/adhaar.jpg',
    ))
        .buffer
        .asUint8List();
    final photoImage = pw.MemoryImage(widget.model.photo!);

    final bgImage = pw.MemoryImage(bgBytes);
    final qrDataString = qrData(widget.model);

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: hindiFont,
        bold: notoBold,
        italic: hindiFont,
        boldItalic: notoBold,
      ),
    );


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
              pw.Positioned(
                left: x(0.137),
                top: y(0.664),
                child: pw.Image( hindiNameResult.image,
                  width: pdfImageWidth*1.05,
                  height: pdfImageHeight*1.05,
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
              gender,

              // DOB ------------------------------------------------>
              pw.Positioned(
                left: x(0.1773),
                top: y(0.6869),
                child: pw.Container(
                  color: PdfColors.white,
                  padding: pw.EdgeInsets.only(left: 1,right: 2),
                  child: pw.Text(
                    "/DOB:",
                    style: pw.TextStyle(
                      font: engFont,
                      fontSize: w * 0.010,
                    ),
                  ),
                ),
              ),
              pw.Positioned(
                left: x(0.207),
                top: y(0.6869),
                child: pw.Text(
                  widget.model.adhaarIssued,
                  style: pw.TextStyle(
                    font: notoRegular,
                    fontSize: w*0.01,
                  ),
                ),
              ),
              hindiGenderWidget,
              !(widget.gender)?pw.Positioned(
                left: x(0.165),
                top: y(0.696),
                child: pw.Text(
                  "/ FEMALE",
                  style: pw.TextStyle(
                    font: engFont,
                    fontSize: w*0.011,
                  ),
                ),
              ):pw.Positioned(
                left: x(0.157),
                top: y(0.696),
                child: pw.Text(
                  "/ MALE",
                  style: pw.TextStyle(
                    font: engFont,
                    fontSize: w*0.011,
                  ),
                ),
              ),
              //GENDER -------------------------------------->
              /*pw.Positioned(
                left: x(0.137),
                top: y(0.695),
                child: pw.RichText(
                  text: pw.TextSpan(
                    children: buildHindiSpans(
                      fixHindiLigatures(widget.model.gender.substring(0,5)),
                      hindiFont,
                      w * 0.011,
                    ),

                  ),
                ),
              ),*/


              //Addresss--------------------------------------->
              // English prefix
              pw.Positioned(
                left: x(0.4289),
                top: y(0.6692),
                child: pw.Container(
                  color: PdfColors.white,
                  width: w/6,
                  height: 10
                ),
              ),
              hindiAddressWidget,
              pw.Positioned(
                left: x(0.4289),
                top: y(0.6692),
                child: pw.Container(
                  padding: const pw.EdgeInsets.only(left: 1),
                  child: pw.Text(
                    widget.addressso + ":",
                    style: pw.TextStyle(
                      font: engFont,
                      fontSize: w * 0.009,
                    ),
                  ),
                ),
              ),
              // Hindi address image

              pw.Positioned(
                left: x(0.4289),
                top:  y(0.7025),
                child: pw.Container(
                  color: PdfColors.white,
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 1,
                  ),
                  child: pw.Text(
                    widget.addressso+": "+breakTextByWords(widget.model.address,maxChars: 45),
                    style: pw.TextStyle(
                      font: engFont,
                      fontSize: w*0.01,
                    ),
                  ),
                )
              ),

              // VID & ADHAAR ID FRONT
              pw.Positioned(
                left: x(0.127),
                top:y(0.773),
                child: pw.Text(
                  breakEvery4(widget.model.adhaarId),
                  style: pw.TextStyle(
                    font: notoBold,
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
                    font: notoBold,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: w*0.018,
                  ),
                ),
              ),
              pw.Positioned(
                left: x(0.52),
                top: y(0.7779),
                child: pw.Row(
                  children: List.generate(
                    253,
                        (index) => pw.Container(
                      width: 0.2,
                      height: 0.2,
                      margin: const pw.EdgeInsets.only(right: 0.2),
                      //color: PdfColors.black
                      color: PdfColors.grey500,
                    ),
                  ),
                ),
              ),
              pw.Positioned(
                left: x(0.538),
                top:y(0.778),
                child: pw.Text(
                  widget.model.vid.isEmpty?"":("VID : "+breakEvery4(widget.model.vid)),
                  style: pw.TextStyle(
                    font: notoBold,
                    fontSize: w*0.011,
                  ),
                ),
              ),

              //Roated for LEFT FRONT
              pw.Positioned(
                left: x(0.0069),
                top: y(0.673),
                child: pw.Transform.rotate(
                  angle: 3.1416 / 2,
                  child: pw.Text(
                    widget.model.details,
                    style: pw.TextStyle(
                      fontSize:w*0.008 ,
                      font: notoBold,
                    ),
                  ),
                ),
              ),

            ],
          );
        },
      ),
    );

    if(share){
      final bytes = await pdf.save();
      await savePdf(bytes, "aadhaar.pdf");
      changep(false);

    }else{
      await Printing.layoutPdf(
        onLayout: (_) async => pdf.save(),
      );
      changep(false);
    }

  }


  void changep(bool s){
    setState(() {
      progress=s;
    });
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
      appBar: AppBar(title: const Text('DEMO ADHAAR ')),
      persistentFooterButtons: [
        progress?Center(child: CircularProgressIndicator()): Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              onTap: (){
                generateTrueAadhaarPdf(false);
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
                generateTrueAadhaarPdf(true);
              },
              child:kIsWeb?Container(
                width: w/2-10,
                height: 50,
                color: Colors.blue.shade800,
                child: Row(
                  mainAxisAlignment:MainAxisAlignment.center,
                  children: [
                    Icon(Icons.download,color: Colors.white,),
                    SizedBox(width: 10,),
                    Text("Download Pdf",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w900),)
                  ],
                ),
              ): Container(
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

                  epText(text: '${breakTextByWords(m.address)}', top: y(0.701), left: x(0.53),fontFamily: "LiberationSerif",size: 3.8),
                  epText(text: '${breakTextByWords(m.hindiAddress)}', top: y(0.735), left: x(0.53),fontFamily: "NotoSansDevanagari",size: 3.8),
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
