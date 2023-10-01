import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EmiNotifier with ChangeNotifier {

  //project details screen variables
  double loanAmount = 50;
  double interestSliderValue = 8.5;
  int tenureSliderValue = 30;
  double R = 0.0;
  int N = 1;
  String monthlyEmi = '₹ 0';
  String emiPerLac = '₹ 0';

  //emi calculator screen variables
  double emiISV = 8.5;
  int emiTSV = 15;
  String emiMonthly = '₹ 0';
  double interestAmount = 0;
  double emiLSV = 25.0;
  double emiR = 0.0;
  int emiN = 1;

  final formatter = NumberFormat('##,##,##,###');

  //project details screen home loan function
  calculateMonthlyEmi() {
    R = interestSliderValue / 12 / 100;
    N = tenureSliderValue * 12;
    monthlyEmi = ((loanAmount * R * (pow((1 + R), N))) /
        ((pow((1 + R), N)) - 1))
        .isNaN
        ? '₹ 0'
        : '₹ ${formatter.format((loanAmount * R * (pow((1 + R), N))) / ((pow((1 + R), N)) - 1))}';
    return monthlyEmi;
  }

  //project details screen home loan function
  calculateEmiPerLac() {
    R = interestSliderValue / 12 / 100;
    N = tenureSliderValue * 12;
    emiPerLac = ((100000 * R * (pow((1 + R), N))) / ((pow((1 + R), N)) - 1))
        .isNaN
        ? '₹ 0'
        : '₹ ${formatter.format((100000 * R * (pow((1 + R), N))) / ((pow((1 + R), N)) - 1))}';
    return emiPerLac;
  }

  //emi screen function
  calculateEmiMonthly() {
    emiR = emiISV / 12 / 100;
    emiN = emiTSV * 12;
    emiMonthly = (((emiLSV * 100000.00) * emiR * (pow((1 + emiR), emiN))) /
        ((pow((1 + emiR), emiN)) - 1))
        .isNaN
        ? '₹ 0'
        : '₹ ${formatter.format(((emiLSV * 100000.00) * emiR * (pow((1 + emiR), emiN))) / ((pow((1 + emiR), emiN)) - 1))}';
    return emiMonthly;
  }

  //emi screen function
  calculateInterestAmount(){
    emiR = emiISV / 12 / 100;
    emiN = emiTSV * 12;
    interestAmount = double.tryParse((((((emiLSV * 100000.00) *
        emiR *
        (pow((1 + emiR), emiN))) /
        ((pow((1 + emiR), emiN)) - 1)) *
        emiN) -
        (emiLSV * 100000.00))
        .isNaN
        ? '0'
        : (((((emiLSV * 100000.00) *
        emiR *
        (pow((1 + emiR), emiN))) /
        ((pow((1 + emiR), emiN)) - 1)) *
        emiN) -
        (emiLSV * 100000.00)).toStringAsFixed(0))!;
    return interestAmount;
  }

}
