import 'dart:io';

import 'package:squarest/Models/m_resale_property.dart';
import 'package:squarest/Services/s_autocomplete_notifier.dart';
import 'package:squarest/Views/v_resale_property_screen_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../Services/s_resale_property_notifier.dart';
import '../Services/s_show_address_search.dart';
import '../Utils/u_constants.dart';
import '../Utils/u_custom_styles.dart';

class ResalePropertyScreen1 extends StatefulWidget {
  final bool isComingFromEdit;
  final ResalePropertyModel? resalePropertyModel;
  const ResalePropertyScreen1({required this.isComingFromEdit, required this.resalePropertyModel, Key? key}) : super(key: key);

  @override
  State<ResalePropertyScreen1> createState() => _ResalePropertyScreen1State();
}

class _ResalePropertyScreen1State extends State<ResalePropertyScreen1> {

  final form1 = GlobalKey<FormState>();
  final form2 = GlobalKey<FormState>();
  final form3 = GlobalKey<FormState>();
  final form4 = GlobalKey<FormState>();
  final form5 = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    final autoCompleteNotifier = Provider.of<AutocompleteNotifier>(context);
    final resalePropertyNotifier = Provider.of<ResalePropertyNotifier>(context);
    return Scaffold(
      appBar: Platform.isAndroid ? PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          scrolledUnderElevation: 0.0,
          backgroundColor: (MediaQuery.of(context).platformBrightness ==
              Brightness.dark)
              ? Colors.grey[900]
              : Colors.white,
          title: Text('Post Property for Sale',
              style: CustomTextStyles.getTitle(
                  null,
                  (MediaQuery.of(context).platformBrightness == Brightness.dark)
                      ? Colors.white
                      : Colors.black,
                  null,
                  19)),
          centerTitle: true,
        ),
      ): CupertinoNavigationBar(
        backgroundColor: (MediaQuery.of(context).platformBrightness ==
            Brightness.dark)
            ? Colors.grey[900]
            : CupertinoColors.white,
        middle: Text('Post Property for Sale',
            style: CustomTextStyles.getTitle(
                null,
                (MediaQuery.of(context).platformBrightness == Brightness.dark)
                    ? CupertinoColors.white
                    : CupertinoColors.black,
                null,
                19)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              Container(
                margin: const EdgeInsets.only(left: 10),
                child: Text(
                  'Location',
                  style: CustomTextStyles.getH4(
                      null,
                      (MediaQuery.of(context).platformBrightness ==
                              Brightness.dark)
                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                          : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                      null,
                      14),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: Platform.isAndroid ? null : 50,
                margin: const EdgeInsets.only(left: 10, right: 10),
                child: Platform.isAndroid ? TextFormField(
                  controller: autoCompleteNotifier.locationTextController,
                  autofocus: false,
                  // showCursor: true,
                  onTap: () {
                    showSearch(
                        context: context, delegate: SearchAddressDelegate());
                  },
                  // controller: _txtController,
                  onChanged: (value) {},
                  decoration: InputDecoration(
                    hintText: 'Search for address of your property',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.only(left: 15),
                    fillColor: (MediaQuery.of(context).platformBrightness ==
                        Brightness.dark)
                        ? Colors.black54
                        : Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                          color: (MediaQuery.of(context).platformBrightness ==
                              Brightness.dark)
                              ? Colors.grey
                              : Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: const BorderSide(color: Colors.grey)),
                    // prefixIcon: const SizedBox(width: 5,),
                    suffixIcon: InkWell(
                      radius: 10,
                      onTap: () {
                        autoCompleteNotifier.getCurrentLocation(context, this);
                      },
                      child: Icon(Icons.my_location,
                          color: (MediaQuery.of(context).platformBrightness ==
                              Brightness.dark)
                              ? Colors.white
                              : Colors.black),
                    ),
                    // Container(
                    //   padding: const EdgeInsets.only(right: 10),
                    //   width: 10,
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.end,
                    //     children: [
                    //       // InkWell(
                    //       //   radius: 10,
                    //       //   onTap: (){
                    //       //     showSearch(
                    //       //         context: context,
                    //       //         delegate: SearchAddressDelegate());
                    //       //   },
                    //       //   child: const Icon(
                    //       //     Icons.search,
                    //       //     color: globalColor,
                    //       //   ),
                    //       // ),
                    //       // const SizedBox(
                    //       //   width: 10,
                    //       // ),
                    //       InkWell(
                    //         radius: 10,
                    //         onTap: ()  {
                    //            autoCompleteNotifier.getCurrentLocation();
                    //         },
                    //         child: Icon(Icons.my_location,
                    //             color: (MediaQuery.of(context)
                    //                 .platformBrightness ==
                    //                 Brightness.dark)
                    //                 ? Colors.white
                    //                 : Colors.black),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ),
                ) : CupertinoTextField(
                  decoration: BoxDecoration(
                    color: null,
                    border: Border.all(width: 1, color: (MediaQuery.of(context).platformBrightness ==
                        Brightness.dark)
                        ? CupertinoColors.systemGrey
                        : CupertinoColors.black,),
                    borderRadius: BorderRadius.circular(25)
                  ),
                  padding: const EdgeInsets.only(left: 15),
                  controller: autoCompleteNotifier.locationTextController,
                  autofocus: false,
                  style: TextStyle(color: (MediaQuery.of(context).platformBrightness ==
                      Brightness.dark)
                      ? CupertinoColors.white
                      : CupertinoColors.black,),
                  suffix: InkWell(
                    radius: 10,
                    onTap: () {
                      autoCompleteNotifier.getCurrentLocation(context, this);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(CupertinoIcons.location,
                          color: (MediaQuery.of(context).platformBrightness ==
                              Brightness.dark)
                              ? CupertinoColors.white
                              : CupertinoColors.black),
                    ),
                  ),
                  onTap: () {
                    showSearch(
                        context: context, delegate: SearchAddressDelegate());
                  },
                  placeholder: 'Search for address of your property',
                  onChanged: (value) {},
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.only(left: 10),
                child: Text(
                  'Type',
                  style: CustomTextStyles.getH4(
                      null,
                      (MediaQuery.of(context).platformBrightness ==
                              Brightness.dark)
                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                          : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                      null,
                      14),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                // margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  children: [
                    FilterChip(
                      showCheckmark: false,
                      padding: const EdgeInsets.only(left: 13, right: 13),
                      backgroundColor: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                      selectedColor: globalColor,
                      disabledColor: Platform.isAndroid ? Colors.blue : CupertinoColors.systemBlue,
                      label: Text(
                        'Flat',
                        style: TextStyle(fontSize: 12, color: Platform.isAndroid ? Colors.black : CupertinoColors.black),
                      ),
                      selected: resalePropertyNotifier.isFlatSelected,
                      onSelected: (_) {
                        setState(() {
                          resalePropertyNotifier.isFlatSelected = true;
                          resalePropertyNotifier.isBungalowSelected = false;
                        });
                      },
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    FilterChip(
                      showCheckmark: false,
                      padding: const EdgeInsets.only(left: 13, right: 13),
                      backgroundColor: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                      selectedColor: globalColor,
                      disabledColor: Platform.isAndroid ? Colors.blue : CupertinoColors.systemBlue,
                      label: Text(
                        'Bungalow',
                        style: TextStyle(fontSize: 12, color: Platform.isAndroid ? Colors.black : CupertinoColors.black),
                      ),
                      selected: resalePropertyNotifier.isBungalowSelected,
                      onSelected: (_) {
                        setState(() {
                          resalePropertyNotifier.isBungalowSelected = true;
                          resalePropertyNotifier.isFlatSelected = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: Text(
                    'Name of building',
                    style: CustomTextStyles.getH4(
                        null,
                        (MediaQuery.of(context).platformBrightness ==
                                Brightness.dark)
                            ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                            : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                        null,
                        14),
                  )),
              const SizedBox(height: 10),
              Form(
                key: form1,
                child: Container(
                  height: 50,
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  child: Platform.isAndroid ? TextFormField(
                    controller:
                    resalePropertyNotifier.buildingNameTextController,
                    onChanged: (val) {},
                    maxLength: 100,
                    decoration: InputDecoration(
                        hintText: 'Enter name of the building',
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        )),
                    // keyboardType: widget.id == "4"
                    //     ? TextInputType.number : null,
                  ) : CupertinoTextField(
                    decoration: BoxDecoration(
                        color: null,
                        border: Border.all(width: 1, color: (MediaQuery.of(context).platformBrightness ==
                            Brightness.dark)
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.black,),
                        borderRadius: BorderRadius.circular(25)
                    ),
                    style: TextStyle(color: (MediaQuery.of(context).platformBrightness ==
                        Brightness.dark)
                        ? CupertinoColors.white
                        : CupertinoColors.black,),
                    padding: const EdgeInsets.only(left: 15),
                    controller:
                        resalePropertyNotifier.buildingNameTextController,
                    onChanged: (val) {},
                    maxLength: 100,
                    placeholder: 'Enter name of the building',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: Text(
                    'Description',
                    style: CustomTextStyles.getH4(
                        null,
                        (MediaQuery.of(context).platformBrightness ==
                                Brightness.dark)
                            ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                            : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                        null,
                        14),
                  )),
              const SizedBox(height: 10),
              Form(
                key: form2,
                child: Container(
                  height: 50,
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  child: Platform.isAndroid ? TextFormField(
                    controller:
                    resalePropertyNotifier.descriptionTextController,
                    onChanged: (val) {},
                    maxLength: 1000,
                    decoration: InputDecoration(
                        hintText: 'Describe highlights of your property',
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        )),
                    // keyboardType: widget.id == "4"
                    //     ? TextInputType.number : null,
                  ) : CupertinoTextField(
                    decoration: BoxDecoration(
                        color: null,
                        border: Border.all(width: 1, color: (MediaQuery.of(context).platformBrightness ==
                            Brightness.dark)
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.black,),
                        borderRadius: BorderRadius.circular(25)
                    ),
                    style: TextStyle(color: (MediaQuery.of(context).platformBrightness ==
                        Brightness.dark)
                        ? CupertinoColors.white
                        : CupertinoColors.black,),
                    padding: const EdgeInsets.only(left: 15),
                    controller:
                        resalePropertyNotifier.descriptionTextController,
                    onChanged: (val) {},
                    maxLength: 1000,
                    placeholder: 'Describe highlights of your property',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (!resalePropertyNotifier.isBungalowSelected)
                Container(
                    margin: const EdgeInsets.only(left: 10, bottom: 10),
                    child: Text(
                      'Floor',
                      style: CustomTextStyles.getH4(
                          null,
                          (MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark)
                              ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                              : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                          null,
                          14),
                    )),
              if (!resalePropertyNotifier.isBungalowSelected)
                Container(
                  width: 200,
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Form(
                        key: form3,
                        child: Flexible(
                            child: Platform.isAndroid ? TextFormField(
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              controller:
                              resalePropertyNotifier.floorMinTextController,
                              textAlign: TextAlign.center,
                              maxLength: 2,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                // hintText: '0',
                                counterText: '',
                              ),
                              // validator: (val) {
                              //   if(int.parse(val!) < 1){
                              //     return 'enter value > 0';
                              //   } else {
                              //     return null;
                              //   }
                              //
                              // },
                              // onChanged: (val){
                              //   if(int.parse(val) < 1){
                              //     form.currentState?.validate();
                              //   }else{
                              //     form.currentState?.validate();
                              //   }
                              // },
                            ) : CupertinoTextField(
                              decoration: BoxDecoration(
                                  color: null,
                                  border: Border(bottom: BorderSide(width: 1, color: (MediaQuery.of(context).platformBrightness ==
                                      Brightness.dark)
                                      ? CupertinoColors.systemGrey
                                      : CupertinoColors.black,)),
                              ),
                              style: TextStyle(color: (MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark)
                                  ? CupertinoColors.white
                                  : CupertinoColors.black,),
                              padding: EdgeInsets.zero,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller:
                              resalePropertyNotifier.floorMinTextController,
                          textAlign: TextAlign.center,
                          maxLength: 2,
                          keyboardType: TextInputType.number,
                        )),
                      ),
                      const Flexible(child: Text('out of')),
                      Form(
                        key: form4,
                        child: Flexible(
                            child: Platform.isAndroid ? TextFormField(
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              controller:
                              resalePropertyNotifier.floorMaxTextController,
                              textAlign: TextAlign.center,
                              maxLength: 2,
                              // validator: (val) {
                              //   if(int.parse(val!) < 1){
                              //     return 'enter value > 0';
                              //   } else {
                              //     return null;
                              //   }
                              // },
                              // onChanged: (val){
                              //   if(int.parse(val) < 1){
                              //     form.currentState?.validate();
                              //   }else{
                              //     form.currentState?.validate();
                              //   }
                              // },
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                counterText: '',
                                // hintText: '0',
                              ),
                            ) : CupertinoTextField(
                              decoration: BoxDecoration(
                                color: null,
                                border: Border(bottom: BorderSide(width: 1, color: (MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark)
                                    ? CupertinoColors.systemGrey
                                    : CupertinoColors.black,)),
                              ),
                              style: TextStyle(color: (MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark)
                                  ? CupertinoColors.white
                                  : CupertinoColors.black,),
                              padding: EdgeInsets.zero,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller:
                              resalePropertyNotifier.floorMaxTextController,
                          textAlign: TextAlign.center,
                          maxLength: 2,
                          keyboardType: TextInputType.number,
                        )),
                      ),
                    ],
                  ),
                ),
              if (!resalePropertyNotifier.isBungalowSelected)
                const SizedBox(height: 20),
              Container(
                  margin: const EdgeInsets.only(left: 10, bottom: 10),
                  child: Text(
                    'Age of construction',
                    style: CustomTextStyles.getH4(
                        null,
                        (MediaQuery.of(context).platformBrightness ==
                                Brightness.dark)
                            ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                            : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                        null,
                        14),
                  )),
              Container(
                margin: const EdgeInsets.only(left: 2),
                width: 190,
                child: Row(
                  children: [
                    Form(
                      key: form5,
                      child: Flexible(
                        child: Container(
                          margin: const EdgeInsets.only(left: 10, right: 10),
                          child: Platform.isAndroid ? TextFormField(
                            textAlign: TextAlign.center,
                            controller: resalePropertyNotifier
                                .constructionAgeTextController,
                            autofocus: false,
                            showCursor: true,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onTap: () {
                              // showSearch(
                              //     context: context,
                              //     delegate: SearchPlaceDelegate());
                            },
                            // validator: (val) {
                            //   if(int.parse(val!) < 1){
                            //     return 'enter value > 0';
                            //   } else {
                            //     return null;
                            //   }
                            //
                            // },
                            // controller: _txtController,
                            maxLength: 2,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              // hintText: '0',
                              // border: InputBorder.none
                              counterText: "",
                              contentPadding: const EdgeInsets.all(2.0),
                              fillColor:
                              (MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark)
                                  ? Colors.black54
                                  : Colors.white,
                            ),
                          ) : CupertinoTextField(
                            decoration: BoxDecoration(
                              color: null,
                              border: Border(bottom: BorderSide(width: 1, color: (MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark)
                                  ? CupertinoColors.systemGrey
                                  : CupertinoColors.black,)),
                            ),
                            style: TextStyle(color: (MediaQuery.of(context).platformBrightness ==
                                Brightness.dark)
                                ? CupertinoColors.white
                                : CupertinoColors.black,),
                            padding: EdgeInsets.zero,
                            textAlign: TextAlign.center,
                            controller: resalePropertyNotifier
                                .constructionAgeTextController,
                            autofocus: false,
                            showCursor: true,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onTap: () {
                            },
                            maxLength: 2,
                            keyboardType: TextInputType.number,

                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Flexible(child: Text('years'))
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.only(left: 10),
                child: Text(
                  'Amenities',
                  style: CustomTextStyles.getH4(
                      null,
                      (MediaQuery.of(context).platformBrightness ==
                              Brightness.dark)
                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                          : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                      null,
                      14),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: FilterChip(
                        showCheckmark: false,
                        padding: const EdgeInsets.only(left: 13, right: 13),
                        backgroundColor: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                        selectedColor: globalColor,
                        disabledColor: Platform.isAndroid ? Colors.blue : CupertinoColors.systemBlue,
                        label: Text(
                          '24x7\nwater',
                          style: TextStyle(fontSize: 12, color: Platform.isAndroid ? Colors.black : CupertinoColors.black),
                          maxLines: 2,
                        ),
                        selected: resalePropertyNotifier.isWaterSelected,
                        onSelected: (_) {
                          setState(() {
                            resalePropertyNotifier.isWaterSelected =
                                !resalePropertyNotifier.isWaterSelected;
                          });
                          if (resalePropertyNotifier.isWaterSelected) {
                            resalePropertyNotifier.amenities.add(0);
                            if (kDebugMode) {
                              print(resalePropertyNotifier.amenities);
                            }
                          } else {
                            resalePropertyNotifier.amenities.remove(0);
                            if (kDebugMode) {
                              print(resalePropertyNotifier.amenities);
                            }
                          }
                        },
                      ),
                    ),
                    Flexible(
                      child: FilterChip(
                        showCheckmark: false,
                        padding: const EdgeInsets.only(
                            left: 13, right: 13, bottom: 8.5, top: 8.5),
                        backgroundColor: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                        selectedColor: globalColor,
                        disabledColor: Platform.isAndroid ? Colors.blue : CupertinoColors.systemBlue,
                        label: Text(
                          'Lift',
                          style: TextStyle(fontSize: 12, color: Platform.isAndroid ? Colors.black : CupertinoColors.black),
                        ),
                        selected: resalePropertyNotifier.isLiftSelected,
                        onSelected: (_) {
                          setState(() {
                            resalePropertyNotifier.isLiftSelected =
                                !resalePropertyNotifier.isLiftSelected;
                          });
                          if (resalePropertyNotifier.isLiftSelected) {
                            resalePropertyNotifier.amenities.add(1);
                            if (kDebugMode) {
                              print(resalePropertyNotifier.amenities);
                            }
                          } else {
                            resalePropertyNotifier.amenities.remove(1);
                            if (kDebugMode) {
                              print(resalePropertyNotifier.amenities);
                            }
                          }
                        },
                      ),
                    ),
                    Flexible(
                      child: FilterChip(
                        showCheckmark: false,
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        backgroundColor: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                        selectedColor: globalColor,
                        disabledColor: Platform.isAndroid ? Colors.blue : CupertinoColors.systemBlue,
                        label: Text(
                          'Power\nbackup',
                          style: TextStyle(fontSize: 12, color: Platform.isAndroid ? Colors.black : CupertinoColors.black),
                          maxLines: 2,
                        ),
                        selected: resalePropertyNotifier.isPowerSelected,
                        onSelected: (_) {
                          setState(() {
                            resalePropertyNotifier.isPowerSelected =
                                !resalePropertyNotifier.isPowerSelected;
                          });
                          if (resalePropertyNotifier.isPowerSelected) {
                            resalePropertyNotifier.amenities.add(2);
                            if (kDebugMode) {
                              print(resalePropertyNotifier.amenities);
                            }
                          } else {
                            resalePropertyNotifier.amenities.remove(2);
                            if (kDebugMode) {
                              print(resalePropertyNotifier.amenities);
                            }
                          }
                        },
                      ),
                    ),
                    Flexible(
                      child: FilterChip(
                        showCheckmark: false,
                        padding: const EdgeInsets.only(
                            left: 8, right: 8, bottom: 8.5, top: 8.5),
                        backgroundColor: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                        selectedColor: globalColor,
                        disabledColor: Platform.isAndroid ? Colors.blue : CupertinoColors.systemBlue,
                        label: Text(
                          'Security',
                          style: TextStyle(fontSize: 12, color: Platform.isAndroid ? Colors.black : CupertinoColors.black),
                        ),
                        selected: resalePropertyNotifier.isSecuritySelected,
                        onSelected: (_) {
                          setState(() {
                            resalePropertyNotifier.isSecuritySelected =
                                !resalePropertyNotifier.isSecuritySelected;
                          });
                          if (resalePropertyNotifier.isSecuritySelected) {
                            resalePropertyNotifier.amenities.add(3);
                            if (kDebugMode) {
                              print(resalePropertyNotifier.amenities);
                            }
                          } else {
                            resalePropertyNotifier.amenities.remove(3);
                            if (kDebugMode) {
                              print(resalePropertyNotifier.amenities);
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // const SizedBox(
              //   height: 5,
              // ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: FilterChip(
                        showCheckmark: false,
                        padding: const EdgeInsets.only(left: 13, right: 13),
                        backgroundColor: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                        selectedColor: globalColor,
                        disabledColor: Platform.isAndroid ? Colors.blue : CupertinoColors.systemBlue,
                        label: Text(
                          'Club\nhouse',
                          style: TextStyle(fontSize: 12, color: Platform.isAndroid ? Colors.black : CupertinoColors.black), maxLines: 2,
                        ),
                        selected: resalePropertyNotifier.isClubSelected,
                        onSelected: (_) {
                          setState(() {
                            resalePropertyNotifier.isClubSelected =
                                !resalePropertyNotifier.isClubSelected;
                          });
                          if (resalePropertyNotifier.isClubSelected) {
                            resalePropertyNotifier.amenities.add(4);
                            if (kDebugMode) {
                              print(resalePropertyNotifier.amenities);
                            }
                          } else {
                            resalePropertyNotifier.amenities.remove(4);
                            if (kDebugMode) {
                              print(resalePropertyNotifier.amenities);
                            }
                          }
                        },
                      ),
                    ),
                    Flexible(
                      child: FilterChip(
                        showCheckmark: false,
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        backgroundColor: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                        selectedColor: globalColor,
                        labelPadding: const EdgeInsets.all(0),
                        disabledColor: Platform.isAndroid ? Colors.blue : CupertinoColors.systemBlue,
                        label: Text('Swimming\n     pool',
                            style: TextStyle(fontSize: 12, color: Platform.isAndroid ? Colors.black : CupertinoColors.black),
                            maxLines: 2),
                        selected: resalePropertyNotifier.isSwimmingPoolSelected,
                        onSelected: (_) {
                          setState(() {
                            resalePropertyNotifier.isSwimmingPoolSelected =
                                !resalePropertyNotifier.isSwimmingPoolSelected;
                          });
                          if (resalePropertyNotifier.isSwimmingPoolSelected) {
                            resalePropertyNotifier.amenities.add(5);
                            if (kDebugMode) {
                              print(resalePropertyNotifier.amenities);
                            }
                          } else {
                            resalePropertyNotifier.amenities.remove(5);
                            if (kDebugMode) {
                              print(resalePropertyNotifier.amenities);
                            }
                          }
                        },
                      ),
                    ),
                    Flexible(
                      child: FilterChip(
                        showCheckmark: false,
                        padding: const EdgeInsets.only(
                            left: 8, right: 8, top: 8.5, bottom: 8.5),
                        backgroundColor: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                        selectedColor: globalColor,
                        disabledColor: Platform.isAndroid ? Colors.blue : CupertinoColors.systemBlue,
                        label: Text(
                          'Park',
                          style: TextStyle(fontSize: 12, color: Platform.isAndroid ? Colors.black : CupertinoColors.black),
                        ),
                        selected: resalePropertyNotifier.isParkSelected,
                        onSelected: (_) {
                          setState(() {
                            resalePropertyNotifier.isParkSelected =
                                !resalePropertyNotifier.isParkSelected;
                          });
                          if (resalePropertyNotifier.isParkSelected) {
                            resalePropertyNotifier.amenities.add(6);
                            if (kDebugMode) {
                              print(resalePropertyNotifier.amenities);
                            }
                          } else {
                            resalePropertyNotifier.amenities.remove(6);
                            if (kDebugMode) {
                              print(resalePropertyNotifier.amenities);
                            }
                          }
                        },
                      ),
                    ),
                    Flexible(
                      child: FilterChip(
                        showCheckmark: false,
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        backgroundColor: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                        selectedColor: globalColor,
                        disabledColor: Platform.isAndroid ? Colors.blue : CupertinoColors.systemBlue,
                        label: Text(
                          'Gas\npipeline',
                          style: TextStyle(fontSize: 12, color: Platform.isAndroid ? Colors.black : CupertinoColors.black), maxLines: 2,
                        ),
                        selected: resalePropertyNotifier.isGasSelected,
                        onSelected: (_) {
                          setState(() {
                            resalePropertyNotifier.isGasSelected =
                                !resalePropertyNotifier.isGasSelected;
                          });
                          if (resalePropertyNotifier.isGasSelected) {
                            resalePropertyNotifier.amenities.add(7);
                            if (kDebugMode) {
                              print(resalePropertyNotifier.amenities);
                            }
                          } else {
                            resalePropertyNotifier.amenities.remove(7);
                            if (kDebugMode) {
                              print(resalePropertyNotifier.amenities);
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              if(Platform.isIOS)
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10),
                width: double.infinity,
                child: CupertinoButton(
                  color: globalColor,
                  borderRadius: BorderRadius.circular(25),
                  child: const Text('Save and continue',
                    style: TextStyle(color: CupertinoColors.white, fontSize: 15)), onPressed: () {
                  if ((resalePropertyNotifier.isFlatSelected &&
                      (resalePropertyNotifier
                          .floorMinTextController.text.isEmpty ||
                          resalePropertyNotifier
                              .floorMaxTextController.text.isEmpty)) ||
                      resalePropertyNotifier
                          .constructionAgeTextController.text.isEmpty ||
                      autoCompleteNotifier
                          .locationTextController.text.isEmpty ||
                      resalePropertyNotifier
                          .descriptionTextController.text.isEmpty ||
                      resalePropertyNotifier
                          .buildingNameTextController.text.isEmpty) {
                    Fluttertoast.showToast(
                      msg: 'Enter all the details before you continue',
                      backgroundColor: CupertinoColors.white,
                      textColor: CupertinoColors.black,
                    );
                  } else if (resalePropertyNotifier.isFlatSelected &&
                      int.parse(resalePropertyNotifier
                          .floorMaxTextController.text) <
                          1) {
                    form1.currentState?.validate();
                    form2.currentState?.validate();
                    form3.currentState?.validate();
                    form4.currentState?.validate();
                    form5.currentState?.validate();
                  } else {
                    form1.currentState?.validate();
                    form2.currentState?.validate();
                    form3.currentState?.validate();
                    form4.currentState?.validate();
                    form5.currentState?.validate();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => ResalePropertyScreen2(isComingFromEdit: widget.isComingFromEdit, resalePropertyModel: widget.resalePropertyModel,)));
                  }
                },),
              ),
              if(Platform.isAndroid)
              Center(
                child: Container(
                  height: 60,
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: globalColor),
                    onPressed: () {
                      if ((resalePropertyNotifier.isFlatSelected &&
                              (resalePropertyNotifier
                                      .floorMinTextController.text.isEmpty ||
                                  resalePropertyNotifier
                                      .floorMaxTextController.text.isEmpty)) ||
                          resalePropertyNotifier
                              .constructionAgeTextController.text.isEmpty ||
                          autoCompleteNotifier
                              .locationTextController.text.isEmpty ||
                          resalePropertyNotifier
                              .descriptionTextController.text.isEmpty ||
                          resalePropertyNotifier
                              .buildingNameTextController.text.isEmpty) {
                        Fluttertoast.showToast(
                          msg: 'Enter all the details before you continue',
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                        );
                      } else if (resalePropertyNotifier.isFlatSelected &&
                          int.parse(resalePropertyNotifier
                                  .floorMaxTextController.text) <
                              1) {
                        form1.currentState?.validate();
                        form2.currentState?.validate();
                        form3.currentState?.validate();
                        form4.currentState?.validate();
                        form5.currentState?.validate();
                      } else {
                        form1.currentState?.validate();
                        form2.currentState?.validate();
                        form3.currentState?.validate();
                        form4.currentState?.validate();
                        form5.currentState?.validate();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => ResalePropertyScreen2(isComingFromEdit: widget.isComingFromEdit, resalePropertyModel: widget.resalePropertyModel,)));
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 8),
                      child: Text('Save and continue',
                          style: TextStyle(color: Colors.white, fontSize: 15)),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: globalColor,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
