import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/screens/globals.dart' as globals;
import 'package:simpliflat_landlord/screens/start_navigation.dart';
import 'dart:async';
import 'package:simpliflat_landlord/screens/utility.dart';

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
    var userId;
    var flatId;
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      Timer(Duration(milliseconds: 2000), () async {
        //check shared prefs for user and flat existence
        userId = sp.get(globals.userId);
        flatId = sp.get(globals.flatIdDefault);
        if (userId != null) userId = userId.toString();
        if (flatId != null) flatId = flatId;

        // check for new flats and any removed flats
        var flatList = await Utility.getFlatIdList();
        var newList = new List();
        if (flatList == null) {
          flatList = new List();
        }

        Firestore.instance
            .collection(globals.landlord)
            .document(userId)
            .get()
            .then((snapshot) {
          if (snapshot.exists) {
            var newFlatIdList = snapshot.data['flat'];
            if (newFlatIdList != null) {
              for (var newId in newFlatIdList) {
                var name = '';
                for (var id in flatList) {
                  if (id.contains(newId) && id.contains("Name=")) {
                    name = id.split("Name=")[1];
                  }
                }
                if (name != '') {
                  newList.add(newId + "Name=" + name);
                } else {
                  newList.add(newId);
                }
              }
              Utility.addToSharedPref(flatIdList: newList);
              flatList = newList;
            }
          }
        }, onError: (e) {});

        // START: check if all the flats have names present. if not update them.

        var defaultFlatName = await Utility.getFlatName();
        List toUpdateFlatRefs = new List();
        if (flatList != null) {
          for (String id in flatList) {
            debugPrint(id);
            if (id.contains("Name=")) continue;
            toUpdateFlatRefs.add(FlatIncomingReq(
                Firestore.instance.collection(globals.flat).document(id), id));
          }
        }

        Map<String, String> flatIdName = new Map();

        Firestore.instance.runTransaction((transaction) async {
          for (int i = 0; i < toUpdateFlatRefs.length; i++) {
            DocumentSnapshot flatData =
                await transaction.get(toUpdateFlatRefs[i].ref);
            if (flatData.exists)
              flatIdName[toUpdateFlatRefs[i].displayId] = flatData.data['name'];
          }
        }).whenComplete(() {
          debugPrint("IN WHEN COMPLETE TRANSACTION");
          List updatedFlatList = new List();
          for (String id in flatList) {
            if (id == flatId) {
              if (defaultFlatName == null || defaultFlatName == "") {
                if (id.contains("Name=")) {
                  Utility.addToSharedPref(flatName: id.split("Name=")[1]);
                } else if (flatIdName.containsKey(id)) {
                  Utility.addToSharedPref(flatName: flatIdName[id]);
                }
              }
            }
            if (id.contains("Name="))
              updatedFlatList.add(id);
            else {
              if (flatIdName.containsKey(id))
                updatedFlatList.add(id + "Name=" + flatIdName[id]);
              else
                updatedFlatList.add(id);
            }
          }
          Utility.addToSharedPref(flatIdList: updatedFlatList);
        });
        // END: check if all the flats have names present. if not update them.

        userId == null
            ? debugPrint("User Id is null")
            : debugPrint("User Id is = " + userId);
        flatId == null
            ? debugPrint("Flat Id is null")
            : debugPrint("Flat Id is = " + flatId);

        if (userId == null)
          _navigate(_navigatorContext, 1);
        else if (flatId == null || flatId == "null" || flatId == "") {
          debugPrint("IN FLAT NULL");

          Firestore.instance
              .collection(globals.requests)
              .where("user_id", isEqualTo: userId)
              .getDocuments()
              .then((requests) {
            debugPrint("AFTER JOIN REQ");
            if (requests.documents != null && requests.documents.length != 0) {
              bool userRequested = false;
              String statusForUserReq = "";
              List<String> incomingRequests = new List<String>();

              List<FlatIncomingReq> flatIdGetDisplay = new List();
              requests.documents.sort((a, b) =>
                  a.data['updated_at'].compareTo(b.data['updated_at']) > 0
                      ? 1
                      : -1);
              for (int i = 0; i < requests.documents.length; i++) {
                debugPrint("doc + " + requests.documents[i].documentID);
                var data = requests.documents[i].data;
                var reqFlatId = data['flat_id'];
                var reqStatus = data['status'];
                var reqFromFlat = data['request_from_flat'];

                if (reqFromFlat.toString() == "0") {
                  userRequested = true;
                  statusForUserReq = reqStatus.toString();
                  flatId = reqFlatId;
                } else {
                  // case where flat made a request to add user
                  // show all these flats to user on next screen - Create or join
                  debugPrint(reqFlatId);
                  if (reqStatus.toString() == "0")
                    flatIdGetDisplay.add(FlatIncomingReq(
                        Firestore.instance
                            .collection(globals.flat)
                            .document(reqFlatId),
                        ''));
                }
              }

              //get Display IDs for flats with incoming requests
              Firestore.instance.runTransaction((transaction) async {
                for (int i = 0; i < flatIdGetDisplay.length; i++) {
                  DocumentSnapshot flatData =
                      await transaction.get(flatIdGetDisplay[i].ref);
                  if (flatData.exists) {
                    flatIdGetDisplay[i].displayId = flatData.data['display_id'];
                    flatIdentifierData[flatData.data['display_id']] = {
                      'apartment_name': flatData.data['apartment_name'],
                      'apartment_number': flatData.data['apartment_number'],
                      'zipcode': flatData.data['zipcode']
                    };
                  }
                }
              }).whenComplete(() {
                debugPrint("IN WHEN COMPLETE TRANSACTION");
                for (int i = 0; i < flatIdGetDisplay.length; i++) {
                  incomingRequests.add(flatIdGetDisplay[i].displayId);
                }
                debugPrint("IN NAVIGATE");
                debugPrint(incomingRequests.length.toString());
                if (userRequested) {
                  userId = userId.toString();
                  if (statusForUserReq == "1") {
                    //this should never run as flat field in landlord collection will be updated if request is accepted by tenant
                    List flatList = new List();
                    flatList.add(flatId);
                    Utility.addToSharedPref(
                        flatIdList: flatList, flatIdDefault: flatId[0]);
                    _navigate(_navigatorContext, 3, flatId: flatId, userId: userId);
                  } else if (statusForUserReq == "-1") {
                    _navigate(_navigatorContext, 2,
                        requestDenied: -1, incomingRequests: incomingRequests, userId: userId);
                  } else {
                    _navigate(_navigatorContext, 2,
                        requestDenied: 0, incomingRequests: incomingRequests, userId: userId);
                  }
                } else {
                  _navigate(_navigatorContext, 2,
                      requestDenied: 2, incomingRequests: incomingRequests, userId: userId);
                }
              }).catchError((e) {
                debugPrint("SERVER TRANSACTION ERROR");
                Utility.createErrorSnackBar(_navigatorContext);
              });
            } else {
              debugPrint("IN ELSE FLAT NULL");
              _navigate(_navigatorContext, 2, requestDenied: 2, userId: userId);
            }
          }, onError: (e) {
            debugPrint("CALL ERROR");
            Utility.createErrorSnackBar(_navigatorContext);
          }).catchError((e) {
            debugPrint("SERVER ERROR");
            debugPrint(e.toString());
            Utility.createErrorSnackBar(_navigatorContext);
          });
        } else {
          debugPrint("IN ELSE");
          _navigate(_navigatorContext, 3, flatId: flatId, userId: userId);
        }
      });
    });
  }

  // flag indicate -
  // 1 : User is new - SignUp()
  // 2 : CreateOrJoin() page with request status
  // 3 : LandlordPortal()
  void _navigate(context, flag,
      {flatId, requestDenied = 2, List<String> incomingRequests, userId}) {
    debugPrint("Flag for navigation is " + flag.toString());
    Navigator.pushReplacement(
      _navigatorContext,
      new MaterialPageRoute(builder: (context) {
        return StartNavigation(
            flag, requestDenied, incomingRequests, flatId, flatIdentifierData, userId);
      }),
    );
  }

  void moveToLastScreen() {
    debugPrint("EXIT");
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}
