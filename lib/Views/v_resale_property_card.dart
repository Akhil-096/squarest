import 'dart:async';
import 'dart:io';
import 'package:animations/animations.dart';
import 'package:squarest/Services/s_autocomplete_notifier.dart';
import 'package:squarest/Services/s_resale_property_notifier.dart';
import 'package:squarest/Utils/u_constants.dart';
import 'package:squarest/Utils/u_custom_styles.dart';
import 'package:squarest/Views/v_know_more_mem_plan.dart';
import 'package:squarest/Views/v_resale_property_details.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';
import '../Models/m_resale_property.dart';
import '../Services/s_liked_projects_notifier.dart';
import '../Services/s_user_profile_notifier.dart';

class ResalePropertyCard extends StatefulWidget {
  final ResalePropertyModel resalePropertyModel;
  final bool isComingFromMapOrList;

  const ResalePropertyCard(
      {Key? key,
      required this.resalePropertyModel,
      required this.isComingFromMapOrList})
      : super(key: key);

  @override
  State<ResalePropertyCard> createState() => _ResalePropertyCardState();
}

class _ResalePropertyCardState extends State<ResalePropertyCard> {
  // final PageController _controller = PageController();
  ScreenshotController screenshotController = ScreenshotController();
  List<String> imageUrls = [];
  LikeButton? likeButton;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    loadImages(widget.resalePropertyModel.address, widget.resalePropertyModel.name).whenComplete(() {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
    getLikedResaleProperties();
  }

  @override
  Widget build(BuildContext context) {
    final likedProjectsNotifier = Provider.of<LikedProjectsNotifier>(context);
    return (isLoading || likedProjectsNotifier.isResaleLoading)
        ? const ProjectCardShimmer()
        : Screenshot(
            controller: screenshotController, child: contentWidget(imageUrls));
  }

  Column contentWidget(List<String> imgUrl) {
    final userProfileNotifier = Provider.of<UserProfileNotifier>(context);
    final likedProjectsNotifier = Provider.of<LikedProjectsNotifier>(context);
    final resalePropertyNotifier = Provider.of<ResalePropertyNotifier>(context);

    final resaleNotifier =
        Provider.of<ResalePropertyNotifier>(context, listen: false);
    final autocompleteNotifier =
        Provider.of<AutocompleteNotifier>(context, listen: false);
    // final width = MediaQuery.of(context).size.width;
    // final height = MediaQuery.of(context).size.height;
    // print(height);
    // print(width);
    // LikedProjectsService likedProjectsService = LikedProjectsService();
    // final date = DateTime.now();
    return Column(
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
                child: OpenContainer(
                  transitionType: ContainerTransitionType.fadeThrough,
                  transitionDuration: const Duration(milliseconds: 500),
                  onClosed: (_) {
                    if (widget.isComingFromMapOrList) {
                      getLikedResaleProperties();
                      autocompleteNotifier.closeResaleBottomSheet();
                    } else {
                      resaleNotifier.closeBottomSheet();
                    }
                    // imageUrls.clear();
                    imgUrl.clear();
                  },
                  closedBuilder: (ctx, openContainer) {
                    return InkWell(
                      onTap: openContainer,
                      child: PageView(
                        children: [
                          if (imgUrl.isEmpty)
                            Container(
                              color: Platform.isAndroid ? Colors.black : CupertinoColors.black,
                              child: Opacity(
                                opacity: 0.6,
                                child: FittedBox(
                                  fit: BoxFit.fill,
                                  child:
                                      Image.asset('assets/images/default.png'),
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
                                    width: 200,
                                    memCacheHeight: (200 *
                                            MediaQuery.of(context)
                                                .devicePixelRatio)
                                        .round(),
                                    memCacheWidth: (200 *
                                            MediaQuery.of(context)
                                                .devicePixelRatio)
                                        .round(),
                                    imageUrl: imgUrl.first,
                                    placeholder: (context, url) =>
                                        Image.memory(kTransparentImage),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                    fadeInDuration:
                                        const Duration(milliseconds: 10),
                                    fadeOutDuration:
                                        const Duration(milliseconds: 10),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                  openBuilder: (_, __) {
                    FocusScope.of(context).unfocus();
                    return ChangeNotifierProvider.value(
                      value: widget.resalePropertyModel,
                      child: ResalePropertyDetails(
                        resalePropertyModel: widget.resalePropertyModel,
                        isComingFromList: false,
                        // imgUrl: imgUrl,
                      ),
                    );
                  },
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
                        Text(
                          '${NumberFormat.compactCurrency(
                            decimalDigits: 2,
                            symbol: '',
                          ).format(1000).replaceAll(".00", "")} views',
                          style: CustomTextStyles.getBodySmall(
                              CustomShadows.textNormal, Platform.isAndroid ? Colors.white : CupertinoColors.white, null, 14),
                        ),
                        Text(
                          'Listed 0 days ago',
                          style: CustomTextStyles.getBodySmall(
                              CustomShadows.textNormal, Platform.isAndroid ? Colors.white : CupertinoColors.white, null, 14),
                        ),
                      ],
                    )),
              ),
              if (!widget.resalePropertyModel.type)
                Positioned(
                  right: 50,
                  top: 12,
                  child: Text('Bungalow',
                      style: CustomTextStyles.getBodySmall(
                          CustomShadows.textNormal,
                          Platform.isAndroid ? Colors.white : CupertinoColors.white,
                          FontWeight.bold,
                          14)),
                ),
              Positioned(
                right: 8,
                top: 8,
                child: GestureDetector(
                  onTap: () {
                    if (widget.isComingFromMapOrList) {
                      autocompleteNotifier.closeResaleBottomSheet();
                    } else {
                      resaleNotifier.closeBottomSheet();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                        borderRadius: BorderRadius.circular(50)),
                    child: Icon(
                      Platform.isAndroid ? Icons.cancel_outlined : CupertinoIcons.clear_circled,
                      color: Platform.isAndroid ? Colors.white : CupertinoColors.white,
                      size: 20.0,
                    ),
                  ),
                ),
              ),
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
                                  // Navigator.of(context).push(
                                  //     MaterialPageRoute(
                                  //         builder: (ctx) =>
                                  //         const LoginScreen(
                                  //           isComingFromLike: true,
                                  //           isComingFromShare: false,
                                  //           isAccountScreen: false,
                                  //           isComingFromHomeLoan: false,
                                  //         )));
                                }
                              : (isLiked) async {
                                  likedProjectsNotifier.isResaleLiked = isLiked;
                                  if (!isLiked) {
                                    await likedProjectsNotifier
                                        .insertResaleLikes(
                                            (userProfileNotifier
                                                    .userProfileModel.id)
                                                .toInt(),
                                            widget.resalePropertyModel.id)
                                        .whenComplete(() {
                                      getLikedResaleProperties();
                                    });
                                  }
                                  if (isLiked) {
                                    await likedProjectsNotifier
                                        .deleteResaleLikes(
                                            (userProfileNotifier
                                                    .userProfileModel.id)
                                                .toInt(),
                                            widget.resalePropertyModel.id)
                                        .whenComplete(() {
                                      getLikedResaleProperties();
                                    });
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
                                      double pixelRatio = MediaQuery.of(context)
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
              if ((FirebaseAuth.instance.currentUser?.uid != null &&
                  (widget.resalePropertyModel.posted_by_user_id ==
                      userProfileNotifier.userProfileModel.id)))
                Positioned(
                  top: 45,
                  right: MediaQuery.of(context).size.width * 0.005,
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
              Positioned(
                bottom: (widget.resalePropertyModel
                    .posted_by_user_id !=
                    userProfileNotifier
                        .userProfileModel.id && (FirebaseAuth.instance.currentUser?.uid == null ||
                        (resalePropertyNotifier.memPlans.isEmpty ||
                            (resalePropertyNotifier.memPlans.isNotEmpty &&
                                !DateTime.now().isBefore(resalePropertyNotifier
                                    .memPlans[0].ending_on)))))
                    ? MediaQuery.of(context).size.height * 0.005
                    : MediaQuery.of(context).size.height * 0.035,
                left: MediaQuery.of(context).size.width * 0.025,
                child: FirebaseAuth.instance.currentUser?.uid == null
                    ? Column (
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            // margin: const EdgeInsets.only(top: 5),
                            // elevation: 4,
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
                                              style: TextStyle(color: Platform.isAndroid ? Colors.white : CupertinoColors.white),
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
                            widget.resalePropertyModel.locality ?? '',
                            style: CustomTextStyles.getBodySmall(
                                CustomShadows.textNormal,
                                Platform.isAndroid ? Colors.white : CupertinoColors.white,
                                null,
                                14),
                          ),
                          Text(
                            (widget.resalePropertyModel.city == null ||
                                    widget.resalePropertyModel.pincode == null)
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
                          (widget.resalePropertyModel
                              .posted_by_user_id !=
                              userProfileNotifier
                                  .userProfileModel.id && (resalePropertyNotifier.memPlans.isEmpty ||
                                  (resalePropertyNotifier.memPlans.isNotEmpty &&
                                      !DateTime.now().isBefore(
                                          resalePropertyNotifier
                                              .memPlans[0].ending_on))))
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                      widget.resalePropertyModel.locality ?? '',
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
                                      child: widget.resalePropertyModel
                                                  .posted_by_user_id ==
                                              userProfileNotifier
                                                  .userProfileModel.id
                                          ? Text(
                                              widget.resalePropertyModel.name,
                                              maxLines: 1,
                                              style: CustomTextStyles
                                                  .getProjectNameFont(
                                                      CustomShadows.textNormal,
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
                                                      CustomShadows.textNormal,
                                                  Platform.isAndroid ? Colors.white : CupertinoColors.white,
                                                      16),
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                    ),
                                    SizedBox(
                                      width: 180,
                                      child: widget.resalePropertyModel
                                                  .posted_by_user_id ==
                                              userProfileNotifier
                                                  .userProfileModel.id
                                          ? Text(
                                              widget
                                                  .resalePropertyModel.address,
                                              style: CustomTextStyles.getBody(
                                                  CustomShadows.textNormal,
                                                  Platform.isAndroid ? Colors.white : CupertinoColors.white,
                                                  16),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          : Text(
                                              widget
                                                  .resalePropertyModel.address,
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
                                      widget.resalePropertyModel.locality ?? '',
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
              if (imgUrl.isNotEmpty)
                Positioned(
                  bottom: 5,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                        borderRadius: BorderRadius.circular(50)),
                    child: Text("${imgUrl.length} images",
                        style: TextStyle(
                          color: Platform.isAndroid ? Colors.white : CupertinoColors.white,
                        )),
                  ),
                ),
            ],
          ),
        ),
        OpenContainer(
          transitionType: ContainerTransitionType.fadeThrough,
          transitionDuration: const Duration(milliseconds: 500),
          onClosed: (_) {
            if (widget.isComingFromMapOrList) {
              getLikedResaleProperties();
              autocompleteNotifier.closeResaleBottomSheet();
            } else {
              resaleNotifier.closeBottomSheet();
            }
            imgUrl.clear();
          },
          closedBuilder: (ctx, openContainer) {
            return InkWell(
              onTap: openContainer,
              child: Container(
                color: (MediaQuery.of(context).platformBrightness ==
                        Brightness.dark)
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
                        children: [
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.01),
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
                                      (MediaQuery.of(context)
                                                  .platformBrightness ==
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
                                      (MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.dark)
                                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                          : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                      FontWeight.bold,
                                      14),
                                )),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.01),
                        ],
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.01),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height *
                                          0.02),
                              child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Text(
                                    '${widget.resalePropertyModel.age} years old',
                                    style: CustomTextStyles.getBodySmall(
                                        null,
                                        (MediaQuery.of(context)
                                                    .platformBrightness ==
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
                                        MediaQuery.of(context).size.height *
                                            0.02),
                                child: FittedBox(
                                    fit: BoxFit.fitWidth,
                                    child: Text(
                                      '${widget.resalePropertyModel.floor}/${widget.resalePropertyModel.total_floors} floor',
                                      style: CustomTextStyles.getBodySmall(
                                          null,
                                          (MediaQuery.of(context)
                                                      .platformBrightness ==
                                                  Brightness.dark)
                                              ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                              : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                          FontWeight.bold,
                                          14),
                                    )),
                              ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.01),
                          ])
                    ],
                  ),
                ),
              ),
            );
          },
          openBuilder: (_, __) {
            FocusScope.of(context).unfocus();
            return ChangeNotifierProvider.value(
              value: widget.resalePropertyModel,
              child: ResalePropertyDetails(
                resalePropertyModel: widget.resalePropertyModel,
                isComingFromList: false,
                // imgUrl: imgUrl,
              ),
            );
          },
        ),
      ],
    );
  }

  getLikedResaleProperties() async {
    final likedProjectsNotifier =
        Provider.of<LikedProjectsNotifier>(context, listen: false);
    likedProjectsNotifier.getLikedResaleProperties(context).whenComplete(() {
      if (likedProjectsNotifier.likedResalePropertyList.isNotEmpty) {
        if (likedProjectsNotifier.likedResalePropertyList
            .where((element) => element.id == widget.resalePropertyModel.id)
            .toList()
            .isNotEmpty) {
          likedProjectsNotifier.isResaleLiked = true;
        } else {
          likedProjectsNotifier.isResaleLiked = false;
        }
      } else {
        likedProjectsNotifier.isResaleLiked = false;
      }
    });
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

class ProjectCardShimmer extends StatelessWidget {
  const ProjectCardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 1.0),
        child: Shimmer.fromColors(
          baseColor:
              (MediaQuery.of(context).platformBrightness == Brightness.dark)
                  ? Colors.grey.shade700
                  : Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: ListView.builder(
            itemBuilder: (_, __) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        height: 220,
                        color: Colors.grey.shade300,
                      ),
                    ],
                  ),
                )
              ],
            ),
            itemCount: 1,
          ),
        ),
      ),
    );
  }
}
