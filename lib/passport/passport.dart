import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart' show getTemporaryDirectory;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../utils/helper.dart';

const double a4Ratio = 297 / 210; // height / width

class A4GridPrintPassport extends StatefulWidget {
  final Uint8List image; // single image input

  const A4GridPrintPassport({super.key, required this.image});

  @override
  State<A4GridPrintPassport> createState() => _A4GridPrintPageState();
}

class _A4GridPrintPageState extends State<A4GridPrintPassport> {
  final GlobalKey repaintKey = GlobalKey();

  int copies = 2; // must be even

  // ================= CAPTURE =================
  Future<Uint8List> captureWidget() async {
    RenderRepaintBoundary boundary =
    repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    ui.Image image = await boundary.toImage(pixelRatio: 6.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  // ================= PRINT =================
  Future<void> printA4() async {
    changep(true);
    final bytes = await captureWidget();
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) =>
            pw.Center(
              child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain,dpi: 300),
            ),
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
    changep(false);

  }
  final double photoWidthPt  = (3.5 / 2.54) * 72;  // ≈ 99.21 pt
  final double photoHeightPt = (4.5 / 2.54) * 72;  // ≈ 127.56 pt

  Future<void> shareA4Pdf() async {
    changep(true);

    final bytes = await captureWidget();
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Center(
          child: pw.Image(
            pw.MemoryImage(bytes),
            fit: pw.BoxFit.contain,
            dpi: 300,
          ),
        ),
      ),
    );

    final pdfBytes = await pdf.save();
    await savePdf(pdfBytes, "passport_photos.pdf");
    changep(false);
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
    final double h = w * a4Ratio;

    final List<Uint8List> images = List.generate(copies, (_) => widget.image);

    int crossAxisCount = 2; // fixed 2 grids
    int rows = (images.length / 2).ceil();

    return Scaffold(
      appBar: AppBar(title: const Text('A4 Grid Image Print')),

      persistentFooterButtons: [
        progress?Center(child: CircularProgressIndicator(),):Column(
          children: [
            Text('Copies: $copies (Even only)'),
            Slider(
              value: copies.toDouble(),
              min: 2,
              max: 25,
              divisions: 5,
              label: copies.toString(),
              onChanged: (v) {
                int val = v.round();
                if (val % 2 != 0) val++; // force even
                setState(() => copies = val);
              },
            ),
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
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(images.length, (index) {
                  return Container(
                    width: photoWidthPt * (w / PdfPageFormat.a4.width),   // scale to screen
                    height: photoHeightPt * (h / PdfPageFormat.a4.height),// scale to screen
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Image.memory(
                      images[index],
                      fit: BoxFit.cover,
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
