import 'dart:io';

import 'package:squarest/Services/s_filter_notifier.dart';
import 'package:squarest/Utils/u_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:provider/provider.dart';
import 'package:squarest/Services/s_autocomplete_notifier.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:squarest/Models/m_latlng.dart' as location;


class SearchPlaceDelegate extends SearchDelegate {
  int _selectedIndex = 0;
  String label = "City or locality";
  final State state;
  final bool isComingFromNewHot;

  SearchPlaceDelegate(this.state, this.isComingFromNewHot);

  @override
  List<Widget> buildActions(BuildContext context) {
    final autocompleteNotifier = Provider.of<AutocompleteNotifier>(context);
    return [
      if (query.isNotEmpty)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
              onTap: () {
                query = "";
              },
              child: Icon(Platform.isAndroid ? Icons.clear : CupertinoIcons.clear)),
        ),
      if (query.isEmpty)
      StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: const EdgeInsets.only(
            top: 10,
            bottom: 10,
            right: 10,
          ),
          child: autocompleteNotifier.status ? FlutterToggleTab(
            width: 30,
            borderRadius: 20,
            selectedBackgroundColors: const [globalColor],
            selectedTextStyle: TextStyle(
              color: Platform.isAndroid ? Colors.white : CupertinoColors.white,
              fontSize: 14,
            ),
            unSelectedTextStyle: TextStyle(
              color: Platform.isAndroid ? Colors.black : CupertinoColors.black,
              fontSize: 14,
            ),
            labels: const ["Place", "Project"],
            selectedLabelIndex: (index) {
              setState(() {
              _selectedIndex = index;
              });
              if (_selectedIndex == 0) {
                setState((){
                  label = "City or locality";
                });
              } else {
                setState((){
                  label = "Name of project";
                });
              }

            },
            selectedIndex: _selectedIndex,
          ) : Container(
            width: 60,
            decoration: BoxDecoration(
              color: globalColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(child: Text('Place', style: TextStyle(color: Platform.isAndroid ? Colors.white : CupertinoColors.white),)),
          ),
        ),
      ),
    ];
  }

  @override
  String? get searchFieldLabel => label;

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
          backgroundColor:
              (MediaQuery.of(context).platformBrightness == Brightness.dark)
                  ? Colors.grey[900]
                  : Platform.isAndroid ? Colors.white : CupertinoColors.white), // appbar background color
      textSelectionTheme: TextSelectionThemeData(
          cursorColor:
              (MediaQuery.of(context).platformBrightness == Brightness.dark)
                  ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                  : Platform.isAndroid ? Colors.black : CupertinoColors.black), // cursor color
      hintColor: (MediaQuery.of(context).platformBrightness == Brightness.dark)
          ? Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey
          : Platform.isAndroid ? Colors.black : CupertinoColors.black, //hint text color
      textTheme: theme.textTheme.copyWith(
        titleLarge: TextStyle(
            fontWeight: FontWeight.normal,
            color:
                (MediaQuery.of(context).platformBrightness == Brightness.dark)
                    ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                    : Platform.isAndroid ? Colors.black : CupertinoColors.black), // query Color
      ),
    );
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Platform.isAndroid ? Icons.arrow_back : CupertinoIcons.arrow_left),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return const Text("");
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final autocompleteNotifier = Provider.of<AutocompleteNotifier>(context);
    final filters = Provider.of<FilterNotifier>(context);

    if (query.length > 2) {
      if (_selectedIndex == 0) {
        Provider.of<AutocompleteNotifier>(context, listen: false)
            .searchPlaces(query);
      } else {
        Provider.of<AutocompleteNotifier>(context, listen: false).getSearchedProjects(query);
      }
      if (kDebugMode) {
        print(autocompleteNotifier.searchedProjects.length);
      }
      return ListView.builder(
          shrinkWrap: true,
          itemCount: _selectedIndex == 0
              ? autocompleteNotifier.searchResults.length
              : autocompleteNotifier.searchedProjects.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () async {
                await FirebaseAnalytics.instance.logEvent(
                  name: "select_content",
                  parameters: {
                    "content_type":
                    _selectedIndex == 0 ? "locality" : "project",
                    "item_id": _selectedIndex == 0
                        ? autocompleteNotifier.searchResults[index].description
                        : autocompleteNotifier.searchedProjects[index].name_of_project,
                  },
                );
                if(_selectedIndex == 0){
                  if(isComingFromNewHot) {
                    NavigationBar navigationBar = autocompleteNotifier.bottomNavGlobalKey.currentWidget as NavigationBar;
                    navigationBar.onDestinationSelected!(0);
                  }
                  autocompleteNotifier.setSelectedPlace(
                      autocompleteNotifier.searchResults[index].placeId);
                  autocompleteNotifier.searchedLocation(
                      autocompleteNotifier.searchResults[index].description);
                  // saveRecentPlaces({'placeId' : autocompleteNotifier.searchResults[index].placeId, 'description' : autocompleteNotifier.searchResults[index].description});
                  autocompleteNotifier.closeBottomSheet();

                } else {
                  if(isComingFromNewHot) {
                    NavigationBar navigationBar = autocompleteNotifier.bottomNavGlobalKey.currentWidget as NavigationBar;
                    navigationBar.onDestinationSelected!(0);
                  }
                  filters.setFiltersToFalse();
                  filters.selectedChoices.clear();
                  filters.selectedChoices.add(0);
                  filters.resetAppliedFilter();
                  autocompleteNotifier.setIsSearchProjectToTrue();
                  autocompleteNotifier.setSelectedProject(location.Location(lat: autocompleteNotifier.searchedProjects[index].lat, lng: autocompleteNotifier.searchedProjects[index].lng));
                  autocompleteNotifier.searchedLocation(
                      autocompleteNotifier.searchedProjects[index].name_of_project);
                  autocompleteNotifier.setProjectId = autocompleteNotifier.searchedProjects[index].id;
                  // saveRecentProjects({'projectId' : autocompleteNotifier.searchedProjects[index].id, 'nameOfProject' : autocompleteNotifier.searchedProjects[index].name_of_project, 'lat' : autocompleteNotifier.searchedProjects[index].lat, 'lng' : autocompleteNotifier.searchedProjects[index].lng});
                  autocompleteNotifier.closeBottomSheet();

                }
                if (!state.mounted) return;
                close(context, null);
              },
              child: Column(
                children: [
                  _selectedIndex == 0 ?
                  ListTile(
                    title: Text(autocompleteNotifier.searchResults[index].description),
                  ) :
                  ListTile(
                    title: RichText(
                      text: TextSpan(
                          children: [
                            TextSpan(text: '${autocompleteNotifier.searchedProjects[index].applicationno}  ${autocompleteNotifier.searchedProjects[index].name_of_project}  ', style: TextStyle(fontSize: 17, color: (MediaQuery.of(context).platformBrightness == Brightness.dark)
                                ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                : Platform.isAndroid ? Colors.black : CupertinoColors.black)),
                            TextSpan(text: '\n${autocompleteNotifier.searchedProjects[index].builder_name ?? autocompleteNotifier.searchedProjects[index].promoter_name}  ${autocompleteNotifier.searchedProjects[index].project_village}  ${autocompleteNotifier.searchedProjects[index].project_district}', style: TextStyle(fontSize: 14, color: (MediaQuery.of(context).platformBrightness == Brightness.dark)
                                ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                : Platform.isAndroid ? Colors.black : CupertinoColors.black))
                          ]
                      ),
                      maxLines: 3,
                    ),
                  ),
                  if(_selectedIndex == 1)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 13,
                        right: 13,
                        top: 2,
                      ),
                      child: Divider(
                        color: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                      ),
                    ),
                ],
              ),
            );
          });
    } else {
      autocompleteNotifier.searchedProjects.clear();
      return Container();
    }
  }

}
