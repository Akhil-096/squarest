import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:squarest/Models/m_user.dart';
import 'package:squarest/Utils/u_constants.dart';


class UserService {

  Future<void> createUser(UserProfileModel userProfile, BuildContext context) async {
    final response = await http.post(
      Uri.parse(functionCreateUserProfile),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(userProfile),
    );
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 201 || response.statusCode == 200) {
      Fluttertoast.showToast(
        msg:
        'Profile setup successful.',
        backgroundColor: Platform.isAndroid ? Colors.white : CupertinoColors.white,
        textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
      );
    } else {
      Fluttertoast.showToast(
        msg:
        'Failed to setup profile.',
        backgroundColor: Platform.isAndroid ? Colors.white : CupertinoColors.white,
        textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
      );
      throw Exception('Failed to create user.');
    }
  }

  Future<void> updateUser(UserProfileModel userProfile) async {
    final response = await http.put(
      Uri.parse(functionUpdateUserProfile),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(userProfile),
    );
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      Fluttertoast.showToast(
        msg:
        'Profile successfully updated',
        backgroundColor: Platform.isAndroid ? Colors.white : CupertinoColors.white,
        textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
      );
    } else {
      Fluttertoast.showToast(
        msg:
        'Failed to update profile',
        backgroundColor: Platform.isAndroid ? Colors.white : CupertinoColors.white,
        textColor: Platform.isAndroid ? Colors.black : CupertinoColors.black,
      );
      throw Exception('Failed to update user.');
    }
  }

  Future<UserProfileModel> getUser(String uid) async {
    const String endpointUrl = functionGetUser;
    final String firebaseUid = uid;
    Map<String, String> queryParam = {"uid": firebaseUid};

    String queryString = Uri(queryParameters: queryParam).query;
    var requestUrl = '$endpointUrl?$queryString';

    final response = await http.get(Uri.parse(requestUrl));
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200) {
      return compute(parseUser, response.body);
    } else {
      throw Exception('Failed to get User profile');
    }
  }

  UserProfileModel parseUser(String responseBody) {
    var responseJson = jsonDecode(responseBody);
    var jsonUser = (responseJson['User'] ?? []) as List;
    UserProfileModel
    user = jsonUser
        .map((jsonResults) => UserProfileModel.fromJson(jsonResults))
        .toList()[0];
    return user;
  }

}
