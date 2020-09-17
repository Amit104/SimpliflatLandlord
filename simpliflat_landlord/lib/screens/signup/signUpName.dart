import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/screens/createOrJoin/createOrJoinHome.dart';
import 'dart:math';
import 'package:simpliflat_landlord/screens/globals.dart' as globals;
import 'package:simpliflat_landlord/screens/models/Owner.dart';
import 'package:simpliflat_landlord/screens/signup/signupBackground.dart';
import 'package:simpliflat_landlord/screens/tenant_portal/tenant_portal.dart';
import 'package:simpliflat_landlord/screens/home/Home.dart';
import '../utility.dart';
import 'create_or_join.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpName extends StatefulWidget {
  final phone;

  SignUpName(this.phone);

  @override
  State<StatefulWidget> createState() {
    return _SignUpNameUser(phone);
  }
}

class _SignUpNameUser extends State<SignUpName> {
  var _formKey = GlobalKey<FormState>();
  var _progressCircleState = 0;
  var _isButtonDisabled = false;
  var phone;
  final _minpad = 5.0;
  String smsCode;
  String verificationId;
  BuildContext _scaffoldContext;
  TextEditingController name = TextEditingController();

  _SignUpNameUser(this.phone);

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(title: Text("Name please"), elevation: 0.0),
        //resizeToAvoidBottomPadding: false,
        body: Stack(children: <Widget>[
          SignUpBackground(3),
          Builder(builder: (BuildContext scaffoldContext) {
            _scaffoldContext = scaffoldContext;
            return Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 50.0, left: _minpad * 2, right: _minpad * 2),
                  child: ListView(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(_minpad),
                        child: Opacity(
                          //
                          opacity: 1,
                          child: SizedBox(
                              height: max(deviceSize.height / 2, 270),
                              width: deviceSize.width * 0.85,
                              child: new Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  color: Colors.white,
                                  elevation: 2.0,
                                  child: Column(children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: 60.0,
                                      ),
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 1,
                                          child: Container(),
                                        ),
                                        Expanded(
                                          flex: 7,
                                          child: Text(
                                            "What should I call you?",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontFamily: 'Montserrat',
                                                fontSize: 18.0),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: 35.0,
                                      ),
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 1,
                                          child: Container(),
                                        ),
                                        Expanded(
                                          flex: 7,
                                          child: TextFormField(
                                            autofocus: true,
                                            keyboardType: TextInputType.text,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontFamily: 'Montserrat',
                                                fontSize: 30.0,
                                                fontWeight: FontWeight.w700),
                                            controller: name,
                                            validator: (String value) {
                                              if (value.isEmpty)
                                                return "Please enter Name";
                                              return null;
                                            },
                                            onFieldSubmitted: (v) {
                                              _submitForm();
                                            },
                                            decoration: InputDecoration(
                                                //labelText: "Name",
                                                hintText: "Rahul",
                                                //labelStyle: TextStyle(
                                                //    color: Colors.white),
                                                hintStyle: TextStyle(
                                                    color: Colors.grey),
                                                errorStyle: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 12.0,
                                                    fontFamily: 'Montserrat',
                                                    fontWeight:
                                                        FontWeight.w700),
                                                border: InputBorder.none),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 30.0),
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 1,
                                          child: Container(),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: ButtonTheme(
                                              height: 40.0,
                                              child: RaisedButton(
                                                  shape:
                                                      new RoundedRectangleBorder(
                                                    borderRadius:
                                                        new BorderRadius
                                                            .circular(10.0),
                                                    side: BorderSide(
                                                      width: 1.0,
                                                      color: Colors.indigo[900],
                                                    ),
                                                  ),
                                                  color: Colors.white,
                                                  textColor: Theme.of(context)
                                                      .primaryColorDark,
                                                  child: setUpButtonChild(),
                                                  onPressed: () {
                                                    _submitForm();
                                                  })),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Container(),
                                        ),
                                      ],
                                    ),
                                  ]))),
                        ),
                      ),
                    ],
                  ),
                ));
          }),
        ]));
  }

  void _submitForm() {
    if (_formKey.currentState.validate() && _isButtonDisabled == false) {
      setState(() {
        _progressCircleState = 1;
        _isButtonDisabled = true;
        debugPrint("STARTING API CALL");
      });
      _addUserHandler(_scaffoldContext);
    }
  }

  void _serverError(scaffoldContext) {
    setState(() {
      _progressCircleState = 0;
      _isButtonDisabled = false;
      debugPrint("SERVER ERROR");
      Utility.createErrorSnackBar(scaffoldContext);
    });
  }

  void _onSuccess(
      {String userId,
      String flatId,
      String displayId,
      String userName,
      String flatName}) {
    String flatTemp;
    if (flatId != null && flatId.length > 0) {
      flatTemp = flatId[0];
    } else {
      flatTemp = null;
    }
    Utility.addToSharedPref(
        userId: userId,
        flatIdDefault: flatTemp,
        flatIdList: flatId,
        userName: userName,
        flatName: flatName);
    setState(() {
      _isButtonDisabled = false;
      _progressCircleState = 2;
      debugPrint("CALL SUCCCESS");
    });
  }

  void _addUserHandler(scaffoldContext) async {
    var timeNow = DateTime.now();

    final FirebaseAuth _auth = FirebaseAuth.instance;
    final Firestore _firestore = Firestore.instance;

    FirebaseUser user = await _auth.currentUser();
    var userData = {
      'phone': phone,
      'name': name.text,
      "updated_at": timeNow,
      "created_at": timeNow,
      'flat_id': null,
      'notification_token': ''
    };
    debugPrint('phone = ' + phone);
    Firestore.instance
        .collection(globals.landlord)
        .where("phone", isEqualTo: phone.trim())
        .limit(1)
        .getDocuments()
        .then((snapshot) {
      if (snapshot == null || snapshot.documents.length == 0) {
        debugPrint("IN NEW USER === " + user.uid.toString());
        DocumentReference ref =
            _firestore.collection(globals.landlord).document(user.uid);
        ref.setData(userData).then((addedUser) {
          var userId = user.uid;
          _onSuccess(userId: userId, userName: name.text);
          navigate(userId, name.text, phone, true);
        }, onError: (e) {
          _serverError(scaffoldContext);
        });
      } else {
        _onSuccess(
            userId: snapshot.documents[0].documentID,
            userName: snapshot.documents[0].data['name']);
        navigate(snapshot.documents[0].documentID,
            snapshot.documents[0].data['name'], phone, false);
      }
    }, onError: (e) {
      debugPrint("ERROR");
      _serverError(scaffoldContext);
    });
  }

  Widget setUpButtonChild() {
    if (_progressCircleState == 0) {
      return new Text(
        "Let's Go!",
        style: const TextStyle(
            color: Colors.indigo,
            fontSize: 16.0,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700),
      );
    } else if (_progressCircleState == 1) {
      return Container(
        margin: EdgeInsets.all(3.0),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo[900]),
        ),
      );
    } else {
      return Icon(Icons.check, color: Colors.white);
    }
  }

  void navigate(
      String userId, String userName, String userPhone, bool newUser) async {
    Owner user = new Owner();
    user.setName(userName);
    user.setOwnerId(userId);
    user.setPhone(userPhone);
    if (newUser) {
      navigateToCreateOrJoin(user);
    } else {
      bool propReg = await Utility.getPropertyRegistered();
      if (propReg == null) {
        propReg = await getAndSetIfPropertyRegistred(userId);
      }

      if (propReg) {
        navigateToHome(user);
      } else {
        navigateToCreateOrJoin(user);
      }
    }
  }

  Future<bool> getAndSetIfPropertyRegistred(String userId) async {
    QuerySnapshot docs = await Firestore.instance
        .collection(globals.ownerFlat)
        .where('ownerIdList', arrayContains: userId)
        .limit(1)
        .getDocuments();
    bool propReg = docs.documents != null && docs.documents.length > 0;
    Utility.addToSharedPref(propertyRegistered: propReg);
    return propReg;
  }

  navigateToHome(Owner user) {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
      return Home(user);
    }), ModalRoute.withName('/'))
        .whenComplete(() {
      _progressCircleState = 0;
      _isButtonDisabled = false;
    });
  }

  navigateToCreateOrJoin(Owner user) {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
      return CreateOrJoinHome(user);
    }), ModalRoute.withName('/'))
        .whenComplete(() {
      _progressCircleState = 0;
      _isButtonDisabled = false;
    });
  }

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  void moveToLastScreen(BuildContext context) {
    Navigator.pop(context);
  }
}
