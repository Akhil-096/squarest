import 'dart:convert';
import 'dart:io';
import 'package:squarest/Services/s_user_profile_notifier.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../Services/s_auth_notifier.dart';
import '../Utils/u_constants.dart';
import 'package:readmore/readmore.dart';

class ApplyHomeLoan extends StatefulWidget {
  const ApplyHomeLoan({Key? key}) : super(key: key);

  @override
  State<ApplyHomeLoan> createState() => _ApplyHomeLoanState();
}

class _ApplyHomeLoanState extends State<ApplyHomeLoan> {
  bool checkBoxValue = false;
  bool checkBoxValidation = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = Provider.of<AuthNotifier>(context);
    final userProfileNotifier = Provider.of<UserProfileNotifier>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'We will contact you on this number',
          style: TextStyle(
              color:
                  (MediaQuery.of(context).platformBrightness == Brightness.dark)
                      ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                      : Colors.grey[600]),
        ),
        const SizedBox(
          height: 10,
        ),
        Text((FirebaseAuth.instance.currentUser?.phoneNumber)
            .toString(),
        style: const TextStyle(fontSize: 18),
    ),
        const SizedBox(
          height: 40,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 24.0,
                  width: 24.0,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      unselectedWidgetColor:
                          !checkBoxValidation ? (Platform.isAndroid ? Colors.red : CupertinoColors.systemRed) : null,
                    ),
                    child: Checkbox(
                      activeColor: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                      value: checkBoxValue,
                      onChanged: (value) {
                        setState(() {
                          checkBoxValue = value!;
                          checkBoxValidation = true;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            // if (checkBoxValue)
            Expanded(
              child: ReadMoreText(
                'I give my consent to squarest (Apartmint Solutions Pvt. Ltd.), its business associates and/or partners to call, sms or email me regarding my interest for a home loan or for offering related products and services... ',
                trimLines: 2,
                // colorClickableText: Colors.white,
                trimMode: TrimMode.Line,
                trimCollapsedText: 'more',
                colorClickableText: globalColor,
                trimExpandedText: 'less',
                style: TextStyle(
                  fontSize: 14,
                  color: !checkBoxValidation
                      ? (Platform.isAndroid ? Colors.red : CupertinoColors.systemRed)
                      : (MediaQuery.of(context).platformBrightness ==
                              Brightness.dark)
                          ? (Platform.isAndroid ? Colors.white : CupertinoColors.white)
                          : Colors.grey[600],
                ),
                // moreStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 40,
        ),
        if(Platform.isAndroid)
        Center(
          child: SizedBox(
            height: 60,
            width: double.infinity,
            child: TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: globalColor),
              onPressed: !checkBoxValue
                  ? () {
                if (checkBoxValue) {
                  setState(() {
                    checkBoxValidation = true;
                  });
                } else {
                  setState(() {
                    checkBoxValidation = false;
                  });
                }
              }
                  : (FirebaseAuth.instance.currentUser?.phoneNumber == null ||
                  (FirebaseAuth.instance.currentUser?.phoneNumber)
                      .toString()
                      .isEmpty)
                  ? () {}
                  : (FirebaseAuth.instance.currentUser?.phoneNumber !=
                  null ||
                  (FirebaseAuth
                      .instance.currentUser?.phoneNumber)
                      .toString()
                      .isNotEmpty) &&
                  checkBoxValue
                  ? () async {
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
              }
                  : null,
              child: const Padding(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: Text('Apply for Home Loan',
                    style: TextStyle(color: Colors.white, fontSize: 15)),
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
            onPressed: !checkBoxValue
                ? () {
              if (checkBoxValue) {
                setState(() {
                  checkBoxValidation = true;
                });
              } else {
                setState(() {
                  checkBoxValidation = false;
                });
              }
            }
                : (FirebaseAuth.instance.currentUser?.phoneNumber == null ||
                (FirebaseAuth.instance.currentUser?.phoneNumber)
                    .toString()
                    .isEmpty)
                ? () {}
                : (FirebaseAuth.instance.currentUser?.phoneNumber !=
                null ||
                (FirebaseAuth
                    .instance.currentUser?.phoneNumber)
                    .toString()
                    .isNotEmpty) &&
                checkBoxValue
                ? () async {
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
                  backgroundColor: CupertinoColors.white,
                  textColor: CupertinoColors.black,
                );
              }
              if (kDebugMode) {
                print(response.statusCode);
              }
            }
                : null,
              child: const Text('Apply for Home Loan',
              style: TextStyle(color: CupertinoColors.white, fontSize: 15)),
          ),
        )
      ],
    );
  }
}
