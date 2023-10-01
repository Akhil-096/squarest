import 'dart:async';
import 'dart:io';
import 'package:squarest/Utils/u_open_pdf.dart';
import 'package:squarest/Views/v_all_mem_plans.dart';
import 'package:squarest/Views/v_horizontal_list_card.dart';
import 'package:squarest/Views/v_horizontal_property_card.dart';
import 'package:squarest/Views/v_liked_projects.dart';
import 'package:squarest/Views/v_liked_resale_projects.dart';
import 'package:squarest/Views/v_know_more_mem_plan.dart';
import 'package:squarest/Views/v_nav_page_list.dart';
import 'package:squarest/Views/v_add_reasale_property.dart';
import 'package:squarest/Views/v_nav_page_mysquare.dart';
import 'package:squarest/Views/v_user_profile.dart';
import 'package:flutter/gestures.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Services/s_autocomplete_notifier.dart';
import '../Services/s_liked_projects_notifier.dart';
import '../Services/s_resale_property_notifier.dart';
import '../Utils/u_constants.dart';
import '../Utils/u_custom_styles.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';


const String _kStandardSubscriptionId = 'standard_subscription_plan';
// const String _kPremiumSubscriptionId = 'premium_subscription_plan';

const List<String> _kProductIds = <String>[
  // _kBasicSubscriptionId,
  _kStandardSubscriptionId,
  // _kPremiumSubscriptionId,
];

class UserAccount extends StatefulWidget {
  const UserAccount({Key? key}) : super(key: key);

  @override
  State<UserAccount> createState() => _UserAccountState();
}

class _UserAccountState extends State<UserAccount> {
  final likedNewProjectsTitle = 'New Projects';
  final likedResaleProjectsTitle = 'Resale Projects';
  int currentProjectPage = 1;
  int currentResalePage = 1;
  bool isLoading = false;
  late bool isBenefitsClicked;
  late bool isNewClicked;
  late bool isResaleClicked;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<String> _notFoundIds = <String>[];
  List<ProductDetails> _products = <ProductDetails>[];
  List<PurchaseDetails> _purchases = <PurchaseDetails>[];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String? _queryProductError;
  bool checkBoxValue = false;
  bool checkBoxValidation = true;
  String selectedCityAndroid = 'Pune';
  String selectedValidityAndroid = '3 months';
  int selectedCity = 0;

  @override
  void initState() {
    super.initState();
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription =
        purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (Object error) {
      Fluttertoast.showToast(
        msg: error.toString(),
        backgroundColor:
            Platform.isAndroid ? Colors.white : CupertinoColors.white,
        textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
      );
    });
    initStoreInfo();
    final resalePropertyNotifier =
        Provider.of<ResalePropertyNotifier>(context, listen: false);
    final likedProjectsNotifier =
        Provider.of<LikedProjectsNotifier>(context, listen: false);
    if (!likedProjectsNotifier.isNavigatingToProfile) {
      setState(() {
        isLoading = true;
      });
      resalePropertyNotifier.getMemPlans(context);
      if (kDebugMode) {
        print(resalePropertyNotifier.memPlans);
      }
      getLikedProjects();
      getLikedResaleProjects();
    }
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  void handleError(IAPError error) {
    setState(() {
      _purchasePending = false;
    });
    Fluttertoast.showToast(
      msg: 'Something went wrong !',
      backgroundColor:
          Platform.isAndroid ? Colors.white : CupertinoColors.white,
      textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
    );
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    Fluttertoast.showToast(
      msg: 'Invalid Purchase !',
      backgroundColor:
          Platform.isAndroid ? Colors.white : CupertinoColors.white,
      textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
    );
  }

  Future<void> deliverProduct(PurchaseDetails purchaseDetails) async {
    final resalePropertyNotifier =
        Provider.of<ResalePropertyNotifier>(context, listen: false);
    DateTime createdDate = DateTime.now();
    setState(() {
      _purchases.add(purchaseDetails);
      _purchasePending = false;
    });
    var endingDate =
        DateTime(createdDate.year, createdDate.month + 3, createdDate.day);
    resalePropertyNotifier
        .insertMemPlan(context, 'Select', 3, 5999, createdDate, endingDate)
        .then((_) {
      resalePropertyNotifier.getMemPlans(context);
      // Navigator.of(context).pop();
      Fluttertoast.showToast(
        msg: 'Successfully purchased !',
        backgroundColor:
            Platform.isAndroid ? Colors.white : CupertinoColors.white,
        textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
      );
    });
  }

  void showPendingUI() {
    setState(() {
      _purchasePending = true;
    });
  }

  Future<void> initStoreInfo() async {
    // final resalePropertyNotifier =
    //     Provider.of<ResalePropertyNotifier>(context, listen: false);
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = <ProductDetails>[];
        _purchases = <PurchaseDetails>[];
        _notFoundIds = <String>[];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
      _inAppPurchase
          .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    final ProductDetailsResponse productDetailResponse =
        await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      setState(() {
        _queryProductError = productDetailResponse.error!.message;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = <PurchaseDetails>[];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _queryProductError = null;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = <PurchaseDetails>[];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    setState(() {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _notFoundIds = productDetailResponse.notFoundIDs;
      _purchasePending = false;
      _loading = false;
      // final ProductDetails secondItem = _products.removeAt(1);
      // _products = _products..add(secondItem);
    });
    // resalePropertyNotifier.memPlan = _products[0];
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
      _inAppPurchase
          .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _subscription.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    final resalePropertyNotifier = Provider.of<ResalePropertyNotifier>(context);
    final likedProjectsNotifier = Provider.of<LikedProjectsNotifier>(context);
    if (resalePropertyNotifier.memPlans.isEmpty ||
        (resalePropertyNotifier.memPlans.isNotEmpty &&
            !DateTime.now()
                .isBefore(resalePropertyNotifier.memPlans[0].ending_on))) {
      setState(() {
        isBenefitsClicked = true;
      });
    } else {
      setState(() {
        isBenefitsClicked = false;
      });
    }
    if (likedProjectsNotifier.likedProjectsList.isEmpty) {
      setState(() {
        isNewClicked = false;
      });
    } else {
      setState(() {
        isNewClicked = true;
      });
    }
    if (likedProjectsNotifier.likedResalePropertyList.isEmpty) {
      setState(() {
        isResaleClicked = false;
      });
    } else {
      setState(() {
        isResaleClicked = true;
      });
    }
    setState(() {
      isLoading = false;
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final resalePropertyNotifier = Provider.of<ResalePropertyNotifier>(context);
    final likedProjectsNotifier = Provider.of<LikedProjectsNotifier>(context);
    final autocompleteNotifier = Provider.of<AutocompleteNotifier>(context);
    return Scaffold(
      appBar: Platform.isAndroid
          ? AppBar(
              scrolledUnderElevation: 0.0,
              backgroundColor:
                  (MediaQuery.of(context).platformBrightness == Brightness.dark)
                      ? Colors.grey[900]
                      : Colors.white,
              primary: true,
              automaticallyImplyLeading: false,
              actions: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        likedProjectsNotifier.isNavigatingToProfile = true;
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (ctx) => const AddResaleProperty()))
                            .then((value) {
                          likedProjectsNotifier.isNavigatingToProfile = false;
                        });
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.home_outlined,
                            size: 30,
                          ),
                          Text('My Property',
                              style: CustomTextStyles.getTitle(
                                  null,
                                  (MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark)
                                      ? Platform.isAndroid
                                          ? Colors.white
                                          : CupertinoColors.white
                                      : Platform.isAndroid
                                          ? Colors.black
                                          : CupertinoColors.black,
                                  null,
                                  null),)
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    GestureDetector(
                      onTap: () {
                        likedProjectsNotifier.isNavigatingToProfile = true;
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (ctx) => const UserProfile(
                                      isComingFromAccountScreen: true,
                                    )))
                            .then((value) {
                          likedProjectsNotifier.isNavigatingToProfile = false;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.face,
                              size: 30,
                            ),
                            Text('Profile',
                              style: CustomTextStyles.getTitle(
                                  null,
                                  (MediaQuery.of(context).platformBrightness ==
                                      Brightness.dark)
                                      ? Platform.isAndroid
                                      ? Colors.white
                                      : CupertinoColors.white
                                      : Platform.isAndroid
                                      ? Colors.black
                                      : CupertinoColors.black,
                                  null,
                                  null),)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : PreferredSize(
              preferredSize: const Size.fromHeight(90),
              child: SizedBox(
                height: 90,
                child: CupertinoNavigationBar(
                  padding: EdgeInsetsDirectional.zero,
                  backgroundColor: (MediaQuery.of(context).platformBrightness ==
                          Brightness.dark)
                      ? Colors.grey[900]
                      : CupertinoColors.white,
                  trailing: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          likedProjectsNotifier.isNavigatingToProfile = true;
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (ctx) => const AddResaleProperty()))
                              .then((value) {
                            likedProjectsNotifier.isNavigatingToProfile = false;
                          });
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              CupertinoIcons.home,
                              size: 30,
                            ),
                            Text('My Property',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: (MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.dark)
                                        ? CupertinoColors.white
                                        : CupertinoColors.black))
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      GestureDetector(
                        onTap: () {
                          likedProjectsNotifier.isNavigatingToProfile = true;
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (ctx) => const UserProfile(
                                        isComingFromAccountScreen: true,
                                      )))
                              .then((value) {
                            likedProjectsNotifier.isNavigatingToProfile = false;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 15),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.face,
                                size: 30,
                              ),
                              Text('Profile',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: (MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.dark)
                                          ? CupertinoColors.white
                                          : CupertinoColors.black))
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      body: SafeArea(
        child: isLoading
            ? const AccountScreenShimmer()
            : WillPopScope(
                onWillPop: autocompleteNotifier.onWillPop,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 10, right: 10, top: 5),
                        child: Text(
                          'Saved Properties',
                          style: CustomTextStyles.getTitle(
                              null,
                              (MediaQuery.of(context).platformBrightness ==
                                      Brightness.dark)
                                  ? Platform.isAndroid
                                      ? Colors.white
                                      : CupertinoColors.white
                                  : Platform.isAndroid
                                      ? Colors.black
                                      : CupertinoColors.black,
                              null,
                              19),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isNewClicked = !isNewClicked;
                              });
                            },
                            child: Container(
                              height: 40,
                              width: 100,
                              padding: const EdgeInsets.only(
                                left: 10,
                              ),
                              child: Card(
                                color: (MediaQuery.of(context)
                                            .platformBrightness ==
                                        Brightness.dark)
                                    ? Colors.grey[800]
                                    : Colors.grey[100],
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    const Text(
                                      'New',
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      height: 25,
                                      width: 25,
                                      padding: const EdgeInsets.all(5),
                                      decoration: const BoxDecoration(
                                          color: globalColor,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(50))),
                                      child: Icon(
                                        size: 15,
                                        isNewClicked
                                            ? Platform.isAndroid
                                                ? Icons.remove
                                                : CupertinoIcons.minus
                                            : Platform.isAndroid
                                                ? Icons.add
                                                : CupertinoIcons.add,
                                        color: Platform.isAndroid
                                            ? Colors.white
                                            : CupertinoColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          if (isNewClicked)
                            SizedBox(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10, bottom: 2.5),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (ctx) =>
                                                      LikedProjectsList(
                                                        appBarTitle:
                                                            likedNewProjectsTitle,
                                                      )),
                                            );
                                          },
                                          child: Text('View all',
                                              style: CustomTextStyles.getTitle(
                                                  null,
                                                  (MediaQuery.of(context)
                                                              .platformBrightness ==
                                                          Brightness.dark)
                                                      ? Platform.isAndroid
                                                          ? Colors.white
                                                          : CupertinoColors
                                                              .white
                                                      : Platform.isAndroid
                                                          ? Colors.black
                                                          : CupertinoColors
                                                              .black,
                                                  TextDecoration.underline,
                                                  14)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Flexible(
                                    child: SizedBox(
                                      height: 250,
                                      child: likedProjectsNotifier.isLoading
                                          ? const NavListShimmer()
                                          : likedProjectsNotifier
                                                  .likedProjectsList.isEmpty
                                              ? const Center(
                                                  child: Text(
                                                      'No new project saved yet. Save it to see it here.'))
                                              : PageView.builder(
                                                  controller: PageController(
                                                      viewportFraction: 1 / 2),
                                                  padEnds: false,
                                                  onPageChanged: (page) {
                                                    setState(() {
                                                      currentProjectPage = (page %
                                                              likedProjectsNotifier
                                                                  .likedProjectsList
                                                                  .length) +
                                                          1;
                                                    });
                                                  },
                                                  itemBuilder: (ctx, i) {
                                                    return GestureDetector(
                                                      onTap: () async {
                                                        FocusScope.of(context)
                                                            .unfocus();
                                                        autocompleteNotifier
                                                                .projectForBottomSheet =
                                                            likedProjectsNotifier
                                                                    .likedProjectsList[
                                                                i %
                                                                    likedProjectsNotifier
                                                                        .likedProjectsList
                                                                        .length];
                                                        autocompleteNotifier
                                                            .openBottomSheet(
                                                                context);
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 3.5),
                                                        child:
                                                            HorizontalListCard(
                                                          project: likedProjectsNotifier
                                                                  .likedProjectsList[
                                                              i %
                                                                  likedProjectsNotifier
                                                                      .likedProjectsList
                                                                      .length],
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                    ),
                                  ),
                                  if (likedProjectsNotifier
                                      .likedProjectsList.isNotEmpty)
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  if (likedProjectsNotifier
                                      .likedProjectsList.isNotEmpty)
                                    Center(
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            left: 5, right: 5),
                                        height: 20,
                                        // width: 90,
                                        decoration: BoxDecoration(
                                          color: (MediaQuery.of(context)
                                                      .platformBrightness ==
                                                  Brightness.dark)
                                              ? Platform.isAndroid
                                                  ? Colors.grey
                                                  : CupertinoColors.systemGrey
                                              : Platform.isAndroid
                                                  ? Colors.black54
                                                  : CupertinoColors
                                                      .darkBackgroundGray,
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                        ),
                                        child: Text(
                                          '$currentProjectPage/${likedProjectsNotifier.likedProjectsList.length}',
                                          style: TextStyle(
                                              color: Platform.isAndroid
                                                  ? Colors.white
                                                  : CupertinoColors.white),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          const SizedBox(
                            height: 5,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isResaleClicked = !isResaleClicked;
                              });
                            },
                            child: Container(
                              height: 40,
                              width: 115,
                              padding: const EdgeInsets.only(
                                left: 10,
                              ),
                              child: Card(
                                color: (MediaQuery.of(context)
                                            .platformBrightness ==
                                        Brightness.dark)
                                    ? Colors.grey[800]
                                    : Colors.grey[100],
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    const Text(
                                      'Resale',
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      height: 25,
                                      width: 25,
                                      padding: const EdgeInsets.all(5),
                                      decoration: const BoxDecoration(
                                          color: globalColor,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(50))),
                                      child: Icon(
                                        size: 15,
                                        isResaleClicked
                                            ? Platform.isAndroid
                                                ? Icons.remove
                                                : CupertinoIcons.minus
                                            : Platform.isAndroid
                                                ? Icons.add
                                                : CupertinoIcons.add,
                                        color: Platform.isAndroid
                                            ? Colors.white
                                            : CupertinoColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          if (isResaleClicked)
                            SizedBox(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, bottom: 2.5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (ctx) =>
                                                      LikedResalePropertyList(
                                                        appBarTitle:
                                                            likedResaleProjectsTitle,
                                                      )),
                                            );
                                          },
                                          child: Text('View all',
                                              style: CustomTextStyles.getTitle(
                                                  null,
                                                  (MediaQuery.of(context)
                                                              .platformBrightness ==
                                                          Brightness.dark)
                                                      ? Platform.isAndroid
                                                          ? Colors.white
                                                          : CupertinoColors
                                                              .white
                                                      : Platform.isAndroid
                                                          ? Colors.black
                                                          : CupertinoColors
                                                              .black,
                                                  TextDecoration.underline,
                                                  14)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    child: SizedBox(
                                      height: 250,
                                      child: likedProjectsNotifier
                                              .isResaleLoading
                                          ? const NavListShimmer()
                                          : likedProjectsNotifier
                                                  .likedResalePropertyList
                                                  .isEmpty
                                              ? const Center(
                                                  child: Text(
                                                      'No resale property saved yet. Save it to see it here.'))
                                              : PageView.builder(
                                                  controller: PageController(
                                                      viewportFraction: 1 / 2),
                                                  padEnds: false,
                                                  onPageChanged: (page) {
                                                    setState(() {
                                                      currentResalePage = (page %
                                                              likedProjectsNotifier
                                                                  .likedResalePropertyList
                                                                  .length) +
                                                          1;
                                                    });
                                                  },
                                                  itemBuilder: (ctx, i) {
                                                    return GestureDetector(
                                                      onTap: () async {
                                                        FocusScope.of(context)
                                                            .unfocus();
                                                        autocompleteNotifier
                                                                .propertyForBottomSheet =
                                                            likedProjectsNotifier
                                                                    .likedResalePropertyList[
                                                                i %
                                                                    likedProjectsNotifier
                                                                        .likedResalePropertyList
                                                                        .length];
                                                        autocompleteNotifier
                                                            .openResaleBottomSheet(
                                                                context, true);
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 3.5),
                                                        child:
                                                            HorizontalPropertyCard(
                                                          resalePropertyModel:
                                                              likedProjectsNotifier
                                                                      .likedResalePropertyList[
                                                                  i %
                                                                      likedProjectsNotifier
                                                                          .likedResalePropertyList
                                                                          .length],
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                    ),
                                  ),
                                  if (likedProjectsNotifier
                                      .likedResalePropertyList.isNotEmpty)
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  if (likedProjectsNotifier
                                      .likedResalePropertyList.isNotEmpty)
                                    Center(
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            left: 5, right: 5),
                                        height: 20,
                                        // width: 90,
                                        decoration: BoxDecoration(
                                          color: (MediaQuery.of(context)
                                                      .platformBrightness ==
                                                  Brightness.dark)
                                              ? Platform.isAndroid
                                                  ? Colors.grey
                                                  : CupertinoColors.systemGrey
                                              : Platform.isAndroid
                                                  ? Colors.black54
                                                  : CupertinoColors
                                                      .darkBackgroundGray,
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                        ),
                                        child: Text(
                                          '$currentResalePage/${likedProjectsNotifier.likedResalePropertyList.length}',
                                          style: TextStyle(
                                              color: Platform.isAndroid
                                                  ? Colors.white
                                                  : CupertinoColors.white),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ExpansionTile(
                        tilePadding: const EdgeInsets.all(5),
                        collapsedIconColor: (MediaQuery.of(context).platformBrightness ==
                            Brightness.dark)
                            ? Platform.isAndroid ? Colors.white : CupertinoColors.white : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                        iconColor: (MediaQuery.of(context).platformBrightness ==
                            Brightness.dark)
                            ? Platform.isAndroid ? Colors.white : CupertinoColors.white : CupertinoColors.black,
                        childrenPadding: (resalePropertyNotifier
                            .memPlans.isNotEmpty &&
                            DateTime.now().isBefore(
                                resalePropertyNotifier
                                    .memPlans[0].ending_on)) ? const EdgeInsets.only(left: 5, right: 5) : const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        title: Text(
                          'Select Membership',
                          style: CustomTextStyles.getTitle(
                              null,
                              (MediaQuery.of(context).platformBrightness ==
                                      Brightness.dark)
                                  ? Platform.isAndroid
                                      ? Colors.white
                                      : CupertinoColors.white
                                  : Platform.isAndroid
                                      ? Colors.black
                                      : CupertinoColors.black,
                              null,
                              19),
                        ),
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (Platform.isIOS &&
                                  (resalePropertyNotifier.memPlans.isEmpty ||
                                      !DateTime.now().isBefore(
                                          resalePropertyNotifier
                                              .memPlans[0].ending_on)))
                                Container(
                                  margin:
                                  const EdgeInsets.only(left: 5, top: 10),
                                  child: CupertinoButton(
                                    borderRadius: BorderRadius.circular(25),
                                    color: globalColor,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (ctx) =>
                                            const KnowMoreMemPlan(
                                              isComingFromJoinNow: true,
                                              isComingFromKnowMore: false,
                                              // isComingFromUserAccount: true,
                                            )),
                                      );
                                    },
                                    child: Text('Know More',
                                        style: TextStyle(
                                            color: Platform.isAndroid
                                                ? Colors.white
                                                : CupertinoColors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              if (Platform.isAndroid &&
                                  (resalePropertyNotifier.memPlans.isEmpty ||
                                      !DateTime.now().isBefore(
                                          resalePropertyNotifier
                                              .memPlans[0].ending_on)))
                                Container(
                                  height: 60,
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(
                                      left: 5, top: 10, right: 150),
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                        foregroundColor: Colors.black,
                                        backgroundColor: globalColor),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (ctx) =>
                                            const KnowMoreMemPlan(
                                              isComingFromJoinNow: true,
                                              isComingFromKnowMore: false,
                                              // isComingFromUserAccount: true,
                                            )),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8, bottom: 8),
                                      child: Text('Know More',
                                          style: TextStyle(
                                              color: Platform.isAndroid
                                                  ? Colors.white
                                                  : CupertinoColors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                              const SizedBox(
                                height: 10,
                              ),
                              resalePropertyNotifier.isPlansLoading
                                  ? const SizedBox()
                                  : Column(
                                children: [
                                  // if(resalePropertyNotifier.memPlans.isNotEmpty && DateTime.now().isBefore(resalePropertyNotifier.memPlans[0].ending_on))
                                  //   const SizedBox(
                                  //     height: 5,
                                  //   ),
                                  if (resalePropertyNotifier
                                      .memPlans.isNotEmpty &&
                                      DateTime.now().isBefore(
                                          resalePropertyNotifier
                                              .memPlans[0].ending_on))
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (ctx) =>
                                              const AllMemPlans(
                                                appBarTitle:
                                                'Membership History',
                                              )),
                                        );
                                      },
                                      child: Card(
                                        elevation: 2,
                                        child: Column(
                                            children: [
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                        const EdgeInsets
                                                            .only(left: 10),
                                                        child: Text(
                                                          '₹ ${resalePropertyNotifier.memPlans[0].mem_plan_amt.toString().replaceAll(".0", "")} /-',
                                                          style: const TextStyle(
                                                              fontWeight:
                                                              FontWeight.bold),
                                                        ),
                                                      ),
                                                      Padding(
                                                          padding:
                                                          const EdgeInsets
                                                              .only(left: 2.5, top: 2.5),
                                                          child: Text(
                                                              '${resalePropertyNotifier.memPlans[0].mem_plan_durn} ${resalePropertyNotifier.memPlans[0].mem_plan_durn == 1 ? 'Month' : 'Months'}',
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold))),
                                                    ],
                                                  ),
                                                  Container(
                                                    margin:
                                                    const EdgeInsets
                                                        .only(
                                                        right:
                                                        10),
                                                    child: Text(
                                                        'Starting on ${DateFormat('dd-MM-yyyy').format(resalePropertyNotifier.memPlans[0].created_on)}'),),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 25,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .end,
                                                children: [
                                                  Container(
                                                    margin: const EdgeInsets.only(left: 5),
                                                    child: Card(
                                                      color: Platform
                                                          .isAndroid
                                                          ? Colors
                                                          .green
                                                          : CupertinoColors
                                                          .systemGreen,
                                                      child: Padding(
                                                          padding:
                                                          const EdgeInsets
                                                              .all(10),
                                                          child: Text(
                                                            'Active',
                                                            style: TextStyle(
                                                                color: Platform.isAndroid
                                                                    ? Colors.white
                                                                    : CupertinoColors.white, fontWeight: FontWeight.bold),
                                                          )),
                                                    ),
                                                  ),
                                                  Container(
                                                      margin:
                                                      const EdgeInsets
                                                          .only(
                                                          right:
                                                          10),
                                                      child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                          children: [
                                                            Text(
                                                                'Ending on ${DateFormat('dd-MM-yyyy').format(resalePropertyNotifier.memPlans[0].ending_on)}'),
                                                            Text(
                                                              '${DateTime.now().difference(resalePropertyNotifier.memPlans[0].ending_on).inDays.toString().replaceAll('-', '')} days left', style: const TextStyle(fontWeight: FontWeight.bold),)
                                                          ])),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                            ]),
                                      ),
                                    ),
                                  if (resalePropertyNotifier
                                      .memPlans.isNotEmpty &&
                                      DateTime.now().isBefore(
                                          resalePropertyNotifier
                                              .memPlans[0].ending_on))
                                    const SizedBox(
                                      height: 7,
                                    ),
                                  if (resalePropertyNotifier
                                      .memPlans.isEmpty ||
                                      !DateTime.now().isBefore(
                                          resalePropertyNotifier
                                              .memPlans[0].ending_on))
                                    Stack(
                                      children: [
                                        if (_queryProductError == null)
                                          Column(
                                            children: [
                                              (_loading || !_isAvailable)
                                                  ? const SizedBox()
                                                  : Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  if (_notFoundIds
                                                      .isNotEmpty)
                                                    ListTile(
                                                        title: Text(
                                                            '[${_notFoundIds.join(", ")}] not found',
                                                            style: TextStyle(
                                                                color: ThemeData.light()
                                                                    .colorScheme
                                                                    .error)),
                                                        subtitle:
                                                        const Text(
                                                            'This app needs special configuration to run. Please see example/README.md for instructions.')),
                                                  ListView.builder(
                                                      shrinkWrap:
                                                      true,
                                                      physics:
                                                      const NeverScrollableScrollPhysics(),
                                                      itemCount:
                                                      _products
                                                          .length,
                                                      itemBuilder:
                                                          (ctx, i) {
                                                        return Container(
                                                          margin: const EdgeInsets
                                                              .only(
                                                              left:
                                                              5,
                                                              right:
                                                              5),
                                                          decoration:
                                                          BoxDecoration(
                                                            gradient: LinearGradient(
                                                                begin:
                                                                Alignment.topRight,
                                                                end: Alignment.bottomLeft,
                                                                stops: const [
                                                                  0.2,
                                                                  0.5,
                                                                  0.8,
                                                                  0.7
                                                                ],
                                                                colors: [
                                                                  Colors.blue[50]!,
                                                                  Colors.green[100]!,
                                                                  Colors.blue[100]!,
                                                                  Colors.blue[100]!,
                                                                ]),
                                                          ),
                                                          child:
                                                          Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                            children: [
                                                              const SizedBox(
                                                                height:
                                                                10,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                const EdgeInsets.all(5),
                                                                child:
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    if (Platform.isAndroid)
                                                                      const Icon(
                                                                        Icons.favorite_outlined,
                                                                        color: Colors.red,
                                                                      ),
                                                                    if (Platform.isIOS)
                                                                      const Icon(
                                                                        CupertinoIcons.suit_heart_fill,
                                                                        color: CupertinoColors.systemRed,
                                                                      ),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Flexible(
                                                                        child: Text(
                                                                          'Personalized recommendations of projects, as per your specified criteria',
                                                                          style: TextStyle(color: Platform.isAndroid ? Colors.black : CupertinoColors.black, fontWeight: FontWeight.bold),
                                                                        ))
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height:
                                                                5,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                const EdgeInsets.all(5),
                                                                child:
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Icon(
                                                                      Icons.drive_eta_outlined,
                                                                      color: Platform.isAndroid ? Colors.green : CupertinoColors.systemGreen,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Flexible(
                                                                        child: Text(
                                                                          'Free pickup and drop facility (maximum 15 km one way) for 3 Site Visits',
                                                                          style: TextStyle(color: Platform.isAndroid ? Colors.black : CupertinoColors.black, fontWeight: FontWeight.bold),
                                                                        ))
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height:
                                                                5,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                const EdgeInsets.all(5),
                                                                child:
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Icon(Icons.assistant_outlined, color: Colors.yellow[700]),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Flexible(
                                                                        child: Text(
                                                                          'Dedicated assistance during Booking and Home Loan processing',
                                                                          style: TextStyle(color: Platform.isAndroid ? Colors.black : CupertinoColors.black, fontWeight: FontWeight.bold),
                                                                        ))
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height:
                                                                5,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                const EdgeInsets.only(left: 5, right: 5, top: 5),
                                                                child:
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Icon(Icons.perm_phone_msg_outlined, color: Platform.isAndroid ? Colors.blue : CupertinoColors.systemBlue),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Flexible(
                                                                        child: Text(
                                                                          'Dedicated helpline to track progress and resolve issues at each stage',
                                                                          style: TextStyle(color: Platform.isAndroid ? Colors.black : CupertinoColors.black, fontWeight: FontWeight.bold),
                                                                        ))
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height:
                                                                10,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                const EdgeInsets.only(left: 20, right: 20),
                                                                child:
                                                                Divider(
                                                                  color: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? Colors.grey.withOpacity(0.1) : CupertinoColors.systemGrey.withOpacity(0.1),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height:
                                                                10,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Row(children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(left: 5),
                                                                      child: Text('For',
                                                                        style: CustomTextStyles.getProjectNameFont(
                                                                            null,
                                                                            Platform.isAndroid
                                                                                ? Colors
                                                                                .black
                                                                                : CupertinoColors
                                                                                .black,
                                                                            18),),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    if(Platform.isAndroid)
                                                                      Container(
                                                                        padding: const EdgeInsets.only(left: 10),
                                                                        height: 30,
                                                                        decoration: const BoxDecoration(
                                                                            color: globalColor,
                                                                            borderRadius:
                                                                            BorderRadius.all(
                                                                                Radius.circular(20))),
                                                                        child:
                                                                        DropdownButtonHideUnderline(
                                                                          child: DropdownButton<String>(
                                                                            value: selectedCityAndroid,
                                                                            style: const TextStyle(
                                                                              color: globalColor,
                                                                            ),
                                                                            icon: const Icon(
                                                                              Icons.arrow_drop_down,
                                                                              color: Colors
                                                                                  .white, // <-- SEE HERE
                                                                            ),
                                                                            selectedItemBuilder:
                                                                                (BuildContext context) {
                                                                              return cities
                                                                                  .map((String cities) {
                                                                                return Center(child: Text(selectedCityAndroid, style: const TextStyle(color: Colors.white)));

                                                                              }).toList();
                                                                            },
                                                                            items: cities
                                                                                .map((String cities) {
                                                                              return DropdownMenuItem(
                                                                                value: cities,
                                                                                child: Text(cities,),
                                                                              );
                                                                            }).toList(),
                                                                            onChanged: (value) {
                                                                              setState(() {
                                                                                selectedCityAndroid = value!;
                                                                              });
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    if(Platform.isIOS)
                                                                      GestureDetector(
                                                                        onTap: () => _showDialog(
                                                                          CupertinoPicker(
                                                                            magnification: 1.22,
                                                                            squeeze: 1.2,
                                                                            useMagnifier: true,
                                                                            itemExtent: 32.0,
                                                                            onSelectedItemChanged: (int selectedItem) {
                                                                              setState(() {
                                                                                selectedCity = selectedItem;
                                                                              });
                                                                            },
                                                                            children:
                                                                            List<Widget>.generate(cities.length, (int index) {
                                                                              return Center(
                                                                                child: Text(
                                                                                  cities[index],
                                                                                ),
                                                                              );
                                                                            }),
                                                                          ),
                                                                        ),
                                                                        child: Container(
                                                                          padding: const EdgeInsets.only(
                                                                              left: 10),
                                                                          height: 30,
                                                                          decoration: const BoxDecoration(
                                                                              color: globalColor,
                                                                              borderRadius:
                                                                              BorderRadius.all(
                                                                                  Radius.circular(
                                                                                      20))),
                                                                          child: Row(
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            children: [
                                                                              Text(cities[selectedCity], style: const TextStyle(color: CupertinoColors.white),),
                                                                              const Padding(
                                                                                padding: EdgeInsets.only(left: 2.5, right: 2.5),
                                                                                child: Icon(
                                                                                  CupertinoIcons.arrowtriangle_down_circle_fill,
                                                                                  color: CupertinoColors
                                                                                      .white, // <-- SEE HERE
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),

                                                                        ),
                                                                      ),
                                                                  ],),
                                                                  // const SizedBox(
                                                                  //   width: 5,
                                                                  // ),
                                                                  Row(
                                                                    children: [
                                                                      Text('Validity',
                                                                        style: CustomTextStyles.getProjectNameFont(
                                                                            null,
                                                                            Platform.isAndroid
                                                                                ? Colors
                                                                                .black
                                                                                : CupertinoColors
                                                                                .black,
                                                                            18),),
                                                                      const SizedBox(
                                                                        width: 5,
                                                                      ),
                                                                      if(Platform.isAndroid)
                                                                        Container(
                                                                          margin: const EdgeInsets.only(right: 5),
                                                                          padding: const EdgeInsets.only(left: 10),
                                                                          height: 30,
                                                                          decoration: const BoxDecoration(
                                                                              color: globalColor,
                                                                              borderRadius:
                                                                              BorderRadius.all(
                                                                                  Radius.circular(20))),
                                                                          child:
                                                                          DropdownButtonHideUnderline(
                                                                            child: DropdownButton<String>(
                                                                              value: selectedValidityAndroid,
                                                                              style: const TextStyle(
                                                                                color: globalColor,
                                                                              ),
                                                                              icon: const Icon(
                                                                                Icons.arrow_drop_down,
                                                                                color: Colors
                                                                                    .white, // <-- SEE HERE
                                                                              ),
                                                                              selectedItemBuilder:
                                                                                  (BuildContext context) {
                                                                                return validityList
                                                                                    .map((String validity) {
                                                                                  return Center(child: Text(selectedValidityAndroid, style: const TextStyle(color: Colors.white)));

                                                                                }).toList();
                                                                              },
                                                                              items: validityList
                                                                                  .map((String validity) {
                                                                                return DropdownMenuItem(
                                                                                  value: validity,
                                                                                  child: Text(validity,),
                                                                                );
                                                                              }).toList(),
                                                                              onChanged: (value) {
                                                                                setState(() {
                                                                                  selectedValidityAndroid = value!;
                                                                                });
                                                                              },
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      if(Platform.isIOS)
                                                                        GestureDetector(
                                                                          onTap: () => _showDialog(
                                                                            CupertinoPicker(
                                                                              magnification: 1.22,
                                                                              squeeze: 1.2,
                                                                              useMagnifier: true,
                                                                              itemExtent: 32.0,
                                                                              onSelectedItemChanged: (int selectedItem) {
                                                                                setState(() {
                                                                                  selectedCity = selectedItem;
                                                                                });
                                                                              },
                                                                              children:
                                                                              List<Widget>.generate(cities.length, (int index) {
                                                                                return Center(
                                                                                  child: Text(
                                                                                    cities[index],
                                                                                  ),
                                                                                );
                                                                              }),
                                                                            ),
                                                                          ),
                                                                          child: Container(
                                                                            margin: const EdgeInsets.only(right: 5),
                                                                            padding: const EdgeInsets.only(
                                                                                left: 10),
                                                                            height: 30,
                                                                            decoration: const BoxDecoration(
                                                                                color: globalColor,
                                                                                borderRadius:
                                                                                BorderRadius.all(
                                                                                    Radius.circular(
                                                                                        20))),
                                                                            child: Row(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Text(cities[selectedCity], style: const TextStyle(color: CupertinoColors.white),),
                                                                                const Padding(
                                                                                  padding: EdgeInsets.only(left: 2.5, right: 2.5),
                                                                                  child: Icon(
                                                                                    CupertinoIcons.arrowtriangle_down_circle_fill,
                                                                                    color: CupertinoColors
                                                                                        .white, // <-- SEE HERE
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),

                                                                          ),
                                                                        ),
                                                                    ],)
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height:
                                                                10,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Flexible(
                                                                    child: Padding(
                                                                      padding:
                                                                      const EdgeInsets.all(5),
                                                                      child:
                                                                      Row(
                                                                        children: [
                                                                          SizedBox(height: 30, width: 30, child: Image.asset('assets/images/fireworks.png')),
                                                                          const SizedBox(
                                                                            width: 10,
                                                                          ),
                                                                          Flexible(
                                                                            child: Text(
                                                                              "Introductory Offer - Only for the first 500 Select members!",
                                                                              style: TextStyle(color: Platform.isAndroid ? Colors.purple : CupertinoColors.systemPurple, fontWeight: FontWeight.bold),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets.all(5),
                                                                        child: Text(
                                                                          '₹ 9,999 /-',
                                                                          style: TextStyle(decoration: TextDecoration.lineThrough, color: Platform.isAndroid ? Colors.black : CupertinoColors.black, fontSize: 20, decorationColor: Platform.isAndroid ? Colors.black : CupertinoColors.black, fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
                                                                        child: Text(
                                                                          '${_products[i].currencySymbol} ${_products[i].price.replaceAll("₹", '').replaceAll(".00", '')} /-',
                                                                          style: TextStyle(color: Platform.isAndroid ? Colors.black : CupertinoColors.black, fontWeight: FontWeight.bold, fontSize: 20),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height:
                                                                10,
                                                              ),
                                                              if (Platform.isIOS)
                                                                Container(
                                                                  margin: const EdgeInsets.only(left: 10, right: 10),
                                                                  width: double.infinity,
                                                                  child: CupertinoButton(
                                                                    borderRadius: BorderRadius.circular(25),
                                                                    color: globalColor,
                                                                    onPressed: !checkBoxValue
                                                                        ? () {
                                                                      if (checkBoxValue) {
                                                                        setState(() {
                                                                          checkBoxValidation = true;
                                                                        });
                                                                      } else {
                                                                        setState(() {
                                                                          checkBoxValidation = false;
                                                                        });
                                                                      }
                                                                    }
                                                                        : () {
                                                                      late PurchaseParam purchaseParam;
                                                                      purchaseParam = GooglePlayPurchaseParam(
                                                                        productDetails: _products[i],
                                                                      );
                                                                      _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
                                                                    },
                                                                    child: Text('Buy', style: TextStyle(color: Platform.isAndroid ? Colors.white : CupertinoColors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                                                  ),
                                                                ),
                                                              if (Platform.isAndroid)
                                                                Center(
                                                                  child: Container(
                                                                    height: 60,
                                                                    margin: const EdgeInsets.only(left: 10, right: 10),
                                                                    width: double.infinity,
                                                                    child: TextButton(
                                                                      style: TextButton.styleFrom(foregroundColor: Colors.black, backgroundColor: globalColor),
                                                                      onPressed: !checkBoxValue
                                                                          ? () {
                                                                        if (checkBoxValue) {
                                                                          setState(() {
                                                                            checkBoxValidation = true;
                                                                          });
                                                                        } else {
                                                                          setState(() {
                                                                            checkBoxValidation = false;
                                                                          });
                                                                        }
                                                                      }
                                                                          : () {
                                                                        late PurchaseParam purchaseParam;
                                                                        purchaseParam = GooglePlayPurchaseParam(
                                                                          productDetails: _products[i],
                                                                        );
                                                                        _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
                                                                      },
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                                                                        child: Text('Buy', style: TextStyle(color: Platform.isAndroid ? Colors.white : CupertinoColors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              const SizedBox(
                                                                height:
                                                                10,
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }),
                                                  if (_queryProductError !=
                                                      null)
                                                    Text(
                                                        _queryProductError!),
                                                ],
                                              ),
                                            ],
                                          ),
                                        if (_purchasePending)
                                          Positioned(
                                              left: 0,
                                              right: 0,
                                              bottom: 0,
                                              top: 0,
                                              child: Center(
                                                child: Platform.isAndroid
                                                    ? const CircularProgressIndicator()
                                                    : const CupertinoActivityIndicator(),
                                              )),
                                      ],
                                    ),
                                  if (resalePropertyNotifier
                                      .memPlans.isEmpty ||
                                      !DateTime.now().isBefore(
                                          resalePropertyNotifier
                                              .memPlans[0].ending_on))
                                    const SizedBox(
                                      height: 20,
                                    ),
                                  if (resalePropertyNotifier
                                      .memPlans.isEmpty ||
                                      !DateTime.now().isBefore(
                                          resalePropertyNotifier
                                              .memPlans[0].ending_on))
                                    Container(
                                      margin: const EdgeInsets.only(
                                          left: 5, right: 5),
                                      child: Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 24.0,
                                                width: 24.0,
                                                child: Theme(
                                                  data: Theme.of(context)
                                                      .copyWith(
                                                    unselectedWidgetColor:
                                                    !checkBoxValidation
                                                        ? (Platform
                                                        .isAndroid
                                                        ? Colors
                                                        .red
                                                        : CupertinoColors
                                                        .systemRed)
                                                        : null,
                                                  ),
                                                  child: Checkbox(
                                                    activeColor: Platform
                                                        .isAndroid
                                                        ? Colors.grey
                                                        : CupertinoColors
                                                        .systemGrey,
                                                    value: checkBoxValue,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        checkBoxValue =
                                                        value!;
                                                        checkBoxValidation =
                                                        true;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 10),
                                          // if (checkBoxValue)
                                          Flexible(
                                            child: Container(
                                              margin:
                                              const EdgeInsets.only(
                                                  left: 8),
                                              child: RichText(
                                                text: TextSpan(children: [
                                                  TextSpan(
                                                    text:
                                                    'I have read ',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                      !checkBoxValidation
                                                          ? (Platform
                                                          .isAndroid
                                                          ? Colors
                                                          .red
                                                          : CupertinoColors
                                                          .systemRed)
                                                          : (MediaQuery.of(context).platformBrightness ==
                                                          Brightness
                                                              .dark)
                                                          ? (Platform.isAndroid
                                                          ? Colors
                                                          .white
                                                          : CupertinoColors
                                                          .white)
                                                          : Colors
                                                          .grey[600],
                                                    ),
                                                  ),
                                                  TextSpan(
                                                      text:
                                                      'the terms ',
                                                      recognizer:
                                                      TapGestureRecognizer()
                                                        ..onTap =
                                                            () async {
                                                          Navigator
                                                              .push(
                                                            context,
                                                            Platform.isAndroid
                                                                ? MaterialPageRoute(
                                                                builder: (ctx) => const OpenPdf(
                                                                  imgUrl: [
                                                                    'https://storage.googleapis.com/squarest_docs/Select_Terms.pdf'
                                                                  ],
                                                                ))
                                                                : CupertinoPageRoute(
                                                                builder: (ctx) => const OpenPdf(
                                                                  imgUrl: [
                                                                    'https://storage.googleapis.com/squarest_docs/Select_Terms.pdf'
                                                                  ],
                                                                )),
                                                          );
                                                        },
                                                      style: const TextStyle(
                                                          decoration:
                                                          TextDecoration
                                                              .underline,
                                                          color:
                                                          globalColor,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold)),
                                                  TextSpan(
                                                    text:
                                                    ' of squarest Select membership plan and I agree to them.',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                      !checkBoxValidation
                                                          ? (Platform
                                                          .isAndroid
                                                          ? Colors
                                                          .red
                                                          : CupertinoColors
                                                          .systemRed)
                                                          : (MediaQuery.of(context).platformBrightness ==
                                                          Brightness
                                                              .dark)
                                                          ? (Platform.isAndroid
                                                          ? Colors
                                                          .white
                                                          : CupertinoColors
                                                          .white)
                                                          : Colors
                                                          .grey[600],
                                                    ),
                                                  ),
                                                ]),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (resalePropertyNotifier
                                      .memPlans.isEmpty ||
                                      !DateTime.now().isBefore(
                                          resalePropertyNotifier
                                              .memPlans[0].ending_on))
                                    const SizedBox(
                                      height: 10,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ]
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  getLikedProjects() {
    final likedProjectsNotifier =
        Provider.of<LikedProjectsNotifier>(context, listen: false);
    likedProjectsNotifier.getLikedProjects(context);
  }

  getLikedResaleProjects() {
    final likedProjectsNotifier =
        Provider.of<LikedProjectsNotifier>(context, listen: false);
    likedProjectsNotifier.getLikedResaleProperties(context);
  }

  _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => Container(
          height: 216,
          padding: const EdgeInsets.only(top: 6.0),
          // The Bottom margin is provided to align the popup above the system navigation bar.
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          // Provide a background color for the popup.
          color: CupertinoColors.systemBackground.resolveFrom(context),
          // Use a SafeArea widget to avoid system overlaps.
          child: SafeArea(
            top: false,
            child: child,
          ),
        ));
  }

}
