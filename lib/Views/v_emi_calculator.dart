import 'dart:io';
import 'dart:math';
import 'package:squarest/Services/s_emi_notifier.dart';
import 'package:squarest/Utils/u_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../Utils/u_custom_styles.dart';

class EmiCalculator extends StatefulWidget {
  const EmiCalculator({Key? key}) : super(key: key);

  @override
  State<EmiCalculator> createState() => _EmiCalculatorState();
}

class ChartData {
  ChartData(this.x, this.y);

  final String x;
  final double y;
}

class _EmiCalculatorState extends State<EmiCalculator> {
  var loanController = TextEditingController(text: 25.0.toString());
  var tenureController = TextEditingController(text: 15.toString());
  var interestController = TextEditingController(text: 8.5.toString());
  final form1 = GlobalKey<FormState>();
  final form2 = GlobalKey<FormState>();
  final form3 = GlobalKey<FormState>();


  @override
  void initState() {
    super.initState();
    final emiNotifier = Provider.of<EmiNotifier>(context, listen: false);
    emiNotifier.calculateEmiMonthly();
    emiNotifier.calculateInterestAmount();
  }


  @override
  void dispose() {
    super.dispose();
    loanController.dispose();
    tenureController.dispose();
    interestController.dispose();
    form1.currentState?.dispose();
    form2.currentState?.dispose();
    form3.currentState?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emiNotifier = Provider.of<EmiNotifier>(context);
    return Scaffold(
      appBar: Platform.isAndroid ? PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          scrolledUnderElevation: 0.0,
          backgroundColor:
          (MediaQuery
              .of(context)
              .platformBrightness == Brightness.dark)
              ? Colors.grey[900]
              : Colors.white,
          title: Text(
            'EMI Calculator', style: CustomTextStyles.getTitle(null, (MediaQuery
              .of(context)
              .platformBrightness ==
              Brightness.dark)
              ? Colors.white
              : Colors.black, null, 20),),
          // elevation: 1,
        ),
      ) : CupertinoNavigationBar(
        middle: Text(
          'EMI Calculator', style: CustomTextStyles.getTitle(null, (MediaQuery
            .of(context)
            .platformBrightness ==
            Brightness.dark)
            ? CupertinoColors.white
            : CupertinoColors.black, null, 20),),
        backgroundColor:
        (MediaQuery
            .of(context)
            .platformBrightness == Brightness.dark)
            ? Colors.grey[900]
            : CupertinoColors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10,),
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Card(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Row(
                            children: [
                              Text(
                                'Loan Amount in Lakh',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: (MediaQuery
                                        .of(context)
                                        .platformBrightness ==
                                        Brightness.dark)
                                        ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                        : Platform.isAndroid ? Colors.black.withOpacity(0.3) : CupertinoColors.black.withOpacity(0.3),
                                    fontSize: 15),
                              ),
                              const SizedBox(
                                width: 53,
                              ),
                              const Text(
                                '₹' ' ',
                                style: TextStyle(fontSize: 20),
                              ),
                              const SizedBox(
                                width: 2,
                              ),
                              Form(
                                key: form1,
                                child: Flexible(
                                  child: Platform.isAndroid ? TextFormField(
                                    // maxLength: 8,
                                    textAlign: TextAlign.center,
                                    controller: loanController,
                                    validator: (value) {
                                      if (double.parse(value.toString()) >
                                          249 ||
                                          double.parse(value.toString()) <
                                              10) {
                                        return 'range is 10 - 249';
                                        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a value between 10 lac - 2.5 cr')));
                                      }
                                      return null;
                                    },
                                    inputFormatters: [
                                      // DecimalTextInputFormatter(
                                      //     decimalRange: 2),
                                      FilteringTextInputFormatter.allow(RegExp(r'^\d{1,3}(\.\d{0,2})?')),
                                      FilteringTextInputFormatter.deny(RegExp(r'^0+')),
                                    ],
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      counterText: '',
                                      hintStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        if (double.parse(value) >= 10 &&
                                            double.parse(value) <= 249) {
                                          form1.currentState?.validate();
                                          emiNotifier.emiLSV = double.parse(value);
                                          emiNotifier.calculateEmiMonthly();
                                          emiNotifier.calculateInterestAmount();
                                        } else {
                                          form1.currentState?.validate();
                                        }
                                      });
                                      // if (int.parse(value) >= 1000000 &&
                                      //     int.parse(value) <= 25000000) {
                                      //   _form.currentState?.validate();
                                      //   setState(
                                      //     () {
                                      //       loanSliderValue = int.parse(value);
                                      //     },
                                      //   );
                                      // } else {
                                      //   _form.currentState?.validate();
                                      // }
                                    },
                                  ) : CupertinoTextFormFieldRow(
                                    padding: EdgeInsetsDirectional.zero,
                                    style: TextStyle(
                                        color: (MediaQuery
                                            .of(context)
                                            .platformBrightness ==
                                            Brightness.dark)
                                            ? CupertinoColors.white
                                            : CupertinoColors.black
                                    ),
                                    decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            width: 1,
                                            color: (MediaQuery
                                                .of(context)
                                                .platformBrightness ==
                                                Brightness.dark)
                                                ? Colors.grey[600]!
                                                : CupertinoColors.black
                                          )
                                        )
                                    ),
                                    textAlign: TextAlign.center,
                                    controller: loanController,
                                    validator: (value) {
                                      if (double.parse(value.toString()) >
                                          249 ||
                                          double.parse(value.toString()) <
                                              10) {
                                        return 'range is 10 - 249';
                                        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a value between 10 lac - 2.5 cr')));
                                      }
                                      return null;
                                    },
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'^\d{1,3}(\.\d{0,2})?')),
                                      FilteringTextInputFormatter.deny(RegExp(r'^0+')),
                                    ],
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      setState(() {
                                        if (double.parse(value) >= 10 &&
                                            double.parse(value) <= 249) {
                                          form1.currentState?.validate();
                                          emiNotifier.emiLSV = double.parse(value);
                                          emiNotifier.calculateEmiMonthly();
                                          emiNotifier.calculateInterestAmount();
                                        } else {
                                          form1.currentState?.validate();
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if(Platform.isAndroid)
                        Slider(
                            thumbColor: Colors.white,
                            activeColor: globalColor,
                            inactiveColor: Colors.grey,
                            min: 10,
                            max: 249.99,
                            value: emiNotifier.emiLSV,
                            onChanged: (value) {
                              setState(
                                    () {
                                  emiNotifier.emiLSV = value;
                                  loanController.text =
                                      emiNotifier.emiLSV.toStringAsFixed(2);
                                  emiNotifier.calculateEmiMonthly();
                                  emiNotifier.calculateInterestAmount();
                                },
                              );
                            },
                          ),
                        if(Platform.isIOS)
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoSlider(
                            thumbColor: CupertinoColors.white,
                            activeColor: globalColor,
                            // inactiveColor: CupertinoColors.systemGrey,
                            min: 10,
                            max: 249.99,
                            value: emiNotifier.emiLSV,
                            onChanged: (value) {
                              setState(
                                    () {
                                  emiNotifier.emiLSV = value;
                                  loanController.text =
                                      emiNotifier.emiLSV.toStringAsFixed(2);
                                  emiNotifier.calculateEmiMonthly();
                                  emiNotifier.calculateInterestAmount();
                                },
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SizedBox(
                            height: 20,
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                              children: [
                                Text('₹ 10 Lac',
                                    style: TextStyle(
                                        color: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(
                                  width: 100,
                                ),
                                Text('₹ 249 Lac',
                                    style: TextStyle(
                                        color: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Row(
                            children: [
                              Text(
                                'Tenure (Years)',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: (MediaQuery
                                        .of(context)
                                        .platformBrightness ==
                                        Brightness.dark)
                                        ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                        : Platform.isAndroid ? Colors.black.withOpacity(0.3) : CupertinoColors.black.withOpacity(0.3),
                                    fontSize: 15),
                              ),
                              const SizedBox(
                                width: 145,
                              ),
                              Form(
                                key: form2,
                                child: Flexible(
                                  child: Platform.isAndroid ? TextFormField(
                                    maxLength: 2,
                                    validator: (value) {
                                      if (int.parse(value.toString()) < 1 ||
                                          int.parse(value.toString()) > 30) {
                                        return '1 - 30 years';
                                        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a value between 1 - 30 years')));
                                      }
                                      return null;
                                    },
                                    textAlign: TextAlign.center,
                                    controller: tenureController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      counterText: '',
                                      hintStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        if (int.parse(value) >= 1 &&
                                            int.parse(value) <= 30) {
                                          form2.currentState?.validate();
                                          emiNotifier.emiTSV = int.parse(value);
                                          emiNotifier.emiN =
                                              int.parse(value) * 12;
                                          emiNotifier.calculateEmiMonthly();
                                          emiNotifier.calculateInterestAmount();
                                        } else {
                                          form2.currentState?.validate();
                                        }
                                      });
                                      // if (int.parse(value) >= 1 &&
                                      //     int.parse(value) <= 30) {
                                      //   _form.currentState?.validate();
                                      //   setState(() {
                                      //     tenureSliderValue = int.parse(value);
                                      //     N = int.parse(value) * 12;
                                      //   });
                                      // } else {
                                      //   _form.currentState?.validate();
                                      // }
                                    },
                                  ) : CupertinoTextFormFieldRow(
                                    padding: EdgeInsetsDirectional.zero,
                                    style: TextStyle(
                                        color: (MediaQuery
                                            .of(context)
                                            .platformBrightness ==
                                            Brightness.dark)
                                            ? CupertinoColors.white
                                            : CupertinoColors.black
                                    ),
                                    maxLength: 2,
                                    validator: (value) {
                                      if (int.parse(value.toString()) < 1 ||
                                          int.parse(value.toString()) > 30) {
                                        return '1 - 30 years';
                                        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a value between 1 - 30 years')));
                                      }
                                      return null;
                                    },
                                    textAlign: TextAlign.center,
                                    controller: tenureController,
                                    keyboardType: TextInputType.number,
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                width: 1,
                                                color: (MediaQuery
                                                    .of(context)
                                                    .platformBrightness ==
                                                    Brightness.dark)
                                                    ? Colors.grey[600]!
                                                    : CupertinoColors.black
                                            )
                                        )
                                    ),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        if (int.parse(value) >= 1 &&
                                            int.parse(value) <= 30) {
                                          form2.currentState?.validate();
                                          emiNotifier.emiTSV = int.parse(value);
                                          emiNotifier.emiN =
                                              int.parse(value) * 12;
                                          emiNotifier.calculateEmiMonthly();
                                          emiNotifier.calculateInterestAmount();
                                        } else {
                                          form2.currentState?.validate();
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if(Platform.isAndroid)
                          Slider(
                            thumbColor: Colors.white,
                            activeColor: globalColor,
                            inactiveColor: Colors.grey,
                            min: 1,
                            max: 30,
                            value: emiNotifier.emiTSV.toDouble(),
                            onChanged: (value) {
                              setState(() {
                                emiNotifier.emiTSV = value.toInt();
                                tenureController.text =
                                    emiNotifier.emiTSV.toString();
                                emiNotifier.emiN = emiNotifier.emiTSV * 12;
                                emiNotifier.calculateEmiMonthly();
                                emiNotifier.calculateInterestAmount();
                              });
                            },
                          ),
                        if(Platform.isIOS)
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoSlider(
                            thumbColor: CupertinoColors.white,
                            activeColor: globalColor,
                            // inactiveColor: CupertinoColors.systemGrey,
                            min: 1,
                            max: 30,
                            value: emiNotifier.emiTSV.toDouble(),
                            onChanged: (value) {
                              setState(() {
                                emiNotifier.emiTSV = value.toInt();
                                tenureController.text =
                                    emiNotifier.emiTSV.toString();
                                emiNotifier.emiN = emiNotifier.emiTSV * 12;
                                emiNotifier.calculateEmiMonthly();
                                emiNotifier.calculateInterestAmount();
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SizedBox(
                            height: 20,
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                              children: const [
                                Text('1',
                                    style: TextStyle(
                                        color: CupertinoColors.systemGrey,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(
                                  width: 100,
                                ),
                                Text('30',
                                    style: TextStyle(
                                        color: CupertinoColors.systemGrey,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Row(
                            children: [
                              Text(
                                'Interest Rate (% per annum)',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: (MediaQuery
                                        .of(context)
                                        .platformBrightness ==
                                        Brightness.dark)
                                        ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                        : Platform.isAndroid ? Colors.black.withOpacity(0.3) : CupertinoColors.black.withOpacity(0.3),
                                    fontSize: 15),
                              ),
                              const SizedBox(
                                width: 59,
                              ),
                              Form(
                                key: form3,
                                child: Flexible(
                                  child: Platform.isAndroid ? TextFormField(
                                    // maxLength: emiNotifier.emiISV >= 15 ? 2 : null,
                                    validator: (value) {
                                      if (double.parse(value.toString()) >
                                          15.0) {
                                        return '1 - 15 %';
                                        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('interest rate must be less than 15%')));
                                      }
                                      return null;
                                    },
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(RegExp(r'^\d{1,2}(\.\d{0,2})?')),
                                      FilteringTextInputFormatter.deny(RegExp(r'^0+')),
                                      // FilteringTextInputFormatter.deny(RegExp(r'^([0]?[1-9]|1[0-5])')),
                                    ],
                                    textAlign: TextAlign.center,
                                    controller: interestController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      counterText: '',
                                      hintStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        if (double.parse(value) >= 0.0 &&
                                            double.parse(value) <= 15.0) {
                                          form3.currentState?.validate();
                                          emiNotifier.emiISV =
                                              double.parse(value);
                                          emiNotifier.emiR =
                                              double.parse(value) / 12 / 100;
                                          emiNotifier.calculateEmiMonthly();
                                          emiNotifier.calculateInterestAmount();
                                        } else {
                                          form3.currentState?.validate();
                                        }
                                      });
                                      // if (double.parse(value) >= 0.0 &&
                                      //     double.parse(value) <= 15.0) {
                                      //   _form.currentState?.validate();
                                      //   setState(
                                      //     () {
                                      //       interestSliderValue =
                                      //           double.parse(value);
                                      //       R = double.parse(value) / 12 / 100;
                                      //     },
                                      //   );
                                      // } else {
                                      //   _form.currentState?.validate();
                                      // }
                                    },
                                  ) : CupertinoTextFormFieldRow(
                                    padding: EdgeInsetsDirectional.zero,
                                    // maxLength: emiNotifier.emiISV >= 15 ? 2 : null,
                                    style: TextStyle(
                                      color: (MediaQuery
                                          .of(context)
                                          .platformBrightness ==
                                          Brightness.dark)
                                          ? CupertinoColors.white
                                          : CupertinoColors.black
                                    ),
                                    validator: (value) {
                                      if (double.parse(value.toString()) >
                                          15.0) {
                                        return '1 - 15 %';
                                        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('interest rate must be less than 15%')));
                                      }
                                      return null;
                                    },
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(RegExp(r'^\d{1,2}(\.\d{0,2})?')),
                                      FilteringTextInputFormatter.deny(RegExp(r'^0+')),
                                      // FilteringTextInputFormatter.deny(RegExp(r'^([0]?[1-9]|1[0-5])')),
                                    ],
                                    textAlign: TextAlign.center,
                                    controller: interestController,
                                    keyboardType: TextInputType.number,
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                width: 1,
                                                color: (MediaQuery
                                                    .of(context)
                                                    .platformBrightness ==
                                                    Brightness.dark)
                                                    ? Colors.grey[600]!
                                                    : CupertinoColors.black
                                            )
                                        )
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        if (double.parse(value) >= 0.0 &&
                                            double.parse(value) <= 15.0) {
                                          form3.currentState?.validate();
                                          emiNotifier.emiISV =
                                              double.parse(value);
                                          emiNotifier.emiR =
                                              double.parse(value) / 12 / 100;
                                          emiNotifier.calculateEmiMonthly();
                                          emiNotifier.calculateInterestAmount();
                                        } else {
                                          form3.currentState?.validate();
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const Text(
                                ' ' '%',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        if(Platform.isAndroid)
                          Slider(
                            thumbColor: Colors.white,
                            activeColor: globalColor,
                            inactiveColor: Colors.grey,
                            min: 0.0,
                            max: 15.0,
                            value: emiNotifier.emiISV,
                            onChanged: (value) {
                              setState(
                                    () {
                                  emiNotifier.emiISV =
                                      double.parse(value.toStringAsFixed(2));
                                  interestController.text =
                                      emiNotifier.emiISV.toString();
                                  emiNotifier.emiR =
                                      emiNotifier.emiISV / 12 / 100;
                                  emiNotifier.calculateEmiMonthly();
                                  emiNotifier.calculateInterestAmount();
                                },
                              );
                            },
                          ),
                        if(Platform.isIOS)
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoSlider(
                            thumbColor: CupertinoColors.white,
                            activeColor: globalColor,
                            // inactiveColor: CupertinoColors.systemGrey,
                            min: 0.0,
                            max: 15.0,
                            value: emiNotifier.emiISV,
                            onChanged: (value) {
                              setState(
                                    () {
                                  emiNotifier.emiISV =
                                      double.parse(value.toStringAsFixed(2));
                                  interestController.text =
                                      emiNotifier.emiISV.toString();
                                  emiNotifier.emiR =
                                      emiNotifier.emiISV / 12 / 100;
                                  emiNotifier.calculateEmiMonthly();
                                  emiNotifier.calculateInterestAmount();
                                },
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SizedBox(
                            height: 20,
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  '1',
                                  style: TextStyle(
                                      color: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  width: 100,
                                ),
                                Text('15',
                                    style: TextStyle(
                                        color: Platform.isAndroid ? Colors.grey : CupertinoColors.systemGrey,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly EMI',
                      style: TextStyle(
                        color: (MediaQuery
                            .of(context)
                            .platformBrightness ==
                            Brightness.dark)
                            ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                            : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(emiNotifier.emiMonthly,
                      style: TextStyle(
                          fontSize: 30,
                          color: (MediaQuery
                              .of(context)
                              .platformBrightness ==
                              Brightness.dark)
                              ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                              : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          'Principal Amount',
                          style: TextStyle(
                            color:
                            (MediaQuery
                                .of(context)
                                .platformBrightness ==
                                Brightness.dark)
                                ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                      ],
                    ),
                    Text(
                      '₹ ${emiNotifier.formatter.format(emiNotifier.emiLSV * 100000.00)}',
                      style: TextStyle(
                          fontSize: 20,
                          color: (MediaQuery
                              .of(context)
                              .platformBrightness == Brightness.dark)
                              ? globalColor
                              : Colors.blue[900],
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          'Interest Amount',
                          style: TextStyle(
                            color:
                            (MediaQuery
                                .of(context)
                                .platformBrightness ==
                                Brightness.dark)
                                ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                                : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                      ],
                    ),
                    Text(
                      '₹ ${emiNotifier.formatter.format(
                          emiNotifier.interestAmount)}',
                      style: TextStyle(
                          fontSize: 20,
                          color: (MediaQuery
                              .of(context)
                              .platformBrightness == Brightness.dark) ? Platform.isAndroid ? Colors.yellow : CupertinoColors
                              .systemYellow : Platform.isAndroid ? Colors.orange : CupertinoColors.systemOrange,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Total Amount',
                      style: TextStyle(
                        color: (MediaQuery
                            .of(context)
                            .platformBrightness ==
                            Brightness.dark)
                            ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                            : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                      ),
                    ),
                    Text(
                      ((((emiNotifier.emiLSV * 100000.00) * emiNotifier.emiR * (pow(
                          (1 + emiNotifier.emiR), emiNotifier.emiN))) /
                          ((pow((1 + emiNotifier.emiR), emiNotifier.emiN)) -
                              1)) *
                          emiNotifier.emiN)
                          .isNaN
                          ? '₹ 10,00,000'
                          : '₹ ${emiNotifier.formatter
                          .format((((emiNotifier.emiLSV * 100000.00) *
                          emiNotifier.emiR *
                          (pow((1 + emiNotifier.emiR), emiNotifier.emiN))) /
                          ((pow((1 + emiNotifier.emiR), emiNotifier.emiN)) -
                              1)) *
                          emiNotifier.emiN)}',
                      style: TextStyle(
                          fontSize: 20,
                          color: (MediaQuery
                              .of(context)
                              .platformBrightness ==
                              Brightness.dark)
                              ? Platform.isAndroid ? Colors.white : CupertinoColors.white
                              : Platform.isAndroid ? Colors.black : CupertinoColors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  height: 140,
                  width: 140,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: SfCircularChart(
                    palette: [
                      (MediaQuery
                          .of(context)
                          .platformBrightness == Brightness.dark)
                          ? globalColor
                          : Colors.blue[900]!,
                      (MediaQuery
                          .of(context)
                          .platformBrightness == Brightness.dark) ? Platform.isAndroid ? Colors.yellow : CupertinoColors
                          .systemYellow : Platform.isAndroid ? Colors.orange : CupertinoColors.systemOrange,
                    ],
                    series: <CircularSeries>[
                      PieSeries<ChartData, String>(
                          dataSource: [
                            ChartData(
                                '',
                                double.parse((emiNotifier.emiLSV * 100000).toString())),
                            ChartData(
                                '',
                                double.parse(
                                    emiNotifier.interestAmount
                                        .toStringAsFixed(0)))
                          ],
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          explode: true,
                          explodeIndex: 1)
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }
}
