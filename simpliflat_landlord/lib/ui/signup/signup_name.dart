import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/common_widgets/common.dart';
import 'package:simpliflat_landlord/dao/owner_dao.dart';
import 'package:simpliflat_landlord/dao/owner_flat_dao.dart';
import 'package:simpliflat_landlord/main.dart';
import 'package:simpliflat_landlord/model/user.dart';
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "ENTER NAME",
            style: TextStyle(
              color: Color(0xff373D4C),
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
          elevation: 0.0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Color(0xff373D4C),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        //resizeToAvoidBottomPadding: false,
        body: Builder(builder: (BuildContext scaffoldContext) {
          _scaffoldContext = scaffoldContext;
          return Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.only(
                  top: 60.0,
                ),
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(_minpad),
                      child: Opacity(
                        //
                        opacity: 1,
                        child: SizedBox(
                          width: deviceSize.width,
                          child: new Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            color: Colors.white,
                            elevation: 0.0,
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Container(),
                                    ),
                                    Expanded(
                                      flex: 7,
                                      child: Text(
                                        "Please enter your name",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w700,
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
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 30.0,
                                        ),
                                        controller: name,
                                        validator: (String value) {
                                          if (value.isEmpty)
                                            return "Please enter Name";
                                          return null;
                                        },
                                        onFieldSubmitted: (v) => _submitForm(),
                                        decoration: InputDecoration(
                                          //labelText: "Name",
                                          hintText: "Rahul",
                                          //labelStyle: TextStyle(
                                          //    color: Colors.white),
                                          hintStyle:
                                              TextStyle(color: Colors.grey),
                                          errorStyle: TextStyle(
                                            color: Colors.red,
                                            fontSize: 12.0,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w700,
                                          ),
                                          border: new UnderlineInputBorder(
                                            borderSide: new BorderSide(
                                                color: Colors.black),
                                          ),
                                          focusedBorder:
                                              new UnderlineInputBorder(
                                            borderSide: new BorderSide(
                                                color: Colors.black),
                                          ),
                                        ),
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
                                      flex: 8,
                                      child: ButtonTheme(
                                          height: 50.0,
                                          child: RaisedButton(
                                              shape: new RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        25.0),
                                                side: BorderSide(
                                                  width: 0.0,
                                                ),
                                              ),
                                              color: Color(0xff2079FF),
                                              textColor: Theme.of(context)
                                                  .primaryColorDark,
                                              child: setUpButtonChild(),
                                              onPressed: () => _submitForm(),
                                                )),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(),
                                    ),
                                  ],
                                ),
                                Container(height: 10.0),
                                CommonWidgets.getDotIndicator(10, 10, 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ));
        }));
  }

  Widget setUpButtonChild() {
    if (_progressCircleState == 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "CREATE ACCOUNT",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
          new Spacer(),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
          ),
        ],
      );
    } else if (_progressCircleState == 1) {
      return Container(
        margin: EdgeInsets.all(5.0),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else {
      return Icon(Icons.check, color: Colors.white);
    }
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
