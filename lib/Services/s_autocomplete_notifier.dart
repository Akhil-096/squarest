import 'dart:io';

import 'package:squarest/Models/m_builders.dart';
import 'package:squarest/Models/m_project_inventory.dart';
import 'package:squarest/Models/m_resale_property.dart';
import 'package:squarest/Models/m_search_project.dart';
import 'package:squarest/Services/s_liked_projects_notifier.dart';
import 'package:squarest/Services/s_resale_property_service.dart';
import 'package:squarest/Services/s_storage_access.dart';
import 'package:squarest/Views/v_project_card.dart';
import 'package:squarest/Models/m_project.dart';
import 'package:squarest/Services/s_filter_notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:squarest/Services/s_resale_property_notifier.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:squarest/Models/m_places_search.dart';
import 'package:squarest/Services/s_places_service.dart';
import 'package:squarest/Services/s_get_project_service.dart';
import 'package:squarest/Models/m_place.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:squarest/Models/m_latlng.dart' as location;
import '../Models/m_search_address.dart';
import '../Views/v_resale_property_card.dart';



class AutocompleteNotifier with ChangeNotifier {
  final placesService = PlacesService();
  final projectService = ProjectService();
  final resaleService = ResalePropertyService();
  final Completer<GoogleMapController> controller = Completer();
  String selectedNewHint = "Place or project";
  String selectedResaleHint = "Place";
  String selectedLocationFilter = "";
  bool openShare = false;



  // Project? project;
  Project? projectForBottomSheet;
  bool isBottomSheetOpen = false;
  PersistentBottomSheetController? persistentBottomSheetController;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSearchProject = false;
  int _projectId = 0;
  DateTime currentBackPressTime = DateTime.now();
  bool isMapIdle = false;

  List<PlaceSearch> searchResults = [];
  StreamController<Place> selectedPlace = StreamController<Place>.broadcast();
  StreamController<location.Location> selectedProject = StreamController<location.Location>.broadcast();
  List<Project> projectList = [];
  List<ResalePropertyModel> resaleProjectList = [];
  List<Project> originalList = [];
  List<Project> brandedBuilders = [];
  List<Project> otherBuilders = [];
  List<SearchProjectModel> searchedProjects = [];
  List<ProjectInventory> projectInventoryList = [];
  List<BuildersModel> topBuildersList = [];
  List<Project> aRprojectLists = [];
  List<Project> builderProjectLists = [];
  List<Project> newLaunchesLists = [];
  List<Project> trendingLists = [];
  List<Project> worthALookLists = [];
  List<CandidatesModel> candidates = [];
  bool isSearching = false;
  final locationTextController = TextEditingController();
  SearchAddressModel? searchedAddress;
  Position? currentPosition;
  Placemark? place;
  String subLocality = '';
  String locality = '';
  String postalCode = '';
  ResalePropertyModel? propertyForBottomSheet;
  bool status = true;
  final GlobalKey globalKey = GlobalKey();
  DateTime? selectedDate;
  List<bool> dropDownItems = [
    true,
    false,
  ];
  final GlobalKey bottomNavGlobalKey = GlobalKey();


  // bool isSearchedFromNewHot = false;
  //
  //
  toggleStatus(bool value){
    status = value;
    notifyListeners();
  }


  Future<void> setSelectedDate(DateTime? calendarDate) async {
    selectedDate = calendarDate;
    notifyListeners();
  }

  setIsSearchProjectToFalse(){
    isSearchProject = false;
    notifyListeners();
  }

  setIsSearchProjectToTrue(){
    isSearchProject = true;
    notifyListeners();
  }

  set setProjectId(int id){
    _projectId = id;
  }

  int get getProjectId {
    return _projectId;
  }

  Future<bool> onWillPop() {
    if(isBottomSheetOpen){
      closeBottomSheet();
      return Future.value(false);
    } else {
        DateTime now = DateTime.now();
        if (now.difference(currentBackPressTime) > const Duration(seconds: 2)) {
          currentBackPressTime = now;
          Fluttertoast.showToast(
            msg: 'Press again to exit',
            backgroundColor: Platform.isAndroid ? Colors.white : CupertinoColors.white,
            textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
          );
          return Future.value(false);
        }
        return Future.value(true);
    }

  }

  closeBottomSheet() {
    if (persistentBottomSheetController != null) {
      persistentBottomSheetController?.close();
      persistentBottomSheetController?.closed.whenComplete(() {
        persistentBottomSheetController = null;
        isBottomSheetOpen = false;
      });
    }
  }

  openBottomSheet(BuildContext context){
    isBottomSheetOpen = true;
    persistentBottomSheetController = scaffoldKey.currentState?.showBottomSheet((context) {
      return ProjectCard(
        project: projectForBottomSheet as Project,
      );
    },
      shape:  RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)),
      constraints: BoxConstraints.loose(Size(
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height * 0.40)),
      enableDrag: false
    );
  }


  closeResaleBottomSheet() {
    if (persistentBottomSheetController != null) {
      persistentBottomSheetController?.close();
      persistentBottomSheetController?.closed.whenComplete(() {
        persistentBottomSheetController = null;
        isBottomSheetOpen = false;
      });
    }
    notifyListeners();
  }

  openResaleBottomSheet(BuildContext context, bool isComingFromMapOrList){
    isBottomSheetOpen = true;
    // print(isBottomSheetOpen);
    persistentBottomSheetController = scaffoldKey.currentState?.showBottomSheet((context) {
      return ResalePropertyCard(
        resalePropertyModel: propertyForBottomSheet as ResalePropertyModel,
        isComingFromMapOrList: isComingFromMapOrList,
      );
    },
        shape:  RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)),
        constraints: BoxConstraints.loose(Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height * 0.40)),
        enableDrag: false
    );
    notifyListeners();
  }

  // setLikeToTrue(){
  //   like = true;
  //   notifyListeners();
  // }
  //
  // setLikeToFalse(){
  //   like = false;
  //   notifyListeners();
  // }

  setOpenShareToTrue(){
    openShare = true;
    notifyListeners();
  }

  setOpenShareToFalse(){
    openShare = false;
    notifyListeners();
  }

  searchPlaces(String searchTerm) async {
    searchResults = await placesService.getAutocomplete(searchTerm);
    notifyListeners();
  }

  searchedLocation(String newLocation) {
    selectedNewHint = newLocation;
    notifyListeners();
  }

  setSelectedPlace(String placeId) async {
    selectedPlace.add(await placesService.getPlace(placeId));
    searchResults = [];
    notifyListeners();
  }

  setSelectedProject(location.Location location) async {
    selectedProject.add(location);
    notifyListeners();
  }

  Future<void> getProjectsForBounds(BuildContext context, State state) async {
    final autocompleteNotifier =
    Provider.of<AutocompleteNotifier>(context, listen: false);
    GoogleMapController controller =
    await autocompleteNotifier.controller.future;
    LatLngBounds bounds = await controller.getVisibleRegion();
    if(autocompleteNotifier.status){
      if (!state.mounted) return;
      await autocompleteNotifier.addProjects(context, bounds, state);
    } else {
      if (!state.mounted) return;
      await autocompleteNotifier.addResaleProjects(context, bounds, state);
    }
  }


  Future<void> getSearchedAddress(String userText) async {
    searchedAddress = await placesService.getSearchedAddress(userText);
    candidates = searchedAddress!.candidates;
    notifyListeners();
  }

  Future<void> getCurrentLocation(BuildContext context, State state) async {
    bool serviceEnabled;
    LocationPermission permission;
    const String noLocationMsg = 'Unable to get location. Please try later.';
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      Fluttertoast.showToast(
        msg: 'Location service is disabled. Enable and try again',
        backgroundColor: Platform.isAndroid ? Colors.white : CupertinoColors.white,
        textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
      );
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(
          msg: 'Location permissions are denied',
          backgroundColor: Platform.isAndroid ? Colors.white : CupertinoColors.white,
          textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
        );
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      Fluttertoast.showToast(
        msg: 'Location permissions are permanently denied, we cannot request permissions.',
        backgroundColor: Platform.isAndroid ? Colors.white : CupertinoColors.white,
        textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
      );
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    isSearching = true;
    if (isSearching) {
      locationTextController.text = 'fetching live location...';
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      if(!state.mounted) return;
      getAddressFromLatLong(await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5)), context);
    } catch (e) {
      Fluttertoast.showToast(
        msg: noLocationMsg,
        backgroundColor: Platform.isAndroid ? Colors.white : CupertinoColors.white,
        textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
      );
      return Future.error('Unable to get current location.');
    }
    notifyListeners();
  }

  Future<void> getAddressFromLatLong(Position position, BuildContext context) async {
    final resalePropertyNotifier = Provider.of<ResalePropertyNotifier>(context, listen: false);
    List<Placemark> placeMarks =
    await placemarkFromCoordinates(position.latitude, position.longitude);
    resalePropertyNotifier.lat = position.latitude;
    resalePropertyNotifier.lng = position.longitude;
    place = placeMarks[0];
    isSearching = false;
    subLocality = '${place?.subLocality}';
    locality = '${place?.locality}';
    postalCode = '${place?.postalCode}';
    locationTextController.text =
    '${place?.street}, ${place?.thoroughfare}, ${place?.subLocality}, ${place?.locality}, ${place?.postalCode}, ${place?.administrativeArea}, ${place?.country}';
    notifyListeners();
  }


  addProjects(BuildContext context, LatLngBounds bounds, State state) async {
    projectList.clear();
    projectList = await projectService.fetchProjects(bounds).whenComplete(() {
      isSearching = false;
    });
    if(!state.mounted) return;
    loadImages();
    loadLikes(context);
    originalList = projectList;
    notifyListeners();
  }

  addResaleProjects(BuildContext context, LatLngBounds bounds, State state) async {
    resaleProjectList.clear();
    resaleProjectList = await resaleService.getResaleProjectsFromBounds(bounds).whenComplete(() {
      isSearching = false;
    });
    // if(!state.mounted) return;
    // loadImages();
    // loadLikes(context);
    // originalList = projectList;
    notifyListeners();
  }

  getSearchedProjects(String userText) async {
    searchedProjects = await projectService.getSearchedProjects(userText);
    notifyListeners();
  }

  Future<void> getTopBuilders(BuildContext context, State state) async {
    topBuildersList = await projectService.getTopBuilders();
    if(!state.mounted) return;
    loadBuilderLogos(context);
    notifyListeners();
  }

  Future<void> getNewLaunches(BuildContext context, State state) async {
    newLaunchesLists = await projectService.getNewLaunches();
    if(!state.mounted) return;
    loadNewLaunchesImages();
    loadNewLaunchesLikes(context);
    notifyListeners();
  }

  Future<void> getTrending(BuildContext context, State state) async {
    trendingLists = await projectService.getTrendingProjects();
    if(!state.mounted) return;
    loadTrendingImages();
    loadTrendingLikes(context);
    notifyListeners();
  }

  Future<void> get3dBuilders(BuildContext context, State state) async {
    aRprojectLists = await projectService.get3dProjects();
    if(!state.mounted) return;
    load3dImages();
    load3dLikes(context);
    notifyListeners();
  }

  Future<void> getWorthALook(BuildContext context, State state) async {
    worthALookLists = await projectService.getWorthALook();
    if(!state.mounted) return;
    loadWorthALookImages();
    loadWorthALookLikes(context);
    notifyListeners();
  }

  getProjectInventory(int id) async {
    projectInventoryList = await projectService.getProjectInventory(id);
    notifyListeners();
  }

  Future<void> getBuilderProjects(BuildContext context, int builderId, State state) async {
    builderProjectLists.clear();
    builderProjectLists = await projectService.getBuilderProjects(builderId);
    if(!state.mounted) return;
    loadBuilderImages();
    loadBuilderLikes(context);
    notifyListeners();
  }

  getProjectById(BuildContext context, int id, State state) async {
    projectList.clear();
    projectList = await projectService.getProjectById(id).whenComplete(() {
      isSearching = false;
    });
    if(!state.mounted) return;
    loadImages();
    loadLikes(context);
    notifyListeners();
  }

  Future<void> loadBuilderLogos(BuildContext context) async {
    Future.delayed(const Duration(milliseconds: 500));
    try {
      // String json =
      // await rootBundle.loadString('assets/storage_img_serv_acc_cred.json');
      // StorageAccess storageAccess = StorageAccess(json);
      for (int i = 0; i < topBuildersList.length; i++) {
        topBuildersList[i].imageUrlList = topBuildersList[i].imageUrlList
          ..add('https://storage.googleapis.com/squarest_photos/Builders/${topBuildersList[i].logo}');
      }
    } catch (error) {
      if (kDebugMode) {
        print('$error');
      }
      rethrow;
    }
  }

   loadImages() async {
    Future.delayed(const Duration(milliseconds: 500));
    // final autoCompleteNotifier =
    // Provider.of<AutocompleteNotifier>(context, listen: false);
    try {
      String json =
      await rootBundle.loadString('assets/storage_img_serv_acc_cred.json');
      StorageAccess storageAccess = StorageAccess(json);
          if(projectList.isNotEmpty){
            for (int i = 0; i < projectList.length; i++) {
              projectList[i].imageUrlList = projectList[i].imageUrlList
                ..addAll((await storageAccess.loadFromBucket(
                    projectList[i].applicationno).whenComplete(() {
                  notifyListeners();
                })));

            }
          }
    } catch (error) {
      if (kDebugMode) {
        print('$error');
      }
      rethrow;
    }
  }

  loadBuilderImages()async{
    Future.delayed(const Duration(milliseconds: 500));
    String json =
    await rootBundle.loadString('assets/storage_img_serv_acc_cred.json');
    StorageAccess storageAccess = StorageAccess(json);
    if(builderProjectLists.isNotEmpty){
      for (int i = 0; i < builderProjectLists.length; i++) {
        builderProjectLists[i].imageUrlList =
        builderProjectLists[i].imageUrlList
          ..addAll((await storageAccess.loadFromBucket(
              builderProjectLists[i].applicationno).whenComplete(() {
            notifyListeners();
          })));
      }
    }
  }

  loadTrendingImages()async{
    Future.delayed(const Duration(milliseconds: 500));
    String json =
    await rootBundle.loadString('assets/storage_img_serv_acc_cred.json');
    StorageAccess storageAccess = StorageAccess(json);
    if(trendingLists.isNotEmpty){
      for (int i = 0; i < trendingLists.length; i++) {
        trendingLists[i].imageUrlList =
        trendingLists[i].imageUrlList
          ..addAll((await storageAccess.loadFromBucket(
              trendingLists[i].applicationno).whenComplete(() {
            notifyListeners();
          })));
      }
    }
  }

  loadWorthALookImages() async {
    Future.delayed(const Duration(milliseconds: 500));
    String json =
    await rootBundle.loadString('assets/storage_img_serv_acc_cred.json');
    StorageAccess storageAccess = StorageAccess(json);
    if(worthALookLists.isNotEmpty){
      for (int i = 0; i < worthALookLists.length; i++) {
        worthALookLists[i].imageUrlList =
        worthALookLists[i].imageUrlList
          ..addAll((await storageAccess.loadFromBucket(
              worthALookLists[i].applicationno).whenComplete(() {
            notifyListeners();
          })));
      }
    }
  }

  loadNewLaunchesImages()async{
    Future.delayed(const Duration(milliseconds: 500));
    String json =
    await rootBundle.loadString('assets/storage_img_serv_acc_cred.json');
    StorageAccess storageAccess = StorageAccess(json);
    if(newLaunchesLists.isNotEmpty){
      for (int i = 0; i < newLaunchesLists.length; i++) {
        newLaunchesLists[i].imageUrlList =
        newLaunchesLists[i].imageUrlList
          ..addAll((await storageAccess.loadFromBucket(
              newLaunchesLists[i].applicationno).whenComplete(() {
            notifyListeners();
          })));
      }
    }
  }

  load3dImages()async{
    Future.delayed(const Duration(milliseconds: 500));
    String json =
    await rootBundle.loadString('assets/storage_img_serv_acc_cred.json');
    StorageAccess storageAccess = StorageAccess(json);
    if(aRprojectLists.isNotEmpty){
      for (int i = 0; i < aRprojectLists.length; i++) {
        aRprojectLists[i].imageUrlList = aRprojectLists[i].imageUrlList
          ..addAll((await storageAccess.loadFromBucket(
              aRprojectLists[i].applicationno).whenComplete(() {
            notifyListeners();
          })));

      }
    }
  }

  load3dLikes(BuildContext context)async{
    Future.delayed(const Duration(milliseconds: 500));
    final likedProjectsNotifier =
    Provider.of<LikedProjectsNotifier>(context, listen: false);
    List<Project> currentLiked3dProjects = [];
    for (int i = 0; i < likedProjectsNotifier.likedProjectsList.length; i++) {
      if(aRprojectLists.isNotEmpty){
        currentLiked3dProjects = currentLiked3dProjects..addAll(aRprojectLists.where((element) => likedProjectsNotifier.likedProjectsList[i].id == element.id).toList());
      }
    }
    if(aRprojectLists.isNotEmpty){
      for(int i = 0; i < currentLiked3dProjects.length; i++){
        aRprojectLists = aRprojectLists..firstWhere((element) => element.id == currentLiked3dProjects[i].id).isLiked = true;
      }
    }
  }

  loadWorthALookLikes(BuildContext context)async{
    Future.delayed(const Duration(milliseconds: 500));
    final likedProjectsNotifier =
    Provider.of<LikedProjectsNotifier>(context, listen: false);
    List<Project> currentLikedWorthALookProjects = [];
    for (int i = 0; i < likedProjectsNotifier.likedProjectsList.length; i++) {
      if(worthALookLists.isNotEmpty){
        currentLikedWorthALookProjects = currentLikedWorthALookProjects..addAll(worthALookLists.where((element) => likedProjectsNotifier.likedProjectsList[i].id == element.id).toList());
      }
    }
    if(worthALookLists.isNotEmpty){
      for(int i = 0; i < currentLikedWorthALookProjects.length; i++){
        worthALookLists = worthALookLists..firstWhere((element) => element.id == currentLikedWorthALookProjects[i].id).isLiked = true;
      }
    }
  }

  loadBuilderLikes(BuildContext context)async{
    Future.delayed(const Duration(milliseconds: 500));
    final likedProjectsNotifier =
    Provider.of<LikedProjectsNotifier>(context, listen: false);
    List<Project> currentLikedBuilderProjects = [];
    for (int i = 0; i < likedProjectsNotifier.likedProjectsList.length; i++) {
      if(builderProjectLists.isNotEmpty){
        currentLikedBuilderProjects = currentLikedBuilderProjects..addAll(builderProjectLists.where((element) => likedProjectsNotifier.likedProjectsList[i].id == element.id).toList());
      }
    }

    if(builderProjectLists.isNotEmpty){
      for(int i = 0; i < currentLikedBuilderProjects.length; i++){
        builderProjectLists = builderProjectLists..firstWhere((element) => element.id == currentLikedBuilderProjects[i].id).isLiked = true;

      }
    }
  }

  loadNewLaunchesLikes(BuildContext context)async{
    Future.delayed(const Duration(milliseconds: 500));
    final likedProjectsNotifier =
    Provider.of<LikedProjectsNotifier>(context, listen: false);
    List<Project> currentLikedNewLaunches = [];
    for (int i = 0; i < likedProjectsNotifier.likedProjectsList.length; i++) {
      if(newLaunchesLists.isNotEmpty){
        currentLikedNewLaunches = currentLikedNewLaunches..addAll(newLaunchesLists.where((element) => likedProjectsNotifier.likedProjectsList[i].id == element.id).toList());
      }
    }

    if(newLaunchesLists.isNotEmpty){
      for (int i = 0; i < currentLikedNewLaunches.length; i++) {
        newLaunchesLists = newLaunchesLists
          ..firstWhere((element) => element.id == currentLikedNewLaunches[i].id)
              .isLiked = true;
      }
    }
  }

  loadTrendingLikes(BuildContext context)async{
    Future.delayed(const Duration(milliseconds: 500));
    final likedProjectsNotifier =
    Provider.of<LikedProjectsNotifier>(context, listen: false);
    List<Project> currentLikedTrending = [];
    for (int i = 0; i < likedProjectsNotifier.likedProjectsList.length; i++) {
      if(trendingLists.isNotEmpty){
        currentLikedTrending = currentLikedTrending..addAll(trendingLists.where((element) => likedProjectsNotifier.likedProjectsList[i].id == element.id).toList());
      }
    }

    if(trendingLists.isNotEmpty){
      for(int i = 0; i < currentLikedTrending.length; i++){
        trendingLists = trendingLists..firstWhere((element) => element.id == currentLikedTrending[i].id).isLiked = true;
      }
    }
  }

  loadLikes(BuildContext context) async {
    Future.delayed(const Duration(milliseconds: 500));
    List<Project> currentLikedProjects = [];
    // final autoCompleteNotifier =
    // Provider.of<AutocompleteNotifier>(context, listen: false);
    final likedProjectsNotifier =
    Provider.of<LikedProjectsNotifier>(context, listen: false);
    for (int i = 0; i < likedProjectsNotifier.likedProjectsList.length; i++) {
      if(projectList.isNotEmpty){
        currentLikedProjects = currentLikedProjects..addAll(projectList.where((element) => likedProjectsNotifier.likedProjectsList[i].id == element.id).toList());
      }
    }
    if(projectList.isNotEmpty){
      for (int i = 0; i < currentLikedProjects.length; i++) {
        projectList = projectList
          ..firstWhere((element) => element.id == currentLikedProjects[i].id)
              .isLiked = true;
      }
    }
  }

  incrementViews(int id) async {
    await projectService.incrementViewCount(id);
  }

  List<Project> filterProjects(BuildContext context) {
    final filters = Provider.of<FilterNotifier>(context, listen: false);
    final date = DateTime.now();

    // Area
    if (filters.appliedFilter.carpetChoice[0] != 0 &&
        filters.appliedFilter.carpetChoice[1] == 0) {
      projectList = projectList
          .where((element) =>
      element.min_area >= filters.appliedFilters.carpetChoice[0])
          .toList();
    } else if (filters.appliedFilter.carpetChoice[0] == 0 &&
        filters.appliedFilter.carpetChoice[1] != 0) {
      projectList = projectList
          .where((element) =>
      element.min_area <= filters.appliedFilters.carpetChoice[1])
          .toList();
    } else if (filters.appliedFilter.carpetChoice[0] != 0 &&
        filters.appliedFilter.carpetChoice[1] != 0) {
      projectList = projectList
          .where((element) =>
      (element.min_area >= filters.appliedFilters.carpetChoice[0] &&
          element.min_area <= filters.appliedFilters.carpetChoice[1]))
          .toList();
    }

      // Price
      if (filters.appliedFilter.priceChoice[0] != 0 &&
          filters.appliedFilter.priceChoice[1] == 0) {
        projectList = projectList
            .where((element) =>
        (element.min_price == 0.0 || (element.min_price >= filters.appliedFilters.priceChoice[0])))
            .toList();
      } else if (filters.appliedFilter.priceChoice[0] == 0 &&
          filters.appliedFilter.priceChoice[1] != 0) {
        projectList = projectList
            .where((element) =>
        (element.min_price == 0.0 || (element.min_price <= filters.appliedFilters.priceChoice[1])))
            .toList();
      } else if (filters.appliedFilter.priceChoice[0] != 0 &&
          filters.appliedFilter.priceChoice[1] != 0) {
        projectList = projectList
            .where((element) =>
        (element.min_price == 0.0 || (element.min_price >= filters.appliedFilters.priceChoice[0] && element.min_price <= filters.appliedFilters.priceChoice[1])))
            .toList();
      }

    // Available Flats
    if (filters.appliedFilter.selectedIndexAvailableFlats == 1) {
      projectList = projectList
          .where((element) =>
      ((element.total_num_apts - element.total_bkd_apts) /
          element.total_num_apts) *
          100 <=
          10)
          .toList();
    } else if (filters.appliedFilter.selectedIndexAvailableFlats == 2) {
      projectList = projectList
          .where((element) =>
      ((element.total_num_apts - element.total_bkd_apts) /
          element.total_num_apts) *
          100 <=
          25)
          .toList();
    } else if (filters.appliedFilter.selectedIndexAvailableFlats == 3) {
      projectList = projectList
          .where((element) =>
      ((element.total_num_apts - element.total_bkd_apts) /
          element.total_num_apts) *
          100 <=
          50)
          .toList();
    } else if (filters.appliedFilter.selectedIndexAvailableFlats == 4) {
      projectList = projectList
          .where((element) =>
      ((element.total_num_apts - element.total_bkd_apts) /
          element.total_num_apts) *
          100 >
          50)
          .toList();
    }

    // Ready Status
    if (filters.appliedFilter.selectedIndexReadyStatus == 1) {
      projectList = projectList
          .where((element) =>
      element.proposed_completion_date
          .difference(date)
          .inDays <=
          date.day)
          .toList();
    } else if (filters.appliedFilter.selectedIndexReadyStatus == 2) {
      projectList = projectList
          .where((element) =>
      element.proposed_completion_date
          .difference(date)
          .inDays <=
          180)
          .toList();
    } else if (filters.appliedFilter.selectedIndexReadyStatus == 3) {
      projectList = projectList
          .where((element) =>
      element.proposed_completion_date
          .difference(date)
          .inDays <=
          365)
          .toList();
    } else if (filters.appliedFilter.selectedIndexReadyStatus == 4) {
      projectList = projectList
          .where((element) =>
      element.proposed_completion_date
          .difference(date)
          .inDays >
          365)
          .toList();
    }

    // // Township
    // if (filters.appliedFilter.slectedIndexTownship == 1) {
    //   projectList = projectList
    //       .where((element) => element.project_is_township == true)
    //       .toList();
    // } else if (filters.appliedFilter.slectedIndexTownship == 2) {
    //   projectList = projectList
    //       .where((element) => element.project_is_township == false)
    //       .toList();
    // }
    //
    // //Bhk
    // if (filters.appliedFilter.bhk.contains(1)) {
    //   projectList = projectList.where((element) => element.one_bhk).toList();
    // } else if (filters.appliedFilter.bhk.contains(2)) {
    //   projectList = projectList.where((element) => element.two_bhk).toList();
    // } else if (filters.appliedFilter.bhk.contains(3)) {
    //   projectList =
    //       projectList.where((element) => element.three_bhk).toList();
    // } else if (filters.appliedFilter.bhk.contains(4)) {
    //   projectList = projectList.where((element) => element.four_bhk).toList();
    // }

      // Builders
      if (filters.appliedFilter.selectedBuilderId
          .where((element) => element != 0)
          .toList()
          .isNotEmpty &&
          filters.appliedFilter.selectedBuilderId
              .where((element) => element == 0)
              .toList()
              .isEmpty) {
        projectList = projectList
            .where((element) =>
            filters.appliedFilter.selectedBuilderId
                .contains(element.builder_id))
            .toList();
      }

      if (filters.appliedFilter.selectedBuilderId
          .where((element) => element == 0)
          .toList()
          .isNotEmpty &&
          filters.appliedFilter.selectedBuilderId
              .where((element) => element != 0)
              .toList()
              .isEmpty) {
        projectList =
            projectList.where((element) => element.builder_id == 0).toList();
      }

      if (filters.appliedFilter.selectedBuilderId
          .where((element) => element == 0)
          .toList()
          .isNotEmpty &&
          filters.appliedFilter.selectedBuilderId
              .where((element) => element != 0)
              .toList()
              .isNotEmpty) {
        projectList = projectList
            .where((element) =>
            filters.appliedFilter.selectedBuilderId
                .contains(element.builder_id))
            .toList();
      }

    return projectList;
  }



  @override
  dispose() {
    selectedPlace.close();
    super.dispose();
  }
}
