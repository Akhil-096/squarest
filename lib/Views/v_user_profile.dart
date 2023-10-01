import 'dart:io';

import 'package:squarest/Views/v_update_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../Services/s_auth_notifier.dart';
import '../Services/s_liked_projects_notifier.dart';
import '../Services/s_user_profile_notifier.dart';
import '../Utils/u_custom_styles.dart';
import 'package:squarest/Services/s_resale_property_notifier.dart';

class UserProfile extends StatefulWidget {
  final bool isComingFromAccountScreen;

  const UserProfile({required this.isComingFromAccountScreen, Key? key})
      : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final _form = GlobalKey<FormState>();
  bool isFirstNameLoading = false;
  bool isLastNameLoading = false;
  bool isEmailLoading = false;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print(FirebaseAuth.instance.currentUser?.uid);
    }
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = Provider.of<AuthNotifier>(context);
    final userProfileNotifier = Provider.of<UserProfileNotifier>(context);
    final likedProjectsNotifier = Provider.of<LikedProjectsNotifier>(context);
    final resalePropertyNotifier = Provider.of<ResalePropertyNotifier>(context);
    final email = FirebaseAuth.instance.currentUser?.email;
    final phoneNo = FirebaseAuth.instance.currentUser?.phoneNumber;
    return Scaffold(
      appBar: Platform.isAndroid ? AppBar(
        backgroundColor:
        (MediaQuery.of(context).platformBrightness == Brightness.dark)
            ? Colors.grey[900]
            : Colors.white,
        title: Text(
          'My Profile', style: CustomTextStyles.getTitle(null, (MediaQuery.of(context).platformBrightness ==
            Brightness.dark)
            ? Colors.white
            : Colors.black, null, 20),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              authNotifier.googleSignIn.disconnect();
              await authNotifier.googleSignIn.signOut();
              await FirebaseAuth.instance.signOut().then((value) async {
                authNotifier.removeSubmittedPhoneNoOnLogOut();
                authNotifier.removeSubmittedProfileOnLogOut();
                userProfileNotifier.setUserProfileModelToNull();
                // likedProjectsNotifier.setLikedProjectsModelToNull();
                likedProjectsNotifier.likedProjectsList.clear();
                likedProjectsNotifier.likedResalePropertyList.clear();
                // likedProjectsNotifier.setIsLikedToFalse();
                // likedProjectsNotifier.setIsResaleLikedToFalse();
                resalePropertyNotifier.clearMemPlans();
                // likedProjectsNotifier.getLikedProjects(context);
                // authNotifier.phoneController.clear();
                Fluttertoast.showToast(
                  msg: 'You have been logged out successfully.',
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                ).then((value) {
                  Navigator.of(context).pop();
                });
              });
            },
            child: Container(
              margin: const EdgeInsets.only(top: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_outlined, size: 20,),
                  Text('Logout', style: CustomTextStyles.getTitle(null, (MediaQuery.of(context).platformBrightness ==
                      Brightness.dark)
                      ? Colors.white
                      : Colors.black, null, null),),
                ],
              ),
            ),
          )
        ],
      ) : PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: SizedBox(
          height: 100,
          child: CupertinoNavigationBar(
            backgroundColor:
            (MediaQuery.of(context).platformBrightness == Brightness.dark)
                ? Colors.grey[900]
                : CupertinoColors.white,
            padding: EdgeInsetsDirectional.zero,
            middle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Profile', style: CustomTextStyles.getTitle(null, (MediaQuery.of(context).platformBrightness ==
                    Brightness.dark)
                    ? CupertinoColors.white
                    : CupertinoColors.black, null, 20),
                ),
                GestureDetector(
                  onTap: () async {
                    authNotifier.googleSignIn.disconnect();
                    await authNotifier.googleSignIn.signOut();
                    await FirebaseAuth.instance.signOut().then((value) async {
                      authNotifier.removeSubmittedPhoneNoOnLogOut();
                      authNotifier.removeSubmittedProfileOnLogOut();
                      userProfileNotifier.setUserProfileModelToNull();
                      likedProjectsNotifier.likedProjectsList.clear();
                      likedProjectsNotifier.likedResalePropertyList.clear();
                      resalePropertyNotifier.clearMemPlans();
                      Fluttertoast.showToast(
                        msg: 'You have been logged out successfully.',
                        backgroundColor: CupertinoColors.white,
                        textColor: CupertinoColors.black,
                      ).then((value) {
                        Navigator.of(context).pop();
                      });
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout_outlined, size: 20,),
                      Text('Logout', style: CustomTextStyles.getTitle(null, (MediaQuery.of(context).platformBrightness ==
                          Brightness.dark)
                          ? CupertinoColors.white
                          : CupertinoColors.black, null, 12),),
                    ],
                  ),

                ),
              ],
            ),
            // trailing: Container(
            //   margin: const EdgeInsets.only(right: 10),
            //   child: GestureDetector(
            //     onTap: () async {
            //       authNotifier.googleSignIn.disconnect();
            //       await authNotifier.googleSignIn.signOut();
            //       await FirebaseAuth.instance.signOut().then((value) async {
            //         authNotifier.removeSubmittedPhoneNoOnLogOut();
            //         authNotifier.removeSubmittedProfileOnLogOut();
            //         userProfileNotifier.setUserProfileModelToNull();
            //         likedProjectsNotifier.likedProjectsList.clear();
            //         likedProjectsNotifier.likedResalePropertyList.clear();
            //         resalePropertyNotifier.clearMemPlans();
            //         Fluttertoast.showToast(
            //           msg: 'You have been logged out successfully.',
            //           backgroundColor: CupertinoColors.white,
            //           textColor: CupertinoColors.black,
            //         ).then((value) {
            //           Navigator.of(context).pop();
            //         });
            //       });
            //     },
            //     child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.center,
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           const Icon(Icons.logout_outlined, size: 20,),
            //           Text('Logout', style: CustomTextStyles.getTitle(null, (MediaQuery.of(context).platformBrightness ==
            //               Brightness.dark)
            //               ? CupertinoColors.white
            //               : CupertinoColors.black, null, 12),),
            //         ],
            //       ),
            //
            //   ),
            // ),
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<dynamic>(
          future: Future.wait([userProfileNotifier.getFirstName(), userProfileNotifier.getLastName(), userProfileNotifier.getEmail()]),
          builder: (ctx, snapshot) {
                if(snapshot.connectionState == ConnectionState.done){
                  return SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.only(top: 100, right: 10),
                      child: Form(
                          key: _form,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: const Text(
                                        'First Name',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      )),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Container(
                                            alignment: Alignment.centerLeft,
                                            height: 60,
                                            width: 500,
                                            decoration: BoxDecoration(
                                                border: Border.all(color: (MediaQuery.of(context).platformBrightness == Brightness.dark)
                                                    ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                                    : Platform.isAndroid ? Colors.black : CupertinoColors.black,),
                                                borderRadius: const BorderRadius.all(
                                                    Radius.circular(15))),
                                            margin: const EdgeInsets.only(left: 10),
                                            padding: const EdgeInsets.only(left: 10),
                                            child: Text(snapshot.data[0])),
                                      ),
                                      IconButton(
                                        icon: Icon(Platform.isAndroid ? Icons.edit : CupertinoIcons.pencil),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                              builder: (ctx) => const UpdateUserProfile(
                                                id: '1',
                                              )));
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: const Text(
                                        'Last Name',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      )),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Container(
                                            alignment: Alignment.centerLeft,
                                            height: 60,
                                            width: 500,
                                            decoration: BoxDecoration(
                                                border: Border.all(color: (MediaQuery.of(context).platformBrightness == Brightness.dark)
                                                    ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                                    : Platform.isAndroid ? Colors.black : CupertinoColors.black,),
                                                borderRadius: const BorderRadius.all(
                                                    Radius.circular(10))),
                                            margin: const EdgeInsets.only(left: 10),
                                            padding: const EdgeInsets.only(left: 10),
                                            child: Text(snapshot.data[1])),
                                      ),
                                      IconButton(
                                        icon: Icon(Platform.isAndroid ? Icons.edit : CupertinoIcons.pencil),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                              builder: (ctx) => const UpdateUserProfile(
                                                id: '2',
                                              )));
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: const Text(
                                        'Email',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      )),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Container(
                                            alignment: Alignment.centerLeft,
                                            height: 60,
                                            width: 500,
                                            decoration: BoxDecoration(
                                                border: Border.all(color: (MediaQuery.of(context).platformBrightness == Brightness.dark)
                                                    ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                                    : Platform.isAndroid ? Colors.black : CupertinoColors.black,),
                                                borderRadius: const BorderRadius.all(
                                                    Radius.circular(10))),
                                            margin: const EdgeInsets.only(left: 10),
                                            padding: const EdgeInsets.only(left: 10),
                                            child: Text(snapshot.data[2])),
                                      ),
                                      (email == null) ?
                                      IconButton(
                                        icon: Icon(Platform.isAndroid ? Icons.edit : CupertinoIcons.pencil),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                              builder: (ctx) =>
                                              const UpdateUserProfile(
                                                id: '3',
                                              )));
                                        },
                                      ) : const SizedBox(
                                        width: 50,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: const Text(
                                        'Phone number',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      )),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Container(
                                            alignment: Alignment.centerLeft,
                                            height: 60,
                                            width: 500,
                                            decoration: BoxDecoration(
                                                border: Border.all(color: (MediaQuery.of(context).platformBrightness == Brightness.dark)
                                                    ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                                    : Platform.isAndroid ? Colors.black : CupertinoColors.black,),
                                                borderRadius: const BorderRadius.all(
                                                    Radius.circular(10))),
                                            margin: const EdgeInsets.only(left: 10),
                                            padding: const EdgeInsets.only(left: 10),
                                            child: Text((userProfileNotifier
                                                .userProfileModel.phone_number ?? '')
                                                .toString())),
                                      ),
                                      (phoneNo == null) ?
                                      IconButton(
                                        icon: Icon(Platform.isAndroid ? Icons.edit : CupertinoIcons.pencil),
                                        onPressed: () {
                                          Navigator.of(context).push(MaterialPageRoute(
                                              builder: (ctx) => const UpdateUserProfile(
                                                id: '4',
                                              )));
                                        },
                                      ) : const SizedBox(
                                        width: 50,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          )),
                    ),
                  );
                } else {
                  return const UserProfileShimmer();
                }
          }
        ),
      ),
    );
  }
  getUser() async {
    final userProfileNotifier =
    Provider.of<UserProfileNotifier>(context, listen: false);
    userProfileNotifier.getUser(
        context, (FirebaseAuth.instance.currentUser?.uid).toString(), this);
  }
}

class UserProfileShimmer extends StatefulWidget {
  const UserProfileShimmer({Key? key}) : super(key: key);

  @override
  State<UserProfileShimmer> createState() => _UserProfileShimmerState();
}

class _UserProfileShimmerState extends State<UserProfileShimmer> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Shimmer.fromColors(
        baseColor: (MediaQuery.of(context).platformBrightness ==
            Brightness.dark)
            ? Colors.grey[700]!
            : Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          itemBuilder: (_, __) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 130, left: 10, right: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: (width < 360 || height < 600) ? 250 : 300,
                            height: 60,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.grey[300]!
                            ),
                          ),
                          Icon(Platform.isAndroid ? Icons.edit : CupertinoIcons.pencil),
                        ],
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: (width < 360 || height < 600) ? 250 : 300,
                            height: 60,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.grey[300]!
                            ),
                          ),
                          Icon(Platform.isAndroid ? Icons.edit : CupertinoIcons.pencil),
                        ],
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: (width < 360 || height < 600) ? 250 : 300,
                            height: 60,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.grey[300]!
                            ),
                          ),
                          Icon(Platform.isAndroid ? Icons.edit : CupertinoIcons.pencil),
                        ],
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: (width < 360 || height < 600) ? 250 : 300,
                            height: 60,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.grey[300]!
                            ),
                          ),
                          Icon(Platform.isAndroid ? Icons.edit : CupertinoIcons.pencil),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          itemCount: 1,
        ),
      ),
    );
  }
}
