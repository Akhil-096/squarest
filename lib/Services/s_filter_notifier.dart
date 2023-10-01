import 'package:squarest/Models/m_applied_filters.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FilterNotifier extends ChangeNotifier {

  bool isFilterApplied = false;
  bool isAnySelected = true;
  bool isOthersSelected = false;
  List<int> selectedIndex = [];
  bool isShowProjectsClicked = false;
  List<int> selectedChoices = [0];

  AppliedFilter appliedFilter = AppliedFilter(
      selectedBuilderId: [],
      bhk: [0],
      priceChoice: [0, 0],
      carpetChoice: [0, 0],
      selectedIndexAvailableFlats: 0,
      selectedIndexReadyStatus: 0,
      slectedIndexTownship: 0
  );

  AppliedFilter get appliedFilters => appliedFilter;

  setAppliedFilter(AppliedFilter appliedFilters) {
    appliedFilter = appliedFilters;
    notifyListeners();
  }

  setFiltersToTrue(){
    isFilterApplied = true;
    notifyListeners();
  }

  toggleOthers(){
    isOthersSelected = !isOthersSelected;
    notifyListeners();
  }


  setFiltersToFalse(){
    isFilterApplied = false;
    notifyListeners();
  }


  resetAppliedFilter() {
    appliedFilter = AppliedFilter(
        selectedBuilderId: [],
        bhk: [0],
        priceChoice: [0, 0],
        carpetChoice: [0, 0],
        selectedIndexAvailableFlats: 0,
        selectedIndexReadyStatus: 0,
        slectedIndexTownship: 0);
    isOthersSelected = false;
    isAnySelected = true;
    selectedIndex.clear();
    setFiltersToFalse();
    notifyListeners();
  }
}
