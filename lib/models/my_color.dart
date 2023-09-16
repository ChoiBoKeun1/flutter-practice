import 'package:flutter/material.dart';

class MyColor {
  String title = '';
  Color color = Colors.black;

  MyColor({
    required this.title,
    required this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'color': color.value.toRadixString(16),
    };
  }

  MyColor.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        color = Color(int.parse(json['color'], radix: 16));
}
