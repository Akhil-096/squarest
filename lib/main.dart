import 'dart:async';
import 'dart:io';
import 'package:squarest/Services/s_auth_notifier.dart';
import 'package:squarest/Services/s_autocomplete_notifier.dart';
import 'package:squarest/Services/s_connectivity_notifier.dart';
import 'package:squarest/Services/s_emi_notifier.dart';
import 'package:squarest/Services/s_filter_notifier.dart';
import 'package:squarest/Services/s_sort_notifier.dart';
import 'package:squarest/Services/s_user_profile_notifier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Services/s_resale_property_notifier.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Services/s_liked_projects_notifier.dart';
import 'Services/s_theme_notifier.dart';
import 'Utils/u_router.gr.dart';
import 'Utils/u_themes.dart';
import 'package:provider/provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'Views/v_custom_error_view.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:upgrader/upgrader.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // if(Platform.isIOS) {
  //   await Firebase.initializeApp(
  //     name: "squarest",
  //     options: const FirebaseOptions(
  //         apiKey: "AIzaSyB6jJpffGtWVRPO9CsBbF5jBF9uyiIiPhEfir",
  //         appId: "1:338991430020:ios:22b70bd9283121ca9e05d1",
  //         messagingSenderId: "338991430020",
  //         projectId: "still-emissary-318811")
  //   );
  // } else {
    await Firebase.initializeApp();
  // }
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = false;
  }
  FlutterError.onError = (details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError;
    FlutterError.presentError = (details) => CustomErrorView(
          flutterErrorDetails: details,
        );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    CustomErrorView(
      exception: error,
      stack: stack,
    );
    return true;
  };
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) {
          return ThemeNotifier(ThemeMode.system);
        }),
        ChangeNotifierProvider(create: (_) => AutocompleteNotifier()),
        ChangeNotifierProvider(create: (_) => FilterNotifier()),
        ChangeNotifierProvider(create: (_) => SortNotifier()),
        ChangeNotifierProvider(
          create: (_) {
            ConnectivityChangeNotifier changeNotifier =
                ConnectivityChangeNotifier();

            changeNotifier.initialLoad();
            return changeNotifier;
          },
        ),
        ChangeNotifierProvider(create: (_) => EmiNotifier()),
        ChangeNotifierProvider(create: (_) => AuthNotifier()),
        ChangeNotifierProvider(create: (_) => UserProfileNotifier()),
        ChangeNotifierProvider(create: (_) => LikedProjectsNotifier()),
        ChangeNotifierProvider(create: (_) => ResalePropertyNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appRouter = PageRouter();

  bool isFirstTime = true;
  bool flexibleUpdateAvailable = false;
  AppUpdateInfo? updateInfo;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  void showSnack(String text) {
    if (scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!)
          .showSnackBar(SnackBar(content: Text(text)));
    }
  }

  Future<bool> checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isFirstTime = (prefs.getBool('intro_seen') ?? true);
    return isFirstTime;
  }

  updateApp() async {
    await InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        updateInfo = info;
      });
    }).then((_) async {
      if (updateInfo?.updateAvailability ==
          UpdateAvailability.updateAvailable) {
        await InAppUpdate.startFlexibleUpdate().then((_) {
          setState(() {
            flexibleUpdateAvailable = true;
          });
        }).then((_) async {
          if (flexibleUpdateAvailable) {
            await InAppUpdate.completeFlexibleUpdate().then((_) {
              setState(() {
                flexibleUpdateAvailable = false;
              });
            });
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if(Platform.isAndroid) {
      updateApp();
    }
    final userProfileNotifier =
        Provider.of<UserProfileNotifier>(context, listen: false);
    final resalePropertyNotifier = Provider.of<ResalePropertyNotifier>(context, listen: false);
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      userProfileNotifier.getUser(
          context, (FirebaseAuth.instance.currentUser?.uid).toString(), this).whenComplete(() {
        resalePropertyNotifier.getMemPlans(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: checkFirstTime(),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Container(
              color: Platform.isAndroid ? Colors.white : CupertinoColors.white,
            );
          } else {
            return Platform.isAndroid ? GestureDetector(
              onTap: () {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus &&
                    currentFocus.focusedChild != null) {
                  currentFocus.focusedChild?.unfocus();
                }
              },
              child: MaterialApp.router(
                routeInformationParser: _appRouter.defaultRouteParser(),
                routerDelegate: _appRouter.delegate(initialRoutes: [
                  !snapshot.data!
                      ? const BottomNavigator()
                      : const GettingStarted(),
                ]),
                debugShowCheckedModeBanner: false,
                theme: AppThemeData().lightTheme,
                darkTheme: AppThemeData().darkTheme,
                themeMode: context.read<ThemeNotifier>().getThemeMode(),
                title: 'squarest',
                builder: (ctx, widget) {
                  Widget error = const Text('...rendering error...');
                  if (widget is Scaffold || widget is CupertinoPageScaffold || widget is Navigator) {
                    error = Scaffold(body: Center(child: error));
                  }
                  ErrorWidget.builder = (flutterErrorDetails) {
                    return CustomErrorView(
                      flutterErrorDetails: flutterErrorDetails,
                    );
                  };
                  return widget!;
                },
              ),
            ) : UpgradeAlert(
              upgrader: Upgrader(dialogStyle: UpgradeDialogStyle.cupertino),
              child: GestureDetector(
                onTap: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus &&
                      currentFocus.focusedChild != null) {
                    currentFocus.focusedChild?.unfocus();
                  }
                },
                child: MaterialApp.router(
                  routeInformationParser: _appRouter.defaultRouteParser(),
                  routerDelegate: _appRouter.delegate(initialRoutes: [
                    !snapshot.data!
                        ? const BottomNavigator()
                        : const GettingStarted(),
                  ]),
                  debugShowCheckedModeBanner: false,
                  theme: AppThemeData().lightTheme,
                  darkTheme: AppThemeData().darkTheme,
                  themeMode: context.read<ThemeNotifier>().getThemeMode(),
                  title: 'squarest',
                  builder: (ctx, widget) {
                    Widget error = const Text('...rendering error...');
                    if (widget is Scaffold || widget is CupertinoPageScaffold || widget is Navigator) {
                      error = Scaffold(body: Center(child: error));
                    }
                    ErrorWidget.builder = (flutterErrorDetails) {
                      return CustomErrorView(
                        flutterErrorDetails: flutterErrorDetails,
                      );
                    };
                    return widget!;
                  },
                ),
              ),
            );
          }
        });
  }
}
