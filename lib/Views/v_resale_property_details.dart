import 'dart:io';
import 'package:squarest/Views/v_know_more_mem_plan.dart';
import 'package:squarest/Views/v_project_details.dart';
import 'package:squarest/Views/v_resale_contact.dart';
import 'package:squarest/Views/v_resale_property_screen_1.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:transparent_image/transparent_image.dart';
import '../Models/m_resale_property.dart';
import '../Services/s_autocomplete_notifier.dart';
import '../Services/s_emi_notifier.dart';
import '../Services/s_liked_projects_notifier.dart';
import '../Services/s_resale_property_notifier.dart';
import '../Services/s_user_profile_notifier.dart';
import '../Utils/u_constants.dart';
import '../Utils/u_custom_styles.dart';


class ResalePropertyDetails extends StatefulWidget {
  final ResalePropertyModel resalePropertyModel;
  final bool isComingFromList;

  const ResalePropertyDetails(
      {required this.resalePropertyModel,
      required this.isComingFromList,
      Key? key})
      : super(key: key);

  @override
  State<ResalePropertyDetails> createState() => _ResalePropertyDetailsState();
}

class _ResalePropertyDetailsState extends State<ResalePropertyDetails> {
  ScreenshotController screenshotController = ScreenshotController();
  final PageController _controller = PageController();
  int currentImage = 1;
  List<String> imageUrls = [];
  List<String> docsUrls = [];
  final form = GlobalKey<FormState>();
  late TextEditingController loanController;

  @override
  void initState() {
    super.initState();
    loanController = TextEditingController(
        text: widget.resalePropertyModel.price.toString());
    final emiNotifier = Provider.of<EmiNotifier>(context, listen: false);
    emiNotifier.loanAmount = widget.resalePropertyModel.price * 100000;
    emiNotifier.calculateMonthlyEmi();
    emiNotifier.calculateEmiPerLac();
    loadImages(
            widget.resalePropertyModel.address, widget.resalePropertyModel.name)
        .whenComplete(() {
      if (mounted) {
        setState(() {});
      }
    });
    loadDocuments(
            widget.resalePropertyModel.address, widget.resalePropertyModel.name)
        .whenComplete(() {
      if (mounted) {
        setState(() {});
      }
    });
    getLikedResaleProperties();
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

  @override
  Widget build(BuildContext context) {
    final userProfileNotifier = Provider.of<UserProfileNotifier>(context);
    final emiNotifier = Provider.of<EmiNotifier>(context);
    final resalePropertyNotifier = Provider.of<ResalePropertyNotifier>(context);
    final autoCompleteNotifier = Provider.of<AutocompleteNotifier>(context);
    final likedProjectsNotifier = Provider.of<LikedProjectsNotifier>(context);
    final resaleProperty = Provider.of<ResalePropertyModel>(context);

    return Screenshot(
      controller: screenshotController,
      child: Scaffold(
        appBar: Platform.isAndroid ? PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: AppBar(
            scrolledUnderElevation: 0.0,
            title: Text(
              'Property details',
              style: CustomTextStyles.getTitle(
                  null,
                  (MediaQuery.of(context).platformBrightness == Brightness.dark)
                      ? Colors.white
                      : Colors.black,
                  null,
                  19),
            ),
            backgroundColor:
            (MediaQuery.of(context).platformBrightness == Brightness.dark)
                ? Colors.grey[900]
                : Colors.white,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.arrow_back,
                size: 35,
              ),
            ),
            automaticallyImplyLeading: false,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 10),
                child: StreamBuilder(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (ctx, userSnapshot) {
                      return Row(
                        children: [
                          LikeButton(
                            size: 30,
                            isLiked: widget.isComingFromList
                                ? resaleProperty.isLiked
                                : likedProjectsNotifier.isResaleLiked,
                            likeBuilder: (isLiked) {
                              return isLiked
                                  ? Icon(
                                Icons.favorite,
                                color: isLiked ? Colors.red : null,
                                size: 30,
                              )
                                  : Icon(
                                Icons.favorite_border_outlined,
                                color: (MediaQuery.of(context)
                                    .platformBrightness ==
                                    Brightness.dark)
                                    ? Colors.white
                                    : Colors.black54,
                                size: 30,
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
                                backgroundColor: Colors.white,
                                textColor: Colors.black,
                              );
                              return null;
                            }
                                : (isLiked) async {
                              // if (kDebugMode) {
                              //   print(userProfileNotifier
                              //       .userProfileModel.id);
                              // }
                              likedProjectsNotifier.isResaleLiked = isLiked;
                              if (!likedProjectsNotifier.isResaleLiked) {
                                if (widget.isComingFromList) {
                                  resaleProperty.toggleLike();
                                }
                                likedProjectsNotifier.insertResaleLikes(
                                    (userProfileNotifier
                                        .userProfileModel.id)
                                        .toInt(),
                                    widget.resalePropertyModel.id);
                                // Future.delayed(const Duration(milliseconds: 2000),(){
                                //   likedProjectsNotifier.getLikedProjects(context);
                                // });
                              }
                              if (likedProjectsNotifier.isResaleLiked) {
                                if (widget.isComingFromList) {
                                  resaleProperty.toggleLike();
                                }
                                likedProjectsNotifier.deleteResaleLikes(
                                    (userProfileNotifier
                                        .userProfileModel.id)
                                        .toInt(),
                                    widget.resalePropertyModel.id);
                                // Future.delayed(const Duration(milliseconds: 2000),(){
                                //   likedProjectsNotifier.getLikedProjects(context);
                                // });
                              }
                              return !isLiked;
                            },
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          GestureDetector(
                            onTap: () {
                              double pixelRatio =
                                  MediaQuery.of(context).devicePixelRatio;
                              screenshotController
                                  .capture(
                                  pixelRatio: pixelRatio,
                                  delay:
                                  const Duration(milliseconds: 10))
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
                            child: Icon(
                              Icons.share_outlined,
                              color: (MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark)
                                  ? Colors.white
                                  : Colors.black54,
                              size: 30,
                            ),
                          ),
                        ],
                      );
                    }),
              ),
            ],
          ),
        ) : CupertinoNavigationBar(
            backgroundColor:
          (MediaQuery.of(context).platformBrightness == Brightness.dark)
              ? Colors.grey[900]
              : CupertinoColors.white,
          trailing: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
            Container(
              margin: const EdgeInsets.only(right: 10),
              child: StreamBuilder(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (ctx, userSnapshot) {
                    return Row(
                      children: [
                        LikeButton(
                          size: 30,
                          isLiked: widget.isComingFromList
                              ? resaleProperty.isLiked
                              : likedProjectsNotifier.isResaleLiked,
                          likeBuilder: (isLiked) {
                            return isLiked
                                ? Icon(
                                   CupertinoIcons.suit_heart_fill,
                                    color: isLiked ? CupertinoColors.systemRed : null,
                                    size: 30,
                                  )
                                : Icon(
                                    CupertinoIcons.suit_heart,
                                    color: (MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.dark)
                                        ? CupertinoColors.white
                                        : CupertinoColors.darkBackgroundGray,
                                    size: 30,
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
                                    backgroundColor: CupertinoColors.white,
                                    textColor: CupertinoColors.black,
                                  );
                                  return null;
                                }
                              : (isLiked) async {
                                  // if (kDebugMode) {
                                  //   print(userProfileNotifier
                                  //       .userProfileModel.id);
                                  // }
                                  likedProjectsNotifier.isResaleLiked = isLiked;
                                  if (!likedProjectsNotifier.isResaleLiked) {
                                    if (widget.isComingFromList) {
                                      resaleProperty.toggleLike();
                                    }
                                    likedProjectsNotifier.insertResaleLikes(
                                        (userProfileNotifier
                                                .userProfileModel.id)
                                            .toInt(),
                                        widget.resalePropertyModel.id);
                                    // Future.delayed(const Duration(milliseconds: 2000),(){
                                    //   likedProjectsNotifier.getLikedProjects(context);
                                    // });
                                  }
                                  if (likedProjectsNotifier.isResaleLiked) {
                                    if (widget.isComingFromList) {
                                      resaleProperty.toggleLike();
                                    }
                                    likedProjectsNotifier.deleteResaleLikes(
                                        (userProfileNotifier
                                                .userProfileModel.id)
                                            .toInt(),
                                        widget.resalePropertyModel.id);
                                    // Future.delayed(const Duration(milliseconds: 2000),(){
                                    //   likedProjectsNotifier.getLikedProjects(context);
                                    // });
                                  }
                                  return !isLiked;
                                },
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        GestureDetector(
                          onTap: () {
                                  double pixelRatio =
                                      MediaQuery.of(context).devicePixelRatio;
                                  screenshotController
                                      .capture(
                                          pixelRatio: pixelRatio,
                                          delay:
                                              const Duration(milliseconds: 10))
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
                          child: Icon(
                            CupertinoIcons.share,
                            color: (MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark)
                                ? CupertinoColors.white
                                : CupertinoColors.darkBackgroundGray,
                            size: 30,
                          ),
                        ),
                      ],
                    );
                  }),
            ),
          ],),
        ),
        body: CustomScrollView(scrollDirection: Axis.vertical, slivers: [
          SliverAppBar(
            backgroundColor:
                (MediaQuery.of(context).platformBrightness == Brightness.dark)
                    ? Platform.isAndroid ? Colors.black54 : CupertinoColors.darkBackgroundGray
                    : Platform.isAndroid ? Colors.white : CupertinoColors.white,
            leading: null,
            automaticallyImplyLeading: false,
            expandedHeight: 250.0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child: InkWell(
                        onTap: imageUrls.isEmpty
                            ? () {}
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (ctx) => PhotoList(
                                      imgUrl: imageUrls,
                                    ),
                                  ),
                                );
                              },
                        child: PageView(
                          controller: _controller,
                          onPageChanged: (int page) {
                            setState(() {
                              currentImage = page + 1;
                            });
                          },
                          children: [
                            if (imageUrls.isEmpty)
                              FittedBox(
                                fit: BoxFit.fill,
                                child: Image.asset('assets/images/default.png'),
                              )
                            else
                              ...imageUrls.map(
                                (e) => FittedBox(
                                  fit: BoxFit.fill,
                                  child: CachedNetworkImage(
                                    memCacheHeight: (200 *
                                            MediaQuery.of(context)
                                                .devicePixelRatio)
                                        .round(),
                                    memCacheWidth: (200 *
                                            MediaQuery.of(context)
                                                .devicePixelRatio)
                                        .round(),
                                    imageUrl: e,
                                    placeholder: (context, url) =>
                                        Image.memory(kTransparentImage),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                    fadeInDuration: const Duration(seconds: 1),
                                    fadeOutDuration: const Duration(seconds: 1),
                                  ),
                                ),
                              ),
                          ],
                        )),
                  ),
                  if (imageUrls.isNotEmpty)
                    Positioned(
                      bottom: 5,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                            borderRadius: BorderRadius.circular(50)),
                        child: Text("$currentImage/${imageUrls.length}",
                            style: TextStyle(
                              color: Platform.isAndroid ? Colors.white : CupertinoColors.white,
                            )),
                      ),
                    ),
                ],
              ),
            ),
            // pinned: true,
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '${NumberFormat.compactCurrency(
                              decimalDigits: 2,
                              symbol: '',
                            ).format(1000).replaceAll(".00", "")} views',
                            style: CustomTextStyles.getBodySmall(
                                null,
                                (MediaQuery.of(context).platformBrightness ==
                                        Brightness.dark)
                                    ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                    : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                null,
                                14)),
                        const SizedBox(
                          height: 2,
                        ),
                        Text('Listed 10 days ago',
                            style: CustomTextStyles.getBodySmall(
                                null,
                                (MediaQuery.of(context).platformBrightness ==
                                        Brightness.dark)
                                    ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                    : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                null,
                                14)),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          // height: 140,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FirebaseAuth.instance.currentUser?.uid == null
                                  ? Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Platform.isAndroid ? Colors.black : CupertinoColors.black),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(15))),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // const SizedBox(
                                          //   height: 15,
                                          // ),
                                          Text(
                                            'To view property name and\naddress, become a member.\nStarting ₹ 5,999/- only',
                                            style: CustomTextStyles.getBodySmall(
                                                null,
                                                (MediaQuery.of(context)
                                                            .platformBrightness ==
                                                        Brightness.dark)
                                                    ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                                    : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                                null,
                                                14),
                                          ),
                                          const SizedBox(
                                            height: 7,
                                          ),
                                          SizedBox(
                                            width: 180,
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                      const KnowMoreMemPlan(isComingFromJoinNow: true, isComingFromKnowMore: false,)),
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
                                                            color:
                                                            Platform.isAndroid ? Colors.white : CupertinoColors.white),
                                                      ),
                                                    )),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Column(
                                      children: [
                                        (widget.resalePropertyModel
                                                        .posted_by_user_id !=
                                                    userProfileNotifier
                                                        .userProfileModel.id &&
                                                (resalePropertyNotifier
                                                        .memPlans.isEmpty ||
                                                    (resalePropertyNotifier
                                                            .memPlans
                                                            .isNotEmpty &&
                                                        !DateTime.now().isBefore(
                                                            resalePropertyNotifier
                                                                .memPlans[0]
                                                                .ending_on))))
                                            ? Container(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Platform.isAndroid ? Colors.black : CupertinoColors.black),
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                15))),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // const SizedBox(
                                                    //   height: 15,
                                                    // ),
                                                    Text(
                                                      'To view property name and\naddress,become a member.\nStarting ₹ 5,000/- only',
                                                      style: CustomTextStyles
                                                          .getBodySmall(
                                                              null,
                                                              (MediaQuery.of(context)
                                                                          .platformBrightness ==
                                                                      Brightness
                                                                          .dark)
                                                                  ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                                                  : Platform.isAndroid ? Colors.black : CupertinoColors
                                                                      .black,
                                                              null,
                                                              14),
                                                    ),
                                                    const SizedBox(
                                                      height: 7,
                                                    ),
                                                    SizedBox(
                                                      width: 180,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                    const KnowMoreMemPlan(isComingFromJoinNow: true, isComingFromKnowMore: false,)),
                                                          );
                                                        },
                                                        child: Card(
                                                          color: globalColor,
                                                          child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(10),
                                                              child: Center(
                                                                child: Text(
                                                                  'Join Now',
                                                                  style: TextStyle(
                                                                      color: Platform.isAndroid ? Colors.white : CupertinoColors
                                                                          .white),
                                                                ),
                                                              )),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: 140,
                                                    child: (widget
                                                                .resalePropertyModel
                                                                .posted_by_user_id ==
                                                            userProfileNotifier
                                                                .userProfileModel
                                                                .id)
                                                        ? Text(
                                                            widget
                                                                .resalePropertyModel
                                                                .name,
                                                            maxLines: 2,
                                                            style: CustomTextStyles.getProjectNameFont(
                                                                null,
                                                                (MediaQuery.of(context)
                                                                            .platformBrightness ==
                                                                        Brightness
                                                                            .dark)
                                                                    ? Platform.isAndroid ? Colors.white : CupertinoColors
                                                                        .white
                                                                    : Platform.isAndroid ? Colors.black : CupertinoColors
                                                                        .black,
                                                                16),
                                                            softWrap: true,
                                                          )
                                                        : Text(
                                                            widget
                                                                .resalePropertyModel
                                                                .name,
                                                            maxLines: 2,
                                                            style: CustomTextStyles.getProjectNameFont(
                                                                null,
                                                                (MediaQuery.of(context)
                                                                            .platformBrightness ==
                                                                        Brightness
                                                                            .dark)
                                                                    ? Platform.isAndroid ? Colors.white : CupertinoColors
                                                                        .white
                                                                    : Platform.isAndroid ? Colors.black : CupertinoColors
                                                                        .black,
                                                                16),
                                                            softWrap: true,
                                                          ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  SizedBox(
                                                    width: 150,
                                                    child: (widget
                                                                .resalePropertyModel
                                                                .posted_by_user_id ==
                                                            userProfileNotifier
                                                                .userProfileModel
                                                                .id)
                                                        ? Text(
                                                            widget
                                                                .resalePropertyModel
                                                                .address,
                                                            style: CustomTextStyles.getBodySmall(
                                                                null,
                                                                (MediaQuery.of(context)
                                                                            .platformBrightness ==
                                                                        Brightness
                                                                            .dark)
                                                                    ? Platform.isAndroid ? Colors.white : CupertinoColors
                                                                        .white
                                                                    : Platform.isAndroid ? Colors.black : CupertinoColors
                                                                        .black,
                                                                null,
                                                                14),
                                                            maxLines: 3,
                                                          )
                                                        : Text(
                                                            widget
                                                                .resalePropertyModel
                                                                .address,
                                                            style: CustomTextStyles.getBodySmall(
                                                                null,
                                                                (MediaQuery.of(context)
                                                                            .platformBrightness ==
                                                                        Brightness
                                                                            .dark)
                                                                    ? Platform.isAndroid ? Colors.white : CupertinoColors
                                                                        .white
                                                                    : Platform.isAndroid ? Colors.black : CupertinoColors
                                                                        .black,
                                                                null,
                                                                14),
                                                            maxLines: 3,
                                                          ),
                                                  ),
                                                ],
                                              )
                                      ],
                                    ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                widget.resalePropertyModel.locality ?? '',
                                style: CustomTextStyles.getBodySmall(
                                    null,
                                    (MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.dark)
                                        ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                        : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                    null,
                                    14),
                              ),
                              // const SizedBox(
                              //   height: 5,
                              // ),
                              Text(
                                (widget.resalePropertyModel.city == null ||
                                        widget.resalePropertyModel.pincode ==
                                            null)
                                    ? ''
                                    : '${widget.resalePropertyModel.city}, ${widget.resalePropertyModel.pincode}',
                                style: CustomTextStyles.getBodySmall(
                                    null,
                                    (MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.dark)
                                        ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                        : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                    null,
                                    14),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                '${widget.resalePropertyModel.bhk} BHK',
                                style: CustomTextStyles.getBodySmall(
                                    null,
                                    (MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.dark)
                                        ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                        : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                    null,
                                    14),
                              ),
                              Text(
                                '${widget.resalePropertyModel.area} sq. ft.',
                                style: CustomTextStyles.getBodySmall(
                                    null,
                                    (MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.dark)
                                        ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                        : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                    null,
                                    14),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          // height: 140,
                          child: Column(
                            children: [
                              Text(
                                'Price: ${widget.resalePropertyModel.price} Lakhs',
                                style: CustomTextStyles.getProjectNameFont(
                                    null,
                                    (MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.dark)
                                        ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                        : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                    16),
                                softWrap: true,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Posted by: ${widget.resalePropertyModel.posted_by ? 'Owner' : 'Agent'}',
                                    style: CustomTextStyles.getBodySmall(
                                        null,
                                        (MediaQuery.of(context)
                                                    .platformBrightness ==
                                                Brightness.dark)
                                            ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                            : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                        null,
                                        14),
                                  ),
                                  Text(
                                    widget.resalePropertyModel.type
                                        ? 'Flat'
                                        : 'Bungalow',
                                    style: CustomTextStyles.getBodySmall(
                                        null,
                                        (MediaQuery.of(context)
                                                    .platformBrightness ==
                                                Brightness.dark)
                                            ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                            : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                        null,
                                        14),
                                  ),
                                  const SizedBox(
                                    height: 65,
                                  ),
                                  if (widget.resalePropertyModel.type)
                                    SizedBox(
                                      height: 20,
                                      child: Row(
                                        children: [
                                          Text(
                                              'Floor ${widget.resalePropertyModel.floor} '),
                                          const Text('out of '),
                                          Text(
                                              '${widget.resalePropertyModel.total_floors}')
                                        ],
                                      ),
                                    ),
                                  Text(
                                      '${widget.resalePropertyModel.age} years old',
                                      style: CustomTextStyles.getBodySmall(
                                          null,
                                          (MediaQuery.of(context)
                                                      .platformBrightness ==
                                                  Brightness.dark)
                                              ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                              : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                          null,
                                          14)),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    // const SizedBox(
                    //   height: 20,
                    // ),
                    // Column(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Row(
                    //       children: [
                    //         Container(
                    //             padding:
                    //             const EdgeInsets.all(5),
                    //             decoration: BoxDecoration(
                    //                 color: Colors.yellow,
                    //                 borderRadius:
                    //                 BorderRadius.circular(
                    //                     50)),
                    //             child: const Icon(
                    //                 Icons
                    //                     .description_outlined,
                    //                 size: 16.0,
                    //                 color: Colors.white)),
                    //         // const SizedBox(
                    //         //   width: 5,
                    //         // ),
                    //         // Text(
                    //         //   'Brochure',
                    //         //   style: CustomTextStyles.getH4(
                    //         //       null,
                    //         //       (MediaQuery.of(context)
                    //         //           .platformBrightness ==
                    //         //           Brightness.dark)
                    //         //           ? Colors.white
                    //         //           : Colors.black,
                    //         //       null,
                    //         //       14),
                    //         // )
                    //       ],
                    //     ),
                    //     // const SizedBox(height: 5),
                    //     // if(docsUrls.isNotEmpty)
                    //     //   docsUrls.where((element) => element.contains(".pdf")).toList().isEmpty ?
                    //     //   Container(
                    //     //     height: MediaQuery.of(context)
                    //     //         .size
                    //     //         .height *
                    //     //         0.30,
                    //     //     width: double.infinity,
                    //     //     margin:
                    //     //     const EdgeInsets.only(top: 5),
                    //     //     child: GestureDetector(
                    //     //       onTap: () {
                    //     //         Navigator.push(
                    //     //           context,
                    //     //           MaterialPageRoute(
                    //     //             builder: (ctx) => PhotoList(
                    //     //               imgUrl: docsUrls,
                    //     //             ),
                    //     //           ),
                    //     //         );
                    //     //       },
                    //     //       child: FittedBox(
                    //     //         fit: BoxFit.fill,
                    //     //         child: CachedNetworkImage(
                    //     //           memCacheHeight: (200 *
                    //     //               MediaQuery.of(context)
                    //     //                   .devicePixelRatio)
                    //     //               .round(),
                    //     //           memCacheWidth: (200 *
                    //     //               MediaQuery.of(context)
                    //     //                   .devicePixelRatio)
                    //     //               .round(),
                    //     //           imageUrl: docsUrls.first,
                    //     //           placeholder: (context, url) =>
                    //     //               Image.memory(kTransparentImage),
                    //     //           errorWidget: (context, url, error) =>
                    //     //           const Icon(Icons.error),
                    //     //           fadeInDuration:
                    //     //           const Duration(seconds: 1),
                    //     //           fadeOutDuration:
                    //     //           const Duration(seconds: 1),
                    //     //         ),
                    //     //       ),
                    //     //     ),
                    //     //   ) :
                    //     //   Container(
                    //     //     height: MediaQuery.of(context)
                    //     //         .size
                    //     //         .height *
                    //     //         0.30,
                    //     //     width: double.infinity,
                    //     //     margin:
                    //     //     const EdgeInsets.only(top: 5),
                    //     //     child: GestureDetector(
                    //     //       onTap: () async {
                    //     //         Navigator.push(
                    //     //           context,
                    //     //           MaterialPageRoute(
                    //     //             builder: (ctx) => OpenPdf(
                    //     //               imgUrl: docsUrls.where((element) => element.contains(".pdf")).toList(),
                    //     //             ),
                    //     //           ),
                    //     //         );
                    //     //       },
                    //     //       child: AbsorbPointer(
                    //     //         child: const PDF(
                    //     //           defaultPage: 0,
                    //     //           enableSwipe: false,
                    //     //         ).cachedFromUrl(docsUrls.where((element) => element.contains(".pdf")).toList()[0],
                    //     //             // maxNrOfCacheObjects: 0,
                    //     //             // maxAgeCacheObject: const Duration(milliseconds: 100),
                    //     //             placeholder: (currentProgress) {
                    //     //               userProfileNotifier.progress = currentProgress;
                    //     //               return CircularPercentIndicator(
                    //     //                 radius: 30.0,
                    //     //                 lineWidth: 5.0,
                    //     //                 percent: currentProgress/100,
                    //     //                 center: Text('${currentProgress.toString().replaceAll(".0", '')} %'),
                    //     //                 progressColor: globalColor,
                    //     //                 backgroundColor: Colors.grey,
                    //     //               );
                    //     //             }
                    //     //         ),
                    //     //       ),
                    //     //     ),
                    //     //   ),
                    //   ],
                    // ),
                    // // const SizedBox(
                    // //   height: 30,
                    // // ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: const Color(0xFFE9CCA4),
                              borderRadius: BorderRadius.circular(50)),
                          child: Icon(Icons.speaker_notes_outlined,
                              size: 16.0, color: Platform.isAndroid ? Colors.white : CupertinoColors.white),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Description',
                          style: CustomTextStyles.getH4(
                              null,
                              (MediaQuery.of(context).platformBrightness ==
                                      Brightness.dark)
                                  ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                  : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                              null,
                              14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ReadMoreText(
                      widget.resalePropertyModel.description ?? '',
                      trimLines: 2,
                      // colorClickableText: Colors.white,
                      trimMode: TrimMode.Line,
                      trimCollapsedText: 'more',
                      colorClickableText: globalColor,
                      trimExpandedText: 'less',
                      style: TextStyle(
                        fontSize: 14,
                        color: (MediaQuery.of(context).platformBrightness ==
                                Brightness.dark)
                            ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                            : Colors.grey[600],
                      ),
                      // moreStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Platform.isAndroid ? Colors.blue : CupertinoColors.systemBlue,
                              borderRadius: BorderRadius.circular(50)),
                          child: Icon(Platform.isAndroid ? Icons.map : CupertinoIcons.map,
                              size: 16.0, color: Platform.isAndroid ? Colors.white : CupertinoColors.white),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Map',
                          style: CustomTextStyles.getH4(
                              null,
                              (MediaQuery.of(context).platformBrightness ==
                                      Brightness.dark)
                                  ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                  : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                              null,
                              14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Image.network(
                      staticMapImageUrl(widget.resalePropertyModel.lat,
                          widget.resalePropertyModel.lng),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: const Color(0xFF93C54B),
                              borderRadius: BorderRadius.circular(50)),
                          child: Icon(Icons.park_outlined,
                              size: 16.0, color: Platform.isAndroid ? Colors.white : CupertinoColors.white),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Amenities',
                          style: CustomTextStyles.getH4(
                              null,
                              (MediaQuery.of(context).platformBrightness ==
                                      Brightness.dark)
                                  ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                  : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                              null,
                              14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if ((widget.resalePropertyModel.amenities ?? [])
                              .contains(0))
                            Flexible(
                              child: FilterChip(
                                showCheckmark: false,
                                padding:
                                    const EdgeInsets.only(left: 8, right: 8),
                                // backgroundColor: Colors.grey,
                                // selectedColor: globalColor,
                                // disabledColor: Colors.blue,
                                label: Text(
                                  '24x7\nwater',
                                  style: TextStyle(
                                      fontSize: 12, color: Platform.isAndroid ? Colors.black : CupertinoColors.black),
                                  maxLines: 2,
                                ),
                                // selected: resalePropertyNotifier.isWaterSelected,
                                onSelected: (_) {
                                  // setState(() {
                                  //   resalePropertyNotifier.isWaterSelected = !resalePropertyNotifier.isWaterSelected;
                                  // });
                                  // if(resalePropertyNotifier.isWaterSelected){
                                  //   resalePropertyNotifier.amenities.add(0);
                                  //   if (kDebugMode) {
                                  //     print(resalePropertyNotifier.amenities);
                                  //   }
                                  // }else {
                                  //   resalePropertyNotifier.amenities.remove(0);
                                  //   if (kDebugMode) {
                                  //     print(resalePropertyNotifier.amenities);
                                  //   }
                                  // }
                                },
                              ),
                            ),
                          if ((widget.resalePropertyModel.amenities ?? [])
                              .contains(1))
                            Flexible(
                              child: FilterChip(
                                showCheckmark: false,
                                padding: const EdgeInsets.only(
                                    left: 13, right: 13, top: 8.5, bottom: 8.5),
                                // backgroundColor: Colors.grey,
                                // selectedColor: globalColor,
                                // disabledColor: Colors.blue,
                                label: Text(
                                  'Lift',
                                  style: TextStyle(
                                      fontSize: 12, color: Platform.isAndroid ? Colors.black : CupertinoColors.black),
                                ),
                                // selected: resalePropertyNotifier.isLiftSelected,
                                onSelected: (_) {
                                  // setState(() {
                                  //   resalePropertyNotifier.isLiftSelected = !resalePropertyNotifier.isLiftSelected;
                                  // });
                                  // if(resalePropertyNotifier.isLiftSelected){
                                  //   resalePropertyNotifier.amenities.add(1);
                                  //   if (kDebugMode) {
                                  //     print(resalePropertyNotifier.amenities);
                                  //   }
                                  // }else {
                                  //   resalePropertyNotifier.amenities.remove(1);
                                  //   if (kDebugMode) {
                                  //     print(resalePropertyNotifier.amenities);
                                  //   }
                                  // }
                                },
                              ),
                            ),
                          if ((widget.resalePropertyModel.amenities ?? [])
                              .contains(2))
                            Flexible(
                              child: FilterChip(
                                showCheckmark: false,
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  right: 8,
                                ),
                                // backgroundColor: Colors.grey,
                                // selectedColor: globalColor,
                                // disabledColor: Colors.blue,
                                label: Text(
                                  'Power\nbackup',
                                  style: TextStyle(
                                      fontSize: 12, color: Platform.isAndroid ? Colors.black : CupertinoColors.black),
                                  maxLines: 2,
                                ),
                                // selected: resalePropertyNotifier.isPowerSelected,
                                onSelected: (_) {
                                  // setState(() {
                                  //   resalePropertyNotifier.isPowerSelected = !resalePropertyNotifier.isPowerSelected;
                                  // });
                                  // if(resalePropertyNotifier.isPowerSelected){
                                  //   resalePropertyNotifier.amenities.add(2);
                                  //   if (kDebugMode) {
                                  //     print(resalePropertyNotifier.amenities);
                                  //   }
                                  // }else {
                                  //   resalePropertyNotifier.amenities.remove(2);
                                  //   if (kDebugMode) {
                                  //     print(resalePropertyNotifier.amenities);
                                  //   }
                                  // }
                                },
                              ),
                            ),
                          if ((widget.resalePropertyModel.amenities ?? [])
                              .contains(3))
                            Flexible(
                              child: FilterChip(
                                showCheckmark: false,
                                padding: const EdgeInsets.only(
                                    left: 8, right: 8, top: 8.5, bottom: 8.5),
                                // backgroundColor: Colors.grey,
                                // selectedColor: globalColor,
                                // disabledColor: Colors.blue,
                                label: Text(
                                  'Security',
                                  style: TextStyle(
                                      fontSize: 12, color: Platform.isAndroid ? Colors.black : CupertinoColors.black),
                                ),
                                // selected: resalePropertyNotifier.isSecuritySelected,
                                onSelected: (_) {
                                  // setState(() {
                                  //   resalePropertyNotifier.isSecuritySelected = !resalePropertyNotifier.isSecuritySelected;
                                  // });
                                  // if(resalePropertyNotifier.isSecuritySelected){
                                  //   resalePropertyNotifier.amenities.add(3);
                                  //   if (kDebugMode) {
                                  //     print(resalePropertyNotifier.amenities);
                                  //   }
                                  // }else {
                                  //   resalePropertyNotifier.amenities.remove(3);
                                  //   if (kDebugMode) {
                                  //     print(resalePropertyNotifier.amenities);
                                  //   }
                                  // }
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    // const SizedBox(
                    //   height: 5,
                    // ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if ((widget.resalePropertyModel.amenities ?? [])
                              .contains(4))
                            Flexible(
                              child: FilterChip(
                                showCheckmark: false,
                                padding:
                                    const EdgeInsets.only(left: 13, right: 13),
                                // backgroundColor: Colors.grey,
                                // selectedColor: globalColor,
                                // disabledColor: Colors.blue,
                                label: Text(
                                  'Club\nhouse',
                                  style: TextStyle(
                                      fontSize: 12, color: Platform.isAndroid ? Colors.black : CupertinoColors.black),
                                  maxLines: 2,
                                ),
                                // selected: resalePropertyNotifier.isClubSelected,
                                onSelected: (_) {
                                  // setState(() {
                                  //   resalePropertyNotifier.isClubSelected = !resalePropertyNotifier.isClubSelected;
                                  // });
                                  // if(resalePropertyNotifier.isClubSelected){
                                  //   resalePropertyNotifier.amenities.add(4);
                                  //   if (kDebugMode) {
                                  //     print(resalePropertyNotifier.amenities);
                                  //   }
                                  // }else {
                                  //   resalePropertyNotifier.amenities.remove(4);
                                  //   if (kDebugMode) {
                                  //     print(resalePropertyNotifier.amenities);
                                  //   }
                                  // }
                                },
                              ),
                            ),
                          if ((widget.resalePropertyModel.amenities ?? [])
                              .contains(5))
                            Flexible(
                              child: FilterChip(
                                showCheckmark: false,
                                padding:
                                    const EdgeInsets.only(left: 8, right: 8),
                                // backgroundColor: Colors.grey,
                                // selectedColor: globalColor,
                                // disabledColor: Colors.blue,
                                labelPadding: const EdgeInsets.all(0),
                                label: Text(
                                  'Swimming\n     pool',
                                  style: TextStyle(
                                      fontSize: 12, color: Platform.isAndroid ? Colors.black : CupertinoColors.black),
                                  maxLines: 2,
                                ),
                                // Text('Swimming\npool', style: TextStyle(fontSize: 10, color: Colors.white), maxLines: 2,),
                                // selected: resalePropertyNotifier.isSwimmingPoolSelected,
                                onSelected: (_) {
                                  // setState(() {
                                  //   resalePropertyNotifier.isSwimmingPoolSelected = !resalePropertyNotifier.isSwimmingPoolSelected;
                                  // });
                                  // if(resalePropertyNotifier.isSwimmingPoolSelected){
                                  //   resalePropertyNotifier.amenities.add(5);
                                  //   if (kDebugMode) {
                                  //     print(resalePropertyNotifier.amenities);
                                  //   }
                                  // }else {
                                  //   resalePropertyNotifier.amenities.remove(5);
                                  //   if (kDebugMode) {
                                  //     print(resalePropertyNotifier.amenities);
                                  //   }
                                  // }
                                },
                              ),
                            ),
                          if ((widget.resalePropertyModel.amenities ?? [])
                              .contains(6))
                            Flexible(
                              child: FilterChip(
                                showCheckmark: false,
                                padding: const EdgeInsets.only(
                                    left: 8, right: 8, top: 8.5, bottom: 8.5),
                                // backgroundColor: Colors.grey,
                                // selectedColor: globalColor,
                                // disabledColor: Colors.blue,
                                label: Text(
                                  'Park',
                                  style: TextStyle(
                                      fontSize: 12, color: Platform.isAndroid ? Colors.black : CupertinoColors.black),
                                ),
                                // selected: resalePropertyNotifier.isParkSelected,
                                onSelected: (_) {
                                  // setState(() {
                                  //   resalePropertyNotifier.isParkSelected = !resalePropertyNotifier.isParkSelected;
                                  // });
                                  // if(resalePropertyNotifier.isParkSelected){
                                  //   resalePropertyNotifier.amenities.add(6);
                                  //   if (kDebugMode) {
                                  //     print(resalePropertyNotifier.amenities);
                                  //   }
                                  // }else {
                                  //   resalePropertyNotifier.amenities.remove(6);
                                  //   if (kDebugMode) {
                                  //     print(resalePropertyNotifier.amenities);
                                  //   }
                                  // }
                                },
                              ),
                            ),
                          if ((widget.resalePropertyModel.amenities ?? [])
                              .contains(7))
                            Flexible(
                              child: FilterChip(
                                showCheckmark: false,
                                padding:
                                    const EdgeInsets.only(left: 8, right: 8),
                                // backgroundColor: Colors.grey,
                                // selectedColor: globalColor,
                                // disabledColor: Colors.blue,
                                label: Text(
                                  'Gas\npipeline',
                                  style: TextStyle(
                                      fontSize: 12, color: Platform.isAndroid ? Colors.black : CupertinoColors.black),
                                  maxLines: 2,
                                ),
                                // selected: resalePropertyNotifier.isGasSelected,
                                onSelected: (_) {
                                  // setState(() {
                                  //   resalePropertyNotifier.isGasSelected = !resalePropertyNotifier.isGasSelected;
                                  // });
                                  // if(resalePropertyNotifier.isGasSelected){
                                  //   resalePropertyNotifier.amenities.add(7);
                                  //   if (kDebugMode) {
                                  //     print(resalePropertyNotifier.amenities);
                                  //   }
                                  // }else {
                                  //   resalePropertyNotifier.amenities.remove(7);
                                  //   if (kDebugMode) {
                                  //     print(resalePropertyNotifier.amenities);
                                  //   }
                                  // }
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Container(
                            height: 25,
                            width: 25,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Platform.isAndroid ? Colors.green : CupertinoColors.systemGreen,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                                child: Text('₹',
                                    style: TextStyle(
                                      color: Platform.isAndroid ? Colors.white : CupertinoColors.white,
                                      fontSize: 12,
                                    )))),
                        const SizedBox(width: 5),
                        Text(
                          'Home Loan',
                          style: CustomTextStyles.getH4(
                              null,
                              (MediaQuery.of(context).platformBrightness ==
                                      Brightness.dark)
                                  ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                  : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                              null,
                              14),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    // if (isHomeLoanSelected)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Interest Rate (% per annum)',
                              style: CustomTextStyles.getBodySmall(
                                  null,
                                  (MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark)
                                      ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                      : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                  null,
                                  14),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Text(
                                  '${emiNotifier.interestSliderValue} %',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                )),
                          ],
                        ),
                        if(Platform.isAndroid)
                          Slider(
                            thumbColor: Colors.white,
                            activeColor: globalColor,
                            inactiveColor: Colors.grey,
                            min: 0.0,
                            max: 15.0,
                            value: emiNotifier.interestSliderValue,
                            onChanged: (value) {
                              setState(
                                    () {
                                  emiNotifier.interestSliderValue =
                                      double.parse(value.toStringAsFixed(2));
                                  emiNotifier.R =
                                      emiNotifier.interestSliderValue / 12 / 100;

                                  emiNotifier.calculateMonthlyEmi();
                                  emiNotifier.calculateEmiPerLac();
                                },
                              );
                            },
                          ),
                        if(Platform.isIOS)
                        SizedBox(
    width:                double.infinity,
                          child: CupertinoSlider(
                            thumbColor: CupertinoColors.white,
                            activeColor: globalColor,
                            // inactiveColor: Colors.grey,
                            min: 0.0,
                            max: 15.0,
                            value: emiNotifier.interestSliderValue,
                            onChanged: (value) {
                              setState(
                                () {
                                  emiNotifier.interestSliderValue =
                                      double.parse(value.toStringAsFixed(2));
                                  emiNotifier.R =
                                      emiNotifier.interestSliderValue / 12 / 100;

                                  emiNotifier.calculateMonthlyEmi();
                                  emiNotifier.calculateEmiPerLac();
                                },
                              );
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              '0',
                              style: TextStyle(
                                  color: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              width: 100,
                            ),
                            Text('15',
                                style: TextStyle(
                                    color: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tenure (Years)',
                              style: CustomTextStyles.getBodySmall(
                                  null,
                                  (MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark)
                                      ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                      : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                  null,
                                  14),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Text(
                                  '${emiNotifier.tenureSliderValue} yrs',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ))
                          ],
                        ),
                        if(Platform.isAndroid)
                        Slider(
                            thumbColor: Colors.white,
                            activeColor: globalColor,
                            inactiveColor: Colors.grey,
                            min: 1,
                            max: 30,
                            value: double.parse(
                                emiNotifier.tenureSliderValue.toString()),
                            onChanged: (value) {
                              setState(() {
                                emiNotifier.tenureSliderValue = value.toInt();
                                emiNotifier.N =
                                    emiNotifier.tenureSliderValue * 12;
                                emiNotifier.calculateMonthlyEmi();
                                emiNotifier.calculateEmiPerLac();
                              });
                            },
                          ),
                        if(Platform.isIOS)
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoSlider(
                            thumbColor: CupertinoColors.white,
                            activeColor: globalColor,
                            // inactiveColor: Colors.grey,
                            min: 1,
                            max: 30,
                            value: double.parse(
                                emiNotifier.tenureSliderValue.toString()),
                            onChanged: (value) {
                              setState(() {
                                emiNotifier.tenureSliderValue = value.toInt();
                                emiNotifier.N =
                                    emiNotifier.tenureSliderValue * 12;
                                emiNotifier.calculateMonthlyEmi();
                                emiNotifier.calculateEmiPerLac();
                              });
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text('1',
                                style: TextStyle(
                                    color: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(
                              width: 100,
                            ),
                            Text('30',
                                style: TextStyle(
                                    color: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'EMI per lakh',
                              style: CustomTextStyles.getBodySmall(
                                  null,
                                  (MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark)
                                      ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                      : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                  null,
                                  14),
                            ),
                            Text(
                              'Loan Amount in lakh',
                              style: CustomTextStyles.getBodySmall(
                                  null,
                                  (MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark)
                                      ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                      : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                  null,
                                  14),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                emiNotifier.emiPerLac,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                width: 196,
                              ),
                              Expanded(
                                child: Form(
                                  key: form,
                                  child: Platform.isAndroid ? TextFormField(
                                    controller: loanController,
                                    validator: (value) {
                                      if (double.parse(value.toString()) >
                                          999.99 ||
                                          double.parse(value.toString()) < 1) {
                                        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a value between 1 - 999')));
                                        return 'range is 1 - 999';
                                      }
                                      return null;
                                    },
                                    inputFormatters: [
                                      // DecimalTextInputFormatter(
                                      //     decimalRange: 2),
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d{1,3}(\.\d{0,2})?')),
                                      FilteringTextInputFormatter.deny(
                                          RegExp(r'^0+')),
                                    ],
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      counterText: "",
                                    ),
                                    // initialValue: "50",
                                    maxLength: 6,
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      setState(() {
                                        if (double.parse(value) <= 999) {
                                          form.currentState?.validate();
                                          emiNotifier.loanAmount =
                                          (double.tryParse(value)! *
                                              100000);
                                          emiNotifier.calculateMonthlyEmi();
                                        } else {
                                          form.currentState?.validate();
                                          // loanController.text = loanController.value.text.substring(0, loanController.value.text.length -1);
                                        }
                                      });
                                    },
                                  ) : CupertinoTextFormFieldRow(
                                    decoration: BoxDecoration(
                                      color: null,
                                      border: Border(bottom: BorderSide(width: 1, color: (MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark)
                                          ? CupertinoColors.systemGrey
                                          : CupertinoColors.black,)),
                                    ),
                                    style: TextStyle(color: (MediaQuery.of(context).platformBrightness ==
                                        Brightness.dark)
                                        ? CupertinoColors.white
                                        : CupertinoColors.black,),
                                    padding: EdgeInsets.zero,
                                    controller: loanController,
                                    validator: (value) {
                                      if (double.parse(value.toString()) >
                                              999.99 ||
                                          double.parse(value.toString()) < 1) {
                                        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a value between 1 - 999')));
                                        return 'range is 1 - 999';
                                      }
                                      return null;
                                    },
                                    inputFormatters: [
                                      // DecimalTextInputFormatter(
                                      //     decimalRange: 2),
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d{1,3}(\.\d{0,2})?')),
                                      FilteringTextInputFormatter.deny(
                                          RegExp(r'^0+')),
                                    ],
                                    textAlign: TextAlign.center,
                                    // decoration: const InputDecoration(
                                    //   counterText: "",
                                    // ),
                                    // initialValue: "50",
                                    maxLength: 6,
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      setState(() {
                                        if (double.parse(value) <= 999) {
                                          form.currentState?.validate();
                                          emiNotifier.loanAmount =
                                              (double.tryParse(value)! *
                                                  100000);
                                          emiNotifier.calculateMonthlyEmi();
                                        } else {
                                          form.currentState?.validate();
                                          // loanController.text = loanController.value.text.substring(0, loanController.value.text.length -1);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Monthly EMI',
                                style: CustomTextStyles.getBodySmall(
                                    null,
                                    (MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.dark)
                                        ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                        : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                    null,
                                    14),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Text(
                                  emiNotifier.monthlyEmi,
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: (MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.dark)
                                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                          : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Locality ${widget.resalePropertyModel.locality}',
                                style: CustomTextStyles.getH4(
                                    null,
                                    (MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.dark)
                                        ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                        : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                    null,
                                    14),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'City ${widget.resalePropertyModel.city}',
                                textAlign: TextAlign.start,
                                style: CustomTextStyles.getH4(
                                    null,
                                    (MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.dark)
                                        ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                        : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                    null,
                                    14),
                              ),
                            ),
                            Column(children: [
                              const SizedBox(height: 20),
                              Text(
                                'Seller Details',
                                textAlign: TextAlign.start,
                                style: CustomTextStyles.getH4(
                                    null,
                                    (MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.dark)
                                        ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                        : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                    null,
                                    14),
                              ),
                              const SizedBox(height: 5),
                            ]),
                            FirebaseAuth.instance.currentUser?.uid == null
                                ? Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Platform.isAndroid ? Colors.black : CupertinoColors.black),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(15))),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // const SizedBox(
                                        //   height: 15,
                                        // ),
                                        Text(
                                          'To view seller details, become a member.\nStarting ₹ 5,000/- only',
                                          style: CustomTextStyles.getBodySmall(
                                              null,
                                              (MediaQuery.of(context)
                                                          .platformBrightness ==
                                                      Brightness.dark)
                                                  ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                                  : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                              null,
                                              14),
                                        ),
                                        const SizedBox(
                                          height: 7,
                                        ),
                                        SizedBox(
                                          width: 180,
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                    const KnowMoreMemPlan(isComingFromJoinNow: true, isComingFromKnowMore: false,)),
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
                                        // const SizedBox(height: 2.5,),
                                        // Text(
                                        //   widget.resalePropertyModel.locality ?? '',
                                        //   style: CustomTextStyles.getBodySmall(
                                        //       CustomShadows.textNormal, Colors.white, null, 14),
                                        // ),
                                        // Text((widget.resalePropertyModel.city == null || widget.resalePropertyModel.pincode == null) ? '' :
                                        // '${widget.resalePropertyModel.city}, ${widget.resalePropertyModel.pincode}',
                                        //   style: CustomTextStyles.getBodySmall(
                                        //       CustomShadows.textNormal, Colors.white, null, 14),
                                        // ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    children: [
                                      (widget.resalePropertyModel
                                                      .posted_by_user_id !=
                                                  userProfileNotifier
                                                      .userProfileModel.id &&
                                              (resalePropertyNotifier
                                                      .memPlans.isEmpty ||
                                                  (resalePropertyNotifier
                                                          .memPlans
                                                          .isNotEmpty &&
                                                      !DateTime.now().isBefore(
                                                          resalePropertyNotifier
                                                              .memPlans[0]
                                                              .ending_on))))
                                          ? Container(
                                              margin: const EdgeInsets.only(
                                                  top: 10),
                                              padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Platform.isAndroid ? Colors.black : CupertinoColors.black),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(15))),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  // const SizedBox(
                                                  //   height: 15,
                                                  // ),
                                                  Text(
                                                    'To view seller details, become a member.\nStarting ₹ 5,000/- only',
                                                    style: CustomTextStyles
                                                        .getBodySmall(
                                                            null,
                                                            (MediaQuery.of(context)
                                                                        .platformBrightness ==
                                                                    Brightness
                                                                        .dark)
                                                                ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                                                : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                                            null,
                                                            14),
                                                  ),
                                                  const SizedBox(
                                                    height: 7,
                                                  ),
                                                  SizedBox(
                                                    width: 180,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                              const KnowMoreMemPlan(isComingFromJoinNow: true, isComingFromKnowMore: false,)),
                                                        );
                                                      },
                                                      child: Card(
                                                        color: globalColor,
                                                        child: Padding(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                    10),
                                                            child: Center(
                                                              child: Text(
                                                                'Join Now',
                                                                style: TextStyle(
                                                                    color: Platform.isAndroid ? Colors.white : CupertinoColors
                                                                        .white),
                                                              ),
                                                            )),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Column(
                                              children: [
                                                const SizedBox(
                                                  height: 2.5,
                                                ),
                                                Container(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Name  ${widget.resalePropertyModel.first_name ?? '- -'} ${widget.resalePropertyModel.last_name ?? '- -'}',
                                                          textAlign:
                                                              TextAlign.start,
                                                          style: CustomTextStyles.getH4(
                                                              null,
                                                              (MediaQuery.of(context)
                                                                          .platformBrightness ==
                                                                      Brightness
                                                                          .dark)
                                                                  ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                                                  : Platform.isAndroid ? Colors.black : CupertinoColors
                                                                      .black,
                                                              null,
                                                              14),
                                                        ),
                                                        Text(
                                                          'Phone  ${widget.resalePropertyModel.phone_number ?? '- -'}',
                                                          textAlign:
                                                              TextAlign.start,
                                                          style: CustomTextStyles.getH4(
                                                              null,
                                                              (MediaQuery.of(context)
                                                                          .platformBrightness ==
                                                                      Brightness
                                                                          .dark)
                                                                  ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                                                  : Platform.isAndroid ? Colors.black : CupertinoColors
                                                                      .black,
                                                              null,
                                                              14),
                                                        ),
                                                        Text(
                                                          'Email  ${widget.resalePropertyModel.email_id ?? '- -'}',
                                                          textAlign:
                                                              TextAlign.start,
                                                          style: CustomTextStyles.getH4(
                                                              null,
                                                              (MediaQuery.of(context)
                                                                          .platformBrightness ==
                                                                      Brightness
                                                                          .dark)
                                                                  ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                                                  : Platform.isAndroid ? Colors.black : CupertinoColors
                                                                      .black,
                                                              null,
                                                              14),
                                                        ),
                                                      ],
                                                    )),
                                              ],
                                            )
                                    ],
                                  )
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        if (((FirebaseAuth.instance.currentUser?.uid != null &&
                                (widget.resalePropertyModel.posted_by_user_id ==
                                    userProfileNotifier.userProfileModel.id)) &&
                            widget.resalePropertyModel.status == 1) && Platform.isIOS)
                          Container(
                              margin:
                              const EdgeInsets.only(left: 10, right: 10),
                              width: double.infinity,
                              child: CupertinoButton(
                                  color: globalColor,
                                  borderRadius: BorderRadius.circular(25),
                                onPressed: () async {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                      builder: (ctx) =>
                                          ResalePropertyScreen1(
                                            isComingFromEdit: true,
                                            resalePropertyModel:
                                            widget.resalePropertyModel,
                                          )))
                                      .then((value) async {
                                    await resalePropertyNotifier
                                        .getResaleProperties(context, this);
                                    resalePropertyNotifier
                                        .buildingNameTextController
                                        .clear();
                                    resalePropertyNotifier
                                        .floorMinTextController
                                        .clear();
                                    resalePropertyNotifier
                                        .floorMaxTextController
                                        .clear();
                                    resalePropertyNotifier.areaTextController
                                        .clear();
                                    resalePropertyNotifier.saleTextController
                                        .clear();
                                    resalePropertyNotifier
                                        .descriptionTextController
                                        .clear();
                                    resalePropertyNotifier
                                        .constructionAgeTextController
                                        .clear();
                                    autoCompleteNotifier.locationTextController
                                        .clear();
                                    resalePropertyNotifier.isWaterSelected =
                                    false;
                                    resalePropertyNotifier.isLiftSelected =
                                    false;
                                    resalePropertyNotifier.isPowerSelected =
                                    false;
                                    resalePropertyNotifier.isSecuritySelected =
                                    false;

                                    resalePropertyNotifier.isClubSelected =
                                    false;
                                    resalePropertyNotifier
                                        .isSwimmingPoolSelected = false;
                                    resalePropertyNotifier.isParkSelected =
                                    false;
                                    resalePropertyNotifier.isGasSelected =
                                    false;

                                    resalePropertyNotifier.isBungalowSelected =
                                    false;
                                    resalePropertyNotifier.isFlatSelected =
                                    true;

                                    resalePropertyNotifier.twoBHK = true;
                                    resalePropertyNotifier.oneBHK = false;
                                    resalePropertyNotifier.threeBHK = false;
                                    resalePropertyNotifier.fourPlusBHK = false;

                                    resalePropertyNotifier.isOwnerSelected =
                                    true;
                                    resalePropertyNotifier.isAgentSelected =
                                    false;
                                  });
                                },
                                  child: const Text('Edit',
                                      style: TextStyle(
                                          color: CupertinoColors.white, fontSize: 15)),
                              )
                          ),
                        if (((FirebaseAuth.instance.currentUser?.uid != null &&
                            (widget.resalePropertyModel.posted_by_user_id ==
                                userProfileNotifier.userProfileModel.id)) &&
                            widget.resalePropertyModel.status == 1) && Platform.isAndroid)
                          Center(
                              child: Container(
                                height: 60,
                                margin:
                                const EdgeInsets.only(left: 10, right: 10),
                                width: double.infinity,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                      foregroundColor: Colors.black,
                                      backgroundColor: globalColor),
                                  onPressed: () async {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                        builder: (ctx) =>
                                            ResalePropertyScreen1(
                                              isComingFromEdit: true,
                                              resalePropertyModel:
                                              widget.resalePropertyModel,
                                            )))
                                        .then((value) async {
                                      await resalePropertyNotifier
                                          .getResaleProperties(context, this);
                                      resalePropertyNotifier
                                          .buildingNameTextController
                                          .clear();
                                      resalePropertyNotifier
                                          .floorMinTextController
                                          .clear();
                                      resalePropertyNotifier
                                          .floorMaxTextController
                                          .clear();
                                      resalePropertyNotifier.areaTextController
                                          .clear();
                                      resalePropertyNotifier.saleTextController
                                          .clear();
                                      resalePropertyNotifier
                                          .descriptionTextController
                                          .clear();
                                      resalePropertyNotifier
                                          .constructionAgeTextController
                                          .clear();
                                      autoCompleteNotifier.locationTextController
                                          .clear();
                                      resalePropertyNotifier.isWaterSelected =
                                      false;
                                      resalePropertyNotifier.isLiftSelected =
                                      false;
                                      resalePropertyNotifier.isPowerSelected =
                                      false;
                                      resalePropertyNotifier.isSecuritySelected =
                                      false;

                                      resalePropertyNotifier.isClubSelected =
                                      false;
                                      resalePropertyNotifier
                                          .isSwimmingPoolSelected = false;
                                      resalePropertyNotifier.isParkSelected =
                                      false;
                                      resalePropertyNotifier.isGasSelected =
                                      false;

                                      resalePropertyNotifier.isBungalowSelected =
                                      false;
                                      resalePropertyNotifier.isFlatSelected =
                                      true;

                                      resalePropertyNotifier.twoBHK = true;
                                      resalePropertyNotifier.oneBHK = false;
                                      resalePropertyNotifier.threeBHK = false;
                                      resalePropertyNotifier.fourPlusBHK = false;

                                      resalePropertyNotifier.isOwnerSelected =
                                      true;
                                      resalePropertyNotifier.isAgentSelected =
                                      false;
                                    });
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.only(top: 8, bottom: 8),
                                    child: Text('Edit',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 15)),
                                  ),
                                ),
                              ),
                            ),
                        if ((FirebaseAuth.instance.currentUser?.uid != null &&
                                (widget.resalePropertyModel.posted_by_user_id ==
                                    userProfileNotifier.userProfileModel.id)) &&
                            widget.resalePropertyModel.status == 1)
                          const SizedBox(
                            height: 20,
                          ),
                        if ((FirebaseAuth.instance.currentUser?.uid != null &&
                                (widget.resalePropertyModel.posted_by_user_id !=
                                    userProfileNotifier.userProfileModel.id)) &&
                            (resalePropertyNotifier.memPlans.isNotEmpty &&
                                DateTime.now().isBefore(resalePropertyNotifier
                                    .memPlans[0].ending_on)))
                          const SizedBox(
                            height: 30,
                          ),
                        if (FirebaseAuth.instance.currentUser?.uid != null &&
                                (widget.resalePropertyModel.posted_by_user_id ==
                                    userProfileNotifier.userProfileModel.id))
                          const SizedBox()
                        else
                          SizedBox(
                            height: (resalePropertyNotifier.memPlans.isEmpty || (resalePropertyNotifier.memPlans.isNotEmpty &&
                                !DateTime.now().isBefore(resalePropertyNotifier
                                    .memPlans[0].ending_on))) ? 70 : 30,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ]),
          )
        ]),
        floatingActionButton:
            (FirebaseAuth.instance.currentUser?.uid != null &&
                        (widget.resalePropertyModel.posted_by_user_id ==
                            userProfileNotifier.userProfileModel.id))
                ? null : SizedBox(
                     height: Platform.isAndroid ? null : 50,
                    // margin: const EdgeInsets.only(left: 10),
                    width: MediaQuery.of(context).size.width * 0.92,
                    child: FloatingActionButton.extended(
                      backgroundColor: globalColor,
                      onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (ctx) => ResaleContact(resaleProject: widget.resalePropertyModel, appBarTitle: "Contact Us")));                        // String emailPostUrl =
                      },
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      label: Text('Contact for more details',
                          style: TextStyle(color: Platform.isAndroid ? Colors.white : CupertinoColors.white, fontSize: 15)),
                    ),
                  ),
      ),
    );
  }

  String staticMapImageUrl(double lat, double long) {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$long&zoom=15&size=600x300&maptype=roadmap&markers=color:red%7C$lat,$long&key=AIzaSyCw5bNd2XOJxMPbSG8Jr_-TPnQKeRkuO2A';
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

  Future<void> loadDocuments(String locationText, String name) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('resale_properties')
        .child('$locationText$name')
        .child('property-documents');
    final listResult = await storageRef.listAll();
    for (var item in listResult.items) {
      docsUrls = docsUrls..add(await item.getDownloadURL());
    }
  }
}
