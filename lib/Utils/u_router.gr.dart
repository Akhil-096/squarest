// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i11;
import 'package:flutter/cupertino.dart' as _i13;
import 'package:flutter/material.dart' as _i12;

import '../Views/v_bottom_navigation_bar.dart' as _i1;
import '../Views/v_filters.dart' as _i4;
import '../Views/v_getting_started.dart' as _i2;
import '../Views/v_login.dart' as _i3;
import '../Views/v_nav_page_list.dart' as _i7;
import '../Views/v_nav_page_loan.dart' as _i9;
import '../Views/v_nav_page_map.dart' as _i5;
import '../Views/v_nav_page_more.dart' as _i10;
import '../Views/v_nav_page_mysquare.dart' as _i8;
import '../Views/v_project_list.dart' as _i6;

class PageRouter extends _i11.RootStackRouter {
  PageRouter([_i12.GlobalKey<_i12.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i11.PageFactory> pagesMap = {
    BottomNavigator.name: (routeData) {
      return _i11.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i1.BottomNavigator(),
      );
    },
    GettingStarted.name: (routeData) {
      return _i11.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i2.GettingStarted(),
      );
    },
    Login.name: (routeData) {
      final args = routeData.argsAs<LoginArgs>();
      return _i11.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i3.LoginScreen(
          isAccountScreen: args.isAccountScreen,
          isComingFromHomeLoan: args.isComingFromHomeLoan,
          isComingFromJoinNow: args.isComingFromJoinNow,
          isComingFromKnowMore: args.isComingFromKnowMore,
          key: args.key,
        ),
      );
    },
    Filters.name: (routeData) {
      return _i11.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i4.Filters(),
      );
    },
    MapRouter.name: (routeData) {
      return _i11.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i5.MapSearch(),
      );
    },
    ProjectListRouter.name: (routeData) {
      final args = routeData.argsAs<ProjectListRouterArgs>();
      return _i11.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i6.ProjectList(
          isComingFromBuilders: args.isComingFromBuilders,
          builderId: args.builderId,
          isComingFrom3d: args.isComingFrom3d,
          appBarTitle: args.appBarTitle,
          isComingFromNewLaunches: args.isComingFromNewLaunches,
          isComingFromTrending: args.isComingFromTrending,
          isComingFromWorthALook: args.isComingFromWorthALook,
          key: args.key,
        ),
      );
    },
    ListPageRouter.name: (routeData) {
      return _i11.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i7.ListPage(),
      );
    },
    SquareRouter.name: (routeData) {
      return _i11.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i8.MySquare(),
      );
    },
    HomeLoanRouter.name: (routeData) {
      return _i11.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i9.HomeLoan(),
      );
    },
    MoreRouter.name: (routeData) {
      return _i11.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i10.More(),
      );
    },
  };

  @override
  List<_i11.RouteConfig> get routes => [
        _i11.RouteConfig(
          BottomNavigator.name,
          path: '/',
          children: [
            _i11.RouteConfig(
              MapRouter.name,
              path: 'mapSearch',
              parent: BottomNavigator.name,
            ),
            _i11.RouteConfig(
              ProjectListRouter.name,
              path: 'projectList',
              parent: BottomNavigator.name,
            ),
            _i11.RouteConfig(
              ListPageRouter.name,
              path: 'listPage',
              parent: BottomNavigator.name,
            ),
            _i11.RouteConfig(
              SquareRouter.name,
              path: 'mySquare',
              parent: BottomNavigator.name,
            ),
            _i11.RouteConfig(
              HomeLoanRouter.name,
              path: 'homeLoan',
              parent: BottomNavigator.name,
            ),
            _i11.RouteConfig(
              MoreRouter.name,
              path: 'more',
              parent: BottomNavigator.name,
            ),
          ],
        ),
        _i11.RouteConfig(
          GettingStarted.name,
          path: '/gettingStarted',
        ),
        _i11.RouteConfig(
          Login.name,
          path: '/login',
        ),
        _i11.RouteConfig(
          Filters.name,
          path: '/filters',
        ),
      ];
}

/// generated route for
/// [_i1.BottomNavigator]
class BottomNavigator extends _i11.PageRouteInfo<void> {
  const BottomNavigator({List<_i11.PageRouteInfo>? children})
      : super(
          BottomNavigator.name,
          path: '/',
          initialChildren: children,
        );

  static const String name = 'BottomNavigator';
}

/// generated route for
/// [_i2.GettingStarted]
class GettingStarted extends _i11.PageRouteInfo<void> {
  const GettingStarted()
      : super(
          GettingStarted.name,
          path: '/gettingStarted',
        );

  static const String name = 'GettingStarted';
}

/// generated route for
/// [_i3.LoginScreen]
class Login extends _i11.PageRouteInfo<LoginArgs> {
  Login({
    required bool isAccountScreen,
    required bool isComingFromHomeLoan,
    required bool isComingFromJoinNow,
    required bool isComingFromKnowMore,
    _i13.Key? key,
  }) : super(
          Login.name,
          path: '/login',
          args: LoginArgs(
            isAccountScreen: isAccountScreen,
            isComingFromHomeLoan: isComingFromHomeLoan,
            isComingFromJoinNow: isComingFromJoinNow,
            isComingFromKnowMore: isComingFromKnowMore,
            key: key,
          ),
        );

  static const String name = 'Login';
}

class LoginArgs {
  const LoginArgs({
    required this.isAccountScreen,
    required this.isComingFromHomeLoan,
    required this.isComingFromJoinNow,
    required this.isComingFromKnowMore,
    this.key,
  });

  final bool isAccountScreen;

  final bool isComingFromHomeLoan;

  final bool isComingFromJoinNow;

  final bool isComingFromKnowMore;

  final _i13.Key? key;

  @override
  String toString() {
    return 'LoginArgs{isAccountScreen: $isAccountScreen, isComingFromHomeLoan: $isComingFromHomeLoan, isComingFromJoinNow: $isComingFromJoinNow, isComingFromKnowMore: $isComingFromKnowMore, key: $key}';
  }
}

/// generated route for
/// [_i4.Filters]
class Filters extends _i11.PageRouteInfo<void> {
  const Filters()
      : super(
          Filters.name,
          path: '/filters',
        );

  static const String name = 'Filters';
}

/// generated route for
/// [_i5.MapSearch]
class MapRouter extends _i11.PageRouteInfo<void> {
  const MapRouter()
      : super(
          MapRouter.name,
          path: 'mapSearch',
        );

  static const String name = 'MapRouter';
}

/// generated route for
/// [_i6.ProjectList]
class ProjectListRouter extends _i11.PageRouteInfo<ProjectListRouterArgs> {
  ProjectListRouter({
    required bool isComingFromBuilders,
    required int? builderId,
    required bool isComingFrom3d,
    required String appBarTitle,
    required bool isComingFromNewLaunches,
    required bool isComingFromTrending,
    required bool isComingFromWorthALook,
    _i13.Key? key,
  }) : super(
          ProjectListRouter.name,
          path: 'projectList',
          args: ProjectListRouterArgs(
            isComingFromBuilders: isComingFromBuilders,
            builderId: builderId,
            isComingFrom3d: isComingFrom3d,
            appBarTitle: appBarTitle,
            isComingFromNewLaunches: isComingFromNewLaunches,
            isComingFromTrending: isComingFromTrending,
            isComingFromWorthALook: isComingFromWorthALook,
            key: key,
          ),
        );

  static const String name = 'ProjectListRouter';
}

class ProjectListRouterArgs {
  const ProjectListRouterArgs({
    required this.isComingFromBuilders,
    required this.builderId,
    required this.isComingFrom3d,
    required this.appBarTitle,
    required this.isComingFromNewLaunches,
    required this.isComingFromTrending,
    required this.isComingFromWorthALook,
    this.key,
  });

  final bool isComingFromBuilders;

  final int? builderId;

  final bool isComingFrom3d;

  final String appBarTitle;

  final bool isComingFromNewLaunches;

  final bool isComingFromTrending;

  final bool isComingFromWorthALook;

  final _i13.Key? key;

  @override
  String toString() {
    return 'ProjectListRouterArgs{isComingFromBuilders: $isComingFromBuilders, builderId: $builderId, isComingFrom3d: $isComingFrom3d, appBarTitle: $appBarTitle, isComingFromNewLaunches: $isComingFromNewLaunches, isComingFromTrending: $isComingFromTrending, isComingFromWorthALook: $isComingFromWorthALook, key: $key}';
  }
}

/// generated route for
/// [_i7.ListPage]
class ListPageRouter extends _i11.PageRouteInfo<void> {
  const ListPageRouter()
      : super(
          ListPageRouter.name,
          path: 'listPage',
        );

  static const String name = 'ListPageRouter';
}

/// generated route for
/// [_i8.MySquare]
class SquareRouter extends _i11.PageRouteInfo<void> {
  const SquareRouter()
      : super(
          SquareRouter.name,
          path: 'mySquare',
        );

  static const String name = 'SquareRouter';
}

/// generated route for
/// [_i9.HomeLoan]
class HomeLoanRouter extends _i11.PageRouteInfo<void> {
  const HomeLoanRouter()
      : super(
          HomeLoanRouter.name,
          path: 'homeLoan',
        );

  static const String name = 'HomeLoanRouter';
}

/// generated route for
/// [_i10.More]
class MoreRouter extends _i11.PageRouteInfo<void> {
  const MoreRouter()
      : super(
          MoreRouter.name,
          path: 'more',
        );

  static const String name = 'MoreRouter';
}
