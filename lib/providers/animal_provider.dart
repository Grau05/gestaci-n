import 'package:flutter/foundation.dart';
import 'package:gestantes/models/animal.dart';
import 'package:gestantes/models/note.dart';
import 'package:gestantes/models/farm.dart';
import 'package:gestantes/database/database_helper.dart';

class AnimalProvider extends ChangeNotifier {
  List<Animal> _animals = [];
  List<Animal> _filteredAnimals = [];
  List<Farm> _farms = [];
  int _activeFarmId = 1;

  List<Animal> get animals => _filteredAnimals.isEmpty ? _animals : _filteredAnimals;
  List<Animal> get allAnimals => _animals;
  List<Farm> get farms => _farms;
  int get activeFarmId => _activeFarmId;
  Farm? get activeFarm {
    if (_farms.isEmpty) return null;
    try {
      return _farms.firstWhere((f) => f.id == _activeFarmId);
    } catch (_) {
      return _farms.first;
    }
  }

  AnimalProvider() {
    loadFarmsAndAnimals();
  }

  Future<void> loadFarmsAndAnimals() async {
    await _loadFarms();
    await loadAnimals();
  }

  Future<void> _loadFarms() async {
    try {
      _farms = await DatabaseHelper.instance.getAllFarms();

      if (_farms.isNotEmpty) {
        // Si la finca activa no existe, usar la primera
        if (!_farms.any((f) => f.id == _activeFarmId)) {
          _activeFarmId = _farms.first.id ?? 1;
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error cargando fincas: $e');
    }
  }

  Future<void> setActiveFarm(int farmId) async {
    _activeFarmId = farmId;
    await loadAnimals();
  }

  Future<void> loadAnimals() async {
    try {
      _animals = await DatabaseHelper.instance.getAllAnimalsByFarm(_activeFarmId);
      _filteredAnimals = [];
      notifyListeners();
    } catch (e) {
      debugPrint('Error cargando animales: $e');
    }
  }

  Future<bool> addAnimal(Animal animal) async {
    try {
      final existing = await DatabaseHelper.instance
          .getAnimalByVisibleId(animal.idVisible, 1);
      if (existing != null) {
        return false;
      }
      await DatabaseHelper.instance.insertAnimal(animal);
      await loadAnimals(); // Recargar inmediatamente
      return true;
    } catch (e) {
      debugPrint('Error agregando animal: $e');
      return false;
    }
  }

  Future<bool> updateAnimal(Animal animal) async {
    try {
      final existing = await DatabaseHelper.instance
          .getAnimalByVisibleId(animal.idVisible, 1);
      if (existing != null && existing.idInterno != animal.idInterno) {
        return false;
      }
      await DatabaseHelper.instance.updateAnimal(animal);
      await loadAnimals(); // Recargar inmediatamente
      return true;
    } catch (e) {
      debugPrint('Error actualizando animal: $e');
      return false;
    }
  }

  Future<void> deleteAnimal(int idInterno) async {
    try {
      await DatabaseHelper.instance.deleteAnimal(idInterno);
      await loadAnimals(); // Recargar inmediatamente
    } catch (e) {
      debugPrint('Error eliminando animal: $e');
    }
  }

  Future<void> addNote(Note note) async {
    try {
      await DatabaseHelper.instance.insertNote(note);
      notifyListeners();
    } catch (e) {
      debugPrint('Error agregando nota: $e');
    }
  }

  Future<List<Note>> getNotesByAnimal(int idAnimal) async {
    try {
      return await DatabaseHelper.instance.getNotesByAnimal(idAnimal);
    } catch (e) {
      debugPrint('Error obteniendo notas: $e');
      return [];
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await DatabaseHelper.instance.deleteNote(noteId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error eliminando nota: $e');
    }
  }

  void clearFilters() {
    _filteredAnimals = [];
    notifyListeners();
  }

  void searchByIdVisible(String id) {
    _filteredAnimals = _animals
        .where((a) => a.idVisible.toLowerCase().contains(id.toLowerCase()))
        .toList();
    notifyListeners();
  }

  void applyMultipleFilters({
    String? raza,
    String? estado,
    int? meses,
    String? deliveryPeriod,
  }) {
    Iterable<Animal> result = _animals;

    if (raza != null) {
      result = result.where((a) => a.raza == raza);
    }

    if (estado != null) {
      result = result.where((a) => a.estado == estado);
    }

    if (meses != null) {
      result = result.where((a) => a.mesesEmbarazo == meses);
    }

    if (deliveryPeriod != null) {
      final now = DateTime.now();
      result = result.where((a) {
        if (a.fechaMonta == null) return false;
        final dueDate = a.fechaMonta!.add(const Duration(days: 283));
        final diff = dueDate.difference(now).inDays;

        switch (deliveryPeriod) {
          case 'proximas_2_semanas':
            return diff >= 0 && diff <= 14;
          case 'proximo_mes':
            return diff > 14 && diff <= 30;
          default:
            return true;
        }
      });
    }

    _filteredAnimals = result.toList();
    notifyListeners();
  }

  void filterByRaza(String raza) {
    _filteredAnimals = _animals.where((a) => a.raza == raza).toList();
    notifyListeners();
  }

  void filterByMeses(int meses) {
    _filteredAnimals = _animals.where((a) => a.mesesEmbarazo == meses).toList();
    notifyListeners();
  }

  List<String> getRazas() {
    return _animals.map((a) => a.raza).toSet().toList();
  }

  Map<String, int> getRazaCount() {
    final counts = <String, int>{};
    for (var animal in _animals) {
      counts[animal.raza] = (counts[animal.raza] ?? 0) + 1;
    }
    return counts;
  }

  Map<int, int> getMesesDistribution() {
    final distribution = <int, int>{};
    for (var animal in _animals) {
      distribution[animal.mesesEmbarazo] =
          (distribution[animal.mesesEmbarazo] ?? 0) + 1;
    }
    return distribution;
  }

  int getAverageGestationDays() {
    if (_animals.isEmpty) return 0;
    final total = _animals.fold<int>(0, (sum, a) => sum + a.mesesEmbarazo);
    return total ~/ _animals.length;
  }

  List<Animal> getAnimalsNearDelivery() {
    return _animals
        .where((a) => a.mesesEmbarazo >= 8 && a.mesesEmbarazo <= 9)
        .toList();
  }

  List<Animal> getAnimalsNeedingPalping() {
    final now = DateTime.now();
    return _animals.where((a) {
      if (a.fechaUltimoPalpado == null) return true;
      final daysSince = now.difference(a.fechaUltimoPalpado!).inDays;
      return daysSince > 28;
    }).toList();
  }

  List<Animal> getAnimalsWithAlerts() {
    return _animals
        .where((a) => a.mesesEmbarazo >= 8 || a.fechaUltimoPalpado == null)
        .toList();
  }
}
