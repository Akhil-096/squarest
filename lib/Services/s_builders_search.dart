import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class BuilderSearch extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {

    return [
      IconButton(
          onPressed: () {
            query = "";
          },
          icon: Icon(Platform.isAndroid ? Icons.clear : CupertinoIcons.clear))
    ];
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
  String? get searchFieldLabel => "Builder name";
  @override
  Widget buildResults(BuildContext context) {
    return const Text("");
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    
    return const Text("");
  }
}
