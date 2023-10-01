import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SortNotifier with ChangeNotifier {
  bool isAvailableUnitsSelected = false;
  bool isReadySelected = false;
  bool isAreaSelected = false;
  bool isPriceSelected = false;

  bool isPriceAscending = false;
  bool isAvailableUnitsAscending = false;
  bool isReadyAscending = false;
  bool isAreaAscending = false;

  void sortPrice() {
    isAreaSelected = false;
    isPriceSelected = true;
    isReadySelected = false;
    isAvailableUnitsSelected = false;
    isPriceAscending = !isPriceAscending;
    notifyListeners();
  }

  void sortCarpetArea() {
    isAreaSelected = true;
    isPriceSelected = false;
    isReadySelected = false;
    isAvailableUnitsSelected = false;
    isAreaAscending = !isAreaAscending;
    notifyListeners();
  }

  void sortAvailableUnits() {
    isAreaSelected = false;
    isPriceSelected = false;
    isReadySelected = false;
    isAvailableUnitsSelected = true;
    isAvailableUnitsAscending = !isAvailableUnitsAscending;
    notifyListeners();
  }

  void sortReady() {
    isAreaSelected = false;
    isPriceSelected = false;
    isReadySelected = true;
    isAvailableUnitsSelected = false;
    isReadyAscending = !isReadyAscending;
    notifyListeners();
  }
}
