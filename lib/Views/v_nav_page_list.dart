import 'dart:io';
import 'package:squarest/Services/s_autocomplete_notifier.dart';
import 'package:squarest/Services/s_connectivity_notifier.dart';
import 'package:squarest/Services/s_resale_property_notifier.dart';
import 'package:squarest/Views/v_all_resale_property_list.dart';
import 'package:squarest/Views/v_applied_filters.dart';
import 'package:squarest/Views/v_horizontal_builder_card.dart';
import 'package:squarest/Views/v_horizontal_list_card.dart';
import 'package:squarest/Views/v_horizontal_property_card.dart';
import 'package:squarest/Views/v_no_internet.dart';
import 'package:squarest/Views/v_project_list.dart';
import 'package:auto_route/auto_route.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../Services/s_filter_notifier.dart';
import '../Services/s_get_current_location.dart';
import '../Services/s_show_search.dart';
import '../Utils/u_constants.dart';
import '../Utils/u_custom_cupertino_sliver_navigation_bar.dart';
import '../Utils/u_custom_styles.dart';
import '../Utils/u_themes.dart';

class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  TextEditingController controller = TextEditingController();
  int currentProjectPage = 1;
  int currentBuilderPage = 1;
  int current3dPage = 1;
  int currentNewLaunchPage = 1;
  int currentTrendingPage = 1;
  int currentWorthALookPage = 1;
  bool isNewLaunchesLoading = false;
  bool is3dFlatsLoading = false;
  bool isTrendingLoading = false;
  bool isTopBuildersLoading = false;
  bool isWorthALookLoading = false;
  int selectedCity = 0;
  String selectedCityAndroid = 'Pune';

  final searchTitle = 'Search Results';
  final newLaunchesTitle = 'New Launches';
  final trendingNowTitle = 'Trending Now';
  final aRFlatsTitle = 'Show Flats in 3D';
  final worthTitle = 'Worth a Look';
  final topBuildersTitle = 'Top Builders';

  @override
  void initState() {
    super.initState();
    final autocompleteNotifier =
        Provider.of<AutocompleteNotifier>(context, listen: false);
    final resaleNotifier =
    Provider.of<ResalePropertyNotifier>(context, listen: false);
    setState(() {
      isTopBuildersLoading = true;
    });
    setState(() {
      is3dFlatsLoading = true;
    });
    setState(() {
      isNewLaunchesLoading = true;
    });
    setState(() {
      isTrendingLoading = true;
    });
    setState(() {
      isWorthALookLoading = true;
    });
    resaleNotifier.getAllResaleProperties(context, this);
    autocompleteNotifier.getTopBuilders(context, this).whenComplete(() {
      setState(() {
        isTopBuildersLoading = false;
      });
    });
    autocompleteNotifier.get3dBuilders(context, this).whenComplete(() {
      setState(() {
        is3dFlatsLoading = false;
      });
    });
    autocompleteNotifier.getNewLaunches(context, this).whenComplete(() {
      setState(() {
        isNewLaunchesLoading = false;
      });
    });
    autocompleteNotifier.getTrending(context, this).whenComplete(() {
      setState(() {
        isTrendingLoading = false;
      });
    });
    autocompleteNotifier.getWorthALook(context, this).whenComplete(() {
      setState(() {
        isWorthALookLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final autocompleteNotifier = Provider.of<AutocompleteNotifier>(context);
    final resaleNotifier =
    Provider.of<ResalePropertyNotifier>(context);
    final con = context.watch<ConnectivityChangeNotifier>();
    controller.text = autocompleteNotifier.status
        ? autocompleteNotifier.selectedNewHint
        : autocompleteNotifier.selectedResaleHint;
    return (con.connectivity == null)
        ? Center(child: Platform.isAndroid ? const CircularProgressIndicator() : const CupertinoActivityIndicator())
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
              automaticallyImplyLeading: false,
              floating: true,
              expandedHeight: 70,
              // forceElevated: true,
              collapsedHeight: 70,
              backgroundColor:
              (MediaQuery.of(context).platformBrightness == Brightness.dark)
                  ? Colors.grey[900]
                  : Colors.white,
              flexibleSpace: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 40,
                      margin: const EdgeInsets.only(left: 5),
                      decoration: const BoxDecoration(
                          color: globalColor,
                          borderRadius:
                          BorderRadius.all(
                              Radius.circular(25))),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<bool>(
                          value: autocompleteNotifier.status,
                          alignment: Alignment.center,
                          // style: const TextStyle(
                          //   color: globalColor,
                          // ),
                          icon: const SizedBox(),
                          selectedItemBuilder:
                              (BuildContext context) {
                            return autocompleteNotifier.dropDownItems
                                .map((items) {
                              return Padding(
                                  padding: EdgeInsets.only(left: autocompleteNotifier.status ? 0 : 5),
                                  child: Center(child: Row(children: [
                                    Text(items ? '   New' : 'Resale', style: const TextStyle(color: Colors.white)),
                                    const Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors
                                          .white, // <-- SEE HERE
                                    ),
                                  ])));
                            }).toList();
                          },
                          items:
                          autocompleteNotifier.dropDownItems.map((bool items) {
                            return DropdownMenuItem(
                              value: items,
                              child: Text(items ? 'New' : 'Resale'),
                            );
                          }).toList(),

                          onChanged: (value) async {
                            // setState(() {
                            //   newValue = value!;
                            // });
                            // autocompleteNotifier.status = value!;
                            autocompleteNotifier.toggleStatus(value!);
                            autocompleteNotifier.isSearching = true;
                            if(autocompleteNotifier.status) {
                              await autocompleteNotifier.getProjectsForBounds(context, this);
                              // manager.setItems(
                              //     autocompleteNotifier
                              //         .projectList);
                            } else {
                              await autocompleteNotifier.getProjectsForBounds(context, this);
                              // resaleManager.setItems(autocompleteNotifier.resaleProjectList);
                            }
                          },
                        ),
                      ),
                    ),
                    // Container(
                    //   margin: const EdgeInsets.only(left: 5),
                    //   child: AnimatedToggleSwitch<bool>.dual(
                    //     loading: false,
                    //     current: autocompleteNotifier.status,
                    //     first: true,
                    //     second: false,
                    //     dif: -7,
                    //     borderColor: (MediaQuery.of(context).platformBrightness ==
                    //         Brightness.dark)
                    //         ? Colors.grey : Colors.black,
                    //     borderWidth: 1,
                    //     height: 47,
                    //     onChanged: (val) async {
                    //       autocompleteNotifier.status = val;
                    //       autocompleteNotifier.isSearching = true;
                    //       if(autocompleteNotifier.status) {
                    //         await autocompleteNotifier.getProjectsForBounds(context, this);
                    //         // manager.setItems(
                    //         //     autocompleteNotifier
                    //         //         .projectList);
                    //       } else {
                    //         await autocompleteNotifier.getProjectsForBounds(context, this);
                    //         // resaleManager.setItems(autocompleteNotifier.resaleProjectList);
                    //       }
                    //     },
                    //     colorBuilder: (b) => Colors.green,
                    //     iconBuilder: (value) => value
                    //         ? const Text('New', style: TextStyle(fontSize: 11, color: Colors.white),)
                    //         : Column(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         children: const [
                    //           Center(child: Text('Re-', style: TextStyle(fontSize: 11, color: Colors.white))),
                    //           Center(child: Text('sale', style: TextStyle(fontSize: 11, color: Colors.white)))]),
                    //     textBuilder: (value) => value
                    //         ? Column(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         children: const [
                    //           Center(child: Text('Re-', style: TextStyle(fontSize: 11,))),
                    //           Center(child: Text('sale', style: TextStyle(fontSize: 11,)))])
                    //         : const Text('New', style: TextStyle(fontSize: 11,)),
                    //   ),
                    // ),
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.only(left: 3, right: 3),
                        decoration: BoxDecoration(
                          color: (MediaQuery.of(context)
                              .platformBrightness ==
                              Brightness.dark)
                              ? const Color(0xFFF6F6F8)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        child: TextField(
                          autofocus: false,
                          readOnly: true,
                          showCursor: true,
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            showSearch(
                                context: context,
                                delegate: SearchPlaceDelegate(this, true));
                          },
                          controller: controller,
                          onChanged: (value) {},
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            fillColor: (MediaQuery.of(context)
                                .platformBrightness ==
                                Brightness.dark)
                                ? Colors.grey[900]
                                : Colors.white,
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(25.0),
                              borderSide: BorderSide(
                                  color: (MediaQuery.of(context).platformBrightness ==
                                      Brightness.dark)
                                      ? Colors.grey : Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(25.0),
                                borderSide: BorderSide(
                                    color: (MediaQuery.of(context).platformBrightness ==
                                        Brightness.dark)
                                        ? Colors.grey : Colors.black)),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: globalColor,
                            ),
                            suffixIcon: InkWell(
                              onTap: () async {
                                controller.text =
                                "Showing Projects near you.";
                                GetGeoLocation().goToCurrentLocation(
                                    autocompleteNotifier.controller,
                                    context);
                                await FirebaseAnalytics.instance
                                    .logEvent(
                                  name: "select_content",
                                  parameters: {
                                    "content_type": "lat:lng",
                                    "item_id": autocompleteNotifier
                                        .projectList.isNotEmpty
                                        ? '${autocompleteNotifier.projectList[0].lat} : ${autocompleteNotifier.projectList[0].lng}'
                                        : '',
                                  },
                                );
                              },
                              child: Icon(Icons.my_location,
                                  color: (MediaQuery.of(context)
                                      .platformBrightness ==
                                      Brightness.dark)
                                      ? Colors.white
                                      : Colors.black),
                            ),
                            hintStyle:
                            const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    if(autocompleteNotifier.status)
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.tune_outlined,
                                size: 30.0),
                            onPressed: () async {
                              AutoRouter.of(context).pushNamed('/filters');
                              FocusScope.of(context).unfocus();
                              await FirebaseAnalytics.instance.logEvent(
                                name: "select_content",
                                parameters: {
                                  "content_type": "filters",
                                  "item_id": "",
                                },
                              );
                            },
                            tooltip: "Filters",
                          ),
                          Text(
                            "Filters",
                            style: TextStyles.callOut1,
                          )
                        ],
                      )
                  ],
                ),
              ),
            ),
            if(Platform.isIOS)
              CustomCupertinoSliverNavigationBar(
                backgroundColor: (MediaQuery.of(context).platformBrightness ==
                    Brightness.dark)
                    ? Colors.grey[900]
                    : CupertinoColors.white,
                padding: const EdgeInsetsDirectional.only(bottom: 5),
                leading: Container(
                  margin: const EdgeInsets.only(left: 5, top: 10, bottom: 10),
                  decoration: const BoxDecoration(
                      color: globalColor,
                      borderRadius:
                      BorderRadius.all(
                          Radius.circular(
                              25))),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: GestureDetector(
                      onTap: () => _showDialog(
                        CupertinoPicker(
                            magnification: 1.22,
                            squeeze: 1.2,
                            useMagnifier: true,
                            itemExtent: 32.0,
                            looping: true,
                            onSelectedItemChanged:
                                (int selectedItem) async {
                              autocompleteNotifier.toggleStatus(autocompleteNotifier.dropDownItems[
                              selectedItem]);
                              autocompleteNotifier.isSearching = true;
                              if(autocompleteNotifier.status) {
                                await autocompleteNotifier.getProjectsForBounds(context, this);
                                // manager.setItems(
                                //     autocompleteNotifier
                                //         .projectList);
                              } else {
                                await autocompleteNotifier.getProjectsForBounds(context, this);
                                // resaleManager.setItems(autocompleteNotifier.resaleProjectList);
                              }
                            },
                            children:
                            List<Widget>.generate(autocompleteNotifier.dropDownItems.length, (index) {
                              return Text(
                                autocompleteNotifier.dropDownItems[index] ? 'New' : 'Resale',
                              );
                            })
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Text(autocompleteNotifier.status ? 'New' : 'Resale', style: const TextStyle(color: CupertinoColors.white, fontSize: 16),)),
                          const Padding(
                            padding: EdgeInsets.only(left: 2.5, right: 2.5),
                            child: Icon(
                              CupertinoIcons.arrowtriangle_down_circle_fill,
                              color: CupertinoColors
                                  .white,
                              size: 25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                largeTitle: Container(
                  height: 50,
                  margin: const EdgeInsets.only(right: 5),
                  decoration: BoxDecoration(
                    color: (MediaQuery.of(context).platformBrightness ==
                        Brightness.dark)
                        ? const Color(0xFFF6F6F8)
                        : CupertinoColors.white,
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: CupertinoTextField(
                    suffix: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: InkWell(
                        onTap: () async {
                          controller.text = "Showing Projects near you.";
                          GetGeoLocation().goToCurrentLocation(
                              autocompleteNotifier.controller, context);
                          await FirebaseAnalytics.instance.logEvent(
                            name: "select_content",
                            parameters: {
                              "content_type": "lat:lng",
                              "item_id": autocompleteNotifier
                                  .projectList.isNotEmpty
                                  ? '${autocompleteNotifier.projectList[0].lat} : ${autocompleteNotifier.projectList[0].lng}'
                                  : '',
                            },
                          );
                        },
                        child: Icon(CupertinoIcons.location,
                            color: (MediaQuery.of(context).platformBrightness ==
                                Brightness.dark)
                                ? CupertinoColors.white
                                : CupertinoColors.black),
                      ),
                    ),
                    prefix: const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Icon(
                          CupertinoIcons.search,
                          color: CupertinoColors.activeBlue,
                        )),
                    style: TextStyle(
                        color: (MediaQuery.of(context).platformBrightness ==
                            Brightness.dark)
                            ? CupertinoColors.white
                            : CupertinoColors.black),
                    decoration: BoxDecoration(
                      color: (MediaQuery.of(context).platformBrightness ==
                          Brightness.dark)
                          ? Colors.grey[900]
                          : CupertinoColors.white,
                      borderRadius: BorderRadius.circular(25.0),
                      border: Border.all(
                          width: 1,
                          color: (MediaQuery.of(context).platformBrightness ==
                              Brightness.dark)
                              ? CupertinoColors.systemGrey
                              : CupertinoColors.black),
                    ),
                    autofocus: false,
                    readOnly: true,
                    showCursor: true,
                    onTap: () {
                      showSearch(
                          context: context, delegate: SearchPlaceDelegate(this, true));
                    },
                    controller: controller,
                    onChanged: (value) {},
                  ),
                ),
                trailing: autocompleteNotifier.status
                    ? Column(
                  children: [
                    IconButton(
                        padding: EdgeInsets.zero,

                      icon: const Icon(CupertinoIcons.slider_horizontal_3, size: 25.0),
                      onPressed: () async {
                        AutoRouter.of(context).pushNamed('/filters');
                        FocusScope.of(context).unfocus();
                        await FirebaseAnalytics.instance.logEvent(
                          name: "select_content",
                          parameters: {
                            "content_type": "filters",
                            "item_id": "",
                          },
                        );
                      },
                    ),
                    Text(
                      "Filters",
                      style: TextStyle(color: (MediaQuery.of(context).platformBrightness ==
                          Brightness.dark)
                          ? CupertinoColors.white
                          : CupertinoColors.black, fontWeight: FontWeight.bold,
                          fontSize: FontSizes.s12
                      ),
                    )
                  ],
                )
                    : null,
              ),
          ],
          body: WillPopScope(
                      onWillPop: autocompleteNotifier.onWillPop,
                      child: SingleChildScrollView(
                        child: Consumer<FilterNotifier>(
                          builder: (ctx, filters, _) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              filters.isFilterApplied
                                  ? const AppliedFilters()
                                  : const SizedBox(),
                              if (filters.isFilterApplied)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 13,
                                    right: 13,
                                    top: 2,
                                  ),
                                  child: Divider(
                                    color: Colors.grey[500]!,
                                  ),
                                ),
                              const SizedBox(height: 30),
                              Container(
                                    height: 40,
                                    margin: const EdgeInsets.only(
                                        left: 8, right: 8),
                                    child: Row(
                                        children: [
                                          Text(
                                            'Showing in',
                                            style: CustomTextStyles.getTitle(
                                                null,
                                                (MediaQuery.of(context)
                                                    .platformBrightness ==
                                                    Brightness.dark)
                                                    ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                                    : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                                null,
                                                19),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          if(Platform.isAndroid)
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
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
                                        ],),),
                              if (!autocompleteNotifier.status)
                              Column(
                                children: [
                                  const SizedBox(height: 30),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'All Resale Properties',
                                          style: CustomTextStyles.getTitle(
                                              null,
                                              (MediaQuery.of(context)
                                                  .platformBrightness ==
                                                  Brightness.dark)
                                                  ? CupertinoColors.white
                                                  : CupertinoColors.black,
                                              null,
                                              19),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (ctx) =>
                                                     const AllResalePropertyList(appBarTitle: "All Resale Properties",)),
                                            ).then((value) {
                                              autocompleteNotifier
                                                  .closeResaleBottomSheet();
                                            });
                                          },
                                          child: Text('View all',
                                              style: CustomTextStyles.getTitle(
                                                  null,
                                                  (MediaQuery.of(context)
                                                      .platformBrightness ==
                                                      Brightness.dark)
                                                      ? CupertinoColors.white
                                                      : CupertinoColors.black,
                                                  TextDecoration.underline,
                                                  14)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  SizedBox(
                                    height: 270,
                                    child: resaleNotifier
                                        .isLoading ? const NavListShimmer() : resaleNotifier
                                        .allPropertyItems.where((element) => element.status == 2).toList().isEmpty
                                        ? const Center(
                                      child: Text(
                                        'No results currently.',
                                        maxLines: 2,
                                      ),
                                    )
                                        : PageView.builder(
                                      // itemCount:
                                      //     autocompleteNotifier.projectList.length,
                                        controller: PageController(
                                          // initialPage: initialPage,
                                            viewportFraction: 1 / 2),
                                        padEnds: false,
                                        onPageChanged: (page) {
                                          setState(() {
                                              currentProjectPage = (page %
                                                  resaleNotifier
                                                      .allPropertyItems.where((element) => element.status == 2).toList()
                                                      .length) +
                                                  1;
                                          });
                                        },
                                        itemBuilder: (ctx, i) {
                                          // final index = itemCount - (initialPage - i - 1) % itemCount - 1;
                                          return GestureDetector(
                                            onTap: () async {
                                              FocusScope.of(context)
                                                  .unfocus();
                                                autocompleteNotifier
                                                    .propertyForBottomSheet =
                                                    resaleNotifier
                                                        .allPropertyItems.where((element) => element.status == 2).toList()[
                                                i %
                                                    resaleNotifier
                                                        .allPropertyItems.where((element) => element.status == 2).toList()
                                                        .length];
                                                autocompleteNotifier
                                                    .openResaleBottomSheet(
                                                    context, true);

                                            },
                                            child: Container(
                                              padding:
                                              const EdgeInsets.only(
                                                  left: 3.5),
                                              child: HorizontalPropertyCard(
                                                  resalePropertyModel:
                                                  resaleNotifier
                                                      .allPropertyItems.where((element) => element.status == 2).toList()[
                                                  i %
                                                      resaleNotifier
                                                          .allPropertyItems.where((element) => element.status == 2).toList()
                                                          .length]),
                                            ),
                                          );
                                        }),
                                  ),
                                  const SizedBox(height: 10),
                                  if (resaleNotifier
                                      .allPropertyItems.where((element) => element.status == 2).toList().isNotEmpty)
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  if (resaleNotifier
                                      .allPropertyItems.where((element) => element.status == 2).toList().isNotEmpty)
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
                                              ? CupertinoColors.systemGrey
                                              : CupertinoColors.darkBackgroundGray,
                                          borderRadius:
                                          BorderRadius.circular(30.0),
                                        ),
                                        child: Text(
                                          '$currentProjectPage/${resaleNotifier
                                              .allPropertyItems.where((element) => element.status == 2).toList().length}',
                                          style: const TextStyle(
                                              color: CupertinoColors.white),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 30),
                                ],
                              ),
                              if (autocompleteNotifier.status)
                                Column(
                                  children: [

                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      color: const Color(0xFF004D40),
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 30,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10, right: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Text(
                                                  newLaunchesTitle,
                                                  style:
                                                  CustomTextStyles.getTitle(
                                                      null,
                                                      Platform.isAndroid ? Colors.white : CupertinoColors.white,
                                                      null,
                                                      19),
                                                ),
                                                // if(autocompleteNotifier.projectList.isNotEmpty)
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (ctx) =>
                                                              ProjectList(
                                                                isComingFromWorthALook:
                                                                false,
                                                                isComingFromBuilders:
                                                                false,
                                                                builderId: null,
                                                                isComingFrom3d:
                                                                false,
                                                                appBarTitle:
                                                                newLaunchesTitle,
                                                                isComingFromTrending:
                                                                false,
                                                                isComingFromNewLaunches:
                                                                true,
                                                              )),
                                                    ).then((value) {
                                                      autocompleteNotifier
                                                          .closeBottomSheet();
                                                    });
                                                  },
                                                  child: Text('View all',
                                                      style: CustomTextStyles
                                                          .getTitle(
                                                          null,
                                                          Platform.isAndroid ? Colors.white : CupertinoColors.white,
                                                          TextDecoration
                                                              .underline,
                                                          14)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Container(
                                            color: const Color(0xFF004D40),
                                            height: 270,
                                            child: isNewLaunchesLoading
                                                ? const NavListShimmer()
                                                : autocompleteNotifier
                                                .newLaunchesLists
                                                .isEmpty
                                                ? Center(
                                                child: Text(
                                                    'No new launches.', style: TextStyle(color: Platform.isAndroid ? Colors.white : CupertinoColors.white),))
                                                : PageView.builder(
                                                controller:
                                                PageController(
                                                  // initialPage: initialPage,
                                                    viewportFraction:
                                                    1 / 2),
                                                padEnds: false,
                                                onPageChanged: (page) {
                                                  setState(() {
                                                    currentNewLaunchPage = (page %
                                                        autocompleteNotifier
                                                            .newLaunchesLists
                                                            .length) +
                                                        1;
                                                  });
                                                },
                                                // shrinkWrap: true,
                                                itemBuilder: (ctx, i) {
                                                  return GestureDetector(
                                                    onTap: () async {
                                                      FocusScope.of(
                                                          context)
                                                          .unfocus();
                                                      autocompleteNotifier
                                                          .projectForBottomSheet = autocompleteNotifier
                                                          .newLaunchesLists[
                                                      i %
                                                          autocompleteNotifier
                                                              .newLaunchesLists
                                                              .length];
                                                      autocompleteNotifier
                                                          .openBottomSheet(
                                                          context);
                                                    },
                                                    child: Container(
                                                      padding:
                                                      const EdgeInsets
                                                          .only(
                                                          left:
                                                          3.5),
                                                      child: HorizontalListCard(
                                                          project: autocompleteNotifier.newLaunchesLists[i %
                                                              autocompleteNotifier
                                                                  .newLaunchesLists
                                                                  .length]),
                                                    ),
                                                  );
                                                }),
                                          ),
                                          if (autocompleteNotifier
                                              .newLaunchesLists.isNotEmpty)
                                            const SizedBox(
                                              height: 10,
                                            ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          if (autocompleteNotifier
                                              .newLaunchesLists.isNotEmpty)
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
                                                      ? Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey
                                                      : Platform.isAndroid ? Colors.black54 : CupertinoColors.darkBackgroundGray,
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      30.0),
                                                ),
                                                child: Text(
                                                  '$currentNewLaunchPage/${autocompleteNotifier.newLaunchesLists.length}',
                                                  style: TextStyle(
                                                      color: Platform.isAndroid ? Colors.white : CupertinoColors.white),
                                                ),
                                              ),
                                            ),
                                          const SizedBox(
                                            height: 30,
                                          )
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        const SizedBox(
                                          height: 30,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                trendingNowTitle,
                                                style: CustomTextStyles.getTitle(
                                                    null,
                                                    (MediaQuery.of(context)
                                                        .platformBrightness ==
                                                        Brightness.dark)
                                                        ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                                        : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                                    null,
                                                    19),
                                              ),
                                              // if(autocompleteNotifier.projectList.isNotEmpty)
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (ctx) =>
                                                            ProjectList(
                                                              isComingFromWorthALook:
                                                              false,
                                                              appBarTitle:
                                                              trendingNowTitle,
                                                              builderId: null,
                                                              isComingFrom3d:
                                                              false,
                                                              isComingFromBuilders:
                                                              false,
                                                              isComingFromNewLaunches:
                                                              false,
                                                              isComingFromTrending:
                                                              true,

                                                            )),
                                                  ).then((value) {
                                                    autocompleteNotifier
                                                        .closeBottomSheet();
                                                  });
                                                },
                                                child: Text(
                                                  'View all',
                                                  style: CustomTextStyles.getTitle(
                                                      null,
                                                      (MediaQuery.of(context)
                                                          .platformBrightness ==
                                                          Brightness.dark)
                                                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                                          : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                                      TextDecoration.underline,
                                                      14),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        SizedBox(
                                          height: 270,
                                          child: isTrendingLoading
                                              ? const NavListShimmer()
                                              : autocompleteNotifier
                                              .trendingLists.isEmpty
                                              ? const Center(
                                              child: Text(
                                                  'No trending projects.'))
                                              : PageView.builder(
                                              controller: PageController(
                                                // initialPage: initialPage,
                                                  viewportFraction: 1 / 2),
                                              padEnds: false,
                                              onPageChanged: (page) {
                                                setState(() {
                                                  currentTrendingPage = (page %
                                                      autocompleteNotifier
                                                          .trendingLists
                                                          .length) +
                                                      1;
                                                });
                                              },
                                              itemBuilder: (ctx, i) {
                                                return GestureDetector(
                                                  onTap: () async {
                                                    FocusScope.of(
                                                        context)
                                                        .unfocus();
                                                    autocompleteNotifier
                                                        .projectForBottomSheet = autocompleteNotifier
                                                        .trendingLists[
                                                    i %
                                                        autocompleteNotifier
                                                            .trendingLists
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
                                                    child: HorizontalListCard(
                                                        project: autocompleteNotifier.trendingLists[i %
                                                            autocompleteNotifier
                                                                .trendingLists
                                                                .length]),
                                                  ),
                                                );
                                              }),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        if (autocompleteNotifier
                                            .trendingLists.isNotEmpty)
                                          const SizedBox(
                                            height: 10,
                                          ),
                                        if (autocompleteNotifier
                                            .trendingLists.isNotEmpty)
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
                                                    ? Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey
                                                    : Platform.isAndroid ? Colors.black54 : CupertinoColors.darkBackgroundGray,
                                                borderRadius:
                                                BorderRadius.circular(30.0),
                                              ),
                                              child: Text(
                                                '$currentTrendingPage/${autocompleteNotifier.trendingLists.length}',
                                                style: TextStyle(
                                                    color: Platform.isAndroid ? Colors.white : CupertinoColors.white),
                                              ),
                                            ),
                                          ),
                                        const SizedBox(
                                          height: 30,
                                        ),
                                      ],
                                    ),
                                    Container(
                                      color: const Color(0XFF7B1FA2),
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 30,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10, right: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Text(
                                                  aRFlatsTitle,
                                                  style:
                                                  CustomTextStyles.getTitle(
                                                      null,
                                                      Platform.isAndroid ? Colors.white : CupertinoColors.white,
                                                      null,
                                                      19),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (ctx) =>
                                                              ProjectList(
                                                                isComingFromWorthALook:
                                                                false,
                                                                isComingFromBuilders:
                                                                false,
                                                                builderId: null,
                                                                isComingFrom3d:
                                                                true,
                                                                appBarTitle:
                                                                aRFlatsTitle,
                                                                isComingFromTrending:
                                                                false,
                                                                isComingFromNewLaunches:
                                                                false,

                                                              )),
                                                    ).then((value) {
                                                      autocompleteNotifier
                                                          .closeBottomSheet();
                                                    });
                                                  },
                                                  child: Text(
                                                    'View all',
                                                    style: CustomTextStyles
                                                        .getTitle(
                                                        null,
                                                        Platform.isAndroid ? Colors.white : CupertinoColors.white,
                                                        TextDecoration
                                                            .underline,
                                                        14),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Container(
                                            color: const Color(0XFF7B1FA2),
                                            height: 270,
                                            child: is3dFlatsLoading
                                                ? const NavListShimmer()
                                                : autocompleteNotifier
                                                .aRprojectLists.isEmpty
                                                ? Center(
                                                child: Text(
                                                    'No flats in 3D.', style: TextStyle(color: Platform.isAndroid ? Colors.white : CupertinoColors.white),))
                                                : PageView.builder(
                                              // itemCount:
                                              // autocompleteNotifier.aRprojectLists.length,
                                                scrollDirection:
                                                Axis.horizontal,
                                                controller:
                                                PageController(
                                                  // initialPage: initialPage,
                                                    viewportFraction:
                                                    1 / 2),
                                                padEnds: false,
                                                onPageChanged: (page) {
                                                  setState(() {
                                                    current3dPage = (page %
                                                        autocompleteNotifier
                                                            .aRprojectLists
                                                            .length) +
                                                        1;
                                                  });
                                                },
                                                itemBuilder: (ctx, i) {
                                                  return GestureDetector(
                                                    onTap: () async {
                                                      FocusScope.of(
                                                          context)
                                                          .unfocus();
                                                      autocompleteNotifier
                                                          .projectForBottomSheet = autocompleteNotifier
                                                          .aRprojectLists[
                                                      i %
                                                          autocompleteNotifier
                                                              .aRprojectLists
                                                              .length];
                                                      autocompleteNotifier
                                                          .openBottomSheet(
                                                          context);
                                                    },
                                                    child: Container(
                                                      padding:
                                                      const EdgeInsets
                                                          .only(
                                                          left:
                                                          3.5),
                                                      child: HorizontalListCard(
                                                          project: autocompleteNotifier.aRprojectLists[i %
                                                              autocompleteNotifier
                                                                  .aRprojectLists
                                                                  .length]),
                                                    ),
                                                  );
                                                  // return HorizontalListCard(project: autocompleteNotifier.aRprojectLists[i % autocompleteNotifier.aRprojectLists.length]);
                                                }),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          if (autocompleteNotifier
                                              .aRprojectLists.isNotEmpty)
                                            const SizedBox(
                                              height: 10,
                                            ),
                                          if (autocompleteNotifier
                                              .aRprojectLists.isNotEmpty)
                                            Center(
                                              child: Container(
                                                padding: const EdgeInsets.only(
                                                    left: 5, right: 5),
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  color: (MediaQuery.of(context)
                                                      .platformBrightness ==
                                                      Brightness.dark)
                                                      ? Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey
                                                      : Platform.isAndroid ? Colors.black54 : CupertinoColors.darkBackgroundGray,
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      30.0),
                                                ),
                                                child: Text(
                                                  '$current3dPage/${autocompleteNotifier.aRprojectLists.length}',
                                                  style: TextStyle(
                                                      color: Platform.isAndroid ? Colors.white : CupertinoColors.white),
                                                ),
                                              ),
                                            ),
                                          const SizedBox(
                                            height: 30,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        const SizedBox(
                                          height: 30,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                worthTitle,
                                                style: CustomTextStyles.getTitle(
                                                    null,
                                                    (MediaQuery.of(context)
                                                        .platformBrightness ==
                                                        Brightness.dark)
                                                        ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                                        : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                                    null,
                                                    19),
                                              ),
                                              // if(autocompleteNotifier.projectList.isNotEmpty)
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (ctx) =>
                                                            ProjectList(
                                                              isComingFromWorthALook:
                                                              true,
                                                              isComingFromTrending:
                                                              false,
                                                              isComingFromNewLaunches:
                                                              false,
                                                              isComingFrom3d:
                                                              false,
                                                              isComingFromBuilders:
                                                              false,
                                                              builderId: null,
                                                              appBarTitle:
                                                              worthTitle,

                                                            )),
                                                  ).then((value) {
                                                    autocompleteNotifier
                                                        .closeBottomSheet();
                                                  });
                                                },
                                                child: Text(
                                                  'View all',
                                                  style: CustomTextStyles.getTitle(
                                                      null,
                                                      (MediaQuery.of(context)
                                                          .platformBrightness ==
                                                          Brightness.dark)
                                                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                                          : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                                      TextDecoration.underline,
                                                      14),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        SizedBox(
                                          height: 270,
                                          child: isWorthALookLoading
                                              ? const NavListShimmer()
                                              : autocompleteNotifier
                                              .worthALookLists.isEmpty
                                              ? const Center(
                                            child: Text(
                                              'Coming soon. Stay tuned...',
                                              maxLines: 2,
                                            ),
                                          )
                                              : PageView.builder(
                                              scrollDirection:
                                              Axis.horizontal,
                                              controller:
                                              PageController(
                                                // initialPage: initialPage,
                                                  viewportFraction:
                                                  1 / 2.3),
                                              padEnds: false,
                                              onPageChanged: (page) {
                                                setState(() {
                                                  currentWorthALookPage = (page %
                                                      autocompleteNotifier
                                                          .worthALookLists
                                                          .length) +
                                                      1;
                                                });
                                              },
                                              itemBuilder: (ctx, i) {
                                                return GestureDetector(
                                                  onTap: () async {
                                                    FocusScope.of(
                                                        context)
                                                        .unfocus();
                                                    autocompleteNotifier
                                                        .projectForBottomSheet = autocompleteNotifier
                                                        .worthALookLists[
                                                    i %
                                                        autocompleteNotifier
                                                            .worthALookLists
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
                                                    child: HorizontalListCard(
                                                        project: autocompleteNotifier.worthALookLists[i %
                                                            autocompleteNotifier
                                                                .worthALookLists
                                                                .length]),
                                                  ),
                                                );
                                              }),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        if (autocompleteNotifier
                                            .worthALookLists.isNotEmpty)
                                          const SizedBox(
                                            height: 10,
                                          ),
                                        if (autocompleteNotifier
                                            .worthALookLists.isNotEmpty)
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
                                                    ? Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey
                                                    : Platform.isAndroid ? Colors.black54 : CupertinoColors.darkBackgroundGray,
                                                borderRadius:
                                                BorderRadius.circular(30.0),
                                              ),
                                              child: Text(
                                                '$currentWorthALookPage/${autocompleteNotifier.worthALookLists.length}',
                                                style: TextStyle(
                                                    color: Platform.isAndroid ? Colors.white : CupertinoColors.white),
                                              ),
                                            ),
                                          ),
                                        const SizedBox(
                                          height: 30,
                                        ),
                                      ],
                                    ),
                                    Container(
                                      color: const Color(0xFF900C3F),
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 30,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10, right: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Text(topBuildersTitle,
                                                    style: CustomTextStyles
                                                        .getTitle(
                                                        null,
                                                        Platform.isAndroid ? Colors.white : CupertinoColors.white,
                                                        null,
                                                        19)),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Container(
                                            color: const Color(0xFF900C3F),
                                            height: 180,
                                            child: isTopBuildersLoading
                                                ? const TopBuilderListShimmer()
                                                : autocompleteNotifier
                                                .topBuildersList.isEmpty
                                                ? Center(
                                                child: Text(
                                                    'No top builders', style: TextStyle(color: Platform.isAndroid ? Colors.white : CupertinoColors.white),))
                                                : PageView.builder(
                                              // itemCount:
                                              // autocompleteNotifier.topBuildersList.length,
                                                scrollDirection:
                                                Axis.horizontal,
                                                controller:
                                                PageController(
                                                  // initialPage: initialPage,
                                                    viewportFraction:
                                                    1 / 2.3),
                                                padEnds: false,
                                                onPageChanged: (page) {
                                                  setState(() {
                                                    currentBuilderPage = (page %
                                                        autocompleteNotifier
                                                            .topBuildersList
                                                            .length) +
                                                        1;
                                                  });
                                                },
                                                itemBuilder: (ctx, i) {
                                                  return GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (ctx) =>
                                                                  ProjectList(
                                                                    isComingFromWorthALook: false,
                                                                    isComingFromBuilders: true,
                                                                    builderId: autocompleteNotifier.topBuildersList[i % autocompleteNotifier.topBuildersList.length].builder_id,
                                                                    isComingFrom3d: false,
                                                                    appBarTitle: autocompleteNotifier.topBuildersList[i % autocompleteNotifier.topBuildersList.length].builder_name,
                                                                    isComingFromNewLaunches: false,
                                                                    isComingFromTrending: false,

                                                                  )),
                                                        );
                                                      },
                                                      child:
                                                      HorizontalBuilderCard(
                                                        topBuilders: autocompleteNotifier.topBuildersList[i %
                                                            autocompleteNotifier
                                                                .topBuildersList
                                                                .length],
                                                      ));
                                                }),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          if (autocompleteNotifier
                                              .topBuildersList.isNotEmpty)
                                            const SizedBox(
                                              height: 10,
                                            ),
                                          if (autocompleteNotifier
                                              .topBuildersList.isNotEmpty)
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
                                                      ? Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey
                                                      : Platform.isAndroid ? Colors.black54 : CupertinoColors.darkBackgroundGray,
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      30.0),
                                                ),
                                                child: Text(
                                                  '$currentBuilderPage/${autocompleteNotifier.topBuildersList.length}',
                                                  style: TextStyle(
                                                      color: Platform.isAndroid ? Colors.white : CupertinoColors.white),
                                                ),
                                              ),
                                            ),
                                          const SizedBox(
                                            height: 30,
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                            ],
                          ),
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

class NavListShimmer extends StatefulWidget {
  const NavListShimmer({Key? key}) : super(key: key);

  @override
  State<NavListShimmer> createState() => _NavListShimmerState();
}

class _NavListShimmerState extends State<NavListShimmer> {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (_, __) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 5),
              height: 270,
              width: 170,
              decoration: BoxDecoration(
                  color: Colors.grey[300]!,
                  borderRadius: const BorderRadius.all(Radius.circular(15))),
              child: const Card(),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10),
            ),
            Container(
              height: 270,
              width: 170,
              decoration: BoxDecoration(
                  color: Colors.grey[300]!,
                  borderRadius: const BorderRadius.all(Radius.circular(15))),
              child: const Card(),
            )
          ],
        ),
        itemCount: 1,
      ),
    );
  }
}

class TopBuilderListShimmer extends StatefulWidget {
  const TopBuilderListShimmer({Key? key}) : super(key: key);

  @override
  State<TopBuilderListShimmer> createState() => _TopBuilderListShimmerState();
}

class _TopBuilderListShimmerState extends State<TopBuilderListShimmer> {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(top: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(left: 10),
                height: 160,
                width: 150,
                decoration: BoxDecoration(
                    color: Colors.grey[300]!,
                    borderRadius: const BorderRadius.all(Radius.circular(15))),
                child: const Card(),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 10),
              ),
              Container(
                height: 160,
                width: 150,
                decoration: BoxDecoration(
                    color: Colors.grey[300]!,
                    borderRadius: const BorderRadius.all(Radius.circular(15))),
                child: const Card(),
              ),
            ],
          ),
        ),
        itemCount: 2,
      ),
    );
  }
}
