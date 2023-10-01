import 'package:squarest/Views/v_bottom_navigation_bar.dart';
import 'package:squarest/Views/v_filters.dart';
import 'package:squarest/Views/v_getting_started.dart';
import 'package:squarest/Views/v_login.dart';
import 'package:squarest/Views/v_nav_page_loan.dart';
import 'package:squarest/Views/v_nav_page_more.dart';
import 'package:squarest/Views/v_nav_page_list.dart';
import 'package:squarest/Views/v_nav_page_map.dart';
import 'package:squarest/Views/v_nav_page_mysquare.dart';
import 'package:auto_route/auto_route.dart';

import '../Views/v_project_list.dart';

@MaterialAutoRouter(replaceInRouteName: 'page, Route', routes: <AutoRoute>[
  AutoRoute(page: BottomNavigator, initial: true, path: '/', children: [
    AutoRoute(page: MapSearch, path: 'mapSearch', name: "MapRouter"),
    AutoRoute(page: ProjectList, path: 'projectList', name: "ProjectListRouter"),
    AutoRoute(page: ListPage, path: 'listPage', name: "ListPageRouter"),
    AutoRoute(page: MySquare, path: 'mySquare', name: "SquareRouter"),
    AutoRoute(page: HomeLoan, path: 'homeLoan', name: "HomeLoanRouter"),
    AutoRoute(page: More, path: 'more', name: "MoreRouter"),
  ]),
  AutoRoute(
      page: GettingStarted, path: '/gettingStarted', name: "GettingStarted"),
  AutoRoute(page: LoginScreen, path: '/login', name: "Login"),
  AutoRoute(page: Filters, path: '/filters', name: "Filters"),
])
class $PageRouter {}
