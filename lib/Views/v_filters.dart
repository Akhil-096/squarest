import 'dart:io';
import 'package:squarest/Models/m_applied_filters.dart';
import 'package:squarest/Services/s_autocomplete_notifier.dart';
import 'package:squarest/Services/s_filter_notifier.dart';
import 'package:squarest/Services/s_connectivity_notifier.dart';
import 'package:squarest/Views/v_no_internet.dart';
import 'package:auto_route/auto_route.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:squarest/Utils/u_constants.dart';
import 'package:darq/darq.dart';
import '../Utils/u_custom_styles.dart';
import '../Utils/u_multi_select_controller.dart';

class Filters extends StatefulWidget {
  const Filters({Key? key}) : super(key: key);

  @override
  State<Filters> createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
  int? _priceLowChoice;
  int? _priceHighChoice;
  int? _carpetMinChoice;
  int? _carpetMaxChoice;
  late int _selectedIndexTownship;
  late int _selectedIndexAvailableFlats;
  late int _selectedIndexReadyStatus;
  AutocompleteNotifier autocompleteNotifier = AutocompleteNotifier();
  List<int> brandedBuilders = [];
  MultiSelectController controller = MultiSelectController();

  @override
  void initState() {
    super.initState();
    brandedBuilders = brandedBuilders..addAll(context.read<FilterNotifier>().appliedFilter.selectedBuilderId);
    controller.selectedIndexes = context.read<FilterNotifier>().selectedIndex;
    autocompleteNotifier =
        Provider.of<AutocompleteNotifier>(context, listen: false);
    _priceLowChoice =
    context.read<FilterNotifier>().appliedFilter.priceChoice[0];
    _priceHighChoice =
    context.read<FilterNotifier>().appliedFilter.priceChoice[1];
    _carpetMinChoice =
    context.read<FilterNotifier>().appliedFilter.carpetChoice[0];
    _carpetMaxChoice =
    context.read<FilterNotifier>().appliedFilter.carpetChoice[1];
    _selectedIndexTownship =
        context.read<FilterNotifier>().appliedFilter.slectedIndexTownship;
    _selectedIndexReadyStatus =
        context.read<FilterNotifier>().appliedFilter.selectedIndexReadyStatus;
    _selectedIndexAvailableFlats = context
        .read<FilterNotifier>()
        .appliedFilter
        .selectedIndexAvailableFlats;
    if(autocompleteNotifier.isMapIdle){
      setState(() {
        controller.selectedIndexes.clear();
        if(context
            .read<FilterNotifier>().isOthersSelected){
          context
              .read<FilterNotifier>().isAnySelected = false;
        } else {
          context
              .read<FilterNotifier>().isAnySelected = true;
        }

        autocompleteNotifier.isMapIdle = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final con = context.watch<ConnectivityChangeNotifier>();
    return (con.connectivity == null)
        ? const Center(child: CupertinoActivityIndicator())
        : ((con.connectivity == ConnectivityResult.none) ||
        (con.isDeviceConnected == false))
        ? const NoInternet()
        : Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (_, __) => [
            if(Platform.isAndroid)
              SliverAppBar(
                floating: true,
                // forceElevated: true,
                leading: GestureDetector(
                  child: Icon(Icons.clear, color: (MediaQuery.of(context).platformBrightness ==
                      Brightness.dark)
                      ? Colors.white : Colors.black),
                  onTap: () {
                    AutoRouter.of(context).pop();
                  },
                ),
                backgroundColor: (MediaQuery.of(context).platformBrightness ==
                    Brightness.dark)
                    ? Colors.grey[900]
                    : Colors.white,
                centerTitle: true,
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Consumer<FilterNotifier>(
                        builder: (ctx, filters, _) => GestureDetector(
                          onTap: () {
                            setState(() {
                              brandedBuilders.clear();
                              _selectedIndexTownship = 0;
                              _selectedIndexAvailableFlats = 0;
                              _selectedIndexReadyStatus = 0;
                              filters.selectedChoices.clear();
                              controller.selectedIndexes.clear();
                              filters.selectedChoices.add(0);
                              _priceLowChoice = priceLow[0];
                              _priceHighChoice = priceHigh[0];
                              _carpetMinChoice = carpetAreaMin[0];
                              _carpetMaxChoice = carpetAreaMax[0];
                              context
                                  .read<FilterNotifier>()
                                  .resetAppliedFilter();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.only(top: 7, left: 12, right: 12, bottom: 7),
                            decoration: const BoxDecoration(
                              color: globalColor,
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                            ),
                            child: const Text("Clear all",
                                style: TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        ),
                        // child:
                      ),
                    ),
                  )
                ],
                title: Text(
                  "Filters",
                  style: CustomTextStyles.getTitle(null, (MediaQuery.of(context).platformBrightness ==
                      Brightness.dark)
                      ? Colors.white
                      : Colors.black, null, 20),
                ),
              ),
            if(Platform.isIOS)
            CupertinoSliverNavigationBar(
              backgroundColor: (MediaQuery.of(context).platformBrightness ==
                  Brightness.dark)
                  ? Colors.grey[900]
                  : CupertinoColors.white,
              leading: GestureDetector(
                child: Icon(CupertinoIcons.clear, color: (MediaQuery.of(context).platformBrightness ==
                    Brightness.dark)
                    ? CupertinoColors.white
                    : CupertinoColors.black, size: 25,),
                onTap: () {
                  AutoRouter.of(context).pop();
                },
              ),
              largeTitle: Text(
                "Filters",
                style: CustomTextStyles.getTitle(null, (MediaQuery.of(context).platformBrightness ==
                    Brightness.dark)
                    ? CupertinoColors.white
                    : CupertinoColors.black, null, null),
              ),
              trailing: Consumer<FilterNotifier>(
                builder: (ctx, filters, _) => Container(
                  margin: const EdgeInsets.only(top: 7, bottom: 7),
                  child: CupertinoButton(
                      padding: const EdgeInsets.only(left: 12, right: 12),
                      color: globalColor,
                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                      onPressed: () {
                        setState(() {
                    brandedBuilders.clear();
                    _selectedIndexTownship = 0;
                    _selectedIndexAvailableFlats = 0;
                    _selectedIndexReadyStatus = 0;
                    filters.selectedChoices.clear();
                    controller.selectedIndexes.clear();
                    filters.selectedChoices.add(0);
                    _priceLowChoice = priceLow[0];
                    _priceHighChoice = priceHigh[0];
                    _carpetMinChoice = carpetAreaMin[0];
                    _carpetMaxChoice = carpetAreaMax[0];
                    context
                        .read<FilterNotifier>()
                        .resetAppliedFilter();
                  }); },
                  child: const Text("Clear all",
                      style: TextStyle(color: CupertinoColors.white, fontSize: 12), )),
                ),
                // child:
              ),
            ),
          ],
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(
                      left: 13, right: 13, top: 13),
                  child: Text("Builder"),
                ),
                Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: (MediaQuery.of(context)
                            .platformBrightness ==
                            Brightness.dark)
                            ? Platform.isAndroid ? Colors.black : CupertinoColors.black
                            : Platform.isAndroid ? Colors.white : CupertinoColors.white,
                        borderRadius:
                        const BorderRadius.all(Radius.circular(10))),
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10, top: 5,bottom: 5),
                              child: Consumer<FilterNotifier>(
                                builder: (ctx, filters, _) => FilterChip(
                                  showCheckmark: false,
                                  padding: const EdgeInsets.only(
                                      left: 13, right: 13),
                                  backgroundColor: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                                  selectedColor: globalColor,
                                  disabledColor: Platform.isAndroid ? Colors.blue : CupertinoColors.activeBlue,
                                  label: const Text('Any', style: TextStyle(fontSize: 15),),
                                  selected: filters.isAnySelected,
                                  onSelected: (_) {
                                    setState(() {
                                      filters.isAnySelected = true;
                                      filters.isOthersSelected = false;
                                      brandedBuilders.clear();
                                      filters.selectedIndex.clear();
                                      controller.selectedIndexes.clear();
                                    });
                                  },
                                ),
                                // child:
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10, top: 5,bottom: 5),
                              child: Consumer<FilterNotifier>(
                                  builder: (ctx, filters, _) {
                                    if(filters.isAnySelected){
                                      filters.isOthersSelected = false;
                                    }
                                    return
                                      autocompleteNotifier.originalList.where((element) => element.builder_id == 0).toList().isNotEmpty ? FilterChip(
                                        showCheckmark: false,
                                        padding: const EdgeInsets.only(
                                            left: 13, right: 13),
                                        backgroundColor: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                                        selectedColor: globalColor,
                                        disabledColor: Platform.isAndroid ? Colors.blue : CupertinoColors.activeBlue,
                                        label: const Text(
                                          'Others',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        selected: filters.isOthersSelected,
                                        onSelected: (_) {
                                          setState(() {
                                            filters.toggleOthers();
                                            if (filters.isOthersSelected) {
                                              brandedBuilders =
                                              brandedBuilders..add(0);
                                            } else {
                                              brandedBuilders =
                                              brandedBuilders
                                                ..removeWhere(
                                                        (element) =>
                                                    element == 0);
                                            }
                                          });
                                          if(filters.isOthersSelected || brandedBuilders.where((element) => element!=0).toList().isNotEmpty){
                                            filters.isAnySelected = false;
                                          } else {
                                            filters.isAnySelected = true;
                                          }
                                        },
                                      ) : Container();
                                  }
                                // child:
                              ),
                            ),
                          ],
                        ),
                        autocompleteNotifier.originalList.where((element) => element.builder_id!=0).toList().isNotEmpty ? Consumer<FilterNotifier>(
                          builder: (ctx, filters, _) =>
                              GridView.builder(
                                shrinkWrap: true,
                                itemBuilder: (ctx, i) {
                                  return
                                    MultiSelectItem(
                                      isSelecting: controller.isSelecting,
                                      onSelected: (){
                                        setState(() {
                                          controller.toggle(i);
                                          filters.isAnySelected = false;
                                          if(controller.isSelecting || filters.isOthersSelected){
                                            filters.isAnySelected = false;
                                          } else {
                                            filters.isAnySelected = true;
                                          }
                                          if(controller.isSelected(i)) {
                                            brandedBuilders = brandedBuilders..add(autocompleteNotifier.originalList.distinct((e) => e.builder_id).where((element) => element.builder_id != 0).toList()[i].builder_id);
                                            filters.selectedIndex = controller.selectedIndexes;
                                          } else {
                                            brandedBuilders = brandedBuilders..removeWhere((element) => element == autocompleteNotifier.originalList.distinct((e) => e.builder_id).where((element) => element.builder_id!=0).toList()[i].builder_id);
                                          }
                                        }
                                        );
                                      },
                                      child: FittedBox(
                                        child: Container(
                                          height: 50,
                                          width: 150,
                                          margin: const EdgeInsets.all(10),
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              color: controller.isSelected(i) ? globalColor : Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                                              border: Border.all(width: 1)
                                          ),
                                          // child: Center(
                                          child: Center(
                                            child: Text(
                                              autocompleteNotifier
                                                  .originalList
                                                  .distinct((e) => e.builder_id)
                                                  .where((element) =>
                                              element.builder_id != 0)
                                                  .toList()[i]
                                                  .builder_name,
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              style: TextStyle(
                                                  color: (MediaQuery.of(context)
                                                      .platformBrightness ==
                                                      Brightness.dark) ? Platform.isAndroid ? Colors.white : CupertinoColors.white : Platform.isAndroid ? Colors.black : CupertinoColors.black, fontSize: 15),
                                            ),
                                          ),

                                        ),
                                      ),
                                    );
                                },
                                gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 16/8),
                                itemCount: autocompleteNotifier
                                    .originalList
                                    .distinct((e) => e.builder_id)
                                    .where((e) => e.builder_id != 0)
                                    .toList()
                                    .length,
                              ),
                          // child:
                        ) : Container(),
                      ],
                    )),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 13,
                    right: 13,
                    top: 2,
                  ),
                  child: Divider(
                    color: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? Colors.grey[600] : Platform.isAndroid ? Colors.black : CupertinoColors
                        .black,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    left: 13,
                    right: 13,
                    bottom: 2,
                    top: 2,
                  ),
                  child: Text("Price in Lakhs"),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                      color: (MediaQuery.of(context)
                          .platformBrightness ==
                          Brightness.dark)
                          ? Platform.isAndroid ? Colors.black : CupertinoColors.black
                          : Platform.isAndroid ? Colors.white : CupertinoColors.white,
                      borderRadius:
                      const BorderRadius.all(Radius.circular(10))),
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 13,
                      right: 13,
                      bottom: 5,
                    ),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        if(Platform.isAndroid)
                          DropdownButton<int>(
                            value: _priceLowChoice,
                            items: [
                              ...priceLow.where((e) {
                                if (_priceHighChoice == 0) return true;
                                if (e == 0) return true;
                                return (_priceHighChoice! >= e);
                              }).map((e) {
                                if (e == 0) {
                                  return DropdownMenuItem(
                                    value: e,
                                    child: const Text("No min"),
                                  );
                                }
                                if (_priceHighChoice! == 0) {
                                  return DropdownMenuItem(
                                    value: e,
                                    child: Text(e.toString()),
                                  );
                                }
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text(e.toString()),
                                );
                              })
                            ],
                            onChanged: (value) {
                              setState(() {
                                _priceLowChoice = value;
                              });
                            },
                          ),
                        if(Platform.isIOS)
                        Container(
                          margin: const EdgeInsets.all(10),
                          child: GestureDetector(
                            onTap: () => _showDialog(
                              CupertinoPicker(
                                magnification: 1.22,
                                squeeze: 1.2,
                                useMagnifier: true,
                                itemExtent: 32.0,
                                looping: true,
                                onSelectedItemChanged: (int selectedItem) {
                                  setState(() {
                                    _priceLowChoice = priceLow[selectedItem];
                                  });
                                },
                                children: [
                                  ...priceLow.where((e) {
                                    if (_priceHighChoice == 0) return true;
                                    if (e == 0) return true;
                                    return (_priceHighChoice! >= e);
                                  }).map((e) {
                                    if (e == 0) {
                                      return const Center(
                                        child: Text("No min")
                                      );
                                    }
                                    if (_priceHighChoice! == 0) {
                                      return Center(
                                          child: Text(e.toString())
                                      );
                                    }
                                    return Center(
                                        child: Text(e.toString())
                                    );
                                  })
                                ]
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_priceLowChoice == 0 ? 'No min' : _priceLowChoice.toString(), style: TextStyle(color: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? Platform.isAndroid ? Colors.white : CupertinoColors
                                    .white : Platform.isAndroid ? Colors.black : CupertinoColors
                                    .black, fontSize: 16),),
                                Padding(
                                  padding: const EdgeInsets.only(left: 2.5, right: 2.5),
                                  child: Icon(
                                    Icons.arrow_drop_down,
                                    color: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? Platform.isAndroid ? Colors.white : CupertinoColors
                                        .white : Platform.isAndroid ? Colors.black : CupertinoColors
                                        .black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Text('to'),
                        if(Platform.isAndroid)
                          DropdownButton<int>(
                            value: _priceHighChoice,
                            items: [
                              ...priceHigh.where((e) {
                                if (_priceLowChoice == 0) return true;
                                if (e == 0) return true;

                                return (_priceLowChoice! <= e);
                              }).map((e) {
                                if (e == 0) {
                                  return DropdownMenuItem(
                                    value: e,
                                    child: const Text("No max"),
                                  );
                                }
                                if (_priceLowChoice! == 0) {
                                  return DropdownMenuItem(
                                    value: e,
                                    child: Text(e.toString()),
                                  );
                                }
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text(e.toString()),
                                );
                              })
                            ],
                            onChanged: (value) {
                              setState(() {
                                _priceHighChoice = value;
                              });
                            },
                          ),
                        if(Platform.isIOS)
                        Container(
                          margin: const EdgeInsets.all(10),
                          child: GestureDetector(
                            onTap: () => _showDialog(
                              CupertinoPicker(
                                  magnification: 1.22,
                                  squeeze: 1.2,
                                  useMagnifier: true,
                                  itemExtent: 32.0,
                                  looping: true,
                                  onSelectedItemChanged: (int selectedItem) {
                                    setState(() {
                                      _priceHighChoice = priceHigh[selectedItem];
                                    });
                                  },
                                  children: [
                                    ...priceHigh.where((e) {
                                      if (_priceLowChoice == 0) return true;
                                      if (e == 0) return true;
                                      return (_priceLowChoice! >= e);
                                    }).map((e) {
                                      if (e == 0) {
                                        return const Center(
                                            child: Text("No max")
                                        );
                                      }
                                      if (_priceLowChoice! == 0) {
                                        return Center(
                                            child: Text(e.toString())
                                        );
                                      }
                                      return Center(
                                          child: Text(e.toString())
                                      );
                                    })
                                  ]
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_priceHighChoice == 0 ? 'No max' : _priceHighChoice.toString(), style: TextStyle(color: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? Platform.isAndroid ? Colors.white : CupertinoColors
                                    .white : Platform.isAndroid ? Colors.black : CupertinoColors
                                    .black, fontSize: 16),),
                                Padding(
                                  padding: const EdgeInsets.only(left: 2.5, right: 2.5),
                                  child: Icon(
                                    Icons.arrow_drop_down,
                                    color: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? Platform.isAndroid ? Colors.white : CupertinoColors
                                        .white : Platform.isAndroid ? Colors.black : CupertinoColors
                                        .black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 13,
                    right: 13,
                    bottom: 2,
                  ),
                  child: Divider(
                    color: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? Colors
                        .grey[600] : Platform.isAndroid ? Colors.black : CupertinoColors
                        .black,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    left: 13,
                    right: 13,
                    bottom: 2,
                  ),
                  child: Text("Carpet Area in sq. feet"),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                      color: (MediaQuery.of(context)
                          .platformBrightness ==
                          Brightness.dark)
                          ? Platform.isAndroid ? Colors.black : CupertinoColors.black
                          : Platform.isAndroid ? Colors.white : CupertinoColors.white,
                      borderRadius:
                      const BorderRadius.all(Radius.circular(10))),
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 13,
                      right: 13,
                      bottom: 5,
                    ),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        if(Platform.isAndroid)
                          DropdownButton<int>(
                            value: _carpetMinChoice,
                            items: [
                              ...carpetAreaMin.where((e) {
                                if (_carpetMaxChoice == 0) return true;
                                if (e == 0) return true;
                                return (_carpetMaxChoice! >= e);
                              }).map((e) {
                                if (e == 0) {
                                  return DropdownMenuItem(
                                    value: e,
                                    child: const Text("No min"),
                                  );
                                }
                                if (_carpetMaxChoice! == 0) {
                                  return DropdownMenuItem(
                                    value: e,
                                    child: Text(e.toString()),
                                  );
                                }
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text(e.toString()),
                                );
                              })
                            ],
                            onChanged: (value) {
                              setState(() {
                                _carpetMinChoice = value;
                              });
                            },
                          ),
                        if(Platform.isIOS)
                        Container(
                          margin: const EdgeInsets.all(10),
                          child: GestureDetector(
                            onTap: () => _showDialog(
                              CupertinoPicker(
                                  magnification: 1.22,
                                  squeeze: 1.2,
                                  useMagnifier: true,
                                  itemExtent: 32.0,
                                  looping: true,
                                  onSelectedItemChanged: (int selectedItem) {
                                    setState(() {
                                      _carpetMinChoice = carpetAreaMin[selectedItem];
                                    });
                                  },
                                  children: [
                                    ...carpetAreaMin.where((e) {
                                      if (_carpetMaxChoice == 0) return true;
                                      if (e == 0) return true;
                                      return (_carpetMaxChoice! >= e);
                                    }).map((e) {
                                      if (e == 0) {
                                        return const Center(
                                            child: Text("No min")
                                        );
                                      }
                                      if (_carpetMaxChoice! == 0) {
                                        return Center(
                                            child: Text(e.toString())
                                        );
                                      }
                                      return Center(
                                          child: Text(e.toString())
                                      );
                                    })
                                  ]
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_carpetMinChoice == 0 ? 'No min' : _carpetMinChoice.toString(), style: TextStyle(color: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? Platform.isAndroid ? Colors.white : CupertinoColors
                                    .white : Platform.isAndroid ? Colors.black : CupertinoColors
                                    .black, fontSize: 16),),
                                Padding(
                                  padding: const EdgeInsets.only(left: 2.5, right: 2.5),
                                  child: Icon(
                                    Icons.arrow_drop_down,
                                    color: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? Platform.isAndroid ? Colors.white : CupertinoColors
                                        .white : Platform.isAndroid ? Colors.black : CupertinoColors
                                        .black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Text('to'),
                        if(Platform.isAndroid)
                          DropdownButton<int>(
                            value: _carpetMaxChoice,
                            items: [
                              ...carpetAreaMax.where((e) {
                                if (_carpetMinChoice == 0) return true;
                                if (e == 0) return true;
                                return (_carpetMinChoice! <= e);
                              }).map((e) {
                                if (e == 0) {
                                  return DropdownMenuItem(
                                    value: e,
                                    child: const Text("No max"),
                                  );
                                }
                                if (_carpetMinChoice! == 0) {
                                  return DropdownMenuItem(
                                    value: e,
                                    child: Text(e.toString()),
                                  );
                                }
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text(e.toString()),
                                );
                              })
                            ],
                            onChanged: (value) {
                              setState(() {
                                _carpetMaxChoice = value;
                              });
                            },
                          ),
                        if(Platform.isIOS)
                        Container(
                          margin: const EdgeInsets.all(10),
                          child: GestureDetector(
                            onTap: () => _showDialog(
                              CupertinoPicker(
                                  magnification: 1.22,
                                  squeeze: 1.2,
                                  useMagnifier: true,
                                  itemExtent: 32.0,
                                  looping: true,
                                  onSelectedItemChanged: (int selectedItem) {
                                    setState(() {
                                      _carpetMaxChoice = carpetAreaMax[selectedItem];
                                    });
                                  },
                                  children: [
                                    ...carpetAreaMax.where((e) {
                                      if (_carpetMinChoice == 0) return true;
                                      if (e == 0) return true;
                                      return (_carpetMinChoice! >= e);
                                    }).map((e) {
                                      if (e == 0) {
                                        return const Center(
                                            child: Text("No max")
                                        );
                                      }
                                      if (_carpetMinChoice! == 0) {
                                        return Center(
                                            child: Text(e.toString())
                                        );
                                      }
                                      return Center(
                                          child: Text(e.toString())
                                      );
                                    })
                                  ]
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_carpetMaxChoice == 0 ? 'No max' : _carpetMaxChoice.toString(), style: TextStyle(color: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? Platform.isAndroid ? Colors.white : CupertinoColors
                                    .white : Platform.isAndroid ? Colors.black : CupertinoColors
                                    .black, fontSize: 16),),
                                Padding(
                                  padding: const EdgeInsets.only(left: 2.5, right: 2.5),
                                  child: Icon(
                                    Icons.arrow_drop_down,
                                    color: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? Platform.isAndroid ? Colors.white : CupertinoColors
                                        .white : Platform.isAndroid ? Colors.black : CupertinoColors
                                        .black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 13,
                    right: 13,
                    bottom: 2,
                  ),
                  child: Divider(
                    color: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? Colors
                        .grey[600] : Platform.isAndroid ? Colors.black : CupertinoColors
                        .black,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    left: 13,
                    right: 13,
                    bottom: 2,
                  ),
                  child: Text("Available flats"),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: (MediaQuery.of(context)
                          .platformBrightness ==
                          Brightness.dark)
                          ? Platform.isAndroid ? Colors.black : CupertinoColors.black
                          : Platform.isAndroid ? Colors.white : CupertinoColors.white,
                      borderRadius:
                      const BorderRadius.all(Radius.circular(10))),
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Wrap(children: [
                    ...availableFlats.mapIndexed((i, e) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 13,
                          right: 13,
                        ),
                        child: FilterChip(
                          showCheckmark: false,
                          padding: const EdgeInsets.only(
                              left: 13, right: 13),
                          backgroundColor: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                          selectedColor: globalColor,
                          disabledColor: Platform.isAndroid ? Colors.blue : CupertinoColors.activeBlue,
                          onSelected: (isSelected) {
                            setState(() {
                              if (isSelected) {
                                _selectedIndexAvailableFlats = i;
                              }
                            });
                          },
                          label: Text(e, style: const TextStyle(fontSize: 15),),
                          selected: _selectedIndexAvailableFlats == i,
                        ),
                      );
                    }).toList(),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 13,
                    right: 13,
                    bottom: 2,
                  ),
                  child: Divider(
                    color: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? Colors
                        .grey[600] : Platform.isAndroid ? Colors.black : CupertinoColors
                        .black,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    left: 13,
                    right: 13,
                    bottom: 2,
                  ),
                  child: Text("Ready Status"),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: (MediaQuery.of(context)
                          .platformBrightness ==
                          Brightness.dark)
                          ? Platform.isAndroid ? Colors.black : CupertinoColors.black
                          : Platform.isAndroid ? Colors.white : CupertinoColors.white,
                      borderRadius:
                      const BorderRadius.all(Radius.circular(10))),
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Wrap(children: [
                    ...plannedCompletion.mapIndexed((i, e) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 13,
                          right: 13,
                        ),
                        child: FilterChip(
                          showCheckmark: false,
                          selectedColor: globalColor,
                          padding: const EdgeInsets.only(
                              left: 13, right: 13),
                          backgroundColor: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                          disabledColor: Platform.isAndroid ? Colors.blue : CupertinoColors.activeBlue,
                          onSelected: (isSelected) {
                            setState(() {
                              if (isSelected) {
                                _selectedIndexReadyStatus = i;
                              }
                            });
                          },
                          label: Text(e, style: const TextStyle(fontSize: 15),),
                          selected: _selectedIndexReadyStatus == i,
                        ),
                      );
                    }).toList(),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 13,
                    right: 13,
                    bottom: 7,
                  ),
                  child: Divider(
                    color: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? Colors
                        .grey[600] : Platform.isAndroid ? Colors.black : CupertinoColors
                        .black,
                  ),
                ),
                Consumer<FilterNotifier>(
                  builder: (ctx,filters, _) => Container(
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    width: double.infinity,
                    child: Platform.isAndroid ? Center(
                      child: SizedBox(
                        height: 60,
                        width: double.infinity,
                        child: TextButton(
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.black, backgroundColor: globalColor),
                          onPressed: () async {
                            filters.isShowProjectsClicked = true;
                            context
                                .read<FilterNotifier>()
                                .setAppliedFilter(AppliedFilter(
                                selectedBuilderId: brandedBuilders,
                                bhk: filters.selectedChoices,
                                priceChoice: [
                                  _priceLowChoice!,
                                  _priceHighChoice!
                                ],
                                carpetChoice: [
                                  _carpetMinChoice!,
                                  _carpetMaxChoice!
                                ],
                                selectedIndexAvailableFlats:
                                _selectedIndexAvailableFlats,
                                selectedIndexReadyStatus:
                                _selectedIndexReadyStatus,
                                slectedIndexTownship:
                                _selectedIndexTownship));
                            filters.setFiltersToTrue();
                            autocompleteNotifier.projectList = autocompleteNotifier.originalList;
                            await FirebaseAnalytics.instance.logEvent(
                              name: "select_content",
                              parameters: {
                                "content_type": "apply_filters",
                                "item_id": "",
                              },
                            );
                            if(!mounted) return;
                            AutoRouter.of(context).pop();
                          },
                          child: const Padding(
                            padding:
                            EdgeInsets.only(top: 8, bottom: 8),
                            child: Text("Show Projects",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15)),
                          ),
                        ),
                      ),
                    ) : CupertinoButton(
                      color: globalColor,
                      borderRadius: const BorderRadius.all(Radius.circular(25)),
                      child: const Text("Show Projects",
                          style: TextStyle(
                              color: CupertinoColors.white, fontSize: 15)),
                      onPressed: () async {
                        filters.isShowProjectsClicked = true;
                        context
                            .read<FilterNotifier>()
                            .setAppliedFilter(AppliedFilter(
                            selectedBuilderId: brandedBuilders,
                            bhk: filters.selectedChoices,
                            priceChoice: [
                              _priceLowChoice!,
                              _priceHighChoice!
                            ],
                            carpetChoice: [
                              _carpetMinChoice!,
                              _carpetMaxChoice!
                            ],
                            selectedIndexAvailableFlats:
                            _selectedIndexAvailableFlats,
                            selectedIndexReadyStatus:
                            _selectedIndexReadyStatus,
                            slectedIndexTownship:
                            _selectedIndexTownship));
                        filters.setFiltersToTrue();
                        autocompleteNotifier.projectList = autocompleteNotifier.originalList;
                        await FirebaseAnalytics.instance.logEvent(
                          name: "select_content",
                          parameters: {
                            "content_type": "apply_filters",
                            "item_id": "",
                          },
                        );
                        if(!mounted) return;
                        AutoRouter.of(context).pop();
                      },
                    ),
                  ),
                  // child:
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
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
