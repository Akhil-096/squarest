import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:squarest/Utils/u_constants.dart';
import '../Models/m_project.dart';
import '../Models/m_resale_property.dart';

class LikedProjectsService {

  Future<void> insertLikes (
      int uid, int projectId) async {
    final response = await http.post(
      Uri.parse(functionInsertLikes),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "user_id": uid,
        "project_id": projectId
      }),
    );
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Fluttertoast.showToast(
      //   msg: 'like successful',
      //   backgroundColor: Colors.white,
      //   textColor: Colors.black,
      // );
    } else {
      // Fluttertoast.showToast(
      //   msg: 'like failed',
      //   backgroundColor: Colors.white,
      //   textColor: Colors.black,
      // );
      throw Exception('Failed to like.');
    }
  }

  Future<void> deleteLikes(int uid, int projectId) async {
    final response = await http.delete(
      Uri.parse(functionDeleteLikes),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "user_id": uid,
        "project_id": projectId
      }),
    );
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Fluttertoast.showToast(
      //   msg: 'unlike successful',
      //   backgroundColor: Colors.white,
      //   textColor: Colors.black,
      // );
    } else {
      // Fluttertoast.showToast(
      //   msg: 'unlike failed',
      //   backgroundColor: Colors.white,
      //   textColor: Colors.black,
      // );
      throw Exception('Failed to unlike.');
    }
  }

  Future<List<Project>> getLikedProjects(int uid) async {
    // Map<String, dynamic> queryParam = {"list_project_ids": projectIds};
    // String queryString = Uri(queryParameters: queryParam).query;
    const String endpointUrl = functionLikedProjects;
    var requestUrl = '$endpointUrl?user_id=$uid';
    final response = await http.get(Uri.parse(requestUrl));
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (kDebugMode) {
      print(requestUrl);
    }
    if(response.statusCode == 200){
      // var responseJson = jsonDecode(response.body);
      // var jsonResults = (responseJson['Projects'] ?? []) as List;
      // List<Project> projects = jsonResults
      //     .map((jsonResults) => Project.fromJson(jsonResults))
      //     .toList();
      // return projects;
      return compute(parseProjects, response.body);
    }else {
      throw Exception('Failed to get liked projects');
    }
  }

  List<Project> parseProjects(String responseBody) {
    var responseJson = jsonDecode(responseBody);
    var jsonResults = (responseJson['Projects'] ?? []) as List;
    List<Project> projects = jsonResults
        .map((jsonResults) => Project.fromJson(jsonResults))
        .toList();
    return projects;
  }

  // resale

  Future<void> insertResaleLikes (
      int uid, int propId) async {
    final response = await http.post(
      Uri.parse(functionInsertResaleLikes),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "user_id": uid,
        "prop_id": propId
      }),
    );
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Fluttertoast.showToast(
      //   msg: 'like successful',
      //   backgroundColor: Colors.white,
      //   textColor: Colors.black,
      // );
    } else {
      // Fluttertoast.showToast(
      //   msg: 'like failed',
      //   backgroundColor: Colors.white,
      //   textColor: Colors.black,
      // );
      throw Exception('Failed to like.');
    }
  }

  Future<void> deleteResaleLikes(int uid, int propId) async {
    final response = await http.delete(
      Uri.parse(functionDeleteResaleLikes),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "user_id": uid,
        "prop_id": propId
      }),
    );
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Fluttertoast.showToast(
      //   msg: 'unlike successful',
      //   backgroundColor: Colors.white,
      //   textColor: Colors.black,
      // );
    } else {
      // Fluttertoast.showToast(
      //   msg: 'unlike failed',
      //   backgroundColor: Colors.white,
      //   textColor: Colors.black,
      // );
      throw Exception('Failed to unlike.');
    }
  }

  Future<List<ResalePropertyModel>> getLikedResaleProperties(int uid) async {
    // Map<String, dynamic> queryParam = {"list_project_ids": projectIds};
    // String queryString = Uri(queryParameters: queryParam).query;
    const String endpointUrl = functionLikedResaleProperties;
    var requestUrl = '$endpointUrl?user_id=$uid';
    final response = await http.get(Uri.parse(requestUrl));
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (kDebugMode) {
      print(requestUrl);
    }
    if(response.statusCode == 200){
      return compute(parseResaleProjects, response.body);
    }else {
      throw Exception('Failed to get liked resale projects');
    }
  }

  List<ResalePropertyModel> parseResaleProjects(String responseBody) {
    var responseJson = jsonDecode(responseBody);
    var jsonResults = (responseJson['Properties'] ?? []) as List;
    List<ResalePropertyModel> resaleProperties = jsonResults
        .map((jsonResults) => ResalePropertyModel.fromJson(jsonResults))
        .toList();
    return resaleProperties;
  }

}
