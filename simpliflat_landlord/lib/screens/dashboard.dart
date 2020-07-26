import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:simpliflat_landlord/screens/globals.dart' as globals;
import 'package:simpliflat_landlord/screens/tenant_portal/tenant_portal.dart';
import 'package:simpliflat_landlord/screens/tasks/view_task.dart';
import 'package:simpliflat_landlord/screens/utility.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:simpliflat_landlord/screens/widgets/common.dart';
import 'package:simpliflat_landlord/screens/widgets/loading_container.dart';
import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/services.dart';

class Dashboard extends StatefulWidget {
  final flatId;

  Dashboard(this.flatId);

  @override
  State<StatefulWidget> createState() {
    return DashboardState(this.flatId);
  }
}

class DashboardState extends State<Dashboard> {
  var _navigatorContext;
  final flatId;
  var currentUserId;
  bool noticesExist = false;
  bool tasksExist = false;
  List existingUsers;
  int usersCount;
  String landlordUserName;
  List landlordFlatList = new List();
  List flatNameList = new List();
  List readNoticeIds = new List();
  List readTaskIds = new List();

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

  int unreadNoticesCount = 0;
  bool unreadNoticesCountSet = false;
  int unreadTasksCount = 0;
  bool unreadTasksCountSet = false;

  Map<String, int> flatWiseNoticeLastSeens = new Map();

  Map<String, int> flatWiseTaskLastSeens = new Map();

  Map<String, int> readNoticesCount = new Map();

  Map<String, int> readTasksCount = new Map();

  Map<String, String> flatIdNameMap = new Map();

  Map<String, Map> flatIdentifierData = new Map();

  String flatName;

  var _progressCircleState = 0;

  var _isButtonDisabled = false;

  DashboardState(this.flatId);

  @override
  void initState() {
    super.initState();
    _buttonColor = Colors.blue;
    debugPrint("in init");
    Utility.getUserId().then((id) {
      debugPrint("id == " + id);
      if (id == null || id == "") {
      } else {
        if (mounted) {
          setState(() {
            currentUserId = id;
          });
        }
      }
    });
    Utility.getFlatName().then((name) {
      if (name == null) {
        if (mounted) {
          setState(() {
            flatName = "Flat";
          });
        }
      } else {
        if (mounted) {
          setState(() {
            flatName = name;
          });
        }
      }
    });
    Utility.getUserName().then((name) {
      if (name != null && name != '') {
        if (mounted) {
          setState(() {
            landlordUserName = name;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            landlordUserName = 'Landlord';
          });
        }
      }
    });
    Utility.getFlatIdList().then((flatList) {
      List tempid = new List();
      List tempname = new List();
      for (String id in flatList) {
        if (id.contains("Name=")) {
          tempid.add(id.split("Name=")[0]);
          tempname.add(id.split("Name=")[1]);
          flatIdNameMap[id.split("Name=")[0]] = id.split("Name=")[1];
        } else {
          tempid.add(id);
          flatIdNameMap[id] = "Flat";
        }
      }
      if (mounted) {
        setState(() {
          landlordFlatList = tempid;
          flatNameList = tempname;
        });
      }
      landlordFlatList = tempid;

      for (int i = 0; i < landlordFlatList.length; i++) {
        debugPrint(landlordFlatList[i].toString());
      }
      Map<String, int> flatWiseNoticeLastSeensTemp = new Map();
      Map<String, int> flatWiseTaskLastSeensTemp = new Map();
      for (int i = 0; i < landlordFlatList.length; i++) {
        flatWiseNoticeLastSeensTemp[landlordFlatList[i]] = 0;
        readNoticesCount[landlordFlatList[i]] = 0;
        flatWiseTaskLastSeensTemp[landlordFlatList[i]] = 0;
        readTasksCount[landlordFlatList[i]] = 0;
      }

      Utility.getReadNoticesLastSeen().then((notices) {
        if (notices != null) {
          for (int i = 0; i < notices.length; i++) {
            debugPrint('notices ===== ' + notices[i]['flatId'].toString());
            flatWiseNoticeLastSeensTemp[notices[i]['flatId']] =
                (notices[i]['lastSeen'] as int);
          }
        }
        if (mounted) {
          setState(() {
            flatWiseNoticeLastSeens = flatWiseNoticeLastSeensTemp;
          });
        }
      });

      Utility.getReadTasksLastSeen().then((tasks) {
        if (tasks != null) {
          for (int i = 0; i < tasks.length; i++) {
            flatWiseTaskLastSeensTemp[tasks[i]['flatId']] =
                (tasks[i]['lastSeen'] as int);
          }
        }

        String temp = Timestamp.fromMillisecondsSinceEpoch(
                flatWiseTaskLastSeensTemp['gbvVAkwNtY6FOvhXtCDu'] as int)
            .toDate()
            .toIso8601String();
        debugPrint("lastseen for flat:" + temp);
        if (mounted) {
          setState(() {
            flatWiseTaskLastSeens = flatWiseTaskLastSeensTemp;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _moveToLastScreen(context);
        return null;
      },
      child: Scaffold(
        body: Builder(builder: (BuildContext scaffoldC) {
          _navigatorContext = scaffoldC;
          return new SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 30.0,
                ),
                flatNameWidget(),
                SizedBox(
                  height: 30.0,
                ),

                // Today's Items

                getStatistics(),
                SizedBox(
                  height: 20.0,
                ),

                getNewRequestsWidget(),

                SizedBox(
                  height: 20.0,
                ),
                // Today's Items

                getTasks(),
                SizedBox(
                  height: 20.0,
                ),

                getNotices(),
              ],
            ),
          );
        }),
      ),
    );
  }

  Map<String, String> pendingRequestsFlatNameIdList = new Map();

  Future<dynamic> getNewRequests() async {
    List<DocumentSnapshot> listOfPendingRequests = new List();

    debugPrint(" current user id = " + currentUserId);

    QuerySnapshot a = await Firestore.instance
        .collection(globals.requests)
        .where("user_id", isEqualTo: currentUserId)
        .where("status", isEqualTo: 0)
        .getDocuments();

    listOfPendingRequests.addAll(a.documents);

    for (int i = 0; i < listOfPendingRequests.length; i++) {
      debugPrint("in loop = " + listOfPendingRequests[i].data['flat_id']);
    }

    await Firestore.instance.runTransaction((transaction) async {
      for (int i = 0; i < listOfPendingRequests.length; i++) {
        debugPrint("flat in loop = " +
            listOfPendingRequests[i].data['flat_id'].toString());
        DocumentReference flat = Firestore.instance
            .collection(globals.flat)
            .document(listOfPendingRequests[i].data['flat_id']);
        DocumentSnapshot d = await flat.get();
        debugPrint("in another loop = " + d.data['name']);
        pendingRequestsFlatNameIdList[
            listOfPendingRequests[i].data['flat_id']] = d.data['name'];
        flatIdentifierData[listOfPendingRequests[i].data['flat_id']] = {
          'apartment_name': d.data['apartment_name'],
          'apartment_number': d.data['apartment_number'],
          'zipcode': d.data['zipcode']
        };
      }
    });

    return listOfPendingRequests;
  }

  Widget getNewRequestsWidget() {
    if (landlordFlatList == null ||
        landlordFlatList.isEmpty ||
        currentUserId == null ||
        currentUserId == '') return LoadingContainerVertical(2);
    return FutureBuilder(
      future: getNewRequests(),
      builder: (context, AsyncSnapshot<dynamic> documents) {
        if (!documents.hasData) {
          return LoadingContainerVertical(2);
        }

        return ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: documents.data.length,
          itemBuilder: (context, position) {
            return getRequestTile(
                context, position, documents.data[position], documents);
            // return ListTile(
            //   title: Text(pendingRequestsFlatNameIdList[documents.data[position]['flat_id']]),
            // );
          },
        );
      },
    );
  }

  Widget getRequestTile(BuildContext context, int index,
      DocumentSnapshot document, AsyncSnapshot<dynamic> documents) {
    debugPrint("flat name = " + document['flat_id']);
    return Container(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        child: Card(
            color: Colors.white,
            elevation: 1.0,
            child: Dismissible(
              key: ObjectKey(document['flat_id']),
              background: swipeBackground(),
              onDismissed: (direction) {
                String request = document['flat_id'];
                setState(() {
                  (documents.data as List).removeAt(index);
                });
                _respondToJoinRequest(context, request, -1);
              },
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    pendingRequestsFlatNameIdList[document['flat_id']],
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
                subtitle: getFlatIdentifierTextWidget(document['flat_id']),
                trailing: ButtonTheme(
                    height: 25.0,
                    minWidth: 30.0,
                    child: RaisedButton(
                        elevation: 0.0,
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                          side: BorderSide(
                            width: 1.0,
                            color: Colors.black,
                          ),
                        ),
                        color: Colors.white,
                        textColor: Theme.of(context).primaryColorDark,
                        child: (_progressCircleState == 0)
                            ? setUpButtonChild("Accept")
                            : setUpButtonChild("Waiting"),
                        onPressed: () {
                          if (_isButtonDisabled == false) {
                            setState(() {
                              _progressCircleState = 1;
                            });
                            _respondToJoinRequest(
                                context, document['flat_id'], 1);
                          } else {
                            setState(() {
                              _progressCircleState = 1;
                            });
                            Utility.createErrorSnackBar(context,
                                error: "Waiting for Request Call to Complete!");
                          }
                        })),
              ),
            )),
      ),
    );
  }

  Widget getFlatIdentifierTextWidget(String displayId) {
    if (flatIdentifierData == null ||
        !flatIdentifierData.containsKey(displayId)) {
      return Text('');
    }
    String text = '';
    if (flatIdentifierData[displayId]['apartment_name'] != null &&
        flatIdentifierData[displayId]['apartment_name'] != '')
      text = text + flatIdentifierData[displayId]['apartment_name'] + ', ';

    if (flatIdentifierData[displayId]['apartment_number'] != null &&
        flatIdentifierData[displayId]['apartment_number'] != '')
      text = text + flatIdentifierData[displayId]['apartment_number'] + ', ';

    if (flatIdentifierData[displayId]['zipcode'] != null &&
        flatIdentifierData[displayId]['zipcode'] != '')
      text = text + flatIdentifierData[displayId]['zipcode'];

    text = text.trim();
    if (text.endsWith(", ")) {
      text = text.substring(0, text.length - 1);
    }

    return Text(text);
  }

  var _buttonColor;

  void _respondToJoinRequest(scaffoldContext, flatId, didAccept) async {
    setState(() {
      _buttonColor = Colors.lightBlueAccent;
      _isButtonDisabled = true;
    });
    var userId = currentUserId;
    List landlordFlatList1 = await Utility.getFlatIdList();
    List flatListOnly = new List();
    for (String id in landlordFlatList1) {
      if (id.contains("Name="))
        flatListOnly.add(id.split("Name=")[0]);
      else
        flatListOnly.add(id);
    }
    var timeNow = DateTime.now();

    var flatName = pendingRequestsFlatNameIdList[flatId];
    //check if we have a request from this flat
    if (didAccept == 1) {
      Firestore.instance
          .collection(globals.requests)
          .where("user_id", isEqualTo: userId)
          .where("flat_id", isEqualTo: flatId)
          .where("request_from_flat", isEqualTo: 1)
          .limit(1)
          .getDocuments()
          .then((incomingReq) {
        var now = new DateTime.now();
        if (incomingReq.documents != null &&
            incomingReq.documents.length != 0) {
          List<DocumentReference> toRejectList = new List();
          DocumentReference toAccept;
          debugPrint("FLAT REQUEST TO USER EXISTS!");

          // accept current request
          Firestore.instance
              .collection(globals.requests)
              .where("user_id", isEqualTo: userId)
              .where("flat_id", isEqualTo: flatId)
              .where("request_from_flat", isEqualTo: 1)
              .getDocuments()
              .then((toAcceptData) async {
            if (toAcceptData.documents != null &&
                toAcceptData.documents.length != 0) {
              toAccept = Firestore.instance
                  .collection(globals.requests)
                  .document(toAcceptData.documents[0].documentID);
            }
            //perform actual batch operations
            var batch = Firestore.instance.batch();
            for (int i = 0; i < toRejectList.length; i++) {
              batch.updateData(
                  toRejectList[i], {'status': -1, 'updated_at': timeNow});
            }
            batch.updateData(toAccept, {'status': 1, 'updated_at': timeNow});

            //update user
            flatListOnly.add(flatId.toString().trim());
            var userRef = Firestore.instance
                .collection(globals.landlord)
                .document(userId);
            batch.updateData(userRef, {'flat_id': flatListOnly});

            // to store flat id with name in shared preferences
            List landlordFlatListWithName = landlordFlatList1;
            landlordFlatListWithName.add(flatId.toString().trim() +
                "Name=" +
                flatName.toString().trim());

            //update flat landlord
            var flatRef =
                Firestore.instance.collection(globals.flat).document(flatId);
            batch.updateData(flatRef, {'landlord_id': userId});

            batch.commit().then((res) {
              debugPrint("ADDED TO FLAT");
              Utility.addToSharedPref(
                  flatIdDefault: flatId,
                  flatName: flatName,
                  flatIdList: landlordFlatListWithName);
              setState(() {
                _isButtonDisabled = false;
                debugPrint("CALL SUCCCESS");
              });
            }, onError: (e) {
              _setErrorState(scaffoldContext, "CALL ERROR");
            }).catchError((e) {
              _setErrorState(scaffoldContext, "SERVER ERROR");
            });
          }, onError: (e) {
            _setErrorState(scaffoldContext, "CALL ERROR");
          }).catchError((e) {
            _setErrorState(scaffoldContext, "SERVER ERROR");
          });
        }
      });
    } else if (didAccept == -1) {
      DocumentReference toReject;
      Firestore.instance
          .collection(globals.requests)
          .where("user_id", isEqualTo: userId)
          .where("flat_id", isEqualTo: flatId)
          .where("request_from_flat", isEqualTo: 1)
          .getDocuments()
          .then((toRejectData) {
        if (toRejectData.documents != null &&
            toRejectData.documents.length != 0) {
          toReject = Firestore.instance
              .collection(globals.requests)
              .document(toRejectData.documents[0].documentID);
        }
        //perform actual batch operations
        var batch = Firestore.instance.batch();

        batch.updateData(toReject, {'status': -1, 'updated_at': timeNow});

        batch.commit().then((res) {
          setState(() {
            _isButtonDisabled = false;
          });
        }, onError: (e) {
          _setErrorState(scaffoldContext, "CALL ERROR");
        }).catchError((e) {
          _setErrorState(scaffoldContext, "SERVER ERROR");
        });
      });
    }
  }

  void _setErrorState(scaffoldContext, error, {textToSend}) {
    setState(() {
      _isButtonDisabled = false;
      debugPrint(error);
      if (textToSend != null && textToSend != "")
        Utility.createErrorSnackBar(scaffoldContext, error: textToSend);
      else
        Utility.createErrorSnackBar(scaffoldContext);
    });
  }

  Widget swipeBackground() {
    return Container(
      color: Colors.red[600],
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(),
          ),
          Expanded(
            flex: 5,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
                Expanded(
                  flex: 1,
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                Expanded(
                  flex: 10,
                  child: Container(),
                ),
                Expanded(
                  flex: 1,
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(),
          ),
        ],
      ),
    );
  }

  Widget setUpButtonChild(buttonText) {
    if (_progressCircleState == 0) {
      return new Text(
        buttonText,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 10.0,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w700,
        ),
      );
    } else if (_progressCircleState == 1) {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
      );
    } else {
      return Icon(Icons.check, color: Colors.black);
    }
  }

  Widget flatNameWidget() {
    if (flatName == null) {
      return CircularProgressIndicator();
    }
    // return FutureBuilder (
    //   future: Utility.getFlatName(),
    //   builder: (context, snapshot) {
    //     if(!snapshot.hasData) return LoadingContainerVertical(1);
    return Text(
      flatName,
      style: TextStyle(
        color: Colors.indigo[400],
        fontSize: 30.0,
        fontFamily: 'Montserrat',
      ),
    );
    //  });
  }

  Stream<List<QuerySnapshot>> getTasksAndNotices(flatid) {
    Stream stream1 = Firestore.instance
        .collection(globals.flat)
        .document(flatId)
        .collection("tasks_landlord")
        .where("landlord_id", isEqualTo: currentUserId)
        .where("completed", isEqualTo: false)
        .snapshots();
    Stream stream2 = Firestore.instance
        .collection(globals.flat)
        .document(flatId)
        .collection(globals.messageBoard)
        .snapshots();

    return StreamZip([stream1, stream2]);
  }

  Widget getUnreadNoticesWidget(int position) {
    if (flatWiseNoticeLastSeens.isEmpty)
      return SpinKitRotatingPlain(
        color: Colors.grey,
        size: 5.0,
      );
    return StreamBuilder(
      stream: Firestore.instance
          .collection(globals.flat)
          .document(landlordFlatList[position])
          .collection(globals.messageBoard)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        debugPrint("flat id now in notices: " + flatId);
        if (!snapshot.hasData) return CircularProgressIndicator();

        List<DocumentSnapshot> allNotices = snapshot.data.documents;
        for (int i = 0; i < flatWiseNoticeLastSeens.length; i++) {
          flatWiseNoticeLastSeens.forEach((elem, milli) {
            debugPrint("flat_id - " + elem + ' milli - ' + milli.toString());
          });
        }
        Timestamp lastSeen;
        int millisecondsSinceEpoch =
            flatWiseNoticeLastSeens[landlordFlatList[position]];
        debugPrint("milli = " + millisecondsSinceEpoch.toString());
        if (millisecondsSinceEpoch == 0) {
          lastSeen = Timestamp.now();
        } else {
          lastSeen =
              Timestamp.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
        }
        int noticesCount = 0;
        if (allNotices.isNotEmpty)
          noticesCount = setUnreadNoticesCount(allNotices, lastSeen);
        else
          noticesCount = 0;

        readNoticesCount[landlordFlatList[position]] = noticesCount;
        return Text(noticesCount.toString());
      },
    );
  }

  Widget getUnreadTasksWidget(int position) {
    if (flatWiseTaskLastSeens.isEmpty)
      return SpinKitRotatingPlain(
        color: Colors.grey,
        size: 5.0,
      );
    return StreamBuilder(
      stream: Firestore.instance
          .collection(globals.flat)
          .document(landlordFlatList[position])
          .collection("tasks_landlord")
          .where("landlord_id", isEqualTo: currentUserId)
          .where("completed", isEqualTo: false)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        debugPrint("flat id now in tasks: " +
            flatId +
            " and current user id: " +
            currentUserId);

        if (!snapshot.hasData) return CircularProgressIndicator();

        List<DocumentSnapshot> allTasks = snapshot.data.documents;

        int tasksCount = 0;

        Timestamp lastSeen;
        int millisecondsSinceEpoch =
            flatWiseTaskLastSeens[landlordFlatList[position]];
        if (millisecondsSinceEpoch == 0) {
          lastSeen = Timestamp.now();
        } else {
          lastSeen =
              Timestamp.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
        }

        if (allTasks.isNotEmpty)
          tasksCount = setUnreadTasksCount(allTasks, lastSeen);
        else
          tasksCount = 0;

        readTasksCount[landlordFlatList[position]] = tasksCount;
        return Text(tasksCount.toString());
      },
    );
  }

  Widget getStatistics() {
    debugPrint("in get statistics");
    if (landlordFlatList == null) {
      debugPrint("landlordflatlist is null");
    }
    if (landlordFlatList != null && landlordFlatList.isEmpty) {
      debugPrint("landlordflatlist is empty");
    }
    if (currentUserId == null) {
      debugPrint("currentuserid is null");
    }
    if (flatNameList == null) {
      debugPrint("flatnamelist is null");
    }
    if (flatNameList != null && flatNameList.isEmpty) {
      debugPrint("flatNameList is empty");
    }
    if (landlordFlatList == null ||
        landlordFlatList.isEmpty ||
        currentUserId == null) {
      return LoadingContainerVertical(2);
    } else if ((landlordFlatList != null &&
            landlordFlatList.isNotEmpty &&
            currentUserId != null) &&
        (flatNameList == null || flatNameList.isEmpty)) {
      return Container();
    }
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.0),
      child: Card(
        child: ListView.separated(
          separatorBuilder: (context, index) {
            return Divider(height: 1.0);
          },
          itemCount: landlordFlatList.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemBuilder: (context, position) {
            return ListTile(
              title: Text(flatNameList[position]),
              subtitle: Row(
                children: [
                  Text('Unread Notices: '),
                  getUnreadNoticesWidget(position),
                  Text('     Unread Tasks: '),
                  getUnreadTasksWidget(position)
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<dynamic> getLandlordNameAndId() async {
    String flatNameTemp = await Utility.getUserName();
    String flatIdTemp = await Utility.getUserId();
    return {'id': flatIdTemp, 'name': flatNameTemp};
  }

  // Get Tasks data for today
  Widget getTasks() {
    if (currentUserId == null) return LoadingContainerVertical(2);

    var date = DateFormat("yyyy-MM-dd");
    // return FutureBuilder(
    //       future: getLandlordNameAndId(),
    //       builder: (context, snapshot) {
    //         if(!snapshot.hasData) return LoadingContainerVertical(1);

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
                  .collection("tasks_landlord")
                  .where("landlord_id", isEqualTo: currentUserId)
                  .where("completed", isEqualTo: false)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> taskSnapshot) {
                if (!taskSnapshot.hasData) return LoadingContainerVertical(3);

                taskSnapshot.data.documents.sort(
                    (DocumentSnapshot a, DocumentSnapshot b) => int.parse(b
                        .data['nextDueDate']
                        .compareTo(a.data['nextDueDate'])
                        .toString()));

                taskSnapshot.data.documents.removeWhere((data) =>
                    date.format((data['nextDueDate'] as Timestamp).toDate()) !=
                    date.format(DateTime.now().toLocal()));

                taskSnapshot.data.documents.removeWhere((s) => !s
                    .data['assignee']
                    .toString()
                    .contains(currentUserId.trim()));

                /// TASK LIST VIEW
                var tooltipKey = new List();
                for (int i = 0; i < taskSnapshot.data.documents.length; i++) {
                  tooltipKey.add(GlobalKey());
                }

                return Column(children: [
                  taskSnapshot.data.documents.length > 0
                      ? Text(
                          'Tasks for you today',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                          ),
                        )
                      : Container(),
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
                            child: Card(
                              color: Colors.white,
                              elevation: 2.0,
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
                                trailing: getUsersAssignedView(
                                    taskSnapshot.data.documents[position]
                                        ["assignee"],
                                    snapshot1),
                                onTap: () {
                                  navigateToViewTask(
                                      taskId: taskSnapshot
                                          .data.documents[position].documentID);
                                },
                              ),
                            ),
                          ));
                    },
                  ),
                ]);
              });
        });
    // });
  }

  Widget getUsersAssignedView(users, AsyncSnapshot<QuerySnapshot> snapshot1) {
    //get user color id
    List userList = users.toString().trim().split(';');
    var overflowAddition = 0.0;
    if (userList.length > 3) overflowAddition = 8.0;

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
    List<String> userList = users.toString().trim().split(',').toList();
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
    if (userList.contains(currentUserId)) {
      var colorL = currentUserId.toString().trim().hashCode;

      overlappingUsers.add(new Positioned(
        right: (availableUsers * 20) + overflowAddition,
        child: new CircleAvatar(
          maxRadius: 14.0,
          backgroundColor: Colors.primaries[colorL % Colors.primaries.length]
              [300],
          child: Text(landlordUserName[0]),
        ),
      ));
    }
    return overlappingUsers;
  }

  String getInitial(documentId, flatUsers) {
    for (int i = 0; i < flatUsers.length; i++) {
      if (flatUsers[i].documentID == documentId) {
        return flatUsers[i].data['name'][0];
      }
    }
    return '';
  }

  /// TODO: Change taskList code to store names along with user id in array. Then change this hardcoded values to show those.

  void navigateToViewTask({taskId}) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return ViewTask(taskId, flatId, currentUserId, landlordUserName);
      }),
    );
  }

  int setUnreadNoticesCount(
      List<DocumentSnapshot> notices, Timestamp timestamp) {
    unreadNoticesCount = 0;
    for (int i = 0; i < notices.length; i++) {
      if ((notices[i].data['updated_at'] as Timestamp).compareTo(timestamp) >
          0) {
        unreadNoticesCount++;
      }
    }

    // setState(() {
    //       unreadNoticesCount = unreadNoticesCount;
    //       unreadNoticesCountSet = true;
    //     });

    return unreadNoticesCount;
  }

  int setUnreadTasksCount(List<DocumentSnapshot> tasks, Timestamp timestamp) {
    unreadTasksCount = 0;
    for (int i = 0; i < tasks.length; i++) {
      debugPrint("---------- " + tasks[i].data['title']);
      debugPrint((tasks[i].data['updated_at'] as Timestamp)
          .toDate()
          .toIso8601String());
      debugPrint((timestamp).toDate().toIso8601String());

      if ((tasks[i].data['updated_at'] as Timestamp).compareTo(timestamp) > 0) {
        unreadTasksCount++;
      }
    }

    // setState(() {
    //       unreadTasksCount = unreadTasksCount;
    //       unreadTasksCountSet = true;
    //     });

    return unreadTasksCount;
  }

  // Get NoticeBoard data
  Widget getNotices() {
    var date = DateFormat("yyyy-MM-dd");
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection(globals.flat)
          .document(flatId)
          .collection(globals.messageBoard)
          //.where('updated_at', isGreaterThanOrEqualTo: date.format(DateTime.now().toLocal()))
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> notesSnapshot) {
        if (!notesSnapshot.hasData ||
            currentUserId == null ||
            currentUserId == "") return LoadingContainerVertical(3);

        List<DocumentSnapshot> notices1 =
            List.from(notesSnapshot.data.documents);
        notesSnapshot.data.documents
            .sort((a, b) => b['updated_at'].compareTo(a['updated_at']));
        notesSnapshot.data.documents.removeWhere((data) =>
            date.format((data['updated_at'] as Timestamp).toDate()) !=
            date.format(DateTime.now().toLocal()));
        if (notesSnapshot.data.documents.length > 0) {
          noticesExist = true;
        } else {
          noticesExist = false;
        }
        return Column(children: [
          notesSnapshot.data.documents.length > 0
              ? Text(
                  'Notices today',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                  ),
                )
              : Container(),
          ListView.builder(
              itemCount: notesSnapshot.data.documents.length,
              key: UniqueKey(),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int position) {
                return _buildNoticeListItem(
                    notesSnapshot.data.documents[position], position);
              }),
        ]);
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
        width: MediaQuery.of(context).size.width * 0.85,
        child: Card(
          color: Colors.white,
          elevation: 1.0,
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
