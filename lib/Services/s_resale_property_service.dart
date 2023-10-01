import 'dart:convert';
import 'dart:io';
import 'package:squarest/Models/m_resale_property.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../Utils/u_constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Models/m_mem_plan.dart';

class ResalePropertyService {

  Future<void> insertProperty(ResalePropertyModel resalePropertyModel) async {
    final response = await http.post(
      Uri.parse(functionInsertResaleProperty),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(resalePropertyModel),
    );
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 201 || response.statusCode == 200) {
      Fluttertoast.showToast(
        msg:
        'Property posted successfully.',
        backgroundColor: Platform.isAndroid ? Colors.white : CupertinoColors.white,
        textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
      );
    } else {
      Fluttertoast.showToast(
        msg:
        'Failed to post property.',
        backgroundColor: Platform.isAndroid ? Colors.white : CupertinoColors.white,
        textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
      );
      throw Exception('Failed to create user.');
    }
  }

  Future<List<ResalePropertyModel>> getAllResaleProperties() async {
    const String endpointUrl = functionGetResaleProperties;
    var requestUrl = '$endpointUrl?all=all';
    final response = await http.get(Uri.parse(requestUrl));
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (kDebugMode) {
      print(requestUrl);
    }
    if(response.statusCode == 200){
      return compute(parseProjects, response.body);
    } else {
      throw Exception('Failed to get all resale properties');
    }
  }

  Future<List<ResalePropertyModel>> getResaleProperties(int uid) async {
    const String endpointUrl = functionGetResaleProperties;
    var requestUrl = '$endpointUrl?user_id=$uid';
    final response = await http.get(Uri.parse(requestUrl));
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (kDebugMode) {
      print(requestUrl);
    }
    if(response.statusCode == 200){
      return compute(parseProjects, response.body);
    }else {
      throw Exception('Failed to get resale properties');
    }
  }

  Future<List<ResalePropertyModel>> getResaleProjectsFromBounds(LatLngBounds bounds) async {
    const String endpointUrl = functionGetResaleProperties;
    final double swLat = bounds.southwest.latitude;
    final double swLng = bounds.southwest.longitude;
    final double neLat = bounds.northeast.latitude;
    final double neLng = bounds.northeast.longitude;
    Map<String, String> queryParams = {
      "lat1": "$swLat",
      "lat2": "$neLat",
      "lng1": "$swLng",
      "lng2": "$neLng"
    };
    String queryString = Uri(queryParameters: queryParams).query;
    var requestUrl = '$endpointUrl?$queryString';
    final response = await http.get(Uri.parse(requestUrl));
    if (kDebugMode) {
      print(response.statusCode);
        print('fetch resale projects !!!');
        print(response.statusCode);
        print(swLat);
        print(neLat);
        print(swLng);
        print(neLng);
    }
    if (kDebugMode) {
      print(requestUrl);
    }
    if(response.statusCode == 200){
      return compute(parseProjects, response.body);
    }else {
      throw Exception('Failed to get resale projects');
    }
  }

  Future<void> updateResaleProperty(ResalePropertyModel resalePropertyModel) async {
    final response = await http.put(
      Uri.parse(functionUpdateResaleProperties),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(resalePropertyModel),
    );
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      Fluttertoast.showToast(
        msg:
        'Property successfully updated',
        backgroundColor: Platform.isAndroid ? Colors.white : CupertinoColors.white,
        textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
      );
    } else {
      Fluttertoast.showToast(
        msg:
        'Failed to update property',
        backgroundColor: Platform.isAndroid ? Colors.white : CupertinoColors.white,
        textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
      );
      throw Exception('Failed to update property.');
    }
  }

  Future<void> insertMemPlan(MemPlan memPlan) async {
    final response = await http.post(
      Uri.parse(functionInsertMemPlans),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(memPlan),
    );
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 201 || response.statusCode == 200) {
    } else {
      Fluttertoast.showToast(
        msg:
        'Failed to purchase plan.',
        backgroundColor: Platform.isAndroid ? Colors.white : CupertinoColors.white,
        textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
      );
      throw Exception('Failed to post plan.');
    }
  }


  Future<List<MemPlan>> getMemPlans(int uid) async {
    const String endpointUrl = functionGetMemPlans;
    var requestUrl = '$endpointUrl?user_id=$uid';
    final response = await http.get(Uri.parse(requestUrl));
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (kDebugMode) {
      print(endpointUrl);
    }
    if(response.statusCode == 200){
      return compute(parsePlans, response.body);
    }else {
      throw Exception('Failed to get plans');
    }
  }

  List<MemPlan> parsePlans(String responseBody) {
    var responseJson = jsonDecode(responseBody);
    var jsonResults = (responseJson['Plans'] ?? []) as List;
    List<MemPlan> memPlans = jsonResults
        .map((jsonResults) => MemPlan.fromJson(jsonResults))
        .toList();
    return memPlans;
  }

  List<ResalePropertyModel> parseProjects(String responseBody) {
    var responseJson = jsonDecode(responseBody);
    var jsonResults = (responseJson['Properties'] ?? []) as List;
    List<ResalePropertyModel> resaleProperties = jsonResults
        .map((jsonResults) => ResalePropertyModel.fromJson(jsonResults))
        .toList();
    return resaleProperties;
  }

}