
import 'package:flutter/material.dart';

enum CureLinkAgeGroup {
  child,
  youth,
  olderAdult,
}

class AgeGroupUI {
  AgeGroupUI._();

  static double textScale(CureLinkAgeGroup group) {
    switch (group) {
      case CureLinkAgeGroup.child:
        return 1.1;
      case CureLinkAgeGroup.youth:
        return 1.0;
      case CureLinkAgeGroup.olderAdult:
        return 1.25;
    }
  }

  static double buttonHeight(CureLinkAgeGroup group) {
    switch (group) {
      case CureLinkAgeGroup.child:
        return 60;
      case CureLinkAgeGroup.youth:
        return 56;
      case CureLinkAgeGroup.olderAdult:
        return 68;
    }
  }

  static double iconSize(CureLinkAgeGroup group) {
    switch (group) {
      case CureLinkAgeGroup.child:
        return 26;
      case CureLinkAgeGroup.youth:
        return 22;
      case CureLinkAgeGroup.olderAdult:
        return 28;
    }
  }

  static EdgeInsets screenPadding(CureLinkAgeGroup group) {
    switch (group) {
      case CureLinkAgeGroup.child:
        return const EdgeInsets.all(16);
      case CureLinkAgeGroup.youth:
        return const EdgeInsets.all(20);
      case CureLinkAgeGroup.olderAdult:
        return const EdgeInsets.all(24);
    }
  }
}
