import 'package:flutter/cupertino.dart';

extension WidgetExt on Widget {
  Padding bottom(double value) {
    return Padding(
      padding: EdgeInsets.only(bottom: value),
      child: this,
    );
  }

  Padding left(double value) {
    return Padding(
      padding: EdgeInsets.only(left: value),
      child: this,
    );
  }

  Padding right(double value) {
    return Padding(
      padding: EdgeInsets.only(right: value),
      child: this,
    );
  }

  Padding top(double value) {
    return Padding(
      padding: EdgeInsets.only(top: value),
      child: this,
    );
  }
}
