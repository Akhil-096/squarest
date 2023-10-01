import 'dart:io';

import 'package:squarest/Services/s_connectivity_notifier.dart';
import 'package:squarest/Utils/u_constants.dart';
import 'package:squarest/Views/v_loan_and_mem_contact_us.dart';
import 'package:squarest/Views/v_apply_home_loan.dart';
import 'package:squarest/Views/v_login.dart';
import 'package:squarest/Views/v_no_internet.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../Services/s_auth_notifier.dart';
import '../Services/s_autocomplete_notifier.dart';
import '../Utils/u_custom_styles.dart';
import '../Services/s_remote_config_service.dart';
import 'package:shimmer_animation/shimmer_animation.dart';


class HomeLoan extends StatefulWidget {
  const HomeLoan({Key? key}) : super(key: key);

  @override
  State<HomeLoan> createState() => _HomeLoanState();
}

class _HomeLoanState extends State<HomeLoan> {
  final _form = GlobalKey<FormState>();
  bool showBanner = false;


  @override
  void initState() {
    super.initState();
    getShowBanner();
  }

  getShowBanner() async {
    showBanner = await RemoteConfigService.getShowBanner();
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    final con = context.watch<ConnectivityChangeNotifier>();
    final authNotifier = Provider.of<AuthNotifier>(context);
    final autocompleteNotifier = Provider.of<AutocompleteNotifier>(context);
    return ((con.connectivity == ConnectivityResult.none) ||
        (con.isDeviceConnected == false))
        ? const NoInternet()
        : GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Scaffold(
              appBar: AppBar(
                scrolledUnderElevation: 0.0,
                toolbarHeight: showBanner ? 75.0 : null,
                backgroundColor: (MediaQuery.of(context).platformBrightness ==
                        Brightness.dark)
                    ? Colors.grey[900]
                    : Platform.isAndroid ? Colors.white : CupertinoColors.white,
                elevation: 0,
                centerTitle: true,
                title: Row(
                  mainAxisAlignment: !showBanner ? MainAxisAlignment.center : MainAxisAlignment.end,
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'squarest',
                              style: CustomTextStyles.getTitle(
                                  null,
                                  (MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark)
                                      ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                      : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                  null,
                                  20),
                            ),
                            const SizedBox(
                              width: 2,
                            ),
                          ],
                        ),
                        Text(
                          'Home Loans',
                          style: CustomTextStyles.getTitle(
                              null,
                              (MediaQuery.of(context).platformBrightness ==
                                      Brightness.dark)
                                  ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                  : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                              null,
                              20),
                        ),
                      ],
                    ),
                    if(showBanner)
                    const SizedBox(width: 10,),
                    if(showBanner)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Shimmer(
                          duration: const Duration(seconds: 1),
                          interval: const Duration(seconds: 1),
                          child: Container(
                            padding: const EdgeInsets.only(left: 7, right: 7),
                            height: 65,
                            width: 65,
                            decoration: BoxDecoration(
                                border: Border.all(width: 3, color: Platform.isAndroid ? Colors.yellow : CupertinoColors.systemYellow),
                                shape: BoxShape.circle,
                                color: Platform.isAndroid ? Colors.red : CupertinoColors.systemRed,
                            ),
                            child: Center(
                              child: RichText(
                                textAlign: TextAlign.center,
                                  maxLines: 10,
                                  text: TextSpan(children: [
                                    TextSpan(text: 'Zero', style: TextStyle(fontSize: 8, color: Platform.isAndroid ? Colors.white : CupertinoColors.white, fontWeight: FontWeight.bold)),
                                    TextSpan(text: '\nprocessing', style: TextStyle(fontSize: 8, color: Platform.isAndroid ? Colors.white : CupertinoColors.white)),
                                    TextSpan(text: '\nfee', style: TextStyle(fontSize: 8, color: Platform.isAndroid ? Colors.white : CupertinoColors.white)),
                                    TextSpan(text: '\ntill', style: TextStyle(fontSize: 8, color: Platform.isAndroid ? Colors.white : CupertinoColors.white)),
                                    TextSpan(text: '\n31.03.2023', style: TextStyle(fontSize: 8, color: Platform.isAndroid ? Colors.white : CupertinoColors.white, fontWeight: FontWeight.bold)),
                                  ])),
                            ),
                          ),
                        ),
                        const SizedBox(width: 2,),
                        const Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text('*Terms apply', style: TextStyle(fontSize: 8,)))
                      ],
                    ),
                  ],
                ),
              ),
              body: SafeArea(
                child:  WillPopScope(
                  onWillPop: autocompleteNotifier.onWillPop,
                  child: SingleChildScrollView(
                    child: Form(
                      key: _form,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(
                              height: 1,
                              color: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Center(
                              child: Text(
                                'Our curated service for Home Loans',
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: (MediaQuery.of(context)
                                              .platformBrightness ==
                                          Brightness.dark)
                                      ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 50,
                                        width: 50,
                                        padding: const EdgeInsets.all(5),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: globalColor,
                                        ),
                                        child: Icon(Icons.scale,
                                            size: 20, color: Platform.isAndroid ? Colors.white : CupertinoColors.white),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      const Text('Compare'),
                                    ],
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Icon(Platform.isAndroid ? Icons.chevron_right : CupertinoIcons.chevron_right, size: 40)),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 50,
                                        width: 50,
                                        padding: const EdgeInsets.all(5),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: globalColor,
                                        ),
                                        child: Icon(Icons.manage_accounts,
                                            size: 20, color: Platform.isAndroid ? Colors.white : CupertinoColors.white),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      const Text('Customize'),
                                    ],
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Icon(Platform.isAndroid ? Icons.chevron_right : CupertinoIcons.chevron_right, size: 40)),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 50,
                                        width: 50,
                                        padding: const EdgeInsets.all(5),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: globalColor,
                                        ),
                                        child: Icon(Icons.shopping_basket,
                                            size: 20, color: Platform.isAndroid ? Colors.white : CupertinoColors.white),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      const Text('Cash'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Divider(
                              height: 1,
                              color: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            StreamBuilder(
                                stream:
                                    FirebaseAuth.instance.authStateChanges(),
                                builder: (ctx, userSnapshot) {
                                  if (!userSnapshot.hasData) {
                                    if(Platform.isAndroid){
                                      return Center(
                                        child: SizedBox(
                                          height: 60,
                                          width: double.infinity,
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                                foregroundColor: Colors.black,
                                                backgroundColor: globalColor),
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (ctx) =>
                                                      const LoanAndMemContactUs(appBarTitle: 'Contact Us', isComingFromPlan: false,)));
                                              // Navigator.of(context).push(
                                              //     MaterialPageRoute(
                                              //         builder: (ctx) =>
                                              //         const LoginScreen(
                                              //           isAccountScreen:
                                              //           false,
                                              //           isComingFromHomeLoan:
                                              //           true,
                                              //           isComingFromJoinNow: false,
                                              //         )));
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.only(
                                                  top: 8, bottom: 8),
                                              child: Text("Apply for Home Loan",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15)),
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      return SizedBox(
                                        width: double.infinity,
                                        child: CupertinoButton(
                                          borderRadius: BorderRadius.circular(25),
                                          color: globalColor,
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (ctx) =>
                                                    const LoginScreen(
                                                      isAccountScreen:
                                                      false,
                                                      isComingFromHomeLoan:
                                                      true,
                                                      isComingFromJoinNow: false,
                                                      isComingFromKnowMore: false,
                                                    )));
                                          },
                                          child: const Text("Apply for Home Loan",
                                              style: TextStyle(
                                                  color: CupertinoColors.white,
                                                  fontSize: 15)),),
                                      );
                                    }
                                  } else {
                                    return FutureBuilder<dynamic>(
                                      future: Future.wait([
                                        authNotifier.checkIfPhoneNoSubmitted(),
                                        authNotifier.getSavedPhoneNo()
                                      ]),
                                      builder: (ctx, snapshot) {
                                        // if(snapshot.connectionState == ConnectionState.waiting) {
                                        //   return const SizedBox();
                                        // } else {
                                          if (!snapshot.data[0]) {
                                            return const ApplyHomeLoan();
                                          } else {
                                            return Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: const [
                                                Center(
                                                  child: Text(
                                                    'Home Loan Inquiry Received.',
                                                    style: TextStyle(
                                                        fontWeight:
                                                        FontWeight.bold),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 25,
                                                ),
                                                Text(
                                                  'We have received your interest for a home loan. We will contact you shortly for next steps.',
                                                  maxLines: 3,
                                                )
                                              ],
                                            );
                                          }
                                        // }

                                          // }
                                        // }
                                      },
                                    );
                                  }
                                })
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
