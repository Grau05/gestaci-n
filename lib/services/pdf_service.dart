import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:gestantes/models/animal.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<void> generateAnimalReport(Animal animal, List<Note> notes) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Reporte Animal: ${animal.idVisible}',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          
          // Info basica
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Informacion Basica', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      pw.Text('ID: ${animal.idVisible}'),
                      pw.Text('Nombre: ${animal.nombre ?? 'N/A'}'),
                      pw.Text('Raza: ${animal.raza}'),
                    ]),
                    pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      pw.Text('Estado: ${animal.estado}'),
                      pw.Text('Meses: ${animal.mesesEmbarazo}'),
                      pw.Text('Finca: ${animal.idFinca}'),
                    ]),
                  ],
                ),
              ],
            ),
          ),
          
          pw.SizedBox(height: 20),
          
          // Fechas
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Fechas Importantes', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                pw.SizedBox(height: 8),
                pw.Text('Registro: ${DateFormat('dd/MM/yyyy').format(animal.fechaRegistro)}'),
                if (animal.fechaMonta != null)
                  pw.Text('Monta: ${DateFormat('dd/MM/yyyy').format(animal.fechaMonta!)}'),
                if (animal.fechaUltimoPalpado != null)
                  pw.Text('Ultimo Palpado: ${DateFormat('dd/MM/yyyy').format(animal.fechaUltimoPalpado!)}'),
              ],
            ),
          ),
          
          if (animal.etiquetas.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Etiquetas', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                  pw.SizedBox(height: 8),
                  pw.Text(animal.etiquetas.join(', ')),
                ],
              ),
            ),
          ],
          
          if (notes.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            pw.Text('Historial de Notas', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
            pw.SizedBox(height: 8),
            pw.Column(
              children: notes.map((note) => pw.Container(
                padding: const pw.EdgeInsets.all(8),
                margin: const pw.EdgeInsets.only(bottom: 8),
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('${note.tipo} - ${DateFormat('dd/MM/yyyy HH:mm').format(note.fecha)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text(note.contenido),
                  ],
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }
}
