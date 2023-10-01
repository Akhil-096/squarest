import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

class GetGeoLocation {
  Future<void> goToCurrentLocation(
      Completer<GoogleMapController> controller, context) async {
    bool serviceEnabled;
    LocationPermission permission;
    final GoogleMapController mapController = await controller.future;
    Position location;
    const String noLocationMsg = 'Unable to get location. Please try later.';

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(
        msg: 'Location service is disabled. Enable and try again',
        backgroundColor: Platform.isAndroid ? Colors.white : CupertinoColors.white,
        textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
      );
      Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(
          msg: 'Location permissions are denied',
          backgroundColor: Platform.isAndroid ? Colors.white : CupertinoColors.white,
          textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
        );
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
        msg: 'Location permissions are permanently denied, we cannot request permissions.',
        backgroundColor: Platform.isAndroid ? Colors.white : CupertinoColors.white,
        textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
      );
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    try {
      location = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5));
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(location.latitude, location.longitude), zoom: 15.0)));
    } catch (e) {
      Fluttertoast.showToast(
        msg: noLocationMsg,
        backgroundColor: Platform.isAndroid ? Colors.white : CupertinoColors.white,
        textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
      );
      return Future.error('Unable to get current location.');
    }
  }
}
