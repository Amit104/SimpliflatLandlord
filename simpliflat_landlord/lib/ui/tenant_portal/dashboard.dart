import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/constants/colors.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;
import 'package:simpliflat_landlord/constants/strings.dart';
import 'package:simpliflat_landlord/model/message.dart';
import 'package:simpliflat_landlord/model/owner_tenant.dart';
import 'package:simpliflat_landlord/model/task.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/ui/tasks/view_task.dart';
import 'package:simpliflat_landlord/common_widgets/common.dart';
import 'package:simpliflat_landlord/common_widgets/loading_container.dart';
import 'package:simpliflat_landlord/view_model/dashboard_empty_check_model.dart';

class Dashboard extends StatelessWidget {

  final OwnerTenant flat;
  bool tasksExist = false;
  List existingUsers;
  int usersCount;

  bool loadingState = false;


  Map<int, String> numToMonth = {
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



  Dashboard(this.flat, this.user);


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _moveToLastScreen(context);
        return null;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('DashBoard', style: CommonWidgets.getAppBarTitleStyle(),),
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: Builder(builder: (BuildContext scaffoldC) {
          return new SingleChildScrollView(
            child: ChangeNotifierProvider(
                create: (_) => DashboardEmptyCheckModel(),
                key: GlobalKey(),
                builder: (dashboardContext, child) {
             return Column(
              children: <Widget>[
                flatNameWidget(context),
                SizedBox(height: 10),
                getTasks(context, dashboardContext),
                SizedBox(height: 10),
                getNotices(dashboardContext),
                Consumer<DashboardEmptyCheckModel>(builder: (BuildContext context,
                          DashboardEmptyCheckModel dashboardEmptyCheckModel, Widget child) {
                        return getEmptyImage(dashboardEmptyCheckModel);
                      }),
              ],
            );
                }));
        }),
      ),
    );
  }

  getEmptyImage(DashboardEmptyCheckModel dashboardEmptyCheckModel) {
    if (!dashboardEmptyCheckModel.noticesExist && !dashboardEmptyCheckModel.tasksExist) {
      return Center(
        child: Column(
          children: [
            Image.asset(
              'assets/images/dashboard-bg.PNG',
              fit: BoxFit.fill,
            ),
            Container(
              height: 10.0,
            ),
            Text(
              "You are all caught up for today!",
              style: TextStyle(
                fontSize: 18.0,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    }
    return Container();
  }

  
  

  BoxDecoration getBlueGradientBackground() {
    return new BoxDecoration(
            color: AppColors.PRIMARY_COLOR
          );
  }

  Widget flatNameWidget(BuildContext context) {

    return Container(
                                    color: AppColors.PRIMARY_COLOR,
                                                                      child: ListTile(
                                                                        contentPadding: EdgeInsets.only(top: 15, bottom: 15, left: 15, right: 15.0),
                                      
                                      title: Text(this.flat.getOwnerFlat().getFlatName(), style: CommonWidgets.getTextStyleBold(size: 20, color: Colors.white)),
                                    ),
                                  );

    /*return Card(
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
    );*/
    //  });
  }


  Widget getTasks(BuildContext context, BuildContext dbCxt) {

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
                debugPrint("after fetching");

                List<Task> tasks = taskSnapshot.data.documents.map((DocumentSnapshot doc) => Task.fromJson(doc.data, doc.documentID)).toList();

                /// TASK LIST VIEW
                List<GlobalKey> tooltipKey = new List();
                for (int i = 0; i < taskSnapshot.data.documents.length; i++) {
                  tooltipKey.add(GlobalKey());
                }

                WidgetsBinding.instance.addPostFrameCallback((_){
                              if (taskSnapshot.data.documents.length > 0) {
                                Provider.of<DashboardEmptyCheckModel>(dbCxt, listen: false).tasksChange(true);
                              } else {
                                Provider.of<DashboardEmptyCheckModel>(dbCxt, listen: false).tasksChange(false);
                              }
                            });
                if(tasks.isEmpty)
                  return Container();

                return Container(
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          child: Card(
            elevation: 5.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Container(padding: EdgeInsets.only(top: 20.0,bottom:20.0,left:10.0),   decoration: getBlueGradientBackground(), child: Text('Tasks For You', style: CommonWidgets.getTextStyleBold(color: Colors.white, size: 12.0),)),
                  new ListView.builder(
                    itemCount: tasks.length,
                    scrollDirection: Axis.vertical,
                    key: UniqueKey(),
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int position) {
                      Task task = tasks[position];
                      DateTime datetime = task.getNextDueDate().toDate();
                      final DateFormat f = new DateFormat.jm();
                      String datetimeString = datetime.day.toString() +
                          " " +
                          numToMonth[datetime.month.toInt()] +
                          " " +
                          datetime.year.toString() +
                          " - " +
                          f.format(datetime);

                      if (tasks.length > 0) {
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
                                  task.getTitle(),
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
                                navigateToViewTask(context,
                                    taskId: task.getTaskId());
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

  void navigateToViewTask(BuildContext context, {taskId}) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return ViewTask(taskId, this.flat, this.user);
      }),
    );
  }

  //DONE: need to change below
  // Get NoticeBoard data
  Widget getNotices(BuildContext dbCxt) {
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

        List<Message> notices = notesSnapshot.data.documents.map((DocumentSnapshot doc) => Message.fromJson(doc.data, doc.documentID)).toList();

        if(notices.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_){
            Provider.of<DashboardEmptyCheckModel>(dbCxt, listen: false).noticesChange(false);
          });
        }
        else {
          WidgetsBinding.instance.addPostFrameCallback((_){
          Provider.of<DashboardEmptyCheckModel>(dbCxt, listen: false).noticesChange(true);
        });
        }
        if(notices.isEmpty)
          return Container();

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          child: Card(
            elevation: 5.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Container(padding: EdgeInsets.only(top: 20.0,bottom:20.0,left:10.0),    decoration: getBlueGradientBackground(), child: Text('Notices For You', style: CommonWidgets.getTextStyleBold(size: 12, color: Colors.white),)),
          ListView.separated(
            separatorBuilder: (context, builder) {return Divider(height: 1.0);},
              itemCount: notices.length,
              key: UniqueKey(),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int position) {
                return _buildNoticeListItem(
                    notices[position], position);
              }),
        ])));
      },
    );
  }

  Widget _buildNoticeListItem(Message notice, index) {
    DateTime datetime = notice.getUpdatedAt().toDate();
    final DateFormat f = new DateFormat.jm();
    String datetimeString = f.format(datetime);

    String userName = notice.getCreatedByUserName()== null
        ? ""
        : notice.getCreatedByUserName().trim();

    int color = notice.getCreatedByUserId().trim().hashCode;

    String noticeTitle = notice.getMessage().trim();
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
    Map<int, String> numToWeekday = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday'
    };

    DateTime now = DateTime.now().toLocal();
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

  _moveToLastScreen(BuildContext context) {
    debugPrint("Back");
    Navigator.of(context).pop();
  }
}
