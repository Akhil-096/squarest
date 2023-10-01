import 'dart:convert';
import 'dart:io';
import 'package:squarest/Views/v_otp_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_date_picker_fork/flutter_cupertino_date_picker_fork.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Models/m_project.dart';
import '../Services/s_autocomplete_notifier.dart';
import '../Services/s_resale_property_notifier.dart';
import '../Services/s_user_profile_notifier.dart';
import '../Utils/u_constants.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../Utils/u_custom_styles.dart';

class BookAVisit extends StatefulWidget {
  // final DateTime selectedDate;
  final Project project;
  final String appBarTitle;
  final bool isComingFromContactUs;

  const BookAVisit(
      {required this.project,
      required this.appBarTitle,
      required this.isComingFromContactUs,
      Key? key})
      : super(key: key);

  @override
  State<BookAVisit> createState() => _BookAVisitState();
}

class _BookAVisitState extends State<BookAVisit> {
  bool isTimeSlot1Selected = false;
  bool isTimeSlot2Selected = false;
  bool isTimeSlot3Selected = false;

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
    messageTextEditingController = TextEditingController(text: '');
    if (widget.isComingFromContactUs) {
      messageTextEditingController.text =
          'I would like more information regarding the property ${widget.project.name_of_project} at ${widget.project.project_village} ${widget.project.project_district}';
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
    final autoCompleteNotifier = Provider.of<AutocompleteNotifier>(context);
    final resalePropertyNotifier = Provider.of<ResalePropertyNotifier>(context);

    return Scaffold(
        appBar: Platform.isAndroid
            ? PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: AppBar(
                  scrolledUnderElevation: 0.0,
                  backgroundColor: (MediaQuery.of(context).platformBrightness ==
                          Brightness.dark)
                      ? Colors.grey[900]
                      : Colors.white,
                  title: Text(
                    widget.appBarTitle,
                    style: CustomTextStyles.getTitle(
                        null,
                        (MediaQuery.of(context).platformBrightness ==
                                Brightness.dark)
                            ? Colors.white
                            : Colors.black,
                        null,
                        19),
                  ),
                ),
              )
            : CupertinoNavigationBar(
                backgroundColor: (MediaQuery.of(context).platformBrightness ==
                        Brightness.dark)
                    ? Colors.grey[900]
                    : CupertinoColors.white,
                middle: Text(
                  widget.appBarTitle,
                  style: CustomTextStyles.getTitle(
                      null,
                      (MediaQuery.of(context).platformBrightness ==
                              Brightness.dark)
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
                if (widget.isComingFromContactUs)
                  const SizedBox(
                    height: 10,
                  ),
                if (!widget.isComingFromContactUs)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('d MMMM yyyy').format(
                            autoCompleteNotifier.selectedDate ??
                                DateTime.now()),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      // const SizedBox(
                      //   width: 20,
                      // ),
                      ActionChip(
                        padding:
                            const EdgeInsets.only(left: 3, top: 2, bottom: 2),
                        avatar: CircleAvatar(
                            backgroundColor: globalColor,
                            child: Icon(
                              Platform.isAndroid
                                  ? Icons.calendar_month
                                  : CupertinoIcons.calendar_today,
                              size: 18,
                              color: Colors.white,
                            )),
                        label: const Text(
                          'Change',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: Platform.isAndroid
                            ? _showDatePicker
                            : () {
                                DatePicker.showDatePicker(
                                  context,
                                  pickerTheme: DateTimePickerTheme(
                                    cancelTextStyle: const TextStyle(
                                        color: CupertinoColors.destructiveRed),
                                    backgroundColor: (MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.dark)
                                        ? Colors.grey[900]!
                                        : CupertinoColors.white,
                                    itemTextStyle: TextStyle(
                                      color: (MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.dark)
                                          ? CupertinoColors.white
                                          : CupertinoColors.black,
                                    ),
                                    confirmTextStyle: const TextStyle(
                                        color: CupertinoColors.systemBlue),
                                  ),
                                  onMonthChangeStartWithFirstDate: true,
                                  initialDateTime: DateTime(
                                      DateTime.now().year,
                                      DateTime.now().month,
                                      DateTime.now().day + 1),
                                  minDateTime: DateTime(
                                      DateTime.now().year,
                                      DateTime.now().month,
                                      DateTime.now().day + 1),
                                  pickerMode: DateTimePickerMode.date,
                                  maxDateTime: DateTime(
                                          DateTime.now().year,
                                          DateTime.now().month,
                                          DateTime.now().day + 1)
                                      .add(const Duration(days: 15)),
                                  onChange: null,
                                  onClose: null,
                                  onCancel: null,
                                  onConfirm: (date, _) {
                                    autoCompleteNotifier.setSelectedDate(date);
                                  },
                                );
                              },
                        backgroundColor:
                            (MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark)
                                ? Colors.grey[800]
                                : Colors.grey[100],
                        shape: const StadiumBorder(
                            side: BorderSide(
                          width: 1,
                        )),
                      )
                    ],
                  ),
                if (!widget.isComingFromContactUs)
                  const SizedBox(
                    height: 15,
                  ),
                if (!widget.isComingFromContactUs)
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Flexible(
                          child: SizedBox(
                            height: 70,
                            child: FilterChip(
                              showCheckmark: false,
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              backgroundColor: Platform.isAndroid
                                  ? Colors.white
                                  : CupertinoColors.white,
                              selectedColor: globalColor,
                              disabledColor: Platform.isAndroid
                                  ? Colors.blue
                                  : CupertinoColors.systemBlue,
                              label: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Morning',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: isTimeSlot1Selected
                                            ? Platform.isAndroid
                                                ? Colors.white
                                                : CupertinoColors.white
                                            : Platform.isAndroid
                                                ? Colors.black
                                                : CupertinoColors.black,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    '10 am - 1 pm',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: isTimeSlot1Selected
                                            ? Platform.isAndroid
                                                ? Colors.white
                                                : CupertinoColors.white
                                            : Platform.isAndroid
                                                ? Colors.black
                                                : CupertinoColors.black),
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                              selected: isTimeSlot1Selected,
                              onSelected: (_) {
                                setState(() {
                                  isTimeSlot1Selected = !isTimeSlot1Selected;
                                });
                                if (isTimeSlot1Selected) {
                                  setState(() {
                                    isTimeSlot2Selected = false;
                                    isTimeSlot3Selected = false;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        Flexible(
                          child: SizedBox(
                            height: 70,
                            child: FilterChip(
                              showCheckmark: false,
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              backgroundColor: Platform.isAndroid
                                  ? Colors.white
                                  : CupertinoColors.white,
                              selectedColor: globalColor,
                              disabledColor: Platform.isAndroid
                                  ? Colors.blue
                                  : CupertinoColors.systemBlue,
                              label: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Afternoon',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: isTimeSlot2Selected
                                            ? Platform.isAndroid
                                                ? Colors.white
                                                : CupertinoColors.white
                                            : Platform.isAndroid
                                                ? Colors.black
                                                : CupertinoColors.black,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    '1 pm - 4 pm',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: isTimeSlot2Selected
                                            ? Platform.isAndroid
                                                ? Colors.white
                                                : CupertinoColors.white
                                            : Platform.isAndroid
                                                ? Colors.black
                                                : CupertinoColors.black),
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                              selected: isTimeSlot2Selected,
                              onSelected: (_) {
                                setState(() {
                                  isTimeSlot2Selected = !isTimeSlot2Selected;
                                });
                                if (isTimeSlot2Selected) {
                                  setState(() {
                                    isTimeSlot1Selected = false;
                                    isTimeSlot3Selected = false;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        Flexible(
                          child: SizedBox(
                            height: 70,
                            child: FilterChip(
                              showCheckmark: false,
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              backgroundColor: Platform.isAndroid
                                  ? Colors.white
                                  : CupertinoColors.white,
                              selectedColor: globalColor,
                              disabledColor: Platform.isAndroid
                                  ? Colors.blue
                                  : CupertinoColors.systemBlue,
                              label: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Evening',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: isTimeSlot3Selected
                                            ? Platform.isAndroid
                                                ? Colors.white
                                                : CupertinoColors.white
                                            : Platform.isAndroid
                                                ? Colors.black
                                                : CupertinoColors.black,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    '4 pm - 7 pm',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: isTimeSlot3Selected
                                            ? Platform.isAndroid
                                                ? Colors.white
                                                : CupertinoColors.white
                                            : Platform.isAndroid
                                                ? Colors.black
                                                : CupertinoColors.black),
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                              selected: isTimeSlot3Selected,
                              onSelected: (_) {
                                setState(() {
                                  isTimeSlot3Selected = !isTimeSlot3Selected;
                                });
                                if (isTimeSlot3Selected) {
                                  setState(() {
                                    isTimeSlot1Selected = false;
                                    isTimeSlot2Selected = false;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ]),
                if (!widget.isComingFromContactUs)
                  const SizedBox(
                    height: 20,
                  ),
                Form(
                  key: form1,
                  child: Container(
                    decoration: Platform.isAndroid
                        ? null : BoxDecoration(
                        color: null,
                        border: Border.all(
                          width: 1,
                          color: (MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark)
                              ? Platform.isAndroid
                                  ? Colors.grey
                                  : CupertinoColors.systemGrey
                              : Platform.isAndroid
                                  ? Colors.black
                                  : CupertinoColors.black,
                        ),
                        borderRadius: BorderRadius.circular(25)),
                    child: Platform.isAndroid
                        ? TextFormField(
                            controller: nameTextEditingController,
                            onChanged: (value) {
                              if (RegExp(r'^([a-zA-Z]+\s)*[a-zA-Z]+$')
                                  .hasMatch(value)) {
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
                              if (!RegExp(r'^([a-zA-Z]+\s)*[a-zA-Z]+$')
                                  .hasMatch(value!)) {
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
                          )
                        : CupertinoTextFormFieldRow(
                            decoration: const BoxDecoration(
                              color: null,
                            ),
                            style: TextStyle(
                              color:
                                  (MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark)
                                      ? CupertinoColors.white
                                      : CupertinoColors.black,
                            ),
                            padding: const EdgeInsets.all(10),
                            controller: nameTextEditingController,
                            onChanged: (value) {
                              if (RegExp(r'^([a-zA-Z]+\s)*[a-zA-Z]+$')
                                  .hasMatch(value)) {
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
                              if (!RegExp(r'^([a-zA-Z]+\s)*[a-zA-Z]+$')
                                  .hasMatch(value!)) {
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
                  child: Container(
                    decoration: Platform.isAndroid
                        ? null : BoxDecoration(
                        color: null,
                        border: Border.all(
                          width: 1,
                          color: (MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark)
                              ? Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey
                              : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                        ),
                        borderRadius: BorderRadius.circular(25)),
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
                      controller: emailTextEditingController,
                      enabled: (FirebaseAuth.instance.currentUser?.uid !=
                                  null &&
                              FirebaseAuth.instance.currentUser?.email != null)
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
                  child: Container(
                    decoration: Platform.isAndroid
                        ? null : BoxDecoration(
                        color: null,
                        border: Border.all(
                          width: 1,
                          color: (MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark)
                              ? Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey
                              : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                        ),
                        borderRadius: BorderRadius.circular(25)),
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
                      controller: phoneTextEditingController,
                      enabled: (FirebaseAuth.instance.currentUser?.uid !=
                                  null &&
                              FirebaseAuth.instance.currentUser?.phoneNumber !=
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
                  },
                  // validator: (value) {
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
                    onChanged: (value) {},
                    // validator: (value) {},
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
                        if (!widget.isComingFromContactUs && (!isTimeSlot1Selected &&
                            !isTimeSlot2Selected &&
                            !isTimeSlot3Selected)) {
                          Fluttertoast.showToast(
                            msg: 'Please select a time slot',
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                            toastLength: Toast.LENGTH_LONG,
                          );
                        } else if (!RegExp(r'^([a-zA-Z]+\s)*[a-zA-Z]+$').hasMatch(nameTextEditingController
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
                                  "message": 'Subject - ${widget.isComingFromContactUs ? 'More Info-New' : 'Book Site Visit'}\nProject - ${widget.project.name_of_project}\nUser - ${nameTextEditingController.text.split(" ").first} ${nameTextEditingController.text.split(" ").last}\nPhone - ${FirebaseAuth.instance.currentUser?.phoneNumber ?? phoneTextEditingController.text}\nEmail - ${FirebaseAuth.instance.currentUser?.email ?? ((userProfileNotifier.userProfileModel.email_id == null || userProfileNotifier.userProfileModel.email_id!.isEmpty) ? emailTextEditingController.text : userProfileNotifier.userProfileModel.email_id)}\nMessage - ${messageTextEditingController.text}${!widget.isComingFromContactUs ? '\nDate - ${DateFormat('d MMMM yyyy').format(autoCompleteNotifier.selectedDate ?? DateTime.now())}' : '\nDate - ${DateFormat('dd/MM/yyyy').format(DateTime.now())}'}${!widget.isComingFromContactUs ? '\n${isTimeSlot1Selected ? '10 am - 1 pm' : isTimeSlot2Selected ? '1 pm - 4 pm' : '4 pm - 7 pm'}' : ''}',
                                }
                              }));
                          if (response.statusCode == 200) {
                            Fluttertoast.showToast(
                              msg: widget.isComingFromContactUs ? 'Submit done successfully. We will contact you shortly.' :
                              'Booking done successfully. We will contact you shortly.',
                              backgroundColor: Colors.white,
                              textColor: Colors.black,
                              toastLength: Toast.LENGTH_LONG,
                            );
                            if(!mounted) return;
                            Navigator.of(context).pop();
                          } else {
                            Fluttertoast.showToast(
                              msg:
                              'Something went wrong. Please try again.',
                              backgroundColor: Colors.white,
                              textColor: Colors.black,
                              toastLength: Toast.LENGTH_LONG,
                            );
                          }
                          if (kDebugMode) {
                            print(response.statusCode);
                          }
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
                                              "message": 'Subject - ${widget.isComingFromContactUs ? 'More Info-New' : 'Book Site Visit'}\nProject - ${widget.project.name_of_project}\nUser - ${nameTextEditingController.text.split(" ").first} ${nameTextEditingController.text.split(" ").last}\nPhone - ${FirebaseAuth.instance.currentUser?.phoneNumber ?? phoneTextEditingController.text}\nEmail - ${FirebaseAuth.instance.currentUser?.email ?? ((userProfileNotifier.userProfileModel.email_id == null || userProfileNotifier.userProfileModel.email_id!.isEmpty) ? emailTextEditingController.text : userProfileNotifier.userProfileModel.email_id)}\nMessage - ${messageTextEditingController.text}${!widget.isComingFromContactUs ? '\nDate - ${DateFormat('d MMMM yyyy').format(autoCompleteNotifier.selectedDate ?? DateTime.now())}' : '\nDate - ${DateFormat('dd/MM/yyyy').format(DateTime.now())}'}${!widget.isComingFromContactUs ? '\n${isTimeSlot1Selected ? '10 am - 1 pm' : isTimeSlot2Selected ? '1 pm - 4 pm' : '4 pm - 7 pm'}' : ''}',
                                            }
                                          }));
                                      if (response.statusCode == 200) {
                                        Fluttertoast.showToast(
                                          msg: widget.isComingFromContactUs ? 'SignUp and submit successful. We will contact you shortly.' :
                                          'SignUp and booking done successfully. We will contact you shortly.',
                                          backgroundColor: Colors.white,
                                          textColor: Colors.black,
                                          toastLength: Toast.LENGTH_LONG,
                                        );
                                        if(!mounted) return;
                                        Navigator.of(context).pop();
                                      } else {
                                        Fluttertoast.showToast(
                                          msg:
                                          'Something went wrong. Please try again.',
                                          backgroundColor: Colors.white,
                                          textColor: Colors.black,
                                          toastLength: Toast.LENGTH_LONG,
                                        );
                                      }
                                      if (kDebugMode) {
                                        print(response.statusCode);
                                      }
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
                                          "message": 'Subject - ${widget.isComingFromContactUs ? 'More Info-New' : 'Book Site Visit'}\nProject - ${widget.project.name_of_project}\nUser - ${nameTextEditingController.text.split(" ").first} ${nameTextEditingController.text.split(" ").last}\nPhone - ${FirebaseAuth.instance.currentUser?.phoneNumber ?? phoneTextEditingController.text}\nEmail - ${FirebaseAuth.instance.currentUser?.email ?? ((userProfileNotifier.userProfileModel.email_id == null || userProfileNotifier.userProfileModel.email_id!.isEmpty) ? emailTextEditingController.text : userProfileNotifier.userProfileModel.email_id)}\nMessage - ${messageTextEditingController.text}${!widget.isComingFromContactUs ? '\nDate - ${DateFormat('d MMMM yyyy').format(autoCompleteNotifier.selectedDate ?? DateTime.now())}' : '\nDate - ${DateFormat('dd/MM/yyyy').format(DateTime.now())}'}${!widget.isComingFromContactUs ? '\n${isTimeSlot1Selected ? '10 am - 1 pm' : isTimeSlot2Selected ? '1 pm - 4 pm' : '4 pm - 7 pm'}' : ''}',
                                        }
                                      }));
                                  if (response.statusCode == 200) {
                                    Fluttertoast.showToast(
                                      msg: widget.isComingFromContactUs ? 'Sign in and submit successful. We will contact you shortly.' :
                                      'Sign in and booking done successfully. We will contact you shortly.',
                                      backgroundColor: Colors.white,
                                      textColor: Colors.black,
                                      toastLength: Toast.LENGTH_LONG,
                                    );
                                    if(!mounted) return;
                                    Navigator.of(context).pop();
                                  } else {
                                    Fluttertoast.showToast(
                                      msg:
                                      'Something went wrong. Please try again.',
                                      backgroundColor: Colors.white,
                                      textColor: Colors.black,
                                      toastLength: Toast.LENGTH_LONG,
                                    );
                                  }
                                  if (kDebugMode) {
                                    print(response.statusCode);
                                  }
                                }
                              });
                            }
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: widget.isComingFromContactUs ? Text(FirebaseAuth.instance.currentUser?.uid == null
                            ? 'Signup and Submit'
                            : 'Submit',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15)) : Text(
                            FirebaseAuth.instance.currentUser?.uid == null
                                ? 'Signup and Book Visit'
                                : 'Book Visit',
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
                    child: widget.isComingFromContactUs
                        ? Text(
                            FirebaseAuth.instance.currentUser?.uid == null
                                ? 'Signup and Submit'
                                : 'Submit',
                            style: const TextStyle(
                                color: CupertinoColors.white, fontSize: 15))
                        : Text(
                            FirebaseAuth.instance.currentUser?.uid == null
                                ? 'Signup and Book Visit'
                                : 'Book Visit',
                            style: const TextStyle(
                                color: CupertinoColors.white, fontSize: 15)),
                    onPressed: () async {
                      if (!widget.isComingFromContactUs &&
                          (!isTimeSlot1Selected &&
                              !isTimeSlot2Selected &&
                              !isTimeSlot3Selected)) {
                        Fluttertoast.showToast(
                          msg: 'Please select a time slot',
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          toastLength: Toast.LENGTH_LONG,
                        );
                      } else if (!RegExp(r'^([a-zA-Z]+\s)*[a-zA-Z]+$')
                              .hasMatch(nameTextEditingController.value.text) ||
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
                                "message":
                                    'Subject - ${widget.isComingFromContactUs ? 'More Info-New' : 'Book Site Visit'}\nProject - ${widget.project.name_of_project}\nUser - ${nameTextEditingController.text.split(" ").first} ${nameTextEditingController.text.split(" ").last}\nPhone - ${FirebaseAuth.instance.currentUser?.phoneNumber ?? phoneTextEditingController.text}\nEmail - ${FirebaseAuth.instance.currentUser?.email ?? ((userProfileNotifier.userProfileModel.email_id == null || userProfileNotifier.userProfileModel.email_id!.isEmpty) ? emailTextEditingController.text : userProfileNotifier.userProfileModel.email_id)}\nMessage - ${messageTextEditingController.text}${!widget.isComingFromContactUs ? '\nDate - ${DateFormat('d MMMM yyyy').format(autoCompleteNotifier.selectedDate ?? DateTime.now())}' : '\nDate - ${DateFormat('dd/MM/yyyy').format(DateTime.now())}'}${!widget.isComingFromContactUs ? '\n${isTimeSlot1Selected ? '10 am - 1 pm' : isTimeSlot2Selected ? '1 pm - 4 pm' : '4 pm - 7 pm'}' : ''}',
                              }
                            }));
                        if (response.statusCode == 200) {
                          Fluttertoast.showToast(
                            msg: widget.isComingFromContactUs
                                ? 'Submit done successfully. We will contact you shortly.'
                                : 'Booking done successfully. We will contact you shortly.',
                            backgroundColor: CupertinoColors.white,
                            textColor: CupertinoColors.black,
                            toastLength: Toast.LENGTH_LONG,
                          );
                          if (!mounted) return;
                          Navigator.of(context).pop();
                        } else {
                          Fluttertoast.showToast(
                            msg: 'Something went wrong. Please try again.',
                            backgroundColor: CupertinoColors.white,
                            textColor: CupertinoColors.black,
                            toastLength: Toast.LENGTH_LONG,
                          );
                        }
                        if (kDebugMode) {
                          print(response.statusCode);
                        }
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
                          if (FirebaseAuth.instance.currentUser?.uid == null) {
                            return;
                          } else {
                            await userProfileNotifier
                                .getUser(
                                    context,
                                    (FirebaseAuth.instance.currentUser?.uid)
                                        .toString(),
                                    this)
                                .whenComplete(() async {
                              if (userProfileNotifier
                                          .userProfileModel.firebase_user_id ==
                                      null ||
                                  userProfileNotifier.userProfileModel
                                      .firebase_user_id!.isEmpty) {
                                if (!mounted) return;
                                userProfileNotifier
                                    .createUser(
                                        nameTextEditingController.text
                                            .split(" ")
                                            .first,
                                        nameTextEditingController.text
                                            .split(" ")
                                            .last,
                                        FirebaseAuth
                                            .instance.currentUser?.phoneNumber,
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
                                    await resalePropertyNotifier
                                        .getMemPlans(context);
                                    if (FirebaseAuth.instance.currentUser
                                            ?.phoneNumber !=
                                        null) {
                                      phoneTextEditingController.text =
                                          FirebaseAuth
                                              .instance.currentUser!.phoneNumber
                                              .toString();
                                    }
                                    if (FirebaseAuth
                                            .instance.currentUser?.email !=
                                        null) {
                                      emailTextEditingController.text =
                                          FirebaseAuth.instance.currentUser!
                                                  .email ??
                                              '';
                                    } else {
                                      emailTextEditingController.text =
                                          (userProfileNotifier.userProfileModel
                                                          .email_id ==
                                                      null ||
                                                  userProfileNotifier
                                                      .userProfileModel
                                                      .email_id!
                                                      .isEmpty)
                                              ? emailTextEditingController.text
                                              : userProfileNotifier
                                                  .userProfileModel.email_id!;
                                    }
                                    if ((userProfileNotifier.userProfileModel
                                                    .first_name !=
                                                null ||
                                            userProfileNotifier.userProfileModel
                                                .first_name!.isNotEmpty) &&
                                        (userProfileNotifier.userProfileModel
                                                    .last_name !=
                                                null ||
                                            userProfileNotifier.userProfileModel
                                                .last_name!.isNotEmpty)) {
                                      nameTextEditingController.text =
                                          '${userProfileNotifier.userProfileModel.first_name ?? ''} ${userProfileNotifier.userProfileModel.last_name ?? ''}';
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
                                            "message":
                                                'Subject - ${widget.isComingFromContactUs ? 'More Info-New' : 'Book Site Visit'}\nProject - ${widget.project.name_of_project}\nUser - ${nameTextEditingController.text.split(" ").first} ${nameTextEditingController.text.split(" ").last}\nPhone - ${FirebaseAuth.instance.currentUser?.phoneNumber ?? phoneTextEditingController.text}\nEmail - ${FirebaseAuth.instance.currentUser?.email ?? ((userProfileNotifier.userProfileModel.email_id == null || userProfileNotifier.userProfileModel.email_id!.isEmpty) ? emailTextEditingController.text : userProfileNotifier.userProfileModel.email_id)}\nMessage - ${messageTextEditingController.text}${!widget.isComingFromContactUs ? '\nDate - ${DateFormat('d MMMM yyyy').format(autoCompleteNotifier.selectedDate ?? DateTime.now())}' : '\nDate - ${DateFormat('dd/MM/yyyy').format(DateTime.now())}'}${!widget.isComingFromContactUs ? '\n${isTimeSlot1Selected ? '10 am - 1 pm' : isTimeSlot2Selected ? '1 pm - 4 pm' : '4 pm - 7 pm'}' : ''}',
                                          }
                                        }));
                                    if (response.statusCode == 200) {
                                      Fluttertoast.showToast(
                                        msg: widget.isComingFromContactUs
                                            ? 'SignUp and submit successful. We will contact you shortly.'
                                            : 'SignUp and booking done successfully. We will contact you shortly.',
                                        backgroundColor: CupertinoColors.white,
                                        textColor: CupertinoColors.black,
                                        toastLength: Toast.LENGTH_LONG,
                                      );
                                      if (!mounted) return;
                                      Navigator.of(context).pop();
                                    } else {
                                      Fluttertoast.showToast(
                                        msg:
                                            'Something went wrong. Please try again.',
                                        backgroundColor: CupertinoColors.white,
                                        textColor: CupertinoColors.black,
                                        toastLength: Toast.LENGTH_LONG,
                                      );
                                    }
                                    if (kDebugMode) {
                                      print(response.statusCode);
                                    }
                                  });
                                });
                              } else {
                                await resalePropertyNotifier
                                    .getMemPlans(context);
                                if (FirebaseAuth
                                        .instance.currentUser?.phoneNumber !=
                                    null) {
                                  phoneTextEditingController.text = FirebaseAuth
                                      .instance.currentUser!.phoneNumber
                                      .toString();
                                }
                                if (FirebaseAuth.instance.currentUser?.email !=
                                    null) {
                                  emailTextEditingController.text = FirebaseAuth
                                          .instance.currentUser!.email ??
                                      '';
                                } else {
                                  emailTextEditingController.text =
                                      (userProfileNotifier.userProfileModel
                                                      .email_id ==
                                                  null ||
                                              userProfileNotifier
                                                  .userProfileModel
                                                  .email_id!
                                                  .isEmpty)
                                          ? emailTextEditingController.text
                                          : userProfileNotifier
                                              .userProfileModel.email_id!;
                                }
                                if ((userProfileNotifier
                                                .userProfileModel.first_name !=
                                            null ||
                                        userProfileNotifier.userProfileModel
                                            .first_name!.isNotEmpty) &&
                                    (userProfileNotifier
                                                .userProfileModel.last_name !=
                                            null ||
                                        userProfileNotifier.userProfileModel
                                            .last_name!.isNotEmpty)) {
                                  nameTextEditingController.text =
                                      '${userProfileNotifier.userProfileModel.first_name ?? ''} ${userProfileNotifier.userProfileModel.last_name ?? ''}';
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
                                        "message":
                                            'Subject - ${widget.isComingFromContactUs ? 'More Info-New' : 'Book Site Visit'}\nProject - ${widget.project.name_of_project}\nUser - ${nameTextEditingController.text.split(" ").first} ${nameTextEditingController.text.split(" ").last}\nPhone - ${FirebaseAuth.instance.currentUser?.phoneNumber ?? phoneTextEditingController.text}\nEmail - ${FirebaseAuth.instance.currentUser?.email ?? ((userProfileNotifier.userProfileModel.email_id == null || userProfileNotifier.userProfileModel.email_id!.isEmpty) ? emailTextEditingController.text : userProfileNotifier.userProfileModel.email_id)}\nMessage - ${messageTextEditingController.text}${!widget.isComingFromContactUs ? '\nDate - ${DateFormat('d MMMM yyyy').format(autoCompleteNotifier.selectedDate ?? DateTime.now())}' : '\nDate - ${DateFormat('dd/MM/yyyy').format(DateTime.now())}'}${!widget.isComingFromContactUs ? '\n${isTimeSlot1Selected ? '10 am - 1 pm' : isTimeSlot2Selected ? '1 pm - 4 pm' : '4 pm - 7 pm'}' : ''}',
                                      }
                                    }));
                                if (response.statusCode == 200) {
                                  Fluttertoast.showToast(
                                    msg: widget.isComingFromContactUs
                                        ? 'Sign in and submit successful. We will contact you shortly.'
                                        : 'Sign in and booking done successfully. We will contact you shortly.',
                                    backgroundColor: CupertinoColors.white,
                                    textColor: CupertinoColors.black,
                                    toastLength: Toast.LENGTH_LONG,
                                  );
                                  if (!mounted) return;
                                  Navigator.of(context).pop();
                                } else {
                                  Fluttertoast.showToast(
                                    msg:
                                        'Something went wrong. Please try again.',
                                    backgroundColor: CupertinoColors.white,
                                    textColor: CupertinoColors.black,
                                    toastLength: Toast.LENGTH_LONG,
                                  );
                                }
                                if (kDebugMode) {
                                  print(response.statusCode);
                                }
                              }
                            });
                          }
                        });
                      }
                    },
                  ),
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
                          ? CupertinoColors.white
                          : Colors.grey[600],
                    ),
                    // moreStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                if (widget.isComingFromContactUs)
                  const SizedBox(
                    height: 15,
                  ),
                if (widget.isComingFromContactUs)
                Container(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Row(children: <Widget>[
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          child: Divider(
                            color: (MediaQuery.of(context).platformBrightness ==
                                Brightness.dark)
                                ? Colors.grey[700]
                                : Colors.grey[300]!,
                          ),
                        ),
                      ),
                      const Text("or"),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          child: Divider(
                            color: (MediaQuery.of(context).platformBrightness ==
                                Brightness.dark)
                                ? Colors.grey[700]
                                : Colors.grey[300]!,
                          ),
                        ),
                      ),
                    ]),
                  ),
                if (widget.isComingFromContactUs)
                const SizedBox(
                    height: 15,
                  ),
                if (widget.isComingFromContactUs && Platform.isAndroid)
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
                              style: TextStyle(color: Colors.white, fontSize: 15)),
                        ),
                      ),
                    ),
                  ),
                if (widget.isComingFromContactUs && Platform.isIOS)
                SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: globalColor,
                      borderRadius: BorderRadius.circular(25),
                      onPressed: _launchCaller,
                      child: const Text('Talk to us',
                          style: TextStyle(color: Colors.white, fontSize: 15)),
                    ),
                  ),
                const SizedBox(
                  height: 5,
                ),
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
        backgroundColor: Colors.white,
        textColor: Colors.black,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  void _showDatePicker() {
    final autoCompleteNotifier =
        Provider.of<AutocompleteNotifier>(context, listen: false);
    showDatePicker(
            context: context,
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: globalColor, // header background color
                    onPrimary: Colors.white, // header text color
                    onSurface: (MediaQuery.of(context).platformBrightness ==
                            Brightness.dark)
                        ? Colors.white
                        : Colors.black, // body text color
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: globalColor, // button text color
                    ),
                  ),
                ),
                child: child ?? const SizedBox(),
              );
            },
            initialDate: DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day + 1),
            firstDate: DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day + 1),
            lastDate: DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day + 1)
                .add(const Duration(days: 15)))
        .then((pickedDate) {
      if (pickedDate == null) {
        return;
      } else {
        // setState(() {
        autoCompleteNotifier.setSelectedDate(pickedDate);
        // });
        // Navigator.of(context).push(
        //     MaterialPageRoute(
        //         builder: (ctx) => BookAVisit(selectedDate: _selectedDate ?? DateTime(DateTime.now().year), project: widget.project, appBarTitle: "Book Site Visit", isComingFromContactUs: false,))).then((value) {
        //   setState(() {
        //     _selectedDate = null;
        //   });
        // });
      }
    });
  }
}
