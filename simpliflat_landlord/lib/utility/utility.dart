import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;
import 'package:simpliflat_landlord/local_db/database_helper.dart';
import 'dart:math';

class Utility {


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

  static Future<void> addToSharedPref(
      {userName: 'null',
      userPhone: '',
      userId: 'null',
      notificationToken: 'null',
      bool propertyRegistered,
      int activityLastSeen}) async {
    final prefs = await SharedPreferences.getInstance();
    if (userName != 'null')
      await prefs.setString(globals.userName, userName.toString());
    if (userPhone != 'null')
      await prefs.setString(globals.userPhone, userPhone.toString());
    if (userId != 'null')
      await prefs.setString(globals.userId, userId.toString());
    if (notificationToken != 'null')
      await prefs.setString(globals.notificationToken, notificationToken);
    if (propertyRegistered != null) await prefs.setBool(globals.propertyRegistered, propertyRegistered);
    if(activityLastSeen != null) await prefs.setInt(globals.activityLastSeen, activityLastSeen);
  }

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

  static Future<int> getActivityLastSeen() async {
    final prefs = await SharedPreferences.getInstance();
    // Try reading data from the counter key. If it does not exist, return 0.
    return await prefs.get(globals.activityLastSeen);
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

  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    // Try reading data from the counter key. If it does not exist, return 0.
    return await prefs.get(globals.notificationToken);
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

  static void assertThis(bool value) {
    if(!value) {
      throw Exception;
    }
  }

}