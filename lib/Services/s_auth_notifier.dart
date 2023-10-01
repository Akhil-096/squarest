import 'package:squarest/Services/s_user_profile_notifier.dart';
import 'package:squarest/Views/v_login.dart';
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/s_resale_property_notifier.dart';
import 'dart:io';

class AuthNotifier with ChangeNotifier {
  FirebaseAuth auth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn();
  GoogleSignInAccount? user;
  String verificationCode = '';
  final phoneController = TextEditingController();

  googleLogin(BuildContext context, LoginScreenState loginScreenState) async {
    final googleUser = await googleSignIn.signIn();
    if (!loginScreenState.mounted) return;
    // final userProfileModelNotifier = Provider.of<UserProfileModel>(context, listen: false);
    final userProfileNotifier =
        Provider.of<UserProfileNotifier>(context, listen: false);
    final resalePropertyNotifier =
        Provider.of<ResalePropertyNotifier>(context, listen: false);

    if (googleUser == null) return;
    user = googleUser;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await auth.signInWithCredential(credential).then((value) async {
      Fluttertoast.showToast(
        msg: 'You have been logged in successfully.',
        backgroundColor: Platform.isAndroid ? Colors.white : CupertinoColors.white,
        textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
      );
    });
    if (!loginScreenState.mounted) return;
    userProfileNotifier
        .getUser(context, (FirebaseAuth.instance.currentUser?.uid).toString(),
            loginScreenState)
        .then((value) => userProfileNotifier.setIsBottomNavVisibleToTrue());
    resalePropertyNotifier.getMemPlans(context);
    if (FirebaseAuth.instance.currentUser?.uid != null &&
        userProfileNotifier.userProfileModel.firebase_user_id == null) {
      userProfileNotifier.setIsBottomNavVisibleToFalse();
    }
    Navigator.of(context).pop();
    notifyListeners();
  }

  verifyPhoneNoForLogin(String phoneNo, BuildContext context,
      bool isAccountScreen, bool isComingFromJoinNow, bool isComingFromBookAVisit, bool isComingFromHomeLoan, bool isComingFromKnowMore, State myState) async {
    final userProfileNotifier =
        Provider.of<UserProfileNotifier>(context, listen: false);
    final resalePropertyNotifier =
        Provider.of<ResalePropertyNotifier>(context, listen: false);
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91$phoneNo',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((value) async {
            if (value.user != null) {
                if (isComingFromJoinNow || isComingFromHomeLoan) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                } else if(isComingFromKnowMore) {
                  userProfileNotifier
                      .getUser(
                      context,
                      (FirebaseAuth.instance.currentUser?.uid)
                          .toString(),
                      myState)
                      .then((value) => userProfileNotifier
                      .setIsBottomNavVisibleToTrue());
                  resalePropertyNotifier.getMemPlans(context);
                  if (FirebaseAuth.instance.currentUser?.uid !=
                      null &&
                      (userProfileNotifier.userProfileModel
                          .firebase_user_id ==
                          null ||
                          userProfileNotifier.userProfileModel
                              .firebase_user_id!.isEmpty)) {
                    userProfileNotifier
                        .setIsBottomNavVisibleToFalse();
                  }
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                } else if (isAccountScreen) {
                  userProfileNotifier
                      .getUser(
                          context,
                          (FirebaseAuth.instance.currentUser?.uid).toString(),
                          myState)
                      .then((value) =>
                          userProfileNotifier.setIsBottomNavVisibleToTrue());
                  resalePropertyNotifier.getMemPlans(context);
                  if (FirebaseAuth.instance.currentUser?.uid != null &&
                      userProfileNotifier.userProfileModel.firebase_user_id ==
                          null) {
                    userProfileNotifier.setIsBottomNavVisibleToFalse();
                  }
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                } else if (isComingFromBookAVisit) {
                  Navigator.of(context).pop();
                } else {
                AutoRouter.of(context).popUntilRouteWithName('/');
                AutoRouter.of(context).pushNamed('/');
              }
            }
            Fluttertoast.showToast(
              msg: 'You have been logged in successfully.',
              backgroundColor: Platform.isAndroid ? Colors.white : CupertinoColors.white,
              textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
            );
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.message!)));
        },
        codeSent: (String? verificationId, int? resendToken) {
          verificationCode = verificationId!;
          Fluttertoast.showToast(
            msg: 'Awaiting to receive OTP',
            backgroundColor: Platform.isAndroid ? Colors.white : CupertinoColors.white,
            textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
          );
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          verificationCode = verificationID;
        },
        timeout: const Duration(seconds: 30));
    notifyListeners();
  }

  verifyPhoneNoForHomeLoan(String phoneNo, BuildContext context) async {
    final navigator = Navigator.of(context);
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91$phoneNo',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.currentUser
              ?.updatePhoneNumber(credential);
          navigator.pop();
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.message!)));
        },
        codeSent: (String? verificationId, int? resendToken) {
          verificationCode = verificationId!;
          Fluttertoast.showToast(
            msg: 'Awaiting to receive OTP',
            backgroundColor: Platform.isAndroid ? Colors.white : CupertinoColors.white,
            textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
          );
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          verificationCode = verificationID;
        },
        timeout: const Duration(seconds: 30));
    notifyListeners();
  }

  Future<bool> checkIfPhoneNoSubmitted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isPhoneNoSubmitted = (prefs.getBool('isPhoneNoSubmitted') ?? false);
    return isPhoneNoSubmitted;
  }

  Future<String> getSavedPhoneNo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final getPhoneNo = (prefs.getString('homeLoanPhoneNo') ?? '');
    return getPhoneNo;
  }


  saveSubmittedPhoneNo(String phoneNo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPhoneNoSubmitted', true);
    await prefs.setString('homeLoanPhoneNo', phoneNo);
    notifyListeners();
  }

  removeSubmittedPhoneNoOnLogOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('homeLoanPhoneNo');
    prefs.remove('isPhoneNoSubmitted');
    notifyListeners();
  }

  removeSubmittedProfileOnLogOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('isProfileSubmitted');
    notifyListeners();
  }
}
