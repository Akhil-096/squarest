import 'dart:convert';
import 'dart:io';
import 'package:squarest/Utils/u_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../Utils/u_custom_styles.dart';

class FeedBackScreen extends StatefulWidget {
  const FeedBackScreen({Key? key}) : super(key: key);

  @override
  State<FeedBackScreen> createState() => _FeedBackScreenState();
}

class _FeedBackScreenState extends State<FeedBackScreen> {
  final controller = TextEditingController();
  final form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: Platform.isAndroid ? PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: AppBar(
            scrolledUnderElevation: 0.0,
            backgroundColor:
            (MediaQuery.of(context).platformBrightness == Brightness.dark)
                ? Colors.grey[900]
                : Colors.white,
            title: Text('Feedback', style: CustomTextStyles.getTitle(null, (MediaQuery.of(context).platformBrightness ==
                Brightness.dark)
                ? Colors.white
                : Colors.black, null, 20),),
            // elevation: 1,
          ),
        ) : CupertinoNavigationBar(
          backgroundColor: (MediaQuery.of(context).platformBrightness ==
              Brightness.dark)
              ? Colors.grey[900]
              : CupertinoColors.white,
          middle: Text('Feedback', style: CustomTextStyles.getTitle(null, (MediaQuery.of(context).platformBrightness ==
              Brightness.dark)
              ? CupertinoColors.white
              : CupertinoColors.black, null, 20),),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 70, left: 8, right: 8, bottom: 8),
              child: SizedBox(
                // height: MediaQuery.of(context).size.height * 0.5,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Form(
                          key: form,
                          child: TextFormField(
                            autofocus: true,
                            maxLines: null,
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'This field cannot be empty';
                              } else {
                                return null;
                              }
                            },
                            onChanged: (val) {
                              if (val.isEmpty) {
                                form.currentState?.validate();
                                setState(() {});
                              } else {
                                form.currentState?.validate();
                                setState(() {});
                              }
                            },
                            controller: controller,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Your feedback will be anonymous',
                                counterText: '',
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color:
                                      (MediaQuery.of(context).platformBrightness ==
                                              Brightness.dark)
                                          ? Platform.isAndroid ? Colors.white.withOpacity(0.25) : CupertinoColors.white.withOpacity(0.25)
                                          : Platform.isAndroid ? Colors.black.withOpacity(0.25) : CupertinoColors.black.withOpacity(0.25),
                                ),
                                hintText:
                                    "Please give your inputs to make the app better",
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color:
                                      (MediaQuery.of(context).platformBrightness ==
                                              Brightness.dark)
                                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                          : Platform.isAndroid ? Colors.black.withOpacity(0.5) : CupertinoColors.black.withOpacity(0.5),
                                ),
                                hintMaxLines: 2),
                            style: TextStyle(
                              fontSize: 20.0,
                              height: 2.0,
                              color:
                              (MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark)
                                  ? Platform.isAndroid ? Colors.white.withOpacity(0.7) : CupertinoColors.white.withOpacity(0.7)
                                  : Platform.isAndroid ? Colors.black.withOpacity(0.5) : CupertinoColors.black.withOpacity(0.5),
                            ),
                          ),
                        ),
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
                              onPressed: controller.text.isEmpty ? (){
                                if (controller.text.isEmpty) {
                                  form.currentState?.validate();
                                  setState(() {});
                                } else {
                                  form.currentState?.validate();
                                  setState(() {});
                                }
                              } :
                                  () async {
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
                                      "template_id": "template_l964mm2",
                                      "user_id": "EhQW8PzI3mUXrzJ0y",
                                      'template_params': {
                                        "message": limitTextTo10k(controller.value.text),
                                      }
                                    }));
                                if (kDebugMode) {
                                  print(response.statusCode);
                                }
                                if (response.statusCode == 200) {
                                  Fluttertoast.showToast(
                                    msg: 'Feedback submitted successfully',
                                    backgroundColor: Colors.white,
                                    textColor: Colors.black,
                                  );
                                } else {
                                  Fluttertoast.showToast(
                                    msg:
                                    'Something went wrong. Please try again.',
                                    backgroundColor: Colors.white,
                                    textColor: Colors.black,
                                  );
                                }
                                if (!mounted) return;
                                Navigator.of(context).pop();
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
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton(
                          color: globalColor,
                            borderRadius: const BorderRadius.all(Radius.circular(25)),
                            onPressed: controller.text.isEmpty ? (){
                          if (controller.text.isEmpty) {
                            form.currentState?.validate();
                            setState(() {});
                          } else {
                            form.currentState?.validate();
                            setState(() {});
                          }
                        } :
                            () async {
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
                                "template_id": "template_l964mm2",
                                "user_id": "EhQW8PzI3mUXrzJ0y",
                                'template_params': {
                                  "message": limitTextTo10k(controller.value.text),
                                }
                              }));
                          if (kDebugMode) {
                            print(response.statusCode);
                          }
                          if (response.statusCode == 200) {
                            Fluttertoast.showToast(
                              msg: 'Feedback submitted successfully',
                              backgroundColor: CupertinoColors.white,
                              textColor: CupertinoColors.black,
                            );
                          } else {
                            Fluttertoast.showToast(
                              msg:
                              'Something went wrong. Please try again.',
                              backgroundColor: CupertinoColors.white,
                              textColor: CupertinoColors.black,
                            );
                          }
                          if (!mounted) return;
                          Navigator.of(context).pop();
                        }, child: const Text("Submit",
                            style: TextStyle(
                                color: CupertinoColors.white, fontSize: 15))),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  String limitTextTo10k(String feedbackMessage){
    if(feedbackMessage.length > 10000){
      return '${feedbackMessage.substring(0,10000)}...';
    }
    else{
      return feedbackMessage;
    }
  }
}
