import 'package:flutter/foundation.dart';
import 'package:googleapis/storage/v1.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

class StorageAccess {
  auth.ServiceAccountCredentials accountCredentials;
  late auth.AutoRefreshingAuthClient _authClient;

  StorageAccess(String json)
      : accountCredentials = auth.ServiceAccountCredentials.fromJson(json);

  Future<List<String>> loadFromBucket(String folderName) async {
    const url = 'https://storage.googleapis.com/';
    const bktName = 'squarest_photos/';
    List<String> listImages = [];
    _authClient = await auth.clientViaServiceAccount(accountCredentials, [
      StorageApi.devstorageReadOnlyScope,
    ]);
    final storage = StorageApi(_authClient);
    var photos = await storage.objects.list(
      'squarest_photos',
      delimiter: '/',
      $fields: 'items(name)',
      prefix: '$folderName/',
    );

    try {
      final items = photos.items;
      for (var file in items ?? []) {
        String image = file.name;
        listImages.add('$url$bktName$image');
      }
    } catch(e){
      if (kDebugMode) {
        print(e);
      }
    }


    _authClient.close();
    return listImages;
  }

  // Future<List<String>> loadBuildersFromBucket(String fileName) async {
  //   const url = 'https://storage.googleapis.com/';
  //   const bktName = 'squarest_photos/';
  //   List<String> listImages = [];
  //   _authClient = await auth.clientViaServiceAccount(accountCredentials, [
  //     StorageApi.devstorageReadOnlyScope,
  //   ]);
  //   final storage = StorageApi(_authClient);
  //   var photos = await storage.objects.list(
  //     'squarest_photos',
  //     delimiter: '/',
  //     $fields: 'items(name)',
  //     prefix: '$fileName/',
  //   );
  //
  //   try {
  //     final items = photos.items;
  //     for (var file in items ?? []) {
  //       String image = file.name;
  //       listImages.add('$url$bktName$image');
  //     }
  //   } catch(e){
  //     if (kDebugMode) {
  //       print(e);
  //     }
  //   }
  //   _authClient.close();
  //   return listImages;
  // }


}
