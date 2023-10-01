import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';
import '../Models/m_resale_property.dart';
import '../Services/s_resale_property_notifier.dart';
import '../Utils/u_custom_styles.dart';
import 'package:provider/provider.dart';
import '../Services/s_user_profile_notifier.dart';



class HorizontalPropertyCard extends StatefulWidget {
  final ResalePropertyModel resalePropertyModel;

  const HorizontalPropertyCard({required this.resalePropertyModel, Key? key}) : super(key: key);

  @override
  State<HorizontalPropertyCard> createState() => _HorizontalPropertyCardState();
}

class _HorizontalPropertyCardState extends State<HorizontalPropertyCard> {

  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    loadImages(widget.resalePropertyModel.address, widget.resalePropertyModel.name).then((value) {
      if(mounted) {
        setState(() {
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final userProfileNotifier = Provider.of<UserProfileNotifier>(context);
    final resalePropertyNotifier = Provider.of<ResalePropertyNotifier>(context);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(),
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: PageView(
                    children: [
                      if (imageUrls
                          .isEmpty)
                        FittedBox(
                          fit: BoxFit.fill,
                          child: Image.asset(
                              'assets/images/default.png'),
                        )
                      else
                        FittedBox(
                          fit: BoxFit.fill,
                          child: CachedNetworkImage(
                            imageUrl: imageUrls.first,
                            placeholder: (context, url) =>
                                Image.memory(kTransparentImage),
                            errorWidget: (context, url, error) =>
                                Icon(Platform.isAndroid ? Icons.error : CupertinoIcons.exclamationmark_circle_fill),
                            fadeInDuration: const Duration(milliseconds: 10),
                            fadeOutDuration: const Duration(milliseconds: 10),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            // height: MediaQuery.of(context).size.height * 0.10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 8, right: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          '${NumberFormat.compactCurrency(
                            decimalDigits: 2,
                            symbol: '',
                          ).format(0).replaceAll(".00", "")} views • 0 days ago',
                          style:  CustomTextStyles.getBodySmall(null, (MediaQuery.of(context).platformBrightness ==
                              Brightness.dark)
                              ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                              : Platform.isAndroid ? Colors.black : CupertinoColors.black, null, (width < 360 || height < 600) ? 10 : 11.5)),
                      // Text(
                      //     '${DateTime.now().difference(widget.project.insert_date).inDays} days ago',
                      //     style:  CustomTextStyles.getBodySmall(null, (MediaQuery.of(context).platformBrightness ==
                      //         Brightness.dark)
                      //         ? Colors.white
                      //         : Colors.black, null, 13)),
                    ],
                  ),
                ),
                if((FirebaseAuth.instance.currentUser?.uid != null && (widget.resalePropertyModel.posted_by_user_id == userProfileNotifier.userProfileModel.id)))
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          widget.resalePropertyModel.status == 0 ? "Under review" : widget.resalePropertyModel.status == 1 ? 'Changes required' : 'Live',
                          style:  CustomTextStyles.getBodySmall(null, (MediaQuery.of(context).platformBrightness ==
                              Brightness.dark)
                              ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                              : Platform.isAndroid ? Colors.black : CupertinoColors.black, null, (width < 360 || height < 600) ? 10 : 13)),
                      // Text(
                      //     '${DateTime.now().difference(widget.project.insert_date).inDays} days ago',
                      //     style:  CustomTextStyles.getBodySmall(null, (MediaQuery.of(context).platformBrightness ==
                      //         Brightness.dark)
                      //         ? Colors.white
                      //         : Colors.black, null, 13)),
                    ],
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 5, left: 8, right: 5),
                    child: (FirebaseAuth.instance.currentUser?.uid != null && (widget.resalePropertyModel.posted_by_user_id == userProfileNotifier.userProfileModel.id)) ? Text(
                      widget.resalePropertyModel.name,
                      style: CustomTextStyles.getProjectNameFont(null, (MediaQuery.of(context).platformBrightness ==
                          Brightness.dark)
                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                          : Platform.isAndroid ? Colors.black : CupertinoColors.black, 16),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ) : Text((resalePropertyNotifier.memPlans.isNotEmpty && DateTime.now().isBefore(resalePropertyNotifier.memPlans[0].ending_on)) ? widget.resalePropertyModel.name : '',
                      style: CustomTextStyles.getProjectNameFont(null, (MediaQuery.of(context).platformBrightness ==
                          Brightness.dark)
                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                          : Platform.isAndroid ? Colors.black : CupertinoColors.black, 16),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    )),
                Padding(
                    padding: const EdgeInsets.only(left: 8, right: 5),
                    child: Text(
                      'Price: ${widget.resalePropertyModel.price} L',
                      style: CustomTextStyles.getBodySmall(null, (MediaQuery.of(context).platformBrightness ==
                          Brightness.dark)
                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                          : Platform.isAndroid ? Colors.black : CupertinoColors.black, null, 14),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    )),
                Padding(
                    padding: const EdgeInsets.only(left: 8, right: 5),
                    child: Text(
                      '${widget.resalePropertyModel.area} sq. ft.',
                      style: CustomTextStyles.getBodySmall(null, (MediaQuery.of(context).platformBrightness ==
                          Brightness.dark)
                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                          : Platform.isAndroid ? Colors.black : CupertinoColors.black, null, 14),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    )),
                Padding(
                    padding: const EdgeInsets.only(left: 8, right: 5),
                    child: Text(
                      widget.resalePropertyModel.locality ?? '',
                      style: CustomTextStyles.getBodySmall(null, (MediaQuery.of(context).platformBrightness ==
                          Brightness.dark)
                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                          : Platform.isAndroid ? Colors.black : CupertinoColors.black, null, 14),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loadImages(String locationText, String name) async {
    final storageRef = FirebaseStorage.instance.ref().child('resale_properties').child('$locationText$name').child('property-photos');
    final listResult = await storageRef.listAll();
    for (var item in listResult.items) {
      imageUrls = imageUrls..add(await item.getDownloadURL());
    }
  }
}
