import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;
import 'package:simpliflat_landlord/constants/strings.dart';

class CommonWidgets {
  static Widget optionText(String message, BuildContext context, {List list}) {
    return Container(
      padding: EdgeInsets.only(top: 8.0),
      height: (list == null || list.length == 0)
          ? 5.0
          : MediaQuery.of(context).size.height / 20.0,
      child: (list == null || list.length == 0)
          ? null
          : textBox(message, 15.0, fontStyle: FontStyle.italic),
    );
  }

  static Widget textBox(String text, double fontSize,
      {String fontFamily = Strings.PRIMARY_FONT_FAMILY, fontWeight = Strings.PRIMARY_FONT_WEIGHT, fontStyle = FontStyle.normal, color: Colors.blue}) {
    return Text(
      text,
      style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontFamily: fontFamily,
          fontWeight: fontWeight,
          fontStyle: fontStyle),
    );
  }

  static Widget swipeBackground() {
    return Container(
      color: Colors.red[600],
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(),
          ),
          Expanded(
            flex: 5,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
                Expanded(
                  flex: 1,
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                Expanded(
                  flex: 10,
                  child: Container(),
                ),
                Expanded(
                  flex: 1,
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(),
          ),
        ],
      ),
    );
  }

  static getDotIndicator(double s1, double s2, double s3) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Color(0xffBFDAFF),
            shape: BoxShape.circle,
          ),
          height: s1,
          width: s1,
        ),
        Container(width: 10.0,),
        Container(
          decoration: BoxDecoration(
            color: Color(0xffBFDAFF),
            shape: BoxShape.circle,
          ),
          height: s2,
          width: s2,
        ),
        Container(width: 10.0,),
        Container(
          decoration: BoxDecoration(
            color: Color(0xffBFDAFF),
            shape: BoxShape.circle,
          ),
          height: s3,
          width: s3,
        ),
      ],
    );
  }

  static TextStyle getAppBarTitleStyle() {
    return TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600);
  }

  static TextStyle getTextStyleBold({Color color, double size}) {
    return TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, color: color == null? Colors.black: color, fontSize: size == null? 15:size);
  }

}