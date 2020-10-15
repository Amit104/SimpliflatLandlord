import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/dao/owner_dao.dart';
import 'package:simpliflat_landlord/dao/owner_flat_dao.dart';
import 'package:simpliflat_landlord/main.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/ui/create_or_join/create_or_join_home.dart';
import 'dart:math';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;
import 'package:simpliflat_landlord/model/owner.dart';
import 'package:simpliflat_landlord/ui/signup/signup_background.dart';
import 'package:simpliflat_landlord/ui/home/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simpliflat_landlord/utility/utility.dart';

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

    final FirebaseAuth _auth = FirebaseAuth.instance;
    final Firestore _firestore = Firestore.instance;

    FirebaseUser user = await _auth.currentUser();

    User userObj = new User();
    userObj.setPhone(phone);
    userObj.setName(name.text);
    userObj.setNotificationToken("");
    userObj.setUserId(user.uid);
    Map<String, dynamic> userData = userObj.toJson();
    
    debugPrint('phone = ' + phone);
    QuerySnapshot snapshot = await OwnerDao.getOwnerByPhoneNumber(phone.trim());
    
    if (snapshot == null || snapshot.documents.length == 0) {
      debugPrint("IN NEW USER === " + user.uid.toString());
      DocumentReference ref = OwnerDao.getDocumentReference(user.uid);
      ref.setData(userData).then((addedUser) {
        var userId = user.uid;
        _onSuccess(userId: userId, userName: name.text);
        navigate(true, userObj);
      }, onError: (e) {
        _serverError(scaffoldContext);
      });
    } else {
      _onSuccess(
          userId: snapshot.documents[0].documentID,
          userName: snapshot.documents[0].data['name']);
      navigate(false, userObj);
    }
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

  void navigate(bool newUser, User user) async {
    
    if (newUser) {
      navigateToCreateOrJoin(user);
    } else {
      bool propReg = await Utility.getPropertyRegistered();
      if (propReg == null) {
        propReg = await getAndSetIfPropertyRegistred(user.getUserId());
      }

      if (propReg) {
        navigateToHome(user);
      } else {
        navigateToCreateOrJoin(user);
      }
    }
  }

  Future<bool> getAndSetIfPropertyRegistred(String userId) async {
    QuerySnapshot docs = await OwnerFlatDao.getAnOwnerFlatForUser(userId);
    bool propReg = docs.documents != null && docs.documents.length > 0;
    Utility.addToSharedPref(propertyRegistered: propReg);
    return propReg;
  }

  navigateToHome(User user) {
    //TODO: check if the get from sp in main clashes with the set in sp in onsuccess method in this file
    debugPrint('user id in signup name - ' + user.getUserId());
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
      return MyApp();
    }), ModalRoute.withName('/'))
        .whenComplete(() {
      _progressCircleState = 0;
      _isButtonDisabled = false;
    });
  }

  navigateToCreateOrJoin(User user) {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
      
        return MyApp();
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
