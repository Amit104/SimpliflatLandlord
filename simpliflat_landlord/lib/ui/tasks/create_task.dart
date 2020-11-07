import 'package:flutter/material.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;
import 'package:simpliflat_landlord/dao/task_dao.dart';
import 'package:simpliflat_landlord/model/models.dart';
import 'package:simpliflat_landlord/model/owner.dart';
import 'package:simpliflat_landlord/model/owner_flat.dart';
import 'package:simpliflat_landlord/model/owner_tenant.dart';
import 'package:simpliflat_landlord/model/task.dart';
import 'package:simpliflat_landlord/model/tenant.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/services/task_service.dart';
import 'package:simpliflat_landlord/utility/utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/common_widgets/loading_container.dart';
import 'package:simpliflat_landlord/ui/tasks/assign_to_flat.dart';
import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class CreateTask extends StatefulWidget {
  final String taskId;
  OwnerTenant _flat;
  final typeOfTask;

  final User user;

  CreateTask(this.taskId, this._flat, this.typeOfTask, this.user);

  @override
  State<StatefulWidget> createState() {
    return _CreateTask(
        taskId, _flat, typeOfTask, this.user);
  }
}

class _CreateTask extends State<CreateTask> {
  final String taskId;
  final OwnerTenant _flat;
  String typeOfTask;

  Set<String> selectedUsers = new Set();

  //static const existingUsers = ["User1", "User2"];
  bool _remind = false;
  String _selectedType = "Responsibility";
  String _selectedPriority = "Low";
  String _selectedUser = "";
  List<String> assignedTo = new List();
  static const _priorities = ["High", "Low"];
  static const _taskType = ["Responsibility", "Issue"];
  static const _days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  var _navigatorContext;
  TextEditingController tc = TextEditingController();
  TextEditingController notescontroller = TextEditingController();
  TextEditingController paymentAmountController = TextEditingController();
  TextEditingController payeecontroller = TextEditingController();

  var _formKey1 = GlobalKey<FormState>();
  var _formKey2 = GlobalKey<FormState>();
  DateTime _selectedDate;
  TimeOfDay _selectedTime;
  String _duedate;
  static DateTime _due;
  static int _repeat = -1;
  static Set<int> _selectedFrequencies;
  bool initialized = false;
  String _durationStr = '';
  Duration _duration;
  String _repeatStr = '';
  final User user;

  String createdBy;

  DateTime _nextDueDate;

  DateTime duebefore;
  int repeatbefore;

  bool openConfictsView = false;

  String _notes = '';

  Map<int, String> repeatMsgs = {
    -1: 'Occurs Once',
    0: 'Set Daily',
    1: 'Always Available',
    2: 'Set weekly',
    3: 'Set weekly on particular days',
    4: 'Set Monthly',
    5: 'Set monthly on particular dates'
  };

  String _payee;

  RegExp regExp = new RegExp('[0-9]{2}h [0-9]{2}m');

  bool _isRemindMeOfIssueSelected;

  bool showConflictsWarningSign = false;

  _CreateTask(this.taskId, this._flat, this.typeOfTask, this.user) {
    this._isRemindMeOfIssueSelected = false;
  }

  @override
  Widget build(BuildContext context) {
    //initUsers();
    return WillPopScope(
        onWillPop: () {
          _moveToLastScreen(context);
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: taskId == null ? Text("Add Task") : Text("Edit Task"),
            elevation: 2.0,
            centerTitle: true,
          ),
          body: Builder(builder: (BuildContext scaffoldC) {
            _navigatorContext = scaffoldC;
            return Column(children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(top: 0.0),
                  child: taskId == null
                      ? buildForm()
                      : StreamBuilder(
                          stream: TaskDao.getTask(_flat.getOwnerTenantId(), taskId),
                          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (!snapshot.hasData)
                              return LoadingContainerVertical(1);
                             /** build screen */
                             return populateTaskDetails(snapshot);
                          },
                        ),
                ),
              ),
              Row(
                children: <Widget>[
                  _getSaveButtonWidget(),
                  _getDeleteButtonWidget(),
                ],
              ),
            ]);
          }),
        ));
  }

  Widget _getDeleteButtonWidget() {
    return Expanded(
      child: Opacity(
        opacity: 1.0,
        child: Container(
          padding: const EdgeInsets.only(top: 1.0, right: 1.0, left: 0.0),
          child: RaisedButton(
              padding: EdgeInsets.symmetric(vertical: 15.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
              color: Colors.red[200],
              child: Text(
                "Delete",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontFamily: 'Montserrat'),
              ),
              onPressed: () => deleteTask(),
                ),
              ),
        ),
      
    );
  }

  Widget _getSaveButtonWidget() {
    return Expanded(
      child: Opacity(
        opacity: 1.0,
        child: Container(
          padding: const EdgeInsets.only(top: 1.0, right: 1.0, left: 0.0),
          child: RaisedButton(
              padding: EdgeInsets.symmetric(vertical: 15.0),
              color: Colors.green[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
              child: Text(
                "Save",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontFamily: 'Montserrat'),
              ),
              onPressed: () => saveTask(),
        ),
      ),
    ));
  }

  Widget _getTaskNameWidget() {
    TextStyle textStyle = Theme.of(_navigatorContext).textTheme.title;
    return Container(
      height: 55.0,
      alignment: Alignment.center,
      child: TextFormField(
        controller: tc,
        style: textStyle,
        validator: (String value) {
          if (value.isEmpty) return "Task cannot be empty!";
          if (value.length > 50)
            return "Maximum length of task is 50 characters!";
          return null;
        },
        decoration: InputDecoration(
          hintText: 'Task Name',
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding:
              EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
          errorStyle: TextStyle(
              color: Colors.red,
              fontSize: 12.0,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700),
          labelStyle: textStyle,
        ),
      ),
    );
  }

  Widget _getDueDateTimeWidget(String nextDueDate) {
    debugPrint('new datetime = ' + nextDueDate);

    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(5.0),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.25),
              blurRadius: 4,
              offset: Offset(0, 4), // changes position of shadow
            ),
          ],
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
          subtitle: nextDueDate == ''
              ? null
              : Text(nextDueDate,
                  style: const TextStyle(
                    fontSize: 13.0,
                    fontFamily: 'Montserrat',
                  )),
          trailing: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Visibility(
                    visible: showConflictsWarningSign,
                    child: IconButton(
                      icon: Icon(
                        Icons.warning,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          openConfictsView = true;
                        });
                      },
                    )),
                Icon(Icons.edit, color: Colors.blueGrey)
              ]),
          onTap: () {
            _selectDate(context);
          }),
    );
  }

  String getDateTimeFormattedString(duedate) {
    if (duedate == null) return '';
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

  Container _getRepeatLayout() {
    int subtitle = _repeat;
    debugPrint('subtitle --- ' + subtitle.toString());
    Set<int> frequencies = _selectedFrequencies;
    return Container(
        padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: Colors.white,
            border: Border.all(width: 1.0, color: Colors.grey[300]),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.25),
              blurRadius: 4,
              offset: Offset(0, 4), // changes position of shadow
            ),
          ],
        ),
        child: ListTile(
          dense: true,
          leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.replay)]),
          title: Text(
            (subtitle == null
                ? '-'
                : subtitle == 3
                    ? getWeeksFrequencyMsg(frequencies.toList())
                    : repeatMsgs[subtitle]),
            style: TextStyle(
                color: Colors.black, fontSize: 14.0, fontFamily: 'Montserrat'),
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => new Form(
                key: _formKey2,
                child: AlertDialog(
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0),
                    side: BorderSide(
                      width: 1.0,
                      color: Colors.indigo[900],
                    ),
                  ),
                  title: new Text("Repeat",
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                          fontSize: 16.0)),
                  content: new SingleChildScrollView(
                    child: new Material(
                      child: new RepeatDialog(
                          this.getFrequency, _repeat, _selectedFrequencies),
                    ),
                  ),
                ),
              ),
            );
          },
          trailing: Icon(Icons.edit),
        ));
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

  Widget getFlatAssigneesList() {
    return Container(
      padding: EdgeInsets.only(top: 5.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                child: ExpansionTile(
                    trailing: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.home),
                            onPressed: () {
                              navigateToAssignToFlatsScreen();
                            },
                          ),
                          Icon(Icons.arrow_drop_down)
                        ]),
                    initiallyExpanded: false,
                    title: Text('ASSIGN TO FLATS'),
                    children: [getFlatNamesListWidget()])),
          ]),
    );
  }

  void navigateToAssignToFlatsScreen() async {
    List<String> assignedFlatIdsTemp =
        assignedFlatIds == null ? new List() : assignedFlatIds;
    assignedFlatIdsTemp =
        await Navigator.push(context, new MaterialPageRoute(builder: (context) {
      return AssignToFlat(List.from(assignedFlatIdsTemp), flatIdNameList);
    }));

    if (assignedFlatIdsTemp != null) {
      setState(() {
        assignedFlatIds = assignedFlatIdsTemp;
      });
    }
    if (assignedFlatIdsTemp != null && assignedFlatIdsTemp.isNotEmpty) {
      setState(() {
        ifAssignToUser = false;
        selectedUsers = new Set();
      });
    } else if (assignedFlatIdsTemp != null && assignedFlatIdsTemp.isEmpty) {
      setState(() {
        ifAssignToUser = true;
      });
    }
  }

  bool ifAssignToUser = true;
  Widget _getAssigneesLayout() {
    return Container(
      padding: EdgeInsets.only(top: 5.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
                dense: true,
                title: Text(
                  'ASSIGN TO USERS',
                  style: TextStyle(fontSize: 15.0),
                ),
                trailing: Icon(Icons.people, color: Colors.lightGreen[400])),
            SizedBox(height: 5.0),
            ifAssignToUser
                ? Container(
                    padding: EdgeInsets.only(left: 10.0),
                    height: 60.0,

                        
                          child: ListView.builder(
                              itemCount: this._flat.getOwnerFlat().getOwners().length + this._flat.getTenantFlat().getTenants().length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder:
                                  (BuildContext context, int position) {
                                debugPrint("position - " + position.toString());
                                var documentID;
                                var name;
                                if(position < this._flat.getOwnerFlat().getOwners().length) {
                                  //owners
                                  documentID = this._flat.getOwnerFlat().getOwners()[position].getOwnerId();
                                  name = this._flat.getOwnerFlat().getOwners()[position].getName();
                                } else {
                                  //tenants
                                  documentID = this._flat.getTenantFlat().getTenants()[position - this._flat.getOwnerFlat().getOwners().length].getTenantId();
                                  name = this._flat.getTenantFlat().getTenants()[position - this._flat.getOwnerFlat().getOwners().length].getName();
                                }
                                
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      debugPrint("docuemnt - " + documentID);
                                      if (selectedUsers.contains(documentID))
                                        selectedUsers.remove(documentID);
                                      else
                                        selectedUsers.add(documentID);
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(right: 5.0),
                                    child: Chip(
                                      labelPadding: EdgeInsets.all(5.0),
                                      avatar: CircleAvatar(
                                          backgroundColor:
                                              selectedUsers.contains(documentID)
                                                  ? Colors.grey[400]
                                                  :  Colors.primaries[documentID.hashCode % Colors.primaries.length],
                                          child: Text(
                                            getInitials(name),
                                          )),
                                      label: Text(name),
                                    ),
                                  ),
                                );
                              }))
                        
                  
                : Container(child: Text('Assigned to all users'))
          ]),
    );
  }

  Future<dynamic> getFlatIdAndNamesList() async {
    List<Map> flatIdNameListTemp = new List();
    flatIdNameListTemp.add({'id': 'ALL', 'name': 'ALL'});
    List flatIdList = await Utility.getFlatIdList();
    for (int i = 0; i < flatIdList.length; i++) {
      var id = flatIdList[i];
      if (id.contains("Name=")) {
        flatIdNameListTemp
            .add({'id': id.split("Name=")[0], 'name': id.split("Name=")[1]});
      }
    }

    flatIdNameList = List.from(flatIdNameListTemp);
    return flatIdNameListTemp;
  }

  List flatIdNameList = new List();

  List<String> assignedFlatIds;
  Widget getFlatNamesListWidget() {
    if (assignedFlatIds == null) {
      return Container();
    }
    return FutureBuilder(
      future: getFlatIdAndNamesList(),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return LoadingContainerVertical(1);
        }
        List assignedFlatIdsTemp = List.from(assignedFlatIds);
        assignedFlatIdsTemp.remove("ALL");
        return ListView.builder(
          shrinkWrap: true,
          itemCount: assignedFlatIdsTemp.length,
          itemBuilder: (context, position) {
            return ListTile(
              title: Text(getFlatNameFromId(snapshot.data, position,
                  assignedFlatIdsTemp)), //Text((snapshot.data as List)[position]['name']),
            );
          },
        );
      },
    );
  }

  String getFlatNameFromId(List data, int position, List assignedFlatIdsTemp) {
    Map flatTemp =
        data.firstWhere((e) => e['id'] == assignedFlatIdsTemp[position]);
    if (flatTemp != null) {
      return flatTemp['name'];
    } else {
      return 'Flat ' + position.toString();
    }
  }

  Widget _getRemindMeWidget() {
    return Container(
        padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.25),
                blurRadius: 4,
                offset: Offset(0, 4), // changes position of shadow
              ),
            ],
            color: Colors.white,
            border: Border.all(width: 1.0, color: Colors.grey[300])),
        child: ListTile(
            dense: true,
            trailing: Switch(
              value: _isRemindMeOfIssueSelected,
              onChanged: (value) {
                setState(() {
                  debugPrint((!value).toString());
                  _isRemindMeOfIssueSelected = value;
                  _repeat = value ? 0 : -1;
                  debugPrint(_isRemindMeOfIssueSelected.toString());
                });
              },
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

  Widget _getPaymentInfoWidget() {
    TextStyle textStyle = Theme.of(_navigatorContext).textTheme.title;

    _payee = _payee == null ? '-' : _payee;
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
              title: Container(
                child: TextField(
                  controller: paymentAmountController,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 17.0,
                  ),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Payment Amount',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorStyle: TextStyle(
                        color: Colors.red,
                        fontSize: 10.0,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700),
                    labelStyle: textStyle,
                  ),
                ),
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
                    Icons.person,
                    color: Colors.blueGrey,
                  ),
                ],
              ),
              title: TextFormField(
                  maxLines: null,
                  controller: payeecontroller,
                  decoration: const InputDecoration(
                    hintText: 'Payee',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  )),
            ),
          ),
        ]));
  }

  Widget _getNotesWidget() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
          alignment: Alignment.center,
          margin: EdgeInsets.only(left: 10.0, right: 5.0, bottom: 4.0),
          child: TextFormField(
              maxLines: null,
              controller: notescontroller,
              decoration: const InputDecoration(
                hintText: 'Notes',
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ))),
    ]);
  }

  Widget _getDurationWidget() {
    return ListTile(
      title: _durationStr == ''
          ? Text(
              'Duration',
              style: TextStyle(
                color: _durationStr == '' ? Colors.grey[500] : Colors.black,
              ),
            )
          : Text(getFormattedDurationString()),
      leading: Icon(
        Icons.timer,
        color: Colors.indigo[400],
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => new Form(
            key: _formKey2,
            child: AlertDialog(
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10.0),
                side: BorderSide(
                  width: 1.0,
                  color: Colors.indigo[900],
                ),
              ),
              title: new Text("Duration",
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Montserrat',
                      fontSize: 16.0)),
              content: new SingleChildScrollView(
                child: new Column(
                  children: [
                    CupertinoTimerPicker(
                      initialTimerDuration:
                          _duration == null ? new Duration() : _duration,
                      mode: CupertinoTimerPickerMode.hm,
                      onTimerDurationChanged: (value) {
                        debugPrint(value.toString());
                        _durationStr = value.toString();
                        _duration = value;
                      },
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              OutlineButton(
                                  shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(10.0),
                                    side: BorderSide(
                                      width: 1.0,
                                      color: Colors.indigo[900],
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  textColor: Colors.black,
                                  child: Text('Save',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14.0,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w700)),
                                  onPressed: () {
                                    setState(() {
                                      showConflictsWarningSign = false;
                                      _durationStr = _durationStr;
                                      _getTasksWithConflicts();
                                    });
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                  }),
                              OutlineButton(
                                  shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(10.0),
                                    side: BorderSide(
                                      width: 1.0,
                                      color: Colors.indigo[900],
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  textColor: Colors.black,
                                  child: Text('Cancel',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14.0,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w700)),
                                  onPressed: () {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                  })
                            ]))
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _getConflictsViewWidget() {
    return Visibility(
      visible: tasksWithConflicts.length > 0 && openConfictsView,
      child: Container(
        color: Colors.grey[100],
        child: Card(
          child: Column(
            children: [
              Container(
                  color: Colors.grey[400],
                  child: ListTile(
                      title: Text('Conflicts'),
                      trailing: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            openConfictsView = false;
                          });
                        },
                      ))),
              Scrollbar(
                child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 400.0),
                    child: ListView.separated(
                      itemCount: tasksWithConflicts.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      separatorBuilder: (context, index) {
                        return Divider();
                      },
                      itemBuilder: (BuildContext context, int index) {
                        int repeatTemp = tasksWithConflicts[index]['repeat'];
                        List<int> freqTemp;
                        if (repeatTemp == 3 || repeatTemp == 5) {
                          freqTemp =
                              (tasksWithConflicts[index]['frequency'] as String)
                                  .split(',')
                                  .map(int.parse)
                                  .toList();
                        }
                        return ListTile(
                          title: Text(tasksWithConflicts[index]['title']),
                          subtitle: Text(repeatTemp == 3
                              ? getWeeksFrequencyMsg(freqTemp.toList())
                              : repeatMsgs[repeatTemp]),
                        );
                      },
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildForm() {
    return Container(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      child: Form(
        key: _formKey1,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  SizedBox(height: 20.0),
                  _getTaskNameWidget(),
                  typeOfTask != 'Complaint'
                      ? SizedBox(height: 20.0)
                      : Container(),
                  typeOfTask != 'Complaint' ? _getRepeatLayout() : Container(),
                  typeOfTask == 'Reminder'
                      ? SizedBox(height: 20.0)
                      : Container(),
                  typeOfTask == 'Reminder' ? _getDurationWidget() : Container(),
                  _repeat != 1 ? SizedBox(height: 20.0) : Container(),
                  _repeat != 1
                      ? _getDueDateTimeWidget(getDateTimeFormattedString1())
                      : Container(),
                  _repeat != 1 ? SizedBox(height: 10.0) : Container(),
                  _repeat != 1 ? _getConflictsViewWidget() : Container(),
                  typeOfTask == 'Complaint'
                      ? SizedBox(height: 20.0)
                      : Container(),
                  typeOfTask == 'Complaint'
                      ? _getRemindMeWidget()
                      : Container(),
                  SizedBox(height: 20.0),
                  _getAssigneesLayout(),
                  taskId == null ? SizedBox(height: 20.0) : Container(),
                  taskId == null ? getFlatAssigneesList() : Container(),
                  typeOfTask == 'Payment'
                      ? SizedBox(height: 20.0)
                      : Container(),
                  typeOfTask == 'Payment'
                      ? _getPaymentInfoWidget()
                      : Container(),
                  SizedBox(height: 20.0),
                  _getNotesWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// validates form and returns error message or '' if no error
  String _validateForm() {
    /** validate title */

    if (!_formKey1.currentState.validate()) {
      return 'Task Name is mandatory';
    } else if (_selectedDate == null || _selectedTime == null) {
      return 'Due date and time is mandatory';
    }

    if (typeOfTask == 'Reminder') {
    } else if (typeOfTask == 'Complaint') {
    } else if (typeOfTask == 'Payment') {}

    return '';
  }

  ///formats selected due date and and selected due time into a dd/MM/yyyy hh24:mi:ss string
  String getDateTimeFormattedString1() {
    if (_selectedDate == null || _selectedTime == null) return '';
    String date = DateFormat('dd/MM/yyyy').format(_selectedDate);
    String time = _selectedTime.hour.toString().padLeft(2, '0') +
        ":" +
        _selectedTime.minute.toString().padLeft(2, '0');
    return date + ' ' + time;
  }

  ///formats duration into a '<>h <>m' string
  String getFormattedDurationString() {
    String hours = _duration.inHours.toString();
    String minutes = _duration.inMinutes.remainder(60).toString();
    return 'Takes  ' + hours + 'h ' + minutes + 'm';
  }

  ///returns initials of name
  String getInitials(String name) {
    debugPrint("name = " + name);
    var names = name.split(' ');
    var initials = names[0][0];
    if (names.length == 2) initials = initials + names[1][0];

    return initials;
  }

  ///callback after repeat is set
  getFrequency(Set<int> frequencies, int repeat) {
    var msg = repeatMsgs[repeat];
    debugPrint("in getFreq");

    setState(() {
      if (repeat == 1) {
        _selectedDate = DateTime.now();
        _selectedTime = TimeOfDay(
            hour: _selectedDate.hour, minute: _selectedDate.minute + 1);
      } else {
        _selectedDate = null;
        _selectedTime = null;
      }
      _selectedFrequencies = frequencies;
      _repeat = repeat;
      _repeatStr = msg;
      showConflictsWarningSign = false;
      openConfictsView = false;
    });
  }

  ///dialog box to select due date and time and check conflicts
  Future<Null> _selectDate(BuildContext context) async {
    DateTime picked;
    if (_repeat == 1) {
      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return AlertDialog(
                content: Text(
                    'Not allowed to set due date time when repeat is set to always available'));
          });
      return;
    }
    if (_repeat == -1 || typeOfTask == 'Complaint') {
      picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate == null ? DateTime.now() : _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2101));
      final TimeOfDay timePicked = await showTimePicker(
        context: context,
        initialTime: _selectedTime == null ? TimeOfDay.now() : _selectedTime,
      );
      if ((timePicked != null && timePicked != _selectedTime) ||
          (picked != null && picked != _selectedDate)) {
        setState(() {
          showConflictsWarningSign = false;
        });
        setState(() {
          _selectedTime = timePicked;
          _selectedDate = picked;
        });
        _getTasksWithConflicts();
      }
    } else {
      final TimeOfDay timePicked = await showTimePicker(
        context: context,
        initialTime: _selectedTime == null ? TimeOfDay.now() : _selectedTime,
      );
      if ((timePicked != null && timePicked != _selectedTime)) {
        String freq =
            _selectedFrequencies == null ? '' : _selectedFrequencies.join(',');
        DateTime now = DateTime.now();

        picked = TaskService.getNextDueDateTime(
            new DateTime(now.year, now.month, now.day, timePicked.hour,
                timePicked.minute),
            _repeat,
            freq);

        setState(() {
          showConflictsWarningSign = false;
        });
        debugPrint('in else');
        setState(() {
          _selectedTime = timePicked;
          _selectedDate = picked;
        });
        _getTasksWithConflicts();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_selectedFrequencies != null) _selectedFrequencies.clear();
    _repeat = -1;
  }

  _moveToLastScreen(BuildContext _navigatorContext) {
    debugPrint("Back");
    if (_selectedFrequencies != null) _selectedFrequencies.clear();
    _repeat = -1;
    Navigator.pop(_navigatorContext, true);
  }



  List tasksWithConflicts = new List();

  ///check conflicts and add them in tasksWithConflicts variable
  void _getTasksWithConflicts() async {
    if (_selectedDate == null || _selectedTime == null) {
      debugPrint('returned');
      return;
    }

    DateTime duedatetime = new DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute);
    tasksWithConflicts = await TaskService.getTasksWithConflicts(this._flat.getOwnerTenantId(), tasksWithConflicts, _repeat, _selectedFrequencies, taskId, _duration, duedatetime);
   
      setState(() {
        tasksWithConflicts = tasksWithConflicts;
        if (tasksWithConflicts.length > 0)
          showConflictsWarningSign = true;
        else
          showConflictsWarningSign = false;
      });
    
  }

  Widget populateTaskDetails(AsyncSnapshot<DocumentSnapshot> snapshot) {
    if (taskId != null && !initialized) {
                              /** if edit task */
                              /** process data receieved from database and assign */
                              
                              Task task = Task.fromJson(snapshot.data.data, taskId);
                              debugPrint(snapshot.data['title'] +
                                  ' ' +
                                  snapshot.data['priority'].toString() +
                                  ' ' +
                                  snapshot.data['duration'].toString() +
                                  ' ' +
                                  snapshot.data['repeat'].toString() +
                                  ' ' +
                                  snapshot.data['frequency'].toString() +
                                  ' ' +
                                  snapshot.data['assignee'].toString() +
                                  ' ' +
                                  snapshot.data['due'].toString() +
                                  ' ' +
                                  snapshot.data['notes']);
                              
                              this.createdBy = task.getCreatedByUserId();


                              /** get task name */
                              tc.text = task.getTitle();
                              /** get task name ends */

                              /** get priority */
                              _selectedPriority = task.getPriority() == 0
                                  ? "Low"
                                  : "High";
                              /** get priority ends */

                              /**  get duration */
                              _duration = task.getDuration();
                              if(_duration != null) {
                                _durationStr = getFormattedDurationString();
                              } else {
                                _durationStr = '';
                              }
                              /** get duration ends */

                              /** get repeat */
                              _repeat = task.getRepeat();
                              repeatbefore = _repeat;
                              if (task.getFrequency() != null)
                                _selectedFrequencies = task.getFrequency().toSet();
                              else
                                _selectedFrequencies = new Set();
                              if (_repeat == -1)
                                _repeatStr = 'Repeat';
                              else
                                _repeatStr = repeatMsgs[_repeat];
                              /** get repeat ends */

                              /** get assigned users */
                              if (task.getAssignees() != null)
                                selectedUsers
                                    .addAll(task.getAssignees());
                              /** get assigned users ends */

                              _selectedType = task.getType();
                              typeOfTask = task.getType();

                              /** get due date time starts */
                              _selectedDate =
                                  task.getDue().toDate();
                              duebefore =
                                  task.getDue().toDate();
                              _selectedTime = new TimeOfDay(
                                  hour: _selectedDate.hour,
                                  minute: _selectedDate.minute);
                              /** get due date time ends */

                              /** get notes */
                              _notes = task.getNotes();
                              notescontroller.text = _notes;
                              /** get notes ends */

                              /** get remindIssue */
                              _isRemindMeOfIssueSelected =
                                  task.isRemindIssue();
                              /** get remindIssue ends */

                              /** get payment amount */
                              paymentAmountController.text =
                                  task.getPaymentAmount().toString();
                              /** get payment amount ends */

                              /** get payee */
                              _payee = task.getPayee();
                              payeecontroller.text =
                                  _payee == null ? '' : _payee;
                              /** get payee ends */

                              /** get next due date starts */
                              if (task.getNextDueDate() != null)
                                _nextDueDate =
                                    task.getNextDueDate()
                                        .toDate();
                              else
                                _nextDueDate =
                                    task.getNextDueDate()
                                        .toDate();
                              ;
                              /** get next due date ends */

                              _remind =
                                  task.isShouldRemindDaily();

                              initialized = true;

                              //return buildForm(snapshot.data);
                              /** data processed and assigned */
                            } else if (taskId == null) {
                              tc.text = "";
                              notescontroller.text = "";
                              payeecontroller.text = "";
                            }

                            return buildForm();
  }

  void saveTask() async {
    String errorMsg = _validateForm();
                if (errorMsg == '') {
                  debugPrint('Saved');
                  String taskTitle = tc.text.trim();
                  DateTime timeNow = DateTime.now();

                  String notestext = '';
                  if (notescontroller.text != null)
                    notestext = notescontroller.text.trim();

                  String payeetext = '';
                  if (payeecontroller.text != null)
                    payeetext = payeecontroller.text.trim();

                  String _time = "$_selectedTime".substring(10, 15);
                  String _date = "$_selectedDate.toLocal()".substring(0, 11);
                  _duedate = "$_date$_time" + ":00";
                  debugPrint("Due date is: $_duedate");
                  _due = DateTime.parse(_duedate);
                  debugPrint("Due date is: $_due");
                  DateTime temp = new DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      _selectedTime.hour,
                      _selectedTime.minute);
                  Timestamp duedatetime = Timestamp.fromDate(temp);
                  String _frequencies = (_selectedFrequencies == null)
                      ? ""
                      : _selectedFrequencies.toList().join(",");

                  double paymentAmount = (typeOfTask == 'Payment')
                      ? double.parse(paymentAmountController.text)
                      : 0.0;



                  Timestamp _nextNewDueDate;

                  if (taskId == null) {
                    _nextNewDueDate = Timestamp.fromDate(TaskService.getNextDueDateTime(
                        duedatetime.toDate(),
                        _repeat,
                        _frequencies));
                
                    Task task = getTaskObject(title: taskTitle, due: duedatetime, frequencies: _frequencies, notes: notestext, payee: payeetext, paymentAmount: paymentAmount, nextDueDate: _nextNewDueDate, createdBy: this.user.getUserId());
                    if (!ifAssignToUser) {
                      assignedFlatIds.remove('ALL');
                      WriteBatch batch = Firestore.instance.batch();
                      assignedFlatIds.forEach((doc) {
                        var docRef = Firestore.instance
                            .collection(globals.ownerTenantFlat)
                            .document(doc)
                            .collection(globals.tasksLandlord)
                            .document(); //automatically generate unique id
                        batch.setData(docRef, task.toJson());
                      });
                      await batch.commit();
                    } else {
                      Firestore.instance
                          .collection(globals.ownerTenantFlat)
                          .document(_flat.getOwnerTenantId())
                          .collection(globals.tasksLandlord)
                          .add(task.toJson());
                    }
                    if (_selectedFrequencies != null)
                      _selectedFrequencies.clear();
                    _repeat = -1;
                    Navigator.of(_navigatorContext).pop();
                  } else {
                    if (duebefore.compareTo(duedatetime.toDate()) != 0 ||
                        repeatbefore != _repeat) {
                      _nextNewDueDate = Timestamp.fromDate(TaskService.getNextDueDateTime(
                          duedatetime.toDate(),
                          _repeat,
                          _frequencies));
                    } else {
                      _nextNewDueDate = Timestamp.fromDate(_nextDueDate);
                    }

                    Task task = getTaskObject(title: taskTitle, due: duedatetime, frequencies: _frequencies, notes: notestext, payee: payeetext, paymentAmount: paymentAmount, nextDueDate: _nextNewDueDate, createdBy: this.createdBy, update: true);

                    
                    Firestore.instance
                        .collection(globals.ownerTenantFlat)
                        .document(_flat.getOwnerTenantId())
                        .collection(globals.tasksLandlord)
                        .document(taskId)
                        .updateData(task.toJson());

                    if (_selectedFrequencies != null)
                      _selectedFrequencies.clear();
                    _repeat = -1;
                    Navigator.of(_navigatorContext).pop();
                  }
                } else {
                  return showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Validation Error'),
                          content: Text(errorMsg),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      });
                }
  }

  void deleteTask() async {
    bool ifSuccess = await TaskDao.delete(_flat.getOwnerTenantId(), taskId);
                if(ifSuccess) {
                  Utility.createErrorSnackBar(_navigatorContext, error: "Success!");
                  Navigator.of(_navigatorContext).pop();
                }
  }

  Task getTaskObject({String title, Timestamp due, String frequencies, String notes, double paymentAmount, String payee, Timestamp nextDueDate, String createdBy, bool update: false}) {
    Task task = new Task();
    task.setTitle(title);
    task.setDue(due);
    task.setType(typeOfTask);
    task.setPriority(_selectedPriority == "Low" ? 0 : 1);
    task.setAssignees(selectedUsers.toList());
    task.setCreatedByUserId(createdBy);
    task.setFrequency(frequencies == "" || frequencies == null?List():frequencies.split(",").map(int.parse).toList());
    task.setRepeat(_repeat);
    task.setDuration(_duration);
    task.setNotes(notes);
    task.setRemindIssue(_isRemindMeOfIssueSelected);
    task.setPaymentAmount(paymentAmount);
    task.setPayee(payee);
    task.setNextDueDate(nextDueDate);
    task.setCompleted(false);
    task.setAssignedToFlat(!ifAssignToUser);
    task.setShouldRemindDaily(_selectedType == "Responsibility" ? false : _remind);
    task.setLandlordId(this.user.getUserId());
    task.setUpdatedAt(Timestamp.now());
    if(!update) task.setCreatedAt(Timestamp.now());
    return task;
  }
}

class RepeatDialog extends StatefulWidget {
  final Function callback;

  int repeatOps;
  Set<int> frequencies;

  RepeatDialog(this.callback, repeatOps, frequencies) {
    this.repeatOps = repeatOps;
    this.frequencies = frequencies;
  }

  @override
  State<StatefulWidget> createState() {
    return new _RepeatDialogState(repeatOps, frequencies);
  }
}

class _RepeatDialogState extends State<RepeatDialog> {
  var _repeatOps = new Map<String, int>();

  String _selectedDailyOp = "once a day";
  String _selectedWeeklyOp = "once a week";
  String _selectedMonthlyOp = "once a month";

  _RepeatDialogState(int repeatOps, Set frequencies) {
    _repeatOps["once a day"] = 0;
    _repeatOps["always available"] = 1;
    _repeatOps["once a week"] = 2;
    _repeatOps["on these days"] = 3;
    _repeatOps["once a month"] = 4;
    _repeatOps["on these dates"] = 5;
    if (repeatOps == 3 && frequencies != null) {
      _selectedWeekDays = Set.from(frequencies);
      _selectedFreq = 'Weekly';
      _selectedWeeklyOp = 'on these days';
    } else if (repeatOps == 5 && frequencies != null) {
      _selectedDates = Set.from(frequencies);
      _selectedFreq = 'Monthly';
      _selectedMonthlyOp = 'on these dates';
    } else if (repeatOps == 0) {
      _selectedFreq = 'Daily';
      _selectedDailyOp = 'once a day';
    } else if (repeatOps == 2) {
      _selectedFreq = 'Weekly';
      _selectedWeeklyOp = 'once a week';
    } else if (repeatOps == 4) {
      _selectedFreq = 'Monthly';
      _selectedMonthlyOp = 'once a month';
    } else {
      _selectedFreq = 'Daily';
      _selectedDailyOp = 'always available';
    }
  }

  //var _formKey1 = GlobalKey<FormState>();
  int _counter = 1;
  Set<int> selectedFrequency = new Set();

  String _selectedPriority = "Low";
  String _selectedFreq = "Daily";
  String _selectedUser = "User 1";
  static const _priorities = ["High", "Low"];
  static const _taskType = ["Responsibility", "Issue"];
  static const _taskFrequency = ["Once", "Daily", "Weekly", "Monthly"];
  static const _days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  static const _taskDaily = [
    "once a day",
    "always available",
  ];
  static const _taskWeekly = [
    "once a week",
    "on these days",
  ];
  static const _taskMonthly = [
    "once a month",
    "on these dates",
  ];

  Set<int> _selectedWeekDays = new Set();
  Set<int> _selectedDates = new Set();

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    return Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height / 2.3,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            ListTile(
              title: DropdownButton(
                  items: _taskFrequency.map((String dropdownStringItem) {
                    return DropdownMenuItem<String>(
                      value: dropdownStringItem,
                      child: Text(dropdownStringItem),
                    );
                  }).toList(),
                  style: textStyle,
                  value: _selectedFreq,
                  hint: Text('Frequency'),
                  onChanged: (valueSelected) {
                    setState(() {
                      debugPrint('User selected something');
                      _selectedFreq = valueSelected;
                    });
                  }),
            ),
//            Center(child: Text("every")),
//            Container(margin: EdgeInsets.all(10.0)),
//            Center(
//              child: Row(
//                children: <Widget>[
//                  Container(margin: EdgeInsets.all(5.0)),
//                  GestureDetector(
//                    child: Icon(Icons.minimize),
//                    onTap: () {
//                      setState(() {
//                        _counter--;
//                      });
//                    },
//                  ),
//                  Container(margin: EdgeInsets.all(5.0)),
//                  Text(_counter.toString()),
//                  Container(margin: EdgeInsets.all(5.0)),
//                  GestureDetector(
//                    child: Icon(Icons.add),
//                    onTap: () {
//                      setState(() {
//                        _counter++;
//                      });
//                    },
//                  ),
//                ],
//              ),
//            ),
            (_selectedFreq == 'Daily')
                ? _showDailyWidget(context)
                : (_selectedFreq == 'Weekly')
                    ? _showWeeklyWidget(context)
                    : (_selectedFreq == 'Monthly')
                        ? _showMonthlyWidget(context)
                        : Container(),
            Padding(
                padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      OutlineButton(
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0),
                            side: BorderSide(
                              width: 1.0,
                              color: Colors.indigo[900],
                            ),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          textColor: Colors.black,
                          child: Text('Save',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.0,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w700)),
                          onPressed: () {
                            debugPrint("in save");
                            if (_selectedDailyOp != 'always available') {
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Text(
                                          'Changing repeat will reset due date and time'),
                                      actions: <Widget>[
                                        OutlineButton(
                                          shape: new RoundedRectangleBorder(
                                            borderRadius:
                                                new BorderRadius.circular(10.0),
                                            side: BorderSide(
                                              width: 1.0,
                                              color: Colors.indigo[900],
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(8.0),
                                          textColor: Colors.black,
                                          child: Text('Continue',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14.0,
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w700)),
                                          onPressed: () {
                                            var repeat;
                                            if (_selectedFreq == 'Daily')
                                              repeat =
                                                  _repeatOps[_selectedDailyOp];
                                            else if (_selectedFreq ==
                                                'Weekly') {
                                              repeat =
                                                  _repeatOps[_selectedWeeklyOp];
                                              selectedFrequency =
                                                  _selectedWeekDays;
                                            } else if (_selectedFreq ==
                                                'Monthly') {
                                              repeat = _repeatOps[
                                                  _selectedMonthlyOp];
                                              selectedFrequency =
                                                  _selectedDates;
                                            } else if (_selectedFreq ==
                                                'Once') {
                                              repeat = -1;
                                            }

                                            this.widget.callback(
                                                selectedFrequency, repeat);

                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop();
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop();
                                          },
                                        ),
                                        OutlineButton(
                                          shape: new RoundedRectangleBorder(
                                            borderRadius:
                                                new BorderRadius.circular(10.0),
                                            side: BorderSide(
                                              width: 1.0,
                                              color: Colors.indigo[900],
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(8.0),
                                          textColor: Colors.black,
                                          child: Text('Cancel',
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 14.0,
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w700)),
                                          onPressed: () {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop();
                                          },
                                        ),
                                      ],
                                    );
                                  });
                            } else {
                              debugPrint("in else");
                              var repeat;
                              if (_selectedFreq == 'Daily')
                                repeat = _repeatOps[_selectedDailyOp];
                              else if (_selectedFreq == 'Weekly') {
                                repeat = _repeatOps[_selectedWeeklyOp];
                                selectedFrequency = _selectedWeekDays;
                              } else if (_selectedFreq == 'Monthly') {
                                repeat = _repeatOps[_selectedMonthlyOp];
                                selectedFrequency = _selectedDates;
                              } else if (_selectedFreq == 'Once') {
                                repeat = -1;
                              }

                              this.widget.callback(selectedFrequency, repeat);

                              Navigator.of(context, rootNavigator: true).pop();
                            }
                          }),
                      OutlineButton(
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0),
                            side: BorderSide(
                              width: 1.0,
                              color: Colors.indigo[900],
                            ),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          textColor: Colors.black,
                          child: Text('Cancel',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14.0,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w700)),
                          onPressed: () {
                            debugPrint("in cancel");

                            Navigator.of(context, rootNavigator: true).pop();
                          })
                    ]))
          ],
        ));
  }

  Widget _showDailyWidget(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: DropdownButton(
              items: _taskDaily.map((String dropdownStringItem) {
                return DropdownMenuItem<String>(
                  value: dropdownStringItem,
                  child: Text(dropdownStringItem),
                );
              }).toList(),
              value: _selectedDailyOp,
              onChanged: (valueSelected) {
                setState(() {
                  debugPrint('User selected something');
                  _selectedDailyOp = valueSelected;
                });
              }),
        ),
//        (_selectedDailyOp == "times per day")
//            ? Container(
//                width: double.maxFinite,
//                height: MediaQuery.of(context).size.height / 5.0,
//                child: ListView.builder(
//                    scrollDirection: Axis.horizontal,
//                    itemCount: 24,
//                    itemBuilder: (context, int position) {
//                      return CircleAvatar(
//                        child: Text(position.toString() + "x"),
//                      );
//                    }))
        Container(margin: EdgeInsets.all(10.0))
      ],
    );
  }

  Widget _showWeeklyWidget(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: DropdownButton(
              items: _taskWeekly.map((String dropdownStringItem) {
                return DropdownMenuItem<String>(
                  value: dropdownStringItem,
                  child: Text(dropdownStringItem),
                );
              }).toList(),
              value: _selectedWeeklyOp,
              onChanged: (valueSelected) {
                setState(() {
                  debugPrint('User selected something');
                  _selectedWeeklyOp = valueSelected;
                });
              }),
        ),
        (_selectedWeeklyOp == 'on these days')
            ? Container(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height / 5.0,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 7,
                    itemBuilder: (context, int position) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            var day = (position + 1);
                            if (_selectedWeekDays.contains(day))
                              _selectedWeekDays.remove(day);
                            else
                              _selectedWeekDays.add(day);
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.all(2.0),
                          child: CircleAvatar(
                            backgroundColor:
                                _selectedWeekDays.contains((position + 1))
                                    ? Colors.indigo[300]
                                    : Colors.indigo[100],
                            child: Text(
                              _days[position],
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12.0,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      );
                    }))
            : Container(margin: EdgeInsets.all(10.0))
      ],
    );
  }

  Widget _showMonthlyWidget(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: DropdownButton(
              items: _taskMonthly.map((String dropdownStringItem) {
                return DropdownMenuItem<String>(
                  value: dropdownStringItem,
                  child: Text(dropdownStringItem),
                );
              }).toList(),
              value: _selectedMonthlyOp,
              onChanged: (valueSelected) {
                setState(() {
                  debugPrint('User selected something');
                  _selectedMonthlyOp = valueSelected;
                });
              }),
        ),
        (_selectedMonthlyOp == 'on these dates')
            ? Container(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height / 5.6,
                child: GridView.count(
                    scrollDirection: Axis.horizontal,
                    crossAxisCount: 4,
                    children: List.generate(31, (position) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            var date = (position + 1);
                            if (_selectedDates.contains(date))
                              _selectedDates.remove(date);
                            else
                              _selectedDates.add(date);
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.all(3.0),
                          child: CircleAvatar(
                            backgroundColor:
                                _selectedDates.contains((position + 1))
                                    ? Colors.indigo[300]
                                    : Colors.indigo[100],
                            child: Text(
                              (position + 1).toString(),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12.0,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      );
                    })))
            : Container(margin: EdgeInsets.all(10.0))
      ],
    );
  }
}
