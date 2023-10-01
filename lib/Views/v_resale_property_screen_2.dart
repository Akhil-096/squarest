import 'dart:convert';
import 'dart:io';
import 'package:squarest/Views/v_project_details.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:readmore/readmore.dart';
import '../Models/m_resale_property.dart';
import '../Services/s_autocomplete_notifier.dart';
import '../Services/s_resale_property_notifier.dart';
import '../Services/s_user_profile_notifier.dart';
import '../Utils/u_constants.dart';
import '../Utils/u_custom_styles.dart';

class ResalePropertyScreen2 extends StatefulWidget {
  final ResalePropertyModel? resalePropertyModel;
  final bool isComingFromEdit;
  const ResalePropertyScreen2({required this.isComingFromEdit, required this.resalePropertyModel, Key? key}) : super(key: key);

  @override
  State<ResalePropertyScreen2> createState() =>
      _ResalePropertyScreen2State();
}

class _ResalePropertyScreen2State
    extends State<ResalePropertyScreen2> {
  final ImagePicker imagePicker = ImagePicker();
  List<XFile> livingRoomImages = [];
  List<XFile> bedRoomImages = [];
  List<XFile> kitchenImages = [];
  List<PlatformFile> allFiles = [];
  final form1 = GlobalKey<FormState>();
  final form2 = GlobalKey<FormState>();
  List<XFile> allImages = [];
  UploadTask? uploadTask;
  bool isFilesUploading = false;



  void selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png']);
    if (result == null) return;
    setState(() {
      allFiles = allFiles..addAll(result.files);
    });
  }

  Future<void> getLivingRoomPictures() async {
    final List<XFile> selectedImages = await imagePicker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      livingRoomImages.addAll(selectedImages);
      allImages.addAll(livingRoomImages);
    }
    setState(() {});
  }

  Future<void> getBedRoomPictures() async {
    final List<XFile> selectedImages = await imagePicker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      bedRoomImages.addAll(selectedImages);
      allImages.addAll(bedRoomImages);
    }
    setState(() {});
  }

  Future<void> getKitchenPictures() async {
    final List<XFile> selectedImages = await imagePicker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      kitchenImages.addAll(selectedImages);
      allImages.addAll(kitchenImages);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final resalePropertyNotifier = Provider.of<ResalePropertyNotifier>(context);
    final autocompleteNotifier = Provider.of<AutocompleteNotifier>(context);
    // final userProfileNotifier = Provider.of<UserProfileNotifier>(context);

    return Scaffold(
      appBar: Platform.isAndroid ? PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          scrolledUnderElevation: 0.0,
          backgroundColor: (MediaQuery.of(context).platformBrightness ==
              Brightness.dark)
              ? Colors.grey[900]
              : Colors.white,
          title: Text('Post Property for Sale', style: CustomTextStyles.getTitle(null, (MediaQuery.of(context).platformBrightness ==
              Brightness.dark)
              ? Colors.white
              : Colors.black, null, 19)),
        ),
      ) : CupertinoNavigationBar(
    backgroundColor: (MediaQuery.of(context).platformBrightness ==
        Brightness.dark)
        ? Colors.grey[900]
        : CupertinoColors.white,
    middle: Text('Post Property for Sale', style: CustomTextStyles.getTitle(null, (MediaQuery.of(context).platformBrightness ==
        Brightness.dark)
        ? CupertinoColors.white
        : CupertinoColors.black, null, 19)),
      ),
      body: SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              margin: const EdgeInsets.only(top: 30, left: 10, bottom: 10),
              child: Text('Area',
                  style: CustomTextStyles.getH4(
                      null,
                      (MediaQuery.of(context)
                          .platformBrightness ==
                          Brightness.dark)
                          ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                          : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                      null,
                      14))),
          SizedBox(
            width: 200,
            child: Row(
              children: [
                Form(
                  key: form1,
                  child: Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(left: 10, right: 10),
                      child: Platform.isAndroid ? TextFormField(
                        textAlign: TextAlign.center,
                        controller: resalePropertyNotifier.areaTextController,
                        // maxLength: 8,
                        autofocus: false,
                        showCursor: true,
                        inputFormatters: [
                          DecimalTextInputFormatter(decimalRange: 2)
                        ],
                        onTap: () {
                          // showSearch(
                          //     context: context,
                          //     delegate: SearchPlaceDelegate());
                        },
                        // validator: (val) {
                        //   if (int.parse(val!) < 1) {
                        //     return 'enter value > 0';
                        //   } else {
                        //     return '';
                        //   }
                        // },
                        // // controller: _txtController,
                        // onChanged: (value) {},
                        // maxLength: 2,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          // border: InputBorder.none
                          // hintText: '00.00',
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
                        controller: resalePropertyNotifier.areaTextController,
                        autofocus: false,
                        showCursor: true,
                        inputFormatters: [
                          DecimalTextInputFormatter(decimalRange: 2)
                        ],
                        onTap: () {
                        },
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                const Flexible(child: Text('sq. feet'))
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.only(left: 10),
            child: Text('BHK',
                style: CustomTextStyles.getH4(
                    null,
                    (MediaQuery.of(context)
                        .platformBrightness ==
                        Brightness.dark)
                        ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                        : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                    null,
                    14)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  child: FilterChip(
                    showCheckmark: false,
                    padding: const EdgeInsets.only(left: 13, right: 13),
                    backgroundColor: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                    selectedColor: globalColor,
                    disabledColor: Platform.isAndroid ? Colors.blue : CupertinoColors.systemBlue,
                    label: Text(
                      '1',
                      style: TextStyle(fontSize: 12, color: Platform.isAndroid ? Colors.black : CupertinoColors.black),
                    ),
                    selected: resalePropertyNotifier.oneBHK,
                    onSelected: (_) {
                      setState(() {
                        resalePropertyNotifier.oneBHK = true;
                        resalePropertyNotifier.twoBHK = false;
                        resalePropertyNotifier.threeBHK = false;
                        resalePropertyNotifier.fourPlusBHK = false;
                      });
                      resalePropertyNotifier.bhk = 1;
                    },
                  ),
                ),
                Flexible(
                  child: FilterChip(
                    showCheckmark: false,
                    padding: const EdgeInsets.only(left: 13, right: 13),
                    backgroundColor: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                    selectedColor: globalColor,
                    disabledColor: Platform.isAndroid ? Colors.blue : CupertinoColors.systemBlue,
                    label: Text(
                      '2',
                      style: TextStyle(fontSize: 12, color: Platform.isAndroid ? Colors.black : CupertinoColors.black),
                    ),
                    selected: resalePropertyNotifier.twoBHK,
                    onSelected: (_) {
                      setState(() {
                        resalePropertyNotifier.oneBHK = false;
                        resalePropertyNotifier.twoBHK = true;
                        resalePropertyNotifier.threeBHK = false;
                        resalePropertyNotifier.fourPlusBHK = false;
                      });
                      resalePropertyNotifier.bhk = 2;
                    },
                  ),
                ),
                Flexible(
                  child: FilterChip(
                    showCheckmark: false,
                    padding: const EdgeInsets.only(left: 13, right: 13),
                    backgroundColor: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                    selectedColor: globalColor,
                    disabledColor: Platform.isAndroid ? Colors.blue : CupertinoColors.systemBlue,
                    label: Text(
                      '3',
                      style: TextStyle(fontSize: 12, color: Platform.isAndroid ? Colors.black : CupertinoColors.black),
                    ),
                    selected: resalePropertyNotifier.threeBHK,
                    onSelected: (_) {
                      setState(() {
                        resalePropertyNotifier.oneBHK = false;
                        resalePropertyNotifier.twoBHK = false;
                        resalePropertyNotifier.threeBHK = true;
                        resalePropertyNotifier.fourPlusBHK = false;
                      });
                      resalePropertyNotifier.bhk = 3;
                    },
                  ),
                ),
                Flexible(
                  child: FilterChip(
                    showCheckmark: false,
                    padding: const EdgeInsets.only(left: 13, right: 13),
                    backgroundColor: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                    selectedColor: globalColor,
                    disabledColor: Platform.isAndroid ? Colors.blue : CupertinoColors.systemBlue,
                    label: Text(
                      '4+',
                      style: TextStyle(fontSize: 12, color: Platform.isAndroid ? Colors.black : CupertinoColors.black),
                    ),
                    selected: resalePropertyNotifier.fourPlusBHK,
                    onSelected: (_) {
                      setState(() {
                        resalePropertyNotifier.oneBHK = false;
                        resalePropertyNotifier.twoBHK = false;
                        resalePropertyNotifier.threeBHK = false;
                        resalePropertyNotifier.fourPlusBHK = true;
                      });
                      resalePropertyNotifier.bhk = 4;
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.only(left: 10, bottom: 10),
            child: Text('Sale Price',
                style: CustomTextStyles.getH4(
                    null,
                    (MediaQuery.of(context)
                        .platformBrightness ==
                        Brightness.dark)
                        ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                        : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                    null,
                    14)),
          ),
          SizedBox(
            width: 250,
            child: Row(
              children: [
                Flexible(
                    child: Container(
                        margin: const EdgeInsets.only(top: 5, left: 10),
                        child: const Text('₹', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),))),
                Form(
                  key: form2,
                  child: Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(left: 5, right: 5),
                      child: Platform.isAndroid ? TextFormField(
                        textAlign: TextAlign.center,
                        autofocus: false,
                        showCursor: true,
                        inputFormatters: [
                          DecimalTextInputFormatter(decimalRange: 2)
                        ],
                        controller: resalePropertyNotifier.saleTextController,
                        onTap: () {
                          // showSearch(
                          //     context: context,
                          //     delegate: SearchPlaceDelegate());
                        },
                        // validator: (val) {
                        //   if (double.parse(val!) < 1) {
                        //     return 'enter value > 0';
                        //   } else {
                        //     return '';
                        //   }
                        // },
                        // // controller: _txtController,
                        // onChanged: (value) {},
                        // maxLength: 6,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          // border: InputBorder.none
                          // hintText: '00.00',
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
                        autofocus: false,
                        showCursor: true,
                        inputFormatters: [
                          DecimalTextInputFormatter(decimalRange: 2)
                        ],
                        controller: resalePropertyNotifier.saleTextController,
                        onTap: () {
                        },
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                const Flexible(child: Text('lakh'))
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.only(left: 10),
            child: Text('Photos (3 minimum)',
                style: CustomTextStyles.getH4(
                    null,
                    (MediaQuery.of(context)
                        .platformBrightness ==
                        Brightness.dark)
                        ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                        : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                    null,
                    14)),
          ),
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                    child: Column(
                  children: [
                    const Text('Living'),
                    Stack(
                      children: [
                        livingRoomImages.isNotEmpty
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: getLivingRoomPictures,
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(top: 5),
                                          height: 50,
                                          width: 50,
                                          child: Image.file(
                                            File(livingRoomImages
                                                .first.path),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            livingRoomImages = [];
                                          });
                                        },
                                        child: Container(
                                            height: 50,
                                            width: 11,
                                            color: Platform.isAndroid ? Colors.red : CupertinoColors.systemRed,
                                            child: Icon(
                                              Platform.isAndroid ? Icons.clear : CupertinoIcons.clear,
                                              size: 10,
                                              color: Platform.isAndroid ? Colors.white : CupertinoColors.white,
                                            ),
                                            ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    '${livingRoomImages.length} images selected',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ],
                              )
                            : IconButton(
                                icon:
                                    const Icon(Icons.add_a_photo_outlined),
                                onPressed: getLivingRoomPictures,
                              ),
                      ],
                    )
                  ],
                )),
                Flexible(
                    child: Column(
                  children: [
                    const Text('Bed'),
                    bedRoomImages.isNotEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: getBedRoomPictures,
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 5),
                                      height: 50,
                                      width: 50,
                                      child: Image.file(
                                        File(bedRoomImages.first.path),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        bedRoomImages = [];
                                      });
                                    },
                                    child: Container(
                                        height: 50,
                                        width: 11,
                                        color: Platform.isAndroid ? Colors.red : CupertinoColors.systemRed,
                                        child: Icon(
                                          Platform.isAndroid ? Icons.clear : CupertinoIcons.clear,
                                          size: 10,
                                          color: Platform.isAndroid ? Colors.white : CupertinoColors.white,
                                        ),
                                        ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                '${bedRoomImages.length} images selected',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          )
                        : IconButton(
                            icon: const Icon(Icons.add_a_photo_outlined),
                            onPressed: getBedRoomPictures,
                          ),
                  ],
                )),
                Flexible(
                    child: Column(
                  children: [
                    const Text('Kitchen'),
                    kitchenImages.isNotEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: getKitchenPictures,
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 5),
                                      height: 50,
                                      width: 50,
                                      child: Image.file(
                                        File(kitchenImages.first.path),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        kitchenImages = [];
                                      });
                                    },
                                    child: Container(
                                        height: 50,
                                        width: 11,
                                        color: Platform.isAndroid ? Colors.red : CupertinoColors.systemRed,
                                        child: Icon(
                                          Platform.isAndroid ? Icons.clear : CupertinoIcons.clear,
                                          size: 10,
                                          color: Platform.isAndroid ? Colors.white : CupertinoColors.white,
                                        ),
                                        ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                '${kitchenImages.length} images selected',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          )
                        : IconButton(
                            icon: const Icon(Icons.add_a_photo_outlined),
                            onPressed: getKitchenPictures,
                          ),
                  ],
                )),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.only(left: 10),
            child:
            RichText(
              text: TextSpan(
                  children: [
                    TextSpan(text: 'Document of proof of ownership:', style: CustomTextStyles.getH4(
                        null,
                        (MediaQuery.of(context)
                            .platformBrightness ==
                            Brightness.dark)
                            ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                            : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                        null,
                        14)),
                    TextSpan(text: '\n(Index-II / recent utility bill for electricity or gas)', style: CustomTextStyles.getH4(
                        null,
                        (MediaQuery.of(context)
                            .platformBrightness ==
                            Brightness.dark)
                            ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                            : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                        null,
                        14))
                  ]
              ),
              maxLines: 3,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Center(
              child: allFiles.isNotEmpty
                  ? GestureDetector(
                onTap: selectFile,
                    child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              (allFiles.first.extension == "jpg" || allFiles.first.extension == "jpeg" || allFiles.first.extension == "png")
                                  ? SizedBox(
                                      height: 100,
                                      width: 100,
                                      child: Image.file(
                                        File(allFiles.first.path!),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    )
                                  : SizedBox(
                                      height: 100,
                                      width: 100,
                                      child: GestureDetector(
                                        onTap: null,
                                        child: AbsorbPointer(
                                          child: ShowPdf(
                                              path: allFiles.where((element) => element.extension == "pdf").first.path.toString()),
                                        ),
                                      ),
                                    ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    allFiles = [];
                                  });
                                },
                                child: Container(
                                    height: 100,
                                    width: 12,
                                    color: Platform.isAndroid ? Colors.red : CupertinoColors.systemRed,
                                    child: Icon(
                                      Platform.isAndroid ? Icons.clear : CupertinoIcons.clear,
                                      size: 10,
                                      color: Platform.isAndroid ? Colors.white : CupertinoColors.white,
                                    )),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text('${allFiles.length} documents selected'),
                        ],
                      ),
                  )
                  : IconButton(
                      onPressed: selectFile,
                      icon: const Icon(Icons.upload_file_outlined))),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.only(left: 10),
            child: Text('Posted by',
                style: CustomTextStyles.getH4(
                    null,
                    (MediaQuery.of(context)
                        .platformBrightness ==
                        Brightness.dark)
                        ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                        : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                    null,
                    14)),
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
                    'Self owner',
                    style: TextStyle(fontSize: 12, color: Platform.isAndroid ? Colors.white : CupertinoColors.white),
                  ),
                  selected: resalePropertyNotifier.isOwnerSelected,
                  onSelected: (_) {
                    setState(() {
                      resalePropertyNotifier.isAgentSelected = false;
                      resalePropertyNotifier.isOwnerSelected = true;
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
                    'Agent',
                    style: TextStyle(fontSize: 12, color: Platform.isAndroid ? Colors.white : CupertinoColors.white),
                  ),
                  selected: resalePropertyNotifier.isAgentSelected,
                  onSelected: (_) {
                    setState(() {
                      resalePropertyNotifier.isAgentSelected = true;
                      resalePropertyNotifier.isOwnerSelected = false;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          isFilesUploading ? Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: LinearProgressIndicator(
                color: globalColor,
                backgroundColor: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
              )) : (Platform.isAndroid ? Center(
            child: Container(
              height: 60,
              margin: const EdgeInsets.only(left: 10, right: 10),
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: Colors.black, backgroundColor: globalColor),
                onPressed: () async {
                  if(resalePropertyNotifier.saleTextController.text.isEmpty || resalePropertyNotifier.areaTextController.text.isEmpty){
                    Fluttertoast.showToast(
                      msg:
                      'Enter all the details before you continue',
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                    );
                  }

                  if(double.parse(resalePropertyNotifier.saleTextController.text) < 1 || int.parse(resalePropertyNotifier.areaTextController.text) < 1 || livingRoomImages.isEmpty || bedRoomImages.isEmpty || kitchenImages.isEmpty){
                    if(double.parse(resalePropertyNotifier.saleTextController.text) < 1 || int.parse(resalePropertyNotifier.areaTextController.text) < 1){
                      form1.currentState?.validate();
                      form2.currentState?.validate();
                    }
                    if(livingRoomImages.isEmpty || bedRoomImages.isEmpty || kitchenImages.isEmpty){
                      Fluttertoast.showToast(
                        msg:
                        'Upload all images to continue',
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                      );
                    }
                    // if((livingRoomImages.isEmpty || bedRoomImages.isEmpty || kitchenImages.isEmpty) && allFiles.isEmpty){
                    //   Fluttertoast.showToast(
                    //     msg:
                    //     'upload images and document of proof to continue',
                    //     backgroundColor: Colors.white,
                    //     textColor: Colors.black,
                    //   );
                    // }
                    // if((livingRoomImages.isNotEmpty || bedRoomImages.isNotEmpty || kitchenImages.isNotEmpty) && allFiles.isEmpty){
                    //   Fluttertoast.showToast(
                    //     msg:
                    //     'upload property document to continue',
                    //     backgroundColor: Colors.white,
                    //     textColor: Colors.black,
                    //   );
                    // }
                  } else {
                    form1.currentState?.validate();
                    form2.currentState?.validate();
                    setState(() {
                      isFilesUploading = true;
                    });
                    uploadImages(allImages).whenComplete(() {
                      uploadDocuments(allFiles).whenComplete(() async {
                        if(widget.isComingFromEdit){
                          await resalePropertyNotifier.updateResaleProperty(context, widget.resalePropertyModel!.id, autocompleteNotifier.locationTextController.text, resalePropertyNotifier.lat, resalePropertyNotifier.lng, resalePropertyNotifier.isFlatSelected ? true : false, resalePropertyNotifier.buildingNameTextController.text, resalePropertyNotifier.isBungalowSelected ? 0 : int.parse(resalePropertyNotifier.floorMinTextController.text), resalePropertyNotifier.isBungalowSelected ? 0 : int.parse(resalePropertyNotifier.floorMaxTextController.text), int.parse(resalePropertyNotifier.constructionAgeTextController.text), resalePropertyNotifier.amenities, double.parse(resalePropertyNotifier.areaTextController.text), resalePropertyNotifier.bhk, double.parse(resalePropertyNotifier.saleTextController.text), resalePropertyNotifier.descriptionTextController.text, autocompleteNotifier.subLocality, autocompleteNotifier.locality, int.parse(autocompleteNotifier.postalCode), resalePropertyNotifier.isOwnerSelected ? true : false,).then((value) async {
                            setState(() {
                              isFilesUploading = false;
                            });
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            if(resalePropertyNotifier.isBottomSheetOpen){
                              resalePropertyNotifier.closeBottomSheet();
                            } else if (autocompleteNotifier.isBottomSheetOpen) {
                              autocompleteNotifier.closeResaleBottomSheet();
                            } else {
                              Navigator.of(context).pop();
                            }
                            final userProfileNotifier = Provider.of<UserProfileNotifier>(context, listen: false);
                            String emailPostUrl =
                                "https://api.emailjs.com/api/v1.0/email/send";
                            final url = Uri.parse(emailPostUrl);
                            final response = await http.post(url,
                                headers: {
                                  'origin': "http://localhost",
                                  'Content-Type': 'application/json',
                                },
                                body: json.encode({
                                  "service_id": "service_tc16pbr",
                                  "template_id": "template_l964mm2",
                                  "user_id": "EhQW8PzI3mUXrzJ0y",
                                  'template_params': {
                                    "message": 'Property updated by user_id ${userProfileNotifier.userProfileModel.id}',
                                  }
                                }));
                            if (kDebugMode) {
                              print(response.statusCode);
                            }
                          });
                        } else {
                          await resalePropertyNotifier.insertResaleProperty(context, autocompleteNotifier.locationTextController.text, resalePropertyNotifier.lat, resalePropertyNotifier.lng, resalePropertyNotifier.isFlatSelected ? true : false, resalePropertyNotifier.buildingNameTextController.text, resalePropertyNotifier.isBungalowSelected ? 0 : int.parse(resalePropertyNotifier.floorMinTextController.text), resalePropertyNotifier.isBungalowSelected ? 0 : int.parse(resalePropertyNotifier.floorMaxTextController.text), int.parse(resalePropertyNotifier.constructionAgeTextController.text), resalePropertyNotifier.amenities, double.parse(resalePropertyNotifier.areaTextController.text), resalePropertyNotifier.bhk, double.parse(resalePropertyNotifier.saleTextController.text), resalePropertyNotifier.descriptionTextController.text, autocompleteNotifier.subLocality, autocompleteNotifier.locality, int.parse(autocompleteNotifier.postalCode), resalePropertyNotifier.isOwnerSelected ? true : false,).then((value) async {
                            setState(() {
                              isFilesUploading = false;
                            });
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            final userProfileNotifier = Provider.of<UserProfileNotifier>(context, listen: false);
                            String emailPostUrl =
                                "https://api.emailjs.com/api/v1.0/email/send";
                            final url = Uri.parse(emailPostUrl);
                            final response = await http.post(url,
                                headers: {
                                  'origin': "http://localhost",
                                  'Content-Type': 'application/json',
                                },
                                body: json.encode({
                                  "service_id": "service_tc16pbr",
                                  "template_id": "template_l964mm2",
                                  "user_id": "EhQW8PzI3mUXrzJ0y",
                                  'template_params': {
                                    "message": 'Property posted by user_id ${userProfileNotifier.userProfileModel.id}',
                                  }
                                }));
                            if (kDebugMode) {
                              print(response.statusCode);
                            }
                          });
                        }
                      });
                    });
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  child: Text('Submit',
                      style: TextStyle(color: Colors.white, fontSize: 15)),
                ),
              ),
            ),
          ) : Container(
            width: double.infinity,
                 margin: const EdgeInsets.only(left: 10, right: 10),
                child: CupertinoButton(
            color: globalColor,
            borderRadius: BorderRadius.circular(25),
            child: const Text('Submit',
                style: TextStyle(color: CupertinoColors.white, fontSize: 15)), onPressed: () async {
            if(resalePropertyNotifier.saleTextController.text.isEmpty || resalePropertyNotifier.areaTextController.text.isEmpty){
                Fluttertoast.showToast(
                  msg:
                  'Enter all the details before you continue',
                  backgroundColor: CupertinoColors.white,
                  textColor: CupertinoColors.black,
                );
            }

            if(double.parse(resalePropertyNotifier.saleTextController.text) < 1 || int.parse(resalePropertyNotifier.areaTextController.text) < 1 || livingRoomImages.isEmpty || bedRoomImages.isEmpty || kitchenImages.isEmpty){
                if(double.parse(resalePropertyNotifier.saleTextController.text) < 1 || int.parse(resalePropertyNotifier.areaTextController.text) < 1){
                  form1.currentState?.validate();
                  form2.currentState?.validate();
                }
                if(livingRoomImages.isEmpty || bedRoomImages.isEmpty || kitchenImages.isEmpty){
                  Fluttertoast.showToast(
                    msg:
                    'Upload all images to continue',
                    backgroundColor: CupertinoColors.white,
                    textColor: CupertinoColors.black,
                  );
                }
            } else {
                form1.currentState?.validate();
                form2.currentState?.validate();
                setState(() {
                  isFilesUploading = true;
                });
                uploadImages(allImages).whenComplete(() {
                  uploadDocuments(allFiles).whenComplete(() async {
                    if(widget.isComingFromEdit){
                      await resalePropertyNotifier.updateResaleProperty(context, widget.resalePropertyModel!.id, autocompleteNotifier.locationTextController.text, resalePropertyNotifier.lat, resalePropertyNotifier.lng, resalePropertyNotifier.isFlatSelected ? true : false, resalePropertyNotifier.buildingNameTextController.text, resalePropertyNotifier.isBungalowSelected ? 0 : int.parse(resalePropertyNotifier.floorMinTextController.text), resalePropertyNotifier.isBungalowSelected ? 0 : int.parse(resalePropertyNotifier.floorMaxTextController.text), int.parse(resalePropertyNotifier.constructionAgeTextController.text), resalePropertyNotifier.amenities, double.parse(resalePropertyNotifier.areaTextController.text), resalePropertyNotifier.bhk, double.parse(resalePropertyNotifier.saleTextController.text), resalePropertyNotifier.descriptionTextController.text, autocompleteNotifier.subLocality, autocompleteNotifier.locality, int.parse(autocompleteNotifier.postalCode), resalePropertyNotifier.isOwnerSelected ? true : false,).then((value) async {
                        setState(() {
                          isFilesUploading = false;
                        });
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        if(resalePropertyNotifier.isBottomSheetOpen){
                          resalePropertyNotifier.closeBottomSheet();
                        } else if (autocompleteNotifier.isBottomSheetOpen) {
                          autocompleteNotifier.closeResaleBottomSheet();
                        } else {
                          Navigator.of(context).pop();
                        }
                        final userProfileNotifier = Provider.of<UserProfileNotifier>(context, listen: false);
                        String emailPostUrl =
                            "https://api.emailjs.com/api/v1.0/email/send";
                        final url = Uri.parse(emailPostUrl);
                        final response = await http.post(url,
                            headers: {
                              'origin': "http://localhost",
                              'Content-Type': 'application/json',
                            },
                            body: json.encode({
                              "service_id": "service_tc16pbr",
                              "template_id": "template_l964mm2",
                              "user_id": "EhQW8PzI3mUXrzJ0y",
                              'template_params': {
                                "message": 'Property updated by user_id ${userProfileNotifier.userProfileModel.id}',
                              }
                            }));
                        if (kDebugMode) {
                          print(response.statusCode);
                        }
                      });
                    } else {
                      await resalePropertyNotifier.insertResaleProperty(context, autocompleteNotifier.locationTextController.text, resalePropertyNotifier.lat, resalePropertyNotifier.lng, resalePropertyNotifier.isFlatSelected ? true : false, resalePropertyNotifier.buildingNameTextController.text, resalePropertyNotifier.isBungalowSelected ? 0 : int.parse(resalePropertyNotifier.floorMinTextController.text), resalePropertyNotifier.isBungalowSelected ? 0 : int.parse(resalePropertyNotifier.floorMaxTextController.text), int.parse(resalePropertyNotifier.constructionAgeTextController.text), resalePropertyNotifier.amenities, double.parse(resalePropertyNotifier.areaTextController.text), resalePropertyNotifier.bhk, double.parse(resalePropertyNotifier.saleTextController.text), resalePropertyNotifier.descriptionTextController.text, autocompleteNotifier.subLocality, autocompleteNotifier.locality, int.parse(autocompleteNotifier.postalCode), resalePropertyNotifier.isOwnerSelected ? true : false,).then((value) async {
                        setState(() {
                          isFilesUploading = false;
                        });
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        final userProfileNotifier = Provider.of<UserProfileNotifier>(context, listen: false);
                        String emailPostUrl =
                            "https://api.emailjs.com/api/v1.0/email/send";
                        final url = Uri.parse(emailPostUrl);
                        final response = await http.post(url,
                            headers: {
                              'origin': "http://localhost",
                              'Content-Type': 'application/json',
                            },
                            body: json.encode({
                              "service_id": "service_tc16pbr",
                              "template_id": "template_l964mm2",
                              "user_id": "EhQW8PzI3mUXrzJ0y",
                              'template_params': {
                                "message": 'Property posted by user_id ${userProfileNotifier.userProfileModel.id}',
                              }
                            }));
                        if (kDebugMode) {
                          print(response.statusCode);
                        }
                      });
                    }
                  });
                });
            }
          },),
              )),
          const SizedBox(height: 15,),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: ReadMoreText(
                  'By clicking \'Submit\' button above, I give my consent to squarest (Apartmint Solutions Pvt. Ltd.), its business associates and/or partners to share my property and contact details with others as required and to call, sms or email me regarding sale of my property...',
                  trimLines: 2,
                  // colorClickableText: Colors.white,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: 'more',
                  colorClickableText: globalColor,
                  trimExpandedText: 'less',
                  style: TextStyle(
                    fontSize: 14,
                    color: (MediaQuery.of(context)
                        .platformBrightness ==
                        Brightness.dark)
                        ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                        : Colors.grey[600],
                  ),
                  // moreStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                    ),
                  ),
                  const SizedBox(width: 10,),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: globalColor,
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    ),
      ),
    );
  }


  Future<void> uploadDocuments (List<PlatformFile> files) async {
  for(int i = 0; i < files.length; i++){
  uploadDocumentFile(files[i]);
  }
  }

  Future<String> uploadDocumentFile(PlatformFile file) async {
      final resalePropertyNotifier = Provider.of<ResalePropertyNotifier>(context, listen: false);
      final autocompleteNotifier = Provider.of<AutocompleteNotifier>(context, listen: false);

      final storageRef = FirebaseStorage.instance;
      Reference reference = storageRef.ref().child("resale_properties").child("${autocompleteNotifier.locationTextController.text}${resalePropertyNotifier.buildingNameTextController.text}").child("property-documents").child(file.name);
      uploadTask = reference.putFile(File(file.path!));
      await uploadTask?.whenComplete(() {
        if (kDebugMode) {
          print(reference.getDownloadURL());
        }
      });
      return await reference.getDownloadURL();
  }

  Future<String> uploadImageFile(XFile image) async {
    final resalePropertyNotifier = Provider.of<ResalePropertyNotifier>(context, listen: false);
    final autocompleteNotifier = Provider.of<AutocompleteNotifier>(context, listen: false);
    final storageRef = FirebaseStorage.instance;
    Reference reference = storageRef.ref().child("resale_properties").child("${autocompleteNotifier.locationTextController.text}${resalePropertyNotifier.buildingNameTextController.text}").child("property-photos").child(image.name);
    uploadTask = reference.putFile(File(image.path));
    await uploadTask?.whenComplete(() {
      if (kDebugMode) {
        print(reference.getDownloadURL());
      }
    });
    return await reference.getDownloadURL();
  }

  Future<void> uploadImages(List<XFile> images) async {
    for(int i = 0; i < images.length; i++){
      uploadImageFile(images[i]);
    }
 }
}

class ShowPdf extends StatelessWidget {
  final String path;

  const ShowPdf({Key? key, required this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const PDF().fromPath(path),
    );
  }
}
