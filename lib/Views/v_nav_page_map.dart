import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:squarest/Models/m_project.dart';
import 'package:squarest/Models/m_resale_property.dart';
import 'package:squarest/Services/s_filter_notifier.dart';
import 'package:squarest/Services/s_show_search.dart';
import 'package:squarest/Services/s_connectivity_notifier.dart';
import 'package:squarest/Models/m_latlng.dart' as location;
import 'package:squarest/Views/v_applied_filters.dart';
import 'package:squarest/Views/v_details_marker.dart';
import 'package:squarest/Views/v_no_internet.dart';
import 'package:auto_route/auto_route.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shimmer/shimmer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:squarest/Utils/u_themes.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:squarest/Services/s_autocomplete_notifier.dart';
import 'package:squarest/Models/m_place.dart';
import 'package:squarest/Services/s_get_current_location.dart';
import 'package:squarest/Utils/u_mapstyles.dart';
import 'package:squarest/Views/v_project_list.dart';
import 'package:squarest/Views/v_resale_property_list.dart';
import '../Services/s_resale_property_notifier.dart';

import '../Utils/u_constants.dart';

class MapSearch extends StatefulWidget {
  const MapSearch({Key? key}) : super(key: key);

  @override
  State<MapSearch> createState() => _MapSearchState();
}

class _MapSearchState extends State<MapSearch> with WidgetsBindingObserver {
  final TextEditingController _txtController = TextEditingController();
  Set<Marker> markers = {};
  Set<Marker> resaleMarkers = {};
  final LatLng _center = const LatLng(18.5204303, 73.8567437);
  late StreamSubscription placeSubscription;
  late StreamSubscription projectSubscription;
  List<Project> items = [];
  List<ResalePropertyModel> resaleItems = [];
  late String id = "";
  static const double _initialZoomLevel = 14.00;
  static const double _zoomLevelProjects = 13.00;
  double zoomLevel = _initialZoomLevel;
  bool showMap = false;
  static late final BitmapDescriptor customMarker;
  static late final BitmapDescriptor clickedMarker;
  late ClusterManager manager;
  late ClusterManager resaleManager;


  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    final autocompleteNotifier =
        Provider.of<AutocompleteNotifier>(context, listen: false);
    final mediaQuery = MediaQuery.of(context);
    if (state == AppLifecycleState.resumed) {
      var controller = await autocompleteNotifier.controller.future;
      if (mediaQuery.platformBrightness == Brightness.dark) {
        controller.setMapStyle(MapStyles.mapDark);
      } else {
        controller.setMapStyle(MapStyles.mapLight);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    final autocompleteNotifier =
        Provider.of<AutocompleteNotifier>(context, listen: false);
    WidgetsBinding.instance.addObserver(this);
    _setMapStyle();
    manager = _initClusterManager();
    resaleManager = _initClusterManagerResale();
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(48, 48)),
            'assets/images/marker.png')
        .then((onValue) {
      customMarker = onValue;
    });
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(48, 48)),
            'assets/images/click_marker.png')
        .then((onValue) {
      clickedMarker = onValue;
    });
    placeSubscription =
        autocompleteNotifier.selectedPlace.stream.listen((place) {
      _goToPlace(place);
    });
    projectSubscription =
        autocompleteNotifier.selectedProject.stream.listen((location) {
      goToProject(location);
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        showMap = true;
      });
    });
    autocompleteNotifier.isSearching = true;
  }

  @override
  dispose() {
    placeSubscription.cancel();
    projectSubscription.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final autocompleteNotifier = Provider.of<AutocompleteNotifier>(context);
    final resalePropertyNotifier = Provider.of<ResalePropertyNotifier>(context);
    final con = context.watch<ConnectivityChangeNotifier>();
    // final cupertinoNavBarHeight = const CupertinoNavigationBar().preferredSize.height;
    _txtController.text = autocompleteNotifier.status
        ? autocompleteNotifier.selectedNewHint
        : autocompleteNotifier.selectedResaleHint;
    if (autocompleteNotifier.status) {
      manager.setItems(autocompleteNotifier.filterProjects(context));
    } else {
      resaleManager.setItems(autocompleteNotifier.resaleProjectList);
    }
    return (con.connectivity == null)
        ? const Center(child: ShimmerWidget())
        : ((con.connectivity == ConnectivityResult.none) ||
                (con.isDeviceConnected == false))
            ? const NoInternet()
            : Scaffold(
                appBar: Platform.isAndroid
                    ? PreferredSize(
                        preferredSize: const Size.fromHeight(70.0),
                        child: Container(
                          padding: const EdgeInsets.only(top: 30),
                          child: AppBar(
                              backgroundColor:
                                  (MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark)
                                      ? Colors.grey[900]
                                      : Colors.white,
                              primary: true,
                              automaticallyImplyLeading: false,
                              flexibleSpace: Center(
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                                autocompleteNotifier.toggleStatus(value!);
                                                // autocompleteNotifier.status = value!;
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
                                          margin: const EdgeInsets.only(
                                              left: 3, right: 3),
                                          decoration: BoxDecoration(
                                            color: (MediaQuery.of(context)
                                                        .platformBrightness ==
                                                    Brightness.dark)
                                                ? const Color(0xFFF6F6F8)
                                                : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                          ),
                                          child: TextField(
                                            autofocus: false,
                                            readOnly: true,
                                            showCursor: true,
                                            onTap: () {
                                              showSearch(
                                                  context: context,
                                                  delegate: SearchPlaceDelegate(
                                                      this, false));
                                            },
                                            controller: _txtController,
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
                                                    color: (MediaQuery.of(
                                                                    context)
                                                                .platformBrightness ==
                                                            Brightness.dark)
                                                        ? Colors.grey
                                                        : Colors.black),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.0),
                                                  borderSide: BorderSide(
                                                      color: (MediaQuery.of(
                                                                      context)
                                                                  .platformBrightness ==
                                                              Brightness.dark)
                                                          ? Colors.grey
                                                          : Colors.black)),
                                              prefixIcon: const Icon(
                                                Icons.search,
                                                color: globalColor,
                                              ),
                                              suffixIcon: InkWell(
                                                onTap: () async {
                                                  _txtController.text =
                                                      "Showing Projects near you.";
                                                  GetGeoLocation()
                                                      .goToCurrentLocation(
                                                          autocompleteNotifier
                                                              .controller,
                                                          context);
                                                  await FirebaseAnalytics
                                                      .instance
                                                      .logEvent(
                                                    name: "select_content",
                                                    parameters: {
                                                      "content_type": "lat:lng",
                                                      "item_id":
                                                          autocompleteNotifier
                                                                  .projectList
                                                                  .isNotEmpty
                                                              ? '${autocompleteNotifier.projectList[0].lat} : ${autocompleteNotifier.projectList[0].lng}'
                                                              : '',
                                                    },
                                                  );
                                                },
                                                child: Icon(Icons.my_location,
                                                    color: (MediaQuery.of(
                                                                    context)
                                                                .platformBrightness ==
                                                            Brightness.dark)
                                                        ? Colors.white
                                                        : Colors.black),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (autocompleteNotifier.status)
                                        Container(
                                          margin: const EdgeInsets.only(right: 5),
                                          child: Column(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.tune_outlined,
                                                    size: 30.0),
                                                onPressed: () async {
                                                  AutoRouter.of(context)
                                                      .pushNamed('/filters');
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  await FirebaseAnalytics.instance
                                                      .logEvent(
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
                                          ),
                                        ),
                                    ]),
                              )),
                        ),
                      )
                    : PreferredSize(
                        preferredSize: const Size.fromHeight(100),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.14,
                          child: CupertinoNavigationBar(
                            backgroundColor:
                                (MediaQuery.of(context).platformBrightness ==
                                        Brightness.dark)
                                    ? Colors.grey[900]
                                    : CupertinoColors.white,
                            padding:
                                const EdgeInsetsDirectional.only(bottom: 5),
                            leading: Container(
                              margin: const EdgeInsets.only(
                                  left: 5, top: 10, bottom: 10),
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
                            middle: Container(
                              height: 50,
                              margin: const EdgeInsets.only(right: 5),
                              decoration: BoxDecoration(
                                color: (MediaQuery.of(context)
                                    .platformBrightness ==
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
                                      _txtController.text =
                                      "Showing Projects near you.";
                                      GetGeoLocation().goToCurrentLocation(
                                          autocompleteNotifier.controller,
                                          context);
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
                                        color: (MediaQuery.of(context)
                                            .platformBrightness ==
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
                                    color: (MediaQuery.of(context)
                                        .platformBrightness ==
                                        Brightness.dark)
                                        ? CupertinoColors.white
                                        : CupertinoColors.black),
                                decoration: BoxDecoration(
                                  color: (MediaQuery.of(context)
                                      .platformBrightness ==
                                      Brightness.dark)
                                      ? Colors.grey[900]
                                      : CupertinoColors.white,
                                  borderRadius: BorderRadius.circular(25.0),
                                  border: Border.all(
                                      width: 1,
                                      color: (MediaQuery.of(context)
                                          .platformBrightness ==
                                          Brightness.dark)
                                          ? CupertinoColors.systemGrey
                                          : CupertinoColors.black),
                                ),
                                autofocus: false,
                                readOnly: true,
                                showCursor: true,
                                onTap: () {
                                  showSearch(
                                      context: context,
                                      delegate: SearchPlaceDelegate(this, false));
                                },
                                controller: _txtController,
                                onChanged: (value) {},
                              ),
                            ),
                            trailing: autocompleteNotifier.status
                                ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(CupertinoIcons.slider_horizontal_3,
                                      size: 25),
                                  onPressed: () async {
                                    AutoRouter.of(context)
                                        .pushNamed('/filters');
                                    FocusScope.of(context).unfocus();
                                    await FirebaseAnalytics.instance
                                        .logEvent(
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
                                  style: TextStyle(
                                      color: (MediaQuery.of(context)
                                          .platformBrightness ==
                                          Brightness.dark)
                                          ? CupertinoColors.white
                                          : CupertinoColors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: FontSizes.s12),
                                )
                              ],
                            )
                                : null,
                          ),
                        )),
                backgroundColor: (MediaQuery.of(context).platformBrightness ==
                        Brightness.dark)
                    ? CupertinoColors.black
                    : CupertinoColors.white,
                body: SafeArea(
                  child: WillPopScope(
                    onWillPop: autocompleteNotifier.onWillPop,
                    child: Consumer<FilterNotifier>(
                      builder: (ctx, filters, _) => Column(
                        children: [
                          if (filters.isFilterApplied) const AppliedFilters(),
                          Expanded(
                            child: Stack(
                              children: [
                                if (showMap && zoomLevel > 16)
                                  const DetailsMarker(),
                                if (showMap)
                                  AnimatedOpacity(
                                    curve: Curves.easeInCirc,
                                    duration: const Duration(milliseconds: 500),
                                    opacity: showMap ? 1 : 0,
                                    child: GoogleMap(
                                      initialCameraPosition: CameraPosition(
                                        target: _center,
                                        zoom: _initialZoomLevel,
                                      ),
                                      minMaxZoomPreference: autocompleteNotifier
                                              .status
                                          ? MinMaxZoomPreference.unbounded
                                          : MinMaxZoomPreference(
                                              null,
                                              (resalePropertyNotifier.memPlans
                                                          .isNotEmpty &&
                                                      DateTime.now().isBefore(
                                                          resalePropertyNotifier
                                                              .memPlans[0]
                                                              .ending_on))
                                                  ? null
                                                  : 14),
                                      onMapCreated:
                                          (GoogleMapController controller) {
                                        autocompleteNotifier.controller
                                            .complete(controller);
                                        manager.setMapId(controller.mapId,
                                            withUpdate: false);
                                        resaleManager.setMapId(controller.mapId,
                                            withUpdate: false);
                                      },
                                      onCameraMoveStarted: () {
                                        autocompleteNotifier.isSearching = true;
                                      },
                                      onCameraMove: _onGeoChanged,
                                      onCameraIdle: zoomLevel >=
                                              _zoomLevelProjects
                                          ? () async {
                                              if (autocompleteNotifier.status) {
                                                if (autocompleteNotifier
                                                    .isSearchProject) {
                                                  await autocompleteNotifier
                                                      .getProjectById(
                                                          context,
                                                          autocompleteNotifier
                                                              .getProjectId,
                                                          this);
                                                  manager.setItems(
                                                      autocompleteNotifier
                                                          .projectList);
                                                  autocompleteNotifier
                                                      .setIsSearchProjectToFalse();
                                                } else {
                                                  await autocompleteNotifier
                                                      .getProjectsForBounds(
                                                          context, this);
                                                  if (!mounted) return;
                                                  if (filters.isFilterApplied) {
                                                    manager.setItems(
                                                        autocompleteNotifier
                                                            .filterProjects(
                                                                context));
                                                  } else {
                                                    manager.setItems(
                                                        autocompleteNotifier
                                                            .projectList);
                                                  }
                                                }
                                                autocompleteNotifier.isMapIdle =
                                                    true;
                                              } else {
                                                await autocompleteNotifier
                                                    .getProjectsForBounds(
                                                        context, this);
                                                resaleManager.setItems(
                                                    autocompleteNotifier
                                                        .resaleProjectList);
                                              }
                                            }
                                          : () => {
                                                autocompleteNotifier
                                                    .isSearching = false
                                              },
                                      onTap: (lat) {},
                                      mapType: MapType.normal,
                                      zoomControlsEnabled: false,
                                      zoomGesturesEnabled: true,
                                      myLocationButtonEnabled: false,
                                      compassEnabled: false,
                                      mapToolbarEnabled: false,
                                      markers: autocompleteNotifier.status
                                          ? markers
                                          : resaleMarkers,
                                    ),
                                  ),
                                Positioned(
                                  right: 10,
                                  bottom: 50,
                                  child: GestureDetector(
                                    onTap: () {
                                      if (autocompleteNotifier.status) {
                                        Navigator.of(context).push(
                                          platformPageRoute(
                                            context: context,
                                            builder: (context) =>
                                                const ProjectList(
                                              isComingFromWorthALook: false,
                                              isComingFromBuilders: false,
                                              builderId: null,
                                              isComingFrom3d: false,
                                              appBarTitle: "Search Results",
                                              isComingFromNewLaunches: false,
                                              isComingFromTrending: false,
                                            ),
                                          ),
                                        );
                                      } else {
                                        Navigator.of(context).push(
                                          platformPageRoute(
                                            context: context,
                                            builder: (context) =>
                                                const ResalePropertyList(
                                              appBarTitle: 'Search Results',
                                              isComingFromList: true,
                                            ),
                                          ),
                                        );
                                      }
                                      // autocompleteNotifier.setIsListClickedToTrue();
                                    },
                                    child: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: (MediaQuery.of(context)
                                                      .platformBrightness ==
                                                  Brightness.dark)
                                              ? Colors.grey[900]
                                              : Platform.isAndroid
                                                  ? Colors.white
                                                  : CupertinoColors
                                                      .white, // border color
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Platform.isAndroid
                                            ? Icons
                                                .format_list_bulleted_outlined
                                            : CupertinoIcons.list_bullet)),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(4.0),
                                  width: double.maxFinite,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color: Platform.isAndroid
                                        ? Colors.black.withOpacity(0.5)
                                        : CupertinoColors.black
                                            .withOpacity(0.5),
                                  ),
                                  child: autocompleteNotifier.isSearching
                                      ? DefaultTextStyle(
                                          style: TextStyle(
                                              color: Platform.isAndroid
                                                  ? Colors.white
                                                  : CupertinoColors.white),
                                          child: AnimatedTextKit(
                                            animatedTexts: [
                                              TyperAnimatedText('Searching...'),
                                            ],
                                          ))
                                      : zoomLevel < _zoomLevelProjects
                                          ? Text(
                                              "Please zoom in more to see projects",
                                              style: TextStyle(
                                                  color: Platform.isAndroid
                                                      ? Colors.white
                                                      : CupertinoColors.white),
                                            )
                                          : (autocompleteNotifier.status
                                                  ? autocompleteNotifier
                                                      .projectList.isEmpty
                                                  : autocompleteNotifier
                                                      .resaleProjectList
                                                      .isEmpty)
                                              ? Text(
                                                  "No projects",
                                                  style: TextStyle(
                                                      color: Platform.isAndroid
                                                          ? Colors.white
                                                          : CupertinoColors
                                                              .white),
                                                )
                                              : Text(
                                                  "${autocompleteNotifier.status ? autocompleteNotifier.projectList.length : autocompleteNotifier.resaleProjectList.length} projects",
                                                  style: TextStyle(
                                                      color: Platform.isAndroid
                                                          ? Colors.white
                                                          : CupertinoColors
                                                              .white),
                                                ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // },
                // ),
              );
  }

  Future _setMapStyle() async {
    final autocompleteNotifier =
        Provider.of<AutocompleteNotifier>(context, listen: false);
    final controller = await autocompleteNotifier.controller.future;
    if (!mounted) return;
    if (MediaQuery.of(context).platformBrightness == Brightness.dark) {
      controller.setMapStyle(MapStyles.mapDark);
    } else {
      controller.setMapStyle(MapStyles.mapLight);
    }
  }

  void _onGeoChanged(CameraPosition position) async {
    final autocompleteNotifier =
        Provider.of<AutocompleteNotifier>(context, listen: false);
    setState(() {
      zoomLevel = position.zoom.toDouble();
      if (autocompleteNotifier.status) {
        manager.onCameraMove(position);
      } else {
        resaleManager.onCameraMove(position);
      }
    });
  }

  Future<void> _goToPlace(Place place) async {
    final autocompleteNotifier =
        Provider.of<AutocompleteNotifier>(context, listen: false);
    final GoogleMapController controller =
        await autocompleteNotifier.controller.future;

    LatLngBounds bounds = createBounds(place);

    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 10));
  }

  Future<void> goToProject(location.Location location) async {
    final autocompleteNotifier =
        Provider.of<AutocompleteNotifier>(context, listen: false);
    final GoogleMapController controller =
        await autocompleteNotifier.controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(location.lat, location.lng), _zoomLevelProjects));
  }

  LatLngBounds createBounds(Place place) {
    final southwestLat = place.geometry.viewport.southwest.lat;
    final southwestLon = place.geometry.viewport.southwest.lng;
    final northeastLat = place.geometry.viewport.northeast.lat;
    final northeastLon = place.geometry.viewport.northeast.lng;

    return LatLngBounds(
        southwest: LatLng(southwestLat, southwestLon),
        northeast: LatLng(northeastLat, northeastLon));
  }

  void _updateMarkers(Set<Marker> markers) {
    setState(() {
      this.markers = markers;
    });
  }

  void _updateResaleMarkers(Set<Marker> markers) {
    setState(() {
      resaleMarkers = markers;
    });
  }

  Future<Marker> Function(Cluster<Project>) get _markerBuilder =>
      (cluster) async {
        final autocompleteNotifier =
            Provider.of<AutocompleteNotifier>(context, listen: false);
        String clusterProjectId = cluster.items.first.applicationno;
        return Marker(
            markerId: MarkerId(cluster.getId()),
            position: cluster.location,
            onTap: () async {
              if (cluster.isMultiple == false) {
                id = clusterProjectId;
                autocompleteNotifier.projectForBottomSheet =
                    cluster.items.first;
                autocompleteNotifier.openBottomSheet(context);
              }
              await FirebaseAnalytics.instance.logEvent(
                name: "select_content",
                parameters: {
                  "content_type": "marker",
                  "item_id": clusterProjectId,
                },
              );
            },
            //icon: zoomLevel > 16 ?  await MarkerIcon.widgetToIcon(autocompleteNotifier.globalKey) : _getMarkerBitmap(clusterProjectId));
            icon: zoomLevel > 16
                ? await pictureWidgetWithCenterText(
                    globalKey: autocompleteNotifier.globalKey,
                    min: cluster.items.first.min_price.toInt().toString(),
                    max: cluster.items.first.max_price.toInt().toString(),
                    isComingFromResale: false,
                    size: const Size(200, 100),
                    fontSize: 18)
                : _getMarkerBitmap(clusterProjectId));
      };

  Future<Marker> Function(Cluster<ResalePropertyModel>)
      get _markerResaleBuilder => (cluster) async {
            final autocompleteNotifier =
                Provider.of<AutocompleteNotifier>(context, listen: false);
            String clusterProjectId = cluster.items.first.id.toString();
            return Marker(
                markerId: MarkerId(cluster.getId()),
                position: cluster.location,
                onTap: () async {
                  if (cluster.isMultiple == false) {
                    id = clusterProjectId;
                    autocompleteNotifier.propertyForBottomSheet =
                        cluster.items.first;
                    autocompleteNotifier.openResaleBottomSheet(context, true);
                  }
                  await FirebaseAnalytics.instance.logEvent(
                    name: "select_content",
                    parameters: {
                      "content_type": "marker",
                      "item_id": clusterProjectId,
                    },
                  );
                },
                icon: zoomLevel > 16
                    ? await pictureWidgetWithCenterText(
                        globalKey: autocompleteNotifier.globalKey,
                        price: cluster.items.first.price.toInt().toString(),
                        isComingFromResale: true,
                        size: const Size(200, 100),
                        fontSize: 18)
                    : _getMarkerBitmap(clusterProjectId));
          };

  BitmapDescriptor _getMarkerBitmap(String clusterProjectId) {
    if (id == clusterProjectId) {
      return clickedMarker;
    } else {
      return customMarker;
    }
  }

  ClusterManager _initClusterManager() {
    return ClusterManager<Project>(items, _updateMarkers,
        markerBuilder: _markerBuilder,
        //levels: [13.00, 13.25, 13.50, 13.75, 14.00, 14.25, 14.50, 14.75, 15.00],
        levels: [10.00, 11.00, 12.00, 12.50, 13.00],
        extraPercent: 0.2,
        stopClusteringZoom: 13.00);
  }

  ClusterManager _initClusterManagerResale() {
    return ClusterManager<ResalePropertyModel>(
        resaleItems, _updateResaleMarkers,
        markerBuilder: _markerResaleBuilder,
        //levels: [13.00, 13.25, 13.50, 13.75, 14.00, 14.25, 14.50, 14.75, 15.00],
        levels: [10.00, 11.00, 12.00, 12.50, 13.00],
        extraPercent: 0.2,
        stopClusteringZoom: 13.00);
  }

  Future<BitmapDescriptor> pictureWidgetWithCenterText(
      {required GlobalKey globalKey,
      String? min,
      String? max,
      required bool isComingFromResale,
      String? price,
      required Size size,
      double fontSize = 18,
      Color fontColor = CupertinoColors.white,
      FontWeight fontWeight = FontWeight.w500}) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Path clipPath = Path();
    const Radius radius = Radius.circular(0);
    clipPath.addRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(0.0, 0.0, size.width.toDouble(), size.height.toDouble()),
        topLeft: radius,
        topRight: radius,
        bottomLeft: radius,
        bottomRight: radius,
      ),
    );
    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: isComingFromResale
          ? '₹ $price L'
          : (min == '0' && max != '0')
              ? 'Upto ₹ $max L'
              : (min != '0' && max == '0')
                  ? 'From ₹ $min L'
                  : (min == '0' && max == '0')
                      ? '₹ Request'
                      : '₹ $min - $max L',
      style: TextStyle(
          fontSize: fontSize, color: fontColor, fontWeight: fontWeight),
    );

    canvas.clipPath(clipPath);

    RenderRepaintBoundary boundary =
        globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
    ui.Image imageWidget = await boundary.toImage();

    paintImage(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        canvas: canvas,
        rect: Rect.fromLTWH(
            0, 2.5, size.width.toDouble(), size.height.toDouble()),
        image: imageWidget);
    painter.layout();
    painter.paint(
        canvas,
        Offset((size.width * 0.5) - painter.width * 0.5,
            (size.height * 0.5) - painter.height * 0.5));

    final image = await pictureRecorder
        .endRecording()
        .toImage(size.width.toInt(), (size.height).toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
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

class ShimmerWidget extends StatelessWidget {
  const ShimmerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor:
              (MediaQuery.of(context).platformBrightness == Brightness.dark)
                  ? Colors.grey[900]
                  : Platform.isAndroid
                      ? Colors.white
                      : CupertinoColors.white,
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 35),
            child: Row(
              children: [
                Shimmer.fromColors(
                  baseColor: (MediaQuery.of(context).platformBrightness ==
                          Brightness.dark)
                      ? Colors.grey[700]!
                      : Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 80,
                    height: 50,
                    margin: const EdgeInsets.only(left: 5),
                    decoration: BoxDecoration(
                      color: (MediaQuery.of(context).platformBrightness ==
                              Brightness.dark)
                          ? Colors.grey[700]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: const CupertinoTextField(
                      decoration: BoxDecoration(
                          // border: InputBorder.none,
                          ),
                    ),
                  ),
                ),
                Expanded(
                  child: Shimmer.fromColors(
                    baseColor: (MediaQuery.of(context).platformBrightness ==
                            Brightness.dark)
                        ? Colors.grey[700]!
                        : Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: (MediaQuery.of(context).platformBrightness ==
                                Brightness.dark)
                            ? Colors.grey[700]
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Platform.isAndroid
                                ? Icons.search
                                : CupertinoIcons.search,
                            color: Colors.grey[400]!,
                          ),
                          suffixIcon: Icon(
                            Platform.isAndroid
                                ? Icons.my_location
                                : CupertinoIcons.location,
                            color: Colors.grey[400]!,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Shimmer.fromColors(
                  baseColor: (MediaQuery.of(context).platformBrightness ==
                          Brightness.dark)
                      ? Colors.grey[700]!
                      : Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: IconButton(
                      icon: Icon(
                        Icons.filter_list,
                        size: 30.0,
                        color: Colors.grey[400]!,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 1.0),
        child: Shimmer.fromColors(
          baseColor:
              (MediaQuery.of(context).platformBrightness == Brightness.dark)
                  ? Colors.grey[700]!
                  : Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: ListView.builder(
            itemBuilder: (_, __) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        height: 25.0,
                        color: Colors.grey[300]!,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.75,
                        color: Colors.grey[300]!,
                      )
                    ],
                  ),
                )
              ],
            ),
            itemCount: 1,
          ),
        ),
      ),
    );
  }
}
