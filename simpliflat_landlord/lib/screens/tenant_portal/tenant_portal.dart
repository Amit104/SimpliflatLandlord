import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:simpliflat_landlord/icons/icons_custom_icons.dart';
import 'package:simpliflat_landlord/screens/profile/profile_options.dart';
import '../dashboard.dart';
import '../utility.dart';
import 'document_manager.dart';
import 'message_board.dart';
import 'package:simpliflat_landlord/screens/globals.dart' as globals;

class LandlordPortal extends StatefulWidget {
  final flatId;

  LandlordPortal(this.flatId);

  @override
  State<StatefulWidget> createState() {
    return _LandlordPortal(this.flatId);
  }
}

class _LandlordPortal extends State<LandlordPortal> {
  int _selectedIndex = 0;

  //profile details
  final flatId;
  String flatName = "Hey!";
  String displayId = "";
  String userName = "";
  String userPhone = "";
  var userId;
  String _appBarTitle = "Simpliflat";
  var titleList = ["Simpliflat", "Message Board", "Documents Manager"];

  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  _LandlordPortal(this.flatId);

  // Initialise Firestore notifications
  @override
  void initState() {
    super.initState();
    var notificationToken;
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

    // notification token check.
    Utility.getToken().then((token) {
      if (token == null || token == "") {
        firebaseMessaging.getToken().then((token) async {
          debugPrint("TOKEN = " + token);
          notificationToken = token;
          if (token == null) {
          } else {
            var userId = await Utility.getUserId();
            Firestore.instance
                .collection(globals.landlord)
                .document(userId)
                .updateData({'notification_token': notificationToken}).then(
                    (updated) {
                  Utility.addToSharedPref(notificationToken: notificationToken);
                });
          }
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    _updateUserDetails();
    fetchFlatName(context);
    return WillPopScope(
        onWillPop: () {
          moveToLastScreen(context);
          return null;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              _appBarTitle,
              style: TextStyle(color: Colors.indigo[900]),
            ),
            elevation: 0.0,
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.person, color: Colors.red,),
                onPressed: () {
                  navigateToProfileOptions();
                },
              ),
            ],
          ),
          body: Center(
            child: _selectedIndex == 0
                ? Dashboard(flatId)
                : (_selectedIndex == 1
                    ? MessageBoard(flatId)
                    : DocumentManager(flatId)),
          ),
          bottomNavigationBar: new BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(IconsCustom.tasks_1), title: Text('Tasks')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.message), title: Text('Messages')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.insert_drive_file), title: Text('Documents')),
            ],
            currentIndex: _selectedIndex,
            unselectedItemColor: Colors.indigo[900],
            fixedColor: Colors.red[900],
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
          ),
        ));
  }

  // Navigation for bottom navigation buttons
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _appBarTitle = titleList[index];
    });
  }


  //update user info if missing in shared preferences
  void _updateUserDetails() async {
    var _userId = await Utility.getUserId();
    var _userName = await Utility.getUserName();
    var _userPhone = await Utility.getUserPhone();
    if (_userName == null ||
        _userName == "" ||
        _userPhone == null ||
        _userPhone == "") {
      Firestore.instance.collection(globals.landlord).document(_userId).get().then(
              (snapshot) {
            if (snapshot.exists) {
              if(mounted)
                setState(() {
                  userName = snapshot.data['name'];
                  userPhone = snapshot.data['phone'];
                });
              Utility.addToSharedPref(userName: userName);
              Utility.addToSharedPref(userPhone: userPhone);
            }
          }, onError: (e) {});
    } else {
      userName = await Utility.getUserName();
      userPhone = await Utility.getUserPhone();
    }
  }

  // update flat info if missing in shared preferences
  void fetchFlatName(context) async {
    Utility.getFlatName().then((name) {
      if (flatName == null ||
          flatName == "" ||
          displayId == "" ||
          displayId == null) {
        Firestore.instance
            .collection(globals.flat)
            .document(flatId)
            .get()
            .then((flat) {
          if (flat != null) {
            Utility.addToSharedPref(flatName: flat['name'].toString());
            Utility.addToSharedPref(displayId: flat['display_id'].toString());
            if(mounted)
              setState(() {
                displayId = flat['display_id'].toString();
                flatName = flat['name'].toString().trim();
                if (flatName == null || flatName == "") flatName = "Hey!";
              });
          }
        });
      }
      if (name != null) {
        if(mounted)
          setState(() {
            flatName = name;
          });
      } else {
        if(mounted)
          setState(() {
            flatName = "Hey there!";
          });
      }
    });
  }

  void navigateToProfileOptions() async {
    Map result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ProfileOptions(userName, userPhone, flatName, displayId, flatId)),
    );
  }

  moveToLastScreen(_navigatorContext) {
    Navigator.pop(_navigatorContext, true);
  }
}
