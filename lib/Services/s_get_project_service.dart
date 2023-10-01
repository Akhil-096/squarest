import 'dart:convert';
import 'package:squarest/Models/m_project.dart';
import 'package:squarest/Models/m_project_inventory.dart';
import 'package:squarest/Utils/u_constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../Models/m_builders.dart';
import '../Models/m_search_project.dart';

class ProjectService {


  Future<List<Project>> fetchProjects(LatLngBounds bounds) async {
    const String endpointUrl = functionGetProjects;
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
      print('fetch projects !!!');
      print(response.statusCode);
      print(swLat);
      print(neLat);
      print(swLng);
      print(neLng);
    }

    if (response.statusCode == 200) {
      // Use the compute function to run parsePhotos
      return compute(parseProjects, response.body);
    } else {
      throw HttpException(
          'Unexpected status code ${response.statusCode}:'
          ' ${response.reasonPhrase}',
          uri: Uri.parse(functionGetProjects));
    }
  }

  // A function that converts a response body into a List<Photo>.
  List<Project> parseProjects(String responseBody) {
    var responseJson = jsonDecode(responseBody);
    var jsonResults = (responseJson['Projects'] ?? []) as List;
    List<Project> projects = jsonResults
        .map((jsonResults) => Project.fromJson(jsonResults))
        .toList();
    return projects;
  }

  Future<List<ProjectInventory>> getProjectInventory(int projectId) async {
    const String endpointUrl = functionGetProjectInventory;
    final int projectIdInv = projectId;
    Map<String, String> queryParams = {"projectId": "$projectIdInv"};
    String queryString = Uri(queryParameters: queryParams).query;
    var requestUrl = '$endpointUrl?$queryString';
    final response = await http.get(Uri.parse(requestUrl));
    if(response.statusCode == 200){
      return compute(parseInventory, response.body);
    } else {
      throw HttpException(
          'Unexpected status code ${response.statusCode}:'
              ' ${response.reasonPhrase}',
          uri: Uri.parse(functionGetProjectInventory));
    }
  }

  List<ProjectInventory> parseInventory(String responseBody) {
    var responseJson = jsonDecode(responseBody);
    var jsonResults = (responseJson['Projects_Inv'] ?? []) as List;
    List<ProjectInventory> projectInv = jsonResults
        .map((jsonResults) => ProjectInventory.fromJson(jsonResults))
        .toList();
    return projectInv;
  }

  Future<void> incrementViewCount(int projectId) async {
    final response = await http.put(
      Uri.parse(functionIncrementViewCount),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "id": projectId
      }),
    );
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      //Toast message 'Your profile has been updated successfully'
      // Fluttertoast.showToast(
      //   msg:
      //   'count updated',
      //   backgroundColor: Colors.white,
      //   textColor: Colors.black,
      // );
    } else {
      throw Exception('Failed to update view count.');
    }
  }

  Future<List<SearchProjectModel>> getSearchedProjects(String userText) async {
    const String endpointUrl = functionGetSearchProjectList;
    var requestUrl = '$endpointUrl?search_text=$userText';
    final response = await http.get(Uri.parse(requestUrl));
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (kDebugMode) {
      print(requestUrl);
    }
    if(response.statusCode == 200){
      return compute(parseSearchedProjects, response.body);
    } else {
      throw Exception('Failed to get search projects');
    }
  }

  List<SearchProjectModel> parseSearchedProjects(String responseBody) {
    var responseJson = jsonDecode(responseBody);
    var jsonResults = (responseJson['Projects'] ?? []) as List;
    List<SearchProjectModel> projects = jsonResults
        .map((jsonResults) => SearchProjectModel.fromJson(jsonResults))
        .toList();
    return projects;
  }

  Future<List<Project>> getProjectById(int id) async {
    const String endpointUrl = functionGetProjects;
    var requestUrl = '$endpointUrl?project_id=$id';
    final response = await http.get(Uri.parse(requestUrl));
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200) {
      // Use the compute function to run parsePhotos
      return compute(parseProjects, response.body);
    } else {
      throw HttpException(
          'Unexpected status code ${response.statusCode}:'
              ' ${response.reasonPhrase}',
          uri: Uri.parse(functionGetProjects));
    }
  }

  Future<List<BuildersModel>> getTopBuilders() async {
    const String endpointUrl = functionGetTopBuilders;
    final response = await http.get(Uri.parse(endpointUrl));
    if (kDebugMode) {
      print(response.statusCode);
    }
    if(response.statusCode == 200){
      return compute(parseTopBuilders, response.body);
    } else {
      throw Exception('Failed to get top builders');
    }
  }

  List<BuildersModel> parseTopBuilders(String responseBody) {
    var responseJson = jsonDecode(responseBody);
    var jsonResults = (responseJson['Builders'] ?? []) as List;
    List<BuildersModel> builders = jsonResults
        .map((jsonResults) => BuildersModel.fromJson(jsonResults))
        .toList();
    return builders;
  }

  Future<List<Project>> get3dProjects() async {
    const String endpointUrl = functionGetProjects;

    Map<String, String> queryParams = {
      "3D": "3D"
    };

    String queryString = Uri(queryParameters: queryParams).query;
    var requestUrl = '$endpointUrl?$queryString';

    final response = await http.get(Uri.parse(requestUrl));
    if (kDebugMode) {
      print('fetch projects !!!');
      print(response.statusCode);
    }
    if (response.statusCode == 200) {
      return compute(parseProjects, response.body);
    } else {
      throw HttpException(
          'Unexpected status code ${response.statusCode}:'
              ' ${response.reasonPhrase}',
          uri: Uri.parse(functionGetProjects));
    }
  }

  Future<List<Project>> getWorthALook() async {
    const String endpointUrl = functionGetProjects;

    Map<String, String> queryParams = {
      "worth": "worth"
    };

    String queryString = Uri(queryParameters: queryParams).query;
    var requestUrl = '$endpointUrl?$queryString';

    final response = await http.get(Uri.parse(requestUrl));
    if (kDebugMode) {
      print('fetch projects !!!');
      print(response.statusCode);
    }
    if (response.statusCode == 200) {
      return compute(parseProjects, response.body);
    } else {
      throw HttpException(
          'Unexpected status code ${response.statusCode}:'
              ' ${response.reasonPhrase}',
          uri: Uri.parse(functionGetProjects));
    }
  }

  Future<List<Project>> getBuilderProjects(int builderId) async {
    const String endpointUrl = functionGetProjects;

    Map<String, String> queryParams = {
      "builder_id": '$builderId'
    };

    String queryString = Uri(queryParameters: queryParams).query;
    var requestUrl = '$endpointUrl?$queryString';

    final response = await http.get(Uri.parse(requestUrl));
    if (kDebugMode) {
      print('fetch projects !!!');
      print(response.statusCode);
    }
    if (response.statusCode == 200) {
      return compute(parseProjects, response.body);
    } else {
      throw HttpException(
          'Unexpected status code ${response.statusCode}:'
              ' ${response.reasonPhrase}',
          uri: Uri.parse(functionGetProjects));
    }
  }

  Future<List<Project>> getNewLaunches() async {
    const String endpointUrl = functionGetProjects;

    Map<String, String> queryParams = {
      "new": "new"
    };

    String queryString = Uri(queryParameters: queryParams).query;
    var requestUrl = '$endpointUrl?$queryString';

    final response = await http.get(Uri.parse(requestUrl));
    if (kDebugMode) {
      print('fetch projects !!!');
      print(response.statusCode);
    }
    if (response.statusCode == 200) {
      return compute(parseProjects, response.body);
    } else {
      throw HttpException(
          'Unexpected status code ${response.statusCode}:'
              ' ${response.reasonPhrase}',
          uri: Uri.parse(functionGetProjects));
    }
  }

  Future<List<Project>> getTrendingProjects() async {
    const String endpointUrl = functionGetProjects;

    Map<String, String> queryParams = {
      "trending": "trending"
    };

    String queryString = Uri(queryParameters: queryParams).query;
    var requestUrl = '$endpointUrl?$queryString';

    final response = await http.get(Uri.parse(requestUrl));
    if (kDebugMode) {
      print('fetch projects !!!');
      print(response.statusCode);
    }
    if (response.statusCode == 200) {
      return compute(parseProjects, response.body);
    } else {
      throw HttpException(
          'Unexpected status code ${response.statusCode}:'
              ' ${response.reasonPhrase}',
          uri: Uri.parse(functionGetProjects));
    }
  }

}
