import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/screens/globals.dart' as globals;
import 'package:simpliflat_landlord/screens/start_navigation.dart';
import 'dart:async';
import 'package:simpliflat_landlord/screens/utility.dart';
import 'package:simpliflat_landlord/screens/models/Owner.dart';

class FlatIncomingReq {
  DocumentReference ref;
  String displayId;

  FlatIncomingReq(this.ref, this.displayId);

  DocumentReference get docRef {
    return ref;
  }

  set docRef(dRef) {
    ref = dRef;
  }

  String get displayIdFlat {
    return displayId;
  }

  set displayIdFlat(display) {
    displayId = display;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatelessWidget {
  var _navigatorContext;
  Map<String, Map> flatIdentifierData = new Map();

  @override
  Widget build(BuildContext context) {
    _checkPrefsAndNavigate();

    //splash screen code
    return MaterialApp(
      title: 'SimpliFlat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.white,
        accentColor: Colors.indigo[900],
        fontFamily: 'Montserrat',
      ),
      home: WillPopScope(onWillPop: () {
        moveToLastScreen();
        return null;
      }, child: Scaffold(body: Builder(builder: (BuildContext contextScaffold) {
        _navigatorContext = contextScaffold;
        return Stack(fit: StackFit.expand, children: <Widget>[
          new DecoratedBox(
            decoration: new BoxDecoration(color: Colors.white),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                  flex: 2,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircleAvatar(
                            backgroundColor: Colors.indigo[900],
                            radius: 50.0,
                            child: Icon(Icons.home,
                                color: Colors.white, size: 50.0)),
                        Padding(
                          padding: EdgeInsets.only(top: 10.0),
                        ),
                        Text(
                          "SIMPLIFLAT LANDLORD",
                          style: TextStyle(
                            color: Colors.indigo[900],
                            fontSize: 21.0,
                            fontFamily: 'Montserrat',
                          ),
                        )
                      ],
                    ),
                  )),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.indigo[900]),
                    ),
                  ],
                ),
              )
            ],
          )
        ]);
      }))),
    );
  }

  void _checkPrefsAndNavigate() {
    String userId;
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      Timer(Duration(milliseconds: 2000), () async {
        //check shared prefs for user and flat existence
        userId = sp.get(globals.userId);

        if (userId == null)
          _navigate(_navigatorContext, 1);
        else {
          _navigate(_navigatorContext, 2, userId: userId);
        }
      });
    });
  }

  // flag indicate -
  // 1 : User is new - SignUp()
  // 2 : Home() page with request status
  void _navigate(context, flag,
      {flatId,
      requestDenied = 2,
      List<String> incomingRequests,
      userId}) async {
    Owner user = new Owner();
    if (flag == 2) {
      String _userPhone = await Utility.getUserPhone();
      String _userName = await Utility.getUserName();
      if (_userName == null ||
          _userName == "" ||
          _userPhone == null ||
          _userPhone == "") {
        DocumentSnapshot userDoc = await Firestore.instance
            .collection(globals.landlord)
            .document(userId)
            .get();

        if (userDoc.exists) {
          _userName = userDoc.data['name'];
          _userPhone = userDoc.data['phone'];
          Utility.addToSharedPref(userName: _userName);
          Utility.addToSharedPref(userPhone: _userPhone);
        }
      }

      user.setName(_userName);
      user.setPhone(_userPhone);
      user.setOwnerId(userId);
    }
    debugPrint("Flag for navigation is " + flag.toString());
    Navigator.pushReplacement(
      _navigatorContext,
      new MaterialPageRoute(builder: (context) {
        return StartNavigation(flag, requestDenied, incomingRequests, flatId,
            flatIdentifierData, user);
      }),
    );
  }

  void moveToLastScreen() {
    debugPrint("EXIT");
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}
