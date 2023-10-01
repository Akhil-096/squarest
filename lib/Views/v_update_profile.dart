import 'dart:io';

import 'package:squarest/Services/s_user_profile_notifier.dart';
import 'package:squarest/Views/v_otp_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../Utils/u_constants.dart';

class UpdateUserProfile extends StatefulWidget {
  final String id;

  const UpdateUserProfile({required this.id, Key? key}) : super(key: key);

  @override
  State<UpdateUserProfile> createState() => _UpdateUserProfileState();
}

class _UpdateUserProfileState extends State<UpdateUserProfile> {
  final form = GlobalKey<FormState>();
  bool isButtonEnabled = false;
  final user = FirebaseAuth.instance.currentUser;
  late final TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    final userProfileNotifier =
    Provider.of<UserProfileNotifier>(context, listen: false);
    textEditingController = TextEditingController(
        text: widget.id == "1"
            ? userProfileNotifier.userProfileModel.first_name
            : widget.id == "2"
            ? userProfileNotifier.userProfileModel.last_name
            : widget.id == "3"
            ? userProfileNotifier.userProfileModel.email_id
            : userProfileNotifier.userProfileModel.phone_number == null
            ? ''
            : userProfileNotifier.userProfileModel.phone_number
            .toString());
  }

  @override
  Widget build(BuildContext context) {
    // final userProfileModelNotifier = Provider.of<UserProfileModel>(context);
    final userProfileNotifier = Provider.of<UserProfileNotifier>(context);
    return Scaffold(
      appBar: Platform.isAndroid ? PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          scrolledUnderElevation: 0.0,
          backgroundColor: (MediaQuery.of(context).platformBrightness ==
            Brightness.dark)
            ? Colors.grey[900]
            : Colors.white,),
      ) : CupertinoNavigationBar(
        backgroundColor: (MediaQuery.of(context).platformBrightness ==
            Brightness.dark)
            ? Colors.grey[900]
            : CupertinoColors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  margin: const EdgeInsets.only(top: 40, left: 10),
                  child: Text(
                    widget.id == "1"
                        ? 'Edit Your First Name'
                        : widget.id == "2"
                        ? 'Edit Your Last Name'
                        : widget.id == "3"
                        ? 'Edit Your Email'
                        : 'Edit Your Phone number',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  )),
              const SizedBox(
                height: 50,
              ),
              Form(
                key: form,
                child: Container(
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  decoration: Platform.isAndroid ? null : BoxDecoration(
                      color: null,
                      border: Border.all(
                        width: 1,
                        color: (MediaQuery.of(context).platformBrightness ==
                            Brightness.dark)
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.black,
                      ),
                      borderRadius: BorderRadius.circular(25)),
                  child: Platform.isAndroid ? TextFormField(
                    maxLength: widget.id == "4" ? 10 : null,
                    controller: textEditingController,
                    onChanged: widget.id == "1" || widget.id == "2"
                        ? (value) {
                      if (value.isEmpty) {
                        form.currentState?.validate();
                        setState(() {
                          isButtonEnabled = false;
                        });
                      } else {
                        form.currentState?.validate();
                        setState(() {
                          isButtonEnabled = true;
                        });
                      }
                    }
                        : widget.id == "3"
                        ? (value) {
                      if (!value.contains("@")) {
                        form.currentState?.validate();
                        setState(() {
                          isButtonEnabled = false;
                        });
                      } else {
                        form.currentState?.validate();
                        setState(() {
                          isButtonEnabled = true;
                        });
                      }
                    }
                        : (value) {
                      if (value.length < 10) {
                        form.currentState?.validate();
                        setState(() {
                          isButtonEnabled = false;
                        });
                      } else {
                        form.currentState?.validate();
                        setState(() {
                          isButtonEnabled = true;
                        });
                      }
                    },
                    validator: widget.id == "1" || widget.id == "2"
                        ? (value) {
                      if (int.parse(value!.length.toString()) < 1) {
                        return 'This field cannot be empty';
                      } else {
                        return null;
                      }
                    }
                        : widget.id == "3"
                        ? (value) {
                      if (!value!.contains("@")) {
                        return 'Enter a valid email address';
                      } else {
                        return null;
                      }
                    }
                        : (value) {
                      if (value!.length < 10) {
                        return 'Enter 10 digits';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                        counterText: "",
                        // suffixIcon: Icon(
                        //   Icons.check,
                        //   color: textEditingController.value.text.isEmpty
                        //       ? Colors.grey
                        //       : Colors.green,
                        // ),
                        hintText: widget.id == "1"
                            ? "Enter first name"
                            : widget.id == "2"
                            ? "Enter last name"
                            : widget.id == "3"
                            ? "Enter email address"
                            : "Enter phone number",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        )),
                    inputFormatters: widget.id == "4"
                        ? <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ]
                        : null,
                    keyboardType: widget.id == "4" ? TextInputType.number : null,
                  ) : CupertinoTextFormFieldRow(
                    decoration: const BoxDecoration(
                      color: null,
                    ),
                    style: TextStyle(
                      color: (MediaQuery.of(context).platformBrightness ==
                          Brightness.dark)
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                    padding: const EdgeInsets.all(10),
                    maxLength: widget.id == "4" ? 10 : null,
                    controller: textEditingController,
                    onChanged: widget.id == "1" || widget.id == "2"
                        ? (value) {
                      if (value.isEmpty) {
                        form.currentState?.validate();
                        setState(() {
                          isButtonEnabled = false;
                        });
                      } else {
                        form.currentState?.validate();
                        setState(() {
                          isButtonEnabled = true;
                        });
                      }
                    }
                        : widget.id == "3"
                        ? (value) {
                      if (!value.contains("@")) {
                        form.currentState?.validate();
                        setState(() {
                          isButtonEnabled = false;
                        });
                      } else {
                        form.currentState?.validate();
                        setState(() {
                          isButtonEnabled = true;
                        });
                      }
                    }
                        : (value) {
                      if (value.length < 10) {
                        form.currentState?.validate();
                        setState(() {
                          isButtonEnabled = false;
                        });
                      } else {
                        form.currentState?.validate();
                        setState(() {
                          isButtonEnabled = true;
                        });
                      }
                    },
                    validator: widget.id == "1" || widget.id == "2"
                        ? (value) {
                      if (int.parse(value!.length.toString()) < 1) {
                        return 'This field cannot be empty';
                      } else {
                        return null;
                      }
                    }
                        : widget.id == "3"
                        ? (value) {
                      if (!value!.contains("@")) {
                        return 'Enter a valid email address';
                      } else {
                        return null;
                      }
                    }
                        : (value) {
                      if (value!.length < 10) {
                        return 'Enter 10 digits';
                      } else {
                        return null;
                      }
                    },
                    placeholder: widget.id == "1"
                        ? "Enter first name"
                        : widget.id == "2"
                        ? "Enter last name"
                        : widget.id == "3"
                        ? "Enter email address"
                        : "Enter phone number",
                    inputFormatters: widget.id == "4"
                        ? <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ]
                        : null,
                    keyboardType: widget.id == "4" ? TextInputType.number : null,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              if(Platform.isAndroid)
              Center(
                  child: Container(
                    height: 60,
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    width: double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: globalColor),
                      onPressed: !isButtonEnabled
                          ? () {
                        if (widget.id == "1" || widget.id == "2") {
                          if (textEditingController.text.isEmpty) {
                            form.currentState?.validate();
                          }
                        } else if (widget.id == "3") {
                          if (!textEditingController.text.contains("@")) {
                            form.currentState?.validate();
                          }
                        } else {
                          if (textEditingController.text.length < 10) {
                            form.currentState?.validate();
                          }
                        }
                      }
                          : () async {
                        if (widget.id == "1") {
                          // userProfileNotifier.setFirstName(textEditingController.value.text);
                          await userProfileNotifier
                              .updateUser(
                              context,
                              textEditingController.value.text,
                              (userProfileNotifier
                                  .userProfileModel.last_name)
                                  .toString(),
                              (userProfileNotifier
                                  .userProfileModel.email_id)
                                  .toString(),
                              userProfileNotifier
                                  .userProfileModel.phone_number)
                              .then((value) async {
                            await userProfileNotifier.getUser(
                                context,
                                (FirebaseAuth.instance.currentUser?.uid)
                                    .toString(),
                                this);
                          });
                          // Future.delayed(const Duration(milliseconds: 2500), (){
                          // });
                        } else if (widget.id == "2") {
                          // userProfileNotifier.setLastName(textEditingController.value.text);
                          await userProfileNotifier
                              .updateUser(
                              context,
                              (userProfileNotifier
                                  .userProfileModel.first_name)
                                  .toString(),
                              textEditingController.value.text,
                              (userProfileNotifier
                                  .userProfileModel.email_id)
                                  .toString(),
                              userProfileNotifier
                                  .userProfileModel.phone_number)
                              .then((value) async {
                            await userProfileNotifier.getUser(
                                context,
                                (FirebaseAuth.instance.currentUser?.uid)
                                    .toString(),
                                this);
                          });
                          // Future.delayed(const Duration(milliseconds: 2500), (){
                          // });
                        } else if (widget.id == "3") {
                          // userProfileNotifier.setEmail(textEditingController.value.text);
                          await userProfileNotifier
                              .updateUser(
                              context,
                              (userProfileNotifier
                                  .userProfileModel.first_name)
                                  .toString(),
                              (userProfileNotifier
                                  .userProfileModel.last_name)
                                  .toString(),
                              textEditingController.value.text,
                              userProfileNotifier
                                  .userProfileModel.phone_number)
                              .then((value) async {
                            await userProfileNotifier.getUser(
                                context,
                                (FirebaseAuth.instance.currentUser?.uid)
                                    .toString(),
                                this);
                          });
                          // Future.delayed(const Duration(milliseconds: 2500), (){
                          // });
                        } else {
                          await Navigator.of(context)
                              .push(MaterialPageRoute(
                              builder: (ctx) => OtpScreen(
                                phoneNo: textEditingController.text,
                                isComingFromLogin: false,
                                isComingFromJoinNow: false,
                                isAccountScreen: false,
                                isComingFromHomeLoan: true,
                                isComingFromBookAVisit: false,
                                isComingFromKnowMore: false,
                              )))
                              .then((_) async {
                            await userProfileNotifier
                                .updateUser(
                                context,
                                (userProfileNotifier
                                    .userProfileModel.first_name)
                                    .toString(),
                                (userProfileNotifier
                                    .userProfileModel.last_name)
                                    .toString(),
                                (userProfileNotifier
                                    .userProfileModel.email_id)
                                    .toString(),
                                FirebaseAuth.instance.currentUser?.phoneNumber != null ? int.parse((FirebaseAuth.instance.currentUser?.phoneNumber).toString().replaceAll("+91", "")) : null)
                                .then((value) async {
                              await userProfileNotifier.getUser(
                                  context,
                                  (FirebaseAuth.instance.currentUser?.uid)
                                      .toString(),
                                  this);
                            });
                          });
                        }
                        if (!mounted) return;
                        Navigator.of(context).pop();
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        child: Text("Save",
                            style: TextStyle(color: Colors.white, fontSize: 15)),
                      ),
                    ),
                  ),
                ),
              if(Platform.isIOS)
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10),
                width: double.infinity,
                child: CupertinoButton(
                  color: globalColor,
                  onPressed: !isButtonEnabled
                      ? () {
                    if (widget.id == "1" || widget.id == "2") {
                      if (textEditingController.text.isEmpty) {
                        form.currentState?.validate();
                      }
                    } else if (widget.id == "3") {
                      if (!textEditingController.text.contains("@")) {
                        form.currentState?.validate();
                      }
                    } else {
                      if (textEditingController.text.length < 10) {
                        form.currentState?.validate();
                      }
                    }
                  }
                      : () async {
                    if (widget.id == "1") {
                      // userProfileNotifier.setFirstName(textEditingController.value.text);
                      await userProfileNotifier
                          .updateUser(
                          context,
                          textEditingController.value.text,
                          (userProfileNotifier
                              .userProfileModel.last_name)
                              .toString(),
                          (userProfileNotifier
                              .userProfileModel.email_id)
                              .toString(),
                          userProfileNotifier
                              .userProfileModel.phone_number)
                          .then((value) async {
                        await userProfileNotifier.getUser(
                            context,
                            (FirebaseAuth.instance.currentUser?.uid)
                                .toString(),
                            this);
                      });
                      // Future.delayed(const Duration(milliseconds: 2500), (){
                      // });
                    } else if (widget.id == "2") {
                      // userProfileNotifier.setLastName(textEditingController.value.text);
                      await userProfileNotifier
                          .updateUser(
                          context,
                          (userProfileNotifier
                              .userProfileModel.first_name)
                              .toString(),
                          textEditingController.value.text,
                          (userProfileNotifier
                              .userProfileModel.email_id)
                              .toString(),
                          userProfileNotifier
                              .userProfileModel.phone_number)
                          .then((value) async {
                        await userProfileNotifier.getUser(
                            context,
                            (FirebaseAuth.instance.currentUser?.uid)
                                .toString(),
                            this);
                      });
                      // Future.delayed(const Duration(milliseconds: 2500), (){
                      // });
                    } else if (widget.id == "3") {
                      // userProfileNotifier.setEmail(textEditingController.value.text);
                      await userProfileNotifier
                          .updateUser(
                          context,
                          (userProfileNotifier
                              .userProfileModel.first_name)
                              .toString(),
                          (userProfileNotifier
                              .userProfileModel.last_name)
                              .toString(),
                          textEditingController.value.text,
                          userProfileNotifier
                              .userProfileModel.phone_number)
                          .then((value) async {
                        await userProfileNotifier.getUser(
                            context,
                            (FirebaseAuth.instance.currentUser?.uid)
                                .toString(),
                            this);
                      });
                      // Future.delayed(const Duration(milliseconds: 2500), (){
                      // });
                    } else {
                      await Navigator.of(context)
                          .push(MaterialPageRoute(
                          builder: (ctx) => OtpScreen(
                            phoneNo: textEditingController.text,
                            isComingFromLogin: false,
                            isComingFromJoinNow: false,
                            isAccountScreen: false,
                            isComingFromHomeLoan: true,
                            isComingFromBookAVisit: false,
                            isComingFromKnowMore: false,
                          )))
                          .then((_) async {
                        await userProfileNotifier
                            .updateUser(
                            context,
                            (userProfileNotifier
                                .userProfileModel.first_name)
                                .toString(),
                            (userProfileNotifier
                                .userProfileModel.last_name)
                                .toString(),
                            (userProfileNotifier
                                .userProfileModel.email_id)
                                .toString(),
                            FirebaseAuth.instance.currentUser?.phoneNumber != null ? int.parse((FirebaseAuth.instance.currentUser?.phoneNumber).toString().replaceAll("+91", "")) : null)
                            .then((value) async {
                          await userProfileNotifier.getUser(
                              context,
                              (FirebaseAuth.instance.currentUser?.uid)
                                  .toString(),
                              this);
                        });
                      });
                    }
                    if (!mounted) return;
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(25),
                  child: const Text("Save",
                      style: TextStyle(color: CupertinoColors.white, fontSize: 15)),
                ),
              )
              // Center(
              //   child: Container(
              //     padding: const EdgeInsets.only(left: 10, right: 10),
              //     width: double.infinity,
              //     child: TextButton(
              //       style: TextButton.styleFrom(
              //           foregroundColor: Colors.black,
              //           backgroundColor: globalColor),
              //       onPressed: !isButtonEnabled
              //           ? () {
              //         if (widget.id == "1" || widget.id == "2") {
              //           if (textEditingController.text.isEmpty) {
              //             form.currentState?.validate();
              //           }
              //         } else if (widget.id == "3") {
              //           if (!textEditingController.text.contains("@")) {
              //             form.currentState?.validate();
              //           }
              //         } else {
              //           if (textEditingController.text.length < 10) {
              //             form.currentState?.validate();
              //           }
              //         }
              //       }
              //           : () async {
              //         if (widget.id == "1") {
              //           // userProfileNotifier.setFirstName(textEditingController.value.text);
              //           await userProfileNotifier
              //               .updateUser(
              //               context,
              //               textEditingController.value.text,
              //               (userProfileNotifier
              //                   .userProfileModel.last_name)
              //                   .toString(),
              //               (userProfileNotifier
              //                   .userProfileModel.email_id)
              //                   .toString(),
              //               userProfileNotifier
              //                   .userProfileModel.phone_number)
              //               .then((value) async {
              //             await userProfileNotifier.getUser(
              //                 context,
              //                 (FirebaseAuth.instance.currentUser?.uid)
              //                     .toString(),
              //                 this);
              //           });
              //           // Future.delayed(const Duration(milliseconds: 2500), (){
              //           // });
              //         } else if (widget.id == "2") {
              //           // userProfileNotifier.setLastName(textEditingController.value.text);
              //           await userProfileNotifier
              //               .updateUser(
              //               context,
              //               (userProfileNotifier
              //                   .userProfileModel.first_name)
              //                   .toString(),
              //               textEditingController.value.text,
              //               (userProfileNotifier
              //                   .userProfileModel.email_id)
              //                   .toString(),
              //               userProfileNotifier
              //                   .userProfileModel.phone_number)
              //               .then((value) async {
              //             await userProfileNotifier.getUser(
              //                 context,
              //                 (FirebaseAuth.instance.currentUser?.uid)
              //                     .toString(),
              //                 this);
              //           });
              //           // Future.delayed(const Duration(milliseconds: 2500), (){
              //           // });
              //         } else if (widget.id == "3") {
              //           // userProfileNotifier.setEmail(textEditingController.value.text);
              //           await userProfileNotifier
              //               .updateUser(
              //               context,
              //               (userProfileNotifier
              //                   .userProfileModel.first_name)
              //                   .toString(),
              //               (userProfileNotifier
              //                   .userProfileModel.last_name)
              //                   .toString(),
              //               textEditingController.value.text,
              //               userProfileNotifier
              //                   .userProfileModel.phone_number)
              //               .then((value) async {
              //             await userProfileNotifier.getUser(
              //                 context,
              //                 (FirebaseAuth.instance.currentUser?.uid)
              //                     .toString(),
              //                 this);
              //           });
              //           // Future.delayed(const Duration(milliseconds: 2500), (){
              //           // });
              //         } else {
              //           await Navigator.of(context)
              //               .push(MaterialPageRoute(
              //               builder: (ctx) => OtpScreen(
              //                 phoneNo: textEditingController.text,
              //                 isComingFromLogin: false,
              //                 isComingFromJoinNow: false,
              //                 isAccountScreen: false,
              //                 isComingFromHomeLoan: true,
              //                 isComingFromBookAVisit: false,
              //               )))
              //               .then((_) async {
              //             await userProfileNotifier
              //                 .updateUser(
              //                 context,
              //                 (userProfileNotifier
              //                     .userProfileModel.first_name)
              //                     .toString(),
              //                 (userProfileNotifier
              //                     .userProfileModel.last_name)
              //                     .toString(),
              //                 (userProfileNotifier
              //                     .userProfileModel.email_id)
              //                     .toString(),
              //                 FirebaseAuth.instance.currentUser?.phoneNumber != null ? int.parse((FirebaseAuth.instance.currentUser?.phoneNumber).toString().replaceAll("+91", "")) : null)
              //                 .then((value) async {
              //               await userProfileNotifier.getUser(
              //                   context,
              //                   (FirebaseAuth.instance.currentUser?.uid)
              //                       .toString(),
              //                   this);
              //             });
              //           });
              //         }
              //         if (!mounted) return;
              //         Navigator.of(context).pop();
              //       },
              //       child: const Padding(
              //         padding: EdgeInsets.only(top: 8, bottom: 8),
              //         child: Text("Save",
              //             style: TextStyle(color: CupertinoColors.white, fontSize: 15)),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
