import 'dart:io';

import 'package:animations/animations.dart';
import 'package:squarest/Services/s_liked_projects_notifier.dart';
import 'package:squarest/Views/v_liked_project_card.dart';
import 'package:squarest/Views/v_project_details.dart';
import 'package:squarest/Views/v_project_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Utils/u_custom_styles.dart';

class LikedProjectsList extends StatefulWidget {
  final String appBarTitle;
  const LikedProjectsList({required this.appBarTitle, Key? key}) : super(key: key);

  @override
  State<LikedProjectsList> createState() => _LikedProjectsListState();
}

class _LikedProjectsListState extends State<LikedProjectsList> {


  @override
  void initState() {
    super.initState();
    getLikedProjects();
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
              : CupertinoColors.white,
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
        ? Colors.white
        : Colors.black, null, 19),),
      ),
      body: SafeArea(
        child: Padding(
    padding: const EdgeInsets.all(5),
        child: likedProjectsNotifier.isLoading ? const ListShimmer() : likedProjectsNotifier.likedProjectsList.isEmpty ? const Center(child: Text('No saved project. Save a project to see it here.'),) :
        ListView.builder(
    itemBuilder: (ctx, i) {
        return OpenContainer(
          transitionType: ContainerTransitionType.fadeThrough,
          transitionDuration: const Duration(milliseconds: 500),
          onClosed: (_){
            setState(() {
              likedProjectsNotifier.isLoading = true;
            });
            getLikedProjects();
            setState(() {
              likedProjectsNotifier.isLoading = false;
            });
          },
          closedBuilder: (ctx, openContainer) {
            return GestureDetector(
                onTap: openContainer,
                //     () async {
                //   FocusScope.of(context).unfocus();
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (ctx) => ChangeNotifierProvider.value(
                //         value: likedProjectsNotifier.likedProjectsList[i],
                //         child: ProjectDetails(
                //           project: likedProjectsNotifier.likedProjectsList[i],
                //           isComingFromList: false,
                //         ),
                //       ),
                //     ),
                //   ).then((value) {
                //     setState(() {
                //       likedProjectsNotifier.isLoading = true;
                //     });
                //     getLikedProjects();
                //     setState(() {
                //       likedProjectsNotifier.isLoading = false;
                //     });
                //   });
                //   await FirebaseAnalytics.instance.logEvent(
                //     name: "select_content",
                //     parameters: {
                //       "content_type": "card_list",
                //       "item_id": likedProjectsNotifier.likedProjectsList[i].applicationno,
                //     },
                //   );
                // },
                child: LikedProjectCard(project: likedProjectsNotifier.likedProjectsList[i]));
          },
          openBuilder: (_, __){
            FocusScope.of(context).unfocus();
            return ChangeNotifierProvider.value(
              value: likedProjectsNotifier.likedProjectsList[i],
              child: ProjectDetails(
                project: likedProjectsNotifier.likedProjectsList[i],
                isComingFromList: false,
              ),
            );
          },
        );
    },
    itemCount: likedProjectsNotifier.likedProjectsList.length,
        ),
    ),
      ),
      // FutureBuilder<List<Project>>(
      //     future: likedProjectsNotifier.getLikedProjectsList(),
      //     builder: (ctx, snapshot) {
      //       if(snapshot.connectionState == ConnectionState.waiting || isLoading){
      //         return const ListShimmer();
      //
      //       } else {
      //
      //       }
      // })

    );
  }

  getLikedProjects() {
    final likedProjectsNotifier = Provider.of<LikedProjectsNotifier>(context, listen: false);
    likedProjectsNotifier.getLikedProjects(context);
    likedProjectsNotifier.loadLikedImages(context);
    likedProjectsNotifier.isLiked = true;
  }

  // Future<void> loadImages() async {
  //   Future.delayed(const Duration(milliseconds: 500));
  //   // final autoCompleteNotifier =
  //   // Provider.of<AutocompleteNotifier>(context, listen: false);
  //   final likedProjectsNotifier = Provider.of<LikedProjectsNotifier>(context, listen: false);
  //   try {
  //     String json =
  //     await rootBundle.loadString('assets/storage_img_serv_acc_cred.json');
  //     StorageAccess storageAccess = StorageAccess(json);
  //     for(int i = 0 ; i < likedProjectsNotifier.likedProjectsList.length; i++) {
  //       likedProjectsNotifier.likedProjectsList[i].imageUrlList = likedProjectsNotifier.likedProjectsList[i].imageUrlList..addAll((await storageAccess
  //           .loadFromBucket(likedProjectsNotifier.likedProjectsList[i].applicationno)));
  //     }
  //   } catch (error) {
  //     if (kDebugMode) {
  //       print('$error');
  //     }
  //     rethrow;
  //   }
  // }

}
