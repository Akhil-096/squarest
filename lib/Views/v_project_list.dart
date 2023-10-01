import 'dart:io';

import 'package:animations/animations.dart';
import 'package:squarest/Services/s_liked_projects_notifier.dart';
import 'package:squarest/Utils/u_custom_styles.dart';
import 'package:squarest/Views/v_list_project_card.dart';
import 'package:squarest/Views/v_no_internet.dart';
import 'package:squarest/Views/v_project_details.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../Services/s_autocomplete_notifier.dart';
import '../Services/s_connectivity_notifier.dart';
import '../Services/s_sort_notifier.dart';
import '../Services/s_user_profile_notifier.dart';
import '../Utils/u_constants.dart';


class ProjectList extends StatefulWidget {
  final bool isComingFromBuilders;
  final int? builderId;
  final bool isComingFrom3d;
  final bool isComingFromTrending;
  final bool isComingFromNewLaunches;
  final bool isComingFromWorthALook;
  final String appBarTitle;
  // final bool isComingFromBottomNav;
  const ProjectList({required this.isComingFromBuilders, required this.builderId, required this.isComingFrom3d, required this.appBarTitle, required this.isComingFromNewLaunches, required this.isComingFromTrending, required this.isComingFromWorthALook, Key? key}) : super(key: key);

  @override
  State<ProjectList> createState() => _ProjectListState();
}

class _ProjectListState extends State<ProjectList> {
bool isLoading = false;
ScrollController? scrollController;
bool scrollUp = true;

_scrollListener() {
    if (scrollController!.position.userScrollDirection == ScrollDirection.reverse) {
        setState(() {
          scrollUp = false;
        });
    }
    if (scrollController!.position.userScrollDirection == ScrollDirection.forward) {
        setState(() {
          scrollUp = true;
        });
    }
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController?.addListener(_scrollListener);
    final autocompleteNotifier = Provider.of<AutocompleteNotifier>(context, listen: false);
    if(widget.isComingFromBuilders){
      setState(() {
        isLoading = true;
      });
      autocompleteNotifier.getBuilderProjects(context, widget.builderId!, this).whenComplete(() {
        setState(() {
          isLoading = false;
        });
      });
    }
    final likedProjectsNotifier =
    Provider.of<LikedProjectsNotifier>(context, listen: false);
    final userProfileNotifier = Provider.of<UserProfileNotifier>(context, listen: false);
    if(autocompleteNotifier.builderProjectLists.isNotEmpty || autocompleteNotifier.aRprojectLists.isNotEmpty || autocompleteNotifier.projectList.isNotEmpty){
      if(userProfileNotifier.userProfileModel.firebase_user_id != null) {
        likedProjectsNotifier.getLikedProjects(context).then((value) {
          if(widget.isComingFrom3d){
            autocompleteNotifier.load3dLikes(context);
          } else if(widget.isComingFromBuilders){
            autocompleteNotifier.loadBuilderLikes(context);

          } else if(widget.isComingFromNewLaunches){
            autocompleteNotifier.loadNewLaunchesLikes(context);
          } else if(widget.isComingFromTrending){
            autocompleteNotifier.loadTrendingLikes(context);
          } else if(widget.isComingFromWorthALook) {
            autocompleteNotifier.loadWorthALookLikes(context);
          } else {
            autocompleteNotifier.loadLikes(context);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final autocompleteNotifier = Provider.of<AutocompleteNotifier>(context);
    final con = context.watch<ConnectivityChangeNotifier>();
    final likedProjectsNotifier = Provider.of<LikedProjectsNotifier>(context);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return (con.connectivity == null)
        ? const Center(child: ListShimmer())
        : ((con.connectivity == ConnectivityResult.none) ||
        (con.isDeviceConnected == false))
        ? const NoInternet()
        : Scaffold(
      appBar: Platform.isAndroid ? PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          scrolledUnderElevation: 0.0,
          backgroundColor:
          (MediaQuery.of(context).platformBrightness ==
              Brightness.dark)
              ? Colors.grey[900]
              : Colors.white,
          // elevation: 1,
          title: Text(widget.appBarTitle, style: CustomTextStyles.getTitle(null, (MediaQuery.of(context).platformBrightness ==
              Brightness.dark)
              ? Colors.white
              : Colors.black, null, 19),),
        ),
      ) : CupertinoNavigationBar(
        backgroundColor:
        (MediaQuery.of(context).platformBrightness ==
            Brightness.dark)
            ? Colors.grey[900]
            : CupertinoColors.white,
        middle: Text(widget.appBarTitle, style: CustomTextStyles.getTitle(null, (MediaQuery.of(context).platformBrightness ==
            Brightness.dark)
            ? CupertinoColors.white
            : CupertinoColors.black, null, 19),),
      ),
      body: SafeArea(
        child: isLoading ? const ListShimmer() : Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(4.0),
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: Platform.isAndroid ? Colors.black.withOpacity(0.5) : CupertinoColors.black.withOpacity(0.5),
                  ),
                  child: widget.isComingFrom3d ? Text(
                    autocompleteNotifier
                        .aRprojectLists
                        .isEmpty
                        ? 'No projects'
                        : '${Provider.of<AutocompleteNotifier>(context).aRprojectLists.length} projects',
                    style: TextStyle(color: Platform.isAndroid ? Colors.white : CupertinoColors.white),
                  ) : widget.isComingFromTrending ? Text(
                    autocompleteNotifier
                        .trendingLists
                        .isEmpty
                        ? 'No projects'
                        : '${Provider.of<AutocompleteNotifier>(context).trendingLists.length} projects',
                    style: TextStyle(color: Platform.isAndroid ? Colors.white : CupertinoColors.white),
                  ) :  widget.isComingFromNewLaunches ? Text(
                    autocompleteNotifier
                        .newLaunchesLists
                        .isEmpty
                        ? 'No projects'
                        : '${Provider.of<AutocompleteNotifier>(context).newLaunchesLists.length} projects',
                    style: TextStyle(color: Platform.isAndroid ? Colors.white : CupertinoColors.white),
                  ) : widget.isComingFromBuilders ? Text(autocompleteNotifier
                      .builderProjectLists.isEmpty ? 'No projects' : '${Provider.of<AutocompleteNotifier>(context).builderProjectLists.length} projects', style: TextStyle(color: Platform.isAndroid ? Colors.white : CupertinoColors.white)) : widget.isComingFromWorthALook ? Text(autocompleteNotifier
                      .worthALookLists.isEmpty ? 'No projects' : '${Provider.of<AutocompleteNotifier>(context).worthALookLists.length} projects', style: TextStyle(color: Platform.isAndroid ? Colors.white : CupertinoColors.white)) :
                  Text(
                    autocompleteNotifier
                        .projectList
                        .isEmpty
                        ? 'No projects'
                        : '${Provider.of<AutocompleteNotifier>(context).projectList.length} projects',
                    style: TextStyle(color: Platform.isAndroid ? Colors.white : CupertinoColors.white),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                      controller: scrollController,
                      itemCount:
                      widget.isComingFromBuilders ? autocompleteNotifier.builderProjectLists.length : widget.isComingFromWorthALook ? autocompleteNotifier.worthALookLists.length : widget.isComingFrom3d ? autocompleteNotifier.aRprojectLists.length : widget.isComingFromNewLaunches ? autocompleteNotifier.newLaunchesLists.length : widget.isComingFromTrending ? autocompleteNotifier.trendingLists.length : autocompleteNotifier.projectList.length,
                      itemBuilder:
                          (BuildContext context, int index) {
                        return OpenContainer(
                          closedColor: (MediaQuery.of(context).platformBrightness == Brightness.dark)
                              ? Colors.grey[900]!
                              : Platform.isAndroid ? Colors.white : CupertinoColors.white,
                          closedElevation: 10,
                          closedShape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(0))),
                          transitionType: ContainerTransitionType.fadeThrough,
                          transitionDuration: const Duration(milliseconds: 500),
                          onClosed: (_){
                            likedProjectsNotifier.getLikedProjects(context);
                          },
                          closedBuilder: (ctx, openContainer){
                            return GestureDetector(
                              onTap: openContainer,
                              child: ChangeNotifierProvider.value(
                                value: widget.isComingFromWorthALook ? autocompleteNotifier.worthALookLists[index] : widget.isComingFromBuilders ? autocompleteNotifier.builderProjectLists[index] : widget.isComingFrom3d ? autocompleteNotifier.aRprojectLists[index] : widget.isComingFromNewLaunches ? autocompleteNotifier.newLaunchesLists[index] : widget.isComingFromTrending ? autocompleteNotifier.trendingLists[index] : autocompleteNotifier
                                    .projectList[index],
                                child: ProjectListCard(
                                  project: widget.isComingFromWorthALook ? autocompleteNotifier.worthALookLists[index] : widget.isComingFromBuilders ? autocompleteNotifier.builderProjectLists[index] : widget.isComingFrom3d ? autocompleteNotifier.aRprojectLists[index] : widget.isComingFromNewLaunches ? autocompleteNotifier.newLaunchesLists[index] : widget.isComingFromTrending ? autocompleteNotifier.trendingLists[index] : autocompleteNotifier
                                      .projectList[index],
                                ),
                              ),
                            );
                          },
                          openBuilder: (_,__){
                            FocusScope.of(context).unfocus();
                            return ChangeNotifierProvider.value(
                              value: widget.isComingFromWorthALook ? autocompleteNotifier.worthALookLists[index] : widget.isComingFromBuilders ? autocompleteNotifier.builderProjectLists[index] : widget.isComingFrom3d ? autocompleteNotifier.aRprojectLists[index] : widget.isComingFromTrending ? autocompleteNotifier.trendingLists[index] : widget.isComingFromNewLaunches ? autocompleteNotifier.newLaunchesLists[index] : autocompleteNotifier
                                  .projectList[index],
                              child: ProjectDetails(
                                project: widget.isComingFromWorthALook ? autocompleteNotifier.worthALookLists[index] : widget.isComingFromBuilders ? autocompleteNotifier.builderProjectLists[index] : widget.isComingFrom3d ? autocompleteNotifier.aRprojectLists[index] : widget.isComingFromNewLaunches ? autocompleteNotifier.newLaunchesLists[index] : widget.isComingFromTrending ? autocompleteNotifier.trendingLists[index] : autocompleteNotifier
                                    .projectList[index],
                                isComingFromList: true,
                              ),
                            );
                          },
                        );
                      }),
                ),
              ],
            ),
            // Visibility(
            //     visible: (widget.isComingFrom3d || widget.isComingFromNewLaunches || widget.isComingFromBuilders || widget.isComingFromTrending || widget.isComingFromWorthALook) ? false : true,
            //     child: Positioned(
            //       right: width * 0.030,
            //       bottom: 80, child: GestureDetector(
            //       onTap: () {
            //         autocompleteNotifier.setIsListClickedToFalse();
            //       },
            //       child: Container(
            //           width: 50,
            //           height: 50,
            //           decoration: BoxDecoration(
            //             color: (MediaQuery.of(context).platformBrightness == Brightness.dark)
            //                 ? Colors.grey[900] : Platform.isAndroid ? Colors.white : CupertinoColors.white, // border color
            //             shape: BoxShape.circle,
            //           ),
            //           child: Icon(Platform.isAndroid ? Icons.map_outlined : CupertinoIcons.map)),
            //     ),),),
            Visibility(
              visible: scrollUp ? true : false,
              child: Positioned(
                bottom: height * 0.015,
                left: width * 0.010,
                child: Consumer<SortNotifier>(
                  builder: (ctx, sort, _) => InkWell(
                    onTap: widget.isComingFrom3d ? () async {
                      sort.sortPrice();
                      if (sort.isPriceAscending) {
                        setState(() {
                          autocompleteNotifier.aRprojectLists =
                          autocompleteNotifier.aRprojectLists
                            ..sort((a, b) => (a.min_price)
                                .compareTo(b.min_price));
                        });
                      } else {
                        setState(() {
                          autocompleteNotifier.aRprojectLists =
                              (autocompleteNotifier
                                  .aRprojectLists
                                ..sort((a, b) =>
                                    (a.min_price)
                                        .compareTo(
                                        b.min_price)))
                                  .reversed
                                  .toList();
                        });
                      }
                      await FirebaseAnalytics.instance
                          .logEvent(
                        name: "select_content",
                        parameters: {
                          "content_type": "sort_item",
                          "item_id": "price",
                        },
                      );
                    } : widget.isComingFromWorthALook ? () async {
                      sort.sortPrice();
                      if (sort.isPriceAscending) {
                        setState(() {
                          autocompleteNotifier.worthALookLists =
                          autocompleteNotifier.worthALookLists
                            ..sort((a, b) => (a.min_price)
                                .compareTo(b.min_price));
                        });
                      } else {
                        setState(() {
                          autocompleteNotifier.worthALookLists =
                              (autocompleteNotifier
                                  .worthALookLists
                                ..sort((a, b) =>
                                    (a.min_price)
                                        .compareTo(
                                        b.min_price)))
                                  .reversed
                                  .toList();
                        });
                      }
                      await FirebaseAnalytics.instance
                          .logEvent(
                        name: "select_content",
                        parameters: {
                          "content_type": "sort_item",
                          "item_id": "price",
                        },
                      );
                    } : widget.isComingFromBuilders ? () async {
                      sort.sortPrice();
                      if (sort.isPriceAscending) {
                        setState(() {
                          autocompleteNotifier.builderProjectLists =
                          autocompleteNotifier.builderProjectLists
                            ..sort((a, b) => (a.min_price)
                                .compareTo(b.min_price));
                        });
                      } else {
                        setState(() {
                          autocompleteNotifier.builderProjectLists =
                              (autocompleteNotifier
                                  .builderProjectLists
                                ..sort((a, b) =>
                                    (a.min_price)
                                        .compareTo(
                                        b.min_price)))
                                  .reversed
                                  .toList();
                        });
                      }
                      await FirebaseAnalytics.instance
                          .logEvent(
                        name: "select_content",
                        parameters: {
                          "content_type": "sort_item",
                          "item_id": "price",
                        },
                      );
                    } : widget.isComingFromNewLaunches ? () async {
                      sort.sortPrice();
                      if (sort.isPriceAscending) {
                        setState(() {
                          autocompleteNotifier.newLaunchesLists =
                          autocompleteNotifier.newLaunchesLists
                            ..sort((a, b) => (a.min_price)
                                .compareTo(b.min_price));
                        });
                      } else {
                        setState(() {
                          autocompleteNotifier.newLaunchesLists =
                              (autocompleteNotifier
                                  .newLaunchesLists
                                ..sort((a, b) =>
                                    (a.min_price)
                                        .compareTo(
                                        b.min_price)))
                                  .reversed
                                  .toList();
                        });
                      }
                      await FirebaseAnalytics.instance
                          .logEvent(
                        name: "select_content",
                        parameters: {
                          "content_type": "sort_item",
                          "item_id": "price",
                        },
                      );
                    } : widget.isComingFromTrending ? () async {
                      sort.sortPrice();
                      if (sort.isPriceAscending) {
                        setState(() {
                          autocompleteNotifier.trendingLists =
                          autocompleteNotifier.trendingLists
                            ..sort((a, b) => (a.min_price)
                                .compareTo(b.min_price));
                        });
                      } else {
                        setState(() {
                          autocompleteNotifier.trendingLists =
                              (autocompleteNotifier
                                  .trendingLists
                                ..sort((a, b) =>
                                    (a.min_price)
                                        .compareTo(
                                        b.min_price)))
                                  .reversed
                                  .toList();
                        });
                      }
                      await FirebaseAnalytics.instance
                          .logEvent(
                        name: "select_content",
                        parameters: {
                          "content_type": "sort_item",
                          "item_id": "price",
                        },
                      );
                    } : () async {
                      sort.sortPrice();
                      if (sort.isPriceAscending) {
                        setState(() {
                          autocompleteNotifier.projectList =
                          autocompleteNotifier.projectList
                            ..sort((a, b) => (a.min_price)
                                .compareTo(b.min_price));
                        });
                      } else {
                        setState(() {
                          autocompleteNotifier.projectList =
                              (autocompleteNotifier
                                  .projectList
                                ..sort((a, b) =>
                                    (a.min_price)
                                        .compareTo(
                                        b.min_price)))
                                  .reversed
                                  .toList();
                        });
                      }
                      await FirebaseAnalytics.instance
                          .logEvent(
                        name: "select_content",
                        parameters: {
                          "content_type": "sort_item",
                          "item_id": "price",
                        },
                      );
                    },
                    child: Container(
                      width: 90,
                      height: 50,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.circular(15))),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Card(
                          elevation: 10,
                          child: Row(
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: sort.isPriceSelected ? 5 : 15,
                                  ),
                                  Text(
                                    '\u{20B9}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: (MediaQuery.of(context).platformBrightness ==
                                            Brightness.dark)
                                            ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                            : Platform.isAndroid ? Colors.black : CupertinoColors.black),
                                  ),
                                  sort.isPriceSelected
                                      ? const SizedBox(
                                    width: 2,
                                  )
                                      : SizedBox(
                                    width: sort.isPriceSelected ? 2 : 5,
                                  ),
                                  sort.isPriceSelected
                                      ? Stack(
                                    children: [
                                      sort.isPriceAscending
                                          ? Icon(
                                        Platform.isAndroid ? Icons.arrow_downward : CupertinoIcons
                                            .arrow_down,
                                        size: 15,
                                        color: globalColor,
                                      )
                                          : Icon(
                                        Platform.isAndroid ? Icons.arrow_upward : CupertinoIcons
                                            .arrow_up,
                                        size: 15,
                                        color: globalColor,
                                      ),
                                    ],
                                  )
                                      : Container(),
                                ],
                              ),
                              Text(
                                'Price',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight:
                                    sort.isPriceSelected
                                        ? FontWeight.bold
                                        : null,
                                    fontSize: 13,
                                    color: (MediaQuery.of(context).platformBrightness ==
                                        Brightness.dark)
                                        ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                        : Platform.isAndroid ? Colors.black : CupertinoColors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),),
            ),
            Visibility(
              visible: scrollUp ? true : false,
              child: Positioned(
                bottom: height * 0.015,
                left: width * 0.253,
                child: Consumer<SortNotifier>(
                  builder: (ctx, sort, _) => InkWell(
                    onTap: widget.isComingFrom3d ? () async {
                      sort.sortCarpetArea();
                      if (sort.isAreaAscending) {
                        setState(() {
                          autocompleteNotifier.aRprojectLists =
                          autocompleteNotifier.aRprojectLists
                            ..sort((a, b) => (a.min_area)
                                .compareTo(b.min_area));
                        });
                      } else {
                        setState(() {
                          autocompleteNotifier.aRprojectLists =
                              (autocompleteNotifier
                                  .aRprojectLists
                                ..sort((a, b) =>
                                    (a.min_area)
                                        .compareTo(
                                        b.min_area)))
                                  .reversed
                                  .toList();
                        });
                      }
                      await FirebaseAnalytics.instance
                          .logEvent(
                        name: "select_content",
                        parameters: {
                          "content_type": "sort_item",
                          "item_id": "carpet",
                        },
                      );
                    } : widget.isComingFromWorthALook ? () async {
                      sort.sortCarpetArea();
                      if (sort.isAreaAscending) {
                        setState(() {
                          autocompleteNotifier.worthALookLists =
                          autocompleteNotifier.worthALookLists
                            ..sort((a, b) => (a.min_area)
                                .compareTo(b.min_area));
                        });
                      } else {
                        setState(() {
                          autocompleteNotifier.worthALookLists =
                              (autocompleteNotifier
                                  .worthALookLists
                                ..sort((a, b) =>
                                    (a.min_area)
                                        .compareTo(
                                        b.min_area)))
                                  .reversed
                                  .toList();
                        });
                      }
                      await FirebaseAnalytics.instance
                          .logEvent(
                        name: "select_content",
                        parameters: {
                          "content_type": "sort_item",
                          "item_id": "carpet",
                        },
                      );
                    } : widget.isComingFromBuilders ? () async {
                      sort.sortCarpetArea();
                      if (sort.isAreaAscending) {
                        setState(() {
                          autocompleteNotifier.builderProjectLists =
                          autocompleteNotifier.builderProjectLists
                            ..sort((a, b) => (a.min_area)
                                .compareTo(b.min_area));
                        });
                      } else {
                        setState(() {
                          autocompleteNotifier.builderProjectLists =
                              (autocompleteNotifier
                                  .builderProjectLists
                                ..sort((a, b) =>
                                    (a.min_area)
                                        .compareTo(
                                        b.min_area)))
                                  .reversed
                                  .toList();
                        });
                      }
                      await FirebaseAnalytics.instance
                          .logEvent(
                        name: "select_content",
                        parameters: {
                          "content_type": "sort_item",
                          "item_id": "carpet",
                        },
                      );
                    } : widget.isComingFromTrending ? () async {
                      sort.sortCarpetArea();
                      if (sort.isAreaAscending) {
                        setState(() {
                          autocompleteNotifier.trendingLists =
                          autocompleteNotifier.trendingLists
                            ..sort((a, b) => (a.min_area)
                                .compareTo(b.min_area));
                        });
                      } else {
                        setState(() {
                          autocompleteNotifier.trendingLists =
                              (autocompleteNotifier
                                  .trendingLists
                                ..sort((a, b) =>
                                    (a.min_area)
                                        .compareTo(
                                        b.min_area)))
                                  .reversed
                                  .toList();
                        });
                      }
                      await FirebaseAnalytics.instance
                          .logEvent(
                        name: "select_content",
                        parameters: {
                          "content_type": "sort_item",
                          "item_id": "carpet",
                        },
                      );
                    } : widget.isComingFromNewLaunches ? () async {
                      sort.sortCarpetArea();
                      if (sort.isAreaAscending) {
                        setState(() {
                          autocompleteNotifier.newLaunchesLists =
                          autocompleteNotifier.newLaunchesLists
                            ..sort((a, b) => (a.min_area)
                                .compareTo(b.min_area));
                        });
                      } else {
                        setState(() {
                          autocompleteNotifier.newLaunchesLists =
                              (autocompleteNotifier
                                  .newLaunchesLists
                                ..sort((a, b) =>
                                    (a.min_area)
                                        .compareTo(
                                        b.min_area)))
                                  .reversed
                                  .toList();
                        });
                      }
                      await FirebaseAnalytics.instance
                          .logEvent(
                        name: "select_content",
                        parameters: {
                          "content_type": "sort_item",
                          "item_id": "carpet",
                        },
                      );
                    } : () async {
                      sort.sortCarpetArea();
                      if (sort.isAreaAscending) {
                        setState(() {
                          autocompleteNotifier.projectList =
                          autocompleteNotifier.projectList
                            ..sort((a, b) => (a.min_area)
                                .compareTo(b.min_area));
                        });
                      } else {
                        setState(() {
                          autocompleteNotifier.projectList =
                              (autocompleteNotifier
                                  .projectList
                                ..sort((a, b) =>
                                    (a.min_area)
                                        .compareTo(
                                        b.min_area)))
                                  .reversed
                                  .toList();
                        });
                      }
                      await FirebaseAnalytics.instance
                          .logEvent(
                        name: "select_content",
                        parameters: {
                          "content_type": "sort_item",
                          "item_id": "carpet",
                        },
                      );
                    },
                    child: Container(
                      width: 90,
                      height: 50,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.circular(15))),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Card(
                          elevation: 10,
                          child: Row(
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: sort.isAreaSelected ? 5 : 15,
                                  ),
                                  Icon(
                                      Icons
                                          .settings_overscan_outlined,
                                      size: 17,
                                      color: (MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark)
                                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                          : Platform.isAndroid ? Colors.black : CupertinoColors.black),
                                  sort.isAreaSelected
                                      ? const SizedBox(
                                    width: 2,
                                  )
                                      : SizedBox(
                                    width: sort.isAreaSelected ? 2 : 5,
                                  ),
                                  sort.isAreaSelected
                                      ? Stack(
                                    children: [
                                      sort.isAreaAscending
                                          ? Icon(
                                        Platform.isAndroid ? Icons.arrow_downward : CupertinoIcons
                                            .arrow_down,
                                        size: 15,
                                        color: globalColor,
                                      )
                                          : Icon(
                                        Platform.isAndroid ? Icons.arrow_upward : CupertinoIcons
                                            .arrow_up,
                                        size: 15,
                                        color: globalColor,
                                      ),
                                    ],
                                  )
                                      : Container(),
                                ],
                              ),
                              Text(
                                'Area',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight:
                                    sort.isAreaSelected
                                        ? FontWeight.bold
                                        : null,
                                    fontSize: 13,
                                    color: (MediaQuery.of(context).platformBrightness ==
                                        Brightness.dark)
                                        ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                        : Platform.isAndroid ? Colors.black : CupertinoColors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),),
            ),
            Visibility(
              visible: scrollUp ? true : false,
              child: Positioned(
                bottom: height * 0.015,
                right: width * 0.253,
                child: Consumer<SortNotifier>(
                  builder: (ctx, sort, _) => InkWell(
                    onTap: widget.isComingFrom3d ? () async {
                      sort.sortAvailableUnits();
                      if (sort.isAvailableUnitsAscending) {
                        setState(() {
                          autocompleteNotifier.aRprojectLists =
                          autocompleteNotifier.aRprojectLists
                            ..sort((a, b) => (a
                                .total_num_apts -
                                a.total_bkd_apts)
                                .compareTo(b
                                .total_num_apts -
                                b.total_bkd_apts));
                        });
                      } else {
                        setState(() {
                          autocompleteNotifier
                              .aRprojectLists = (autocompleteNotifier
                              .aRprojectLists
                            ..sort((a, b) => (a
                                .total_num_apts -
                                a.total_bkd_apts)
                                .compareTo(b
                                .total_num_apts -
                                b.total_bkd_apts)))
                              .reversed
                              .toList();
                        });
                      }
                      await FirebaseAnalytics.instance
                          .logEvent(
                        name: "select_content",
                        parameters: {
                          "content_type": "sort_item",
                          "item_id": "availability",
                        },
                      );
                    } : widget.isComingFromWorthALook ? () async {
                      sort.sortAvailableUnits();
                      if (sort.isAvailableUnitsAscending) {
                        setState(() {
                          autocompleteNotifier.worthALookLists =
                          autocompleteNotifier.worthALookLists
                            ..sort((a, b) => (a
                                .total_num_apts -
                                a.total_bkd_apts)
                                .compareTo(b
                                .total_num_apts -
                                b.total_bkd_apts));
                        });
                      } else {
                        setState(() {
                          autocompleteNotifier
                              .worthALookLists = (autocompleteNotifier
                              .worthALookLists
                            ..sort((a, b) => (a
                                .total_num_apts -
                                a.total_bkd_apts)
                                .compareTo(b
                                .total_num_apts -
                                b.total_bkd_apts)))
                              .reversed
                              .toList();
                        });
                      }
                      await FirebaseAnalytics.instance
                          .logEvent(
                        name: "select_content",
                        parameters: {
                          "content_type": "sort_item",
                          "item_id": "availability",
                        },
                      );
                    } : widget.isComingFromBuilders ? () async {
                      sort.sortAvailableUnits();
                      if (sort.isAvailableUnitsAscending) {
                        setState(() {
                          autocompleteNotifier.builderProjectLists =
                          autocompleteNotifier.builderProjectLists
                            ..sort((a, b) => (a
                                .total_num_apts -
                                a.total_bkd_apts)
                                .compareTo(b
                                .total_num_apts -
                                b.total_bkd_apts));
                        });
                      } else {
                        setState(() {
                          autocompleteNotifier
                              .builderProjectLists = (autocompleteNotifier
                              .builderProjectLists
                            ..sort((a, b) => (a
                                .total_num_apts -
                                a.total_bkd_apts)
                                .compareTo(b
                                .total_num_apts -
                                b.total_bkd_apts)))
                              .reversed
                              .toList();
                        });
                      }
                      await FirebaseAnalytics.instance
                          .logEvent(
                        name: "select_content",
                        parameters: {
                          "content_type": "sort_item",
                          "item_id": "availability",
                        },
                      );
                    } : widget.isComingFromNewLaunches ? () async {
                      sort.sortAvailableUnits();
                      if (sort.isAvailableUnitsAscending) {
                        setState(() {
                          autocompleteNotifier.newLaunchesLists =
                          autocompleteNotifier.newLaunchesLists
                            ..sort((a, b) => (a
                                .total_num_apts -
                                a.total_bkd_apts)
                                .compareTo(b
                                .total_num_apts -
                                b.total_bkd_apts));
                        });
                      } else {
                        setState(() {
                          autocompleteNotifier
                              .newLaunchesLists = (autocompleteNotifier
                              .newLaunchesLists
                            ..sort((a, b) => (a
                                .total_num_apts -
                                a.total_bkd_apts)
                                .compareTo(b
                                .total_num_apts -
                                b.total_bkd_apts)))
                              .reversed
                              .toList();
                        });
                      }
                      await FirebaseAnalytics.instance
                          .logEvent(
                        name: "select_content",
                        parameters: {
                          "content_type": "sort_item",
                          "item_id": "availability",
                        },
                      );
                    } : widget.isComingFromTrending ? () async {
                      sort.sortAvailableUnits();
                      if (sort.isAvailableUnitsAscending) {
                        setState(() {
                          autocompleteNotifier.trendingLists =
                          autocompleteNotifier.trendingLists
                            ..sort((a, b) => (a
                                .total_num_apts -
                                a.total_bkd_apts)
                                .compareTo(b
                                .total_num_apts -
                                b.total_bkd_apts));
                        });
                      } else {
                        setState(() {
                          autocompleteNotifier
                              .trendingLists = (autocompleteNotifier
                              .trendingLists
                            ..sort((a, b) => (a
                                .total_num_apts -
                                a.total_bkd_apts)
                                .compareTo(b
                                .total_num_apts -
                                b.total_bkd_apts)))
                              .reversed
                              .toList();
                        });
                      }
                      await FirebaseAnalytics.instance
                          .logEvent(
                        name: "select_content",
                        parameters: {
                          "content_type": "sort_item",
                          "item_id": "availability",
                        },
                      );
                    } : () async {
                      sort.sortAvailableUnits();
                      if (sort.isAvailableUnitsAscending) {
                        setState(() {
                          autocompleteNotifier.projectList =
                          autocompleteNotifier.projectList
                            ..sort((a, b) => (a
                                .total_num_apts -
                                a.total_bkd_apts)
                                .compareTo(b
                                .total_num_apts -
                                b.total_bkd_apts));
                        });
                      } else {
                        setState(() {
                          autocompleteNotifier
                              .projectList = (autocompleteNotifier
                              .projectList
                            ..sort((a, b) => (a
                                .total_num_apts -
                                a.total_bkd_apts)
                                .compareTo(b
                                .total_num_apts -
                                b.total_bkd_apts)))
                              .reversed
                              .toList();
                        });
                      }
                      await FirebaseAnalytics.instance
                          .logEvent(
                        name: "select_content",
                        parameters: {
                          "content_type": "sort_item",
                          "item_id": "availability",
                        },
                      );
                    },
                    child: Container(
                      width: 90,
                      height: 50,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.circular(15))),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Card(
                          elevation: 10,
                          child: Row(
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: sort.isAvailableUnitsSelected ? 5 : 12,
                                  ),
                                  Icon(
                                      Icons.vpn_key_outlined,
                                      size: 17,
                                      color: (MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark)
                                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                          : Platform.isAndroid ? Colors.black : CupertinoColors.black),
                                  sort.isAvailableUnitsSelected
                                      ? const SizedBox(
                                    width: 2,
                                  )
                                      : SizedBox(
                                    width: sort.isAvailableUnitsSelected ? 2 : 5,
                                  ),
                                  sort.isAvailableUnitsSelected
                                      ? Stack(
                                    children: [
                                      sort.isAvailableUnitsAscending
                                          ? Icon(
                                        Platform.isAndroid ? Icons.arrow_downward : CupertinoIcons
                                            .arrow_down,
                                        size: 15,
                                        color: globalColor,
                                      )
                                          : Icon(
                                        Platform.isAndroid ? Icons.arrow_upward : CupertinoIcons
                                            .arrow_up,
                                        size: 15,
                                        color: globalColor,
                                      ),
                                    ],
                                  )
                                      : Container(),
                                ],
                              ),
                              Text(
                                "Units",
                                style: TextStyle(
                                    fontWeight:
                                    sort.isAvailableUnitsSelected
                                        ? FontWeight.bold
                                        : null,
                                    fontSize: 13,
                                    color: (MediaQuery.of(context).platformBrightness ==
                                        Brightness.dark)
                                        ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                        : Platform.isAndroid ? Colors.black : CupertinoColors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),),
            ),
            Visibility(
              visible: scrollUp ? true : false,
              child: Positioned(
                bottom: height * 0.015,
                right: width * 0.010,
                child: Consumer<SortNotifier>(
                  builder: (ctx, sort, _) => InkWell(
                    onTap: widget.isComingFrom3d ? () async {
                      sort.sortReady();
                      if (sort.isReadyAscending) {
                        setState(() {
                          autocompleteNotifier.aRprojectLists =
                          autocompleteNotifier.aRprojectLists
                            ..sort((a, b) => (a
                                .proposed_completion_date)
                                .compareTo(b
                                .proposed_completion_date));
                        });
                      } else {
                        setState(() {
                          autocompleteNotifier
                              .aRprojectLists = (autocompleteNotifier
                              .aRprojectLists
                            ..sort((a, b) => (a
                                .proposed_completion_date)
                                .compareTo(b
                                .proposed_completion_date)))
                              .reversed
                              .toList();
                        });
                      }
                      await FirebaseAnalytics.instance
                          .logEvent(
                        name: "select_content",
                        parameters: {
                          "content_type": "sort_item",
                          "item_id": "ready",
                        },
                      );
                    } : widget.isComingFromWorthALook ? () async {
                      sort.sortReady();
                      if (sort.isReadyAscending) {
                        setState(() {
                          autocompleteNotifier.worthALookLists =
                          autocompleteNotifier.worthALookLists
                            ..sort((a, b) => (a
                                .proposed_completion_date)
                                .compareTo(b
                                .proposed_completion_date));
                        });
                      } else {
                        setState(() {
                          autocompleteNotifier
                              .worthALookLists = (autocompleteNotifier
                              .worthALookLists
                            ..sort((a, b) => (a
                                .proposed_completion_date)
                                .compareTo(b
                                .proposed_completion_date)))
                              .reversed
                              .toList();
                        });
                      }
                      await FirebaseAnalytics.instance
                          .logEvent(
                        name: "select_content",
                        parameters: {
                          "content_type": "sort_item",
                          "item_id": "ready",
                        },
                      );
                    } : widget.isComingFromBuilders ? () async {
                      sort.sortReady();
                      if (sort.isReadyAscending) {
                        setState(() {
                          autocompleteNotifier.builderProjectLists =
                          autocompleteNotifier.builderProjectLists
                            ..sort((a, b) => (a
                                .proposed_completion_date)
                                .compareTo(b
                                .proposed_completion_date));
                        });
                      } else {
                        setState(() {
                          autocompleteNotifier
                              .builderProjectLists = (autocompleteNotifier
                              .builderProjectLists
                            ..sort((a, b) => (a
                                .proposed_completion_date)
                                .compareTo(b
                                .proposed_completion_date)))
                              .reversed
                              .toList();
                        });
                      }
                      await FirebaseAnalytics.instance
                          .logEvent(
                        name: "select_content",
                        parameters: {
                          "content_type": "sort_item",
                          "item_id": "ready",
                        },
                      );
                    } : widget.isComingFromTrending ? () async {
                      sort.sortReady();
                      if (sort.isReadyAscending) {
                        setState(() {
                          autocompleteNotifier.trendingLists =
                          autocompleteNotifier.trendingLists
                            ..sort((a, b) => (a
                                .proposed_completion_date)
                                .compareTo(b
                                .proposed_completion_date));
                        });
                      } else {
                        setState(() {
                          autocompleteNotifier
                              .trendingLists = (autocompleteNotifier
                              .trendingLists
                            ..sort((a, b) => (a
                                .proposed_completion_date)
                                .compareTo(b
                                .proposed_completion_date)))
                              .reversed
                              .toList();
                        });
                      }
                      await FirebaseAnalytics.instance
                          .logEvent(
                        name: "select_content",
                        parameters: {
                          "content_type": "sort_item",
                          "item_id": "ready",
                        },
                      );
                    } : widget.isComingFromNewLaunches ? () async {
                      sort.sortReady();
                      if (sort.isReadyAscending) {
                        setState(() {
                          autocompleteNotifier.newLaunchesLists =
                          autocompleteNotifier.newLaunchesLists
                            ..sort((a, b) => (a
                                .proposed_completion_date)
                                .compareTo(b
                                .proposed_completion_date));
                        });
                      } else {
                        setState(() {
                          autocompleteNotifier
                              .newLaunchesLists = (autocompleteNotifier
                              .newLaunchesLists
                            ..sort((a, b) => (a
                                .proposed_completion_date)
                                .compareTo(b
                                .proposed_completion_date)))
                              .reversed
                              .toList();
                        });
                      }
                      await FirebaseAnalytics.instance
                          .logEvent(
                        name: "select_content",
                        parameters: {
                          "content_type": "sort_item",
                          "item_id": "ready",
                        },
                      );
                    } : () async {
                      sort.sortReady();
                      if (sort.isReadyAscending) {
                        setState(() {
                          autocompleteNotifier.projectList =
                          autocompleteNotifier.projectList
                            ..sort((a, b) => (a
                                .proposed_completion_date)
                                .compareTo(b
                                .proposed_completion_date));
                        });
                      } else {
                        setState(() {
                          autocompleteNotifier
                              .projectList = (autocompleteNotifier
                              .projectList
                            ..sort((a, b) => (a
                                .proposed_completion_date)
                                .compareTo(b
                                .proposed_completion_date)))
                              .reversed
                              .toList();
                        });
                      }
                      await FirebaseAnalytics.instance
                          .logEvent(
                        name: "select_content",
                        parameters: {
                          "content_type": "sort_item",
                          "item_id": "ready",
                        },
                      );
                    },
                    child: Container(
                      width: 90,
                      height: 50,
                      decoration: const BoxDecoration(
                          borderRadius:  BorderRadius.all(
                              Radius.circular(15))),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Card(
                          elevation: 10,
                          child: Row(
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: sort.isReadySelected ? 5 : 10,
                                  ),
                                  Icon(Platform.isAndroid ? Icons.alarm : CupertinoIcons.alarm,
                                      size: 17,
                                      color: (MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark)
                                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                          : Platform.isAndroid ? Colors.black : CupertinoColors.black),
                                  sort.isReadySelected
                                      ? const SizedBox(
                                    width: 0,
                                  )
                                      : SizedBox(
                                    width: sort.isReadySelected ? 2 : 4,
                                  ),
                                  sort.isReadySelected
                                      ? Stack(
                                    children: [
                                      sort.isReadyAscending
                                          ? Icon(
                                        Platform.isAndroid ? Icons.arrow_downward : CupertinoIcons
                                            .arrow_down,
                                        size: 15,
                                        color: globalColor,
                                      )
                                          : Icon(
                                        Platform.isAndroid ? Icons.arrow_upward : CupertinoIcons
                                            .arrow_up,
                                        size: 15,
                                        color: globalColor,
                                      ),
                                    ],
                                  )
                                      : Container(),
                                ],
                              ),
                              Text("Ready",
                                  style: TextStyle(
                                      fontWeight:
                                      sort.isReadySelected
                                          ? FontWeight.bold
                                          : null,
                                      fontSize: sort.isReadySelected ? 12 : 13,
                                      color: (MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark)
                                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                          : Platform.isAndroid ? Colors.black : CupertinoColors.black))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),),
            )
          ],
        ),
      ),
    );
  }
}

class ListShimmer extends StatefulWidget {
  const ListShimmer({Key? key}) : super(key: key);

  @override
  State<ListShimmer> createState() => _ListShimmerState();
}

class _ListShimmerState extends State<ListShimmer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Shimmer.fromColors(
        baseColor:
        (MediaQuery.of(context).platformBrightness == Brightness.dark)
            ? Colors.grey[700]!
            : Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          itemBuilder: (_, __) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 5, left: 5, right: 5),
                  height: 250,
                  decoration: BoxDecoration(
                      color: Colors.grey[300]!,
                      borderRadius: const BorderRadius.all(Radius.circular(15))),
                child: const Card(),
                ),
              )
            ],
          ),
          itemCount: 15,
        ),
      ),
    );
  }
}

