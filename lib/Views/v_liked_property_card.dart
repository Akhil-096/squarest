import 'dart:io';
import 'package:squarest/Views/v_know_more_mem_plan.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:transparent_image/transparent_image.dart';
import '../Models/m_resale_property.dart';
import '../Services/s_liked_projects_notifier.dart';
import '../Services/s_resale_property_notifier.dart';
import '../Services/s_user_profile_notifier.dart';
import '../Utils/u_constants.dart';
import '../Utils/u_custom_styles.dart';

class LikedPropertyCard extends StatefulWidget {
  final ResalePropertyModel resalePropertyModel;

  const LikedPropertyCard({
    Key? key,
    required this.resalePropertyModel,
  }) : super(key: key);

  @override
  State<LikedPropertyCard> createState() => _LikedPropertyCardState();
}

class _LikedPropertyCardState extends State<LikedPropertyCard> {
  ScreenshotController screenshotController = ScreenshotController();

  // String imageUrl = '';
  List<String> imageUrls = [];
  LikeButton? likeButton;

  @override
  void initState() {
    super.initState();
    loadImages(widget.resalePropertyModel.address, widget.resalePropertyModel.name).whenComplete(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(controller: screenshotController, child: contentWidget());
  }

  Card contentWidget() {
    final userProfileNotifier = Provider.of<UserProfileNotifier>(context);
    final likedProjectsNotifier = Provider.of<LikedProjectsNotifier>(context);
    final resalePropertyNotifier = Provider.of<ResalePropertyNotifier>(context);

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
                      if (imageUrls.isEmpty)
                        Container(
                          color: Platform.isAndroid ? Colors.black : CupertinoColors.black,
                          child: Opacity(
                            opacity: 0.6,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Image.asset('assets/images/default.png'),
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
                                imageUrl: imageUrls.first,
                                placeholder: (context, url) =>
                                    Image.memory(kTransparentImage),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                fadeInDuration: const Duration(seconds: 1),
                                fadeOutDuration: const Duration(seconds: 1),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: (widget.resalePropertyModel
                      .posted_by_user_id !=
                      userProfileNotifier
                          .userProfileModel.id &&
                          (resalePropertyNotifier.memPlans.isEmpty ||
                              (resalePropertyNotifier.memPlans.isNotEmpty &&
                                  !DateTime.now().isBefore(
                                      resalePropertyNotifier
                                          .memPlans[0].ending_on))))
                      ? MediaQuery.of(context).size.height * 0.015
                      : MediaQuery.of(context).size.height * 0.035,
                  left: MediaQuery.of(context).size.width * 0.025,
                  child: FirebaseAuth.instance.currentUser?.uid == null
                      ? const SizedBox()
                  // Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Container(
                  //             padding: const EdgeInsets.all(5),
                  //             decoration: BoxDecoration(
                  //                 border: Border.all(color: Colors.black),
                  //                 borderRadius: const BorderRadius.all(Radius.circular(15))
                  //             ),
                  //             child: Column(children: [
                  //               Text(
                  //                 'To view property name and\naddress, become a member.\nStarting ₹ 5,000/- only',
                  //                 style: CustomTextStyles.getBodySmall(
                  //                     CustomShadows.textNormal,
                  //                     Colors.white,
                  //                     null,
                  //                     14),
                  //               ),
                  //               const SizedBox(
                  //                 height: 5,
                  //               ),
                  //               SizedBox(
                  //                 width: 180,
                  //                 child: GestureDetector(
                  //                   onTap: () {},
                  //                   child: const Card(
                  //                     color: globalColor,
                  //                     child: Padding(
                  //                         padding: EdgeInsets.all(10),
                  //                         child: Center(
                  //                           child: Text(
                  //                             'Join Now',
                  //                             style: TextStyle(color: Colors.white),
                  //                           ),
                  //                         )),
                  //                   ),
                  //                 ),
                  //               ),
                  //             ],),
                  //           ),
                  //           const SizedBox(
                  //             height: 1,
                  //           ),
                  //           Text(
                  //             widget.resalePropertyModel.locality ?? '',
                  //             style: CustomTextStyles.getBodySmall(
                  //                 CustomShadows.textNormal,
                  //                 Colors.white,
                  //                 null,
                  //                 14),
                  //           ),
                  //           Text(
                  //             (widget.resalePropertyModel.city == null ||
                  //                     widget.resalePropertyModel.pincode ==
                  //                         null)
                  //                 ? ''
                  //                 : '${widget.resalePropertyModel.city}, ${widget.resalePropertyModel.pincode}',
                  //             style: CustomTextStyles.getBodySmall(
                  //                 CustomShadows.textNormal,
                  //                 Colors.white,
                  //                 null,
                  //                 14),
                  //           ),
                  //         ],
                  //       )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (widget.resalePropertyModel
                                .posted_by_user_id !=
                                userProfileNotifier
                                    .userProfileModel.id && (resalePropertyNotifier.memPlans.isEmpty ||
                                    (resalePropertyNotifier
                                            .memPlans.isNotEmpty &&
                                        !DateTime.now().isBefore(
                                            resalePropertyNotifier
                                                .memPlans[0].ending_on))))
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            border: Border.all(color: Platform.isAndroid ? Colors.black : CupertinoColors.black),
                                            borderRadius: const BorderRadius.all(Radius.circular(15))
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              'To view property name and\naddress, become a member.\nStarting ₹ 5,999/- only',
                                              style: CustomTextStyles.getBodySmall(
                                                  CustomShadows.textNormal,
                                                  Platform.isAndroid ? Colors.white : CupertinoColors.white,
                                                  null,
                                                  14),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            SizedBox(
                                              width: 180,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => const KnowMoreMemPlan(isComingFromJoinNow: true, isComingFromKnowMore: false,)),
                                                  );
                                                },
                                                child: Card(
                                                  color: globalColor,
                                                  child: Padding(
                                                      padding: const EdgeInsets.all(10),
                                                      child: Center(
                                                        child: Text(
                                                          'Join Now',
                                                          style: TextStyle(
                                                              color: Platform.isAndroid ? Colors.white : CupertinoColors.white),
                                                        ),
                                                      )),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 1,
                                      ),
                                      Text(
                                        widget.resalePropertyModel.locality ??
                                            '',
                                        style: CustomTextStyles.getBodySmall(
                                            CustomShadows.textNormal,
                                            Platform.isAndroid ? Colors.white : CupertinoColors.white,
                                            null,
                                            14),
                                      ),
                                      Text(
                                        (widget.resalePropertyModel.city ==
                                                    null ||
                                                widget.resalePropertyModel
                                                        .pincode ==
                                                    null)
                                            ? ''
                                            : '${widget.resalePropertyModel.city}, ${widget.resalePropertyModel.pincode}',
                                        style: CustomTextStyles.getBodySmall(
                                            CustomShadows.textNormal,
                                            Platform.isAndroid ? Colors.white : CupertinoColors.white,
                                            null,
                                            14),
                                      ),
                                    ],
                                  )
                                : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 180,
                                        child: (widget.resalePropertyModel
                                                        .posted_by_user_id ==
                                                    userProfileNotifier
                                                        .userProfileModel.id)
                                            ? Text(
                                                widget.resalePropertyModel.name,
                                                maxLines: 1,
                                                style: CustomTextStyles
                                                    .getProjectNameFont(
                                                        CustomShadows
                                                            .textNormal,
                                                    Platform.isAndroid ? Colors.white : CupertinoColors.white,
                                                        16),
                                                softWrap: true,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : Text(
                                                widget.resalePropertyModel.name,
                                                maxLines: 1,
                                                style: CustomTextStyles
                                                    .getProjectNameFont(
                                                        CustomShadows
                                                            .textNormal,
                                                    Platform.isAndroid ? Colors.white : CupertinoColors.white,
                                                        16),
                                                softWrap: true,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                      ),
                                      // const SizedBox(
                                      //   height: 5,
                                      // ),
                                      SizedBox(
                                        width: 180,
                                        child: (widget.resalePropertyModel
                                                        .posted_by_user_id ==
                                                    userProfileNotifier
                                                        .userProfileModel.id)
                                            ? Text(
                                                widget.resalePropertyModel
                                                    .address,
                                                style: CustomTextStyles.getBody(
                                                    CustomShadows.textNormal,
                                                    Platform.isAndroid ? Colors.white : CupertinoColors.white,
                                                    16),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : Text(
                                                widget.resalePropertyModel
                                                    .address,
                                                style: CustomTextStyles.getBody(
                                                    CustomShadows.textNormal,
                                                    Platform.isAndroid ? Colors.white : CupertinoColors.white,
                                                    16),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                      ),
                                      // if(widget.project.project_village.isNotEmpty)
                                      Text(
                                        widget.resalePropertyModel.locality ??
                                            '',
                                        style: CustomTextStyles.getBodySmall(
                                            CustomShadows.textNormal,
                                            Platform.isAndroid ? Colors.white : CupertinoColors.white,
                                            null,
                                            14),
                                      ),
                                      // if(widget.project.project_district.isNotEmpty)
                                      Text(
                                        (widget.resalePropertyModel.city ==
                                                    null ||
                                                widget.resalePropertyModel
                                                        .pincode ==
                                                    null)
                                            ? ''
                                            : '${widget.resalePropertyModel.city}, ${widget.resalePropertyModel.pincode}',
                                        style: CustomTextStyles.getBodySmall(
                                            CustomShadows.textNormal,
                                            Platform.isAndroid ? Colors.white : CupertinoColors.white,
                                            null,
                                            14),
                                      ),
                                    ],
                                  )
                          ],
                        ),
                ),
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.090,
                  right: MediaQuery.of(context).size.width * 0.025,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price: ${widget.resalePropertyModel.price} L',
                        textAlign: TextAlign.center,
                        style: CustomTextStyles.getBodyBold(
                            CustomShadows.textNormal, Platform.isAndroid ? Colors.white : CupertinoColors.white, 16),
                      ),
                      //image: Image.asset('assets/images/img.gif'),
                      // SizedBox(
                      //     height: MediaQuery.of(context).size.height * 0.0033),
                      Text(
                        widget.resalePropertyModel.type
                            ? 'Posted by Owner'
                            : 'Posted by Agent',
                        textAlign: TextAlign.center,
                        style: CustomTextStyles.getBody(
                            CustomShadows.textNormal, Platform.isAndroid ? Colors.white : CupertinoColors.white, 16),
                      )
                    ],
                  ),
                ),
                if (imageUrls.isNotEmpty)
                  Positioned(
                    bottom: 5,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                          borderRadius: BorderRadius.circular(50)),
                      child: Text("${imageUrls.length} images",
                          style: TextStyle(
                            color: Platform.isAndroid ? Colors.white : CupertinoColors.white,
                          )),
                    ),
                  ),
                Positioned(
                    top: 8,
                    left: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '${NumberFormat.compactCurrency(
                              decimalDigits: 2,
                              symbol: '',
                            ).format(1000).replaceAll(".00", "")} views',
                            style: TextStyle(
                                color: Platform.isAndroid ? Colors.white : CupertinoColors.white,
                                fontWeight: FontWeight.bold)),
                        Text('Listed 10 days ago',
                            style: TextStyle(
                                color: Platform.isAndroid ? Colors.white : CupertinoColors.white,
                                fontWeight: FontWeight.bold)),
                      ],
                    )),
                if (!widget.resalePropertyModel.type)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Text('Bungalow',
                        style: CustomTextStyles.getBodySmall(
                            CustomShadows.textNormal,
                            Platform.isAndroid ? Colors.white : CupertinoColors.white,
                            FontWeight.bold,
                            14)),
                  ),
                if ((FirebaseAuth.instance.currentUser?.uid != null &&
                    (widget.resalePropertyModel.posted_by_user_id ==
                        userProfileNotifier.userProfileModel.id)))
                  Positioned(
                    top: 40,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        // height: 35,
                        // width: 150,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            backgroundColor:
                                widget.resalePropertyModel.status == 0
                                    ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                    : widget.resalePropertyModel.status == 1
                                        ? Platform.isAndroid ? Colors.orange : CupertinoColors.systemOrange
                                        : Platform.isAndroid ? Colors.green : CupertinoColors.systemGreen,
                          ),
                          child: Text(
                            widget.resalePropertyModel.status == 0
                                ? "Under review"
                                : widget.resalePropertyModel.status == 1
                                    ? 'Changes required'
                                    : 'Live',
                            maxLines: 1,
                            style: TextStyle(
                              color: widget.resalePropertyModel.status == 0
                                  ? Platform.isAndroid ? Colors.black : CupertinoColors.black
                                  : widget.resalePropertyModel.status == 1
                                      ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                      : Platform.isAndroid ? Colors.white : CupertinoColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                // Positioned(
                //   right: 50,
                //   top: 12,
                //   child: Text(widget.resalePropertyModel.type ? 'Type: Flat' : 'Type: Bungalow', style: CustomTextStyles.getBodySmall(
                //       CustomShadows.textNormal, Colors.white, FontWeight.bold, 14)),
                // ),
                Positioned(
                    right: 8,
                    bottom: 8,
                    child: StreamBuilder(
                        stream: FirebaseAuth.instance.authStateChanges(),
                        builder: (ctx, userSnapshot) {
                          likeButton = LikeButton(
                            size: 20,
                            isLiked: likedProjectsNotifier.isResaleLiked,
                            likeBuilder: (isLiked) {
                              return isLiked
                                  ? Icon(
                                Platform.isAndroid ? Icons.favorite : CupertinoIcons.suit_heart_fill,
                                      color: isLiked ? Platform.isAndroid ? Colors.red : CupertinoColors.systemRed : null,
                                      size: 20,
                                    )
                                  : Icon(
                                Platform.isAndroid ? Icons.favorite_border_outlined : CupertinoIcons.suit_heart,
                                      color: Platform.isAndroid ? Colors.white : CupertinoColors.white,
                                      size: 20,
                                    );
                            },
                            // circleColor: const CircleColor(
                            //   start: Colors.amber,
                            //   end: Colors.redAccent,
                            // ),
                            // bubblesColor: const BubblesColor(
                            //   dotPrimaryColor: Colors.amber,
                            //   dotSecondaryColor: Colors.redAccent,
                            // ),
                            onTap: !userSnapshot.hasData
                                ? (_) async {
                                    Fluttertoast.showToast(
                                      msg: 'Please login to save a property',
                                      backgroundColor: Platform.isAndroid ? Colors.white : CupertinoColors.white,
                                      textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                    );
                                    return null;
                                  }
                                : (isLiked) async {
                                    likedProjectsNotifier.isResaleLiked =
                                        isLiked;
                                    if (!likedProjectsNotifier.isResaleLiked) {
                                      await likedProjectsNotifier
                                          .insertResaleLikes(
                                              (userProfileNotifier
                                                      .userProfileModel.id)
                                                  .toInt(),
                                              widget.resalePropertyModel.id);
                                      // Future.delayed(const Duration(milliseconds: 2000),(){
                                      // });
                                    }
                                    if (likedProjectsNotifier.isResaleLiked) {
                                      await likedProjectsNotifier
                                          .deleteResaleLikes(
                                              (userProfileNotifier
                                                      .userProfileModel.id)
                                                  .toInt(),
                                              widget.resalePropertyModel.id)
                                          .whenComplete(() async {
                                        likedProjectsNotifier
                                            .getLikedResaleProperties(context);
                                      });
                                      // Future.delayed(const Duration(milliseconds: 2000),(){
                                      //   likedProjectsNotifier.getLikedProjects(context);
                                      // });
                                    }
                                    return !isLiked;
                                  },
                          );
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
                                  child: likeButton),
                              const SizedBox(
                                width: 10,
                              ),
                              // ShareIconWidget(project: widget.project),
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
                                            await imagePath.writeAsBytes(image);
                                            await Share.shareXFiles(
                                                [XFile(imagePath.path)],
                                                text:
                                                    'Check it out on squarest app\n\nDownload from Google Play Store: https://play.google.com/store/apps/details?id=com.apartmint.squarest',
                                                subject:
                                                    'squarest - ${widget.resalePropertyModel.locality}, ${widget.resalePropertyModel.city}, ${widget.resalePropertyModel.pincode}');
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
                                      borderRadius: BorderRadius.circular(50)),
                                  child: Icon(
                                    Platform.isAndroid ? Icons.share : CupertinoIcons.share,
                                    color: Platform.isAndroid ? Colors.white : CupertinoColors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          );
                        })),
              ],
            ),
          ),
          Container(
            color:
                (MediaQuery.of(context).platformBrightness == Brightness.dark)
                    ? Colors.grey[900]
                    : Platform.isAndroid ? Colors.white : CupertinoColors.white,
            height: MediaQuery.of(context).size.height * 0.10,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.02),
                        child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              '${widget.resalePropertyModel.bhk} BHK',
                              style: CustomTextStyles.getBodySmall(
                                  null,
                                  (MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark)
                                      ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                      : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                  FontWeight.bold,
                                  14),
                            )),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.02),
                        child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              '${widget.resalePropertyModel.area} sq. ft.',
                              style: CustomTextStyles.getBodySmall(
                                  null,
                                  (MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark)
                                      ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                      : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                  FontWeight.bold,
                                  14),
                            )),
                      ),
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
                          child: Text(
                            '${widget.resalePropertyModel.age} years old',
                            style: CustomTextStyles.getBodySmall(
                                null,
                                (MediaQuery.of(context).platformBrightness ==
                                        Brightness.dark)
                                    ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                    : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                FontWeight.bold,
                                14),
                          )),
                    ),
                    if (widget.resalePropertyModel.type)
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.02),
                        child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              '${widget.resalePropertyModel.floor}/${widget.resalePropertyModel.total_floors} floor',
                              style: CustomTextStyles.getBodySmall(
                                  null,
                                  (MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark)
                                      ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                      : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                  FontWeight.bold,
                                  14),
                            )),
                      ),
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

  Future<void> loadImages(String locationText, String name) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('resale_properties')
        .child('$locationText$name')
        .child('property-photos');
    final listResult = await storageRef.listAll();
    for (var item in listResult.items) {
      imageUrls = imageUrls..add(await item.getDownloadURL());
    }
  }
}
