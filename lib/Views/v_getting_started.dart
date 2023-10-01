import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:squarest/Utils/u_constants.dart';
import 'package:squarest/Utils/u_custom_styles.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Utils/u_open_pdf.dart';

class GettingStarted extends StatefulWidget {
  const GettingStarted({Key? key}) : super(key: key);


  @override
  State<GettingStarted> createState() => _GettingStartedState();
}

class _GettingStartedState extends State<GettingStarted> {

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: (MediaQuery.of(context).platformBrightness ==
            Brightness.dark)
            ? Colors.grey[900] : Platform.isAndroid ? Colors.white : CupertinoColors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: (MediaQuery.of(context).platformBrightness ==
              Brightness.dark)
              ? Colors.grey[900] : Platform.isAndroid ? Colors.white : CupertinoColors.white,
          statusBarIconBrightness: (MediaQuery.of(context).platformBrightness ==
              Brightness.dark)
              ? Brightness.light : Brightness.dark,
          statusBarBrightness: (MediaQuery.of(context).platformBrightness ==
              Brightness.dark)
              ? Brightness.dark : Brightness.light,
        ),
      ),
      backgroundColor: (MediaQuery.of(context).platformBrightness ==
          Brightness.dark)
          ? Colors.grey[900] : Platform.isAndroid ? Colors.white : CupertinoColors.white,
      body: SafeArea(
        child: Center(
          child: IntroductionScreen(
            globalFooter: null,
            isBottomSafeArea: false,
            pages: [
              PageViewModel(
                decoration: PageDecoration(
                  pageColor: (MediaQuery.of(context).platformBrightness ==
                      Brightness.dark)
                      ? Colors.grey[900] : Platform.isAndroid ? Colors.white : CupertinoColors.white,
                ),
                titleWidget: Padding(
                    padding: const EdgeInsets.only(top: 80.0),
                    child: SizedBox(
                        height: MediaQuery.of(context).size.height / 3,
                        width: 300,
                        child: SvgPicture.asset('assets/images/map.svg'))),
                bodyWidget: Column(
                  children: [
                    AutoSizeText(
                      "Discover",
                      style: CustomTextStyles.getTitle(null, (MediaQuery.of(context).platformBrightness ==
                          Brightness.dark)
                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                          : Platform.isAndroid ? Colors.black : CupertinoColors.black, null, 24),
                      maxLines: 1,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 15,
                    ),
                    Text(
                      "Easily browse projects on map.",
                      style: CustomTextStyles.getNormalPoppins(null, (MediaQuery.of(context).platformBrightness ==
                          Brightness.dark)
                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                          : Platform.isAndroid ? Colors.black : CupertinoColors.black, 14),
                    ),
                  ],
                ),
              ),
              PageViewModel(
                decoration: PageDecoration(
                  pageColor: (MediaQuery.of(context).platformBrightness ==
                      Brightness.dark)
                      ? Colors.grey[900] : Platform.isAndroid ? Colors.white : CupertinoColors.white,
                ),
                titleWidget: Padding(
                    padding: const EdgeInsets.only(top: 80.0),
                    child: SizedBox(
                        height: MediaQuery.of(context).size.height / 3,
                        width: 300,
                        child: SvgPicture.asset('assets/images/apt.svg'))),
                bodyWidget: Column(
                  children: [
                    AutoSizeText(
                      "Choose",
                      style: CustomTextStyles.getTitle(null, (MediaQuery.of(context).platformBrightness ==
                          Brightness.dark)
                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                          : Platform.isAndroid ? Colors.black : CupertinoColors.black, null, 24),
                      maxLines: 1,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 15,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "See project photos, brochures and Show Flats in 3D.",
                            style: CustomTextStyles.getNormalPoppins(null, (MediaQuery.of(context).platformBrightness ==
                                Brightness.dark)
                                ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                : Platform.isAndroid ? Colors.black : CupertinoColors.black, 14), maxLines: 2,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Text(
                            "Find number of available units for each BHK.",
                            style: CustomTextStyles.getNormalPoppins(null, (MediaQuery.of(context).platformBrightness ==
                                Brightness.dark)
                                ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                : Platform.isAndroid ? Colors.black : CupertinoColors.black, 14),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              PageViewModel(
                decoration: PageDecoration(
                  pageColor: (MediaQuery.of(context).platformBrightness ==
                      Brightness.dark)
                      ? Colors.grey[900] : Platform.isAndroid ? Colors.white : CupertinoColors.white,
                ),
                titleWidget: Padding(
                    padding: const EdgeInsets.only(top: 80.0),
                    child: SizedBox(
                        height: MediaQuery.of(context).size.height / 3,
                        width: 300,
                        child: SvgPicture.asset('assets/images/loan.svg'))),
                bodyWidget: Column(
                  children: [
                    AutoSizeText(
                      "Decide",
                      style: CustomTextStyles.getTitle(null, (MediaQuery.of(context).platformBrightness ==
                          Brightness.dark)
                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                          : Platform.isAndroid ? Colors.black : CupertinoColors.black, null, 24),
                      maxLines: 1,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 15,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: Text(
                        "Book site visits and arrange home loan in a jiffy.",
                        style: CustomTextStyles.getNormalPoppins(null, (MediaQuery.of(context).platformBrightness ==
                            Brightness.dark)
                            ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                            : Platform.isAndroid ? Colors.black : CupertinoColors.black, 14),
                      ),
                    ),
                    const SizedBox(height: 15,),
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: 'By continuing, you agree to the ',
                            style: CustomTextStyles.getTitle(null, (MediaQuery.of(context).platformBrightness ==
                                Brightness.dark)
                                ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                : Platform.isAndroid ? Colors.black : CupertinoColors.black, null, 14),
                          ),
                          TextSpan(
                              text: 'Terms of Use ',
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  Navigator.push(
                                    context,
                                    Platform.isAndroid ? MaterialPageRoute(
                                        builder: (ctx) => const OpenPdf(
                                          imgUrl: [
                                            'https://storage.googleapis.com/squarest_docs/Terms_of_Use.pdf'
                                          ],
                                        )) : CupertinoPageRoute(
                                        builder: (ctx) => const OpenPdf(
                                          imgUrl: [
                                            'https://storage.googleapis.com/squarest_docs/Terms_of_Use.pdf'
                                          ],
                                        )),
                                  );
                                },
                              style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: globalColor, fontWeight: FontWeight.bold)),
                          TextSpan(
                            text: 'and ',
                            style: CustomTextStyles.getTitle(null, (MediaQuery.of(context).platformBrightness ==
                                Brightness.dark)
                                ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                : Platform.isAndroid ? Colors.black : CupertinoColors.black, null, 14),),
                          TextSpan(
                              text: 'Privacy Policy',
                              recognizer: TapGestureRecognizer()
                                ..onTap = _launchPrivacyPoliciesInWebView,
                              style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: globalColor, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ),
                  ],
                ),

              ),
            ],
            onDone: () async {
              AutoRouter.of(context).popUntilRouteWithName('/');
              AutoRouter.of(context).pushNamed('/');
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('intro_seen', false);
            },
            showBackButton: true,
            back: Icon(
              Platform.isAndroid ? Icons.arrow_back : CupertinoIcons.chevron_back,
            ),
            next: Icon(
              Platform.isAndroid ? Icons.arrow_forward : CupertinoIcons.chevron_forward,
            ),
            done: Wrap(
              children: [
                Container(
                    width: 100,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: globalColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text("continue",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Platform.isAndroid ? Colors.white : CupertinoColors.white,
                            fontSize: 12))),
              ],
            ),
            controlsMargin: EdgeInsets.zero,
            globalBackgroundColor: (MediaQuery.of(context).platformBrightness ==
                Brightness.dark)
                ? Colors.grey[900] : Platform.isAndroid ? Colors.white : CupertinoColors.white,
            controlsPadding: const EdgeInsets.only(bottom: 5),
            dotsDecorator: DotsDecorator(
              size: const Size.square(10.0),
              activeSize: const Size(20.0, 10.0),
              activeColor: globalColor,
              spacing: const EdgeInsets.symmetric(horizontal: 3.0),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _launchPrivacyPoliciesInWebView() async {
    const url = "https://www.squarest.in/privacy";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.inAppWebView, webViewConfiguration: const WebViewConfiguration(enableJavaScript: true));
    } else {
      Fluttertoast.showToast(
        msg: 'Something went wrong. Please try again.',
        backgroundColor: Colors.white,
        textColor: Colors.black,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

}
