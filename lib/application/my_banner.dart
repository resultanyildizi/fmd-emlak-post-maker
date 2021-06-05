import 'dart:convert';

import 'package:flutter/foundation.dart';

enum BannerType { none, soldOut, rented, forFloor }

class MyBanner {
  BannerType type;
  String label;
  String bannerImagePath;
  MyBanner({
    @required this.type,
    @required this.label,
    this.bannerImagePath,
  });

  MyBanner copyWith({
    BannerType type,
    String label,
    String bannerImagePath,
  }) {
    return MyBanner(
      type: type ?? this.type,
      label: label ?? this.label,
      bannerImagePath: bannerImagePath ?? this.bannerImagePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'label': label,
      'bannerImagePath': bannerImagePath,
    };
  }

  @override
  String toString() =>
      'MyBanner(type: $type, label: $label, bannerImagePath: $bannerImagePath)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is MyBanner &&
        o.type == type &&
        o.label == label &&
        o.bannerImagePath == bannerImagePath;
  }

  @override
  int get hashCode => type.hashCode ^ label.hashCode ^ bannerImagePath.hashCode;
}
