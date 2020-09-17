import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simpliflat_landlord/screens/globals.dart' as globals;
import 'package:simpliflat_landlord/screens/models/DatabaseHelper.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class Utility {
  static final dbHelper = DatabaseHelper.instance;



  static void createErrorSnackBar(scaffoldContext,
      {error: 'Something went wrong. Try again!'}) {
    final snackBar = SnackBar(
      content: Text(error),
      action: SnackBarAction(
        label: 'Close',
        textColor: Colors.white,
        onPressed: () {},
      ),
    );
    Scaffold.of(scaffoldContext).showSnackBar(snackBar);
  }

  static Future<List> getReadNoticesLastSeen() async {
    List<Map<String, dynamic>> t =
        await dbHelper.queryRows(globals.readNoticeIds);

    if (t.length > 0) {
      List<Map<String, dynamic>> lastSeens = new List();
      t.forEach((elem) {
        lastSeens.add({'flatId': elem['flatID'], 'lastSeen': elem['lastSeen']});
      });
      return lastSeens;
    } else {
      return null;
    }
  }

  static Future<List> getReadTasksLastSeen() async {
    List<Map<String, dynamic>> t =
        await dbHelper.queryRows(globals.readTaskIds);
    if (t.length > 0) {
      List<Map<String, dynamic>> lastSeens = new List();
      t.forEach((elem) {
        lastSeens.add({'flatId': elem['flatID'], 'lastSeen': elem['lastSeen']});
      });
      return lastSeens;
    } else {
      return null;
    }
  }

  static void updateReadTasksLastSeen(
      String flatId, int millSecondsSinceEpoch) async {
    debugPrint(millSecondsSinceEpoch.toString());
    dbHelper.insert({
      'type': globals.readTaskIds,
      'flatID': flatId,
      'lastSeen': millSecondsSinceEpoch
    });
  }

  static void updateReadNoticesLastSeen(
      String flatId, int millSecondsSinceEpoch) async {
    dbHelper.insert({
      'type': globals.readNoticeIds,
      'flatID': flatId,
      'lastSeen': millSecondsSinceEpoch
    });
  }

  static void addToSharedPref(
      {userName: 'null',
      userPhone: '',
      userId: 'null',
      flatIdList: 'null',
      flatIdDefault: 'null',
      notificationToken: 'null',
      flatName: 'null',
      bool propertyRegistered}) async {
    final prefs = await SharedPreferences.getInstance();
    if (userName != 'null')
      await prefs.setString(globals.userName, userName.toString());
    if (userPhone != 'null')
      await prefs.setString(globals.userPhone, userPhone.toString());
    if (userId != 'null')
      await prefs.setString(globals.userId, userId.toString());
    if (flatIdList != 'null') {
      List<String> temp = new List();
      for (var id in flatIdList) {
        temp.add(id.toString());
      }
      await prefs.setStringList(globals.flatIdList, temp);
    }
    if (flatIdDefault != 'null')
      await prefs.setString(globals.flatIdDefault, flatIdDefault);
    if (notificationToken != 'null')
      await prefs.setString(globals.notificationToken, notificationToken);
    if (flatName != 'null') await prefs.setString(globals.flatName, flatName);
    if (propertyRegistered != null) await prefs.setBool(globals.propertyRegistered, propertyRegistered);
  }

  // static Future<List> getReadNoticeIds() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   // Try reading data from the counter key. If it does not exist, return 0.
  //   return await prefs.get(globals.readNoticeIds);
  // }

  // static Future<List> getReadTaskIds() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   // Try reading data from the counter key. If it does not exist, return 0.
  //   return await prefs.get(globals.readTaskIds);
  // }

  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    // Try reading data from the counter key. If it does not exist, return 0.
    return await prefs.get(globals.userName);
  }

  static Future<bool> getPropertyRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    // Try reading data from the counter key. If it does not exist, return 0.
    return await prefs.get(globals.propertyRegistered);
  }

  static Future<String> getUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    // Try reading data from the counter key. If it does not exist, return 0.
    return await prefs.get(globals.userPhone);
  }

  static Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    // Try reading data from the counter key. If it does not exist, return 0.
    return await prefs.get(globals.userId);
  }

  static Future<String> getFlatIdDefault() async {
    final prefs = await SharedPreferences.getInstance();
    // Try reading data from the counter key. If it does not exist, return 0.
    return await prefs.get(globals.flatIdDefault);
  }

  static Future<List<String>> getFlatIdList() async {
    final prefs = await SharedPreferences.getInstance();
    // Try reading data from the counter key. If it does not exist, return 0.
    return await prefs.getStringList(globals.flatIdList);
  }

  static Future<String> getFlatDisplayId() async {
    final prefs = await SharedPreferences.getInstance();
    // Try reading data from the counter key. If it does not exist, return 0.
    return await prefs.get(globals.displayId);
  }

  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    // Try reading data from the counter key. If it does not exist, return 0.
    return await prefs.get(globals.notificationToken);
  }

  static Future<String> getFlatName() async {
    final prefs = await SharedPreferences.getInstance();
    // Try reading data from the counter key. If it does not exist, return 0.
    return await prefs.get(globals.flatName);
  }

  static double getAdjustedHeight(double height, BuildContext context) {
    return height * MediaQuery.of(context).size.height / 640.0;
  }

  static Color userIdColor(userId) {
    var color = userId.toString().trim().hashCode;
    return Colors.primaries[color % Colors.primaries.length];
  }

    

  static String getRandomString(int length) { 

    String _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    
    return String.fromCharCodes(Iterable.generate(
    
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

}