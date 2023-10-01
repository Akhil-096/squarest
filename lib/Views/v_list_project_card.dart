import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:squarest/Models/m_project.dart';
import 'package:like_button/like_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:transparent_image/transparent_image.dart';
import '../Services/s_liked_projects_notifier.dart';
import '../Services/s_user_profile_notifier.dart';
import '../Utils/u_custom_styles.dart';

class ProjectListCard extends StatefulWidget {
  final Project project;

  const ProjectListCard({
    Key? key,
    required this.project,
  }) : super(key: key);

  @override
  State<ProjectListCard> createState() => _ProjectListCardState();
}

class _ProjectListCardState extends State<ProjectListCard> {
  final PageController _controller = PageController(
    initialPage: 0,
  );
  bool isBHKVisible = false;
  ScreenshotController screenshotController = ScreenshotController();
  bool isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // ProjectService projectService = ProjectService();
    // projectService.incrementViewCount(widget.project.id);
    isBHKVisible = (widget.project.one_bhk == false &&
            widget.project.two_bhk == false &&
            widget.project.three_bhk == false &&
            widget.project.four_bhk == false)
        ? false
        : true;
  }



  @override
  Widget build(BuildContext context) {
    // final autoCompleteNotifier = Provider.of<AutocompleteNotifier>(context);
    // if(autoCompleteNotifier.openShare) {
    //   autoCompleteNotifier.openShareOnLogin(context, screenshotController);
    //   autoCompleteNotifier.setOpenShareToFalse();
    // }
    return Screenshot(
        controller: screenshotController,
        child: contentWidget(context));
  }

  Card contentWidget(BuildContext ctx) {
    final userProfileNotifier = Provider.of<UserProfileNotifier>(context);
    // final autoCompleteNotifier = Provider.of<AutocompleteNotifier>(context);
    final date = DateTime.now();
    final likedProjectsNotifier = Provider.of<LikedProjectsNotifier>(context);
    final project = Provider.of<Project>(context);
    return Card(
      color: (MediaQuery.of(context).platformBrightness == Brightness.dark)
          ? Colors.grey[900]
          : Platform.isAndroid ? Colors.white : CupertinoColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      elevation: 5,
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(),
            height: MediaQuery.of(context).size.height * 0.30,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: PageView(
                    children: [
                      if (widget.project.imageUrlList
                          .where((element) => !element.contains(".pdf"))
                          .toList()
                          .isEmpty)
                        Container(
                          color: Platform.isAndroid ? Colors.black : CupertinoColors.black,
                          child: Opacity(
                            opacity: 0.6,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Image.asset(
                                  'assets/images/default.png'),
                            ),
                          ),
                        )
                      else
                        Container(
                          color: Platform.isAndroid ? Colors.black : CupertinoColors.black,
                          child: Opacity(
                            opacity: 0.6,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: CachedNetworkImage(
                                imageUrl: widget.project.imageUrlList
                                    .where((element) => !element.contains(".pdf"))
                                    .toList()
                                    .first,
                                placeholder: (context, url) =>
                                    Image.memory(kTransparentImage),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                fadeInDuration: const Duration(milliseconds: 10),
                                fadeOutDuration: const Duration(milliseconds: 10),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  left: 5,
                  top: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${NumberFormat.compactCurrency(
                          decimalDigits: 2,
                          symbol: '',
                        ).format(widget.project.project_views_total).replaceAll(".00", "")} views',
                            style: CustomTextStyles.getBodySmall(CustomShadows.textNormal, Platform.isAndroid ? Colors.white : CupertinoColors.white, null, 14),),
                        Text('Listed ${date.difference(widget.project.insert_date).inDays} days ago',
                            style: CustomTextStyles.getBodySmall(CustomShadows.textNormal, Platform.isAndroid ? Colors.white : CupertinoColors.white, null, 14),),
                      ],
                    ),
                  ),
                ),
                if (widget.project.imageUrlList.isNotEmpty &&
                    widget.project.imageUrlList
                        .where((element) => !element.contains(".pdf"))
                        .toList()
                        .isNotEmpty)
                  Positioned(
                    bottom: 5,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                          borderRadius: BorderRadius.circular(50)),
                      child: Text(
                          "${widget.project.imageUrlList.where((element) => !element.contains(".pdf")).toList().length} images",
                          style: TextStyle(
                            color: Platform.isAndroid ? Colors.white : CupertinoColors.white,
                          )),
                    ),
                  ),
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.035,
                  left: MediaQuery.of(context).size.width * 0.025,
                  child: SizedBox(
                    // height: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 180,
                          child: Text(
                            widget.project.name_of_project,
                            maxLines: 1,
                            style: CustomTextStyles.getProjectNameFont(CustomShadows.textNormal, Platform.isAndroid ? Colors.white : CupertinoColors.white, 16),
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // const SizedBox(
                        //   height: 5,
                        // ),
                        SizedBox(
                          width: 180,
                          child: Text(
                            widget.project.builder_id != 0
                                ? widget.project.builder_name
                                : widget.project.promoter_name,
                            style: CustomTextStyles.getBody(CustomShadows.textNormal, Platform.isAndroid ? Colors.white : CupertinoColors.white, 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(widget.project.project_village,
                            style: CustomTextStyles.getBodySmall(CustomShadows.textNormal, Platform.isAndroid ? Colors.white : CupertinoColors.white, null, 14)),
                        Text(
                            '${widget.project.project_district} ${widget.project.pincode}',
                            style: CustomTextStyles.getBodySmall(CustomShadows.textNormal, Platform.isAndroid ? Colors.white : CupertinoColors.white, null, 14)),
                      ],
                    ),
                  ),

                  // ],
                  //   ),
                  // ),
                ),
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.090,
                  right: MediaQuery.of(context).size.width * 0.025,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(priceRange(),
                            textAlign: TextAlign.center,
                            style: CustomTextStyles.getBodyBold(CustomShadows.textNormal, Platform.isAndroid ? Colors.white : CupertinoColors.white, 16)),
                        //image: Image.asset('assets/images/img.gif'),
                        // SizedBox(height: MediaQuery.of(context).size.height * 0.0033),
                        Text(widget.project.applicationno,
                            textAlign: TextAlign.center,
                            style: CustomTextStyles.getBody(CustomShadows.textNormal, Platform.isAndroid ? Colors.white : CupertinoColors.white, 16))
                      ]),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.project.vr_videos.contains("http"))
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Platform.isAndroid ? Colors.purple : CupertinoColors.systemPurple,
                              borderRadius: BorderRadius.circular(50)),
                          child: Icon(
                            Icons.view_in_ar_outlined,
                            color: Platform.isAndroid ? Colors.white : CupertinoColors.white,
                            size: 16,
                          ),
                        ),
                      const SizedBox(
                        width: 5,
                      ),
                      if (widget.project.imageUrlList
                          .where((element) => element.contains(".pdf"))
                          .toList()
                          .isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Platform.isAndroid ? Colors.yellow : CupertinoColors.systemYellow,
                              borderRadius: BorderRadius.circular(50)),
                          child: Icon(
                            Icons.description_outlined,
                            color: Platform.isAndroid ? Colors.white : CupertinoColors.white,
                            size: 16,
                          ),
                        ),
                      const SizedBox(
                        width: 5,
                      ),
                      if (widget.project.imageUrlList
                          .where((element) => !element.contains(".pdf"))
                          .toList()
                          .isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Platform.isAndroid ? Colors.pink : CupertinoColors.systemPink,
                              borderRadius: BorderRadius.circular(50)),
                          child: Icon(
                            Platform.isAndroid ? Icons.camera_alt_outlined : CupertinoIcons.camera,
                            color: Platform.isAndroid ? Colors.white : CupertinoColors.white,
                            size: 16,
                          ),
                        ),
                      const SizedBox(
                        width: 5,
                      ),
                      if (widget.project.videos.contains("http"))
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Platform.isAndroid ? Colors.red : CupertinoColors.systemRed,
                              borderRadius: BorderRadius.circular(50)),
                          child: Icon(
                            Platform.isAndroid ? Icons.videocam : CupertinoIcons.video_camera,
                            color: Platform.isAndroid ? Colors.white : CupertinoColors.white,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                    right: 8,
                    bottom: 8,
                    child: StreamBuilder(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (ctx, userSnapshot) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 30,
                            width: 30,
                            padding: const EdgeInsets.only(left: 3),
                            decoration: BoxDecoration(
                                color: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                                borderRadius: BorderRadius.circular(50)),
                            child: LikeButton(
                              size: 20,
                              isLiked: project.isLiked,
                              likeBuilder: (isLiked) {
                                return isLiked ? Icon(Platform.isAndroid ? Icons.favorite : CupertinoIcons.suit_heart_fill, color: isLiked ? Platform.isAndroid ? Colors.red : CupertinoColors.systemRed : null, size: 20,) : Icon(Platform.isAndroid ? Icons.favorite_border_outlined : CupertinoIcons.suit_heart, color: Platform.isAndroid ? Colors.white : CupertinoColors.white, size: 20,);
                              },
                              // circleColor: const CircleColor(
                              //   start: Colors.amber,
                              //   end: Colors.redAccent,
                              // ),
                              // bubblesColor: const BubblesColor(
                              //   dotPrimaryColor: Colors.amber,
                              //   dotSecondaryColor: Colors.redAccent,
                              // ),
                              onTap: !userSnapshot.hasData ? (_) async {
                                Fluttertoast.showToast(
                                  msg: 'Please login to save a project',
                                  backgroundColor: Platform.isAndroid ? Colors.white : CupertinoColors.white,
                                  textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                );
                                return null;
                              } : (isLiked) async {
                                likedProjectsNotifier.isLiked = isLiked;
                                if(!likedProjectsNotifier.isLiked){
                                  project.toggleLike();
                                  await likedProjectsNotifier.insertLikes((userProfileNotifier.userProfileModel.id).toInt(), widget.project.id).whenComplete(() async {
                                     likedProjectsNotifier.getLikedProjects(context);
                                  });
                                  // Future.delayed(const Duration(milliseconds: 2000),(){
                                  // });
                                }
                                if(likedProjectsNotifier.isLiked){
                                  project.toggleLike();
                                  await likedProjectsNotifier.deleteLikes((userProfileNotifier.userProfileModel.id).toInt(), widget.project.id).whenComplete(() async {
                                     likedProjectsNotifier.getLikedProjects(context);
                                  });
                                  // Future.delayed(const Duration(milliseconds: 2000),(){
                                  //   likedProjectsNotifier.getLikedProjects(context);
                                  // });
                                }
                                return !isLiked;
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          // ShareIconWidget(project: widget.project,),
                          GestureDetector(
                            onTap: () {
                              double pixelRatio =
                                  MediaQuery.of(context)
                                      .devicePixelRatio;
                              screenshotController
                                  .capture(
                                  pixelRatio: pixelRatio,
                                  delay: const Duration(
                                      milliseconds: 10))
                                  .then((Uint8List? image) async {
                                if (image != null) {
                                  final directory =
                                  await getApplicationDocumentsDirectory();
                                  final imagePath = await File(
                                      '${directory.path}/image.png')
                                      .create();
                                  await imagePath
                                      .writeAsBytes(image);
                                  await Share.shareXFiles(
                                      [XFile(imagePath.path)],
                                      text:
                                      '${widget.project.name_of_project} from ${widget.project.builder_id != 0 ? widget.project.builder_name : widget.project.promoter_name}\n\nCheck it out on squarest app\n\nDownload from Google Play Store: https://play.google.com/store/apps/details?id=com.apartmint.squarest',
                                      subject:
                                      'squarest - ${widget.project.name_of_project} from ${widget.project.builder_id != 0 ? widget.project.builder_name : widget.project.promoter_name}');
                                }
                              }).catchError((onError) {
                                if (kDebugMode) {
                                  print(onError);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                                  borderRadius:
                                  BorderRadius.circular(50)),
                              child: Icon(
                                Platform.isAndroid ? Icons.share : CupertinoIcons.share,
                                color: Platform.isAndroid ? Colors.white : CupertinoColors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                ))
              ],
            ),
          ),
          SizedBox(
            // height: MediaQuery.of(context).size.height * 0.12,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      textGenerator(context,
                          '${widget.project.sanctioned_bldg_count} Building(s)',
                          color: (MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark)
                              ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                              : Platform.isAndroid ? Colors.black : CupertinoColors.black),
                      Visibility(
                          visible: isBHKVisible,
                          child: Wrap(
                            direction: Axis.horizontal,
                            spacing: 5,
                            children: [
                              Visibility(
                                visible: widget.project.one_bhk,
                                child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                                        width: 1,
                                      ),
                                    ),
                                    child: const Text('1')),
                              ),
                              Visibility(
                                visible: widget.project.two_bhk,
                                child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                                        width: 1,
                                      ),
                                    ),
                                    child: const Text('2')),
                              ),
                              Visibility(
                                visible: widget.project.three_bhk,
                                child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                                        width: 1,
                                      ),
                                    ),
                                    child: const Text('3')),
                              ),
                              Visibility(
                                visible: widget.project.four_bhk,
                                child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                                        width: 1,
                                      ),
                                    ),
                                    child: const Text('4+')),
                              ),
                              Visibility(
                                  visible: isBHKVisible,
                                  child: Container(
                                      padding: const EdgeInsets.all(3),
                                      child: Text('BHK', style: CustomTextStyles.getBodySmall(null, (MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark)
                                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                          : Platform.isAndroid ? Colors.black : CupertinoColors.black, null, 14),))),
                            ],
                          )),
                      textGenerator(context,
                          '${widget.project.min_area.round()} - ${widget.project.max_area.round()} sqft. Carpet',
                          color: (MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark)
                              ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                              : Platform.isAndroid ? Colors.black : CupertinoColors.black),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                    ],
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.02),
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: ((widget.project.total_num_apts -
                                    widget.project.total_bkd_apts)
                                .isNegative || widget.project.total_num_apts -
                            widget.project.total_bkd_apts == 0)
                            ? Text(
                                'Units available : Sold Out',
                                style: CustomTextStyles.getBodySmall(null, (MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark)
                                    ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                    : Platform.isAndroid ? Colors.black : CupertinoColors.black, FontWeight.bold, 14),
                              )
                            : Text(
                                'Units available : ${widget.project.total_num_apts - widget.project.total_bkd_apts}/${widget.project.total_num_apts}',
                                style: CustomTextStyles.getBodySmall(null, (MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark)
                                    ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                    : Platform.isAndroid ? Colors.black : CupertinoColors.black, FontWeight.bold, 14),
                              ),
                      ),
                    ),
                    textGenerator(context,
                        'as on ${DateFormat.yMMMd('en_US').format(widget.project.last_modified_date)}',
                        color: (MediaQuery.of(context).platformBrightness ==
                                Brightness.dark)
                            ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                            : Platform.isAndroid ? Colors.black : CupertinoColors.black),
                    textGenerator(
                        context,
                        (widget.project.proposed_completion_date
                                .isBefore(DateTime.now())
                            ? 'Ready to move in'
                            : 'Ready by ${DateFormat.yMMM('en_US').format(widget.project.proposed_completion_date)}'),
                        color: (MediaQuery.of(context).platformBrightness ==
                                Brightness.dark)
                            ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                            : Platform.isAndroid ? Colors.black : CupertinoColors.black),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  ])
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String priceRange() {
    String priceText = '';
    if (widget.project.min_price == 0.0 && widget.project.max_price == 0.0) {
      priceText = 'Price on request';
    } else if (widget.project.min_price != 0.0 &&
        widget.project.max_price != 0.0) {
      priceText =
          '${widget.project.min_price} L to ${widget.project.max_price} L';
    } else if (widget.project.min_price != 0.0 &&
        widget.project.max_price == 0.0) {
      priceText = '${widget.project.min_price} L onwards';
    } else if (widget.project.min_price == 0.0 &&
        widget.project.max_price != 0.0) {
      priceText = 'Upto ${widget.project.max_price} L';
    }
    return priceText;
  }

  // getLikedProjects() async {
  //   final likedProjectsNotifier = Provider.of<LikedProjectsNotifier>(context, listen: false);
  //   setState(() {
  //     isLoading = true;
  //   });
  //   likedProjectsNotifier.getLikedProjects(context).whenComplete(() {
  //     if(likedProjectsNotifier.likedProjectsList != null) {
  //       if(likedProjectsNotifier.likedProjectsList.contains(widget.project)){
  //         likedProjectsNotifier.isLiked = true;
  //       } else {
  //         likedProjectsNotifier.isLiked = false;
  //       }
  //     } else {
  //       likedProjectsNotifier.isLiked = false;
  //     }
  //     setState(() {
  //       isLoading = false;
  //     });
  //   });
  //   // Future.delayed(const Duration(milliseconds: 3000), (){
  //
  //   // })
  // }

  Text textGenerator(BuildContext context, String text,
      {Color? color, FontWeight? fontWeight, bool? isTrim}) {
    String finalText;
    if (isTrim != null && isTrim == true) {
      if (text.length < 25) {
        finalText = text;
      } else {
        finalText = "${text.substring(0, 25)}...";
      }
    } else {
      finalText = text;
    }
    return Text(finalText,
        style: CustomTextStyles.getBodySmall(null, (MediaQuery.of(context).platformBrightness ==
            Brightness.dark)
            ? Platform.isAndroid ? Colors.white : CupertinoColors.white
            : Platform.isAndroid ? Colors.black : CupertinoColors.black, FontWeight.bold, 10.5));
  }
}
