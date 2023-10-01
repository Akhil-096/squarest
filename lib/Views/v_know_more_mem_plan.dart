import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:squarest/Services/s_resale_property_notifier.dart';
import 'package:squarest/Utils/u_open_pdf.dart';
import 'package:cupertino_tabbar/cupertino_tabbar.dart' as cupertinoTabBar;
import 'package:squarest/Utils/u_constants.dart';
import 'package:squarest/Views/v_all_mem_plans.dart';
import 'package:squarest/Views/v_login.dart';
import 'package:squarest/Views/v_loan_and_mem_contact_us.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import '../Services/s_autocomplete_notifier.dart';
import 'package:flutter/cupertino.dart';
import '../Services/s_user_profile_notifier.dart';
import '../Utils/u_custom_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

// const String _kBasicSubscriptionId = 'basic_subscription_plan';
const String _kStandardSubscriptionId = 'standard_subscription_plan';
// const String _kPremiumSubscriptionId = 'premium_subscription_plan';

const List<String> _kProductIds = <String>[
  // _kBasicSubscriptionId,
  _kStandardSubscriptionId,
  // _kPremiumSubscriptionId,
];

class KnowMoreMemPlan extends StatefulWidget {
  // final bool isAccountScreen;
  final bool isComingFromKnowMore;
  final bool isComingFromJoinNow;
  // final bool isComingFromUserAccount;

  const KnowMoreMemPlan(
      {required this.isComingFromJoinNow,
      required this.isComingFromKnowMore,
        // required this.isComingFromUserAccount,
      Key? key})
      : super(key: key);

  @override
  State<KnowMoreMemPlan> createState() => KnowMoreMemPlanState();
}

class KnowMoreMemPlanState extends State<KnowMoreMemPlan> {
  // bool isDisabledButton = true;
  // bool isCheckNumber = false;
  // var phoneNoController = TextEditingController();
  // final form = GlobalKey<FormState>();
  int selectedTabIndex = 0;
  int cupertinoTabBarIValueGetter() => selectedTabIndex;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<String> _notFoundIds = <String>[];
  List<ProductDetails> _products = <ProductDetails>[];
  List<PurchaseDetails> _purchases = <PurchaseDetails>[];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String? _queryProductError;
  String selectedCityAndroid = 'Pune';
  String selectedValidityAndroid = '3 months';
  int selectedCity = 0;
  bool checkBoxValue = false;
  bool checkBoxValidation = true;

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
      Navigator.of(context).pop();
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
  Widget build(BuildContext context) {
    // final authProvider = Provider.of<AuthNotifier>(context);
    final autocompleteNotifier = Provider.of<AutocompleteNotifier>(context);
    final userProfileNotifier = Provider.of<UserProfileNotifier>(context);
    final resalePropertyNotifier = Provider.of<ResalePropertyNotifier>(context);

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: Platform.isAndroid
            ? PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: AppBar(
                  backgroundColor: (MediaQuery.of(context).platformBrightness ==
                          Brightness.dark)
                      ? Colors.grey[900]
                      : Colors.white,
                  scrolledUnderElevation: 0.0,
                ))
            : CupertinoNavigationBar(
                backgroundColor: (MediaQuery.of(context).platformBrightness ==
                        Brightness.dark)
                    ? Colors.grey[900]
                    : CupertinoColors.white,
              ),
        // backgroundColor:
        //  widget.isComingFromJoinNow ? null : (MediaQuery.of(context).platformBrightness == Brightness.dark)
        //         ? Colors.grey[900]
        //         : Platform.isAndroid
        //             ? Colors.white
        //             : CupertinoColors.white,
        body: SafeArea(
          child: WillPopScope(
            onWillPop:
                (widget.isComingFromJoinNow || widget.isComingFromKnowMore)
                    ? () {
                        Navigator.of(context).pop();
                        return Future.value(false);
                      }
                    : autocompleteNotifier.onWillPop,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 25, left: 5, right: 5, bottom: 5),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                                // height: 300,
                                // width: double.infinity,
                                color: Platform.isAndroid
                                    ? Colors.black
                                    : CupertinoColors.black,
                                child: Opacity(
                                  opacity: 0.6,
                                  child: Image.asset(
                                      'assets/images/family_2.jpg'),
                                )),
                            Positioned(
                              bottom: 2.5,
                              left: 0,
                              right: 0,
                              child: Align(
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'squarest Select',
                                      style:
                                          CustomTextStyles.getProjectNameFont(
                                              CustomShadows.textNormal,
                                              Platform.isAndroid
                                                  ? Colors.white
                                                  : CupertinoColors.white,
                                              30),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: Text(
                            'With you, all the way.',
                            style: CustomTextStyles.getProjectNameFont(
                                null,
                                (MediaQuery.of(context).platformBrightness ==
                                        Brightness.dark)
                                    ? Platform.isAndroid
                                        ? Colors.white
                                        : CupertinoColors.white
                                    : Platform.isAndroid
                                        ? Colors.black
                                        : CupertinoColors.black,
                                20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Container(
                    // height: 700,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          stops: const [
                            0.2,
                            0.5,
                            0.8,
                            0.7
                          ],
                          colors: [
                            Colors.black.withOpacity(0.9),
                            Colors.black.withOpacity(0.8),
                            Colors.black.withOpacity(0.7),
                            Colors.black.withOpacity(0.6),
                          ]),
                    ),
                    margin: const EdgeInsets.only(left: 5, right: 5),
                    padding: const EdgeInsets.all(10),
                    child: DefaultTabController(
                      initialIndex: 0,
                      length: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Whats\'s covered',
                            style: CustomTextStyles.getProjectNameFont(
                                null,
                                Platform.isAndroid
                                    ? Colors.white
                                    : CupertinoColors.white,
                                24),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                              // width: double.infinity,
                              // height: 250,
                              child: selectedTabIndex == 0
                                  ? Image.asset(
                                      'assets/images/whats_search.jpg')
                                  : selectedTabIndex == 1
                                      ? Image.asset(
                                          'assets/images/whats_book.jpg')
                                      : Image.asset(
                                          'assets/images/whats_loan.jpg')),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            'FREE',
                            style: CustomTextStyles.getProjectNameFont(
                                null,
                                Platform.isAndroid
                                    ? Colors.white
                                    : CupertinoColors.white,
                                24),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          if (Platform.isAndroid)
                            TabBar(
                              padding: EdgeInsets.zero,
                              indicatorPadding: EdgeInsets.zero,
                              unselectedLabelColor: Platform.isAndroid
                                  ? Colors.grey
                                  : CupertinoColors.systemGrey,
                              dividerColor: Colors.transparent,
                              labelColor: Platform.isAndroid
                                  ? Colors.white
                                  : CupertinoColors.white,
                              indicatorColor: Platform.isAndroid
                                  ? Colors.white
                                  : CupertinoColors.white,
                              onTap: (i) {
                                setState(() {
                                  selectedTabIndex = i;
                                });
                              },
                              tabs: const [
                                Tab(
                                  text: 'Search',
                                ),
                                Tab(
                                  text: 'Booking',
                                ),
                                Tab(
                                  text: 'Home Loan',
                                ),
                              ],
                            ),
                          if (Platform.isIOS)
                            cupertinoTabBar.CupertinoTabBar(
                              Platform.isAndroid
                                  ? Colors.black
                                  : CupertinoColors.black, //_backgroundColor
                              Platform.isAndroid
                                  ? Colors.white
                                  : CupertinoColors.white,
                              innerHorizontalPadding: 0.0,

                              allowExpand: true,
                              [
                                Center(
                                    child: Text(
                                  'Search',
                                  style: TextStyle(
                                    color: selectedTabIndex == 0
                                        ? Platform.isAndroid
                                            ? Colors.black
                                            : CupertinoColors.black
                                        : Platform.isAndroid
                                            ? Colors.grey
                                            : CupertinoColors.systemGrey,
                                  ),
                                )),
                                Center(
                                    child: Text(
                                  'Booking',
                                  style: TextStyle(
                                    color: selectedTabIndex == 1
                                        ? Platform.isAndroid
                                            ? Colors.black
                                            : CupertinoColors.black
                                        : Platform.isAndroid
                                            ? Colors.grey
                                            : CupertinoColors.systemGrey,
                                  ),
                                )),
                                Center(
                                    child: Text(
                                  'Home Loan',
                                  style: TextStyle(
                                    color: selectedTabIndex == 2
                                        ? Platform.isAndroid
                                            ? Colors.black
                                            : CupertinoColors.black
                                        : Platform.isAndroid
                                            ? Colors.grey
                                            : CupertinoColors.systemGrey,
                                  ),
                                ))
                              ],
                              cupertinoTabBarIValueGetter,
                              (int index) {
                                setState(() {
                                  selectedTabIndex = index;
                                });
                              },
                            ),
                          const SizedBox(
                            height: 20,
                          ),
                          if (selectedTabIndex == 0)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(top: 7),
                                            child: Icon(
                                              Platform.isAndroid
                                                  ? Icons.circle
                                                  : CupertinoIcons
                                                      .circle_filled,
                                              color: Platform.isAndroid
                                                  ? Colors.white
                                                  : CupertinoColors.white,
                                              size: 7,
                                            )),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Flexible(
                                            child: Text(
                                          'Personalized recommendations for projects as per your specified criteria.',
                                          style: TextStyle(
                                            color: Platform.isAndroid
                                                ? Colors.white
                                                : CupertinoColors.white,
                                          ),
                                          maxLines: 10,
                                        ))
                                      ]),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(top: 7),
                                            child: Icon(
                                              Platform.isAndroid
                                                  ? Icons.circle
                                                  : CupertinoIcons
                                                      .circle_filled,
                                              color: Platform.isAndroid
                                                  ? Colors.white
                                                  : CupertinoColors.white,
                                              size: 7,
                                            )),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Flexible(
                                            child: Text(
                                          '3 site visits, with free pickup and drop facility (maximum 15 km one way).',
                                          style: TextStyle(
                                            color: Platform.isAndroid
                                                ? Colors.white
                                                : CupertinoColors.white,
                                          ),
                                          maxLines: 10,
                                        ))
                                      ]),
                                ),
                              ],
                            ),
                          if (selectedTabIndex == 1)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(top: 7),
                                            child: Icon(
                                              Platform.isAndroid
                                                  ? Icons.circle
                                                  : CupertinoIcons
                                                      .circle_filled,
                                              color: Platform.isAndroid
                                                  ? Colors.white
                                                  : CupertinoColors.white,
                                              size: 7,
                                            )),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Flexible(
                                            child: Text(
                                          'Dedicated service for documentation for booking.',
                                          style: TextStyle(
                                            color: Platform.isAndroid
                                                ? Colors.white
                                                : CupertinoColors.white,
                                          ),
                                          maxLines: 10,
                                        ))
                                      ]),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(top: 7),
                                            child: Icon(
                                              Platform.isAndroid
                                                  ? Icons.circle
                                                  : CupertinoIcons
                                                      .circle_filled,
                                              color: Platform.isAndroid
                                                  ? Colors.white
                                                  : CupertinoColors.white,
                                              size: 7,
                                            )),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Flexible(
                                            child: Text(
                                          'Dedicated helpline to track progress and resolve issues.',
                                          style: TextStyle(
                                            color: Platform.isAndroid
                                                ? Colors.white
                                                : CupertinoColors.white,
                                          ),
                                          maxLines: 10,
                                        ))
                                      ]),
                                ),
                              ],
                            ),
                          if (selectedTabIndex == 2)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(top: 7),
                                            child: Icon(
                                              Platform.isAndroid
                                                  ? Icons.circle
                                                  : CupertinoIcons
                                                      .circle_filled,
                                              color: Platform.isAndroid
                                                  ? Colors.white
                                                  : CupertinoColors.white,
                                              size: 7,
                                            )),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Flexible(
                                            child: Text(
                                          'Dedicated service for documentation for KYC and credit check to expedite loan sanction.',
                                          style: TextStyle(
                                            color: Platform.isAndroid
                                                ? Colors.white
                                                : CupertinoColors.white,
                                          ),
                                          maxLines: 10,
                                        ))
                                      ]),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(top: 7),
                                            child: Icon(
                                              Platform.isAndroid
                                                  ? Icons.circle
                                                  : CupertinoIcons
                                                      .circle_filled,
                                              color: Platform.isAndroid
                                                  ? Colors.white
                                                  : CupertinoColors.white,
                                              size: 7,
                                            )),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Flexible(
                                            child: Text(
                                          'Dedicated helpline to track progress and resolve issues till final loan disbursal.',
                                          style: TextStyle(
                                            color: Platform.isAndroid
                                                ? Colors.white
                                                : CupertinoColors.white,
                                          ),
                                          maxLines: 10,
                                        ))
                                      ]),
                                ),
                              ],
                            ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  resalePropertyNotifier.isPlansLoading
                      ? const SizedBox()
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (resalePropertyNotifier
                          .memPlans.isNotEmpty &&
                          DateTime.now().isBefore(
                              resalePropertyNotifier
                                  .memPlans[0].ending_on))
                      const SizedBox(height: 5,),
                      if (resalePropertyNotifier
                          .memPlans.isNotEmpty &&
                          DateTime.now().isBefore(
                              resalePropertyNotifier
                                  .memPlans[0].ending_on))
                      Padding(padding: const EdgeInsets.only(left: 5, right: 5), child: Text('Already a Select member',
                        style: CustomTextStyles.getProjectNameFont(
                            null,
                            (MediaQuery.of(context).platformBrightness ==
                                Brightness.dark)
                                ? Platform.isAndroid
                                ? Colors.white
                                : CupertinoColors.white
                                : Platform.isAndroid
                                ? Colors.black
                                : CupertinoColors.black,
                            24),),),
                      if (resalePropertyNotifier
                          .memPlans.isNotEmpty &&
                          DateTime.now().isBefore(
                              resalePropertyNotifier
                                  .memPlans[0].ending_on))
                      const SizedBox(height: 10,),
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
                    ],
                  ),
                  if (resalePropertyNotifier
                      .memPlans.isEmpty ||
                      !DateTime.now().isBefore(
                          resalePropertyNotifier
                              .memPlans[0].ending_on))
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Text(
                          'Key Benefits',
                          style: CustomTextStyles.getProjectNameFont(
                              null,
                              (MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark)
                                  ? Platform.isAndroid
                                  ? Colors.white
                                  : CupertinoColors.white
                                  : Platform.isAndroid
                                  ? Colors.black
                                  : CupertinoColors.black,
                              24),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Stack(
                        children: [
                          if (_queryProductError == null)
                            Column(
                              children: [
                                (_loading || !_isAvailable)
                                    ? const SizedBox()
                                    : Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    if (_notFoundIds.isNotEmpty)
                                      ListTile(
                                          title: Text(
                                              '[${_notFoundIds.join(", ")}] not found',
                                              style: TextStyle(
                                                  color: ThemeData.light()
                                                      .colorScheme
                                                      .error)),
                                          subtitle: const Text(
                                              'This app needs special configuration to run. Please see example/README.md for instructions.')),
                                    ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                        const NeverScrollableScrollPhysics(),
                                        itemCount: _products.length,
                                        itemBuilder: (ctx, i) {
                                          return Container(
                                            margin: const EdgeInsets.only(
                                                left: 5, right: 5),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                  begin: Alignment.topRight,
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
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.all(
                                                      5),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      if (Platform
                                                          .isAndroid)
                                                        const Icon(
                                                          Icons
                                                              .favorite_outlined,
                                                          color: Colors.red,
                                                        ),
                                                      if (Platform.isIOS)
                                                        const Icon(
                                                          CupertinoIcons
                                                              .suit_heart_fill,
                                                          color:
                                                          CupertinoColors
                                                              .systemRed,
                                                        ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Flexible(
                                                          child: Text(
                                                            'Personalized recommendations of projects, as per your specified criteria',
                                                            style: TextStyle(
                                                                color: Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                          ))
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.all(
                                                      5),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .drive_eta_outlined,
                                                        color: Platform
                                                            .isAndroid
                                                            ? Colors.green
                                                            : CupertinoColors
                                                            .systemGreen,
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Flexible(
                                                          child: Text(
                                                            'Free pickup and drop facility (maximum 15 km one way) for 3 Site Visits',
                                                            style: TextStyle(
                                                                color: Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                          ))
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.all(
                                                      5),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      Icon(
                                                          Icons
                                                              .assistant_outlined,
                                                          color: Colors
                                                              .yellow[700]),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Flexible(
                                                          child: Text(
                                                            'Dedicated assistance during Booking and Home Loan processing',
                                                            style: TextStyle(
                                                                color: Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                          ))
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(left: 5, right: 5, top: 5),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      Icon(
                                                          Icons
                                                              .perm_phone_msg_outlined,
                                                          color: Platform
                                                              .isAndroid
                                                              ? Colors.blue
                                                              : CupertinoColors
                                                              .systemBlue),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Flexible(
                                                          child: Text(
                                                            'Dedicated helpline to track progress and resolve issues at each stage',
                                                            style: TextStyle(
                                                                color: Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                          ))
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                      left: 20,
                                                      right: 20),
                                                  child: Divider(
                                                    color: (MediaQuery.of(
                                                        context)
                                                        .platformBrightness ==
                                                        Brightness.dark)
                                                        ? Colors.grey
                                                        .withOpacity(
                                                        0.1)
                                                        : CupertinoColors
                                                        .systemGrey
                                                        .withOpacity(
                                                        0.1),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
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
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: Padding(
                                                        padding:
                                                        const EdgeInsets.all(
                                                            5),
                                                        child: Row(
                                                          children: [
                                                            SizedBox(
                                                                height: 30,
                                                                width: 30,
                                                                child: Image.asset(
                                                                    'assets/images/fireworks.png')),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Flexible(
                                                              child: Text(
                                                                "Introductory Offer - Only for the first 500 Select members!",
                                                                style: TextStyle(
                                                                    color: Platform
                                                                        .isAndroid
                                                                        ? Colors
                                                                        .purple
                                                                        : CupertinoColors
                                                                        .systemPurple,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                          const EdgeInsets
                                                              .all(5),
                                                          child: Text(
                                                            '₹ 9,999 /-',
                                                            style: TextStyle(
                                                                decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                                color: Platform.isAndroid
                                                                    ? Colors
                                                                    .black
                                                                    : CupertinoColors
                                                                    .black,
                                                                fontSize:
                                                                20,
                                                                decorationColor: Platform.isAndroid
                                                                    ? Colors
                                                                    .black
                                                                    : CupertinoColors
                                                                    .black,
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                          const EdgeInsets
                                                              .only(
                                                              left: 5,
                                                              right: 5,
                                                              bottom:
                                                              5),
                                                          child: Text(
                                                            '${_products[i].currencySymbol} ${_products[i].price.replaceAll("₹", '').replaceAll(".00", '')} /-',
                                                            style: TextStyle(
                                                                color: Platform.isAndroid
                                                                    ? Colors
                                                                    .black
                                                                    : CupertinoColors
                                                                    .black,
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                                fontSize:
                                                                20),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                if (Platform.isIOS)
                                                Container(
                                                    margin:
                                                    const EdgeInsets
                                                        .only(left: 10,
                                                        right:
                                                        10),
                                                    width: double
                                                        .infinity,
                                                    child:
                                                    CupertinoButton(
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          25),
                                                      color:
                                                      globalColor,
                                                      onPressed: (FirebaseAuth.instance.currentUser != null && !checkBoxValue)
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
                                                      } :
                                                          () async {
                                                        if (widget
                                                            .isComingFromJoinNow) {
                                                          if (FirebaseAuth
                                                              .instance
                                                              .currentUser
                                                              ?.uid !=
                                                              null) {
                                                            late PurchaseParam
                                                            purchaseParam;
                                                            purchaseParam =
                                                                GooglePlayPurchaseParam(
                                                                  productDetails:
                                                                  _products[i],
                                                                );
                                                            _inAppPurchase.buyNonConsumable(
                                                                purchaseParam:
                                                                purchaseParam);
                                                          } else {
                                                            Navigator
                                                                .push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                  const LoginScreen(
                                                                    isAccountScreen: false,
                                                                    isComingFromHomeLoan: false,
                                                                    isComingFromJoinNow: true,
                                                                    isComingFromKnowMore: false,
                                                                  )),
                                                            ).then(
                                                                    (_) async {
                                                                  // await userProfileNotifier.getUser(context, (FirebaseAuth.instance.currentUser?.uid).toString(), this);
                                                                  if (FirebaseAuth.instance.currentUser?.uid ==
                                                                      null) {
                                                                    return;
                                                                  } else {
                                                                    setState(
                                                                            () {
                                                                          _loading =
                                                                          true;
                                                                        });
                                                                    // if(!mounted) return;
                                                                    await userProfileNotifier
                                                                        .getUser(context, (FirebaseAuth.instance.currentUser?.uid).toString(), this)
                                                                        .whenComplete(() async {
                                                                      if (userProfileNotifier.userProfileModel.firebase_user_id == null ||
                                                                          userProfileNotifier.userProfileModel.firebase_user_id!.isEmpty) {
                                                                        if (!mounted) return;
                                                                        userProfileNotifier.createUser('', '', FirebaseAuth.instance.currentUser?.phoneNumber, FirebaseAuth.instance.currentUser?.email ?? '', context).then((_) async {
                                                                          await userProfileNotifier.getUser(context, (FirebaseAuth.instance.currentUser?.uid).toString(), this).then((_) async {
                                                                            userProfileNotifier.setIsBottomNavVisibleToTrue();
                                                                            await resalePropertyNotifier.getMemPlans(context).then((_) {
                                                                              if ((resalePropertyNotifier.memPlans.isNotEmpty && DateTime.now().isBefore(resalePropertyNotifier.memPlans[0].ending_on))) {
                                                                                if (!mounted) return;
                                                                                setState(() {
                                                                                  _loading = false;
                                                                                });
                                                                                Navigator.of(context).pop();
                                                                              } else {
                                                                                setState(() {
                                                                                  _loading = false;
                                                                                });
                                                                                late PurchaseParam purchaseParam;
                                                                                purchaseParam = GooglePlayPurchaseParam(
                                                                                  productDetails: _products[i],
                                                                                );
                                                                                _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
                                                                              }
                                                                            });
                                                                          });
                                                                        });
                                                                      } else {
                                                                        // if(!mounted) return;
                                                                        await resalePropertyNotifier.getMemPlans(context).then((_) {
                                                                          setState(() {
                                                                            _loading = false;
                                                                          });
                                                                          if ((resalePropertyNotifier.memPlans.isNotEmpty && DateTime.now().isBefore(resalePropertyNotifier.memPlans[0].ending_on))) {
                                                                            if (!mounted) return;
                                                                            Navigator.of(context).pop();
                                                                          } else {
                                                                            late PurchaseParam purchaseParam;
                                                                            purchaseParam = GooglePlayPurchaseParam(
                                                                              productDetails: _products[i],
                                                                            );
                                                                            _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
                                                                          }
                                                                        });
                                                                      }
                                                                    });
                                                                  }
                                                                });
                                                          }
                                                        } else {
                                                          Navigator
                                                              .push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                const LoginScreen(
                                                                  isAccountScreen: false,
                                                                  isComingFromHomeLoan: false,
                                                                  isComingFromJoinNow: false,
                                                                  isComingFromKnowMore: true,
                                                                )),
                                                          );
                                                        }
                                                      },
                                                      child: Text(
                                                          'Buy',
                                                          style: TextStyle(
                                                              color: Platform.isAndroid
                                                                  ? Colors
                                                                  .white
                                                                  : CupertinoColors
                                                                  .white,
                                                              fontSize:
                                                              15,
                                                              fontWeight:
                                                              FontWeight.bold)),
                                                    ),
                                                  ),
                                                if (Platform.isAndroid)
                                                Center(
                                                    child: Container(
                                                      height: 60,
                                                      margin:
                                                      const EdgeInsets
                                                          .only(left: 10,
                                                          right:
                                                          10),
                                                      width: double
                                                          .infinity,
                                                      child:
                                                      TextButton(
                                                        style: TextButton.styleFrom(
                                                            foregroundColor:
                                                            Colors
                                                                .black,
                                                            backgroundColor:
                                                            globalColor),
                                                        onPressed: (FirebaseAuth.instance.currentUser != null && !checkBoxValue)
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
                                                        } : () async {
                                                          if (widget
                                                              .isComingFromJoinNow) {
                                                            if (FirebaseAuth
                                                                .instance
                                                                .currentUser
                                                                ?.uid !=
                                                                null) {
                                                              late PurchaseParam
                                                              purchaseParam;
                                                              purchaseParam =
                                                                  GooglePlayPurchaseParam(
                                                                    productDetails:
                                                                    _products[i],
                                                                  );
                                                              _inAppPurchase.buyNonConsumable(
                                                                  purchaseParam:
                                                                  purchaseParam);
                                                            } else {
                                                              Navigator
                                                                  .push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => const LoginScreen(
                                                                      isAccountScreen: false,
                                                                      isComingFromHomeLoan: false,
                                                                      isComingFromJoinNow: true,
                                                                      isComingFromKnowMore: false,
                                                                    )),
                                                              ).then(
                                                                      (_) async {
                                                                    // await userProfileNotifier.getUser(context, (FirebaseAuth.instance.currentUser?.uid).toString(), this);
                                                                    if (FirebaseAuth.instance.currentUser?.uid ==
                                                                        null) {
                                                                      return;
                                                                    } else {
                                                                      setState(() {
                                                                        _loading = true;
                                                                      });
                                                                      // if(!mounted) return;
                                                                      await userProfileNotifier.getUser(context, (FirebaseAuth.instance.currentUser?.uid).toString(), this).whenComplete(() async {
                                                                        if (userProfileNotifier.userProfileModel.firebase_user_id == null || userProfileNotifier.userProfileModel.firebase_user_id!.isEmpty) {
                                                                          if (!mounted) return;
                                                                          userProfileNotifier.createUser('', '', FirebaseAuth.instance.currentUser?.phoneNumber, FirebaseAuth.instance.currentUser?.email ?? '', context).then((_) async {
                                                                            await userProfileNotifier.getUser(context, (FirebaseAuth.instance.currentUser?.uid).toString(), this).then((_) async {
                                                                              userProfileNotifier.setIsBottomNavVisibleToTrue();
                                                                              await resalePropertyNotifier.getMemPlans(context).then((_) {
                                                                                if ((resalePropertyNotifier.memPlans.isNotEmpty && DateTime.now().isBefore(resalePropertyNotifier.memPlans[0].ending_on))) {
                                                                                  if (!mounted) return;
                                                                                  setState(() {
                                                                                    _loading = false;
                                                                                  });
                                                                                  Navigator.of(context).pop();
                                                                                } else {
                                                                                  setState(() {
                                                                                    _loading = false;
                                                                                  });
                                                                                  late PurchaseParam purchaseParam;
                                                                                  purchaseParam = GooglePlayPurchaseParam(
                                                                                    productDetails: _products[i],
                                                                                  );
                                                                                  _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
                                                                                }
                                                                              });
                                                                            });
                                                                          });
                                                                        } else {
                                                                          // if(!mounted) return;
                                                                          await resalePropertyNotifier.getMemPlans(context).then((_) {
                                                                            setState(() {
                                                                              _loading = false;
                                                                            });
                                                                            if ((resalePropertyNotifier.memPlans.isNotEmpty && DateTime.now().isBefore(resalePropertyNotifier.memPlans[0].ending_on))) {
                                                                              if (!mounted) return;
                                                                              Navigator.of(context).pop();
                                                                            } else {
                                                                              late PurchaseParam purchaseParam;
                                                                              purchaseParam = GooglePlayPurchaseParam(
                                                                                productDetails: _products[i],
                                                                              );
                                                                              _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
                                                                            }
                                                                          });
                                                                        }
                                                                      });
                                                                    }
                                                                  });
                                                            }
                                                          } else {
                                                            Navigator
                                                                .push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                  const LoginScreen(
                                                                    isAccountScreen: false,
                                                                    isComingFromHomeLoan: false,
                                                                    isComingFromJoinNow: false,
                                                                    isComingFromKnowMore: true,
                                                                  )),
                                                            );
                                                          }
                                                        },
                                                        child:
                                                        Padding(
                                                          padding: const EdgeInsets
                                                              .only(
                                                              top: 8,
                                                              bottom:
                                                              8),
                                                          child: Text(
                                                              'Buy',
                                                              style: TextStyle(
                                                                  color: Platform.isAndroid
                                                                      ? Colors.white
                                                                      : CupertinoColors.white,
                                                                  fontSize: 15,
                                                                  fontWeight: FontWeight.bold)),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                    const SizedBox(height: 10,),
                                    if (_queryProductError != null)
                                    Padding(
                                          padding: const EdgeInsets.only(left: 5),
                                          child: Text(_queryProductError!)),
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
                      const SizedBox(height: 10,),
                      if(FirebaseAuth.instance.currentUser == null)
                      Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.only(left: 5),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                    text: 'Detailed terms can be found ',
                                    style: TextStyle(
                                      color: (MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark)
                                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white : Platform.isAndroid
                                          ? Colors.black
                                          : CupertinoColors.black,)
                                ),
                                TextSpan(
                                    text: 'here',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        Navigator.push(
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
                                      decoration: TextDecoration.underline,
                                      color: globalColor,
                                      fontWeight: FontWeight.bold,)),
                              ],
                            ),
                          ),
                        ),
                      if(FirebaseAuth.instance.currentUser != null)
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
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
                      child: Text(
                        "Your questions, answered",
                        style: CustomTextStyles.getProjectNameFont(
                            null,
                            (MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark)
                                ? Platform.isAndroid
                                    ? Colors.white
                                    : CupertinoColors.white
                                : Platform.isAndroid
                                    ? Colors.black
                                    : CupertinoColors.black,
                            24),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: ExpansionTile(
                          collapsedIconColor: (MediaQuery.of(context).platformBrightness ==
                              Brightness.dark)
                              ? Platform.isAndroid ? Colors.white : CupertinoColors.white : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                          iconColor: (MediaQuery.of(context).platformBrightness ==
                              Brightness.dark)
                              ? Platform.isAndroid ? Colors.white : CupertinoColors.white : CupertinoColors.black,
                        tilePadding: const EdgeInsets.all(10),
                        childrenPadding: const EdgeInsets.all(10),
                        title: Text(
                            'Where can I avail benefits of the squarest Select membership ?', style: TextStyle(
                          color: (MediaQuery.of(context).platformBrightness ==
                              Brightness.dark)
                              ? Platform.isAndroid ? Colors.white : CupertinoColors.white : Platform.isAndroid
                              ? Colors.black
                              : CupertinoColors.black,
                          fontWeight: FontWeight.bold
                        )),
                        children: [
                          Text(
                            'squarest Select membership is currently available for properties in Pune. We will soon scale it up to other cities like MMR (Mumbai Metropolitan Region), National Capital Region(NCR), Bengaluru, Hyderabad etc.', style: TextStyle(
                          color: (MediaQuery.of(context).platformBrightness ==
                              Brightness.dark)
                              ? Platform.isAndroid ? Colors.white : CupertinoColors.white : Platform.isAndroid
                              ? Colors.black
                              : CupertinoColors.black,
                        )),
                        ]
                      ),),
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: ExpansionTile(
                          collapsedIconColor: (MediaQuery.of(context).platformBrightness ==
                              Brightness.dark)
                              ? Platform.isAndroid ? Colors.white : CupertinoColors.white : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                          iconColor: (MediaQuery.of(context).platformBrightness ==
                              Brightness.dark)
                              ? Platform.isAndroid ? Colors.white : CupertinoColors.white : CupertinoColors.black,
                        tilePadding: const EdgeInsets.all(10),
                        childrenPadding: const EdgeInsets.all(10),
                        title: Text(
                            'Once I become a squarest Select member, how long can I enjoy its\nbenefits ?', style: TextStyle(
                          color: (MediaQuery.of(context).platformBrightness ==
                              Brightness.dark)
                              ? Platform.isAndroid ? Colors.white : CupertinoColors.white : Platform.isAndroid
                              ? Colors.black
                              : CupertinoColors.black,
                            fontWeight: FontWeight.bold
                        )),
                        children: [
                          Text(
                              'Your squarest Select membership is valid for 3 months. You are requested to avail of all benefits within this duration so as to get maximum advantage of the membership.', style: TextStyle(
                            color: (MediaQuery.of(context).platformBrightness ==
                                Brightness.dark)
                                ? Platform.isAndroid ? Colors.white : CupertinoColors.white : Platform.isAndroid
                                ? Colors.black
                                : CupertinoColors.black,
                          )),
                        ]
                        // controller: _2ndcontroller,
                      ),),
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: ExpansionTile(
                        collapsedIconColor: (MediaQuery.of(context).platformBrightness ==
                            Brightness.dark)
                            ? Platform.isAndroid ? Colors.white : CupertinoColors.white : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                        iconColor: (MediaQuery.of(context).platformBrightness ==
                            Brightness.dark)
                            ? Platform.isAndroid ? Colors.white : CupertinoColors.white : CupertinoColors.black,
                      tilePadding: const EdgeInsets.all(10),
                      childrenPadding: const EdgeInsets.all(10),
                      title: Text(
                          'Can I cancel my squarest Select membership ?', style: TextStyle(
                        color: (MediaQuery.of(context).platformBrightness ==
                            Brightness.dark)
                            ? Platform.isAndroid ? Colors.white : CupertinoColors.white : Platform.isAndroid
                            ? Colors.black
                            : CupertinoColors.black,
                          fontWeight: FontWeight.bold
                      )),
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                  text: 'You can cancel your membership and get a full refund if your request for cancellation is received within 24 hours of the purchase and provided you have not availed of any benefits of the membership.\n\n',
                                  style: TextStyle(
                                    color: (MediaQuery.of(context).platformBrightness ==
                                        Brightness.dark)
                                        ? Platform.isAndroid ? Colors.white : CupertinoColors.white : Platform.isAndroid
                                        ? Colors.black
                                        : CupertinoColors.black,
                                  )
                              ),
                              TextSpan(
                                  text: 'Kindly send your request for cancellation to ',
                                  style: TextStyle(
                                    color: (MediaQuery.of(context).platformBrightness ==
                                        Brightness.dark)
                                        ? Platform.isAndroid ? Colors.white : CupertinoColors.white : Platform.isAndroid
                                        ? Colors.black
                                        : CupertinoColors.black,
                                  )
                              ),
                              TextSpan(
                                  text: 'info@squarest.in.\n\n',
                                  style: TextStyle(
                                    color: Platform.isAndroid
                                        ? Colors.blue
                                        : CupertinoColors.systemBlue,
                                  )
                              ),
                              TextSpan(
                                  text: 'The full refund will be credited to the source account within 5-7 business days.\n\n',
                                  style: TextStyle(
                                    color: (MediaQuery.of(context).platformBrightness ==
                                        Brightness.dark)
                                        ? Platform.isAndroid ? Colors.white : CupertinoColors.white : Platform.isAndroid
                                        ? Colors.black
                                        : CupertinoColors.black,
                                  )
                              ),
                              TextSpan(
                                  text: 'No refund shall be made after 24 hours of the purchase.',
                                  style: TextStyle(
                                    color: (MediaQuery.of(context).platformBrightness ==
                                        Brightness.dark)
                                        ? Platform.isAndroid ? Colors.white : CupertinoColors.white : Platform.isAndroid
                                        ? Colors.black
                                        : CupertinoColors.black,
                                  )
                              ),
                            ],
                          ),
                        ),
                      ]
                    ),),
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: ExpansionTile(
                        collapsedIconColor: (MediaQuery.of(context).platformBrightness ==
                            Brightness.dark)
                            ? Platform.isAndroid ? Colors.white : CupertinoColors.white : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                        iconColor: (MediaQuery.of(context).platformBrightness ==
                            Brightness.dark)
                            ? Platform.isAndroid ? Colors.white : CupertinoColors.white : CupertinoColors.black,
                      tilePadding: const EdgeInsets.all(10),
                      childrenPadding: const EdgeInsets.all(10),
                      title: Text(
                          'Will my squarest Select membership renew automatically ?', style: TextStyle(
                          color: (MediaQuery.of(context).platformBrightness ==
                              Brightness.dark)
                              ? Platform.isAndroid ? Colors.white : CupertinoColors.white : Platform.isAndroid
                              ? Colors.black
                              : CupertinoColors.black,
                          fontWeight: FontWeight.bold
                      )),
                     children: [
                       Text(
                           'No. Your squarest Select membership will expire once the validity period is over. It will not renew automatically with any auto debit to your bank account. You can however choose to renew it if required.', style: TextStyle(
                         color: (MediaQuery.of(context).platformBrightness ==
                             Brightness.dark)
                             ? Platform.isAndroid ? Colors.white : CupertinoColors.white : Platform.isAndroid
                             ? Colors.black
                             : CupertinoColors.black,
                       )),
                     ]
                    ),),
                  const SizedBox(
                    height: 50,
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
                      child: Text(
                        "Need more details ?",
                        style: CustomTextStyles.getProjectNameFont(
                            null,
                            (MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark)
                                ? Platform.isAndroid
                                    ? Colors.white
                                    : CupertinoColors.white
                                : Platform.isAndroid
                                    ? Colors.black
                                    : CupertinoColors.black,
                            24),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  if (Platform.isAndroid)
                    Center(
                      child: Container(
                        height: 60,
                        margin: const EdgeInsets.only(left: 5, right: 5),
                        width: double.infinity,
                        child: TextButton(
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: globalColor),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const LoanAndMemContactUs(
                                        appBarTitle: 'Contact Us',
                                        isComingFromPlan: true,
                                      )),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(top: 8, bottom: 8),
                            child: Text("Contact Us",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15)),
                          ),
                        ),
                      ),
                    ),
                  if (Platform.isIOS)
                    Container(
                      margin: const EdgeInsets.only(left: 5, right: 5),
                      width: double.infinity,
                      child: CupertinoButton(
                        borderRadius: BorderRadius.circular(25),
                        color: globalColor,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoanAndMemContactUs(
                                      appBarTitle: 'Contact Us',
                                      isComingFromPlan: true,
                                    )),
                          );
                        },
                        child: const Text("Contact us",
                            style: TextStyle(
                                color: CupertinoColors.white, fontSize: 15)),
                      ),
                    ),
                  const SizedBox(
                    height: 25,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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

class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}