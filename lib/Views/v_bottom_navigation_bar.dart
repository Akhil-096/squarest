import 'dart:io';

import 'package:squarest/Services/s_user_profile_notifier.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Services/s_autocomplete_notifier.dart';
import '../Utils/u_router.gr.dart';

class BottomNavigator extends StatefulWidget {
  const BottomNavigator({Key? key}) : super(key: key);

  @override
  State<BottomNavigator> createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {

  Future<bool> getIsBottomNavVisible = Future(() => true);


  @override
  Widget build(BuildContext context) {
    final autocompleteNotifier = Provider.of<AutocompleteNotifier>(context, listen: false);
    final userProfileNotifier = Provider.of<UserProfileNotifier>(context);
    getIsBottomNavVisible = userProfileNotifier.getIsBottomNavVisible();
    return Scaffold(
      key: autocompleteNotifier.scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: Consumer<AutocompleteNotifier>(
        builder: (ctx, auto, _) => Platform.isAndroid ? AutoTabsScaffold(
          routes: const [
            // if(!auto.isListClicked)
              MapRouter(),
            // else
            //   ProjectListRouter(isComingFromWorthALook:
            //   false,
            //     isComingFromBuilders:
            //     false,
            //     builderId: null,
            //     isComingFrom3d: false,
            //     appBarTitle:
            //     "Search Results",
            //     isComingFromNewLaunches:
            //     false,
            //     isComingFromTrending:
            //     false,
            //   ),
            ListPageRouter(),
            SquareRouter(),
            HomeLoanRouter(),
            MoreRouter(),
          ],
          bottomNavigationBuilder: (_, tabsRouter) {
            return FutureBuilder<dynamic>(
                future: getIsBottomNavVisible,
                builder:(ctx, snapshot) => snapshot.connectionState == ConnectionState.waiting ? const SizedBox() : !snapshot.data ? const SizedBox() :
                NavigationBarTheme(
                  data: NavigationBarThemeData(
                      indicatorColor: (MediaQuery.of(context).platformBrightness == Brightness.dark)
                          ? const Color(0xff07517e) : const Color(0xffd6eefd)
                  ),
                  child: NavigationBar(
                    key: autocompleteNotifier.bottomNavGlobalKey,
                    height:  70,
                    backgroundColor:
                    (MediaQuery.of(context).platformBrightness == Brightness.dark)
                        ? Colors.grey[900]
                        : Colors.white,
                    // type: BottomNavigationBarType.fixed,
                    // unselectedItemColor:
                    // (MediaQuery.of(context).platformBrightness == Brightness.dark)
                    //     ? Colors.white
                    //     : Colors.black,
                    // showUnselectedLabels: true,
                    destinations: [
                      NavigationDestination(
                          selectedIcon: Icon(
                            Icons.search_outlined,
                            color: (MediaQuery.of(context).platformBrightness == Brightness.dark)
                                ? Colors.white : Colors.black,
                          ),
                          icon: const Icon(
                            Icons.search_outlined,
                          ),
                          label: 'Search'),
                      NavigationDestination(
                          selectedIcon: Icon(
                            Icons.grade_outlined,
                            color: (MediaQuery.of(context).platformBrightness == Brightness.dark)
                                ? Colors.white : Colors.black,
                          ),
                          icon: const Icon(
                            Icons.grade_outlined,
                          ),
                          label: 'New & Hot'),
                      NavigationDestination(
                          selectedIcon: Icon(
                            Icons.account_circle_rounded,
                            color: (MediaQuery.of(context).platformBrightness == Brightness.dark)
                                ? Colors.white : Colors.black,
                          ),
                          icon: const Icon(
                            Icons.account_circle_outlined,
                          ),
                          label: 'Account'),
                      NavigationDestination(
                          selectedIcon: Icon(
                            Icons.account_balance_outlined,
                            color: (MediaQuery.of(context).platformBrightness == Brightness.dark)
                                ? Colors.white : Colors.black,
                          ),
                          icon: const Icon(
                            Icons.account_balance_outlined,
                          ),
                          label: 'Loan'),
                      NavigationDestination(
                          selectedIcon: Icon(
                            Icons.more_horiz_outlined,
                            color: (MediaQuery.of(context).platformBrightness == Brightness.dark)
                                ? Colors.white : Colors.black,
                          ),
                          icon: const Icon(
                            Icons.more_horiz_outlined,
                          ),
                          label: 'More'),
                    ],
                    selectedIndex: tabsRouter.activeIndex,
                    onDestinationSelected: tabsRouter.setActiveIndex,
                    // selectedLabelStyle:
                    // const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    // selectedItemColor:
                    // (MediaQuery.of(context).platformBrightness == Brightness.dark)
                    //     ? Colors.white
                    //     : Colors.black),
                  ),
                )
            );
          },
        ) : AutoTabsScaffold(
          routes: const [
            // if(!auto.isListClicked)
              MapRouter(),
            // else
            //   ProjectListRouter(
            //     isComingFromWorthALook:
            //   false,
            //     isComingFromBuilders:
            //     false,
            //     builderId: null,
            //     isComingFrom3d: false,
            //     appBarTitle:
            //     "Search Results",
            //     isComingFromNewLaunches:
            //     false,
            //     isComingFromTrending:
            //     false,
            //   ),

            ListPageRouter(),
            SquareRouter(),
            HomeLoanRouter(),
            MoreRouter(),
          ],
          bottomNavigationBuilder: (_, tabsRouter) =>
              FutureBuilder<dynamic>(
                future: getIsBottomNavVisible,
                builder: (ctx, snapshot) => snapshot.connectionState == ConnectionState.waiting ? const SizedBox() : !snapshot.data ? const SizedBox() :
                CupertinoTabBar(
                  currentIndex: tabsRouter.activeIndex,
                  onTap: tabsRouter.setActiveIndex,
                  height: 60,
                  activeColor: CupertinoColors.activeBlue,
                  inactiveColor: (MediaQuery.of(context).platformBrightness == Brightness.dark) ? CupertinoColors.white : CupertinoColors.black,
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.search),
                      label: 'Search',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.list_bullet),
                      label: 'New & Hot',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.person_circle),
                      label: 'Account',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.percent),
                      label: 'Loan',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.rectangle_grid_1x2),
                      label: ' More',
                    ),
                  ],
                ),
                // tabBuilder: (BuildContext context, int index) {
                //   return CupertinoTabView(
                //     builder: (BuildContext context) {
                //       return index == 0 ? const MapSearch() : index == 1 ? const ListPage() : index == 2 ? const MySquare() : index == 3 ? const HomeLoan() : const More();
                //     },
                //   );
                // },
                // ),
              ),
        ),
      ),
    );
  }
}
