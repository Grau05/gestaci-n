import 'package:flutter/foundation.dart';
import 'package:gestantes/models/animal.dart';
import 'package:gestantes/database/database_helper.dart';

class AnimalProvider extends ChangeNotifier {
  List<Animal> _animals = [];
  List<Animal> _filteredAnimals = [];

  List<Animal> get animals => _filteredAnimals.isEmpty ? _animals : _filteredAnimals;
  List<Animal> get allAnimals => _animals;

  AnimalProvider() {
    loadAnimals();
  }

  Future<void> loadAnimals() async {
    _animals = await DatabaseHelper.instance.getAllAnimals();
    _filteredAnimals = [];
    notifyListeners();
  }

  Future<bool> addAnimal(Animal animal) async {
    final existing = await DatabaseHelper.instance.getAnimalByVisibleId(animal.idVisible);
    if (existing != null) {
      return false;
    }
    await DatabaseHelper.instance.insertAnimal(animal);
    await loadAnimals();
    return true;
  }

  Future<bool> updateAnimal(Animal animal) async {
    final existing = await DatabaseHelper.instance.getAnimalByVisibleId(animal.idVisible);
    if (existing != null && existing.idInterno != animal.idInterno) {
      return false;
    }
    await DatabaseHelper.instance.updateAnimal(animal);
    await loadAnimals();
    return true;
  }

  Future<void> deleteAnimal(int idInterno) async {
    await DatabaseHelper.instance.deleteAnimal(idInterno);
    await loadAnimals();
  }

  void filterByRaza(String raza) {
    if (raza.isEmpty) {
      _filteredAnimals = [];
    } else {
      _filteredAnimals = _animals.where((a) => a.raza.toLowerCase().contains(raza.toLowerCase())).toList();
    }
    notifyListeners();
  }

  void filterByMeses(int meses) {
    _filteredAnimals = _animals.where((a) => a.mesesEmbarazo == meses).toList();
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
}
