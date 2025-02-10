import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget abuildSegmentedControl(
    double screenWidth, ValueChanged<int> onTabChanged) {
  return CustomSlidingSegmentedControl<int>(
    fixedWidth: screenWidth * 0.3,
    initialValue: 1,
    children: const {
      1: Text('Pending'),
      2: Text('History'),
    },
    decoration: BoxDecoration(
      color: CupertinoColors.lightBackgroundGray,
      borderRadius: BorderRadius.circular(8),
    ),
    thumbDecoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(76),
          blurRadius: 4.0,
          spreadRadius: 1.0,
          offset: const Offset(0.0, 2.0),
        ),
      ],
    ),
    curve: Curves.easeInToLinear,
    onValueChanged: onTabChanged,
  );
}
