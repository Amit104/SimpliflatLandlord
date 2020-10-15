import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/dao/owner_dao.dart';
import 'package:simpliflat_landlord/icons/icons_custom_icons.dart';
import 'package:simpliflat_landlord/model/owner.dart';
import 'package:simpliflat_landlord/model/owner_flat.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/ui/profile/profile_options.dart';
import 'package:simpliflat_landlord/ui/tasks/task_list.dart';
import 'package:simpliflat_landlord/ui/tenant_portal/dashboard.dart';
import 'package:simpliflat_landlord/utility/utility.dart';
import 'document_manager.dart';
import 'message_board.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;
import 'package:flutter/cupertino.dart';
import 'package:simpliflat_landlord/ui/tasks/create_task.dart';

class LandlordPortal extends StatefulWidget {
  OwnerFlat flat;


  LandlordPortal(this.flat);

  @override
  State<StatefulWidget> createState() {
    return _LandlordPortal(this.flat);
  }
}

class _LandlordPortal extends State<LandlordPortal> {
  int _selectedIndex = 0;

  //profile details
  OwnerFlat flat;


  String flatName = "Hey!";
  String userName = "";
  String userPhone = "";
  var userId;
  String _appBarTitle = "Simpliflat";
  var titleList = ["Simpliflat", "Tasks", "Message Board", "Documents Manager", "Profile"];


  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  _LandlordPortal(this.flat);

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
                bool ifSuccess = await OwnerDao.update(userId, Owner.toUpdateJson(notificationToken: notificationToken));
                if(ifSuccess) {
                  Utility.addToSharedPref(notificationToken: notificationToken);
                }
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
    User user = Provider.of<User>(context, listen: false);
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
                ? Dashboard(this.flat, user)
                : (_selectedIndex == 1
                    ? TaskList(this.flat, user)
                    : (_selectedIndex == 2
                        ? MessageBoard(this.flat.getApartmentTenantId())
                        : (_selectedIndex == 3
                        ? DocumentManager(this.flat.getApartmentTenantId())
                        : ProfileOptions(user, this.flat))))
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
    User user = Provider.of<User>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return CreateTask(taskId, this.flat, typeOfTask, user);
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

