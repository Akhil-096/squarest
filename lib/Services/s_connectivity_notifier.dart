import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityChangeNotifier extends ChangeNotifier {
  var isDeviceConnected = true;

  ConnectivityChangeNotifier() {
    Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      isDeviceConnected = await InternetConnectionChecker().hasConnection;

      resultHandler(result);
    });
  }
  ConnectivityResult? _connectivityResult;

  String _pageText =
      'Currently connected to no network. Please connect to a wifi network!';

  ConnectivityResult? get connectivity => _connectivityResult;

  String get pageText => _pageText;

  void resultHandler(ConnectivityResult result) {
    _connectivityResult = result;
    if (result == ConnectivityResult.none) {
      _pageText =
          'Currently connected to no network. Please connect to a wifi network!';
    } else if (result == ConnectivityResult.mobile) {
      _pageText =
          'Currently connected to a cellular network. Please connect to a wifi network!';
    } else if (result == ConnectivityResult.wifi) {
      _pageText = 'Connected to a wifi network!';
    }
    notifyListeners();
  }

  void initialLoad() async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    resultHandler(connectivityResult);
  }
}
