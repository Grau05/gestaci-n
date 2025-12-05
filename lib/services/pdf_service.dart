import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:gestantes/models/animal.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<void> generateAnimalReport(Animal animal) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Reporte de Vaca ${animal.idVisible}',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildInfoRow('ID Visible', animal.idVisible),
                _buildInfoRow('Nombre', animal.nombre ?? 'N/A'),
                _buildInfoRow('Raza', animal.raza),
                _buildInfoRow('Estado', animal.estado),
                _buildInfoRow('Meses de Gestación', '${animal.mesesEmbarazo} meses'),
                _buildInfoRow(
                  'Fecha Monta',
                  animal.fechaMonta != null
                      ? DateFormat('dd/MM/yyyy').format(animal.fechaMonta!)
                      : 'N/A',
                ),
                _buildInfoRow(
                  'Último Palpado',
                  animal.fechaUltimoPalpado != null
                      ? DateFormat('dd/MM/yyyy').format(animal.fechaUltimoPalpado!)
                      : 'N/A',
                ),
                if (animal.etiquetas.isNotEmpty)
                  _buildInfoRow('Etiquetas', animal.etiquetas.join(', ')),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Generado: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }

  static Future<void> generateGeneralReport(List<Animal> animals) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Reporte General de Animales',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Total de animales: ${animals.length}'),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: ['ID', 'Nombre', 'Raza', 'Estado', 'Meses', 'Último Palpado'],
            data: animals
                .map((a) => [
              a.idVisible,
              a.nombre ?? '-',
              a.raza,
              a.estado,
              '${a.mesesEmbarazo}',
              a.fechaUltimoPalpado != null
                  ? DateFormat('dd/MM/yyyy').format(a.fechaUltimoPalpado!)
                  : '-',
            ])
                .toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Generado: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }

  static pw.Row _buildInfoRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
        ),
        pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
      ],
    );
  }
}
