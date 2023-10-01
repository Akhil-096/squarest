import 'dart:io';
import 'package:squarest/Views/v_book_a_visit.dart';
import 'package:flutter/cupertino.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:squarest/Models/m_project.dart';
import 'package:squarest/Models/m_project_inventory.dart';
import 'package:squarest/Services/s_emi_notifier.dart';
import 'package:squarest/Utils/u_constants.dart';
import 'package:squarest/Views/v_project_inventory_details.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:darq/darq.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:like_button/like_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math' as math;
import 'package:shimmer/shimmer.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Services/s_autocomplete_notifier.dart';
import '../Services/s_liked_projects_notifier.dart';
import '../Services/s_storage_access.dart';
import '../Services/s_user_profile_notifier.dart';
import '../Utils/u_custom_styles.dart';
import '../Utils/u_open_pdf.dart';
import 'package:flutter_cupertino_date_picker_fork/flutter_cupertino_date_picker_fork.dart';


class ProjectDetails extends StatefulWidget {
  final Project project;
  final bool isComingFromList;

  const ProjectDetails({
    Key? key,
    required this.project,
    required this.isComingFromList,
  }) : super(key: key);

  @override
  State<ProjectDetails> createState() => _ProjectDetailsState();
}

class _ProjectDetailsState extends State<ProjectDetails> {
  final PageController _controller = PageController();
  final ScrollController _scrollController = ScrollController();
  Future<List<String>> imageUrl = Future(() => []);
  final form = GlobalKey<FormState>();
  int currentImage = 1;
  Future<List<ProjectInventory>> projectInventory = Future(() => []);
  var loanController = TextEditingController(text: "50");
  ScreenshotController screenshotController = ScreenshotController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final autoCompleteNotifier =
        Provider.of<AutocompleteNotifier>(context, listen: false);
    final emiNotifier = Provider.of<EmiNotifier>(context, listen: false);
    emiNotifier.loanAmount = 50 * 100000;
    emiNotifier.calculateMonthlyEmi();
    emiNotifier.calculateEmiPerLac();
    autoCompleteNotifier.incrementViews(widget.project.id);
    getProjectInventory();
    loadImages();
    getLikedProjects();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfileNotifier = Provider.of<UserProfileNotifier>(context);
    final likedProjectsNotifier = Provider.of<LikedProjectsNotifier>(context);
    final project = Provider.of<Project>(context);
    final autoCompleteNotifier = Provider.of<AutocompleteNotifier>(context);

    return Screenshot(
      controller: screenshotController,
      child: isLoading
          ? const ShimmerWidget()
          : Scaffold(
              appBar: Platform.isAndroid ? PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: AppBar(
                  scrolledUnderElevation: 0.0,
                  backgroundColor: (MediaQuery.of(context).platformBrightness ==
                      Brightness.dark)
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
                              // mainAxisAlignment: MainAxisAlignment.end,
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LikeButton(
                                  size: 30,
                                  isLiked: widget.isComingFromList
                                      ? project.isLiked
                                      : likedProjectsNotifier.isLiked,
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
                                      msg: 'Please login to save a project',
                                      backgroundColor: Colors.white,
                                      textColor: Colors.black,
                                    );
                                    return null;
                                  }
                                      : (isLiked) async {
                                    if (kDebugMode) {
                                      print(userProfileNotifier
                                          .userProfileModel.id);
                                    }
                                    likedProjectsNotifier.isLiked = isLiked;
                                    if (!likedProjectsNotifier.isLiked) {
                                      if (widget.isComingFromList) {
                                        project.toggleLike();
                                      }
                                      likedProjectsNotifier.insertLikes(
                                          (userProfileNotifier
                                              .userProfileModel.id)
                                              .toInt(),
                                          widget.project.id);
                                      // Future.delayed(const Duration(milliseconds: 2000),(){
                                      //   likedProjectsNotifier.getLikedProjects(context);
                                      // });
                                    }
                                    if (likedProjectsNotifier.isLiked) {
                                      if (widget.isComingFromList) {
                                        project.toggleLike();
                                      }
                                      likedProjectsNotifier.deleteLikes(
                                          (userProfileNotifier
                                              .userProfileModel.id)
                                              .toInt(),
                                          widget.project.id);
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
                                  child: Icon(
                                    Icons.share_outlined,
                                    color: (MediaQuery.of(context)
                                        .platformBrightness ==
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
                  backgroundColor: (MediaQuery.of(context).platformBrightness ==
                          Brightness.dark)
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
                                        ? project.isLiked
                                        : likedProjectsNotifier.isLiked,
                                    likeBuilder: (isLiked) {
                                      return isLiked
                                          ? Icon(
                                              CupertinoIcons.suit_heart_fill,
                                              color:
                                                  isLiked ? CupertinoColors.systemRed : null,
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
                                    onTap: !userSnapshot.hasData
                                        ? (_) async {
                                            Fluttertoast.showToast(
                                              msg:
                                                  'Please login to save a project',
                                              backgroundColor: CupertinoColors.white,
                                              textColor: CupertinoColors.black,
                                            );
                                            return null;
                                          }
                                        : (isLiked) async {
                                            if (kDebugMode) {
                                              print(userProfileNotifier
                                                  .userProfileModel.id);
                                            }
                                            likedProjectsNotifier.isLiked =
                                                isLiked;
                                            if (!likedProjectsNotifier
                                                .isLiked) {
                                              if (widget.isComingFromList) {
                                                project.toggleLike();
                                              }
                                              likedProjectsNotifier.insertLikes(
                                                  (userProfileNotifier
                                                          .userProfileModel.id)
                                                      .toInt(),
                                                  widget.project.id);
                                            }
                                            if (likedProjectsNotifier.isLiked) {
                                              if (widget.isComingFromList) {
                                                project.toggleLike();
                                              }
                                              likedProjectsNotifier.deleteLikes(
                                                  (userProfileNotifier
                                                          .userProfileModel.id)
                                                      .toInt(),
                                                  widget.project.id);
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
                                    child: Icon(
                                      CupertinoIcons.share,
                                      color: (MediaQuery.of(context)
                                                  .platformBrightness ==
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
                    ],
                  )),
              body: FutureBuilder<List<String>>(
                future: imageUrl,
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      isLoading) {
                    return const ShimmerWidget();
                  } else {
                    if (snapshot.hasError || !snapshot.hasData) {
                      return contentWidget([]);
                    } else {
                      return contentWidget(snapshot.data!);
                    }
                  }
                },
              ),
              bottomSheet: SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: 60,
                      width: 150,
                      child: Platform.isAndroid ? TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: globalColor),
                        onPressed: _showDatePicker,
                        child: const Text('Book Site Visit',
                            style: TextStyle(
                                color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                      ) :
                      CupertinoButton(
                        borderRadius: BorderRadius.circular(25),
                        padding: EdgeInsets.zero,
                        color: globalColor,
                        child: const Text('Book Site Visit',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          DatePicker.showDatePicker(
                            context,
                            pickerTheme: DateTimePickerTheme(
                                cancelTextStyle: const TextStyle(color: CupertinoColors.destructiveRed),
                                backgroundColor: (MediaQuery.of(context).platformBrightness ==
                                Brightness.dark)
                                ? Colors.grey[900]!
                                : CupertinoColors.white,
                                itemTextStyle: TextStyle(color: (MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark)
                                    ? CupertinoColors.white
                                    : CupertinoColors.black,),
                                confirmTextStyle: const TextStyle(color: CupertinoColors.systemBlue),
                            ),
                            onMonthChangeStartWithFirstDate: true,
                            initialDateTime: DateTime(DateTime.now().year, DateTime.now().month,
                              DateTime.now().day + 1),
                            minDateTime: DateTime(DateTime.now().year, DateTime.now().month,
                                DateTime.now().day + 1),
                            pickerMode: DateTimePickerMode.date,
                            maxDateTime: DateTime(DateTime.now().year, DateTime.now().month,
                                DateTime.now().day + 1)
                                .add(const Duration(days: 15)),
                            onChange: null,
                            onClose: null,
                            onCancel: null,
                            onConfirm: (date, _) {
                              autoCompleteNotifier.setSelectedDate(date).then((value) {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                    builder: (ctx) => BookAVisit(
                                      project: widget.project,
                                      appBarTitle: "Book Site Visit",
                                      isComingFromContactUs: false,
                                    )))
                                    .then((value) {
                                  autoCompleteNotifier.setSelectedDate(null);
                                });
                              });
                            },
                          );
                        }
                      )
                    ),
                    SizedBox(
                        height: 60,
                        width: 150,
                        child: Platform.isAndroid ? TextButton(
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: globalColor),
                          onPressed: () {
                            Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (ctx) => BookAVisit(project: widget.project, appBarTitle: "Contact Us", isComingFromContactUs: true,)));
                          },
                          child: const Text('Contact Us',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        ) :
                        CupertinoButton(
                          borderRadius: BorderRadius.circular(25),
                          padding: EdgeInsets.zero,
                          color: globalColor,
                          child: const Text('Contact Us',
                              style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold)),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (ctx) => BookAVisit(
                                  project: widget.project,
                                  appBarTitle: "Contact Us",
                                  isComingFromContactUs: true,
                                )));
                          },
                        )
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> loadImages() async {
    try {
      String json =
          await rootBundle.loadString('assets/storage_img_serv_acc_cred.json');
      StorageAccess storageAccess = StorageAccess(json);
      imageUrl = storageAccess.loadFromBucket(widget.project.applicationno);
    } catch (error) {
      if (kDebugMode) {
        print('$error');
      }
      rethrow;
    }
  }

  Widget contentWidget(List<String> imgUrl) {
    final emiNotifier = Provider.of<EmiNotifier>(context);
    final userProfileNotifier = Provider.of<UserProfileNotifier>(context);
    final date = DateTime.now();
    final autoCompleteNotifier = Provider.of<AutocompleteNotifier>(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Column(
          children: <Widget>[
            Expanded(
              child: CustomScrollView(
                controller: _scrollController,
                // padding: const EdgeInsets.all(5),
                scrollDirection: Axis.vertical,
                slivers: [
                  SliverAppBar(
                    backgroundColor:
                        (MediaQuery.of(context).platformBrightness ==
                                Brightness.dark)
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
                                onTap: imgUrl
                                        .where((element) =>
                                            !element.contains(".pdf"))
                                        .toList()
                                        .isEmpty
                                    ? () {}
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (ctx) => PhotoList(
                                              imgUrl: imgUrl
                                                  .where((element) =>
                                                      !element.contains(".pdf"))
                                                  .toList(),
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
                                    if (imgUrl
                                        .where((element) =>
                                            !element.contains(".pdf"))
                                        .toList()
                                        .isEmpty)
                                      FittedBox(
                                        fit: BoxFit.fill,
                                        child: Image.asset(
                                            'assets/images/default.png'),
                                      )
                                    else
                                      ...imgUrl
                                          .where((element) =>
                                              !element.contains(".pdf"))
                                          .toList()
                                          .map(
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
                                                    Image.memory(
                                                        kTransparentImage),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(Icons.error),
                                                fadeInDuration: const Duration(
                                                    milliseconds: 10),
                                                fadeOutDuration: const Duration(
                                                    milliseconds: 10),
                                              ),
                                            ),
                                          ),
                                  ],
                                )),
                          ),
                          if (imgUrl
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
                                    "$currentImage/${imgUrl.where((element) => !element.contains(".pdf")).toList().length}",
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
                                  ).format(widget.project.project_views_total).replaceAll(".00", "")} views',
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
                                  height: 2,
                                ),
                                Text(
                                  'Listed ${date.difference(widget.project.insert_date).inDays} days ago',
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
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 150,
                                      child: Text(
                                        widget.project.name_of_project,
                                        maxLines: 2,
                                        style:
                                            CustomTextStyles.getProjectNameFont(
                                                null,
                                                (MediaQuery.of(context)
                                                            .platformBrightness ==
                                                        Brightness.dark)
                                                    ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                                    : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                                16),
                                        softWrap: true,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 150,
                                      child: Text(
                                          widget.project.builder_id != 0
                                              ? widget.project.builder_name
                                              : widget.project.promoter_name,
                                          style: CustomTextStyles.getBody(
                                              null,
                                              (MediaQuery.of(context)
                                                          .platformBrightness ==
                                                      Brightness.dark)
                                                  ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                                  : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                              16),
                                          maxLines: 2),
                                    ),
                                    SizedBox(
                                      width: 150,
                                      child: Text(
                                        widget.project.project_village,
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
                                    ),
                                    Text(
                                      '${widget.project.project_district} ${widget.project.pincode}',
                                      style: CustomTextStyles.getBodySmall(
                                          null,
                                          (MediaQuery.of(context)
                                                      .platformBrightness ==
                                                  Brightness.dark)
                                              ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                              : Platform.isAndroid ? Colors.white : CupertinoColors.black,
                                          null,
                                          14),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      priceRange(),
                                      style: CustomTextStyles.getBodyBold(
                                          null,
                                          (MediaQuery.of(context)
                                                      .platformBrightness ==
                                                  Brightness.dark)
                                              ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                              : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                          14),
                                      softWrap: true,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'RERA ID: ${widget.project.applicationno}',
                                      style: CustomTextStyles.getBodySmall(
                                          null,
                                          (MediaQuery.of(context)
                                                      .platformBrightness ==
                                                  Brightness.dark)
                                              ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                              : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                          null,
                                          12),
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.project.proposed_completion_date
                                              .isBefore(DateTime.now())
                                          ? 'Ready to move in'
                                          : 'Ready by ${DateFormat.yMMM('en_US').format(widget.project.proposed_completion_date)}',
                                      style: CustomTextStyles.getBodySmall(
                                          null,
                                          (MediaQuery.of(context)
                                                      .platformBrightness ==
                                                  Brightness.dark)
                                              ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                              : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                          null,
                                          12),
                                    )
                                  ],
                                )
                              ],
                            ),
                            (!widget.project.vr_videos.contains("http") &&
                                    imgUrl
                                        .where((element) =>
                                            element.contains(".pdf"))
                                        .toList()
                                        .isEmpty &&
                                    !widget.project.videos.contains("http"))
                                ? const SizedBox()
                                : const SizedBox(
                                    height: 20,
                                  ),
                            (!widget.project.vr_videos.contains("http") &&
                                    imgUrl
                                        .where((element) =>
                                            element.contains(".pdf"))
                                        .toList()
                                        .isEmpty &&
                                    !widget.project.videos.contains("http"))
                                ? const SizedBox()
                                : Column(
                                    children: [
                                      if (widget.project.vr_videos
                                          .contains("http"))
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                      color: Platform.isAndroid ? Colors.purple : CupertinoColors.systemPurple,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50)),
                                                  child: Icon(
                                                      Icons.view_in_ar_outlined,
                                                      size: 16.0,
                                                      color: Platform.isAndroid ? Colors.white : CupertinoColors.white),
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  'Show Flat in 3D',
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
                                              ],
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 1,
                                                    color: Colors.grey[300]!),
                                              ),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.30,
                                              width: double.infinity,
                                              margin:
                                                  const EdgeInsets.only(top: 5),
                                              child: GestureDetector(
                                                onTap: () async {
                                                  final Uri url3D = Uri.parse(
                                                      widget.project.vr_videos);
                                                  if (await canLaunchUrl(
                                                      url3D)) {
                                                    await launchUrl(
                                                      url3D,
                                                      mode: LaunchMode
                                                          .inAppWebView,
                                                      webViewConfiguration:
                                                          const WebViewConfiguration(
                                                              enableJavaScript:
                                                                  true),
                                                    );
                                                  }
                                                  await FirebaseAnalytics
                                                      .instance
                                                      .logEvent(
                                                    name: "select_content",
                                                    parameters: {
                                                      "content_type": "media ",
                                                      "item_id": "3D",
                                                    },
                                                  );
                                                },
                                                child: AbsorbPointer(
                                                  child: FittedBox(
                                                      fit: BoxFit.fill,
                                                      child: Image.asset(
                                                          'assets/images/3d.jpg')),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (widget.project.vr_videos
                                          .contains("http"))
                                        const SizedBox(
                                          height: 10,
                                        ),
                                      if (imgUrl
                                          .where((element) =>
                                              element.contains(".pdf"))
                                          .toList()
                                          .isNotEmpty)
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                        color: Platform.isAndroid ? Colors.yellow : CupertinoColors.systemYellow,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50)),
                                                    child: Icon(
                                                        Icons
                                                            .description_outlined,
                                                        size: 16.0,
                                                        color: Platform.isAndroid ? Colors.white : CupertinoColors.white)),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  'Brochure',
                                                  style: CustomTextStyles.getH4(
                                                      null,
                                                      (MediaQuery.of(context)
                                                                  .platformBrightness ==
                                                              Brightness.dark)
                                                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                                          : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                                      null,
                                                      14),
                                                )
                                              ],
                                            ),
                                            Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.30,
                                              width: double.infinity,
                                              margin:
                                                  const EdgeInsets.only(top: 5),
                                              child: GestureDetector(
                                                onTap: () async {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (ctx) => OpenPdf(
                                                        imgUrl: imgUrl,
                                                      ),
                                                    ),
                                                  );
                                                  await FirebaseAnalytics
                                                      .instance
                                                      .logEvent(
                                                    name: "select_content",
                                                    parameters: {
                                                      "content_type": "media",
                                                      "item_id": "Brochure",
                                                    },
                                                  );
                                                },
                                                child: AbsorbPointer(
                                                  child: const PDF(
                                                    defaultPage: 0,
                                                    enableSwipe: false,
                                                  ).cachedFromUrl(
                                                      imgUrl
                                                          .where((element) =>
                                                              element.contains(
                                                                  '.pdf'))
                                                          .toList()[0],
                                                      placeholder:
                                                          (currentProgress) {
                                                    userProfileNotifier
                                                            .progress =
                                                        currentProgress;
                                                    return CircularPercentIndicator(
                                                      radius: 20,
                                                      lineWidth: 5,
                                                      percent:
                                                          currentProgress / 100,
                                                      progressColor:
                                                          globalColor,
                                                      backgroundColor:
                                                      Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                                                    );
                                                  }),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (imgUrl
                                          .where((element) =>
                                              element.contains(".pdf"))
                                          .toList()
                                          .isNotEmpty)
                                        const SizedBox(
                                          height: 10,
                                        ),
                                      if (widget.project.videos
                                          .contains("http"))
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                      color: Platform.isAndroid ? Colors.red : CupertinoColors.systemRed,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50)),
                                                  child: Icon(
                                                      Platform.isAndroid ? Icons.videocam : CupertinoIcons.video_camera,
                                                      size: 16.0,
                                                      color: Platform.isAndroid ? Colors.white : CupertinoColors.white),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  'Videos',
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
                                              ],
                                            ),
                                            Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.30,
                                              width: double.infinity,
                                              margin:
                                                  const EdgeInsets.only(top: 5),
                                              child: GestureDetector(
                                                onTap: () async {
                                                  final Uri urlVideos =
                                                      Uri.parse(widget
                                                          .project.videos);
                                                  if (await canLaunchUrl(
                                                      urlVideos)) {
                                                    await launchUrl(
                                                      urlVideos,
                                                      mode: LaunchMode
                                                          .inAppWebView,
                                                      webViewConfiguration:
                                                          const WebViewConfiguration(
                                                              enableJavaScript:
                                                                  true),
                                                    );
                                                  }
                                                  await FirebaseAnalytics
                                                      .instance
                                                      .logEvent(
                                                    name: "select_content",
                                                    parameters: {
                                                      "content_type": "media",
                                                      "item_id": "Video",
                                                    },
                                                  );
                                                },
                                                child: AbsorbPointer(
                                                  child: FittedBox(
                                                      fit: BoxFit.fill,
                                                      child: Image.network(
                                                          'https://img.youtube.com/vi/${widget.project.videos.substring(widget.project.videos.length - 11)}/0.jpg')),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
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
                            const SizedBox(height: 5),
                            Image.network(
                              staticMapImageUrl(
                                  widget.project.lat, widget.project.lng),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: Platform.isAndroid ? Colors.orange : CupertinoColors.systemOrange,
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    child: Icon(
                                      Platform.isAndroid ? Icons.home_outlined : CupertinoIcons.home,
                                      color: Platform.isAndroid ? Colors.white : CupertinoColors.white,
                                      size: 16,
                                    )),
                                const SizedBox(width: 5),
                                Text(
                                  'Units (As on ${DateFormat('dd-MM-yyyy').format(widget.project.last_modified_date)})',
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
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            // if(isAvailableSelected)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${widget.project.sanctioned_bldg_count} building(s)',
                                  style: CustomTextStyles.getBodySmall(
                                      null,
                                      (MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.dark)
                                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                          : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                      FontWeight.w600,
                                      14),
                                ),
                                Text(
                                  '${widget.project.total_num_apts} total units',
                                  style: CustomTextStyles.getBodySmall(
                                      null,
                                      (MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.dark)
                                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                          : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                      FontWeight.w600,
                                      14),
                                ),
                                Text(
                                  '${widget.project.total_num_apts - widget.project.total_bkd_apts} avlb. units',
                                  style: CustomTextStyles.getBodySmall(
                                      null,
                                      (MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.dark)
                                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                          : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                      FontWeight.w600,
                                      14),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Type',
                                  style: CustomTextStyles.getBodySmall(
                                      null,
                                      (MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.dark)
                                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                          : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                      FontWeight.w600,
                                      14),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                      text: 'Min carpet',
                                      style: CustomTextStyles.getBodySmall(
                                          null,
                                          (MediaQuery.of(context)
                                                      .platformBrightness ==
                                                  Brightness.dark)
                                              ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                              : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                          FontWeight.w600,
                                          14),
                                    ),
                                    TextSpan(
                                      text: '\narea (sq.ft.)',
                                      style: CustomTextStyles.getBodySmall(
                                          null,
                                          (MediaQuery.of(context)
                                                      .platformBrightness ==
                                                  Brightness.dark)
                                              ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                              : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                          FontWeight.w600,
                                          14),
                                    )
                                  ]),
                                  maxLines: 2,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                      text: 'Max carpet',
                                      style: CustomTextStyles.getBodySmall(
                                          null,
                                          (MediaQuery.of(context)
                                                      .platformBrightness ==
                                                  Brightness.dark)
                                              ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                              : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                          FontWeight.w600,
                                          14),
                                    ),
                                    TextSpan(
                                      text: '\narea (sq.ft.)',
                                      style: CustomTextStyles.getBodySmall(
                                          null,
                                          (MediaQuery.of(context)
                                                      .platformBrightness ==
                                                  Brightness.dark)
                                              ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                              : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                          FontWeight.w600,
                                          14),
                                    )
                                  ]),
                                  maxLines: 3,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                      text: 'Total',
                                      style: CustomTextStyles.getBodySmall(
                                          null,
                                          (MediaQuery.of(context)
                                                      .platformBrightness ==
                                                  Brightness.dark)
                                              ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                              : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                          FontWeight.w600,
                                          14),
                                    ),
                                    TextSpan(
                                      text: '\nUnits',
                                      style: CustomTextStyles.getBodySmall(
                                          null,
                                          (MediaQuery.of(context)
                                                      .platformBrightness ==
                                                  Brightness.dark)
                                              ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                              : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                          FontWeight.w600,
                                          14),
                                    )
                                  ]),
                                  maxLines: 2,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                      text: 'Available',
                                      style: CustomTextStyles.getBodySmall(
                                          null,
                                          (MediaQuery.of(context)
                                                      .platformBrightness ==
                                                  Brightness.dark)
                                              ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                              : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                          FontWeight.w600,
                                          14),
                                    ),
                                    TextSpan(
                                      text: '\nUnits',
                                      style: CustomTextStyles.getBodySmall(
                                          null,
                                          (MediaQuery.of(context)
                                                      .platformBrightness ==
                                                  Brightness.dark)
                                              ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                              : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                          FontWeight.w600,
                                          14),
                                    )
                                  ]),
                                  maxLines: 2,
                                ),
                              ],
                            ),
                            SizedBox(
                              // height: 500,
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (ctx, i) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        '${(autoCompleteNotifier.projectInventoryList.distinct((e) => e.building_name!).toList()..sort((a, b) => a.building_name!.compareTo(b.building_name!))).toList()[i].building_name}:',
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
                                      ProjectInventoryDetails(
                                          buildingName: (autoCompleteNotifier
                                                  .projectInventoryList
                                                  .distinct(
                                                      (e) => e.building_name!)
                                                  .toList()
                                                ..sort((a, b) =>
                                                    a.building_name!.compareTo(
                                                        b.building_name!)))
                                              .toList()[i]
                                              .building_name!,
                                          projectId: widget.project.id),
                                    ],
                                  );
                                },
                                itemCount: autoCompleteNotifier
                                    .projectInventoryList
                                    .distinct((e) => e.building_name!)
                                    .toList()
                                    .length,
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
                            const SizedBox(
                              height: 5,
                            ),
                            // if (isHomeLoanSelected)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Interest Rate (% per annum)',
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
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(right: 20),
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
                                              double.parse(
                                                  value.toStringAsFixed(2));
                                          emiNotifier.R =
                                              emiNotifier.interestSliderValue /
                                                  12 /
                                                  100;

                                          emiNotifier.calculateMonthlyEmi();
                                          emiNotifier.calculateEmiPerLac();
                                        },
                                      );
                                    },
                                  ),
                                if(Platform.isIOS)
                                SizedBox(
                                   width: double.infinity,
                                  child: CupertinoSlider(
                                    thumbColor: CupertinoColors.white,
                                    activeColor: globalColor,
                                    // inactiveColor: CupertinoColors.systemGrey,
                                    min: 0.0,
                                    max: 15.0,
                                    value: emiNotifier.interestSliderValue,
                                    onChanged: (value) {
                                      setState(
                                        () {
                                          emiNotifier.interestSliderValue =
                                              double.parse(
                                                  value.toStringAsFixed(2));
                                          emiNotifier.R =
                                              emiNotifier.interestSliderValue /
                                                  12 /
                                                  100;

                                          emiNotifier.calculateMonthlyEmi();
                                          emiNotifier.calculateEmiPerLac();
                                        },
                                      );
                                    },
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Tenure (Years)',
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
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(right: 20),
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
                                        emiNotifier.tenureSliderValue =
                                            value.toInt();
                                        emiNotifier.N =
                                            emiNotifier.tenureSliderValue * 12;
                                        emiNotifier.calculateMonthlyEmi();
                                        emiNotifier.calculateEmiPerLac();
                                      });
                                    },
                                  ),
                                if(Platform.isIOS)
                                SizedBox(
                                  width:double.infinity,
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
                                        emiNotifier.tenureSliderValue =
                                            value.toInt();
                                        emiNotifier.N =
                                            emiNotifier.tenureSliderValue * 12;
                                        emiNotifier.calculateMonthlyEmi();
                                        emiNotifier.calculateEmiPerLac();
                                      });
                                    },
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'EMI per lakh',
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
                                      'Loan Amount in lakh',
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
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                                  double.parse(value.toString()) <
                                                      1) {
                                                // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a value between 1 - 999')));
                                                return 'range is 1 - 999';
                                              }
                                              return null;
                                            },
                                            inputFormatters: [
                                              // DecimalTextInputFormatter(
                                              //     decimalRange: 2),
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(
                                                      r'^\d{1,3}(\.\d{0,2})?')),
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
                                                  emiNotifier
                                                      .calculateMonthlyEmi();
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
                                              if (double.parse(
                                                          value.toString()) >
                                                      999.99 ||
                                                  double.parse(
                                                          value.toString()) <
                                                      1) {
                                                return 'range is 1 - 999';
                                              }
                                              return null;
                                            },
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(
                                                      r'^\d{1,3}(\.\d{0,2})?')),
                                              FilteringTextInputFormatter.deny(
                                                  RegExp(r'^0+')),
                                            ],
                                            textAlign: TextAlign.center,
                                            // decoration: const InputDecoration(
                                            //   counterText: "",
                                            // ),
                                            // // initialValue: "50",
                                            maxLength: 6,
                                            keyboardType: TextInputType.number,
                                            onChanged: (value) {
                                              setState(() {
                                                if (double.parse(value) <=
                                                    999) {
                                                  form.currentState?.validate();
                                                  emiNotifier.loanAmount =
                                                      (double.tryParse(value)! *
                                                          100000);
                                                  emiNotifier
                                                      .calculateMonthlyEmi();
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
                                        padding:
                                            const EdgeInsets.only(right: 10),
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
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.80,
                              child: Text(
                                'Builder ${widget.project.builder_id != 0 ? widget.project.builder_name : widget.project.promoter_name}',
                                style: CustomTextStyles.getH4(
                                    null,
                                    (MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.dark)
                                        ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                        : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                    null,
                                    14),
                                maxLines: 2,
                              ),
                            ),
                            // const SizedBox(height: 5),
                            // Text(
                            //   ,
                            //   style: const TextStyle(fontSize: 13),
                            //   maxLines: 2,
                            // ),
                            // : Container(),
                            const SizedBox(
                              height: 20,
                            ),

                            Text(
                              'Locality ${widget.project.project_village}',
                              style: CustomTextStyles.getH4(
                                  null,
                                  (MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark)
                                      ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                      : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                  null,
                                  14),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              'City ${widget.project.project_district}',
                              style: CustomTextStyles.getH4(
                                  null,
                                  (MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark)
                                      ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                      : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                  null,
                                  14),
                            ),
                            const SizedBox(
                              height: 80,
                            ),
                          ],
                        ),
                      ),
                    ]),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker() {
    final autoCompleteNotifier =
        Provider.of<AutocompleteNotifier>(context, listen: false);
    showDatePicker(
            context: context,
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: globalColor, // header background color
                    onPrimary: Colors.white, // header text color
                    onSurface: (MediaQuery.of(context).platformBrightness ==
                            Brightness.dark)
                        ? Colors.white
                        : Colors.black, // body text color
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: globalColor, // button text color
                    ),
                  ),
                ),
                child: child ?? const SizedBox(),
              );
            },
            initialDate: DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day + 1),
            firstDate: DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day + 1),
            lastDate: DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day + 1)
                .add(const Duration(days: 15)))
        .then((pickedDate) {
      if (pickedDate == null) {
        return;
      } else {
        // setState(() {
        autoCompleteNotifier.setSelectedDate(pickedDate);
        // });
        if(autoCompleteNotifier.selectedDate == null) {
          return;
        } else {
          Navigator.of(context)
              .push(MaterialPageRoute(
              builder: (ctx) => BookAVisit(
                project: widget.project,
                appBarTitle: "Book Site Visit",
                isComingFromContactUs: false,
              )))
              .then((value) {
            // setState(() {
            autoCompleteNotifier.setSelectedDate(null);
            // });
          });
        }
      }
    });
  }

  getLikedProjects() async {
    final likedProjectsNotifier =
        Provider.of<LikedProjectsNotifier>(context, listen: false);
    setState(() {
      isLoading = true;
    });
    likedProjectsNotifier.getLikedProjects(context).whenComplete(() {
      if (likedProjectsNotifier.likedProjectsList.isNotEmpty) {
        if (likedProjectsNotifier.likedProjectsList
            .where((element) => element.id == widget.project.id)
            .toList()
            .isNotEmpty) {
          likedProjectsNotifier.isLiked = true;
        } else {
          likedProjectsNotifier.isLiked = false;
        }
      } else {
        likedProjectsNotifier.isLiked = false;
      }
      setState(() {
        isLoading = false;
      });
    });
    // Future.delayed(const Duration(milliseconds: 3000), (){

    // })
  }

  getProjectInventory() async {
    final autoCompleteNotifier =
        Provider.of<AutocompleteNotifier>(context, listen: false);
    autoCompleteNotifier.getProjectInventory(widget.project.id);
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

  String staticMapImageUrl(double lat, double long) {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$long&zoom=15&size=600x300&maptype=roadmap&markers=color:red%7C$lat,$long&key=AIzaSyCw5bNd2XOJxMPbSG8Jr_-TPnQKeRkuO2A';
  }
}

class PhotoFullScreen extends StatefulWidget {
  final String imgUrl;

  const PhotoFullScreen({
    Key? key,
    required this.imgUrl,
  }) : super(key: key);

  @override
  State<PhotoFullScreen> createState() => _PhotoFullScreenState();
}

class _PhotoFullScreenState extends State<PhotoFullScreen> {
  final _transformationController = TransformationController();
  late TapDownDetails _doubleTapDetails;

  @override
  initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Platform.isAndroid ? PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
        backgroundColor: (MediaQuery.of(context).platformBrightness ==
            Brightness.dark)
            ? Colors.grey[900]
            : CupertinoColors.white,
      )) : CupertinoNavigationBar(
        backgroundColor: (MediaQuery.of(context).platformBrightness ==
            Brightness.dark)
            ? Colors.grey[900]
            : CupertinoColors.white,
      ),
      body: Stack(
        children: [
          GestureDetector(
            onDoubleTapDown: _handleDoubleTapDown,
            onDoubleTap: _handleDoubleTap,
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.5,
              maxScale: 4,
              child: PageView(
                children: [
                  // ...widget.url.map(
                  //       (e) =>
                  FittedBox(
                    fit: BoxFit.fitWidth,
                    child: CachedNetworkImage(
                      imageUrl: widget.imgUrl,
                      fadeInDuration: const Duration(milliseconds: 10),
                      fadeOutDuration: const Duration(milliseconds: 10),
                    ),
                  ),
                  // ),
                ],
                // child: ,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails.localPosition;
      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx * 3, -position.dy * 3)
        ..scale(4.0);
    }
  }
}

class PhotoList extends StatefulWidget {
  final List<String> imgUrl;

  const PhotoList({
    Key? key,
    required this.imgUrl,
  }) : super(key: key);

  @override
  State<PhotoList> createState() => _PhotoListState();
}

class _PhotoListState extends State<PhotoList> {
  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print(widget.imgUrl);
    }
    return Scaffold(
      appBar: Platform.isAndroid ? PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: AppBar(
            backgroundColor: (MediaQuery.of(context).platformBrightness ==
                Brightness.dark)
                ? Colors.grey[900]
                : CupertinoColors.white,
          )) : CupertinoNavigationBar(
        backgroundColor: (MediaQuery.of(context).platformBrightness ==
          Brightness.dark)
        ? Colors.grey[900]
        : CupertinoColors.white,
        middle: Text(
          '${widget.imgUrl.length} photos',
          style: const TextStyle(fontSize: 18),
        ),
      ),
      body: ListView.builder(
        itemBuilder: (ctx, i) {
          return FittedBox(
            child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => PhotoFullScreen(
                        imgUrl: widget.imgUrl[i],
                        // index: i,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  height: 120,
                  width: 200,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: CachedNetworkImage(
                      imageUrl: widget.imgUrl[i],
                      memCacheHeight:
                          (200 * MediaQuery.of(context).devicePixelRatio)
                              .round(),
                      memCacheWidth:
                          (200 * MediaQuery.of(context).devicePixelRatio)
                              .round(),
                      fadeInDuration: const Duration(milliseconds: 10),
                      fadeOutDuration: const Duration(milliseconds: 10),
                    ),
                  ),
                )),
          );
        },
        itemCount: widget.imgUrl.length,
      ),
    );
  }
}

class ShimmerWidget extends StatelessWidget {
  const ShimmerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 1.0),
        child: Shimmer.fromColors(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        height: 220,
                        color: Colors.grey[300]!,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 10),
                        width: 50,
                        height: 5,
                        color: Colors.grey[300]!,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 10),
                        width: 100,
                        height: 5,
                        color: Colors.grey[300]!,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 120,
                                  height: 20,
                                  color: Colors.grey[300]!,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: 50,
                                  height: 10,
                                  color: Colors.grey[300]!,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  height: 10,
                                  width: 30,
                                  color: Colors.grey[300]!,
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 50,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  height: 20,
                                  width: 100,
                                  color: Colors.grey[300]!,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  height: 10,
                                  width: 50,
                                  color: Colors.grey[300]!,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  height: 10,
                                  width: 30,
                                  color: Colors.grey[300]!,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: double.infinity,
                        height: 220,
                        color: Colors.grey[300]!,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: double.infinity,
                        height: 100,
                        color: Colors.grey[300]!,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            itemCount: 1,
          ),
        ),
      ),
    );
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({required this.decimalRange})
      : assert(decimalRange == null || decimalRange > 0);

  final int? decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    if (decimalRange != null) {
      String value = newValue.text;

      if (value.contains(".") &&
          value.substring(value.indexOf(".") + 1).length > decimalRange!) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      } else if (value == ".") {
        truncated = "0.";

        newSelection = newValue.selection.copyWith(
          baseOffset: math.min(truncated.length, truncated.length + 1),
          extentOffset: math.min(truncated.length, truncated.length + 1),
        );
      }

      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    return newValue;
  }
}
