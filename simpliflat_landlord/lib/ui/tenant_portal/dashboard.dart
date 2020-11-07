import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;
import 'package:simpliflat_landlord/model/owner.dart';
import 'package:simpliflat_landlord/model/owner_flat.dart';
import 'package:simpliflat_landlord/model/owner_tenant.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/ui/tasks/view_task.dart';
import 'package:simpliflat_landlord/common_widgets/common.dart';
import 'package:simpliflat_landlord/common_widgets/loading_container.dart';

class Dashboard extends StatefulWidget {
  final OwnerTenant flat;
  final User user;

  Dashboard(this.flat, this.user);

  @override
  State<StatefulWidget> createState() {
    return DashboardState(this.flat, this.user);
  }
}

class DashboardState extends State<Dashboard> {
  var _navigatorContext;
  final OwnerTenant flat;
  //bool noticesExist = false;
  bool tasksExist = false;
  List existingUsers;
  int usersCount;

  bool loadingState = false;


  var numToMonth = {
    1: 'Jan',
    2: 'Feb',
    3: 'Mar',
    4: 'Apr',
    5: 'May',
    6: 'Jun',
    7: 'Jul',
    8: 'Aug',
    9: 'Sep',
    10: 'Oct',
    11: 'Nov',
    12: 'Dec'
  };


  final User user;

  Map<String, String> flatIdNameMap = new Map();

  Map<String, Map> flatIdentifierData = new Map();

  var _progressCircleState = 0;

  var _isButtonDisabled = false;

  DashboardState(this.flat, this.user);

  @override
  void initState() {
    super.initState();
    debugPrint("in init");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _moveToLastScreen(context);
        return null;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Builder(builder: (BuildContext scaffoldC) {
          _navigatorContext = scaffoldC;
          return new SingleChildScrollView(
            child: Column(
              children: <Widget>[
                flatNameWidget(),

                getTasks(),
                

                getNotices(),
              ],
            ),
          );
        }),
      ),
    );
  }

  
  

  BoxDecoration getBlueGradientBackground() {
    return new BoxDecoration(
            color: Colors.teal
          );
  }

  Widget flatNameWidget() {

    return Card(
      elevation: 5.0,
      margin: EdgeInsets.only(left: 5.0, top: 10.0, right: 5.0),
      child: Container(
        decoration: getBlueGradientBackground(),
        
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(15.0),
        child: Text(
          this.flat.getOwnerFlat().getFlatName(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 25.0,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
    );
    //  });
  }


  // Get Tasks data for today
  Widget getTasks() {
    //DONE: need to change below

    DateTime now= new DateTime.now();
    Timestamp start = Timestamp.fromDate(DateTime(now.year, now.month, now.day));
    Timestamp end = Timestamp.fromDate(DateTime(now.year, now.month, now.day).add(new Duration(days: 1)));

    return 
           StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection(globals.ownerTenantFlat)
                  .document(this.flat.getOwnerTenantId())
                  .collection('tasks_landlord')
                  .where('nextDueDate', isGreaterThan: start)
                  .where('nextDueDate', isLessThan: end)
                  .where("completed", isEqualTo: false)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> taskSnapshot) {
                if (!taskSnapshot.hasData) return LoadingContainerVertical(3);

                /// TASK LIST VIEW
                var tooltipKey = new List();
                for (int i = 0; i < taskSnapshot.data.documents.length; i++) {
                  tooltipKey.add(GlobalKey());
                }
                if(taskSnapshot.data.documents.isEmpty)
                  return Container();

                return Container(
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          child: Card(
            elevation: 5.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Container(padding: EdgeInsets.only(top: 20.0,bottom:20.0,left:10.0),   decoration: getBlueGradientBackground(), child: Text('Tasks For You', style: TextStyle(color: Colors.white),)),
                  new ListView.builder(
                    itemCount: taskSnapshot.data.documents.length,
                    scrollDirection: Axis.vertical,
                    key: UniqueKey(),
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int position) {
                      var datetime = (taskSnapshot.data.documents[position]
                              ["nextDueDate"] as Timestamp)
                          .toDate();
                      final f = new DateFormat.jm();
                      var datetimeString = datetime.day.toString() +
                          " " +
                          numToMonth[datetime.month.toInt()] +
                          " " +
                          datetime.year.toString() +
                          " - " +
                          f.format(datetime);

                      if (taskSnapshot.data.documents.length > 0) {
                        tasksExist = true;
                      } else {
                        tasksExist = false;
                      }

                      return Padding(
                          padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.85,
                            child: ListTile(
                              title: CommonWidgets.textBox(
                                  taskSnapshot.data.documents[position]
                                      ["title"],
                                  15.0,
                                  color: Colors.black),
                              subtitle: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.access_time,
                                    color: Colors.indigo[700],
                                    size: 16,
                                  ),
                                  Container(
                                    width: 4.0,
                                  ),
                                  CommonWidgets.textBox(datetimeString, 11.0,
                                      color: Colors.black45),
                                ],
                              ),
                              onTap: () {
                                navigateToViewTask(
                                    taskId: taskSnapshot
                                        .data.documents[position].documentID);
                              },
                            ),
                          ));
                    },
                  ),
                ])));
              });
        
    // });
  }

  /// TODO: Change taskList code to store names along with user id in array. Then change this hardcoded values to show those.

  void navigateToViewTask({taskId}) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return ViewTask(taskId, this.flat, this.user);
      }),
    );
  }

  //DONE: need to change below
  // Get NoticeBoard data
  Widget getNotices() {
    DateTime now= new DateTime.now();
    Timestamp start = Timestamp.fromDate(DateTime(now.year, now.month, now.day));
    Timestamp end = Timestamp.fromDate(DateTime(now.year, now.month, now.day).add(new Duration(days: 1)));

    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection(globals.ownerTenantFlat)
          .document(this.flat.getOwnerTenantId())
          .collection(globals.messageBoard)
          .where('updated_at', isGreaterThan: start)
          .where('updated_at', isLessThan: end)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> notesSnapshot) {
        if (!notesSnapshot.hasData)
             return LoadingContainerVertical(3);

       

        if(notesSnapshot.data.documents.isEmpty)
          return Container();

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          child: Card(
            elevation: 5.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Container(padding: EdgeInsets.only(top: 20.0,bottom:20.0,left:10.0),    decoration: getBlueGradientBackground(), child: Text('Notices For You', style: TextStyle(color: Colors.white),)),
          ListView.separated(
            separatorBuilder: (context, builder) {return Divider(height: 1.0);},
              itemCount: notesSnapshot.data.documents.length,
              key: UniqueKey(),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int position) {
                return _buildNoticeListItem(
                    notesSnapshot.data.documents[position], position);
              }),
        ])));
      },
    );
  }

  Widget _buildNoticeListItem(DocumentSnapshot notice, index) {
    var datetime = (notice['updated_at'] as Timestamp).toDate();
    final f = new DateFormat.jm();
    var datetimeString = f.format(datetime);

    var userName = notice['user_name'] == null
        ? ""
        : notice['user_name'].toString().trim();

    var color = notice['user_id'].toString().trim().hashCode;

    String noticeTitle = notice['message'].toString().trim();
    if (noticeTitle.length > 100) {
      noticeTitle = noticeTitle.substring(0, 100) + "...";
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8.0, left: 8.0),
      child: SizedBox(
        child: ListTile(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                child: Text(userName,
                    style: TextStyle(
                      fontSize: 12.0,
                      fontFamily: 'Montserrat',
                      color:
                          Colors.primaries[color % Colors.primaries.length],
                    )),
                padding: EdgeInsets.only(bottom: 5.0),
              ),
              Text(noticeTitle,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontFamily: 'Montserrat',
                    color: Colors.black,
                  )),
            ],
          ),
          subtitle: Padding(
            child: Text(datetimeString,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 12.0,
                  fontFamily: 'Montserrat',
                  color: Colors.black45,
                )),
            padding: EdgeInsets.only(top: 6.0),
          ),
        ),
      ),
    );
  }

  Widget dateUI() {
    var numToWeekday = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday'
    };

    var now = DateTime.now().toLocal();
    String day = numToWeekday[now.weekday];
    String date = numToMonth[now.month.toInt()] + " " + now.day.toString();
    return Text(
      day + ", " + date,
      style: TextStyle(
        color: Colors.green,
        fontSize: 40.0,
        fontFamily: 'Satisfy',
      ),
    );
  }

  _moveToLastScreen(BuildContext _navigatorContext) {
    debugPrint("Back");
    Navigator.of(context).pop();
  }
}
