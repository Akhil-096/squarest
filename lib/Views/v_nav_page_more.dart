import 'dart:io';

import 'package:squarest/Models/m_more.dart';
import 'package:squarest/Services/s_connectivity_notifier.dart';
import 'package:squarest/Views/v_about.dart';
import 'package:squarest/Views/v_emi_calculator.dart';
import 'package:squarest/Views/v_faq_and_policies.dart';
import 'package:squarest/Views/v_feedback.dart';
import 'package:squarest/Views/v_know_more_mem_plan.dart';
import 'package:squarest/Views/v_no_internet.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Services/s_autocomplete_notifier.dart';
import '../Services/s_emi_notifier.dart';


class More extends StatelessWidget {
  const More({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final con = context.watch<ConnectivityChangeNotifier>();
    final autocompleteNotifier = Provider.of<AutocompleteNotifier>(context);
    var list = [
      MoreModel(1, 'Select Membership'),
      MoreModel(2, 'EMI Calculator'),
      // MoreModel(2, 'Frequently asked questions (FAQs)'),
      MoreModel(3, 'Feedback'),
      MoreModel(4, 'Policies'),
      MoreModel(5, 'About Us'),
    ];

    return (con.connectivity == null)
        ? const Center(child: CircularProgressIndicator())
        : ((con.connectivity == ConnectivityResult.none) ||
        (con.isDeviceConnected == false))
        ? const NoInternet()
        : Scaffold(
      appBar: Platform.isAndroid ? PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          scrolledUnderElevation: 0.0,
          backgroundColor:
          (MediaQuery.of(context).platformBrightness ==
              Brightness.dark)
              ? Colors.grey[900]
              : Colors.white,
          // elevation: 1,
        ),
      ) : CupertinoNavigationBar(
        backgroundColor: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? Colors.grey[900] : CupertinoColors.white,
      ),
            body: SafeArea(
              child: WillPopScope(
                    onWillPop: autocompleteNotifier.onWillPop,
                    child: ListView.builder(
                      itemBuilder: (ctx, i) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                          width: double.infinity,
                          child: Card(
                            child: ListTile(
                              title: Text(list[i].title),
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                if (list[i].id == 5) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AboutScreen()),
                                  );
                                } else if (list[i].id == 4) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            FaqAndPoliciesScreen(list[i].id)),
                                  );
                                } else if (list[i].id == 3) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const FeedBackScreen()),
                                  );
                                } else if (list[i].id == 2) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const EmiCalculator()),
                                  ).whenComplete(() {
                                    final emiNotifier = Provider.of<EmiNotifier>(context, listen: false);
                                    emiNotifier.emiISV = 7.5;
                                    emiNotifier.emiTSV = 15;
                                    emiNotifier. emiMonthly = '₹ 0';
                                    emiNotifier. interestAmount = 0;
                                    emiNotifier. emiLSV = 25;
                                    emiNotifier. emiR = 0.0;
                                    emiNotifier. emiN = 1;
                                  });
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const KnowMoreMemPlan(isComingFromJoinNow: true, isComingFromKnowMore: false,)),
                                  );
                                }
                              },
                              trailing: Icon(Platform.isAndroid ? Icons.chevron_right_outlined : CupertinoIcons.right_chevron),
                            ),
                          ),
                        );
                      },
                      itemCount: list.length,
                    ),
                  ),
            ),
              );
  }

  // Future<void> showMyAboutDialog(BuildContext context) async {
  //   PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: false, // user must tap button!
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Row(
  //           children: [
  //             const SizedBox(),
  //             const SizedBox(
  //               width: 20,
  //             ),
  //             Column(
  //               children: [
  //                 const Text('squarest'),
  //                 Text('Version ${packageInfo.version}', style: const TextStyle(fontSize: 14),),
  //               ],
  //             )
  //           ],
  //         ),
  //           // showDialog(
  //           //   context: context,
  //           //   // applicationVersion: 'Version  1.0.00',
  //           //   // applicationName: 'squarest',
  //           //   // applicationIcon: const FlutterLogo(),
  //           //   // applicationLegalese:
  //           //   //     '© Apartmint Solutions Private Limited  2022-2022',
  //           //   builder: (BuildContext context) {
  //           //     return AlertDialog();
  //           //   },
  //           //   // children: [],
  //           //
  //           // );
  //         content: SingleChildScrollView(
  //           child: ListBody(
  //             children: <Widget>[
  //               Text('© Apartmint Solutions Private Limited  2022-2022', style: TextStyle(
  //                 fontSize: 12, color: Colors.grey[500]!
  //               ),),
  //             ],
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Close', style: TextStyle(
  //           fontSize: 16),),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
