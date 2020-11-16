import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/dao/owner_dao.dart';
import 'package:simpliflat_landlord/icons/icons_custom_icons.dart';
import 'package:simpliflat_landlord/model/owner.dart';
import 'package:simpliflat_landlord/model/owner_flat.dart';
import 'package:simpliflat_landlord/model/owner_tenant.dart';
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
  OwnerTenant flat;


  LandlordPortal(this.flat);

  @override
  State<StatefulWidget> createState() {
    return _LandlordPortal(this.flat);
  }
}

class _LandlordPortal extends State<LandlordPortal> {
  int _selectedIndex = 0;

  //profile details
  OwnerTenant flat;


  String flatName = "Hey!";
  String userName = "";
  String userPhone = "";
  String userId;
  String _appBarTitle = "Simpliflat";
  List<String> titleList = ["Simpliflat", "Tasks", "Message Board", "Documents Manager", "Profile"];

  _LandlordPortal(this.flat);

  // Initialise Firestore notifications
  @override
  void initState() {
    super.initState();
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
          body: Center(
            child: _selectedIndex == 0
                ? Dashboard(this.flat, user)
                : (_selectedIndex == 1
                    ? TaskList(this.flat, user)
                    : (_selectedIndex == 2
                        ? DocumentManager(this.flat.getOwnerTenantId())
                        : ProfileOptions(user, this.flat)))
          ),
          bottomNavigationBar: new BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard), title: Text('Dashboard', style: TextStyle(fontFamily: 'Roboto',fontWeight: FontWeight.w700,),)),
              BottomNavigationBarItem(
                  icon: Icon(IconsCustom.date), title: Text('Tasks', style: TextStyle(fontFamily: 'Roboto',fontWeight: FontWeight.w700,),)),
              BottomNavigationBarItem(
                  icon: Icon(Icons.insert_drive_file),
                  title: Text('Documents', style: TextStyle(fontFamily: 'Roboto',fontWeight: FontWeight.w700,),)),
              BottomNavigationBarItem(
                  icon: Icon(IconsCustom.group_people),
                  title: Text('Profile', style: TextStyle(fontFamily: 'Roboto',fontWeight: FontWeight.w700,),)),
            ],
            currentIndex: _selectedIndex,
            unselectedItemColor: Color(0xff373D4C),
            backgroundColor: Colors.white,
            fixedColor: Color(0xff2079FF),
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: new FloatingActionButton(
            heroTag: "announce",
            onPressed: () async {
              
              navigateToNotice();
            },
            tooltip: 'Noticeboard',
            backgroundColor: Color(0xff2079FF),
            shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(8),
            ),
            child: new Icon(IconsCustom.announcement),
          ),
        ));
  }

  navigateToNotice() {
     User user = Provider.of<User>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return MessageBoard(this.flat.getOwnerTenantId());
      }),
    );
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

