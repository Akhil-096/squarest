import 'dart:io';

import 'package:squarest/Views/v_project_list.dart';
import 'package:squarest/Views/v_resale_property_list_card.dart';
import 'package:squarest/Views/v_resale_property_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../Services/s_autocomplete_notifier.dart';
import '../Services/s_liked_projects_notifier.dart';
import '../Services/s_resale_property_notifier.dart';
import '../Services/s_user_profile_notifier.dart';
import '../Utils/u_custom_styles.dart';


class ResalePropertyList extends StatefulWidget {
  final String appBarTitle;
  final bool isComingFromList;
  const ResalePropertyList({required this.appBarTitle, required this.isComingFromList, Key? key}) : super(key: key);

  @override
  State<ResalePropertyList> createState() => _ResalePropertyListState();
}



class _ResalePropertyListState extends State<ResalePropertyList> {

  @override
  void initState() {
    super.initState();
    final likedProjectsNotifier =
    Provider.of<LikedProjectsNotifier>(context, listen: false);
    final resalePropertyNotifier = Provider.of<ResalePropertyNotifier>(context, listen: false);
    final userProfileNotifier = Provider.of<UserProfileNotifier>(context, listen: false);
    if(userProfileNotifier.userProfileModel.firebase_user_id != null) {
      likedProjectsNotifier.getLikedResaleProperties(context).whenComplete(() {
        resalePropertyNotifier.loadResaleLikes(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final autoCompleteNotifier = Provider.of<AutocompleteNotifier>(context);
    final resalePropertyNotifier = Provider.of<ResalePropertyNotifier>(context);
    return Scaffold(
      appBar: Platform.isAndroid ? PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          scrolledUnderElevation: 0.0,
          backgroundColor: (MediaQuery.of(context).platformBrightness ==
              Brightness.dark)
              ? Colors.grey[900]
              : Colors.white,
          title: Text(widget.appBarTitle, style: CustomTextStyles.getTitle(null, (MediaQuery.of(context).platformBrightness ==
              Brightness.dark)
              ? Colors.white
              : Colors.black, null, 19),),
          // centerTitle: true,
        ),
      ) : CupertinoNavigationBar(
        backgroundColor: (MediaQuery.of(context).platformBrightness ==
            Brightness.dark)
            ? Colors.grey[900]
            : CupertinoColors.white,
        middle: Text(widget.appBarTitle, style: CustomTextStyles.getTitle(null, (MediaQuery.of(context).platformBrightness ==
            Brightness.dark)
            ? CupertinoColors.white
            : CupertinoColors.black, null, 19),),
        // centerTitle: true,
      ),
      body: SafeArea(
        child: resalePropertyNotifier.isLoading ? const ListShimmer() : (widget.isComingFromList && autoCompleteNotifier.resaleProjectList.isEmpty) ? const Center(child: Text('No search results currently\ntry a different search.'),) : (!widget.isComingFromList && resalePropertyNotifier.propertyItems.isEmpty) ? const Center(child: Text('Post a property to see it here.'),) : ListView.builder(itemBuilder: (ctx, i) {
          return GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => ChangeNotifierProvider.value(
                      value: widget.isComingFromList ? autoCompleteNotifier.resaleProjectList[i] : resalePropertyNotifier.propertyItems[i],
                      child: ResalePropertyDetails(
                        resalePropertyModel: widget.isComingFromList ? autoCompleteNotifier.resaleProjectList[i] : resalePropertyNotifier.propertyItems[i],
                        isComingFromList: true,
                      ),
                    ),
                  ),
                );
              },
              child: ChangeNotifierProvider.value(
                  value: widget.isComingFromList ? autoCompleteNotifier.resaleProjectList[i] : resalePropertyNotifier.propertyItems[i],
                  child: ResalePropertyListCard(resalePropertyModel: widget.isComingFromList ? autoCompleteNotifier.resaleProjectList[i] : resalePropertyNotifier.propertyItems[i])));
        }, itemCount: widget.isComingFromList ? autoCompleteNotifier.resaleProjectList.length : resalePropertyNotifier.propertyItems.length,),
      ),
    );
  }
}
