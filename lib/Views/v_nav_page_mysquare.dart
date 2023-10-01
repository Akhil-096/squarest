import 'dart:io';

import 'package:squarest/Services/s_connectivity_notifier.dart';
import 'package:squarest/Views/v_my_account_login.dart';
import 'package:squarest/Views/v_no_internet.dart';
import 'package:squarest/Views/v_setup_profile.dart';
import 'package:squarest/Views/v_user_account.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../Services/s_user_profile_notifier.dart';

class MySquare extends StatefulWidget {
  const MySquare({Key? key}) : super(key: key);

  @override
  State<MySquare> createState() => _MySquareState();
}

class _MySquareState extends State<MySquare> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final con = context.watch<ConnectivityChangeNotifier>();
    final userProfileNotifier = Provider.of<UserProfileNotifier>(context);
    return (con.connectivity == null)
        ? const Center(child: SizedBox())
        : ((con.connectivity == ConnectivityResult.none) ||
                (con.isDeviceConnected == false))
            ? const NoInternet()
            : StreamBuilder(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (ctx, userSnapshot) {
                  if (userSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const SizedBox();
                  } else {
                    if (userSnapshot.hasError) {
                      return const SizedBox();
                    } else {
                      if (userSnapshot.hasData) {
                        return FutureBuilder<dynamic>(
                            future: userProfileNotifier.getCurrentUserId(context),
                            builder: (ctx, snapshot) {
                              if(userProfileNotifier.isLoading || snapshot.connectionState == ConnectionState.waiting){
                                return const AccountScreenShimmer();
                              } else {
                                if(snapshot.hasError){
                                  if (kDebugMode) {
                                    print(snapshot.error);
                                  }
                                  return Center(
                                    child: Text('${snapshot.error}'),
                                  );
                                }
                                else {
                                  if(!snapshot.hasData){
                                    return const SetupProfile();
                                  } else {
                                    return const UserAccount();
                                  }
                                }
                              }

                        });
                      } else {
                        return const MyAccountLogin();
                        // return const LoginScreen(
                        //   isComingFromJoinNow: false,
                        //   isAccountScreen: true,
                        //   isComingFromHomeLoan: false,
                        // );
                      }
                    }
                  }
                },
              );
  }


}


class AccountScreenShimmer extends StatefulWidget {
  const AccountScreenShimmer({Key? key}) : super(key: key);

  @override
  State<AccountScreenShimmer> createState() => _AccountScreenShimmerState();
}

class _AccountScreenShimmerState extends State<AccountScreenShimmer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Shimmer.fromColors(
              baseColor: (MediaQuery.of(context).platformBrightness ==
                  Brightness.dark)
                  ? Colors.grey[700]!
                  : Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.grey[500]!
                ),
                width: 40,
                height: 40,
              ),
            ),
          const SizedBox(width: 15,),
          Shimmer.fromColors(
            baseColor: (MediaQuery.of(context).platformBrightness ==
                Brightness.dark)
                ? Colors.grey[700]!
                : Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.grey[500]!
              ),
              width: 40,
              height: 40,
            ),
          ),
        ],),
        backgroundColor: (MediaQuery.of(context).platformBrightness ==
          Brightness.dark)
          ? Colors.grey[700]
          : Platform.isAndroid ? Colors.white : CupertinoColors.white,),
      body: Shimmer.fromColors(
        baseColor: (MediaQuery.of(context).platformBrightness ==
            Brightness.dark)
            ? Colors.grey[700]!
            : Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          itemBuilder: (_, __) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                              width: 150,
                              height: 20,
                              color: Colors.grey[300]!
                          ),
                          Container(
                              width: 50,
                              height: 8.0,
                              color: Colors.grey[300]!
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.80,
                      color: Colors.grey[300]!,
                    )
                  ],
                ),
              )
            ],
          ),
          itemCount: 1,
        ),
      ),
    );
  }
}

