import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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

    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  // ================= PRINT =================
  Future<void> printA4() async {
    final bytes = await captureWidget();
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Center(
          child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain),
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width - 20;
    final double h = w * a4Ratio;

    // duplicate images
    final List<Uint8List> images = List.generate(copies, (_) => widget.image);

    int crossAxisCount = 2; // fixed 2 grids
    int rows = (images.length / 2).ceil();

    return Scaffold(
      appBar: AppBar(title: const Text('A4 Grid Image Print')),

      // ================= FOOTER SLIDER =================
      persistentFooterButtons: [
        Column(
          children: [
            Text('Copies: $copies (Even only)'),
            Slider(
              value: copies.toDouble(),
              min: 2,
              max: 12,
              divisions: 5,
              label: copies.toString(),
              onChanged: (v) {
                int val = v.round();
                if (val % 2 != 0) val++; // force even
                setState(() => copies = val);
              },
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.print),
                label: const Text('PRINT'),
                onPressed: printA4,
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
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: (w / 2) / (h / rows),
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                    ),
                    child: Image.memory(
                      images[index],
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
