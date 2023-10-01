import 'package:squarest/Models/m_builders.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:transparent_image/transparent_image.dart';
import '../Utils/u_custom_styles.dart';
import 'dart:io';

class HorizontalBuilderCard extends StatefulWidget {
  final BuildersModel topBuilders;

  const HorizontalBuilderCard({required this.topBuilders, Key? key})
      : super(key: key);

  @override
  State<HorizontalBuilderCard> createState() => _HorizontalBuilderCardState();
}

class _HorizontalBuilderCardState extends State<HorizontalBuilderCard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 5),
          child: Column(
            children: [
              SizedBox(
                height: 180,
                child: Card(
                  elevation: 2,
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(15),
                              ),
                              child: Container(
                                height: 80,
                                width: 80,
                                padding: const EdgeInsets.only(left: 1.5, right: 1.5, top: 1.5),
                                child: PageView(
                                  children: [
                                    if (widget.topBuilders.imageUrlList.isEmpty)
                                      FittedBox(
                                        fit: BoxFit.fill,
                                        child: Image.asset(
                                            'assets/images/default.png'),
                                      )
                                    else
                                      widget.topBuilders.imageUrlList.first.contains(".svg")
                                          ? FittedBox(
                                              fit: BoxFit.contain,
                                              child: SvgPicture.network(widget
                                                  .topBuilders.imageUrlList
                                                  .where((element) => element.contains(".svg"))
                                                  .toList()
                                                  .first))
                                          : FittedBox(
                                              fit: BoxFit.contain,
                                              child: CachedNetworkImage(
                                                imageUrl: widget.topBuilders.imageUrlList.first,
                                                placeholder: (context, url) =>
                                                    Image.memory(kTransparentImage),
                                                errorWidget: (context, url, error) =>
                                                    const Icon(Icons.error),
                                                fadeInDuration: const Duration(milliseconds: 10),
                                                fadeOutDuration: const Duration(milliseconds: 10),
                                              ),
                                            ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(top: 5, left: 8, right: 5),
                              child: Text(
                                widget.topBuilders.builder_name,
                                style: CustomTextStyles.getProjectNameFont(null, (MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark)
                                    ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                    : Platform.isAndroid ? Colors.black : CupertinoColors.black, 16),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              )),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 8, bottom: 5),
                            // width: 150,
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${widget.topBuilders.bld_proj} Projects',
                                  style: CustomTextStyles.getBodySmall(
                                      null, null, FontWeight.bold, 14),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  Platform.isAndroid ? Icons.arrow_forward : CupertinoIcons.right_chevron,
                                  // color: Colors.white,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
