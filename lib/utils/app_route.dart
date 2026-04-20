import 'package:flutter/material.dart';

PageRoute<T> smoothRoute<T>({required WidgetBuilder builder}) {
  return MaterialPageRoute<T>(builder: builder);
}
