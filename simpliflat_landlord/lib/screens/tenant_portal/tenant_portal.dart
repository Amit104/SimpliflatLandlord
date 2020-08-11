import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:simpliflat_landlord/icons/icons_custom_icons.dart';
import 'package:simpliflat_landlord/screens/profile/profile_options.dart';
import 'package:simpliflat_landlord/screens/tasks/task_list.dart';
import '../../main.dart';
import '../dashboard.dart';
import '../utility.dart';
import 'add_flat.dart';
import 'document_manager.dart';
import 'message_board.dart';
import 'package:simpliflat_landlord/screens/globals.dart' as globals;
import 'package:flutter/cupertino.dart';
import 'package:simpliflat_landlord/screens/tasks/create_task.dart';

class LandlordPortal extends StatefulWidget {
  var flatId;

  LandlordPortal(flatId) {
    this.flatId = flatId;
  }

  @override
  State<StatefulWidget> createState() {
    return _LandlordPortal(this.flatId);
  }
}

class _LandlordPortal extends State<LandlordPortal> {
  int _selectedIndex = 0;

  //profile details
  var flatId;
  String flatName = "Hey!";
  String userName = "";
  String userPhone = "";
  var userId;
  String _appBarTitle = "Simpliflat";
  var titleList = ["Simpliflat", "Tasks", "Message Board", "Documents Manager"];

  String landlordId;

  String landlordName;

  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  _LandlordPortal(flatId) {
    this.flatId = flatId;
  }

  // Initialise Firestore notifications
  @override
  void initState() {
    super.initState();
    Utility.getFlatIdDefault().then((flat) {
      if (flat != null) flatId = flat;
    });
    _updateUserDetails();
    fetchFlatName(context);
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
          drawer: getDrawer(),
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              _appBarTitle,
              style: TextStyle(color: Colors.indigo[900]),
            ),
            elevation: 0.0,
            centerTitle: true,
            /*leading: IconButton(
              icon: Icon(
                Icons.group,
                color: Colors.indigo,
              ),
              onPressed: () {
                changeDefaultFlat();
              },
            ),
            actions: <Widget>[
              _selectedIndex == 1
                  ? IconButton(
                      icon: Icon(Icons.add_circle),
                      onPressed: () {
                        openActionMenu();
                      })
                  : Container(),
              IconButton(
                icon: Icon(
                  Icons.person,
                  color: Colors.indigo,
                ),
                onPressed: () {
                  navigateToProfileOptions();
                },
              ),
            ],*/
          ),
          body: Center(
            child: _selectedIndex == 0
                ? Dashboard(flatId)
                : (_selectedIndex == 1
                    ? getTasksListScreen()
                    : (_selectedIndex == 2
                        ? MessageBoard(flatId)
                        : DocumentManager(flatId))),
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
    if (landlordId == null || landlordName == null) {
      return Container(
        child: CircularProgressIndicator(),
      );
    }
    debugPrint("passing landlordName = " + landlordName);
    return TaskList(flatId, landlordId, landlordName);
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


  Widget getDrawer() {
    return Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Container(),
              decoration: BoxDecoration(
                color: Colors.blue[100],
              ),
            ),
            ListTile(
              title: Text('My buildings'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Profile'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ));
  }

  void navigateToAddTask(String typeOfTask, {taskId}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return CreateTask(taskId, flatId, typeOfTask, landlordId, landlordName);
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

  //update user info if missing in shared preferences
  void _updateUserDetails() async {
    var _userId = await Utility.getUserId();

    var _userName = await Utility.getUserName();
    var _userPhone = await Utility.getUserPhone();
    if (_userName == null ||
        _userName == "" ||
        _userPhone == null ||
        _userPhone == "") {
      Firestore.instance
          .collection(globals.landlord)
          .document(_userId)
          .get()
          .then((snapshot) {
        if (snapshot.exists) {
          debugPrint("in if = " + snapshot.data['name']);
          if (mounted) {
            setState(() {
              userName = snapshot.data['name'];
              userPhone = snapshot.data['phone'];
              landlordName = userName;
            });
          }
          Utility.addToSharedPref(userName: userName);
          Utility.addToSharedPref(userPhone: userPhone);
        }
      }, onError: (e) {});
    } else {
      debugPrint("in else = " + _userName);
      userName = _userName;
      userPhone = _userPhone;
    }
    if (mounted) {
      if (_userName == null || _userName == '') {
        setState(() {
          landlordId = _userId;
        });
      } else {
        setState(() {
          landlordName = _userName;
          landlordId = _userId;
        });
      }
    }
  }

  // update flat info if missing in shared preferences
  // TODO update name of flats stored in landlord table
  void fetchFlatName(context) async {
    Utility.getFlatName().then((name) {
      if (flatName == null || flatName == "") {
        Firestore.instance
            .collection(globals.flat)
            .document(flatId)
            .get()
            .then((flat) {
          if (flat != null) {
            Utility.addToSharedPref(flatName: flat['name'].toString());
            if (mounted)
              setState(() {
                flatName = flat['name'].toString().trim();
                if (flatName == null || flatName == "") flatName = "Hey!";
              });
          }
        });
      }
      if (name != null) {
        if (mounted)
          setState(() {
            flatName = name;
          });
      } else {
        if (mounted)
          setState(() {
            flatName = "Hey there!";
          });
      }
    });
  }

  void navigateToProfileOptions() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ProfileOptions(userName, userPhone, flatName, flatId)),
    );
  }

  moveToLastScreen(_navigatorContext) {
    Navigator.pop(_navigatorContext, true);
  }

  void changeDefaultFlat() async {
    List flatList = await Utility.getFlatIdList();
    bool sanityCheck = await checkSanityOfNames(flatList);
    for (String id in flatList) {
      debugPrint(id);
      if (!id.contains("Name=")) sanityCheck = false;
    }
    if (sanityCheck)
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return FilterSheet(this.filterChange, flatList, flatId);
        },
      );
    else
      Utility.createErrorSnackBar(context,
          error:
              "Something went wrong! Please turn on internet or restart the app.");
  }

  void filterChange(String flat, String name) {
    if (flat != null && flat != "") {
      setState(() {
        Utility.addToSharedPref(
            flatIdDefault: flat, flatName: name.toString().trim());
        flatId = flat;
        flatName = name;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return LandlordPortal(flatId);
        }),
      );
    }
  }

  Future<bool> checkSanityOfNames(List flatList) async {
    var updated = true;

    if (flatList == null) {
      flatList = new List();
    }

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
            updated = false;
        }
      }
      if (updated) Utility.addToSharedPref(flatIdList: updatedFlatList);
    });
    return updated;
  }
}

class FilterSheet extends StatefulWidget {
  Function callback;
  final flatList;
  final defaultFlat;

  FilterSheet(this.callback, this.flatList, this.defaultFlat);

  @override
  State<StatefulWidget> createState() {
    return new _FilterSheet(this.flatList, this.defaultFlat);
  }
}

class _FilterSheet extends State<FilterSheet> {
  final flatList, defaultFlat;

  _FilterSheet(this.flatList, this.defaultFlat);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 30.0),
                child: Text(
                  "Select Flat",
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: IconButton(
                icon: Icon(
                  Icons.add,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return AddFlat(defaultFlat);
                    }),
                  );
                },
              ),
            )
          ],
        ),
        ListView.builder(
          itemCount: flatList.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                flatList[index].split("Name=")[1] != null
                    ? flatList[index].split("Name=")[1]
                    : "PlaceholderFlatName",
                style: defaultFlat == flatList[index].split("Name=")[0]
                    ? TextStyle(color: Colors.redAccent)
                    : TextStyle(color: Colors.black),
              ),
              leading: Icon(
                Icons.arrow_right,
                color: defaultFlat == flatList[index].split("Name=")[0]
                    ? Colors.redAccent
                    : Colors.black,
              ),
              onTap: () {
                Navigator.of(context).pop();
                this.widget.callback(
                    flatList[index].split("Name=")[0],
                    flatList[index].split("Name=")[1] != null
                        ? flatList[index].split("Name=")[1]
                        : "PlaceholderFlatName");
              },
            );
          },
        ),
      ],
    );
  }
}
