import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simpliflat_landlord/dao/owner_dao.dart';
import 'package:simpliflat_landlord/dao/owner_flat_dao.dart';
import 'package:simpliflat_landlord/dao/owner_tenant_dao.dart';
import 'package:simpliflat_landlord/main.dart';
import 'package:simpliflat_landlord/model/owner.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/utility/utility.dart';


class AuthenticationService {
  static Future<FirebaseUser> getCurrentSignedInUser() async {
    return FirebaseAuth.instance.currentUser();
  }

  static Future<FirebaseUser> signinWithCredentials(String verificationId, String otp) async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verificationId,
      smsCode: otp,
    );
    return FirebaseAuth.instance.signInWithCredential(credential).then((FirebaseUser user) {
      return user;
    }).catchError((e) {
      return null;
    });
  }

  static Future<bool> sendOTP(String phoneNumber, Function autoRetrieve, Function codeSent, Function verifiedSuccess, Function verifiedFailed) async {
    return FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: codeSent,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verifiedSuccess,
        verificationFailed: verifiedFailed).then((ret) {return true;}).catchError((e) {return false;});
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> setNotificationToken(String userId, String notificationToken) async {
    WriteBatch wb = Firestore.instance.batch();
    wb.updateData(OwnerDao.getDocumentReference(userId), Owner.toUpdateJson(notificationToken: notificationToken));
    QuerySnapshot qs = await Firestore.instance.collection(globals.ownerTenantFlat).orderBy('o_' + userId).getDocuments();
    
    if(qs.documents != null && qs.documents.isNotEmpty) {
      for(int i = 0; i < qs.documents.length; i++) {
        DocumentReference dr = Firestore.instance.collection('notification_tokens').document(qs.documents[i].documentID);
        String val = qs.documents[i].data['o_' + userId];
        String name = val.split('::')[0];
        wb.updateData(dr, {'o_' + userId: name + "::" + notificationToken});
      }
    }
    try {
      await wb.commit();
      return true;
    } catch(ex) {
      return false;
    }
  }

  static void navigate(BuildContext context, bool newUser, User user) async {
    
    if (newUser) {
      navigateToCreateOrJoin(context, user);
    } else {
      bool propReg = await Utility.getPropertyRegistered();
      if (propReg == null) {
        propReg = await getAndSetIfPropertyRegistred(user.getUserId());
      }

      if (propReg) {
        navigateToHome(context, user);
      } else {
        navigateToCreateOrJoin(context, user);
      }
    }
  }

  static Future<bool> getAndSetIfPropertyRegistred(String userId) async {
    QuerySnapshot docs = await OwnerFlatDao.getAnOwnerFlatForUser(userId);
    bool propReg = docs.documents != null && docs.documents.length > 0;
    Utility.addToSharedPref(propertyRegistered: propReg);
    return propReg;
  }

  static navigateToHome(BuildContext context, User user) {
    //TODO: check if the get from sp in main clashes with the set in sp in onsuccess method in this file
    Navigator.popUntil(context, ModalRoute.withName('/'));
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return MyApp();
    }));
  }

  static navigateToCreateOrJoin(BuildContext context, User user) {
    Navigator.popUntil(context, ModalRoute.withName('/'));
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return MyApp();
    }));
  }
  
  static Future<String> getNotificationToken(String userId) async {

    FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
    firebaseMessaging.configure(onLaunch: (Map<String, dynamic> message) {
      debugPrint("lanuch called");
      //_notificationNavigate(message);
      return null;
    }, onMessage: (Map<String, dynamic> message) {
      debugPrint("message called ");
      //_notificationNavigate(message);
      return null;
    }, onResume: (Map<String, dynamic> message) async {
      //_notificationNavigate(message);
    });

    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(alert: true, badge: true, sound: true));

    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {
      print("IOS Setting resgistered");
    });

    try {
      return await firebaseMessaging.getToken();
    } catch (e) {
      return "";
    }
  }
}