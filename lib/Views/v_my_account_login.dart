import 'dart:io';
import 'package:squarest/Views/v_know_more_mem_plan.dart';
import 'package:squarest/Utils/u_constants.dart';
import 'package:squarest/Views/v_login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Services/s_autocomplete_notifier.dart';
import 'package:flutter/cupertino.dart';
import '../Utils/u_custom_styles.dart';


// const String _kBasicSubscriptionId = 'basic_subscription_plan';
// const String _kStandardSubscriptionId = 'standard_subscription_plan';
// const String _kPremiumSubscriptionId = 'premium_subscription_plan';

// const List<String> _kProductIds = <String>[
//   // _kBasicSubscriptionId,
//   _kStandardSubscriptionId,
//   // _kPremiumSubscriptionId,
// ];

class MyAccountLogin extends StatefulWidget {
  // final bool isAccountScreen;
  // final bool isComingFromHomeLoan;
  // final bool isComingFromJoinNow;

  const MyAccountLogin({Key? key}) : super(key: key);

  @override
  State<MyAccountLogin> createState() => MyAccountLoginState();
}

class MyAccountLoginState extends State<MyAccountLogin> {
  // bool isDisabledButton = true;
  // bool isCheckNumber = false;
  // var phoneNoController = TextEditingController();
  // final form = GlobalKey<FormState>();
  // int selectedTabIndex = 0;
  //
  // int cupertinoTabBarIValueGetter() => selectedTabIndex;
  // final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  // late StreamSubscription<List<PurchaseDetails>> _subscription;
  // List<String> _notFoundIds = <String>[];
  // List<ProductDetails> _products = <ProductDetails>[];
  // List<PurchaseDetails> _purchases = <PurchaseDetails>[];
  // bool _isAvailable = false;
  // bool _purchasePending = false;
  // bool _loading = true;
  // String? _queryProductError;

  // @override
  // void initState() {
  //   super.initState();
  //   final Stream<List<PurchaseDetails>> purchaseUpdated =
  //       _inAppPurchase.purchaseStream;
  //   _subscription =
  //       purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
  //         _listenToPurchaseUpdated(purchaseDetailsList);
  //       }, onDone: () {
  //         _subscription.cancel();
  //       }, onError: (Object error) {
  //         Fluttertoast.showToast(
  //           msg: error.toString(),
  //           backgroundColor:
  //           Platform.isAndroid ? Colors.white : CupertinoColors.white,
  //           textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
  //         );
  //       });
  //   initStoreInfo();
  // }
  //
  // Future<void> _listenToPurchaseUpdated(
  //     List<PurchaseDetails> purchaseDetailsList) async {
  //   for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
  //     if (purchaseDetails.status == PurchaseStatus.pending) {
  //       showPendingUI();
  //     } else {
  //       if (purchaseDetails.status == PurchaseStatus.error) {
  //         handleError(purchaseDetails.error!);
  //       } else if (purchaseDetails.status == PurchaseStatus.purchased ||
  //           purchaseDetails.status == PurchaseStatus.restored) {
  //         final bool valid = await _verifyPurchase(purchaseDetails);
  //         if (valid) {
  //           deliverProduct(purchaseDetails);
  //         } else {
  //           _handleInvalidPurchase(purchaseDetails);
  //           return;
  //         }
  //       }
  //       if (purchaseDetails.pendingCompletePurchase) {
  //         await _inAppPurchase.completePurchase(purchaseDetails);
  //       }
  //     }
  //   }
  // }
  //
  // void handleError(IAPError error) {
  //   setState(() {
  //     _purchasePending = false;
  //   });
  //   Fluttertoast.showToast(
  //     msg: 'Something went wrong !',
  //     backgroundColor:
  //     Platform.isAndroid ? Colors.white : CupertinoColors.white,
  //     textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
  //   );
  // }
  //
  // Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
  //   return Future<bool>.value(true);
  // }
  //
  // void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
  //   Fluttertoast.showToast(
  //     msg: 'Invalid Purchase !',
  //     backgroundColor:
  //     Platform.isAndroid ? Colors.white : CupertinoColors.white,
  //     textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
  //   );
  // }
  //
  // Future<void> deliverProduct(PurchaseDetails purchaseDetails) async {
  //   final resalePropertyNotifier =
  //   Provider.of<ResalePropertyNotifier>(context, listen: false);
  //   DateTime createdDate = DateTime.now();
  //   setState(() {
  //     _purchases.add(purchaseDetails);
  //     _purchasePending = false;
  //   });
  //   var endingDate =
  //   DateTime(createdDate.year, createdDate.month + 3, createdDate.day);
  //   resalePropertyNotifier
  //       .insertMemPlan(context, 'Select', 3, 5999, createdDate, endingDate)
  //       .then((_) {
  //     resalePropertyNotifier.getMemPlans(context);
  //     Navigator.of(context).pop();
  //     Fluttertoast.showToast(
  //       msg: 'Successfully purchased !',
  //       backgroundColor:
  //       Platform.isAndroid ? Colors.white : CupertinoColors.white,
  //       textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
  //     );
  //   });
  // }
  //
  // void showPendingUI() {
  //   setState(() {
  //     _purchasePending = true;
  //   });
  // }
  //
  // Future<void> initStoreInfo() async {
  //   // final resalePropertyNotifier =
  //   //     Provider.of<ResalePropertyNotifier>(context, listen: false);
  //   final bool isAvailable = await _inAppPurchase.isAvailable();
  //   if (!isAvailable) {
  //     setState(() {
  //       _isAvailable = isAvailable;
  //       _products = <ProductDetails>[];
  //       _purchases = <PurchaseDetails>[];
  //       _notFoundIds = <String>[];
  //       _purchasePending = false;
  //       _loading = false;
  //     });
  //     return;
  //   }
  //
  //   final ProductDetailsResponse productDetailResponse =
  //   await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
  //   if (productDetailResponse.error != null) {
  //     setState(() {
  //       _queryProductError = productDetailResponse.error!.message;
  //       _isAvailable = isAvailable;
  //       _products = productDetailResponse.productDetails;
  //       _purchases = <PurchaseDetails>[];
  //       _notFoundIds = productDetailResponse.notFoundIDs;
  //       _purchasePending = false;
  //       _loading = false;
  //     });
  //     return;
  //   }
  //
  //   if (productDetailResponse.productDetails.isEmpty) {
  //     setState(() {
  //       _queryProductError = null;
  //       _isAvailable = isAvailable;
  //       _products = productDetailResponse.productDetails;
  //       _purchases = <PurchaseDetails>[];
  //       _notFoundIds = productDetailResponse.notFoundIDs;
  //       _purchasePending = false;
  //       _loading = false;
  //     });
  //     return;
  //   }
  //
  //   setState(() {
  //     _isAvailable = isAvailable;
  //     _products = productDetailResponse.productDetails;
  //     _notFoundIds = productDetailResponse.notFoundIDs;
  //     _purchasePending = false;
  //     _loading = false;
  //     // final ProductDetails secondItem = _products.removeAt(1);
  //     // _products = _products..add(secondItem);
  //   });
  //   // resalePropertyNotifier.memPlan = _products[0];
  // }

  @override
  Widget build(BuildContext context) {
    // final authProvider = Provider.of<AuthNotifier>(context);
    final autocompleteNotifier = Provider.of<AutocompleteNotifier>(context);

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: Platform.isAndroid ? PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: AppBar(
              backgroundColor: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? Colors.grey[900] : Colors.white,
              scrolledUnderElevation: 0.0,
            )) : CupertinoNavigationBar (
          backgroundColor: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? Colors.grey[900] : CupertinoColors.white,
        ),
        backgroundColor: (MediaQuery.of(context).platformBrightness == Brightness.dark)
            ? Colors.grey[900]
            : Platform.isAndroid
            ? Colors.white
            : CupertinoColors.white,
        body: SafeArea(
          child: WillPopScope(
            onWillPop: autocompleteNotifier.onWillPop,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 25,
                        left: 5,
                        right: 5,
                        bottom: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          // margin: const EdgeInsets.only(top: 5),
                          width: 100,
                          height: 100,
                          child: FittedBox(
                              fit: BoxFit.cover,
                              child:
                              Image.asset('assets/images/squarest.png')),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        if (Platform.isAndroid)
                          Center(
                            child: SizedBox(
                              height: 60,
                              width: double.infinity,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    backgroundColor: globalColor),
                                onPressed: () {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                      builder: (ctx) => const LoginScreen(
                                        isAccountScreen: true,
                                        isComingFromHomeLoan: false,
                                        isComingFromJoinNow: false,
                                        isComingFromKnowMore: false,
                                      )));
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(top: 8, bottom: 8),
                                  child: Text("Login/Sign up",
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
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (ctx) => const LoginScreen(
                                      isAccountScreen: true,
                                      isComingFromHomeLoan: false,
                                      isComingFromJoinNow: false,
                                      isComingFromKnowMore: false,
                                    )));
                              },
                              child: const Text("Login/Sign up",
                                  style: TextStyle(
                                      color: CupertinoColors.white,
                                      fontSize: 15)),
                            ),
                          ),
                        // if(!widget.isComingFromJoinNow)
                          const SizedBox(height: 25),
                        // if(!widget.isComingFromJoinNow)
                          Padding(
                            padding: const EdgeInsets.only(left: 5, right: 5),
                            child: Divider(
                              color:
                              (MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark)
                                  ? Colors.grey[700]
                                  : Colors.grey[300]!,
                            ),
                          ),
                        const SizedBox(height: 25),
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
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
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
                        const SizedBox(height: 50,),
                        Text(
                          'A good start is half the journey.',
                          style: CustomTextStyles.getProjectNameFont(
                              null,
                              (MediaQuery.of(context).platformBrightness == Brightness.dark) ? Platform.isAndroid
                                  ? Colors.white
                                  .withOpacity(0.8)
                                  : CupertinoColors.white
                                  .withOpacity(0.8) : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                              24),
                        ),
                        const SizedBox(height: 10,),
                        const Text(
                          'Become a Select member and enjoy hassle free experience of buying your dream property.',
                        ),
                        const SizedBox(height: 25,),
                        if (Platform.isAndroid)
                        Center(
                            child: SizedBox(
                              height: 60,
                              width: double.infinity,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    backgroundColor: globalColor),
                                onPressed: () {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                      builder: (ctx) => const KnowMoreMemPlan(isComingFromJoinNow: false, isComingFromKnowMore: true,)));
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(top: 8, bottom: 8),
                                  child: Text("Know More",
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
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (ctx) => const KnowMoreMemPlan(isComingFromJoinNow: false, isComingFromKnowMore: true,)));
                              },
                              child: const Text("Know more",
                                  style: TextStyle(
                                      color: CupertinoColors.white,
                                      fontSize: 15)),
                            ),
                          ),
                        const SizedBox(height: 25,),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
