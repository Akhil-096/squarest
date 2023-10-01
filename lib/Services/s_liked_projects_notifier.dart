import 'package:squarest/Models/m_resale_property.dart';
import 'package:squarest/Services/s_liked_projects.dart';
import 'package:squarest/Services/s_storage_access.dart';
import 'package:squarest/Services/s_user_profile_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:squarest/Models/m_project.dart';


class LikedProjectsNotifier with ChangeNotifier {

  LikedProjectsService likedProjectsService = LikedProjectsService();
  // List<LikedProjectsIdsModel> likedProjectsIds = [];
  // LikedProjectsIdsModel likedProjectsIdsModel = LikedProjectsIdsModel(project_id: 0);
  bool isLiked = false;
  bool isResaleLiked = false;
  List<Project> likedProjectsList = [];
  List<ResalePropertyModel> likedResalePropertyList = [];
  bool isLoading = false;
  bool isResaleLoading = false;
  bool isNavigatingToProfile = false;

  // setIsLikedToFalse() {
  //   isLiked = false;
  //   notifyListeners();
  // }
  //
  // setIsResaleLikedToFalse() {
  //   isResaleLiked = false;
  //   notifyListeners();
  // }

  Future<void> insertLikes(int id, int projectId) async {
    await likedProjectsService.insertLikes(id, projectId);
  }

  Future<void> deleteLikes(int id, int projectId) async {
    await likedProjectsService.deleteLikes(id, projectId);
  }

  Future<void> getLikedProjects(BuildContext context) async {
    isLoading = true;
    final userProfileNotifier = Provider.of<UserProfileNotifier>(context, listen: false);
    likedProjectsList = await likedProjectsService.getLikedProjects(userProfileNotifier.userProfileModel.id).whenComplete(() {
      isLoading = false;
      // loadLikedImages(context);
    });
    notifyListeners();
  }

  Future<void> insertResaleLikes(int id, int propId) async {
    await likedProjectsService.insertResaleLikes(id, propId);
  }

  Future<void> deleteResaleLikes(int id, int propId) async {
    await likedProjectsService.deleteResaleLikes(id, propId);
  }

  Future<void> getLikedResaleProperties(BuildContext context) async {
    isResaleLoading = true;
    final userProfileNotifier = Provider.of<UserProfileNotifier>(context, listen: false);
    likedResalePropertyList = await likedProjectsService.getLikedResaleProperties(userProfileNotifier.userProfileModel.id).whenComplete(() {
      isResaleLoading = false;
    });
    notifyListeners();
  }

  loadLikedImages(BuildContext context) async {
    Future.delayed(const Duration(milliseconds: 500));
    try {
      String json =
      await rootBundle.loadString('assets/storage_img_serv_acc_cred.json');
      StorageAccess storageAccess = StorageAccess(json);
      for(int i = 0 ; i < likedProjectsList.length; i++) {
       likedProjectsList[i].imageUrlList = likedProjectsList[i].imageUrlList..addAll((await storageAccess
            .loadFromBucket(likedProjectsList[i].applicationno).whenComplete(() {
              notifyListeners();
        })));
      }
    } catch (error) {
      if (kDebugMode) {
        print('$error');
      }
      rethrow;
    }
  }


}