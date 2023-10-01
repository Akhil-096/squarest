import 'dart:io';
import 'package:squarest/Utils/u_constants.dart';
import 'package:squarest/Views/v_otp_screen.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';
import '../Services/s_auth_notifier.dart';
import 'package:flutter/cupertino.dart';
import '../Services/s_user_profile_notifier.dart';
import '../Utils/u_custom_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  final bool isAccountScreen;
  final bool isComingFromHomeLoan;
  final bool isComingFromJoinNow;
  final bool isComingFromKnowMore;

  const LoginScreen(
      {required this.isAccountScreen,
        required this.isComingFromHomeLoan,
        required this.isComingFromJoinNow,
        required this.isComingFromKnowMore,
        Key? key})
      : super(key: key);

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool isDisabledButton = true;
  bool isCheckNumber = false;
  var phoneNoController = TextEditingController();
  final form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthNotifier>(context);
    final userProfileNotifier = Provider.of<UserProfileNotifier>(context);

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        // backgroundColor: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? Colors.grey[900] : Platform.isAndroid ? Colors.white : CupertinoColors.white,
        appBar: widget.isAccountScreen ? Platform.isAndroid ? PreferredSize(
            preferredSize: const Size.fromHeight(50),
        child: AppBar(
          backgroundColor: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? Colors.grey[900] : Colors.white,
          scrolledUnderElevation: 0.0,
        )) : CupertinoNavigationBar(
          backgroundColor: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? Colors.grey[900] : CupertinoColors.white,
        ) : null,
        body: SafeArea(
          child: Form(
            key: form,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  !widget.isAccountScreen
                      ? IconButton(
                      onPressed: widget.isComingFromHomeLoan ||
                          widget.isComingFromJoinNow
                          ? () {
                        Navigator.of(context).pop();
                      }
                          : () {
                        AutoRouter.of(context)
                            .popUntilRouteWithName('/');
                        AutoRouter.of(context).pushNamed('/');
                      },
                      icon: Icon(
                        Platform.isAndroid ? Icons.clear : CupertinoIcons.clear,
                      ))
                      : const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding:
                    EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05, left: 5, right: 5, bottom: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          // margin: const EdgeInsets.only(top: 5),
                          width: 100,
                          height: 100,
                          child: FittedBox(
                              fit: BoxFit.cover,
                              child:
                              Image.asset('assets/images/squarest.png')),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text("Log in or sign up",
                            style: CustomTextStyles.getTitle(
                                null,
                                (MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark)
                                    ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                    : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                null,
                                20)),
                        const SizedBox(height: 2.5),
                        Padding(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          child: Divider(
                            color: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? Colors.grey[700] : Colors.grey[300]!,
                          ),
                        ),
                        const SizedBox(height: 2.5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(left: 5),
                              child: Text("Buy",
                                  maxLines: 2,
                                  style: CustomTextStyles.getTitle(
                                      null,
                                      (MediaQuery.of(context)
                                          .platformBrightness ==
                                          Brightness.dark)
                                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                          : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                      null,
                                      20)),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 15,
                                ),
                                Icon(
                                  Platform.isAndroid ? Icons.check : CupertinoIcons.checkmark_alt,
                                  size: 20,
                                  color: Platform.isAndroid ? Colors.green : CupertinoColors.activeGreen,
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                const Text("Save your favourite properties",
                                    style: TextStyle(
                                      fontSize: 15,
                                    )),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 15,
                                ),
                                Icon(
                                  Platform.isAndroid ? Icons.check : CupertinoIcons.checkmark_alt,
                                  size: 20,
                                  color: Platform.isAndroid ? Colors.green : CupertinoColors.activeGreen,
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                const Text(
                                    "Book a site visit",
                                    style: TextStyle(
                                      fontSize: 15,
                                    )),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 15,
                                ),
                                Icon(
                                  Platform.isAndroid ? Icons.check : CupertinoIcons.checkmark_alt,
                                  size: 20,
                                  color: Platform.isAndroid ? Colors.green : CupertinoColors.activeGreen,
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                const Text("Apply for Home Loan",
                                    style: TextStyle(
                                      fontSize: 15,
                                    )),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(left: 5),
                              child: Text("Sell",
                                  maxLines: 2,
                                  style: CustomTextStyles.getTitle(
                                      null,
                                      (MediaQuery.of(context)
                                          .platformBrightness ==
                                          Brightness.dark)
                                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                          : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                                      null,
                                      20)),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 15,
                                ),
                                Icon(
                                  Platform.isAndroid ? Icons.check : CupertinoIcons.checkmark_alt,
                                  size: 20,
                                  color: Platform.isAndroid ? Colors.green : CupertinoColors.activeGreen,
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                const Text("Post your property",
                                    style: TextStyle(
                                      fontSize: 15,
                                    )),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text('FREE',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Platform.isAndroid ? Colors.pink : CupertinoColors.systemPink,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        if(Platform.isAndroid)
                        Container(
                            padding: const EdgeInsets.only(left: 5, right: 5),
                            child: TextFormField(
                              controller: phoneNoController,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              validator: (value) {
                                if (int.parse(value!.length.toString()) < 10) {
                                  return 'Enter 10 digits';
                                }
                                return null;
                              },
                              maxLength: 10,
                              showCursor: true,
                              onChanged: (value) {
                                if (int.parse(value.length.toString()) < 10) {
                                  form.currentState?.validate();
                                  setState(() {
                                    isDisabledButton = true;
                                    isCheckNumber = false;
                                  });
                                }
                                if (int.parse(value.length.toString()) == 10) {
                                  form.currentState?.validate();
                                  setState(() {
                                    isDisabledButton = false;
                                    isCheckNumber = true;
                                  });
                                }
                              },
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  counterText: "",
                                  suffixIcon: Icon(
                                    Icons.check,
                                    color: isCheckNumber
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  hintText: "Enter 10 digit number",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                          ),
                        if(Platform.isIOS)
                        Container(
                          margin: const EdgeInsets.only(left: 5, right: 5),
                          decoration: BoxDecoration(
                        border: Border.all(
                            width: 1,
                            color: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? CupertinoColors.systemGrey : CupertinoColors.black
                        ),
                        borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                        Expanded(
                          child: CupertinoTextFormFieldRow(
                              padding: const EdgeInsetsDirectional.all(10),
                              controller: phoneNoController,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              validator: (value) {
                                if (int.parse(value!.length.toString()) < 10) {
                                  return 'Enter 10 digits';
                                }
                                return null;
                              },
                              style: TextStyle(color: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? CupertinoColors.white : CupertinoColors.black, fontSize: 18),
                              maxLength: 10,
                              showCursor: true,
                              onChanged: (value) {
                                if (int.parse(value.length.toString()) < 10) {
                                  form.currentState?.validate();
                                  setState(() {
                                    isDisabledButton = true;
                                    isCheckNumber = false;
                                  });
                                }
                                if (int.parse(value.length.toString()) == 10) {
                                  form.currentState?.validate();
                                  setState(() {
                                    isDisabledButton = false;
                                    isCheckNumber = true;
                                  });
                                }
                              },
                              placeholder: 'Enter 10 digit number',
                              keyboardType: TextInputType.number,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Icon(Platform.isAndroid ? Icons.check : CupertinoIcons.checkmark_alt, color: isCheckNumber
                              ? Platform.isAndroid ? Colors.green : CupertinoColors.activeGreen
                              : Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,),
                        ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        if(Platform.isAndroid)
                        Center(
                            child: SizedBox(
                              height: 60,
                              width: double.infinity,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    backgroundColor: globalColor),
                                onPressed: isDisabledButton
                                    ? () {
                                  if (phoneNoController
                                      .value.text.length <
                                      10) {
                                    form.currentState?.validate();
                                    setState(() {});
                                  }
                                }
                                    : () {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                      builder: (ctx) => OtpScreen(
                                        phoneNo: phoneNoController
                                            .text,
                                        isComingFromLogin: true,
                                        isAccountScreen: widget
                                            .isAccountScreen,
                                        isComingFromHomeLoan: widget
                                            .isComingFromHomeLoan,
                                        isComingFromJoinNow: widget
                                            .isComingFromJoinNow,
                                        isComingFromBookAVisit: false,
                                        isComingFromKnowMore: widget.isComingFromKnowMore,
                                      )));
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(top: 8, bottom: 8),
                                  child: Text("Continue",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15)),
                                ),
                              ),
                            ),
                          ),
                        if(Platform.isIOS)
                        Container(
                          margin: const EdgeInsets.only(left: 5, right: 5),
                          width: double.infinity,
                          child: CupertinoButton(
                            borderRadius: BorderRadius.circular(25),
                            color: globalColor,
                            onPressed: isDisabledButton
                                ? () {
                              if (phoneNoController
                                  .value.text.length <
                                  10) {
                                form.currentState?.validate();
                                setState(() {});
                              }
                            }
                                : () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                  builder: (ctx) => OtpScreen(
                                    phoneNo: phoneNoController
                                        .text,
                                    isComingFromLogin: true,
                                    isAccountScreen: widget
                                        .isAccountScreen,
                                    isComingFromHomeLoan: widget
                                        .isComingFromHomeLoan,
                                    isComingFromJoinNow: widget
                                        .isComingFromJoinNow,
                                    isComingFromBookAVisit: false,
                                    isComingFromKnowMore: widget.isComingFromKnowMore,
                                  )));
                            },
                            child: const Text("Continue",
                                style: TextStyle(
                                    color: CupertinoColors.white, fontSize: 15)),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          child: Row(children: <Widget>[
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5, right: 5),
                                child: Divider(
                                  color: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? Colors.grey[700] : Colors.grey[300]!,
                                ),
                              ),
                            ),
                            const Text("or"),
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5, right: 5),
                                child: Divider(
                                  color: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? Colors.grey[700] : Colors.grey[300]!,
                                ),
                              ),
                            ),
                          ]),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          width: double.infinity,
                          height: 50,
                          child: SignInButton(
                            Buttons.Google,
                            onPressed: () {
                              authProvider
                                  .googleLogin(context, this)
                                  .then((_) async {
                                if (widget.isComingFromHomeLoan ||
                                    widget.isComingFromJoinNow) {
                                  if (widget.isComingFromJoinNow) {
                                    userProfileNotifier
                                        .getUser(
                                        context,
                                        (FirebaseAuth.instance.currentUser
                                            ?.uid)
                                            .toString(),
                                        this)
                                        .then((_) {
                                      userProfileNotifier
                                          .setIsBottomNavVisibleToTrue();
                                    });
                                  }
                                  if (!mounted) return;
                                  Navigator.of(context).pop();
                                } else if (widget.isAccountScreen) {
                                  return;
                                } else {
                                  AutoRouter.of(context)
                                      .popUntilRouteWithName('/');
                                  AutoRouter.of(context).pushNamed('/');
                                }
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
