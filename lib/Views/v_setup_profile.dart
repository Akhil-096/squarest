import 'dart:io';

import 'package:squarest/Services/s_user_profile_notifier.dart';
import 'package:squarest/Views/v_otp_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../Services/s_autocomplete_notifier.dart';
import '../Utils/u_constants.dart';
import '../Utils/u_custom_styles.dart';

class SetupProfile extends StatefulWidget {
  const SetupProfile({Key? key}) : super(key: key);

  @override
  State<SetupProfile> createState() => _SetupProfileState();
}

class _SetupProfileState extends State<SetupProfile> {
  final form1 = GlobalKey<FormState>();
  final form2 = GlobalKey<FormState>();
  final form3 = GlobalKey<FormState>();
  final form4 = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneNoController = TextEditingController(text: FirebaseAuth.instance.currentUser?.phoneNumber == null ? '' : FirebaseAuth.instance.currentUser?.phoneNumber.toString());
  final emailController = TextEditingController(text: FirebaseAuth.instance.currentUser?.email == null ? '' : FirebaseAuth.instance.currentUser?.email.toString());


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userProfileNotifier = Provider.of<UserProfileNotifier>(context);
    final autocompleteNotifier = Provider.of<AutocompleteNotifier>(context);
    return Scaffold(
      appBar: Platform.isAndroid ? PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          scrolledUnderElevation: 0.0,
          backgroundColor: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? Colors.grey[900] : Colors.white,
          centerTitle: true,
          leading: null,
          title: Text(
            'Setup Your Profile', style: CustomTextStyles.getTitle(null, (MediaQuery.of(context).platformBrightness ==
              Brightness.dark)
              ? Colors.white
              : Colors.black, null, 20),
          ),
        ),
      ) : CupertinoNavigationBar(
        backgroundColor: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? Colors.grey[900] : CupertinoColors.white,
        middle: Text(
          'Setup Your Profile', style: CustomTextStyles.getTitle(null, (MediaQuery.of(context).platformBrightness ==
            Brightness.dark)
            ? CupertinoColors.white
            : CupertinoColors.black, null, 20),
        ),
        leading: null,
        trailing: null,
      ),
      body: SafeArea(
        child: WillPopScope(
          onWillPop: autocompleteNotifier.onWillPop,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 100),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: const EdgeInsets.only(left: 10),
                        child: const Text('First Name')),
                    const SizedBox(
                      height: 5,
                    ),
                    Form(
                      key: form1,
                      child: Container(
                        margin: const EdgeInsets.only(left: 10, right: 10),
                        decoration: Platform.isAndroid ? null : BoxDecoration(
                          border: Border.all(
                              width: 1,
                              color: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey : Platform.isAndroid ? Colors.black : CupertinoColors.black
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Platform.isAndroid ? TextFormField(
                          controller: firstNameController,
                          // inputFormatters: <TextInputFormatter>[
                          //   FilteringTextInputFormatter.digitsOnly
                          // ],
                          validator: (value) {
                            if (int.parse(value!.length.toString()) < 1) {
                              return 'This field cannot be empty';
                            }
                            return null;
                          },
                          showCursor: true,
                          onChanged: (value) {
                            if (int.parse(value.length.toString()) < 1) {
                              form1.currentState?.validate();
                              setState(() {});
                            }
                            if (int.parse(value.length.toString()) == 1) {
                              form1.currentState?.validate();
                              setState(() {});
                            }
                          },
                          // keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              counterText: "",
                              suffixIcon: Icon(
                                Icons.check,
                                color: firstNameController.value.text.isEmpty
                                    ? Colors.grey
                                    : Colors.green,
                              ),
                              hintText: "Enter first name",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              )),
                        ) : Row(
                          children: [
                            Expanded(
                              child: CupertinoTextFormFieldRow(
                                padding: const EdgeInsetsDirectional.all(10),
                                controller: firstNameController,
                                validator: (value) {
                                  if (int.parse(value!.length.toString()) < 1) {
                                    return 'This field cannot be empty';
                                  }
                                  return null;
                                },
                                style: TextStyle(color: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? CupertinoColors.white : CupertinoColors.black, fontSize: 18),
                                showCursor: true,
                                onChanged: (value) {
                                  if (int.parse(value.length.toString()) < 1) {
                                    form1.currentState?.validate();
                                    setState(() {});
                                  }
                                  if (int.parse(value.length.toString()) == 1) {
                                    form1.currentState?.validate();
                                    setState(() {});
                                  }
                                },
                                placeholder: "Enter first name",
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: Icon(
                                CupertinoIcons.checkmark_alt,
                                color: firstNameController.value.text.isEmpty
                                    ? CupertinoColors.systemGrey
                                    : CupertinoColors.systemGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                        padding: const EdgeInsets.only(left: 10),
                        child: const Text('Last Name')),
                    const SizedBox(
                      height: 5,
                    ),
                    Form(
                      key: form2,
                      child: Container(
                        margin: const EdgeInsets.only(left: 10, right: 10),
                        decoration: Platform.isAndroid ? null : BoxDecoration(
                          border: Border.all(
                              width: 1,
                              color: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? CupertinoColors.systemGrey : CupertinoColors.black
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Platform.isAndroid ? TextFormField(
                          controller: lastNameController,
                          // inputFormatters: <TextInputFormatter>[
                          //   FilteringTextInputFormatter.digitsOnly
                          // ],
                          validator: (value) {
                            if (int.parse(value!.length.toString()) < 1) {
                              return 'This field cannot be empty';
                            }
                            return null;
                          },
                          showCursor: true,
                          onChanged: (value) {
                            if (int.parse(value.length.toString()) < 1) {
                              form2.currentState?.validate();
                              setState(() {});
                            }
                            if (int.parse(value.length.toString()) == 1) {
                              form2.currentState?.validate();
                              setState(() {});
                            }
                          },
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              counterText: "",
                              suffixIcon: Icon(
                                Icons.check,
                                color: lastNameController.value.text.isEmpty
                                    ? Colors.grey
                                    : Colors.green,
                              ),
                              hintText: "Enter last name",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              )),
                        ) : Row(
                          children: [
                            Expanded(
                              child: CupertinoTextFormFieldRow(
                                padding: const EdgeInsetsDirectional.all(10),
                                controller: lastNameController,
                                validator: (value) {
                                  if (int.parse(value!.length.toString()) < 1) {
                                    return 'This field cannot be empty';
                                  }
                                  return null;
                                },
                                style: TextStyle(color: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? CupertinoColors.white : CupertinoColors.black, fontSize: 18),
                                showCursor: true,
                                onChanged: (value) {
                                  if (int.parse(value.length.toString()) < 1) {
                                    form2.currentState?.validate();
                                    setState(() {});
                                  }
                                  if (int.parse(value.length.toString()) == 1) {
                                    form2.currentState?.validate();
                                    setState(() {});
                                  }
                                },
                                placeholder: "Enter last name",
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            Padding(padding: const EdgeInsets.only(right: 5), child: Icon(
                              CupertinoIcons.checkmark_alt,
                              color: lastNameController.value.text.isEmpty
                                  ? CupertinoColors.systemGrey
                                  : CupertinoColors.systemGreen,
                            ),)
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                        padding: const EdgeInsets.only(left: 10),
                        child: const Text('Email')),
                    const SizedBox(
                      height: 5,
                    ),
                    Form(
                      key: form3,
                      child: Container(
                        margin: const EdgeInsets.only(left: 10, right: 10),
                        decoration: Platform.isAndroid ? null : BoxDecoration(
                          border: Border.all(
                              width: 1,
                              color: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? CupertinoColors.systemGrey : CupertinoColors.black
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Platform.isAndroid ? TextFormField(
                          controller: emailController,
                          enabled: FirebaseAuth.instance.currentUser?.email == null
                              ? true
                              : false,
                          validator: (value) {
                            if (!value!.contains("@")) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                          showCursor: true,
                          onChanged: (value) {
                            if (!value.contains("@")) {
                              form3.currentState?.validate();
                              setState(() {});
                            }
                            if (value.contains("@")) {
                              form3.currentState?.validate();
                              setState(() {});
                            }
                          },
                          // keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              counterText: "",
                              suffixIcon: Icon(
                                Icons.check,
                                color: emailController.value.text.contains("@")
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              hintText: "Enter email address",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              )),
                        ) : Row(
                          children: [
                            Expanded(
                              child: CupertinoTextFormFieldRow(
                                padding: const EdgeInsetsDirectional.all(10),
                                controller: emailController,
                                enabled: (FirebaseAuth.instance.currentUser?.email == null ||
                                    FirebaseAuth.instance.currentUser!.email
                                        .toString()
                                        .isEmpty)
                                    ? true
                                    : false,
                                validator: (value) {
                                  if (!value!.contains("@")) {
                                    return 'Enter a valid email address';
                                  }
                                  return null;
                                },
                                style: TextStyle(color: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? CupertinoColors.white : CupertinoColors.black, fontSize: 18),
                                showCursor: true,
                                onChanged: (value) {
                                  if (!value.contains("@")) {
                                    form3.currentState?.validate();
                                    setState(() {});
                                  }
                                  if (value.contains("@")) {
                                    form3.currentState?.validate();
                                    setState(() {});
                                  }
                                },
                                placeholder: "Enter email address",
                              ),
                            ),
                            Padding(padding: const EdgeInsets.only(right: 5), child: Icon(
                              CupertinoIcons.checkmark_alt,
                              color: emailController.value.text.contains("@")
                                  ? CupertinoColors.activeGreen
                                  : CupertinoColors.systemGrey,
                            ),)
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                        padding: const EdgeInsets.only(left: 10),
                        child: const Text('Phone number')),
                    const SizedBox(
                      height: 5,
                    ),
                    Form(
                      key: form4,
                      child: Container(
                        margin: const EdgeInsets.only(left: 10, right: 10),
                        decoration: Platform.isAndroid ? null : BoxDecoration(
                          border: Border.all(
                              width: 1,
                              color: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? CupertinoColors.systemGrey : CupertinoColors.black
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Platform.isAndroid ? TextFormField(
                          enabled:
                          (FirebaseAuth.instance.currentUser?.phoneNumber ==
                              null ||
                              FirebaseAuth.instance.currentUser!.phoneNumber
                                  .toString()
                                  .isEmpty)
                              ? true
                              : false,
                          controller: phoneNoController,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (value) {
                            if (value!.length < 10) {
                              return 'Enter 10 digits';
                            }
                            return null;
                          },
                          maxLength: 10,
                          showCursor: true,
                          onChanged: (value) {
                            if (value.length < 10) {
                              form4.currentState?.validate();
                              setState(() {});
                            }
                            if (value.length == 10) {
                              form4.currentState?.validate();
                              setState(() {});
                            }
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              counterText: "",
                              suffixIcon: Icon(
                                Icons.check,
                                color: phoneNoController.value.text.length < 10
                                    ? Colors.grey
                                    : Colors.green,
                              ),
                              hintText: "Enter phone number",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              )),
                        ) : Row(
                          children: [
                            Expanded(
                              child: CupertinoTextFormFieldRow(
                                padding: const EdgeInsetsDirectional.all(10),
                                enabled:
                                    (FirebaseAuth.instance.currentUser?.phoneNumber ==
                                                null ||
                                            FirebaseAuth.instance.currentUser!.phoneNumber
                                                .toString()
                                                .isEmpty)
                                        ? true
                                        : false,
                                controller: phoneNoController,
                                style: TextStyle(color: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? CupertinoColors.white : CupertinoColors.black, fontSize: 18),
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                placeholder: "Enter phone number",
                                validator: (value) {
                                  if (value!.length < 10) {
                                    return 'Enter 10 digits';
                                  }
                                  return null;
                                },
                                maxLength: 10,
                                showCursor: true,
                                onChanged: (value) {
                                  if (value.length < 10) {
                                    form4.currentState?.validate();
                                    setState(() {});
                                  }
                                  if (value.length == 10) {
                                    form4.currentState?.validate();
                                    setState(() {});
                                  }
                                },
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: Icon(
                                CupertinoIcons.checkmark_alt,
                                color: phoneNoController.value.text.length < 10
                                    ? CupertinoColors.systemGrey
                                    : CupertinoColors.systemGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                if(Platform.isAndroid)
                Center(
                    child: Container(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      width: double.infinity,
                      child: TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.black, backgroundColor: globalColor),
                        onPressed:
                            () async {
                          if (firstNameController.value.text.isEmpty ||
                              lastNameController.value.text.isEmpty ||
                              !emailController.value.text.contains("@") ||
                              phoneNoController.value.text.length < 10) {
                            form1.currentState?.validate();
                            form2.currentState?.validate();
                            form3.currentState?.validate();
                            form4.currentState?.validate();
                            setState(() {});
                          } else {
                            if (FirebaseAuth.instance.currentUser?.phoneNumber == null) {
                              if(!mounted) return;
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                  builder: (ctx) => OtpScreen(
                                    phoneNo: phoneNoController.text,
                                    isComingFromLogin: false,
                                    isComingFromJoinNow: false,
                                    isAccountScreen: false,
                                    isComingFromHomeLoan: true,
                                    isComingFromBookAVisit: false,
                                    isComingFromKnowMore: false,
                                  )));
                            } else {
                              await userProfileNotifier.createUser(firstNameController.text, lastNameController.text, FirebaseAuth.instance.currentUser!.phoneNumber == null ? phoneNoController.text : FirebaseAuth.instance.currentUser!.phoneNumber.toString(), FirebaseAuth.instance.currentUser?.email == null ? emailController.text : FirebaseAuth.instance.currentUser!.email.toString(), context).then((value) async {
                                await userProfileNotifier.getUser(context, (FirebaseAuth.instance.currentUser?.uid).toString(), this).whenComplete(() {
                                  userProfileNotifier.setIsBottomNavVisibleToTrue();
                                });
                              });
                              // if(!mounted) return;

                              // createUserAndGetUser();
                              // Future.delayed(const Duration(milliseconds: 4000),(){
                              //
                              // });
                              // userProfileNotifier.setUid(context, (userProfileNotifier.userProfileModel?.firebase_user_id).toString());
                            }
                          }
                        },
                        child: const Padding(
                          padding:
                          EdgeInsets.only(top: 8, bottom: 8),
                          child: Text("Submit",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 15)),
                        ),
                      ),
                    ),
                  ),
                if(Platform.isIOS)
                Container(
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  width: double.infinity,
                  child: CupertinoButton(
                    borderRadius: BorderRadius.circular(25),
                      color: globalColor,
                      child: const Text("Submit",
                      style: TextStyle(
                          color: CupertinoColors.white, fontSize: 15)), onPressed: () async {
                    if (firstNameController.value.text.isEmpty ||
                        lastNameController.value.text.isEmpty ||
                        !emailController.value.text.contains("@") ||
                        phoneNoController.value.text.length < 10) {
                      form1.currentState?.validate();
                      form2.currentState?.validate();
                      form3.currentState?.validate();
                      form4.currentState?.validate();
                      setState(() {});
                    } else {
                      if (FirebaseAuth.instance.currentUser?.phoneNumber == null) {
                        if(!mounted) return;
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                            builder: (ctx) => OtpScreen(
                              phoneNo: phoneNoController.text,
                              isComingFromLogin: false,
                              isComingFromJoinNow: false,
                              isAccountScreen: false,
                              isComingFromHomeLoan: true,
                              isComingFromBookAVisit: false,
                              isComingFromKnowMore: false,
                            )));
                      } else {
                        await userProfileNotifier.createUser(firstNameController.text, lastNameController.text, FirebaseAuth.instance.currentUser!.phoneNumber == null ? phoneNoController.text : FirebaseAuth.instance.currentUser!.phoneNumber.toString(), FirebaseAuth.instance.currentUser?.email == null ? emailController.text : FirebaseAuth.instance.currentUser!.email.toString(), context).then((value) async {
                          await userProfileNotifier.getUser(context, (FirebaseAuth.instance.currentUser?.uid).toString(), this).whenComplete(() {
                            userProfileNotifier.setIsBottomNavVisibleToTrue();
                          });
                        });
                      }
                    }
                  }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
