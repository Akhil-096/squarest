import 'package:squarest/Services/s_resale_property_service.dart';
import 'package:squarest/Services/s_user_profile_notifier.dart';
import 'package:squarest/Views/v_resale_property_card.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import '../Models/m_mem_plan.dart';
import '../Models/m_resale_property.dart';
import '../Services/s_liked_projects_notifier.dart';


class ResalePropertyNotifier with ChangeNotifier {
  bool isBottomSheetOpen = false;
  PersistentBottomSheetController? persistentBottomSheetController;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  ResalePropertyModel? propertyForBottomSheet;
  bool isLoading = false;
  bool isPlansLoading = false;
  ProductDetails? memPlan;

  // screen 1
  bool isFlatSelected = true;
  bool isBungalowSelected = false;
  bool isWaterSelected = false;
  bool isLiftSelected = false;
  bool isPowerSelected = false;
  bool isSecuritySelected = false;
  bool isClubSelected = false;
  bool isSwimmingPoolSelected = false;
  bool isParkSelected = false;
  bool isGasSelected = false;
  final floorMinTextController = TextEditingController();
  final floorMaxTextController = TextEditingController();
  final constructionAgeTextController = TextEditingController();
  final buildingNameTextController = TextEditingController();
  final descriptionTextController = TextEditingController();
  ResalePropertyService resalePropertyService = ResalePropertyService();
  double lat = 0.0;
  double lng = 0.0;
  List<int> amenities = [];
  int bhk = 2;

  // screen 2
  bool isOwnerSelected = true;
  bool isAgentSelected = false;
  bool oneBHK = false;
  bool twoBHK = true;
  bool threeBHK = false;
  bool fourPlusBHK = false;
  final areaTextController = TextEditingController();
  final saleTextController = TextEditingController();



  // list screen
  List<ResalePropertyModel> propertyList = [];

  List<ResalePropertyModel> allPropertyList = [];

  List<ResalePropertyModel> get allPropertyItems {
    return [...allPropertyList];
  }

  List<ResalePropertyModel> get propertyItems {
    return [...propertyList];
  }

  List<MemPlan> memPlans = [];

  closeBottomSheet() {
    if (persistentBottomSheetController != null) {
      persistentBottomSheetController?.close();
      persistentBottomSheetController?.closed.whenComplete(() {
        persistentBottomSheetController = null;
        isBottomSheetOpen = false;
      });
    }
    notifyListeners();
  }

  openBottomSheet(BuildContext context, bool isComingFromMapOrList){
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

  Future<bool> onWillPop(BuildContext context) {
    if(isBottomSheetOpen){
      closeBottomSheet();
      // print(isBottomSheetOpen);
      return Future.value(false);
    } else {
      Navigator.of(context).pop();
      return Future.value(true);
    }

  }

  Future<void> insertResaleProperty(BuildContext context, String address, double lat, double lng, bool type, String name, int floor, int totalFloors, int age, List<int> amenities, double area, int bhk, double price, String description, String locality, String city, int pincode, bool posted_by) async {
    final userProfileNotifier = Provider.of<UserProfileNotifier>(context, listen: false);
    ResalePropertyModel resalePropertyModel = ResalePropertyModel(id: 0, address: address, lat: lat, lng: lng, type: type, name: name, floor: floor, total_floors: totalFloors, age: age, amenities: amenities, area: area, bhk: bhk, price: price, description: description, locality: locality, city: city, pincode: pincode, posted_by: posted_by, posted_by_user_id: userProfileNotifier.userProfileModel.id,);
    await resalePropertyService.insertProperty(resalePropertyModel);
    notifyListeners();
  }

  Future<void> getAllResaleProperties(BuildContext context, State state) async {
    isLoading = true;
    allPropertyList = await resalePropertyService.getAllResaleProperties().whenComplete(() {
      isLoading = false;
    });
    if(!state.mounted) return;
    loadResaleLikes(context);
    notifyListeners();
  }

  Future<void> getResaleProperties(BuildContext context, State state) async {
    final userProfileNotifier = Provider.of<UserProfileNotifier>(context, listen: false);
    isLoading = true;
    propertyList = await resalePropertyService.getResaleProperties(userProfileNotifier.userProfileModel.id).whenComplete(() {
      isLoading = false;
    });
    if(!state.mounted) return;
    loadResaleLikes(context);
    notifyListeners();
  }

  Future<void> updateResaleProperty(BuildContext context, int id, String address, double lat, double lng, bool type, String name, int floor, int totalFloors, int age, List<int> amenities, double area, int bhk, double price, String description, String locality, String city, int pincode, bool posted_by) async {
    final userProfileNotifier = Provider.of<UserProfileNotifier>(context, listen: false);
    ResalePropertyModel resalePropertyModel = ResalePropertyModel(id: id, address: address, lat: lat, lng: lng, type: type, name: name, floor: floor, total_floors: totalFloors, age: age, amenities: amenities, area: area, bhk: bhk, price: price, description: description, locality: locality, city: city, pincode: pincode, posted_by: posted_by, posted_by_user_id: userProfileNotifier.userProfileModel.id);
    await resalePropertyService.updateResaleProperty(resalePropertyModel);
    notifyListeners();
  }

  loadResaleLikes(BuildContext context)async{
    Future.delayed(const Duration(milliseconds: 500));
    final likedProjectsNotifier =
    Provider.of<LikedProjectsNotifier>(context, listen: false);
    List<ResalePropertyModel> currentLikedResaleProjects = [];
    for (int i = 0; i < likedProjectsNotifier.likedResalePropertyList.length; i++) {
      if(propertyList.isNotEmpty){
        currentLikedResaleProjects = currentLikedResaleProjects..addAll(propertyList.where((element) => likedProjectsNotifier.likedResalePropertyList[i].id == element.id).toList());
      }
    }
    if(propertyList.isNotEmpty){
      for(int i = 0; i < currentLikedResaleProjects.length; i++){
        propertyList = propertyList..firstWhere((element) => element.id == currentLikedResaleProjects[i].id).isLiked = true;
      }
    }
    notifyListeners();
  }

  clearMemPlans() {
    memPlans.clear();
    notifyListeners();
  }

  Future<void> insertMemPlan(BuildContext context, String planType, int duration, double amount, DateTime createdDate, DateTime endingDate) async {
    final userProfileNotifier = Provider.of<UserProfileNotifier>(context, listen: false);
    MemPlan memPlan = MemPlan(user_id: userProfileNotifier.userProfileModel.id, mem_plan_type: planType, mem_plan_durn: duration,mem_plan_amt: amount, created_on: createdDate, ending_on: endingDate);
    await resalePropertyService.insertMemPlan(memPlan);
    notifyListeners();
  }

  Future<void> getMemPlans(BuildContext context) async {
    final userProfileNotifier = Provider.of<UserProfileNotifier>(context, listen: false);
    isPlansLoading = true;
    memPlans = await resalePropertyService.getMemPlans(userProfileNotifier.userProfileModel.id).whenComplete(() {
      isPlansLoading = false;
    });
    notifyListeners();
  }

}