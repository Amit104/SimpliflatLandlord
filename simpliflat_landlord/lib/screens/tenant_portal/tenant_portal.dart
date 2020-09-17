import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:simpliflat_landlord/icons/icons_custom_icons.dart';
import 'package:simpliflat_landlord/screens/models/Owner.dart';
import 'package:simpliflat_landlord/screens/models/OwnerFlat.dart';
import 'package:simpliflat_landlord/screens/profile/profile_options.dart';
import 'package:simpliflat_landlord/screens/tasks/task_list.dart';
import '../dashboard.dart';
import '../utility.dart';
import 'document_manager.dart';
import 'message_board.dart';
import 'package:simpliflat_landlord/screens/globals.dart' as globals;
import 'package:flutter/cupertino.dart';
import 'package:simpliflat_landlord/screens/tasks/create_task.dart';

class LandlordPortal extends StatefulWidget {
  OwnerFlat flat;

  final Owner owner;

  LandlordPortal(this.flat, this.owner);

  @override
  State<StatefulWidget> createState() {
    return _LandlordPortal(this.flat, this.owner);
  }
}

class _LandlordPortal extends State<LandlordPortal> {
  int _selectedIndex = 0;

  //profile details
  OwnerFlat flat;

  final Owner owner;

  String flatName = "Hey!";
  String userName = "";
  String userPhone = "";
  var userId;
  String _appBarTitle = "Simpliflat";
  var titleList = ["Simpliflat", "Tasks", "Message Board", "Documents Manager", "Profile"];


  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  _LandlordPortal(this.flat, this.owner);

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
    try {
      Utility.getToken().then((token) {
        if (token == null || token == "") {
          firebaseMessaging.getToken().then((token) async {
            try {
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
            } catch (e) {
              debugPrint("exception handled 1");
            }
          });
        }
      });
    } catch (e) {
      debugPrint("exception handled 2");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          moveToLastScreen(context);
          return null;
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              _appBarTitle,
              style: TextStyle(color: Colors.indigo[900]),
            ),
            actions: <Widget>[_selectedIndex == 1?IconButton(icon: Icon(Icons.add), onPressed: () {openActionMenu();},):SizedBox()],
            elevation: 0.0,
            centerTitle: true,
            
          ),
          body: Center(
            child: _selectedIndex == 0
                ? Dashboard(this.flat, this.owner)
                : (_selectedIndex == 1
                    ? getTasksListScreen()
                    : (_selectedIndex == 2
                        ? MessageBoard(this.flat.getApartmentTenantId())
                        : (_selectedIndex == 3
                        ? DocumentManager(this.flat.getApartmentTenantId())
                        : ProfileOptions(this.owner, this.flat))))
          ),
          bottomNavigationBar: new BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard), title: Text('Dashboard')),
              BottomNavigationBarItem(
                  icon: Icon(IconsCustom.tasks_1), title: Text('Tasks')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.message), title: Text('Messages')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.insert_drive_file),
                  title: Text('Documents')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  title: Text('Profile')),
            ],
            currentIndex: _selectedIndex,
            unselectedItemColor: Colors.indigo[900],
            fixedColor: Colors.red[900],
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
          ),
        ));
  }

  Widget getTasksListScreen() {
    return TaskList(this.flat, this.owner);
  }

  void openActionMenu() {
    final action = CupertinoActionSheet(
      title: Text(
        "Tasks",
        style: TextStyle(fontSize: 30),
      ),
      message: Text(
        "Select the type of task to be created",
        style: TextStyle(fontSize: 15.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text("Reminder"),
          onPressed: () {
            Navigator.pop(context);
            navigateToAddTask('Reminder');
          },
        ),
        CupertinoActionSheetAction(
          child: Text("Complaint"),
          onPressed: () {
            Navigator.pop(context);
            navigateToAddTask('Complaint');
          },
        ),
        CupertinoActionSheetAction(
          child: Text("Payment"),
          onPressed: () {
            Navigator.pop(context);
            navigateToAddTask('Payment');
          },
        )
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text("Cancel"),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }


  

  void navigateToAddTask(String typeOfTask, {taskId}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return CreateTask(taskId, this.flat, typeOfTask, this.owner);
      }),
    );
  }

  // Navigation for bottom navigation buttons
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _appBarTitle = titleList[index];
    });
  }

  moveToLastScreen(_navigatorContext) {
    Navigator.pop(_navigatorContext, true);
  }
}

