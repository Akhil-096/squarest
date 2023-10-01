import 'dart:io';

import 'package:squarest/Utils/u_constants.dart';
import 'package:squarest/Views/v_horizontal_property_card.dart';
import 'package:squarest/Views/v_nav_page_list.dart';
import 'package:squarest/Views/v_resale_property_list.dart';
import 'package:squarest/Views/v_resale_property_screen_1.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Services/s_autocomplete_notifier.dart';
import '../Services/s_resale_property_notifier.dart';
import '../Utils/u_custom_styles.dart';

class AddResaleProperty extends StatefulWidget {
  const AddResaleProperty({Key? key}) : super(key: key);

  @override
  State<AddResaleProperty> createState() => _AddResalePropertyState();
}

class _AddResalePropertyState extends State<AddResaleProperty> {

  final postedForResaleTitle = 'Posted for Resale';
  int currentProjectPage = 1;


  @override
  void initState() {
    super.initState();
    final resalePropertyNotifier = Provider.of<ResalePropertyNotifier>(context, listen: false);
    resalePropertyNotifier.getResaleProperties(context, this);
  }

  @override
  Widget build(BuildContext context) {
    final autoCompleteNotifier = Provider.of<AutocompleteNotifier>(context);
    final resalePropertyNotifier = Provider.of<ResalePropertyNotifier>(context);
    return Scaffold(
        key: resalePropertyNotifier.scaffoldKey,
        appBar: Platform.isAndroid ? PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: AppBar(
            scrolledUnderElevation: 0.0,
            backgroundColor: (MediaQuery.of(context).platformBrightness ==
                Brightness.dark)
                ? Colors.grey[900]
                : Colors.white,
            title: Text('My Property', style: CustomTextStyles.getTitle(null, (MediaQuery.of(context).platformBrightness ==
                Brightness.dark)
                ? Colors.white
                : Colors.black, null, 19),),
            // centerTitle: true,
          ),
        ) : CupertinoNavigationBar(
          backgroundColor: (MediaQuery.of(context).platformBrightness ==
              Brightness.dark)
              ? Colors.grey[900]
              : CupertinoColors.white,
          middle: Text('My Property', style: CustomTextStyles.getTitle(null, (MediaQuery.of(context).platformBrightness ==
              Brightness.dark)
              ? CupertinoColors.white
              : CupertinoColors.black, null, 19),),
        ),
        body: SafeArea(
          child: WillPopScope(
            onWillPop: () => resalePropertyNotifier.onWillPop(context),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 2.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          postedForResaleTitle,
                          style: CustomTextStyles.getTitle(null, (MediaQuery.of(context).platformBrightness ==
                              Brightness.dark)
                              ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                              : Platform.isAndroid ? Colors.black : CupertinoColors.black, null, 19),
                        ),
                        // if(autocompleteNotifier.projectList.isNotEmpty)
                        GestureDetector(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (ctx) => ResalePropertyList(appBarTitle: postedForResaleTitle, isComingFromList: false,)
                              ),
                            ).then((value) {
                              resalePropertyNotifier.closeBottomSheet();
                            });
                          },
                          child: Text(
                              'View all',
                              style: CustomTextStyles.getTitle(null, (MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark)
                                  ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                  : Platform.isAndroid ? Colors.black : CupertinoColors.black, TextDecoration.underline, 14)
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SizedBox(
                      height: 250,
                      child: resalePropertyNotifier.isLoading ? const NavListShimmer() : resalePropertyNotifier.propertyItems.isEmpty ? const Center(child: Text('Post a property to see it here.')) : PageView.builder(
                          controller: PageController(
                              viewportFraction:
                              1/2),
                          padEnds: false,
                          onPageChanged: (page) {
                            setState(() {
                              currentProjectPage = (page % resalePropertyNotifier.propertyItems.length) + 1;
                            });
                          },
                          itemBuilder: (ctx, i) {
                            // final index = itemCount - (initialPage - i - 1) % itemCount - 1;
                            return GestureDetector(
                              onTap:  () async {
                                FocusScope.of(context).unfocus();
                                resalePropertyNotifier.propertyForBottomSheet = resalePropertyNotifier.propertyItems[i % resalePropertyNotifier.propertyItems.length];
                                resalePropertyNotifier.openBottomSheet(context, false);
                              },
                              child: Container(
                                padding: const EdgeInsets.only(left: 3.5),
                                child: HorizontalPropertyCard(
                                  resalePropertyModel:
                                  resalePropertyNotifier.propertyItems[i % resalePropertyNotifier.propertyItems.length],
                                ),
                              ),
                            );
                          }),
                    ),
                  ),
                  if(resalePropertyNotifier.propertyItems.isNotEmpty)
                    const SizedBox(
                      height: 10,
                    ),
                  if(resalePropertyNotifier.propertyItems.isNotEmpty)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        height: 20,
                        // width: 90,
                        decoration: BoxDecoration(
                          color: (MediaQuery.of(context).platformBrightness ==
                              Brightness.dark)
                              ? Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey
                              : Platform.isAndroid ? Colors.black54 : CupertinoColors.darkBackgroundGray,
                          borderRadius:
                          BorderRadius.circular(30.0),
                        ),
                        child: Text('$currentProjectPage/${resalePropertyNotifier.propertyItems.length}', style: TextStyle(color: Platform.isAndroid ? Colors.white : CupertinoColors.white),),
                      ),
                    ),
                  const SizedBox(
                      height: 30
                  ),
                  if(!resalePropertyNotifier.isBottomSheetOpen)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => const ResalePropertyScreen1(isComingFromEdit: false, resalePropertyModel: null,))).then((value) async {
                        await resalePropertyNotifier.getResaleProperties(context, this);
                        resalePropertyNotifier.buildingNameTextController.clear();
                        resalePropertyNotifier.floorMinTextController.clear();
                        resalePropertyNotifier.floorMaxTextController.clear();
                        resalePropertyNotifier.areaTextController.clear();
                        resalePropertyNotifier.saleTextController.clear();
                        resalePropertyNotifier.descriptionTextController.clear();
                        resalePropertyNotifier.constructionAgeTextController.clear();
                        autoCompleteNotifier.locationTextController.clear();
                        resalePropertyNotifier.isWaterSelected = false;
                        resalePropertyNotifier.isLiftSelected = false;
                        resalePropertyNotifier.isPowerSelected = false;
                        resalePropertyNotifier.isSecuritySelected = false;

                        resalePropertyNotifier.isClubSelected = false;
                        resalePropertyNotifier.isSwimmingPoolSelected = false;
                        resalePropertyNotifier.isParkSelected = false;
                        resalePropertyNotifier.isGasSelected = false;

                        resalePropertyNotifier.isBungalowSelected = false;
                        resalePropertyNotifier.isFlatSelected = true;

                        resalePropertyNotifier.twoBHK = true;
                        resalePropertyNotifier.oneBHK = false;
                        resalePropertyNotifier.threeBHK = false;
                        resalePropertyNotifier.fourPlusBHK = false;

                        resalePropertyNotifier.isOwnerSelected = true;
                        resalePropertyNotifier.isAgentSelected = false;
                      });
                    },
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 75,
                            height: 75,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: globalColor,
                            ),
                            child: Icon(
                              Platform.isAndroid ? Icons.add : CupertinoIcons.add,
                              color: CupertinoColors.white,
                              size: 37.5,
                            ),
                          ),
                          const SizedBox(height: 5,),
                          const Text('Post your property', style: TextStyle(fontWeight: FontWeight.bold),)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}
