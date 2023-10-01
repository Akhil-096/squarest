import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const String functionGetProjects =
    "https://asia-south1-still-emissary-318811.cloudfunctions.net/CLD_FUN_GET_PROJECTS";

const String functionGetProjectInventory =
    "https://asia-south1-still-emissary-318811.cloudfunctions.net/CLD_FUN_GET_PROJECT_INVENTORY";

const String functionCreateUserProfile =
    "https://asia-south1-still-emissary-318811.cloudfunctions.net/CLD_FUN_CREATE_USER";

const String functionUpdateUserProfile =
    "https://asia-south1-still-emissary-318811.cloudfunctions.net/CLD_FUN_UPDATE_USER";

const String functionGetUser =
    "https://asia-south1-still-emissary-318811.cloudfunctions.net/CLD_FUN_GET_USER";

const String functionInsertLikes =
    "https://asia-south1-still-emissary-318811.cloudfunctions.net/CLD_FUN_INSERT_LIKED_PROJECT";

const String functionDeleteLikes =
    "https://asia-south1-still-emissary-318811.cloudfunctions.net/CLD_FUN_DELETE_LIKED_PROJECT";

const String functionGetLikedProjectsIds =
    "https://asia-south1-still-emissary-318811.cloudfunctions.net/CLD_FUN_GET_LIKED_PROJECTS";

const String functionIncrementViewCount =
    "https://asia-south1-still-emissary-318811.cloudfunctions.net/CLD_FUN_INCREMENT_PROJ_VIEWS";

const String functionLikedProjects =
    'https://asia-south1-still-emissary-318811.cloudfunctions.net/CLD_FUN_GET_LIKED_PROJECT_OBJ';

const String functionGetSearchProjectList =
    "https://asia-south1-still-emissary-318811.cloudfunctions.net/CLD_FUN_GET_SEARCH_PROJS";

const String functionGetTopBuilders =
    'https://asia-south1-still-emissary-318811.cloudfunctions.net/CLD_FUN_GET_TOP_BUILDERS';

const String functionInsertResaleProperty = 'https://asia-south1-still-emissary-318811.cloudfunctions.net/CLD_FUN_INSERT_RESALE_PROP';

const String functionGetResaleProperties = 'https://asia-south1-still-emissary-318811.cloudfunctions.net/CLD_FUN_GET_RESALE_PROPS';

const String functionUpdateResaleProperties = 'https://asia-south1-still-emissary-318811.cloudfunctions.net/CLD_FUN_UPDATE_RESALE_PROP';

const String functionInsertMemPlans = 'https://asia-south1-still-emissary-318811.cloudfunctions.net/CLD_FUN_INSERT_USER_MEM_PLAN';

const String functionGetMemPlans = 'https://asia-south1-still-emissary-318811.cloudfunctions.net/CLD_FUN_GET_MEM_PLANS';

const String functionLikedResaleProperties = 'https://asia-south1-still-emissary-318811.cloudfunctions.net/CLD_FUN_GET_LIKED_RESALE_PROPS';

const String functionInsertResaleLikes =
    "https://asia-south1-still-emissary-318811.cloudfunctions.net/CLD_FUN_INSERT_LIKED_RESALE_PROP";

const String functionDeleteResaleLikes =
    "https://asia-south1-still-emissary-318811.cloudfunctions.net/CLD_FUN_DELETE_LIKED_RESALE_PROP";

extension StringCasingExtension on String {
  String toCapitalized() => length > 0 ?'${this[0].toUpperCase()}${substring(1).toLowerCase()}':'';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized()).join(' ');
}

const String constEmptyString = "";
const globalColor = Color(0xff1da1f2);
const List<int> chipList = [0, 1, 2, 3, 4];
const List<String> township = ["Any", "Yes", "No"];

const List<String> cities = [
  'Pune',
];

const List<String> validityList = [
  '3 months',
];

const List<int> priceLow = [
  0,
  15,
  25,
  30,
  40,
  45,
  50,
  60,
  75,
  100,
  125,
  150,
  200,
  250,
  300,
  350,
  400,
  450,
  500,
  550,
  600,
  700,
  750,
  800,
  850,
  900,
  950,
  1000
];
const List<int> priceHigh = [
  0,
  15,
  25,
  30,
  40,
  45,
  50,
  60,
  75,
  100,
  125,
  150,
  200,
  250,
  300,
  350,
  400,
  450,
  500,
  550,
  600,
  700,
  750,
  800,
  850,
  900,
  950,
  1000
];
const List<String> availableFlats = [
  "Any",
  "Upto 10%",
  "Upto 25%",
  "Upto 50%",
  "More than 50%"
];

const List<String> plannedCompletion = [
  "Any",
  "Ready",
  "Upto 6 months",
  "Upto 1 year",
  "More than a year"
];
const List<int> carpetAreaMin = [
  0,
  100,
  150,
  200,
  250,
  300,
  350,
  400,
  450,
  500,
  550,
  600,
  650,
  700,
  750,
  800,
  850,
  900,
  1000,
  1100,
  1200,
  1300,
  1400,
  1500,
  1750,
  2000,
  2250,
  2500,
  3000,
  3500,
  4000,
  4500,
  5000,
  6000,
  7000,
  8000,
  9000,
  10000
];
const List<int> carpetAreaMax = [
  0,
  100,
  150,
  200,
  250,
  300,
  350,
  400,
  450,
  500,
  550,
  600,
  650,
  700,
  750,
  800,
  850,
  900,
  1000,
  1100,
  1200,
  1300,
  1400,
  1500,
  1750,
  2000,
  2250,
  2500,
  3000,
  3500,
  4000,
  4500,
  5000,
  6000,
  7000,
  8000,
  9000,
  10000
];
