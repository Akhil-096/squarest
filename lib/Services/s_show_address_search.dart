import 'dart:io';

import 'package:squarest/Services/s_places_service.dart';
import 'package:squarest/Services/s_resale_property_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:squarest/Services/s_autocomplete_notifier.dart';

class SearchAddressDelegate extends SearchDelegate {
  final String _label = "Address";
  final placesService = PlacesService();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
              onTap: () {
                if (query.isNotEmpty) {
                  query = "";
                } else {
                  close(context, null);
                }
              },
              child: Icon(Platform.isAndroid ? Icons.clear : CupertinoIcons.clear)),
        );
      }),
    ];
  }

  @override
  String? get searchFieldLabel => _label;

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
      icon: Icon(Platform.isAndroid ? Icons.arrow_back: CupertinoIcons.arrow_left),
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
    final resalePropertyNotifier = Provider.of<ResalePropertyNotifier>(context, listen: false);

    if (query.length > 2) {
      Provider.of<AutocompleteNotifier>(context, listen: false).getSearchedAddress(query);
      return ListView.builder(
      shrinkWrap: true,
      itemCount: autocompleteNotifier.candidates.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            autocompleteNotifier.locationTextController.text =
                autocompleteNotifier.candidates[index].formatted_address;
            resalePropertyNotifier.lat = autocompleteNotifier.candidates[index].geometry.location.lat;
            resalePropertyNotifier.lng = autocompleteNotifier.candidates[index].geometry.location.lng;
            placesService.getCityLocalityPostalCode(context);
            close(context, null);
          },
          child: ListTile(
            title: RichText(
              text: TextSpan(
                  children: [
                    TextSpan(text: '${autocompleteNotifier.candidates[index].name} ', style: TextStyle(fontSize: 17, color: (MediaQuery.of(context).platformBrightness == Brightness.dark)
                        ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                        : Platform.isAndroid ? Colors.black : CupertinoColors.black)),
                    TextSpan(text: '\n${autocompleteNotifier.candidates[index].formatted_address}', style: TextStyle(fontSize: 14, color: (MediaQuery.of(context).platformBrightness == Brightness.dark)
                        ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                        : Platform.isAndroid ? Colors.black : CupertinoColors.black))
                  ]
              ),
              maxLines: 3,
            ),
          ),
        );
      });
    } else {
      autocompleteNotifier.candidates.clear();
      return Container();
    }
  }
}
