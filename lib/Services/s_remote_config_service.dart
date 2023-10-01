import 'package:firebase_remote_config/firebase_remote_config.dart';


class RemoteConfigService {
  static Future<bool> getShowBanner() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(fetchTimeout: const Duration(minutes: 2), minimumFetchInterval: const Duration(seconds: 2)));
    await remoteConfig.fetchAndActivate();
    return remoteConfig.getBool("show_banner");
  }
}