import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/screens/globals.dart' as globals;
import 'package:simpliflat_landlord/screens/tenant_portal/tenant_portal.dart';
import '../../main.dart';
import '../utility.dart';
import 'create_flat.dart';

class CreateOrJoin extends StatefulWidget {
  var requestDenied;
  var lastRequestStatus;
  List incomingRequests;
  Color ccard, ctext;
  var userId;
  Map<String, Map> flatIdentifierData;

  CreateOrJoin(requestDenied, incomingRequests, flatIdentifierData) {
    this.requestDenied = requestDenied;
    this.incomingRequests = incomingRequests;
    this.flatIdentifierData = flatIdentifierData;
    if (requestDenied == -1) {
      lastRequestStatus = "Your last join request was denied!";
      ccard = Colors.red[100];
      ctext = Colors.red[600];
    } else if (requestDenied == 0) {
      lastRequestStatus =
          "Your last request is pending. Wait or join new flat.";
      ccard = Colors.purple[100];
      ctext = Colors.purple[600];
    } else {
      lastRequestStatus =
          "Lets get started! You can only be in one flat at a time";
      ccard = Colors.white;
      ctext = Colors.indigo[900];
    }
  }

  @override
  State<StatefulWidget> createState() {
    return _CreateOrJoinBody(
        lastRequestStatus, ccard, ctext, incomingRequests, flatIdentifierData);
  }
}

class _CreateOrJoinBody extends State<CreateOrJoin> {
  String lastRequestStatus;
  var _progressCircleState = 0;
  Color ccard, ctext;
  List incomingRequests;
  BuildContext scaffoldContext;
  var _isButtonDisabled = false;
  var flatId;
  Map<String, Map> flatIdentifierData;

  var _buttonColor;

  _CreateOrJoinBody(this.lastRequestStatus, this.ccard, this.ctext,
      this.incomingRequests, this.flatIdentifierData);

  @override
  void initState() {
    super.initState();
    _buttonColor = Colors.blue;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<dynamic> _handleRefresh() async {
    var userId = await Utility.getUserId();
    var flatId;
    _checkFlatAccept();
    return Firestore.instance
        .collection(globals.requests)
        .where("user_id", isEqualTo: userId)
        .getDocuments()
        .then((requests) {
      debugPrint("AFTER JOIN REQ");
      if (requests.documents != null && requests.documents.length != 0) {
        bool userRequested = false;
        String statusForUserReq = "";
        List<String> incomingRequestsTemp = new List<String>();

        List<FlatIncomingReq> flatIdGetDisplay = new List();
        requests.documents.sort((a, b) =>
            a.data['updated_at'].compareTo(b.data['updated_at']) > 0 ? 1 : -1);
        for (int i = 0; i < requests.documents.length; i++) {
          debugPrint("doc + " + requests.documents[i].documentID);
          var data = requests.documents[i].data;
          var reqFlatId = data['flat_id'];
          var reqStatus = data['status'];
          var reqFromFlat = data['request_from_flat'];

          if (reqFromFlat.toString() == "0") {
            userRequested = true;
            statusForUserReq = reqStatus.toString();
            flatId = reqFlatId.toString();
          } else {
            // case where flat made a request to add user
            // show all these flats to user on next screen - Create or join
            debugPrint(reqFlatId);
            if (reqStatus.toString() == "0")
              flatIdGetDisplay.add(FlatIncomingReq(
                  Firestore.instance
                      .collection(globals.flat)
                      .document(reqFlatId),
                  ''));
          }
        }

        //get Display IDs for flats with incoming requests
        Firestore.instance.runTransaction((transaction) async {
          for (int i = 0; i < flatIdGetDisplay.length; i++) {
            DocumentSnapshot flatData =
                await transaction.get(flatIdGetDisplay[i].ref);
            if (flatData.exists) {
              flatIdGetDisplay[i].displayId = flatData.data['display_id'];
              debugPrint("display id - " +
                  flatData.data['display_id'] +
                  ' zipcode - ' +
                  flatData.data['zipcode']);
              flatIdentifierData[flatData.data['display_id']] = {
                'apartment_name': flatData.data['apartment_name'],
                'apartment_number': flatData.data['apartment_number'],
                'zipcode': flatData.data['zipcode']
              };
            }
          }
        }).whenComplete(() {
          debugPrint("IN WHEN COMPLETE TRANSACTION");
          for (int i = 0; i < flatIdGetDisplay.length; i++) {
            incomingRequestsTemp.add(flatIdGetDisplay[i].displayId);
          }
          debugPrint(' if incoming requests empty - ' +
              (incomingRequestsTemp == null || incomingRequestsTemp.isEmpty)
                  .toString());
          setState(() {
            incomingRequests = incomingRequestsTemp;
            flatIdentifierData = flatIdentifierData;
          });
          debugPrint("IN NAVIGATE");
          debugPrint(incomingRequestsTemp.length.toString());
          if (userRequested) {
            userId = userId.toString();
            flatId = flatId.toString();
            if (statusForUserReq == "1") {
              List flatList = new List();
              flatList.add(flatId.toString().trim());
              Utility.addToSharedPref(
                  flatIdDefault: flatId, flatIdList: flatList);
              _navigateToHome(flatId);
            } else if (statusForUserReq == "-1") {
              setState(() {
                lastRequestStatus = "Your last join request was denied!";
              });
            } else {
              setState(() {
                lastRequestStatus =
                    "Your last request is pending. Wait or join new flat.";
              });
            }
          } else {
            setState(() {
              lastRequestStatus = "Lets get started! You can add flat's here";
            });
          }
        }).catchError((e) {
          debugPrint("SERVER TRANSACTION ERROR");
          Utility.createErrorSnackBar(scaffoldContext);
        });
      } else {
        debugPrint("IN ELSE FLAT NULL");
        setState(() {
          lastRequestStatus = "Lets get started! You can add flat's here";
        });
      }
    }, onError: (e) {
      debugPrint("CALL ERROR");
      Utility.createErrorSnackBar(scaffoldContext);
    }).catchError((e) {
      debugPrint("SERVER ERROR");
      debugPrint(e.toString());
      Utility.createErrorSnackBar(scaffoldContext);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (flatId == null) _checkFlatAccept();
    var deviceSize = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text("Find a Flat"),
          elevation: 0.0,
        ),
        body: Builder(builder: (BuildContext scaffoldC) {
          scaffoldContext = scaffoldC;
          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 90.0,
                    width: deviceSize.width * 0.95,
                    child: Card(
                        color: ccard,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: (ccard == Colors.white)
                              ? Text(lastRequestStatus,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: 'Montserrat', color: ctext))
                              : ListTile(
                                  leading: Icon(
                                    Icons.warning,
                                    color: ctext,
                                  ),
                                  title: Text(
                                    lastRequestStatus,
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: ctext,
                                    ),
                                  ),
                                ),
                        )),
                  ),
                ),
                Container(margin: EdgeInsets.all(10.0)),
                SizedBox(
                    height: 185,
                    width: deviceSize.width * 0.88,
                    child: GestureDetector(
                      onTap: () {
                        navigateToCreate(context, 1).then((flag) {
                          setState(() {
                            if (flag == 0) {
                              lastRequestStatus =
                                  "Your last request is pending. wait or join new flat.";
                              ccard = Colors.purple[100];
                              ctext = Colors.purple[700];
                            }
                          });
                        });
                      },
                      child: new Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          color: Colors.black87,
                          elevation: 2.0,
                          child: Container(
                            width: deviceSize.width * 0.88,
                            decoration: BoxDecoration(
                              // Box decoration takes a gradient
                              gradient: LinearGradient(
                                // Where the linear gradient begins and ends
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                // Add one stop for each color. Stops should increase from 0 to 1
                                stops: [0.1, 0.5, 0.7, 0.9],
                                colors: [
                                  // Colors are easy thanks to Flutter's Colors class.
                                  Colors.indigo[800],
                                  Colors.indigo[700],
                                  Colors.indigo[600],
                                  Colors.indigo[400],
                                ],
                              ),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  textInCard("Join a Flat", FontWeight.w700,
                                      24.0, 28.0, 40.0),
                                  textInCard("Search for your flat", null, 14.0,
                                      28.0, 20.0),
                                  textInCard("and send a request.", null, 14.0,
                                      28.0, 7.0),
                                ]),
                          )),
                    )),
                Container(
                  margin: EdgeInsets.all(10.0),
                ),
                Container(
                  child: ListTile(
                      title: Text(
                        "Invite Tenants to join",
                      ),
                      leading: GestureDetector(
                        child: Icon(
                          Icons.share,
                          color: Colors.indigo[900],
                        ),
                      ),
                      onTap: () {
                        Share.share('Hey please install Simplitflat',
                            subject: 'Check out Simpliflat!');
                      }),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                ),
                Row(
                  children:
                      (incomingRequests == null || incomingRequests.length == 0)
                          ? <Widget>[Container(margin: EdgeInsets.all(5.0))]
                          : <Widget>[
                              Expanded(child: Container()),
                              Text("Incoming Requests",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontFamily: 'Montserrat',
                                      color: Colors.black)),
                              Expanded(flex: 15, child: Container()),
                            ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0),
                  child: Container(
                    height: (incomingRequests == null ||
                            incomingRequests.length == 0)
                        ? 5.0
                        : MediaQuery.of(context).size.height / 2,
                    child: (incomingRequests == null ||
                            incomingRequests.length == 0)
                        ? null
                        : new ListView.builder(
                            itemCount: incomingRequests.length,
                            itemBuilder: (BuildContext context, int index) =>
                                buildIncomingRequests(context, index)),
                  ),
                ),
              ],
            ),
          );
        }));
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

  //build incoming flat requests list
  Widget buildIncomingRequests(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        child: Card(
            color: Colors.white,
            elevation: 1.0,
            child: Dismissible(
              key: ObjectKey(incomingRequests[index]),
              background: swipeBackground(),
              onDismissed: (direction) {
                String request = incomingRequests[index];
                setState(() {
                  incomingRequests.removeAt(index);
                });
                _respondToJoinRequest(scaffoldContext, request, -1);
              },
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    incomingRequests[index],
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
                subtitle: getFlatIdentifierTextWidget(incomingRequests[index]),
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
                          if (_isButtonDisabled == false)
                            _respondToJoinRequest(
                                scaffoldContext, incomingRequests[index], 1);
                          else {
                            setState(() {
                              _progressCircleState = 1;
                            });
                            Utility.createErrorSnackBar(scaffoldContext,
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

  _getFromSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    // Try reading data from the counter key. If it does not exist, return 0.
    var uID = await prefs.get(globals.userId);
    return uID;
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

  Widget textInCard(text, weight, size, padLeft, padTop) {
    return Padding(
      padding: EdgeInsets.only(top: padTop, left: padLeft),
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: size,
          color: Colors.white,
          fontFamily: 'Montserrat',
          fontWeight: weight,
        ),
      ),
    );
  }

  void _respondToJoinRequest(scaffoldContext, displayFlatId, didAccept) async {
    setState(() {
      _buttonColor = Colors.lightBlueAccent;
      _isButtonDisabled = true;
    });
    var userId = await _getFromSharedPref();
    var timeNow = DateTime.now();
    Firestore.instance
        .collection(globals.flat)
        .where("display_id", isEqualTo: displayFlatId)
        .limit(1)
        .getDocuments()
        .then((flat) {
      if (flat.documents != null && flat.documents.length != 0) {
        var flatId = flat.documents[0].documentID;
        var displayId = flat.documents[0].data['display_id'];
        var flatName = flat.documents[0].data['name'];
        debugPrint("display_Id = " + displayId);
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
                  .then((toAcceptData) {
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
                batch
                    .updateData(toAccept, {'status': 1, 'updated_at': timeNow});

                //update user
                List landlordFlatList = new List();
                landlordFlatList.add(flatId.toString().trim());
                var userRef = Firestore.instance
                    .collection(globals.landlord)
                    .document(userId);
                batch.updateData(userRef, {'flat_id': landlordFlatList});

                // to store flat id with name in shared preferences
                List landlordFlatListWithName = new List();
                landlordFlatListWithName.add(flatId.toString().trim() +
                    "Name=" +
                    flatName.toString().trim());

                //update flat landlord
                var flatRef = Firestore.instance
                    .collection(globals.flat)
                    .document(flatId);
                batch.updateData(flatRef, {'landlord_id': userId});

                batch.commit().then((res) {
                  debugPrint("ADDED TO FLAT");
                  Utility.addToSharedPref(
                      flatIdDefault: flatId,
                      flatName: flatName,
                      flatIdList: landlordFlatListWithName);
                  setState(() {
                    _navigateToHome(flatId);
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
    });
  }

  _checkFlatAccept() async {
    var userId = await Utility.getUserId();
    Firestore.instance.collection(globals.landlord).document(userId).get().then(
        (landlordUser) {
      if (landlordUser != null &&
          landlordUser['flat_id'] != null &&
          landlordUser['flat_id'] != "") {
        Utility.addToSharedPref(
            flatIdDefault: landlordUser['flat_id'][0],
            flatIdList: landlordUser['flat_id']);
        _navigateToHome(landlordUser['flat_id'][0]);
      } else {
        flatId = "";
      }
    }, onError: (e) {}).catchError((e) {});
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

  void _navigateToHome(flatId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) {
        return LandlordPortal(flatId);
      }),
    );
  }

  Future<int> navigateToCreate(BuildContext context, createOrJoin) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return CreateFlat(createOrJoin);
      }),
    );
  }

  void moveToLastScreen(BuildContext context) {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}
