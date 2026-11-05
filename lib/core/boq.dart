import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class BoqItem {
  final String module, description, unit;
  double qty, rate;
  BoqItem(this.module, this.description, this.unit, this.qty, this.rate);
  double get amount => qty * rate;
}

/// App-wide Bill of Quantities. Any module calls Boq.I.add([...]).
class Boq extends ChangeNotifier {
  Boq._();
  static final Boq I = Boq._();
  final List<BoqItem> items = [];
  void add(Iterable<BoqItem> x) { items.addAll(x); notifyListeners(); }
  void removeAt(int i) { items.removeAt(i); notifyListeners(); }
  void clear() { items.clear(); notifyListeners(); }
  double get total => items.fold(0, (s, e) => s + e.amount);

  Future<Uint8List> buildPdf(String project) async {
    final doc = pw.Document();
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      header: (_) => pw.Text('Bill of Quantities - $project',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
      build: (_) => [
        pw.SizedBox(height: 12),
        pw.TableHelper.fromTextArray(
          headers: ['#', 'Module', 'Description', 'Unit', 'Qty', 'Rate', 'Amount'],
          data: [
            for (var i = 0; i < items.length; i++)
              ['${i + 1}', items[i].module, items[i].description, items[i].unit,
               items[i].qty.toStringAsFixed(2), items[i].rate.toStringAsFixed(2),
               items[i].amount.toStringAsFixed(0)],
          ],
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellAlignments: {4: pw.Alignment.centerRight, 5: pw.Alignment.centerRight, 6: pw.Alignment.centerRight},
        ),
        pw.SizedBox(height: 10),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('Grand Total: Rs ${total.toStringAsFixed(0)}',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        ),
      ],
    ));
    return doc.save();
  }

  Future<void> sharePdf(String project) async =>
      Printing.sharePdf(bytes: await buildPdf(project), filename: 'BOQ.pdf');
}
