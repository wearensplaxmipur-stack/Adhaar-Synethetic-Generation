import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../model/adhaar_model.dart';
import '../../utils/helper.dart';



// ================= A4 CONSTANTS =================
const double a4Ratio = 297 / 210; // height / width

class A4PrintPage extends StatefulWidget {
  final bool full;
  const A4PrintPage({super.key,required this.mypic,required this.mypic2 ,required this.full});
  final Uint8List mypic, mypic2;

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


  Widget pText({
    required String text,
    required double top,
    required double left,
    double? right,
    double size = 4.5,
    FontWeight fw = FontWeight.w400,
    Color color = Colors.black,
    int? maxLines,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: Text(
        text, overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: size, fontWeight: fw, color: color),
      ),
    );
  }

  Future<void> generateAndSaveA4(bool share) async {
    changep(true);

    final pdf = pw.Document();

    final img1 = pw.MemoryImage(widget.mypic);
    final img2 = pw.MemoryImage(widget.mypic2);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero, // removes default padding
        build: (context) {
          final pageW = PdfPageFormat.a4.width;
          final pageH = PdfPageFormat.a4.height;

          return pw.Container(
            width: pageW,
            height: pageH,
            color: PdfColors.white,
            child: widget.full
            // SIDE BY SIDE (ROW)
                ? pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Image(
                  img1,
                  width: pageW / 2-15,
                  fit: pw.BoxFit.contain,
                ),
                pw.SizedBox(width: 10),
                pw.Image(
                  img2,
                  width: pageW / 2-15,
                  fit: pw.BoxFit.contain,
                ),
              ],
            )

            // TOP & BOTTOM (COLUMN)
                : pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Image(
                  img1,
                  width: pageW -25,
                  height: pageH / 2-15,
                  fit: pw.BoxFit.contain,
                ),
                pw.SizedBox(height: 10),
                pw.Image(
                  img2,
                  width: pageW -25,
                  height: pageH / 2 - 15,
                  fit: pw.BoxFit.contain,
                ),
              ],
            ),
          );
        },
      ),
    );

    final bytes = await pdf.save();

    if (share) {
      await savePdf(bytes, "a4_output.pdf");
      changep(false);

    } else {
      await Printing.layoutPdf(onLayout: (_) async => bytes);
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

    return Scaffold(
      appBar: AppBar(title: const Text('A4 Stack PDF Generator')),
      persistentFooterButtons: [
        progress?Center(child: CircularProgressIndicator(),):Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              onTap: (){
                generateAndSaveA4(false);
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
              onTap: (){
                generateAndSaveA4(true);
              },
              child: kIsWeb?Container(
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
              ):Container(
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
              child: widget.full?Padding(
                padding: const EdgeInsets.only(top: 28.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.memory(widget.mypic,width: w/2-10,),
                    Image.memory(widget.mypic2,width: w/2-10,),
                  ],
                ),
              ):Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.memory(widget.mypic,width: w-10,),
                  Image.memory(widget.mypic2,width: w-10,),
                  SizedBox(height: 100,)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
