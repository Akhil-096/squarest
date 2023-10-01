import 'dart:io';

import 'package:squarest/Models/m_project.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import '../Services/s_liked_projects_notifier.dart';
import '../Utils/u_custom_styles.dart';

class HorizontalListCard extends StatefulWidget {
  final Project project;

  const HorizontalListCard({required this.project, Key? key}) : super(key: key);

  @override
  State<HorizontalListCard> createState() => _HorizontalListCardState();
}

class _HorizontalListCardState extends State<HorizontalListCard> {



  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
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
                      if (widget.project.imageUrlList
                          .where((element) => !element.contains(".pdf"))
                          .toList()
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
                            imageUrl: widget.project.imageUrlList
                                .where((element) => !element.contains(".pdf"))
                                .toList()
                                .first,
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
                // Positioned(
                //   top: 8,
                //   left: 8,
                //   child:
                // ),
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
                          ).format(widget.project.project_views_total).replaceAll(".00", "")} views • ${DateTime.now().difference(widget.project.insert_date).inDays} days ago',
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
                Padding(
                    padding: const EdgeInsets.only(top: 5, left: 8, right: 5),
                    child: Text(
                      widget.project.name_of_project,
                      style: CustomTextStyles.getProjectNameFont(null, (MediaQuery.of(context).platformBrightness ==
                          Brightness.dark)
                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                          : Platform.isAndroid ? Colors.black : CupertinoColors.black, 16),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    )),
                Padding(
                    padding: const EdgeInsets.only(left: 8, right: 5),
                    child: Text(
                      widget.project.builder_id != 0
                          ? widget.project.builder_name
                          : widget.project.promoter_name,
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
                      priceRange(),
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
                      widget.project.project_village,
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

  String priceRange() {
    String priceText = '';
    if (widget.project.min_price == 0.0 && widget.project.max_price == 0.0) {
      priceText = 'Price on request';
    } else if (widget.project.min_price != 0.0 &&
        widget.project.max_price != 0.0) {
      priceText =
          '${widget.project.min_price} L to ${widget.project.max_price} L';
    } else if (widget.project.min_price != 0.0 &&
        widget.project.max_price == 0.0) {
      priceText = '${widget.project.min_price} L onwards';
    } else if (widget.project.min_price == 0.0 &&
        widget.project.max_price != 0.0) {
      priceText = 'Upto ${widget.project.max_price} L';
    }
    return priceText;
  }

  @override
  void initState() {
    super.initState();
    final likedProjectsNotifier = Provider.of<LikedProjectsNotifier>(context, listen: false);
    likedProjectsNotifier.loadLikedImages(context);
  }
}
