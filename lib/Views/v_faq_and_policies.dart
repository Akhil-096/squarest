import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Utils/u_custom_styles.dart';
import '../Utils/u_open_pdf.dart';

class FaqAndPoliciesScreen extends StatelessWidget {
  final int id;

  const FaqAndPoliciesScreen(this.id, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Platform.isAndroid ? PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: AppBar(
            scrolledUnderElevation: 0.0,
            backgroundColor:
            (MediaQuery.of(context).platformBrightness == Brightness.dark)
                ? Colors.grey[900]
                : Colors.white,
            title: Text(id == 2 ? 'FAQs' : 'Policies', style: CustomTextStyles.getTitle(null, (MediaQuery.of(context).platformBrightness ==
                Brightness.dark)
                ? Colors.white
                : Colors.black, null, 20),),
          ),
        ) : CupertinoNavigationBar(
          backgroundColor: (MediaQuery.of(context).platformBrightness ==
              Brightness.dark)
              ? Colors.grey[900]
              : CupertinoColors.white,
          middle: Text(id == 2 ? 'FAQs' : 'Policies', style: CustomTextStyles.getTitle(null, (MediaQuery.of(context).platformBrightness ==
              Brightness.dark)
              ? CupertinoColors.white
              : CupertinoColors.black, null, 20),),
        ),
        body: SafeArea(
          child: id == 2
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Center(
                child: SizedBox(
                  width: 250,
                  child: Text(
                    'Stay tuned for answers to your most\nfrequent questions!',
                    // textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          )
              : Column(
            children: [
              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (ctx) => const OpenPdf(
                          imgUrl: [
                            'https://storage.googleapis.com/squarest_docs/Select_Terms.pdf'
                          ],
                        )),
                  );
                },
                child: Card(
                  child: ListTile(
                    title: const Text('Select Membership'),
                    trailing: Icon(Platform.isAndroid ? Icons.chevron_right : CupertinoIcons.right_chevron),
                  ),
                ),
              ),
              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (ctx) => const OpenPdf(
                          imgUrl: [
                            'https://storage.googleapis.com/squarest_docs/Terms_of_Use.pdf'
                          ],
                        )),
                  );
                },
                child: Card(
                  child: ListTile(
                    title: const Text('Terms of Use'),
                    trailing: Icon(Platform.isAndroid ? Icons.chevron_right : CupertinoIcons.right_chevron),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _launchPrivacyPoliciesInWebView,
                child: Card(
                  child: ListTile(
                    title: const Text('Privacy'),
                    trailing: Icon(Platform.isAndroid ? Icons.chevron_right : CupertinoIcons.right_chevron),
                  ),
                ),
              ),
            ],
          ),
        ));
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
