import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:simpliflat_landlord/screens/globals.dart' as globals;
import 'package:simpliflat_landlord/screens/tasks/view_task.dart';
import 'package:simpliflat_landlord/screens/widgets/common.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utility.dart';
import 'create_task.dart';
import 'package:flutter/foundation.dart';
import 'package:simpliflat_landlord/screens/widgets/loading_container.dart';
import 'package:simpliflat_landlord/screens/Res/strings.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';

typedef TaskItemBodyBuilder<T> = Widget Function(TaskItem<T> item);
typedef ValueToString<T> = String Function(T value);

class DualHeaderWithHint extends StatelessWidget {
  const DualHeaderWithHint({this.name, this.value, this.hint, this.showHint});

  final String name;
  final String value;
  final String hint;
  final bool showHint;

  Widget _crossFade(Widget first, Widget second, bool isExpanded) {
    return AnimatedCrossFade(
      firstChild: first,
      secondChild: second,
      firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
      secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
      sizeCurve: Curves.fastOutSlowIn,
      crossFadeState:
          isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Row(children: <Widget>[
      Expanded(
        flex: 2,
        child: Container(
          margin: const EdgeInsets.only(left: 24.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              name,
              style: textTheme.body1.copyWith(fontSize: 15.0),
            ),
          ),
        ),
      ),
      Expanded(
          flex: 3,
          child: Container(
              margin: const EdgeInsets.only(left: 24.0),
              child: _crossFade(
                  Text(value,
                      style: textTheme.caption.copyWith(fontSize: 13.0)),
                  Text(hint, style: textTheme.caption.copyWith(fontSize: 13.0)),
                  showHint)))
    ]);
  }
}

class CollapsibleBody extends StatelessWidget {
  const CollapsibleBody({this.margin = EdgeInsets.zero, this.child});

  final EdgeInsets margin;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Container(
          margin: const EdgeInsets.only(bottom: 2.0, right: 15.0, left: 15.0) -
              margin,
          child: Divider(
            height: 1.0,
            color: Colors.black,
          )),
      child,
    ]);
  }
}

class TaskItem<T> {
  TaskItem(
      {this.name,
      this.value,
      this.hint,
      this.builder,
      this.valueToString,
      this.isExpanded})
      : textController = TextEditingController(text: valueToString(value));

  final String name;
  final String hint;
  final TextEditingController textController;
  final TaskItemBodyBuilder<T> builder;
  final ValueToString<T> valueToString;
  T value;
  bool isExpanded;

  ExpansionPanelHeaderBuilder get headerBuilder {
    return (BuildContext context, bool isExpanded) {
      return DualHeaderWithHint(
          name: name,
          value: valueToString(value),
          hint: hint,
          showHint: isExpanded);
    };
  }

  Widget build() => builder(this);
}

class TaskList extends StatefulWidget {
  final flatId;

  final landlordId;
  final landlordName;

  TaskList(this.flatId, this.landlordId, this.landlordName);

  @override
  State<StatefulWidget> createState() {
    return TaskListState(flatId, landlordId, landlordName);
  }
}

enum sortingValues { DUE_DATE, PRIORITY }

class TaskListState extends State<TaskList> {
  int count = 0;
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  var _userId;
  var _userName;
  List<TaskItem<dynamic>> _taskItems;
  bool sortAscending = true;
  var sortBy = sortingValues.DUE_DATE;
  var peopleFilterAllSelected = true;
  int _radioValue1 = 1;
  static var _isResponsibility = true;
  static var _isIssue = true;
  static var _isPayment = true;
  bool initializedNotifications = false;
  String collectionname;
  //List<DateTime> _nextDueDatesForIncompleteTasks;

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

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final flatId;

  final landlordId;
  final landlordName;

  TaskListState(this.flatId, this.landlordId, this.landlordName) {
    debugPrint("landlord name in task list = " + landlordName);
    debugPrint("landlord id in task list = " + landlordId);
    collectionname = 'tasks_landlord';
  }

  Future<void> onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  }

  @override
  void initState() {
    super.initState();
    Utility.getUserId().then((userId) {
      _userId = userId;
    });
    Utility.getUserName().then((userName) {
      _userName = userName;
    });
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    _taskItems = <TaskItem<dynamic>>[
      TaskItem<String>(
        name: 'To-Do',
        value: 'What you do',
        hint: 'Do these items',
        valueToString: (String value) => value,
        isExpanded: true,
        builder: (TaskItem<String> item) {
          return CollapsibleBody(
            child: getTaskListView(false),
          );
        },
      ),
      TaskItem<String>(
        name: 'Completed',
        value: 'These you did',
        hint: 'Items here are done',
        valueToString: (String value) => value,
        isExpanded: false,
        builder: (TaskItem<String> item) {
          return CollapsibleBody(
            child: getTaskListView(true),
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _moveToLastScreen(context);
        return null;
      },
      child: Scaffold(
        body: new SingleChildScrollView(
          child: Column(
            children: <Widget>[
              filterOptions(),
              SafeArea(
                top: false,
                bottom: false,
                child: Container(
                  margin: const EdgeInsets.all(5.0),
                  child: ExpansionPanelList(
                      expansionCallback: (int index, bool isExpanded) {
                        setState(() {
                          _taskItems[index].isExpanded = !isExpanded;
                        });
                      },
                      children: _taskItems
                          .map<ExpansionPanel>((TaskItem<dynamic> item) {
                        return ExpansionPanel(
                            isExpanded: item.isExpanded,
                            headerBuilder: item.headerBuilder,
                            canTapOnHeader: true,
                            body: item.build());
                      }).toList()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getTaskListView(bool isCompleted) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection("user")
            .where('flat_id', isEqualTo: flatId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot1) {
          if (!snapshot1.hasData) return LoadingContainerVertical(7);
          return StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection(globals.flat)
                  .document(flatId)
                  .collection(collectionname)
                  .where("completed", isEqualTo: isCompleted)
                  .where("landlord_id", isEqualTo: landlordId)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> taskSnapshot) {
                if (!taskSnapshot.hasData) return LoadingContainerVertical(7);
                if (isCompleted == false)
                  handleNotifications(taskSnapshot.data.documents);
                updateTasksLastSeen();

                /// SORTING
                ///
                // if(isCompleted == false) {
                //   _nextDueDatesForIncompleteTasks = new List(taskSnapshot.data.documents.length);
                // }

                // _nextDueDatesForIncompleteTasks = new List(taskSnapshot.data.documents.length);
                var sortField = getSortField();
                if (sortAscending) {
                  /*taskSnapshot.data.documents.sort((DocumentSnapshot a,
                    DocumentSnapshot b) =>
                int.parse(a.data['nextDueDate'].compareTo(b.data['nextDueDate']).toString()));*/
                  taskSnapshot.data.documents.sort(
                      (DocumentSnapshot a, DocumentSnapshot b) => int.parse(a
                          .data[sortField]
                          .compareTo(b.data[sortField])
                          .toString()));
                } else {
                  /*taskSnapshot.data.documents.sort((DocumentSnapshot a,
                    DocumentSnapshot b) =>
                int.parse(b.data['nextDueDate'].compareTo(a.data['nextDueDate']).toString()));*/
                  taskSnapshot.data.documents.sort(
                      (DocumentSnapshot a, DocumentSnapshot b) => int.parse(b
                          .data[sortField]
                          .compareTo(a.data[sortField])
                          .toString()));
                }

                if (!peopleFilterAllSelected) {
                  taskSnapshot.data.documents.removeWhere((s) =>
                      !s.data['assignee'].toString().contains(_userId.trim()));
                }

                /// FILTERING
                if (!_isResponsibility) {
                  debugPrint("Removing reminder");
                  taskSnapshot.data.documents.removeWhere(
                      (s) => s.data['type'].toString().trim() == 'Reminder');
                }

                if (!_isIssue) {
                  debugPrint("Removing complaint");
                  taskSnapshot.data.documents.removeWhere(
                      (s) => s.data['type'].toString().trim() == 'Complaint');
                }

                if (!_isPayment) {
                  debugPrint("Removing payment");
                  taskSnapshot.data.documents.removeWhere(
                      (s) => s.data['type'].toString().trim() == 'Payment');
                }

                /// TASK LIST VIEW
                var tooltipKey = new List();
                for (int i = 0; i < taskSnapshot.data.documents.length; i++) {
                  tooltipKey.add(GlobalKey());
                }

                return new ListView.builder(
                  itemCount: taskSnapshot.data.documents.length,
                  scrollDirection: Axis.vertical,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int position) {
                    try {
                      if (isCompleted == false)
                        debugPrint('at load - ' +
                            taskSnapshot.data.documents[position]["nextDueDate"]
                                .toDate()
                                .toIso8601String());
                    } catch (e) {
                      debugPrint(e.toString());
                      debugPrint('it is null');
                    }
                    DateTime datetime = taskSnapshot.data.documents[position]
                                ["nextDueDate"] ==
                            null
                        ? getNextDueDateTime(
                            DateTime.now(),
                            (taskSnapshot.data.documents[position]["due"]
                                    as Timestamp)
                                .toDate(),
                            taskSnapshot.data.documents[position]["_repeat"],
                            taskSnapshot.data.documents[position]["_frequency"])
                        : (taskSnapshot.data.documents[position]["nextDueDate"]
                                as Timestamp)
                            .toDate();

                    final f = new DateFormat.jm();
                    var datetimeString = datetime.day.toString() +
                        " " +
                        numToMonth[datetime.month.toInt()] +
                        " " +
                        datetime.year.toString() +
                        " - " +
                        f.format(datetime);

                    //+ datetime.hour.toString() + ":" + datetime.minute.toString();

                    return Column(
                        //color: Colors.white,
                        //elevation: 2.0,
                        children: [
                          Slidable(
                            key: new Key(position.toString()),
                            enabled: !isCompleted,
                            actionPane: SlidableDrawerActionPane(),
                            dismissal: SlidableDismissal(
                              child: SlidableDrawerDismissal(),
                              closeOnCanceled: true,
                              dismissThresholds: <SlideActionType, double>{
                                SlideActionType.primary: 1.0
                              },
                              onWillDismiss: (actionType) {
                                return showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return new AlertDialog(
                                      title: new Text('Delete'),
                                      content: new Text('Item will be deleted'),
                                      actions: <Widget>[
                                        new FlatButton(
                                          child: new Text('Cancel'),
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                        ),
                                        new FlatButton(
                                          child: new Text('Ok'),
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              onDismissed: (actionType) {
                                Firestore.instance
                                    .collection(globals.flat)
                                    .document(flatId)
                                    .collection(collectionname)
                                    .document(taskSnapshot
                                        .data.documents[position].documentID)
                                    .delete();
                              },
                            ),
                            actionExtentRatio: 0.25,
                            actions: <Widget>[
                              new IconSlideAction(
                                caption: 'Complete',
                                color: Colors.green,
                                icon: Icons.check,
                                onTap: () {
                                  var _repeat = taskSnapshot
                                      .data.documents[position]['repeat'];
                                  var _due = DateTime.now();
                                  if (_repeat != -1 &&
                                      taskSnapshot.data.documents[position]
                                              ['type'] !=
                                          'Complaint') {
                                    debugPrint('datetime --- ' +
                                        datetime.toIso8601String());
                                    DateTime nextDueDate = getNextDueDateTime(
                                        datetime,
                                        taskSnapshot
                                            .data.documents[position]['due']
                                            .toDate(),
                                        taskSnapshot.data.documents[position]
                                            ['repeat'],
                                        taskSnapshot.data.documents[position]
                                            ['frequency']);
                                    debugPrint('nextdatetime --- ' +
                                        nextDueDate.toIso8601String());

                                    Firestore.instance
                                        .collection(globals.flat)
                                        .document(flatId)
                                        .collection(collectionname)
                                        .document(taskSnapshot.data
                                            .documents[position].documentID)
                                        .updateData(
                                            {'nextDueDate': nextDueDate});

                                    var taskHistoryData = {
                                      "created_at": DateTime.now(),
                                      "completed_by": _userId,
                                      "user_name": _userName,
                                    };
                                    Firestore.instance
                                        .collection(globals.flat)
                                        .document(flatId)
                                        .collection(collectionname)
                                        .document(taskSnapshot.data
                                            .documents[position].documentID)
                                        .collection(globals.taskHistory)
                                        .add(taskHistoryData);
                                  } else {
                                    Firestore.instance
                                        .collection(globals.flat)
                                        .document(flatId)
                                        .collection(collectionname)
                                        .document(taskSnapshot.data
                                            .documents[position].documentID)
                                        .updateData({'completed': true});

                                    var taskHistoryData = {
                                      "created_at": DateTime.now(),
                                      "completed_by": _userId,
                                      "user_name": _userName,
                                    };
                                    Firestore.instance
                                        .collection(globals.flat)
                                        .document(flatId)
                                        .collection(collectionname)
                                        .document(taskSnapshot.data
                                            .documents[position].documentID)
                                        .collection(globals.taskHistory)
                                        .add(taskHistoryData);
                                  }
                                  setState(() {});
                                },
                              ),
                            ],
                            secondaryActions: <Widget>[
                              new IconSlideAction(
                                caption: 'Delete',
                                color: Colors.red,
                                icon: Icons.delete,
                                onTap: () async {
                                  var state = Slidable.of(context);
                                  var dismiss = await showDialog<bool>(
                                    context: context,
                                    builder: (context) {
                                      return new AlertDialog(
                                        title: new Text('Delete'),
                                        content:
                                            new Text('Item will be deleted'),
                                        actions: <Widget>[
                                          new FlatButton(
                                            child: new Text('Cancel'),
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                          ),
                                          new FlatButton(
                                            child: new Text('Ok'),
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (dismiss) {
                                    Firestore.instance
                                        .collection(globals.flat)
                                        .document(flatId)
                                        .collection(collectionname)
                                        .document(taskSnapshot.data
                                            .documents[position].documentID)
                                        .delete();
                                    state.dismiss();
                                  }
                                },
                              ),
                            ],
                            child: Card(
                              margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
                              elevation: 5.0,
                              child: ClipPath(
                                clipper: ShapeBorderClipper(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(3))),
                                child: Container(
                                  padding:
                                      EdgeInsets.only(top: 7.0, bottom: 7.0),
                                  decoration: BoxDecoration(
                                    border: Border(
                                        left: BorderSide(
                                            color: getPriorityColor(
                                                datetime, isCompleted),
                                            width: 5.0)),
                                  ),
                                  child: ListTile(
                                    /*leading: CircleAvatar(
                          backgroundColor: Colors.white10,
                          child: Icon(
                            Icons.arrow_right,
                            color: Colors.black26,
                          ),
                        ),*/
                                    title: CommonWidgets.textBox(
                                        taskSnapshot.data.documents[position]
                                            ["title"],
                                        15.0,
                                        color: Colors.black),
                                    subtitle: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 10.0),
                                        taskSnapshot.data.documents[position]
                                                    ["repeat"] ==
                                                1
                                            ? CommonWidgets.textBox(
                                                'Always Available', 12.0,
                                                color: Colors.black45)
                                            : Row(
                                                children: <Widget>[
                                                  CommonWidgets.textBox(
                                                      isCompleted == false
                                                          ? _getDateTimeString(
                                                              datetime)
                                                          : _getDateTimeString(
                                                              taskSnapshot
                                                                  .data
                                                                  .documents[
                                                                      position]
                                                                      ['due']
                                                                  .toDate()),
                                                      11.0,
                                                      color: Colors.black45),
                                                  Container(
                                                    width: 4.0,
                                                  ),
                                                  taskSnapshot.data.documents[
                                                                  position]
                                                              ["repeat"] !=
                                                          -1
                                                      ? Icon(
                                                          Icons.replay,
                                                          size: 16,
                                                        )
                                                      : Container(),
                                                ],
                                              )
                                      ],
                                    ),
                                    trailing: getUsersAssignedView(
                                        taskSnapshot.data.documents[position]
                                            ["assignee"],
                                        snapshot1),
                                    leading: Container(
                                      child: Tooltip(
                                        key: tooltipKey[position],
                                        decoration:
                                            BoxDecoration(color: Colors.indigo),
                                        message: taskSnapshot
                                            .data.documents[position]["type"],
                                        child: IconButton(
                                          icon: Icon(
                                            (icons[taskSnapshot
                                                    .data.documents[position]
                                                ["type"]]['icon']),
                                            color: (icons[taskSnapshot
                                                    .data.documents[position]
                                                ["type"]]['color']),
                                          ),
                                          onPressed: () {
                                            dynamic tooltip =
                                                tooltipKey[position]
                                                    .currentState;
                                            tooltip.ensureTooltipVisible();
                                          },
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      debugPrint("Task added");
                                      navigateToViewTask(
                                          taskId: taskSnapshot.data
                                              .documents[position].documentID);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ]);
                  },
                );
              });
        });
  }

  void updateTasksLastSeen() async {
    Utility.updateReadTasksLastSeen(
        flatId, Timestamp.now().millisecondsSinceEpoch);
  }

  String _getDateTimeString(DateTime nextDueDate) {
    final f = new DateFormat.jm();
    var datetimeString = nextDueDate.day.toString() +
        " " +
        numToMonth[nextDueDate.month.toInt()] +
        " " +
        nextDueDate.year.toString() +
        " - " +
        f.format(nextDueDate);

    return datetimeString;
  }

  DateTime getNextDueDateTime(
      DateTime nowDueDate, DateTime due, int repeat, String frequency) {
    DateTime now = DateTime.now();
    debugPrint('nowduedate = ' + nowDueDate.toIso8601String());
    switch (repeat) {
      case -1:
        {
          return due;
        }
      case 0:
        {
          debugPrint('in 0 ' + repeat.toString());
          return nowDueDate.add(new Duration(days: 1));
        }
      case 1:
        {
          return due;
        }
      case 2:
        {
          DateTime tempNow = new DateTime(nowDueDate.year, nowDueDate.month,
              nowDueDate.day, due.hour, due.minute);

          tempNow = tempNow.add(new Duration(days: 1));
          while (tempNow.weekday != nowDueDate.weekday) {
            tempNow = tempNow.add(new Duration(days: 1));
          }

          return tempNow;
        }
      case 3:
        {
          List<int> taskFreq =
              frequency.split(',').map(int.parse).toSet().toList();
          taskFreq.sort();
          int taskDay = -1;
          for (int i = 0; i < taskFreq.length; i++) {
            if (taskFreq[i] > nowDueDate.weekday) {
              taskDay = taskFreq[i];
              break;
            }
          }

          if (taskDay == -1) {
            taskDay = taskFreq[0];
          }

          DateTime tempNow = new DateTime(nowDueDate.year, nowDueDate.month,
              nowDueDate.day, due.hour, due.minute);
          tempNow = tempNow.add(new Duration(days: 1));
          while (tempNow.weekday != taskDay) {
            tempNow = tempNow.add(new Duration(days: 1));
          }

          return new DateTime(
              tempNow.year, tempNow.month, tempNow.day, due.hour, due.minute);
        }
      case 4:
        {
          int month = nowDueDate.month;
          int year = nowDueDate.year;
          if (month == 12) {
            month = 1;
            year++;
          } else {
            month++;
          }

          debugPrint("new month: " + month.toString());

          int lastDay = getLastDayForMonth(month, year);
          int taskDay;
          if (lastDay < due.day) {
            taskDay = lastDay;
          } else {
            taskDay = due.day;
          }

          return new DateTime(year, month, taskDay, due.hour, due.minute);
        }
      case 5:
        {
          debugPrint("frequencies in repeat 5: " + frequency);
          List<int> taskFreq =
              frequency.split(',').map(int.parse).toSet().toList();
          taskFreq.sort();
          int taskDay = -1;
          for (int i = 0; i < taskFreq.length; i++) {
            debugPrint("date = " + taskFreq[i].toString());
            if (taskFreq[i] > nowDueDate.day) {
              taskDay = taskFreq[i];
              break;
            }
          }

          int month = nowDueDate.month;
          int year = nowDueDate.year;

          if (taskDay == -1) {
            taskDay = taskFreq[0];
            if (month == 12) {
              month = 1;
              year++;
            } else {
              month++;
            }
          }

          debugPrint("new month = " + month.toString());
          debugPrint("taskday = " + taskDay.toString());

          int lastDay = getLastDayForMonth(month, year);
          if (lastDay < taskDay) {
            debugPrint("in if = ");

            taskDay = lastDay;
            if (taskDay == nowDueDate.day &&
                month == nowDueDate.month &&
                year == nowDueDate.year) {
              taskDay = taskFreq[0];
              if (month == 12) {
                month = 1;
                year++;
              } else {
                month++;
              }
              lastDay = getLastDayForMonth(month, year);
              if (lastDay < taskDay) {
                taskDay = lastDay;
              }
            }
          }

          debugPrint("before returning values = " +
              month.toString() +
              " - " +
              taskDay.toString());
          return new DateTime(year, month, taskDay, due.hour, due.minute);
        }
    }

    return nowDueDate;
  }

  int getLastDayForMonth(int month, int year) {
    if (month == 1 ||
        month == 3 ||
        month == 5 ||
        month == 7 ||
        month == 8 ||
        month == 10 ||
        month == 12) {
      return 31;
    } else if (month == 4 || month == 6 || month == 9 || month == 11) {
      return 30;
    } else {
      if (year % 4 == 0) {
        return 29;
      } else {
        return 28;
      }
    }
  }

  DateTime getNextDueDateTimeAfterToday(
      DateTime due, int repeat, String frequency) {
    DateTime now = DateTime.now();
    debugPrint('freq = ' + frequency);
    int nowTime = now.hour * 60 + now.minute;
    int dueTime = due.hour * 60 + due.minute;
    switch (repeat) {
      case -1:
        {
          return due;
        }
      case 0:
        {
          if (nowTime > dueTime) {
            return now.add(new Duration(days: 1));
          }

          return new DateTime(
              now.year, now.month, now.day, due.hour, due.minute);
        }
      case 1:
        {
          return due;
        }
      case 2:
        {
          if (due.weekday == now.weekday && nowTime < dueTime) {
            return new DateTime(
                now.year, now.month, now.day, due.hour, due.minute);
          }

          DateTime tempNow = DateTime.now();

          while (tempNow.weekday != due.weekday) {
            tempNow = tempNow.add(new Duration(days: 1));
          }
          return new DateTime(
              tempNow.year, tempNow.month, tempNow.day, due.hour, due.minute);
        }
      case 3:
        {
          if (due.weekday == now.weekday && nowTime < dueTime) {
            return new DateTime(
                now.year, now.month, now.day, due.hour, due.minute);
          }

          DateTime tempNow = DateTime.now();

          while (tempNow.weekday != due.weekday) {
            tempNow = tempNow.add(new Duration(days: 1));
          }
          return new DateTime(
              tempNow.year, tempNow.month, tempNow.day, due.hour, due.minute);
        }
      case 4:
        {
          if (due.day == now.day && nowTime < dueTime) {
            return new DateTime(
                now.year, now.month, now.day, due.hour, due.minute);
          }

          int month = now.month;
          int year = now.year;
          if (month == 12) {
            month = 1;
            year++;
          } else {
            month++;
          }

          debugPrint("new month: " + month.toString());

          int lastDay = getLastDayForMonth(month, year);
          int taskDay;
          if (lastDay < due.day) {
            taskDay = lastDay;
          } else {
            taskDay = due.day;
          }

          return new DateTime(year, month, taskDay, due.hour, due.minute);
        }
      case 5:
        {
          if (due.day == now.day && nowTime < dueTime) {
            return new DateTime(
                now.year, now.month, now.day, due.hour, due.minute);
          }

          int month = now.month;
          int year = now.year;
          if (month == 12) {
            month = 1;
            year++;
          } else {
            month++;
          }

          debugPrint("new month: " + month.toString());

          int lastDay = getLastDayForMonth(month, year);
          int taskDay;
          if (lastDay < due.day) {
            taskDay = lastDay;
          } else {
            taskDay = due.day;
          }

          return new DateTime(year, month, taskDay, due.hour, due.minute);
        }
    }

    return DateTime.now();
  }

  Map<String, Map<String, dynamic>> icons = {
    'Reminder': {'icon': Icons.calendar_today, 'color': Colors.black},
    'Payment': {'icon': Icons.payment, 'color': Colors.blue},
    'Complaint': {'icon': Icons.error_outline, 'color': Colors.red}
  };

  void navigateToAddTask(String typeOfTask, {taskId}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return CreateTask(taskId, flatId, typeOfTask, landlordId, landlordName);
      }),
    );
  }

  MaterialColor getPriorityColor(DateTime taskDue, bool isCompleted) {
    if (isCompleted) {
      return Colors.grey;
    }
    DateTime now = DateTime.now();
    debugPrint("datetime = " + taskDue.toIso8601String());
    debugPrint(taskDue.toIso8601String());
    debugPrint(now.difference(taskDue).inDays.toString());
    if (taskDue.isBefore(now)) {
      return Colors.grey;
    }
    if (taskDue.difference(now).inMinutes <= 1440) {
      return Colors.red;
    } else if (taskDue.difference(now).inMinutes <= 4320) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }

  bool userDetailsObtained = false;
  Widget getUsersAssignedView(users, AsyncSnapshot<QuerySnapshot> snapshot1) {
    return new Container(
      margin: EdgeInsets.only(right: 5.0),
      child: Stack(
        alignment: Alignment.centerRight,
        overflow: Overflow.visible,
        children:
            _getPositionedOverlappingUsers(users, snapshot1.data.documents),
      ),
    );
  }

  List<Widget> _getPositionedOverlappingUsers(
      users, List<DocumentSnapshot> flatUsers) {
    List<String> userList;
    userList = users.toString().trim().split(',').toList();

    var overflowAddition = 0.0;
    if (userList.length > 3) overflowAddition = 8.0;

    List<Widget> overlappingUsers = new List();
    overflowAddition > 0
        ? overlappingUsers.add(Text('+', style: TextStyle(fontSize: 16.0)))
        : overlappingUsers.add(Container(
            height: 0.0,
            width: 0.0,
          ));

    for (var j in userList) {
      debugPrint("elems == " + j);
    }

    userList.sort();
    int length = userList.length > 3 ? 3 : userList.length;
    debugPrint("length of users - " + userList.length.toString());
    debugPrint("length == " + userList.length.toString());

    int availableUsers = 0;
    for (int i = 0; i < length; i++) {
      String initial = getInitial(userList[i], flatUsers);
      if (initial == '') {
        continue;
      }
      availableUsers++;
      debugPrint("i == " + i.toString());
      var color = userList[i].toString().trim().hashCode;
      overlappingUsers.add(new Positioned(
        right: (i * 20.0) + overflowAddition,
        child: new CircleAvatar(
          maxRadius: 14.0,
          backgroundColor: Colors.primaries[color % Colors.primaries.length]
              [300],
          child: Text(initial),
        ),
      ));
    }
    if (userList.contains(landlordId)) {
      var colorL = landlordId.toString().trim().hashCode;

      overlappingUsers.add(new Positioned(
        right: ((availableUsers) * 20) + overflowAddition,
        child: new CircleAvatar(
          maxRadius: 14.0,
          backgroundColor: Colors.primaries[colorL % Colors.primaries.length]
              [300],
          child: Text(landlordName[0]),
        ),
      ));
    }
    return overlappingUsers;
  }

  String getInitial(documentId, flatUsers) {
    debugPrint("documentId = " + documentId);
    for (int i = 0; i < flatUsers.length; i++) {
      debugPrint("flatusers documentId = " + flatUsers[i].documentID);
      if (flatUsers[i].documentID == documentId) {
        return flatUsers[i].data['name'][0];
      }
    }
    return '';
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

  void navigateToViewTask({taskId}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return ViewTask(taskId, flatId, landlordId, landlordName);
      }),
    );
  }

  _moveToLastScreen(BuildContext _navigatorContext) {
    debugPrint("Back");
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  Widget filterOptions() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          /// Show all tasks
          Column(
            children: <Widget>[
              Material(
                borderRadius: BorderRadius.circular(31),
                color: peopleFilterAllSelected ? Colors.black12 : Colors.white,
                child: InkWell(
                  customBorder: CircleBorder(),
                  child: IconButton(
                      icon: Icon(
                        Icons.home,
                        color: Colors.black,
                      ),
                      onPressed: null),
                  onTap: () {
                    setState(() {
                      peopleFilterAllSelected = true;
                    });
                  },
                ),
              ),
              SizedBox(
                height: 2.0,
              ),
              Text(
                "All",
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12.0,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(
                height: 2.0,
              ),
            ],
          ),

          /// Show my tasks
          Column(
            children: <Widget>[
              Material(
                borderRadius: BorderRadius.circular(31),
                color: peopleFilterAllSelected ? Colors.white : Colors.black12,
                child: InkWell(
                  customBorder: CircleBorder(),
                  child: IconButton(
                      icon: Icon(
                        Icons.person,
                        color: Colors.black,
                      ),
                      onPressed: null),
                  onTap: () {
                    setState(() {
                      peopleFilterAllSelected = false;
                    });
                  },
                ),
              ),
              SizedBox(
                height: 2.0,
              ),
              Text(
                "Me",
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12.0,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(
                height: 2.0,
              ),
            ],
          ),

          /// Task Filter
          Column(
            children: <Widget>[
              Material(
                color: Colors.white,
                child: InkWell(
                  customBorder: CircleBorder(),
                  child: IconButton(
                      icon: Icon(
                        Icons.filter_list,
                        color: Colors.black,
                      ),
                      onPressed: null),
                  onTap: () {
                    showFilterBottomSheet();
                  },
                ),
              ),
              SizedBox(
                height: 2.0,
              ),
              Text(
                "Filter",
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12.0,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(
                height: 2.0,
              ),
            ],
          ),

          ///Task Sort
          Column(
            children: <Widget>[
              Material(
                color: Colors.white,
                child: InkWell(
                  customBorder: CircleBorder(),
                  child: IconButton(
                      icon: Icon(
                        Icons.sort,
                        color: Colors.black,
                      ),
                      onPressed: null),
                  onTap: () {
                    showSortBottomSheet(context);
                  },
                ),
              ),
              SizedBox(
                height: 2.0,
              ),
              Text(
                "Sort",
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12.0,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(
                height: 2.0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleSortRadioValueChange(int value) {
    setState(() {
      _radioValue1 = value;

      switch (_radioValue1) {
        case 0:
          sortAscending = true;
          Navigator.of(context).pop();
          break;
        case 1:
          sortAscending = false;
          Navigator.of(context).pop();
          break;
      }
    });
  }

  showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          bottom: true,
          child: Container(
            height: 180.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(10),
                topRight: const Radius.circular(10),
              ),
            ),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Radio(
                          value: 0,
                          groupValue: _radioValue1,
                          onChanged: _handleSortRadioValueChange,
                        ),
                        new Text(
                          'Ascending',
                          style: new TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Radio(
                          value: 1,
                          groupValue: _radioValue1,
                          onChanged: _handleSortRadioValueChange,
                        ),
                        new Text(
                          'Descending',
                          style: new TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
                ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text(
                    "Due Date",
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12.0,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700),
                  ),
                  trailing: sortBy == sortingValues.DUE_DATE
                      ? Icon(
                          Icons.check,
                          color: Colors.green,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      sortBy = sortingValues.DUE_DATE;
                    });
                    Navigator.pop(context);
                  },
                ),
                
              ],
            ),
          ),
        );
      },
    );
  }

  showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return FilterSheet(this.filterChange);
      },
    );
  }

  void filterChange(String filter, bool value) {
    setState(() {
      if (filter == Strings.responsibility) {
        _isResponsibility = value;
      } else if (filter == Strings.issue) {
        _isIssue = value;
      } else if (filter == Strings.payment) {
        _isPayment = value;
      }
    });
  }

  String getSortField() {
    if (sortBy == sortingValues.DUE_DATE) return 'nextDueDate';
    if (sortBy == sortingValues.PRIORITY) return 'priority';
    return 'due';
  }

  void _showDaily(id, title, description, DateTime due) async {
    debugPrint('daily - ' + id.toString());
    var time = Time(due.hour, due.minute);
    debugPrint(due.hour.toString() + ' - ' + due.minute.toString());
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        "ShowDailyID", 'RepeatDaily', 'Repeat Task Daily at specified time');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
        id.toString().hashCode,
        title,
        description,
        time,
        platformChannelSpecifics,
        payload: 'due:' +
            due.millisecondsSinceEpoch.toString() +
            ',id:' +
            id.toString());
  }

  void _schedule(int id, String title, String description, DateTime due) async {
    debugPrint('schedule - ' + id.toString());

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        "ShowDailyID", 'RepeatDaily', 'Repeat Task Daily at specified time');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    ;
    await flutterLocalNotificationsPlugin.schedule(id.toString().hashCode,
        title, description, due, platformChannelSpecifics,
        payload: 'due:' +
            due.millisecondsSinceEpoch.toString() +
            ',id:' +
            id.toString());
  }

  void _showWeekly(
      int id, String title, String description, DateTime due, int day) async {
    debugPrint('weekly - ' + id.toString());

    day = day + 1;
    if (day == 8) day = 1;
    var time = Time(due.hour, due.minute, 0);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        "ShowWeeklyID", 'RepeatWeekly', 'Repeat Task Weekly at specified time');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
        id.toString().hashCode,
        title,
        description,
        Day(day),
        time,
        platformChannelSpecifics,
        payload: 'due:' +
            due.millisecondsSinceEpoch.toString() +
            ',id:' +
            id.toString());
  }

  void _showMonthly(int id, String title, String description, DateTime due,
      DateTime date) async {
    debugPrint('monthly - ' + title);
    debugPrint('monthly date = ' + date.toIso8601String());

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        "ShowMonthlyID",
        'RepeatMonthly',
        'Repeat Task Monthly at specified time');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(id.toString().hashCode,
        title, description, date, platformChannelSpecifics,
        payload: 'due:' +
            due.millisecondsSinceEpoch.toString() +
            ',id:' +
            id.toString());
  }

  void _removeIfTaskNotPresent(var documents) async {
    var pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    for (var pendingNotificationRequest in pendingNotificationRequests) {
      debugPrint("PENDING = " + pendingNotificationRequest.payload.toString());
      var s = false;
      for (int position = 0; position < documents.length; position++) {
        if (_getNotificationPayloadValue(pendingNotificationRequest, 'id')
            .contains(documents[position].documentID.hashCode.toString())) {
          s = true;
          break;
        }
      }

      if (!s) {
        debugPrint(
            "Cancelling " + pendingNotificationRequest.payload.toString());
        await flutterLocalNotificationsPlugin
            .cancel(pendingNotificationRequest.id);
      }
    }
  }

  String _getNotificationPayloadValue(
      PendingNotificationRequest pendingNotificationRequest, String key) {
    debugPrint(pendingNotificationRequest.payload);
    dynamic payload = pendingNotificationRequest.payload;
    String value;
    try {
      payload = payload.split(',');
      if (key == 'id') {
        value = payload[1].split(':')[1];
      } else if (key == 'due') {
        value = payload[0].split(':')[1];
      }
    } catch (e) {}
    value = value == null ? '' : value;
    return value;
  }

  void _addOrModifyNotificationsForNewTasks(var documents) async {
    var pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    for (int i = 0; i < documents.length; i++) {
      DateTime dueDateTimeTemp = (documents[i]['due'] as Timestamp).toDate();
      if ((documents[i]['repeat'] == -1 &&
              dueDateTimeTemp.isBefore(DateTime.now())) ||
          documents[i]['repeat'] == 1) {
        continue;
      }

      List<PendingNotificationRequest> taskNotifications =
          _getNotificationsForDocument(
              (documents[i] as DocumentSnapshot).documentID.hashCode.toString(),
              pendingNotificationRequests);
      debugPrint('title - ' +
          documents[i]['title'] +
          '; modify - ' +
          taskNotifications.length.toString());
      if (taskNotifications.isEmpty) {
        _addNotificationsForTask(documents[i]);
        continue;
      }
      if ([-1, 0, 1, 2, 4].contains(documents[i]['repeat']) &&
          !_checkIfDueDateOrRepeatModified(
              documents[i], taskNotifications[0]) &&
          taskNotifications.length >= 1) {
        continue;
      } else if ([-1, 0, 1, 2, 4].contains(documents[i]['repeat'])) {
        _cancelNotificationsForTask(taskNotifications);
        _addNotificationsForTask(documents[i]);
        continue;
      }
      List<PendingNotificationRequest> deletedFrequencyTasks =
          _getRemovedTaskFrequencyNotifications(
              taskNotifications, documents[i]['frequency']);
      List<int> addedFrequencies = _getAddedTaskFrequencyNotifications(
          taskNotifications, documents[i]['frequency']);

      if ([3, 5].contains(documents[i]['repeat']) &&
          !_checkIfDueDateOrRepeatModified(
              documents[i], taskNotifications[0]) &&
          deletedFrequencyTasks.isEmpty &&
          addedFrequencies.isEmpty) {
        continue;
      } else if (_checkIfDueDateOrRepeatModified(
          documents[i], taskNotifications[0])) {
        _cancelNotificationsForTask(taskNotifications);
        _addNotificationsForTask(documents[i]);
      } else {
        if (deletedFrequencyTasks.isNotEmpty) {
          _cancelNotificationsForTask(deletedFrequencyTasks);
        }
        if (addedFrequencies.isNotEmpty) {
          _addTasksForAddedFrequencies(addedFrequencies, documents[i]);
        }
      }
    }
  }

  void _addTasksForAddedFrequencies(
      List<int> frequencies, DocumentSnapshot document) {
    int _repeat = document['repeat'];
    String title = document['title'];
    DateTime due = (document['due'] as Timestamp).toDate();
    String description = "You have a task due at " +
        TimeOfDay(hour: due.hour, minute: due.minute).format(context) +
        ". Please check it.";

    if (_repeat == 3) {
      for (int i = 0; i < frequencies.length; i++) {
        _showWeekly(
            int.parse(document.documentID.hashCode.toString() +
                "3" +
                frequencies[i].toString().padLeft(2, '0')),
            title,
            description,
            due,
            frequencies[i]);
      }
    } else if (_repeat == 5) {
      for (int i = 0; i < frequencies.length; i++) {
        DateTime notificationDate =
            getNextDueDateTimeAfterToday(due, _repeat, frequencies.join(','));
        _showMonthly(
            int.parse(document.documentID.hashCode.toString() +
                "5" +
                frequencies[i].toString().padLeft(2, '0')),
            title,
            description,
            due,
            notificationDate);
      }
    }
  }

  List<PendingNotificationRequest> _getRemovedTaskFrequencyNotifications(
      List<PendingNotificationRequest> taskNotifications, String frequency) {
    Set<int> documentFrequencies = frequency.split(',').map(int.parse).toSet();
    List<PendingNotificationRequest> deletedNotificationFrequencies =
        new List();

    for (var notification in taskNotifications) {
      String id = _getNotificationPayloadValue(notification, 'id');
      int nFreq = int.parse(id.substring(id.length - 2));
      if (!documentFrequencies.contains(nFreq)) {
        deletedNotificationFrequencies.add(notification);
      }
    }

    return deletedNotificationFrequencies;
  }

  List<int> _getAddedTaskFrequencyNotifications(
      List<PendingNotificationRequest> taskNotifications, String frequency) {
    Set<int> documentFrequencies = frequency.split(',').map(int.parse).toSet();
    Set<int> notificationFrequencies = new Set();
    for (var notification in taskNotifications) {
      String id = _getNotificationPayloadValue(notification, 'id');
      int freq = int.parse(id.substring(id.length - 2));
      notificationFrequencies.add(freq);
    }

    Set<int> addedFrequencies =
        documentFrequencies.difference(notificationFrequencies);

    return addedFrequencies.toList();
  }

  void _cancelNotificationsForTask(
      List<PendingNotificationRequest> taskNotifications) {
    for (var notification in taskNotifications) {
      flutterLocalNotificationsPlugin.cancel(notification.id);
    }
  }

  bool _checkIfDueDateOrRepeatModified(
      var document, PendingNotificationRequest taskNotification) {
    int _repeat = document['repeat'];
    DateTime documentDue = document['due'].toDate();

    DateTime d = DateTime.fromMillisecondsSinceEpoch(
        int.parse(_getNotificationPayloadValue(taskNotification, 'due')));
    String id = _getNotificationPayloadValue(taskNotification, 'id');
    int taskRepeat = int.parse(id[id.length - 3]);

    if (_repeat == 3 || _repeat == 5) {
      if (documentDue.hour == d.hour &&
          documentDue.minute == d.minute &&
          _repeat == taskRepeat) {
        return false;
      } else {
        return true;
      }
    } else {
      if (d.compareTo(documentDue) == 0 && _repeat == taskRepeat) {
        return false;
      } else {
        return true;
      }
    }
  }

  void _addNotificationsForTask(var document) {
    int _repeat = document['repeat'];
    String title = document['title'];
    DateTime due = (document['due'] as Timestamp).toDate();
    debugPrint('hello');
    List<int> frequency = [];
    if (_repeat == 3 || _repeat == 5)
      frequency =
          document['frequency'].toString().split(',').map(int.parse).toList();
    String description =
        "You have a task due at ${due.hour}:${due.minute}. Please check it.";

    switch (_repeat) {
      case -1:
        {
          _schedule(int.parse(document.documentID.hashCode.toString() + "900"),
              title, description, due);
          break;
        }
      case 0:
        {
          _showDaily(int.parse(document.documentID.hashCode.toString() + "100"),
              title, description, due);
          break;
        }
      case 2:
        {
          _showWeekly(
              int.parse(document.documentID.hashCode.toString() + "200"),
              title,
              description,
              due,
              due.weekday);
          break;
        }
      case 3:
        {
          for (int i = 0; i < frequency.length; i++) {
            _showWeekly(
                int.parse(document.documentID.hashCode.toString() +
                    "3" +
                    frequency[i].toString().padLeft(2, '0')),
                title,
                description,
                due,
                frequency[i]);
          }
          break;
        }
      case 4:
        {
          DateTime notificationDate = getNextDueDateTimeAfterToday(due, 4, '');

          _showMonthly(
              int.parse(document.documentID.hashCode.toString() + "400"),
              title,
              description,
              due,
              notificationDate);
          break;
        }
      case 5:
        {
          for (int i = 0; i < frequency.length; i++) {
            DateTime notificationDate = getNextDueDateTimeAfterToday(
                new DateTime(
                    due.year, due.month, frequency[i], due.hour, due.minute),
                4,
                '');

            _showMonthly(
                int.parse(document.documentID.hashCode.toString() +
                    "5" +
                    frequency[i].toString().padLeft(2, '0')),
                title,
                description,
                due,
                notificationDate);
          }
          break;
        }
    }
  }

  List<PendingNotificationRequest> _getNotificationsForDocument(
      String id, List<PendingNotificationRequest> pendingNotifications) {
    List<PendingNotificationRequest> notificationsForTasks = new List();
    for (var pendingNotificationRequest in pendingNotifications) {
      if (_getNotificationPayloadValue(pendingNotificationRequest, 'id')
          .contains(id)) {
        notificationsForTasks.add(pendingNotificationRequest);
      }
    }
    return notificationsForTasks;
  }

  void handleNotifications(var documents) async {
    List<PendingNotificationRequest> pendingNotifications =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    /* debugPrint(pendingNotifications.length.toString());
    for (var pendingNotificationRequest in pendingNotifications) {
    flutterLocalNotificationsPlugin.cancel(pendingNotificationRequest.id);            
          
        
      }*/

    await _removeIfTaskNotPresent(documents);
    await _addOrModifyNotificationsForNewTasks(documents);

    pendingNotifications =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    debugPrint(pendingNotifications.length.toString());
    for (var pendingNotificationRequest in pendingNotifications) {
      debugPrint('notification == ' +
          pendingNotificationRequest.title +
          ' due = ' +
          pendingNotificationRequest.body.toString());
    }
  }
}

class FilterSheet extends StatefulWidget {
  Function callback;

  FilterSheet(this.callback);

  @override
  State<StatefulWidget> createState() {
    return new _FilterSheet();
  }
}

class _FilterSheet extends State<FilterSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 125.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(10),
          topRight: const Radius.circular(10),
        ),
      ),
      child: Wrap(
        spacing: 5.0,
        runSpacing: 3.0,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FilterChip(
              label: Text(Strings.responsibility),
              backgroundColor: Colors.transparent,
              selectedColor: Colors.white30,
              shape: StadiumBorder(side: BorderSide()),
              selected: TaskListState._isResponsibility,
              onSelected: (bool value) {
                setState(() {
                  TaskListState._isResponsibility = value;
                });
                this.widget.callback(Strings.responsibility, value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FilterChip(
              label: Text(Strings.issue),
              backgroundColor: Colors.transparent,
              selectedColor: Colors.white30,
              shape: StadiumBorder(side: BorderSide()),
              selected: TaskListState._isIssue,
              onSelected: (bool value) {
                setState(() {
                  TaskListState._isIssue = value;
                });
                this.widget.callback(Strings.issue, value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FilterChip(
              label: Text(Strings.payment),
              backgroundColor: Colors.transparent,
              selectedColor: Colors.white30,
              shape: StadiumBorder(side: BorderSide()),
              selected: TaskListState._isPayment,
              onSelected: (bool value) {
                setState(() {
                  TaskListState._isPayment = value;
                });
                this.widget.callback(Strings.payment, value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
