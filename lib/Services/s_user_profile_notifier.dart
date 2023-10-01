import 'package:squarest/Services/s_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import '../Models/m_user.dart';

class UserProfileNotifier with ChangeNotifier {

  double progress = 0;
  bool isLoading = false;

  // setup profile
  UserService userService = UserService();
  bool isBottomNavVisible = true;
  UserProfileModel userProfileModel = UserProfileModel(id: 0, first_name: '', last_name: '', phone_number: 0, email_id: '');

  // setup profile
  Future<void> createUser(String firstName, String lastName, String? phoneNo, String emailId, BuildContext context) async {
    UserProfileModel userProfile = UserProfileModel(id: 0, first_name: firstName, last_name: lastName, phone_number: (phoneNo != null || phoneNo!.isNotEmpty) ? int.parse(phoneNo.replaceAll("+91", '')) : null, email_id: emailId, firebase_user_id: (FirebaseAuth.instance.currentUser?.uid).toString());
    await userService.createUser(userProfile, context);
    notifyListeners();
  }

  Future<void> updateUser(BuildContext context, String firstName, String lastName, String emailId, int? phoneNo) async {
    UserProfileModel userProfile = UserProfileModel(id: userProfileModel.id, first_name: firstName, last_name: lastName, email_id: emailId, firebase_user_id: (userProfileModel.firebase_user_id).toString(), phone_number: phoneNo);
    await userService.updateUser(userProfile);
    notifyListeners();
  }

  Future<void> getUser(BuildContext context, String userId, State myState) async {
    isLoading = true;
    userProfileModel = await userService.getUser(userId).whenComplete(() {
      isLoading = false;
      notifyListeners();
    });
    if(!myState.mounted) return;
    setUid(context, (userProfileModel.firebase_user_id).toString());
    notifyListeners();
  }


  Future<String?> getCurrentUserId(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final String? uId = userProfileModel.firebase_user_id;
    return uId;
  }

  Future<String?> getFirstName() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final String firstName = (userProfileModel.first_name).toString();
    return firstName;
  }

  Future<String?> getLastName() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final String lastName = (userProfileModel.last_name).toString();
    return lastName;
  }

  Future<String?> getEmail() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final String emailId = (userProfileModel.email_id).toString();
    return emailId;
  }

  //
  setUid(BuildContext context, String userId){
    userProfileModel.firebase_user_id = userId;
    notifyListeners();
  }

  setUserProfileModelToNull(){
    // final userProfileModelNotifier = Provider.of<UserProfileModel>(context, listen: false);
    userProfileModel.first_name = null;
    userProfileModel.last_name = null;
    userProfileModel.email_id = null;
    userProfileModel.firebase_user_id = null;
    userProfileModel.phone_number = null;
    notifyListeners();
  }

  setIsBottomNavVisibleToTrue() {
    isBottomNavVisible = true;
    notifyListeners();
  }

  setIsBottomNavVisibleToFalse() {
    isBottomNavVisible = false;
    notifyListeners();
  }

  Future<bool> getIsBottomNavVisible() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return isBottomNavVisible;
  }

}