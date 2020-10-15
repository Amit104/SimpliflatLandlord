import 'package:flutter/material.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;
import 'package:simpliflat_landlord/dao/task_dao.dart';
import 'package:simpliflat_landlord/dao/tenant_dao.dart';
import 'package:simpliflat_landlord/model/owner.dart';
import 'package:simpliflat_landlord/model/owner_flat.dart';
import 'package:simpliflat_landlord/model/models.dart';
import 'package:simpliflat_landlord/model/task.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/ui/tasks/create_task.dart';
import 'package:simpliflat_landlord/ui/tasks/taskHistory.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/common_widgets/loading_container.dart';
import 'package:intl/intl.dart';
import 'package:simpliflat_landlord/utility/utility.dart';

class ViewTask extends StatefulWidget {
  final String taskId;
  final OwnerFlat _flat;
  final User user;

  ViewTask(this.taskId, this._flat, this.user);

  @override
  State<StatefulWidget> createState() {
    return _ViewTask(taskId, _flat, this.user);
  }
}

class _ViewTask extends State<ViewTask> {
  final String taskId;
  final OwnerFlat _flat;
  bool _remind = false;
  String _selectedType = "Responsibility";
  String _selectedPriority = "Low";
  static const _priorities = ["High", "Low"];
  static const _taskType = ["Responsibility", "Issue"];
  static const _days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  List<String> assignedTo = new List();
  var _navigatorContext;
  TextEditingController tc = TextEditingController();
  var _formKey1 = GlobalKey<FormState>();
  Set<String> selectedUsers = new Set();
  String collectionname;

  final User user;

  Map<int, String> repeatMsgs = {
    -1: 'Occur Once',
    0: 'Occurs daily',
    1: 'Always Available',
    2: 'Occurs weekly',
    3: 'Occurs weekly on particular days',
    4: 'Occurs monthly',
    5: 'Occurs monthly on particular dates'
  };

  _ViewTask(this.taskId, this._flat, this.user) {
    collectionname = 'tasks_landlord';
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
          appBar: AppBar(
            title: Text('Task Details'),
            elevation: 0.0,
            backgroundColor: Colors.grey[300],
            centerTitle: true,
          ),
          //floatingActionButton: Padding(padding: EdgeInsets.only(bottom:50.0), child:FloatingActionButton(onPressed: () {_navigateToTaskHistory(taskId, _flatId);},child: Icon(Icons.history), tooltip: 'History',)),
          body: Builder(builder: (BuildContext scaffoldC) {
            _navigatorContext = scaffoldC;
            return Container(
              child: taskId == null
                  ? Container()
                  : StreamBuilder(
                      stream: TaskDao.getTask(_flat.getApartmentTenantId(), taskId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return LoadingContainerVertical(1);
                        
                        Task task = Task.fromJson(snapshot.data, taskId);
                        tc.text = taskId == null ? "" : task.getTitle();
                        return Column(
                          children: <Widget>[
                            Expanded(child: buildView(task)),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Opacity(
                                    opacity: 0.6,
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                          top: 1.0, right: 1.0, left: 0.0),
                                      child: RaisedButton(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 15.0),
                                        color: Colors.grey[200],
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(0.0),
                                        ),
                                        child: Text(
                                          "Edit",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18.0,
                                              fontFamily: 'Montserrat'),
                                        ),
                                        onPressed: () {
                                          navigateToAddTask(taskId,
                                              task.getType());
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Opacity(
                                    opacity: 0.6,
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                          top: 1.0, right: 1.0, left: 0.0),
                                      child: RaisedButton(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 15.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(0.0),
                                        ),
                                        color: Colors.grey[200],
                                        child: Text(
                                          "Delete",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18.0,
                                              fontFamily: 'Montserrat'),
                                        ),
                                        onPressed: () async {
                                          bool ifSuccess = await TaskDao.delete(_flat.getApartmentTenantId(), taskId);
                                          if(ifSuccess)
                                            Navigator.of(_navigatorContext).pop();
                                          else
                                            Utility.createErrorSnackBar(scaffoldC, error: "Error while deleting task. Please try again");
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
            );
          }),
        ));
  }

  void navigateToAddTask(taskId, String typeOfTask) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) {
        return CreateTask(
            taskId, _flat, typeOfTask, this.user);
      }),
    );
  }

  Widget _getTaskNameWidget(String label, String title) {
    return Text(title,
        style: const TextStyle(
            color: Colors.black,
            fontSize: 30.0,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold));
  }

  Widget _getTags(String text, String text2, String duration) {
    return Container(
      child: Wrap(
        runSpacing: 0.0,
        children: [
          Chip(
            label: Text(text,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 13.0,
                  fontFamily: 'Montserrat',
                )),
            backgroundColor: Colors.deepPurple[100],
          ),
          SizedBox(width: 5.0),
          Chip(
            label: Text(text2,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 13.0,
                  fontFamily: 'Montserrat',
                )),
            backgroundColor: Colors.indigo[100],
          ),
          duration != '-' ? SizedBox(width: 5.0) : Container(),
          duration != '-'
              ? Chip(
                  label: Text('Takes ' + duration,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 13.0,
                        fontFamily: 'Montserrat',
                      )),
                  backgroundColor: Colors.lightGreen[100],
                )
              : Container()
        ],
      ),
    );
  }

  Widget _getDueDateTimeWidget(String nextDueDate) {
    var deviceSize = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(width: 1.0, color: Colors.grey[300])),
      child: ListTile(
        dense: true,
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.calendar_today,
              color: Colors.blueGrey,
            ),
          ],
        ),
        title: Text('Due',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              fontFamily: 'Montserrat',
            )),
        subtitle: Text(nextDueDate,
            style: const TextStyle(
              fontSize: 13.0,
              fontFamily: 'Montserrat',
            )),
      ),
    );
  }

  Widget _getNotesWidget(String notes) {
    return Container(
      padding: EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            dense: true,
            trailing: Icon(Icons.event_note, color: Colors.indigo[400]),
            title: Text('NOTES',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14.0,
                  fontFamily: 'Montserrat',
                )),
          ),
          Container(
            margin: EdgeInsets.only(left: 5.0, top: 2.0),
            child: Text(notes == '' ? '-' : notes,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14.0,
                  fontFamily: 'Montserrat',
                )),
          ),
        ],
      ),
    );
  }

  Widget _getCreatedOnWidget(String date) {
    return Text('Created on  ' + date,
        style: const TextStyle(
          color: Colors.blueGrey,
          fontSize: 15.0,
          fontFamily: 'Montserrat',
        ));
  }

  Widget buildView(Task task) {
    String type = task.getType();
    return Container(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      child: ListView(
        children: <Widget>[
          SizedBox(height: 20.0),
          _getTaskNameWidget('Task Name', task.getTitle()),
          SizedBox(height: 25.0),
          _getCreatedOnWidget(getDateTimeFormattedString(task.getCreatedAt())),
          SizedBox(height: 20.0),
          _getTags(
              type,
              task.isCompleted() == true ? "Completed" : "Not Completed",
              getFormattedDurationString(task.getDuration())),

          task.getRepeat() != 1 ? SizedBox(height: 20.0) : Container(),
          task.getRepeat() != 1
              ? _getDueDateTimeWidget(
                  getDateTimeFormattedString(task.getNextDueDate()))
              : Container(),
          SizedBox(height: 20.0),
          task.getType() != 'Complaint'
              ? _getRepeatLayout('Repeat', task.getRepeat(), task.getFrequency())
              : _getRemindMeWidget(task.isRemindIssue()),
          task.getType() == 'Payment'
              ? SizedBox(
                  height: 30.0,
                )
              : Container(),
          task.getType() == 'Payment'
              ? _getPaymentInfoWidget(task.getPaymentAmount(), task.getPayee())
              : Container(),
          SizedBox(height: 30.0),
          _getAssigneesLayout('Assigned To', task.getAssignees()),
          SizedBox(height: 20.0),
          _getNotesWidget(task.getNotes()),
          SizedBox(height: 20.0),
          _getHistoryButton(),
          SizedBox(height: 20.0),
        ],
      ),
    );
  }

  Widget _getHistoryButton() {
    return RaisedButton(
      padding: EdgeInsets.symmetric(vertical: 15.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
      ),
      color: Colors.grey[300],
      child: Text(
        "History",
        style: TextStyle(
            color: Colors.black, fontSize: 18.0, fontFamily: 'Montserrat'),
      ),
      onPressed: () {
        _navigateToTaskHistory(taskId, _flat);
      },
    );
  }

  Widget _getPaymentInfoWidget(double paymentAmount, String payee) {
    payee = payee == null ? '-' : payee;
    return Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          ListTile(
            dense: true,
            trailing: Icon(
              Icons.payment,
              color: Colors.lightBlue[400],
            ),
            title: Text(
              'PAYMENT INFORMATION',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15.0,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
          Container(
            child: ListTile(
              dense: true,
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.attach_money,
                    color: Colors.blueGrey,
                  ),
                ],
              ),
              title: Text('Amount',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontFamily: 'Montserrat',
                  )),
              subtitle: Text(paymentAmount.toString(),
                  style: const TextStyle(
                    fontSize: 13.0,
                    fontFamily: 'Montserrat',
                  )),
            ),
          ),
          Container(
            child: ListTile(
              dense: true,
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.person,
                    color: Colors.blueGrey,
                  ),
                ],
              ),
              title: Text('Payee',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontFamily: 'Montserrat',
                  )),
              subtitle: Text(payee,
                  style: const TextStyle(
                    fontSize: 13.0,
                    fontFamily: 'Montserrat',
                  )),
            ),
          ),
        ]));
  }

  Widget _getRemindMeWidget(bool ifRemind) {
    return Container(
        padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(width: 1.0, color: Colors.grey[300])),
        child: ListTile(
            dense: true,
            trailing: Switch(
              value: ifRemind,
              onChanged: (value) {},
              activeTrackColor: Colors.grey,
              activeColor: Colors.lightBlue[300],
            ),
            title: Text(
              'Remind daily',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 14.0,
                  fontFamily: 'Montserrat'),
            )));
  }

  _navigateToTaskHistory(taskId, flatId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return TaskHistory(taskId, _flat.getApartmentTenantId());
      }),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  _moveToLastScreen(BuildContext _navigatorContext) {
    debugPrint("Back");
    Navigator.pop(_navigatorContext, true);
  }

  Card _getListTile(String title, subtitle) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
      elevation: 7.0,
      child: Container(
        padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [Colors.blue[50], Colors.white])),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: EdgeInsets.all(13.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontFamily: 'Montserrat'),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      subtitle == null ? '-' : subtitle.toString(),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14.0,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ])),
          SizedBox(height: 2.0)
        ]),
      ),
    );
  }

  Container _getRepeatLayout(String title, subtitle, List<int> frequency) {
    debugPrint(subtitle.toString());
    List<int> frequencies =
        frequency != null ? frequency : [];
    return Container(
        padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(width: 1.0, color: Colors.grey[300])),
        child: subtitle != 5
            ? ListTile(
                dense: true,
                leading: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(Icons.replay)]),
                title: Text(
                  (subtitle == null
                      ? '-'
                      : subtitle == 3
                          ? getWeeksFrequencyMsg(frequencies)
                          : repeatMsgs[subtitle]),
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontFamily: 'Montserrat'),
                ))
            : ExpansionTile(
                leading: Icon(Icons.replay),
                title: Text(
                  repeatMsgs[subtitle],
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.0,
                    fontFamily: 'Montserrat',
                  ),
                ),
                children: [
                    Container(
                        height: 190.0,
                        padding: EdgeInsets.all(5.0),
                        child: GridView.count(
                            childAspectRatio: 3 / 2,
                            crossAxisCount: 7,
                            children: List.generate(31, (index) {
                              return Container(
                                  margin: EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: frequencies.contains(index + 1)
                                        ? Colors.grey[300]
                                        : Colors.white,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    (index + 1).toString(),
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 13.0,
                                        fontFamily: 'Montserrat'),
                                  ));
                            })))
                  ]));
  }

  String getWeeksFrequencyMsg(List<int> frequency) {
    String msg = 'Occurs weekly on ';
    frequency.sort();
    for (int i = 0; i < frequency.length; i++) {
      msg = msg + _days[frequency[i] - 1];
      if (i < frequency.length - 1) msg = msg + ', ';
    }
    return msg;
  }

  String getDateTimeFormattedString(Timestamp duedate) {
    // DateTime _selectedDate = (duedate as Timestamp).toDate();
    // var _selectedTime = new TimeOfDay(hour: _selectedDate.hour, minute: _selectedDate.minute);
    // String date = DateFormat('dd/MM/yyyy').format(_selectedDate);
    // String time = _selectedTime.hour.toString().padLeft(2, '0') + ":" + _selectedTime.minute.toString().padLeft(2, '0');
    // return date + ' ' + time;
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
    DateTime datetime = (duedate as Timestamp).toDate();
    final f = new DateFormat.jm();
    var datetimeString = datetime.day.toString() +
        " " +
        numToMonth[datetime.month.toInt()] +
        " " +
        datetime.year.toString() +
        "  " +
        f.format(datetime);

    return datetimeString;
  }

  String getFormattedDurationString(Duration _duration) {
    if (_duration != null) {
      String hours = _duration.inHours.toString();
      String minutes = _duration.inMinutes.remainder(60).toString();
      return hours + 'h ' + minutes + 'm';
    } else {
      return '-';
    }
  }

  Widget _getAssigneesLayout(String title, List<String >assignees) {
    return FutureBuilder(
      future: TenantDao.getTenantsUsingTenantFlatId(_flat.getTenantFlatId()),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return LoadingContainerVertical(1);

        return Container(
            padding: EdgeInsets.all(5.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                      dense: true,
                      title: Text(
                        'ASSIGNED TO',
                        style: TextStyle(fontSize: 15.0),
                      ),
                      trailing:
                          Icon(Icons.people, color: Colors.lightGreen[400])),
                  Container(
                    margin: EdgeInsets.only(left: 5.0),
                    child: Wrap(
                      children:
                          getAssignees(snapshot.data.documents, assignees),
                    ),
                  )
                ]));
      },
    );
  }

  List<Widget> getAssignees(List<DocumentSnapshot> documents, assignees) {
    List<Widget> chips = new List();
    List<String> assigneesList = new List();
    if (assignees != null && assignees != '') {
      assigneesList = assignees.split(',').toList();
    }
    if (assigneesList.contains(this.user.getUserId())) {
      chips.add(Container(
        margin: EdgeInsets.only(right: 5.0),
        child: Chip(
          labelPadding: EdgeInsets.all(0.0),
          label: Text(' ' + this.user.getName() + ' '),
          backgroundColor: Colors.grey[200],
        ),
      ));
    }
    for (int i = 0; i < documents.length; i++) {
      if (assigneesList.contains(documents[i].documentID)) {
        chips.add(Container(
          margin: EdgeInsets.only(right: 5.0),
          child: Chip(
            labelPadding: EdgeInsets.all(0.0),
            label: Text(' ' + documents[i]['name'] + '  '),
            backgroundColor: Colors.grey[200],
          ),
        ));
      }
    }
    return chips;
  }

  List<Container> _getAssigneesTiles(List documents) {
    List<Container> w = new List();
    for (int i = 0; i < documents.length; i++) {
      w.add(Container(
        child: Column(children: [
          Divider(height: 1.0),
          ListTile(
            title: Text(documents[i]['name']),
          ),
        ]),
      ));
    }
    return w;
  }
}