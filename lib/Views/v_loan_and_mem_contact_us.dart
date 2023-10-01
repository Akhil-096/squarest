import 'dart:convert';
import 'dart:io';
import 'package:squarest/Views/v_otp_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readmore/readmore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Services/s_auth_notifier.dart';
import '../Services/s_resale_property_notifier.dart';
import '../Services/s_user_profile_notifier.dart';
import '../Utils/u_constants.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../Utils/u_custom_styles.dart';

class LoanAndMemContactUs extends StatefulWidget {
  // final DateTime selectedDate;
  // final ResalePropertyModel resaleProject;
  final String appBarTitle;
  final bool isComingFromPlan;

  const LoanAndMemContactUs({required this.appBarTitle, required this.isComingFromPlan, Key? key})
      : super(key: key);

  @override
  State<LoanAndMemContactUs> createState() => _LoanAndMemContactUsState();
}

class _LoanAndMemContactUsState extends State<LoanAndMemContactUs> {


  late final TextEditingController nameTextEditingController;
  late final TextEditingController emailTextEditingController;
  late final TextEditingController phoneTextEditingController;
  late final TextEditingController messageTextEditingController;


  final form1 = GlobalKey<FormState>();
  final form2 = GlobalKey<FormState>();
  final form3 = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final userProfileNotifier =
    Provider.of<UserProfileNotifier>(context, listen: false);
    nameTextEditingController = TextEditingController(
        text: FirebaseAuth.instance.currentUser?.uid == null
            ? ''
            : '${userProfileNotifier.userProfileModel.first_name ?? ''} ${userProfileNotifier.userProfileModel.last_name ?? ''}');
    emailTextEditingController = TextEditingController(
        text: FirebaseAuth.instance.currentUser?.uid == null
            ? ''
            : FirebaseAuth.instance.currentUser?.email == null
            ? (userProfileNotifier.userProfileModel.email_id ?? '')
            : FirebaseAuth.instance.currentUser!.email.toString());
    phoneTextEditingController = TextEditingController(
        text: FirebaseAuth.instance.currentUser?.uid == null
            ? ''
            : (FirebaseAuth.instance.currentUser?.phoneNumber == null)
            ? ''
            : FirebaseAuth.instance.currentUser!.phoneNumber.toString());
    if(widget.isComingFromPlan) {
      messageTextEditingController = TextEditingController(text: 'I would like more information regarding the Select membership plan.');
    } else {
      messageTextEditingController = TextEditingController(text: 'I would like more information regarding the Home Loan');
    }
  }

  @override
  void dispose() {
    nameTextEditingController.dispose();
    emailTextEditingController.dispose();
    phoneTextEditingController.dispose();
    messageTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfileNotifier = Provider.of<UserProfileNotifier>(context);
    final resalePropertyNotifier = Provider.of<ResalePropertyNotifier>(context);
    final authNotifier = Provider.of<AuthNotifier>(context);

    return Scaffold(
        appBar: Platform.isAndroid ? PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: AppBar(
            scrolledUnderElevation: 0.0,
            backgroundColor:
            (MediaQuery.of(context).platformBrightness == Brightness.dark)
                ? Colors.grey[900]
                : Colors.white,
            title: Text(widget.appBarTitle,
              style: CustomTextStyles.getTitle(
                  null,
                  (MediaQuery.of(context).platformBrightness == Brightness.dark)
                      ? Colors.white
                      : Colors.black,
                  null,
                  19),
            ),
          ),
        ) : CupertinoNavigationBar(
          backgroundColor:
          (MediaQuery.of(context).platformBrightness == Brightness.dark)
              ? Colors.grey[900]
              : CupertinoColors.white,
          middle: Text(widget.appBarTitle,
            style: CustomTextStyles.getTitle(
                null,
                (MediaQuery.of(context).platformBrightness == Brightness.dark)
                    ? CupertinoColors.white
                    : CupertinoColors.black,
                null,
                19),
          ),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Form(
                      key: form1,
                      child: Platform.isAndroid ? TextFormField(
                        controller: nameTextEditingController,
                        onChanged: (value) {
                          if(RegExp(r'^([a-zA-Z]+\s)*[a-zA-Z]+$').hasMatch(value)){
                            form1.currentState?.validate();
                            setState(() {});
                          } else {
                            form1.currentState?.validate();
                            setState(() {});
                          }
                          // if (!value.contains(' ') || value.isEmpty) {
                          //   form1.currentState?.validate();
                          //   setState(() {});
                          // } else {
                          //   form1.currentState?.validate();
                          //   setState(() {});
                          // }
                        },
                        validator: (value) {
                          if(!RegExp(r'^([a-zA-Z]+\s)*[a-zA-Z]+$').hasMatch(value!)) {
                            return 'Enter first name \'space\' last name';
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
                            hintText: "Name",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            )),
                        // inputFormatters: <TextInputFormatter>[
                        //   FilteringTextInputFormatter.digitsOnly
                        // ],
                        // keyboardType: widget.id == "4" ? TextInputType.number : null,
                      ) : Container(
                        decoration: BoxDecoration(
                            color: null,
                            border: Border.all(
                              width: 1,
                              color: (MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark)
                                  ? CupertinoColors.systemGrey
                                  : CupertinoColors.black,
                            ),
                            borderRadius: BorderRadius.circular(25)),
                        child: CupertinoTextFormFieldRow(
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
                          controller: nameTextEditingController,
                          onChanged: (value) {
                            if(RegExp(r'^([a-zA-Z]+\s)*[a-zA-Z]+$').hasMatch(value)){
                              form1.currentState?.validate();
                              setState(() {});
                            } else {
                              form1.currentState?.validate();
                              setState(() {});
                            }
                            // if (!value.contains(' ') || value.isEmpty) {
                            //   form1.currentState?.validate();
                            //   setState(() {});
                            // } else {
                            //   form1.currentState?.validate();
                            //   setState(() {});
                            // }
                          },
                          validator: (value) {
                            if(!RegExp(r'^([a-zA-Z]+\s)*[a-zA-Z]+$').hasMatch(value!)) {
                              return 'Enter first name \'space\' last name';
                            } else {
                              return null;
                            }
                          },
                          placeholder: "Name",
                          // decoration: InputDecoration(
                          //     counterText: "",
                          //     // suffixIcon: Icon(
                          //     //   Icons.check,
                          //     //   color: textEditingController.value.text.isEmpty
                          //     //       ? Colors.grey
                          //     //       : Colors.green,
                          //     // ),
                          //     hintText: "Name",
                          //     border: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(10),
                          //     )),
                          // inputFormatters: <TextInputFormatter>[
                          //   FilteringTextInputFormatter.digitsOnly
                          // ],
                          // keyboardType: widget.id == "4" ? TextInputType.number : null,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Form(
                      key: form2,
                      child: Platform.isAndroid ? TextFormField(
                        controller: emailTextEditingController,
                        enabled: (FirebaseAuth.instance.currentUser?.uid != null && FirebaseAuth.instance.currentUser?.email != null)
                            ? false
                            : true,
                        onChanged: (value) {
                          if (!value.contains('@')) {
                            form2.currentState?.validate();
                            setState(() {});
                          } else {
                            form2.currentState?.validate();
                            setState(() {});
                          }
                        },
                        validator: (value) {
                          if (!value!.contains('@')) {
                            return 'Enter a valid email address';
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
                            hintText: "Email",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            )),
                      ) : Container(
                        decoration: BoxDecoration(
                            color: null,
                            border: Border.all(
                              width: 1,
                              color: (MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark)
                                  ? CupertinoColors.systemGrey
                                  : CupertinoColors.black,
                            ),
                            borderRadius: BorderRadius.circular(25)),
                        child: CupertinoTextFormFieldRow(
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
                          controller: emailTextEditingController,
                          enabled: (FirebaseAuth.instance.currentUser?.uid != null && FirebaseAuth.instance.currentUser?.email != null)
                              ? false
                              : true,
                          onChanged: (value) {
                            if (!value.contains('@')) {
                              form2.currentState?.validate();
                              setState(() {});
                            } else {
                              form2.currentState?.validate();
                              setState(() {});
                            }
                          },
                          validator: (value) {
                            if (!value!.contains('@')) {
                              return 'Enter a valid email address';
                            } else {
                              return null;
                            }
                          },
                          placeholder: "Email",
                          // decoration: InputDecoration(
                          //     counterText: "",
                          //     // suffixIcon: Icon(
                          //     //   Icons.check,
                          //     //   color: textEditingController.value.text.isEmpty
                          //     //       ? Colors.grey
                          //     //       : Colors.green,
                          //     // ),
                          //     hintText: "Email",
                          //     border: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(10),
                          //     )),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Form(
                      key: form3,
                      child: Platform.isAndroid ? TextFormField(
                        controller: phoneTextEditingController,
                        enabled: (FirebaseAuth.instance.currentUser?.uid != null && FirebaseAuth.instance.currentUser?.phoneNumber !=
                            null)
                            ? false
                            : true,
                        maxLength: 10,
                        onChanged: (value) {
                          if (value.length < 10) {
                            form3.currentState?.validate();
                            setState(() {});
                          } else {
                            form3.currentState?.validate();
                            setState(() {});
                          }
                        },
                        validator: (value) {
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
                            hintText: "Phone",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            )),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        keyboardType: TextInputType.number,
                      ) : Container(
                        decoration: BoxDecoration(
                            color: null,
                            border: Border.all(
                              width: 1,
                              color: (MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark)
                                  ? CupertinoColors.systemGrey
                                  : CupertinoColors.black,
                            ),
                            borderRadius: BorderRadius.circular(25)),
                        child: CupertinoTextFormFieldRow(
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
                          controller: phoneTextEditingController,
                          enabled: (FirebaseAuth.instance.currentUser?.uid != null && FirebaseAuth.instance.currentUser?.phoneNumber !=
                              null)
                              ? false
                              : true,
                          maxLength: 10,
                          onChanged: (value) {
                            if (value.length < 10) {
                              form3.currentState?.validate();
                              setState(() {});
                            } else {
                              form3.currentState?.validate();
                              setState(() {});
                            }
                          },
                          validator: (value) {
                            if (value!.length < 10) {
                              return 'Enter 10 digits';
                            } else {
                              return null;
                            }
                          },
                          placeholder: "Phone",
                          // decoration: InputDecoration(
                          //     counterText: "",
                          //     // suffixIcon: Icon(
                          //     //   Icons.check,
                          //     //   color: textEditingController.value.text.isEmpty
                          //     //       ? Colors.grey
                          //     //       : Colors.green,
                          //     // ),
                          //     hintText: "Phone",
                          //     border: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(10),
                          //     )),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    if(Platform.isAndroid)
                      TextFormField(
                        controller: messageTextEditingController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onChanged: (value) {
                          // if (value.length < 10) {
                          //   form4.currentState?.validate();
                          //   setState(() {});
                          // } else {
                          //   form4.currentState?.validate();
                          //   setState(() {});
                          // }
                        },
                        // validator: (value) {
                        //   // if (value!.length < 10) {
                        //   //   return 'Enter at least 10 letters';
                        //   // } else {
                        //   //   return null;
                        //   // }
                        // },
                        decoration: InputDecoration(
                            counterText: "",
                            hintText: "Message",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            )),
                      ),
                    if(Platform.isIOS)
                      Container(
                        decoration: BoxDecoration(
                            color: null,
                            border: Border.all(
                              width: 1,
                              color: (MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark)
                                  ? CupertinoColors.systemGrey
                                  : CupertinoColors.black,
                            ),
                            borderRadius: BorderRadius.circular(25)),
                        child: CupertinoTextFormFieldRow(
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
                          controller: messageTextEditingController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          onChanged: (value) {
                            // if (value.length < 10) {
                            //   form4.currentState?.validate();
                            //   setState(() {});
                            // } else {
                            //   form4.currentState?.validate();
                            //   setState(() {});
                            // }
                          },
                          // validator: (value) {
                          //   // if (value!.length < 10) {
                          //   //   return 'Enter at least 10 letters';
                          //   // } else {
                          //   //   return null;
                          //   // }
                          // },
                          placeholder: "Message",
                          // decoration: InputDecoration(
                          //     counterText: "",
                          //     hintText: "Message",
                          //     border: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(10),
                          //     )),
                        ),
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    if(Platform.isAndroid)
                      Center(
                        child: SizedBox(
                          height: 60,
                          width: double.infinity,
                          child: TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: globalColor),
                            onPressed: () async {
                              if (!RegExp(r'^([a-zA-Z]+\s)*[a-zA-Z]+$').hasMatch(nameTextEditingController
                                  .value.text) ||
                                  !emailTextEditingController.value.text
                                      .contains("@") ||
                                  phoneTextEditingController.value.text.length < 10) {
                                form1.currentState?.validate();
                                form2.currentState?.validate();
                                form3.currentState?.validate();
                                setState(() {});
                              } else if (FirebaseAuth.instance.currentUser?.uid !=
                                  null) {
                                String emailPostUrl =
                                    "https://api.emailjs.com/api/v1.0/email/send";
                                final url = Uri.parse(emailPostUrl);
                                final response = await http.post(url,
                                    headers: {
                                      'origin': "http://localhost",
                                      'Content-Type': 'application/json',
                                    },
                                    body: json.encode({
                                      "service_id": "service_tc16pbr",
                                      "template_id": "template_5cjrgmn",
                                      "user_id": "EhQW8PzI3mUXrzJ0y",
                                      'template_params': {
                                        "message": 'Subject - Home Loan\nPhone = ${FirebaseAuth
                                            .instance.currentUser?.phoneNumber
                                            .toString()}\nFirst Name - ${userProfileNotifier
                                            .userProfileModel.first_name}\nLast Name - ${userProfileNotifier
                                            .userProfileModel.last_name}',
                                      }
                                    }));
                                if (response.statusCode == 200) {
                                  authNotifier.saveSubmittedPhoneNo(
                                      '+91${FirebaseAuth.instance.currentUser?.phoneNumber.toString().replaceAll("+91", '')}');
                                } else {
                                  Fluttertoast.showToast(
                                    msg:
                                    'Something went wrong. Please try again.',
                                    backgroundColor: Colors.white,
                                    textColor: Colors.black,
                                  );
                                }
                                if (kDebugMode) {
                                  print(response.statusCode);
                                }
                                if(!mounted) return;
                                Navigator.of(context).pop();
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OtpScreen(
                                        isAccountScreen: false,
                                        isComingFromHomeLoan: false,
                                        isComingFromJoinNow: false,
                                        isComingFromLogin: true,
                                        isComingFromBookAVisit: true,
                                        isComingFromKnowMore: false,
                                        phoneNo: phoneTextEditingController.text,
                                      )),
                                ).then((_) async {
                                  if (FirebaseAuth.instance.currentUser?.uid ==
                                      null) {
                                    return;
                                  } else {
                                    await userProfileNotifier
                                        .getUser(
                                        context,
                                        (FirebaseAuth.instance.currentUser?.uid)
                                            .toString(),
                                        this)
                                        .whenComplete(() async {
                                      if (userProfileNotifier.userProfileModel
                                          .firebase_user_id ==
                                          null ||
                                          userProfileNotifier.userProfileModel
                                              .firebase_user_id!.isEmpty) {
                                        if (!mounted) return;
                                        userProfileNotifier
                                            .createUser(
                                            nameTextEditingController.text.split(" ").first,
                                            nameTextEditingController.text.split(" ").last,
                                            FirebaseAuth.instance.currentUser
                                                ?.phoneNumber,
                                            emailTextEditingController.text,
                                            context)
                                            .then((_) async {
                                          await userProfileNotifier
                                              .getUser(
                                              context,
                                              (FirebaseAuth
                                                  .instance.currentUser?.uid)
                                                  .toString(),
                                              this)
                                              .then((_) async {
                                            userProfileNotifier
                                                .setIsBottomNavVisibleToTrue();
                                            await resalePropertyNotifier.getMemPlans(context);
                                            if(FirebaseAuth.instance.currentUser?.phoneNumber != null) {
                                              phoneTextEditingController.text = FirebaseAuth.instance.currentUser!.phoneNumber.toString();
                                            }
                                            if(FirebaseAuth.instance.currentUser?.email != null) {
                                              emailTextEditingController.text = FirebaseAuth.instance.currentUser!.email ?? '';
                                            } else {
                                              emailTextEditingController.text = (userProfileNotifier.userProfileModel.email_id == null || userProfileNotifier.userProfileModel.email_id!.isEmpty) ? emailTextEditingController.text : userProfileNotifier.userProfileModel.email_id!;
                                            }
                                            if((userProfileNotifier.userProfileModel.first_name != null || userProfileNotifier.userProfileModel.first_name!.isNotEmpty) && (userProfileNotifier.userProfileModel.last_name != null || userProfileNotifier.userProfileModel.last_name!.isNotEmpty)) {
                                              nameTextEditingController.text = '${userProfileNotifier.userProfileModel.first_name ?? ''} ${userProfileNotifier.userProfileModel.last_name ?? ''}';
                                            }
                                            String emailPostUrl =
                                                "https://api.emailjs.com/api/v1.0/email/send";
                                            final url = Uri.parse(emailPostUrl);
                                            final response = await http.post(url,
                                                headers: {
                                                  'origin': "http://localhost",
                                                  'Content-Type': 'application/json',
                                                },
                                                body: json.encode({
                                                  "service_id": "service_tc16pbr",
                                                  "template_id": "template_5cjrgmn",
                                                  "user_id": "EhQW8PzI3mUXrzJ0y",
                                                  'template_params': {
                                                    "message": 'Subject - Home Loan\nPhone = ${FirebaseAuth
                                                        .instance.currentUser?.phoneNumber
                                                        .toString()}\nFirst Name - ${userProfileNotifier
                                                        .userProfileModel.first_name}\nLast Name - ${userProfileNotifier
                                                        .userProfileModel.last_name}',
                                                  }
                                                }));
                                            if (response.statusCode == 200) {
                                              authNotifier.saveSubmittedPhoneNo(
                                                  '+91${FirebaseAuth.instance.currentUser?.phoneNumber.toString().replaceAll("+91", '')}');
                                            } else {
                                              Fluttertoast.showToast(
                                                msg:
                                                'Something went wrong. Please try again.',
                                                backgroundColor: Colors.white,
                                                textColor: Colors.black,
                                              );
                                            }
                                            if (kDebugMode) {
                                              print(response.statusCode);
                                            }
                                            if(!mounted) return;
                                            Navigator.of(context).pop();
                                          });
                                        });
                                      } else {
                                        await resalePropertyNotifier.getMemPlans(context);
                                        if(FirebaseAuth.instance.currentUser?.phoneNumber != null) {
                                          phoneTextEditingController.text = FirebaseAuth.instance.currentUser!.phoneNumber.toString();
                                        }
                                        if(FirebaseAuth.instance.currentUser?.email != null) {
                                          emailTextEditingController.text = FirebaseAuth.instance.currentUser!.email ?? '';
                                        } else {
                                          emailTextEditingController.text = (userProfileNotifier.userProfileModel.email_id == null || userProfileNotifier.userProfileModel.email_id!.isEmpty) ? emailTextEditingController.text : userProfileNotifier.userProfileModel.email_id!;
                                        }
                                        if((userProfileNotifier.userProfileModel.first_name != null || userProfileNotifier.userProfileModel.first_name!.isNotEmpty) && (userProfileNotifier.userProfileModel.last_name != null || userProfileNotifier.userProfileModel.last_name!.isNotEmpty)) {
                                          nameTextEditingController.text = '${userProfileNotifier.userProfileModel.first_name ?? ''} ${userProfileNotifier.userProfileModel.last_name ?? ''}';
                                        }
                                        String emailPostUrl =
                                            "https://api.emailjs.com/api/v1.0/email/send";
                                        final url = Uri.parse(emailPostUrl);
                                        final response = await http.post(url,
                                            headers: {
                                              'origin': "http://localhost",
                                              'Content-Type': 'application/json',
                                            },
                                            body: json.encode({
                                              "service_id": "service_tc16pbr",
                                              "template_id": "template_5cjrgmn",
                                              "user_id": "EhQW8PzI3mUXrzJ0y",
                                              'template_params': {
                                                "message": 'Subject - Home Loan\nPhone = ${FirebaseAuth
                                                    .instance.currentUser?.phoneNumber
                                                    .toString()}\nFirst Name - ${userProfileNotifier
                                                    .userProfileModel.first_name}\nLast Name - ${userProfileNotifier
                                                    .userProfileModel.last_name}',
                                              }
                                            }));
                                        if (response.statusCode == 200) {
                                          authNotifier.saveSubmittedPhoneNo(
                                              '+91${FirebaseAuth.instance.currentUser?.phoneNumber.toString().replaceAll("+91", '')}');
                                        } else {
                                          Fluttertoast.showToast(
                                            msg:
                                            'Something went wrong. Please try again.',
                                            backgroundColor: Colors.white,
                                            textColor: Colors.black,
                                          );
                                        }
                                        if (kDebugMode) {
                                          print(response.statusCode);
                                        }
                                        if(!mounted) return;
                                        Navigator.of(context).pop();
                                      }
                                    });
                                  }
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: Text(FirebaseAuth.instance.currentUser?.uid == null
                                  ? 'Signup and Submit'
                                  : 'Submit',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 15)),
                            ),
                          ),
                        ),
                      ),
                    if(Platform.isIOS)
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton(
                            color: globalColor,
                            borderRadius: BorderRadius.circular(25),
                            onPressed: () async {
                              if (!RegExp(r'^([a-zA-Z]+\s)*[a-zA-Z]+$').hasMatch(nameTextEditingController
                                  .value.text) ||
                                  !emailTextEditingController.value.text
                                      .contains("@") ||
                                  phoneTextEditingController.value.text.length < 10) {
                                form1.currentState?.validate();
                                form2.currentState?.validate();
                                form3.currentState?.validate();
                                setState(() {});
                              } else if (FirebaseAuth.instance.currentUser?.uid !=
                                  null) {
                                String emailPostUrl =
                                    "https://api.emailjs.com/api/v1.0/email/send";
                                final url = Uri.parse(emailPostUrl);
                                final response = await http.post(url,
                                    headers: {
                                      'origin': "http://localhost",
                                      'Content-Type': 'application/json',
                                    },
                                    body: json.encode({
                                      "service_id": "service_tc16pbr",
                                      "template_id": "template_5cjrgmn",
                                      "user_id": "EhQW8PzI3mUXrzJ0y",
                                      'template_params': {
                                        "message": 'Subject - ${widget.isComingFromPlan ? 'Home Loan' : 'Plan Details'}\nUser - ${nameTextEditingController.text.split(" ").first} ${nameTextEditingController.text.split(" ").last}\nPhone - ${FirebaseAuth.instance.currentUser?.phoneNumber ?? phoneTextEditingController.text}\nEmail - ${FirebaseAuth.instance.currentUser?.email ?? ((userProfileNotifier.userProfileModel.email_id == null || userProfileNotifier.userProfileModel.email_id!.isEmpty) ? emailTextEditingController.text : userProfileNotifier.userProfileModel.email_id)}\nMessage - ${messageTextEditingController.text}',
                                      }
                                    }));
                                if (response.statusCode == 200) {
                                  authNotifier.saveSubmittedPhoneNo(
                                      '+91${FirebaseAuth.instance.currentUser?.phoneNumber.toString().replaceAll("+91", '')}');
                                } else {
                                  Fluttertoast.showToast(
                                    msg:
                                    'Something went wrong. Please try again.',
                                    backgroundColor: Colors.white,
                                    textColor: Colors.black,
                                  );
                                }
                                if (kDebugMode) {
                                  print(response.statusCode);
                                }
                                if(!mounted) return;
                                Navigator.of(context).pop();
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OtpScreen(
                                        isAccountScreen: false,
                                        isComingFromHomeLoan: false,
                                        isComingFromJoinNow: false,
                                        isComingFromLogin: true,
                                        isComingFromBookAVisit: true,
                                        isComingFromKnowMore: false,
                                        phoneNo: phoneTextEditingController.text,
                                      )),
                                ).then((_) async {
                                  if (FirebaseAuth.instance.currentUser?.uid ==
                                      null) {
                                    return;
                                  } else {
                                    await userProfileNotifier
                                        .getUser(
                                        context,
                                        (FirebaseAuth.instance.currentUser?.uid)
                                            .toString(),
                                        this)
                                        .whenComplete(() async {
                                      if (userProfileNotifier.userProfileModel
                                          .firebase_user_id ==
                                          null ||
                                          userProfileNotifier.userProfileModel
                                              .firebase_user_id!.isEmpty) {
                                        if (!mounted) return;
                                        userProfileNotifier
                                            .createUser(
                                            nameTextEditingController.text.split(" ").first,
                                            nameTextEditingController.text.split(" ").last,
                                            FirebaseAuth.instance.currentUser
                                                ?.phoneNumber,
                                            emailTextEditingController.text,
                                            context)
                                            .then((_) async {
                                          await userProfileNotifier
                                              .getUser(
                                              context,
                                              (FirebaseAuth
                                                  .instance.currentUser?.uid)
                                                  .toString(),
                                              this)
                                              .then((_) async {
                                            userProfileNotifier
                                                .setIsBottomNavVisibleToTrue();
                                            await resalePropertyNotifier.getMemPlans(context);
                                            if(FirebaseAuth.instance.currentUser?.phoneNumber != null) {
                                              phoneTextEditingController.text = FirebaseAuth.instance.currentUser!.phoneNumber.toString();
                                            }
                                            if(FirebaseAuth.instance.currentUser?.email != null) {
                                              emailTextEditingController.text = FirebaseAuth.instance.currentUser!.email ?? '';
                                            } else {
                                              emailTextEditingController.text = (userProfileNotifier.userProfileModel.email_id == null || userProfileNotifier.userProfileModel.email_id!.isEmpty) ? emailTextEditingController.text : userProfileNotifier.userProfileModel.email_id!;
                                            }
                                            if((userProfileNotifier.userProfileModel.first_name != null || userProfileNotifier.userProfileModel.first_name!.isNotEmpty) && (userProfileNotifier.userProfileModel.last_name != null || userProfileNotifier.userProfileModel.last_name!.isNotEmpty)) {
                                              nameTextEditingController.text = '${userProfileNotifier.userProfileModel.first_name ?? ''} ${userProfileNotifier.userProfileModel.last_name ?? ''}';
                                            }
                                            String emailPostUrl =
                                                "https://api.emailjs.com/api/v1.0/email/send";
                                            final url = Uri.parse(emailPostUrl);
                                            final response = await http.post(url,
                                                headers: {
                                                  'origin': "http://localhost",
                                                  'Content-Type': 'application/json',
                                                },
                                                body: json.encode({
                                                  "service_id": "service_tc16pbr",
                                                  "template_id": "template_5cjrgmn",
                                                  "user_id": "EhQW8PzI3mUXrzJ0y",
                                                  'template_params': {
                                                    "message": 'Subject - ${widget.isComingFromPlan ? 'Home Loan' : 'Plan Details'}\nUser - ${nameTextEditingController.text.split(" ").first} ${nameTextEditingController.text.split(" ").last}\nPhone - ${FirebaseAuth.instance.currentUser?.phoneNumber ?? phoneTextEditingController.text}\nEmail - ${FirebaseAuth.instance.currentUser?.email ?? ((userProfileNotifier.userProfileModel.email_id == null || userProfileNotifier.userProfileModel.email_id!.isEmpty) ? emailTextEditingController.text : userProfileNotifier.userProfileModel.email_id)}\nMessage - ${messageTextEditingController.text}',
                                                  }
                                                }));
                                            if (response.statusCode == 200) {
                                              authNotifier.saveSubmittedPhoneNo(
                                                  '+91${FirebaseAuth.instance.currentUser?.phoneNumber.toString().replaceAll("+91", '')}');
                                            } else {
                                              Fluttertoast.showToast(
                                                msg:
                                                'Something went wrong. Please try again.',
                                                backgroundColor: Colors.white,
                                                textColor: Colors.black,
                                              );
                                            }
                                            if (kDebugMode) {
                                              print(response.statusCode);
                                            }
                                            if(!mounted) return;
                                            Navigator.of(context).pop();
                                          });
                                        });
                                      } else {
                                        await resalePropertyNotifier.getMemPlans(context);
                                        if(FirebaseAuth.instance.currentUser?.phoneNumber != null) {
                                          phoneTextEditingController.text = FirebaseAuth.instance.currentUser!.phoneNumber.toString();
                                        }
                                        if(FirebaseAuth.instance.currentUser?.email != null) {
                                          emailTextEditingController.text = FirebaseAuth.instance.currentUser!.email ?? '';
                                        } else {
                                          emailTextEditingController.text = (userProfileNotifier.userProfileModel.email_id == null || userProfileNotifier.userProfileModel.email_id!.isEmpty) ? emailTextEditingController.text : userProfileNotifier.userProfileModel.email_id!;
                                        }
                                        if((userProfileNotifier.userProfileModel.first_name != null || userProfileNotifier.userProfileModel.first_name!.isNotEmpty) && (userProfileNotifier.userProfileModel.last_name != null || userProfileNotifier.userProfileModel.last_name!.isNotEmpty)) {
                                          nameTextEditingController.text = '${userProfileNotifier.userProfileModel.first_name ?? ''} ${userProfileNotifier.userProfileModel.last_name ?? ''}';
                                        }
                                        String emailPostUrl =
                                            "https://api.emailjs.com/api/v1.0/email/send";
                                        final url = Uri.parse(emailPostUrl);
                                        final response = await http.post(url,
                                            headers: {
                                              'origin': "http://localhost",
                                              'Content-Type': 'application/json',
                                            },
                                            body: json.encode({
                                              "service_id": "service_tc16pbr",
                                              "template_id": "template_5cjrgmn",
                                              "user_id": "EhQW8PzI3mUXrzJ0y",
                                              'template_params': {
                                                "message": 'Subject - ${widget.isComingFromPlan ? 'Home Loan' : 'Plan Details'}\nUser - ${nameTextEditingController.text.split(" ").first} ${nameTextEditingController.text.split(" ").last}\nPhone - ${FirebaseAuth.instance.currentUser?.phoneNumber ?? phoneTextEditingController.text}\nEmail - ${FirebaseAuth.instance.currentUser?.email ?? ((userProfileNotifier.userProfileModel.email_id == null || userProfileNotifier.userProfileModel.email_id!.isEmpty) ? emailTextEditingController.text : userProfileNotifier.userProfileModel.email_id)}\nMessage - ${messageTextEditingController.text}',
                                              }
                                            }));
                                        if (response.statusCode == 200) {
                                          authNotifier.saveSubmittedPhoneNo(
                                              '+91${FirebaseAuth.instance.currentUser?.phoneNumber.toString().replaceAll("+91", '')}');
                                        } else {
                                          Fluttertoast.showToast(
                                            msg:
                                            'Something went wrong. Please try again.',
                                            backgroundColor: Colors.white,
                                            textColor: Colors.black,
                                          );
                                        }
                                        if (kDebugMode) {
                                          print(response.statusCode);
                                        }
                                        if(!mounted) return;
                                        Navigator.of(context).pop();
                                      }
                                    });
                                  }
                                });
                              }
                            },
                            child: Text(FirebaseAuth.instance.currentUser?.uid == null
                                ? 'Signup and Submit'
                                : 'Submit',
                                style: const TextStyle(
                                    color: CupertinoColors.white, fontSize: 15))),
                      ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 5),
                      child: ReadMoreText(
                        'By clicking the above button, you consent to receive  calls and messages from squarest (Apartmint Solutions Private Limited), its business associates and partners about your interest in this and other property related matters. This consent applies even if you are registered on the National Do Not Call Registry.',
                        trimLines: 2,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: 'more',
                        colorClickableText: globalColor,
                        trimExpandedText: 'less',
                        style: TextStyle(
                          fontSize: 14,
                          color: (MediaQuery.of(context).platformBrightness ==
                              Brightness.dark)
                              ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                              : Colors.grey[600],
                        ),
                        // moreStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 15,),
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
                    const SizedBox(height: 15,),
                    if(Platform.isAndroid)
                      Center(
                        child: SizedBox(
                          height: 60,
                          width: double.infinity,
                          child: TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: globalColor),
                            onPressed: _launchCaller,
                            child: const Padding(
                              padding: EdgeInsets.only(top: 8, bottom: 8),
                              child: Text('Talk to us',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15)),
                            ),
                          ),
                        ),
                      ),
                    if(Platform.isIOS)
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton(
                          color: globalColor,
                          borderRadius: BorderRadius.circular(25),
                          onPressed: _launchCaller,
                          child: const Text('Talk to us',
                              style: TextStyle(
                                  color: CupertinoColors.white, fontSize: 15)),),
                      ),
                    const SizedBox(height: 5,)
                  ],
                ),
              ),
            )));
  }

  _launchCaller() async {
    const url = "tel:7387946211";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      Fluttertoast.showToast(
        msg: 'Something went wrong. Please call 7387946211',
        backgroundColor: Platform.isAndroid ? Colors.white : CupertinoColors.white,
        textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }
}
