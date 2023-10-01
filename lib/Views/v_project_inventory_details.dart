import 'dart:io';

import 'package:squarest/Models/m_project_inventory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Services/s_autocomplete_notifier.dart';
import '../Utils/u_custom_styles.dart';

class ProjectInventoryDetails extends StatefulWidget {
  final String buildingName;
  final int projectId;

  const ProjectInventoryDetails(
      {required this.buildingName, required this.projectId, Key? key})
      : super(key: key);

  @override
  State<ProjectInventoryDetails> createState() => _ProjectInventoryDetailsState();
}

class _ProjectInventoryDetailsState extends State<ProjectInventoryDetails> {
  Future<List<ProjectInventory>> projectInventory = Future(() => []);

  @override
  void initState() {
    super.initState();
    // ProjectService projectService = ProjectService();
    // projectInventory = projectService.getProjectInventory(widget.projectId);
    getProjectInventory();
  }

  @override
  Widget build(BuildContext context) {
    final autoCompleteNotifier = Provider.of<AutocompleteNotifier>(context);
    // if (autoCompleteNotifier.projectInventoryList.isEmpty) {
    //   return Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Row(
    //         mainAxisAlignment:
    //         MainAxisAlignment.spaceBetween,
    //         crossAxisAlignment:
    //         CrossAxisAlignment.start,
    //         children: [
    //           const Text('Type'),
    //           const SizedBox(
    //             width: 5,
    //           ),
    //           RichText(
    //             text: TextSpan(children: [
    //               TextSpan(
    //                   text: 'Min carpet',
    //                   style: TextStyle(
    //                       color: (MediaQuery.of(
    //                           context)
    //                           .platformBrightness ==
    //                           Brightness.dark)
    //                           ? Colors.white
    //                           : Colors.black)),
    //               TextSpan(
    //                   text: '\narea (sq.ft.)',
    //                   style: TextStyle(
    //                       color: (MediaQuery.of(
    //                           context)
    //                           .platformBrightness ==
    //                           Brightness.dark)
    //                           ? Colors.white
    //                           : Colors.black))
    //             ]),
    //             maxLines: 2,
    //           ),
    //           const SizedBox(
    //             width: 5,
    //           ),
    //           RichText(
    //             text: TextSpan(children: [
    //               TextSpan(
    //                   text: 'Max carpet',
    //                   style: TextStyle(
    //                       color: (MediaQuery.of(
    //                           context)
    //                           .platformBrightness ==
    //                           Brightness.dark)
    //                           ? Colors.white
    //                           : Colors.black)),
    //               TextSpan(
    //                   text: '\narea (sq.ft.)',
    //                   style: TextStyle(
    //                       color: (MediaQuery.of(
    //                           context)
    //                           .platformBrightness ==
    //                           Brightness.dark)
    //                           ? Colors.white
    //                           : Colors.black))
    //             ]),
    //             maxLines: 3,
    //           ),
    //           const SizedBox(
    //             width: 5,
    //           ),
    //           RichText(
    //             text: TextSpan(children: [
    //               TextSpan(
    //                   text: 'Total',
    //                   style: TextStyle(
    //                       color: (MediaQuery.of(
    //                           context)
    //                           .platformBrightness ==
    //                           Brightness.dark)
    //                           ? Colors.white
    //                           : Colors.black)),
    //               TextSpan(
    //                   text: '\nUnits',
    //                   style: TextStyle(
    //                       color: (MediaQuery.of(
    //                           context)
    //                           .platformBrightness ==
    //                           Brightness.dark)
    //                           ? Colors.white
    //                           : Colors.black))
    //             ]),
    //             maxLines: 2,
    //           ),
    //           const SizedBox(
    //             width: 5,
    //           ),
    //           RichText(
    //             text: TextSpan(children: [
    //               TextSpan(
    //                   text: 'Available',
    //                   style: TextStyle(
    //                       color: (MediaQuery.of(
    //                           context)
    //                           .platformBrightness ==
    //                           Brightness.dark)
    //                           ? Colors.white
    //                           : Colors.black)),
    //               TextSpan(
    //                   text: '\nUnits',
    //                   style: TextStyle(
    //                       color: (MediaQuery.of(
    //                           context)
    //                           .platformBrightness ==
    //                           Brightness.dark)
    //                           ? Colors.white
    //                           : Colors.black))
    //             ]),
    //             maxLines: 2,
    //           ),
    //         ],
    //       ),
    //     ],
    //   );
    // } else {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (ctx, i) => Row(
          // crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 50,
              child: Text(
                '${autoCompleteNotifier.projectInventoryList.where((element) => element.building_name!.contains(widget.buildingName)).toList()[i].apartment_type}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                  style: CustomTextStyles.getBodySmall(null, (MediaQuery.of(context)
                  .platformBrightness ==
                  Brightness.dark)
                  ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                  : Platform.isAndroid ? Colors.black : CupertinoColors.black, null, 14),
              ),
            ),
            SizedBox(
              width: 50,
              child: Text(
                '${(autoCompleteNotifier.projectInventoryList.where((element) => element.building_name!.contains(widget.buildingName)).toList()[i].min_area)?.round()}', maxLines: 1,overflow: TextOverflow.ellipsis, style: CustomTextStyles.getBodySmall(null, (MediaQuery.of(context)
                  .platformBrightness ==
                  Brightness.dark)
                  ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                  : Platform.isAndroid ? Colors.black : CupertinoColors.black, null, 14),),
            ),
            Container(
              padding: const EdgeInsets.only(left: 15),
              width: 50,
              child: Text(
                '${(autoCompleteNotifier.projectInventoryList.where((element) => element.building_name!.contains(widget.buildingName)).toList()[i].max_area)?.round()}', maxLines: 1,overflow: TextOverflow.ellipsis, style: CustomTextStyles.getBodySmall(null, (MediaQuery.of(context)
                  .platformBrightness ==
                  Brightness.dark)
                  ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                  : Platform.isAndroid ? Colors.black : CupertinoColors.black, null, 14),),
            ),
            Container(
              padding: const EdgeInsets.only(left: 20),
              width: 50,
              child: Text(
                '${autoCompleteNotifier.projectInventoryList.where((element) => element.building_name!.contains(widget.buildingName)).toList()[i].total_apts}', maxLines: 1,overflow: TextOverflow.ellipsis, style: CustomTextStyles.getBodySmall(null, (MediaQuery.of(context)
                  .platformBrightness ==
                  Brightness.dark)
                  ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                  : Platform.isAndroid ? Colors.black : CupertinoColors.black, null, 14),),
            ),
            Container(
              padding: const EdgeInsets.only(left: 10),
              width: 50,
              child: Text(autoCompleteNotifier.projectInventoryList.where((element) => element.building_name!.contains(widget.buildingName)).toList()[i].total_apts! - autoCompleteNotifier.projectInventoryList.where((element) => element.building_name!.contains(widget.buildingName)).toList()[i].booked_apts! == 0 ? '0' :
              '${autoCompleteNotifier.projectInventoryList.where((element) => element.building_name!.contains(widget.buildingName)).toList()[i].total_apts! - autoCompleteNotifier.projectInventoryList.where((element) => element.building_name!.contains(widget.buildingName)).toList()[i].booked_apts!}', maxLines: 1, style: CustomTextStyles.getBodySmall(null, (MediaQuery.of(context)
                  .platformBrightness ==
                  Brightness.dark)
                ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                : Platform.isAndroid ? Colors.black : CupertinoColors.black, null, 14),),
            ),
          ],
        ),
        itemCount: autoCompleteNotifier.projectInventoryList
            .where((element) => element.building_name!
            .contains(widget.buildingName))
            .toList()
            .length,
      );
    // }
  }
  getProjectInventory() {
    final autoCompleteNotifier = Provider.of<AutocompleteNotifier>(context, listen: false);
    autoCompleteNotifier.getProjectInventory(widget.projectId);
  }
}
