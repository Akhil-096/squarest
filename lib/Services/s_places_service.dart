import 'package:squarest/Models/m_places_search.dart';
import 'package:squarest/Models/m_place.dart';
import 'package:squarest/Services/s_autocomplete_notifier.dart';
import 'package:squarest/Services/s_resale_property_notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert' as convert;
import '../Models/m_search_address.dart';

class PlacesService {

  Future<List<PlaceSearch>> getAutocomplete(String search) async {
    String placesAPI = "AIzaSyCw5bNd2XOJxMPbSG8Jr_-TPnQKeRkuO2A";
    String type = '(regions)';
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$search&key=$placesAPI&types=$type&components=country:in';
    var response = await http.get(Uri.parse(request));
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['predictions'] as List;
    return jsonResults.map((place) => PlaceSearch.fromJson(place)).toList();
  }

  Future<Place> getPlace(String placeId) async {
    String placesApiKey = "AIzaSyCw5bNd2XOJxMPbSG8Jr_-TPnQKeRkuO2A";
    var url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=formatted_address,geometry&region=in&key=$placesApiKey';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResult = json['result'] as Map<String, dynamic>;
    return Place.fromJson(jsonResult);
  }

  Future<SearchAddressModel> getSearchedAddress(String userText) async {
    String placesApiKey = "AIzaSyCw5bNd2XOJxMPbSG8Jr_-TPnQKeRkuO2A";
    var url =
        'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$userText&inputtype=textquery&fields=formatted_address,name,geometry&key=$placesApiKey';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    return SearchAddressModel.fromJson(json);
  }

  Future<void> getCityLocalityPostalCode(BuildContext context) async {
    final autoCompleteNotifier = Provider.of<AutocompleteNotifier>(context, listen: false);
    final resalePropertyNotifier = Provider.of<ResalePropertyNotifier>(context, listen: false);
    List<Placemark> placeMarks =
    await placemarkFromCoordinates(resalePropertyNotifier.lat, resalePropertyNotifier.lng);
    autoCompleteNotifier.place = placeMarks[0];
    autoCompleteNotifier.subLocality = '${autoCompleteNotifier.place?.subLocality}';
    autoCompleteNotifier.locality = '${autoCompleteNotifier.place?.locality}';
    autoCompleteNotifier.postalCode = '${autoCompleteNotifier.place?.postalCode}';
  }

}
