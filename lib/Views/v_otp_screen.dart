import 'dart:io';

import 'package:squarest/Services/s_auth_notifier.dart';
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import '../Services/s_resale_property_notifier.dart';
import '../Services/s_user_profile_notifier.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNo;
  final bool isComingFromLogin;
  final bool isComingFromJoinNow;
  final bool isComingFromBookAVisit;
  final bool isAccountScreen;
  final bool isComingFromHomeLoan;
  final bool isComingFromKnowMore;

  const OtpScreen(
      {Key? key,
      required this.phoneNo,
      required this.isComingFromLogin,
      required this.isComingFromJoinNow,
      required this.isComingFromBookAVisit,
      required this.isAccountScreen,
      required this.isComingFromHomeLoan,
        required this.isComingFromKnowMore
      })
      : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final controller = TextEditingController();
  final focusNode = FocusNode();
  bool isInvalidOtp = false;
  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    if (widget.isComingFromLogin) {
      authNotifier.verifyPhoneNoForLogin(
          widget.phoneNo,
          context,
          widget.isAccountScreen,
          widget.isComingFromJoinNow,
          widget.isComingFromBookAVisit,
          widget.isComingFromHomeLoan,
          widget.isComingFromKnowMore,
          this);
    } else {
      authNotifier.verifyPhoneNoForHomeLoan(widget.phoneNo, context);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  bool showError = false;

  @override
  Widget build(BuildContext context) {
    final authNotifier = Provider.of<AuthNotifier>(context);
    final navigator = Navigator.of(context);
    final userProfileNotifier = Provider.of<UserProfileNotifier>(context);
    final resalePropertyNotifier = Provider.of<ResalePropertyNotifier>(context);
    const length = 6;
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: Platform.isAndroid ? PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: AppBar(
            backgroundColor: (MediaQuery.of(context).platformBrightness ==
                Brightness.dark)
                ? Colors.grey[900]
                : Colors.white,
          ),
        ) : CupertinoNavigationBar(
          backgroundColor: (MediaQuery.of(context).platformBrightness ==
              Brightness.dark)
              ? Colors.grey[900]
              : CupertinoColors.white,
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 20),
              child: const Center(
                child: Text(
                  'Verification',
                  style: TextStyle(fontSize: 30),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text('Enter the code sent to +91-${widget.phoneNo}'),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.only(left: 20, right: 20),
              height: 68,
              child: Pinput(
                length: length,
                controller: controller,
                focusNode: focusNode,
                androidSmsAutofillMethod:
                    AndroidSmsAutofillMethod.smsRetrieverApi,
                closeKeyboardWhenCompleted: false,
                onSubmitted: widget.isComingFromLogin
                    ? (pin) async {
                        try {
                          await FirebaseAuth.instance
                              .signInWithCredential(
                                  PhoneAuthProvider.credential(
                                      verificationId:
                                          authNotifier.verificationCode,
                                      smsCode: pin))
                              .then((value) async {
                            setState(() {
                              isInvalidOtp = false;
                            });
                            if (value.user != null) {
                              if (widget.isComingFromHomeLoan ||
                                  widget.isComingFromJoinNow) {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              } else if(widget.isComingFromBookAVisit) {
                                Navigator.of(context).pop();
                              } else if (widget.isAccountScreen) {
                                userProfileNotifier
                                    .getUser(
                                        context,
                                        (FirebaseAuth.instance.currentUser?.uid)
                                            .toString(),
                                        this)
                                    .then((value) => userProfileNotifier
                                        .setIsBottomNavVisibleToTrue());
                                resalePropertyNotifier.getMemPlans(context);
                                // likedProjectsNotifier.getLikedProjects(context, this);
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
                              } else if(widget.isComingFromKnowMore) {
                                userProfileNotifier
                                    .getUser(
                                    context,
                                    (FirebaseAuth.instance.currentUser?.uid)
                                        .toString(),
                                    this)
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
                              } else {
                                AutoRouter.of(context)
                                    .popUntilRouteWithName('/');
                                AutoRouter.of(context).pushNamed('/');
                              }
                            }
                            Fluttertoast.showToast(
                              msg: 'You have been logged in successfully.',
                              backgroundColor: Platform.isAndroid ? Colors.white : CupertinoColors.white,
                              textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
                            );
                          });

                        } catch (e) {
                          setState(() {
                            isInvalidOtp = true;
                          });
                        }
                      }
                    : (pin) async {
                        try {
                          await FirebaseAuth.instance.currentUser
                              ?.updatePhoneNumber(PhoneAuthProvider.credential(
                                  verificationId: authNotifier.verificationCode,
                                  smsCode: pin));
                          navigator.pop();
                        } catch (e) {
                          setState(() {
                            isInvalidOtp = true;
                          });
                        }
                      },
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            if (isInvalidOtp)
              Text(
                'Invalid OTP. Please try again',
                style: TextStyle(color: Platform.isAndroid ? Colors.red : CupertinoColors.systemRed),
              ),
          ],
        ),
      ),
    );
  }
}
