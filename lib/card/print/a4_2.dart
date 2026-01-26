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

    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
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
            child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain),
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
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
  Future<void> shareA4Pdf() async {
    final bytes = await captureWidget();
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Center(
            child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain),
          );
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/pdf_${DateTime.now().millisecondsSinceEpoch}.pdf');

    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Generated PDF',
    );
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width - 20;
    final double h = w * a4Ratio; // auto A4 height

    double x(double v) => w * v; // width based
    double y(double v) => h * v; // height based

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
