import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomErrorView extends StatelessWidget {
  final FlutterErrorDetails? flutterErrorDetails;
  final dynamic exception;
  final StackTrace? stack;
  const CustomErrorView({this.flutterErrorDetails, this.exception, this.stack, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/error_page.png'),
              Text(kDebugMode ? flutterErrorDetails?.summary.toString() ?? 'Flutter null Error!' : '',
                textAlign: TextAlign.center, style: TextStyle(
                    color: kDebugMode ? Platform.isAndroid ? Colors.red : CupertinoColors.destructiveRed : Platform.isAndroid ? Colors.blue :CupertinoColors.activeBlue, fontWeight: FontWeight.bold, fontSize: 18
                ),
              ),
              if(exception != null)
                Text(kDebugMode ? (exception.toString()) : '',
                  textAlign: TextAlign.center, style: TextStyle(
                      color: kDebugMode ? Platform.isAndroid ? Colors.red : CupertinoColors.destructiveRed : Platform.isAndroid ? Colors.blue : CupertinoColors.activeBlue, fontWeight: FontWeight.bold, fontSize: 18
                  ),
                ),
              if(stack != null)
                Text(kDebugMode ? (stack.toString()) : '',
                  textAlign: TextAlign.center, style: TextStyle(
                      color: kDebugMode ? Platform.isAndroid ? Colors.red : CupertinoColors.destructiveRed : Platform.isAndroid ? Colors.blue : CupertinoColors.activeBlue, fontWeight: FontWeight.bold, fontSize: 18
                  ),
                ),
              kDebugMode ? const SizedBox.shrink() : const Padding(padding: EdgeInsets.only(top: 10), child: Text('An error has occurred. We have taken note and are working on fixing it. Thank you for your patience.'),)
            ],
          ),
        ),
      ),
    );
  }
}
