import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/cupertino.dart';

import '../Utils/u_custom_styles.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  PackageInfo? androidInfo;

  @override
  void initState() {
    super.initState();
    getAndroidInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Platform.isAndroid ? PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: AppBar(backgroundColor: (MediaQuery.of(context).platformBrightness ==
                Brightness.dark)
                ? Colors.grey[900]
                : Colors.white,
            title: Text(
              'About Us',
              style: CustomTextStyles.getTitle(
                  null,
                  (MediaQuery.of(context).platformBrightness == Brightness.dark)
                      ? Colors.white
                      : Colors.black, null,
                  20),
            ),
            )) : CupertinoNavigationBar(
          backgroundColor: (MediaQuery.of(context).platformBrightness ==
              Brightness.dark)
              ? Colors.grey[900]
              : CupertinoColors.white,
          middle: Text(
            'About the app',
            style: CustomTextStyles.getTitle(
                null,
                (MediaQuery.of(context).platformBrightness == Brightness.dark)
                    ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                    : Platform.isAndroid ? Colors.black : CupertinoColors.black, null,
                20),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 5),
                  width: 200,
                  height: 200,
                  child: FittedBox(
                      fit: BoxFit.cover,
                      child: Image.asset('assets/images/squarest.png')),
                ),
                const SizedBox(height: 10,),
                Text(
                  'Version ${androidInfo?.version}',
                  style: CustomTextStyles.getBodySmall(
                    null,
                    (MediaQuery.of(context).platformBrightness == Brightness.dark)
                        ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                        : Platform.isAndroid ? Colors.black : CupertinoColors.black, null,
                    13,),
                ),
                const SizedBox(height: 5,),
                Text('© Apartmint Solutions Private Limited  2022-2023', style: CustomTextStyles.getBodySmall(
                    null,
                    (MediaQuery.of(context).platformBrightness == Brightness.dark)
                        ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                        : Platform.isAndroid ? Colors.black : CupertinoColors.black, null,
                    13,),)
              ],
            ),
          ),
        ));
  }

  getAndroidInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      androidInfo = packageInfo;
    });
  }
}
