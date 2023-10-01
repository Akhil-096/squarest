import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Services/s_resale_property_notifier.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import '../Utils/u_custom_styles.dart';


class AllMemPlans extends StatefulWidget {
  final String appBarTitle;
  const AllMemPlans({Key? key, required this.appBarTitle}) : super(key: key);

  @override
  State<AllMemPlans> createState() => _AllMemPlansState();
}

class _AllMemPlansState extends State<AllMemPlans> {

  @override
  void initState() {
    super.initState();
    final resalePropertyNotifier = Provider.of<ResalePropertyNotifier>(context, listen: false);
    resalePropertyNotifier.getMemPlans(context);

  }

  @override
  Widget build(BuildContext context) {
    final resalePropertyNotifier = Provider.of<ResalePropertyNotifier>(context);

    return Scaffold(
      appBar: Platform.isAndroid ? PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          scrolledUnderElevation: 0.0,
          backgroundColor: (MediaQuery.of(context).platformBrightness ==
              Brightness.dark)
              ? Colors.grey[900]
              : Colors.white,
          title: Text(widget.appBarTitle, style: CustomTextStyles.getTitle(null, (MediaQuery.of(context).platformBrightness ==
              Brightness.dark)
              ? Colors.white
              : Colors.black, null, 19),),
        ),
      ) : CupertinoNavigationBar(
        backgroundColor: (MediaQuery.of(context).platformBrightness ==
            Brightness.dark)
            ? Colors.grey[900]
            : CupertinoColors.white,
        middle: Text(widget.appBarTitle, style: CustomTextStyles.getTitle(null, (MediaQuery.of(context).platformBrightness ==
            Brightness.dark)
            ? CupertinoColors.white
            : CupertinoColors.black, null, 19),),
      ),
      body: SafeArea(
        child: resalePropertyNotifier.isPlansLoading ? const SizedBox() : ListView.builder(
            padding: const EdgeInsets.all(5),
            itemCount: resalePropertyNotifier.memPlans.length,
            itemBuilder: (ctx, i) {
              return Card(
                elevation: 2,
                child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                              Padding(
                              padding:
                              const EdgeInsets
                                  .only(left: 10),
                              child: Text('₹ ${resalePropertyNotifier.memPlans[i].mem_plan_amt.toString().replaceAll(".0", "")} /-', style: const TextStyle(fontWeight: FontWeight.bold),)),
                          const SizedBox(height: 2.5,),
                          Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                  '${resalePropertyNotifier.memPlans[i].mem_plan_durn} ${resalePropertyNotifier.memPlans[i].mem_plan_durn == 1 ? 'Month' : 'Months'}',
                                  style: const TextStyle(fontWeight: FontWeight.bold))),
                            ],
                      ),
                      Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Starting on ${DateFormat('dd-MM-yyyy').format(resalePropertyNotifier.memPlans[i].created_on)}'),

                              ])),
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 5),
                        child: Card(
                          color: (resalePropertyNotifier.memPlans.isNotEmpty && !DateTime.now().isBefore(resalePropertyNotifier.memPlans[i].ending_on)) ? (Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey ): (Platform.isAndroid ? Colors.green : CupertinoColors.activeGreen),
                          child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text((resalePropertyNotifier.memPlans.isNotEmpty && !DateTime.now().isBefore(resalePropertyNotifier.memPlans[i].ending_on)) ? 'Expired' :
                              'Active',
                                style: TextStyle(color: Platform.isAndroid ? Colors.white : CupertinoColors.white),
                              )),
                        ),
                      ),
                      Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .end,
                            children: [
                              Text((resalePropertyNotifier.memPlans.isNotEmpty && !DateTime.now().isBefore(resalePropertyNotifier.memPlans[i].ending_on)) ? 'Ended on ${DateFormat('dd-MM-yyyy').format(resalePropertyNotifier.memPlans[i].ending_on)}' :
                              'Ending on ${DateFormat('dd-MM-yyyy').format(resalePropertyNotifier.memPlans[i].ending_on)}'),
                              if(resalePropertyNotifier.memPlans.isNotEmpty && DateTime.now().isBefore(resalePropertyNotifier.memPlans[i].ending_on))
                              Text(
                                '${DateTime.now().difference(resalePropertyNotifier.memPlans[0].ending_on).inDays.toString().replaceAll('-', '')} days left', style: const TextStyle(fontWeight: FontWeight.bold),),
                            ],
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                ]),
              );
            }),
      )
    );
  }
}
