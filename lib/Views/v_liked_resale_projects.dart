import 'dart:io';

import 'package:animations/animations.dart';
import 'package:squarest/Views/v_liked_property_card.dart';
import 'package:squarest/Views/v_project_list.dart';
import 'package:squarest/Views/v_resale_property_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../Services/s_liked_projects_notifier.dart';
import '../Utils/u_custom_styles.dart';


class LikedResalePropertyList extends StatefulWidget {
  final String appBarTitle;
  const LikedResalePropertyList({required this.appBarTitle, Key? key}) : super(key: key);

  @override
  State<LikedResalePropertyList> createState() => _LikedResalePropertyListState();
}



class _LikedResalePropertyListState extends State<LikedResalePropertyList> {

  @override
  void initState() {
    super.initState();
    getLikedResaleProjects();
  }

  @override
  Widget build(BuildContext context) {
    final likedProjectsNotifier = Provider.of<LikedProjectsNotifier>(context);
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

    ),
    body: SafeArea(child: likedProjectsNotifier.isResaleLoading ? const ListShimmer() : likedProjectsNotifier.likedResalePropertyList.isEmpty ? const Center(child: Text('No Resale project. Save a resale project to see it here.'),) :
    ListView.builder(
      itemBuilder: (ctx, i) {
        return OpenContainer(
          transitionType: ContainerTransitionType.fadeThrough,
          transitionDuration: const Duration(milliseconds: 500),
          onClosed: (_){
            setState(() {
              likedProjectsNotifier.isResaleLoading = true;
            });
            getLikedResaleProjects();
            setState(() {
              likedProjectsNotifier.isResaleLoading = false;
            });
          },
          closedBuilder: (ctx, openContainer) {
            return GestureDetector(
                onTap: openContainer,
                child: LikedPropertyCard(resalePropertyModel: likedProjectsNotifier.likedResalePropertyList[i]));
          },
          openBuilder: (_, __){
            FocusScope.of(context).unfocus();
            return ChangeNotifierProvider.value(
              value: likedProjectsNotifier.likedResalePropertyList[i],
              child: ResalePropertyDetails(
                resalePropertyModel: likedProjectsNotifier.likedResalePropertyList[i],
                isComingFromList: false,
              ),
            );
          },
        );
      }, itemCount: likedProjectsNotifier.likedResalePropertyList.length,),)
    );
  }
  getLikedResaleProjects() {
    final likedProjectsNotifier = Provider.of<LikedProjectsNotifier>(context, listen: false);
    likedProjectsNotifier.getLikedResaleProperties(context);
    likedProjectsNotifier.isResaleLiked = true;
  }
}
