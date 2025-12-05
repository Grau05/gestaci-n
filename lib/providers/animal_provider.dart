import 'package:flutter/foundation.dart';
import 'package:gestantes/models/animal.dart';
import 'package:gestantes/models/farm.dart';
import 'package:gestantes/models/note.dart';
import 'package:gestantes/database/database_helper.dart';
import 'package:gestantes/utils/gestation_calculator.dart';

class AnimalProvider extends ChangeNotifier {
  List<Animal> _animals = [];
  List<Animal> _filteredAnimals = [];
  List<Farm> _farms = [];
  int _currentFarmId = 1;

  List<Animal> get animals => _filteredAnimals.isEmpty ? _animals : _filteredAnimals;
  List<Animal> get allAnimals => _animals;
  List<Farm> get farms => _farms;
  int get currentFarmId => _currentFarmId;
  Farm? get currentFarm => _farms.firstWhere(
        (f) => f.id == _currentFarmId,
        orElse: () => _farms.isNotEmpty ? _farms.first : Farm(nombre: ''),
      );

  AnimalProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _farms = await DatabaseHelper.instance.getAllFarms();
    if (_farms.isNotEmpty) {
      _currentFarmId = _farms.first.id ?? 1;
    }
    await loadAnimalsByFarm(_currentFarmId);
  }

  Future<void> loadAnimalsByFarm(int farmId) async {
    _currentFarmId = farmId;
    _animals = await DatabaseHelper.instance.getAllAnimalsByFarm(farmId);
    _animals.sort((a, b) => int.parse(a.idVisible).compareTo(int.parse(b.idVisible)));
    _filteredAnimals = [];
    notifyListeners();
  }

  Future<bool> addAnimal(Animal animal) async {
    final existing = await DatabaseHelper.instance
        .getAnimalByVisibleId(animal.idVisible, _currentFarmId);
    if (existing != null) {
      return false;
    }

    final updated = animal.copyWith(idFinca: _currentFarmId);
    await DatabaseHelper.instance.insertAnimal(updated);
    await loadAnimalsByFarm(_currentFarmId);
    return true;
  }

  Future<bool> updateAnimal(Animal animal) async {
    final existing = await DatabaseHelper.instance
        .getAnimalByVisibleId(animal.idVisible, _currentFarmId);
    if (existing != null && existing.idInterno != animal.idInterno) {
      return false;
    }

    await DatabaseHelper.instance.updateAnimal(animal);
    await loadAnimalsByFarm(_currentFarmId);
    return true;
  }

  Future<void> deleteAnimal(int idInterno) async {
    await DatabaseHelper.instance.deleteAnimal(idInterno);
    await loadAnimalsByFarm(_currentFarmId);
  }

  // ===== FILTROS =====
  void filterByRaza(String raza) {
    if (raza.isEmpty) {
      _filteredAnimals = [];
    } else {
      _filteredAnimals = _animals
          .where((a) => a.raza.toLowerCase().contains(raza.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void filterByEstado(String estado) {
    if (estado.isEmpty) {
      _filteredAnimals = [];
    } else {
      _filteredAnimals = _animals.where((a) => a.estado == estado).toList();
    }
    notifyListeners();
  }

  void filterByMeses(int meses) {
    _filteredAnimals = _animals.where((a) => a.mesesEmbarazo == meses).toList();
    notifyListeners();
  }

  void filterByDeliveryDate(String period) {
    _filteredAnimals = _animals.where((a) {
      final daysUntil = GestationCalculator.daysUntilDelivery(a);
      switch (period) {
        case 'proximas_2_semanas':
          return daysUntil >= 0 && daysUntil <= 14;
        case 'proximo_mes':
          return daysUntil > 14 && daysUntil <= 30;
        case 'proximos_2_meses':
          return daysUntil > 30 && daysUntil <= 60;
        default:
          return false;
      }
    }).toList();
    notifyListeners();
  }

  void filterByRisk(String riskType) {
    _filteredAnimals = _animals.where((a) {
      return GestationCalculator.classifyRisk(a) == riskType;
    }).toList();
    notifyListeners();
  }

  void applyMultipleFilters({
    String? raza,
    String? estado,
    int? meses,
    String? deliveryPeriod,
    String? riskType,
  }) {
    _filteredAnimals = _animals.where((a) {
      if (raza != null && !a.raza.toLowerCase().contains(raza.toLowerCase())) {
        return false;
      }
      if (estado != null && a.estado != estado) {
        return false;
      }
      if (meses != null && a.mesesEmbarazo != meses) {
        return false;
      }
      if (deliveryPeriod != null) {
        final daysUntil = GestationCalculator.daysUntilDelivery(a);
        switch (deliveryPeriod) {
          case 'proximas_2_semanas':
            if (!(daysUntil >= 0 && daysUntil <= 14)) return false;
            break;
          case 'proximo_mes':
            if (!(daysUntil > 14 && daysUntil <= 30)) return false;
            break;
          default:
            break;
        }
      }
      if (riskType != null) {
        if (GestationCalculator.classifyRisk(a) != riskType) return false;
      }
      return true;
    }).toList();
    notifyListeners();
  }

  void searchByIdVisible(String id) {
    if (id.isEmpty) {
      _filteredAnimals = [];
    } else {
      _filteredAnimals = _animals.where((a) => a.idVisible.contains(id)).toList();
    }
    notifyListeners();
  }

  void clearFilters() {
    _filteredAnimals = [];
    notifyListeners();
  }

  // ===== ESTADÍSTICAS =====
  Set<String> getRazas() {
    return _animals.map((a) => a.raza).toSet();
  }

  Map<int, int> getMesesDistribution() {
    final map = <int, int>{};
    for (var animal in _animals) {
      map[animal.mesesEmbarazo] = (map[animal.mesesEmbarazo] ?? 0) + 1;
    }
    return map;
  }

  Map<String, int> getRazaCount() {
    final map = <String, int>{};
    for (var animal in _animals) {
      map[animal.raza] = (map[animal.raza] ?? 0) + 1;
    }
    return map;
  }

  Map<String, int> getStateCount() {
    final map = <String, int>{};
    for (var animal in _animals) {
      map[animal.estado] = (map[animal.estado] ?? 0) + 1;
    }
    return map;
  }

  // ===== DASHBOARD STATS =====
  List<Animal> getAnimalsNearDelivery() {
    return _animals.where((a) {
      final days = GestationCalculator.daysUntilDelivery(a);
      return days >= 0 && days <= 14;
    }).toList();
  }

  List<Animal> getAnimalsNeedingPalping() {
    return _animals.where((a) {
      final risk = GestationCalculator.classifyRisk(a);
      return risk == 'palpado_vencido' || risk == 'sin_palpado_reciente';
    }).toList();
  }

  List<Animal> getAnimalsWithAlerts() {
    return _animals.where((a) {
      final risk = GestationCalculator.classifyRisk(a);
      return risk != 'normal';
    }).toList();
  }

  double getAverageGestationDays() {
    if (_animals.isEmpty) return 0;
    final sum = _animals.fold<int>(
      0,
      (sum, a) => sum + GestationCalculator.calculateGestationDays(a),
    );
    return sum / _animals.length;
  }

  // ===== FARMS =====
  Future<void> addFarm(Farm farm) async {
    await DatabaseHelper.instance.insertFarm(farm);
    _farms = await DatabaseHelper.instance.getAllFarms();
    notifyListeners();
  }

  Future<void> updateFarm(Farm farm) async {
    await DatabaseHelper.instance.updateFarm(farm);
    _farms = await DatabaseHelper.instance.getAllFarms();
    notifyListeners();
  }

  Future<void> deleteFarm(int farmId) async {
    await DatabaseHelper.instance.deleteFarm(farmId);
    _farms = await DatabaseHelper.instance.getAllFarms();
    if (_currentFarmId == farmId && _farms.isNotEmpty) {
      await loadAnimalsByFarm(_farms.first.id ?? 1);
    }
    notifyListeners();
  }

  // ===== NOTAS =====
  Future<List<Note>> getNotesByAnimal(int idAnimal) async {
    return await DatabaseHelper.instance.getNotesByAnimal(idAnimal);
  }

  Future<void> addNote(Note note) async {
    await DatabaseHelper.instance.insertNote(note);
    notifyListeners();
  }

  Future<void> deleteNote(String noteId) async {
    await DatabaseHelper.instance.deleteNote(noteId);
    notifyListeners();
  }
}
