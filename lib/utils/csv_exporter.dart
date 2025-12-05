import 'package:csv/csv.dart';
import 'package:gestantes/models/animal.dart';
import 'package:intl/intl.dart';

class CsvExporter {
  static String exportToCSV(List<Animal> animals) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    
    final List<List<String>> rows = [];
    
    // Header
    rows.add(['ID Visible', 'Nombre', 'Raza', 'Meses Embarazo', 'Último Palpado']);
    
    // Data
    for (var animal in animals) {
      rows.add([
        animal.idVisible,
        animal.nombre ?? '',
        animal.raza,
        animal.mesesEmbarazo.toString(),
        animal.fechaUltimoPalpado != null 
            ? dateFormat.format(animal.fechaUltimoPalpado!) 
            : '',
      ]);
    }
    
    return const ListToCsvConverter().convert(rows);
  }
}
