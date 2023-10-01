import 'dart:io';

import 'package:squarest/Services/s_autocomplete_notifier.dart';
import 'package:squarest/Services/s_filter_notifier.dart';
import 'package:squarest/Utils/u_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
//import 'package:flutter/src/material/chip_filter.dart' as filterChip;

class AppliedFilters extends StatefulWidget {
  const AppliedFilters({
    Key? key,
  }) : super(key: key);

  @override
  State<AppliedFilters> createState() => _AppliedFiltersState();
}

class _AppliedFiltersState extends State<AppliedFilters> {
  @override
  Widget build(BuildContext context) {
    List<int> bhkList = context.watch<FilterNotifier>().appliedFilter.bhk;
    bhkList.sort();
    return SizedBox(
      width: double.infinity,
      // color: (MediaQuery.of(context).platformBrightness == Brightness.dark)
      //     ? Colors.black54
      //     : Colors.white,
      child: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.35,
            padding: const EdgeInsets.all(5),
            child: Consumer2<FilterNotifier, AutocompleteNotifier>(
              builder: (ctx, filters, autoCompleteNotifier, _) => filters
                              .appliedFilter.slectedIndexTownship !=
                          0 ||
                      filters.appliedFilter.selectedIndexReadyStatus != 0 ||
                      filters.appliedFilter.selectedIndexAvailableFlats != 0 ||
                      filters.appliedFilter.selectedBuilderId.isNotEmpty ||
                      filters.appliedFilter.priceChoice
                          .where((element) => element != 0)
                          .toList()
                          .isNotEmpty ||
                      filters.appliedFilter.carpetChoice
                          .where((element) => element != 0)
                          .toList()
                          .isNotEmpty ||
                      filters.appliedFilter.bhk
                          .where((element) => element != 0)
                          .toList()
                          .isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        filters.setFiltersToFalse();
                        filters.selectedChoices.clear();
                        filters.selectedChoices.add(0);
                        context.read<FilterNotifier>().resetAppliedFilter();
                        autoCompleteNotifier.projectList =
                            autoCompleteNotifier.originalList;
                        if (filters.isFilterApplied == false) {
                          Fluttertoast.showToast(
                            msg: 'All filters are removed',
                            backgroundColor: Platform.isAndroid ? Colors.white : CupertinoColors.white,
                            textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
                          );
                        }
                      },
                      child: Container(
                          height: 33,
                          decoration: BoxDecoration(
                            color: Platform.isAndroid ? Colors.red : CupertinoColors.systemRed,
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.filter_list_off_outlined,
                                color: Platform.isAndroid ? Colors.white : CupertinoColors.white,
                              ),
                              Text(
                                'Clear All',
                                style: TextStyle(
                                    fontSize: 17, color: Platform.isAndroid ? Colors.white : CupertinoColors.white),
                              ),
                            ],
                          )),
                    )
                  : Container(),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.65,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (context
                      .watch<FilterNotifier>()
                      .appliedFilter
                      .selectedBuilderId
                      .isNotEmpty)
                    FilterChip1(
                      text: context
                                  .watch<FilterNotifier>()
                                  .appliedFilter
                                  .selectedBuilderId
                                  .where((element) => element != 0)
                                  .toList()
                                  .isNotEmpty &&
                              context
                                  .watch<FilterNotifier>()
                                  .appliedFilter
                                  .selectedBuilderId
                                  .contains(0)
                          ? 'Builders : ${context.watch<FilterNotifier>().selectedIndex.length} + Others'
                          : context
                                  .watch<FilterNotifier>()
                                  .appliedFilter
                                  .selectedBuilderId
                                  .where((element) => element != 0)
                                  .toList()
                                  .isNotEmpty
                              ? 'Builders : ${context.watch<FilterNotifier>().selectedIndex.length}'
                              : "Builders : Others",
                    ),
                  if (context
                              .watch<FilterNotifier>()
                              .appliedFilter
                              .priceChoice[0] !=
                          0 ||
                      context
                              .watch<FilterNotifier>()
                              .appliedFilter
                              .priceChoice[1] !=
                          0)
                    FilterChip1(
                      text: context
                                      .watch<FilterNotifier>()
                                      .appliedFilter
                                      .priceChoice[0] !=
                                  0 &&
                              context
                                      .watch<FilterNotifier>()
                                      .appliedFilter
                                      .priceChoice[1] ==
                                  0
                          ? "Min ₹ ${context.watch<FilterNotifier>().appliedFilter.priceChoice[0]}L"
                          : context
                                          .watch<FilterNotifier>()
                                          .appliedFilter
                                          .priceChoice[0] ==
                                      0 &&
                                  context
                                          .watch<FilterNotifier>()
                                          .appliedFilter
                                          .priceChoice[1] !=
                                      0
                              ? "Max ₹ ${context.watch<FilterNotifier>().appliedFilter.priceChoice[1]}L"
                              : context
                                              .watch<FilterNotifier>()
                                              .appliedFilter
                                              .priceChoice[0] !=
                                          0 &&
                                      context
                                              .watch<FilterNotifier>()
                                              .appliedFilter
                                              .priceChoice[1] !=
                                          0
                                  ? "₹ ${context.watch<FilterNotifier>().appliedFilter.priceChoice[0]}L - ₹ ${context.watch<FilterNotifier>().appliedFilter.priceChoice[1]}L"
                                  : "",
                    ),
                  if (context.watch<FilterNotifier>().appliedFilter.bhk[0] != 0)
                    FilterChip1(
                        text:
                            "BHK ${bhkList.join(" ")}${(bhkList.contains(4)) ? "+" : ""}"),
                  if (context
                              .watch<FilterNotifier>()
                              .appliedFilter
                              .carpetChoice[0] !=
                          0 ||
                      context
                              .watch<FilterNotifier>()
                              .appliedFilter
                              .carpetChoice[1] !=
                          0)
                    FilterChip1(
                      text: context
                                      .watch<FilterNotifier>()
                                      .appliedFilter
                                      .carpetChoice[0] !=
                                  0 &&
                              context
                                      .watch<FilterNotifier>()
                                      .appliedFilter
                                      .carpetChoice[1] ==
                                  0
                          ? "Min ${context.watch<FilterNotifier>().appliedFilter.carpetChoice[0]} sq.feet"
                          : context
                                          .watch<FilterNotifier>()
                                          .appliedFilter
                                          .carpetChoice[0] ==
                                      0 &&
                                  context
                                          .watch<FilterNotifier>()
                                          .appliedFilter
                                          .carpetChoice[1] !=
                                      0
                              ? "Max ${context.watch<FilterNotifier>().appliedFilter.carpetChoice[1]} sq.feet"
                              : context
                                              .watch<FilterNotifier>()
                                              .appliedFilter
                                              .carpetChoice[0] !=
                                          0 &&
                                      context
                                              .watch<FilterNotifier>()
                                              .appliedFilter
                                              .carpetChoice[1] !=
                                          0
                                  ? "${context.watch<FilterNotifier>().appliedFilter.carpetChoice[0]} - ${context.watch<FilterNotifier>().appliedFilter.carpetChoice[1]} sq.feet"
                                  : "",
                    ),
                  if (context
                          .watch<FilterNotifier>()
                          .appliedFilter
                          .slectedIndexTownship !=
                      0)
                    FilterChip1(
                        text:
                            "Township ${township[context.watch<FilterNotifier>().appliedFilter.slectedIndexTownship]}"),
                  if (context
                          .watch<FilterNotifier>()
                          .appliedFilter
                          .selectedIndexAvailableFlats !=
                      0)
                    FilterChip1(
                        text: availableFlats[context
                            .watch<FilterNotifier>()
                            .appliedFilter
                            .selectedIndexAvailableFlats]),
                  if (context
                          .watch<FilterNotifier>()
                          .appliedFilter
                          .selectedIndexReadyStatus !=
                      0)
                    FilterChip1(
                        text: plannedCompletion[context
                            .watch<FilterNotifier>()
                            .appliedFilter
                            .selectedIndexReadyStatus]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FilterChip1 extends StatelessWidget {
  final String text;

  const FilterChip1({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: FilterChip(
        showCheckmark: false,
        selectedColor: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
        padding: const EdgeInsets.only(left: 13, right: 13),
        backgroundColor: Platform.isAndroid ? Colors.white : CupertinoColors.white,
        disabledColor: Platform.isAndroid ? Colors.blue : CupertinoColors.activeBlue,
        onSelected: (isSelected) {},
        label: Text(text, style: TextStyle(color: Platform.isAndroid ? Colors.white : CupertinoColors.white)),
        selected: true,
      ),
    );
  }
}
