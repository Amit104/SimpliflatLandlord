import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:simpliflat_landlord/screens/globals.dart' as globals;
import 'package:simpliflat_landlord/screens/models/models.dart';
import 'package:simpliflat_landlord/screens/widgets/loading_container.dart';
import '../../main.dart';
import '../utility.dart';

class ProfileOptions extends StatefulWidget {
  var userName;
  var userPhone;
  var flatName;
  var displayId;
  var flatId;

  ProfileOptions(this.userName, this.userPhone, this.flatName, this.displayId, this.flatId);

  @override
  State<StatefulWidget> createState() => new _ProfileOptions(flatId);
}

class _ProfileOptions extends State<ProfileOptions> {
  var uID;
  final flatId;
  Set editedData = Set();
  var _formKey1 = GlobalKey<FormState>();
  var _minimumPadding = 5.0;
  BuildContext _scaffoldContext;
  TextEditingController textField = TextEditingController();
  List existingUsers;
  int usersCount;
  String userName;

  _ProfileOptions(this.flatId);

  void initPrefs() async {
    await _getFromSharedPref();
  }

  void initLists() async {
    if (this.existingUsers == null) {
      existingUsers = new List();
      _updateUsersView();
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    initPrefs();
    initLists();
    return WillPopScope(
        onWillPop: () {
          _moveToLastScreen(context);
          return null;
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text("Profile"),
              elevation: 0.0,
            ),
            body: Builder(builder: (BuildContext scaffoldC) {
              _scaffoldContext = scaffoldC;
              return new Center(
                  child: ListView(children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 10.0, top: 10.0),
                      child: Text(
                        "Flat Members",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontFamily: 'Montserrat',
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 5.0),
                      height: 118.0,
                      color: Colors.white,
                      child: (existingUsers == null ||
                          existingUsers.length == 0)
                          ? LoadingContainerHorizontal(
                          MediaQuery.of(context).size.height / 10 -
                              10.0)
                          : _getExistingUsers(),
                    ),
                    Card(
                      color: Colors.white,
                      elevation: 2.0,
                      child: ListTile(
                          title: Text(
                            widget.flatName,
                          ),
                          leading: Icon(
                            Icons.home,
                            color: Colors.redAccent,
                          ),
                          onTap: () {}),
                    ),
                    Card(
                      color: Colors.white,
                      elevation: 2.0,
                      child: ListTile(
                          title: Text(
                            widget.displayId,
                          ),
                          leading: GestureDetector(
                            child: Icon(
                              Icons.share,
                              color: Colors.indigo[900],
                            ),
                            onTap: () {
                              Share.share(
                                  'Check out Simpliflat. You can join my flat with using ID - ' +
                                      widget.displayId,
                                  subject: 'Check out Simpliflat!');
                            },
                          ),
                          onTap: () {}),
                    ),
                    Card(
                      color: Colors.white,
                      elevation: 2.0,
                      child: ListTile(
                        title: Text(
                          widget.userName,
                        ),
                        leading: Icon(
                          Icons.account_circle,
                          color: Colors.orange,
                        ),
                        trailing: GestureDetector(
                            child: Text(
                              "EDIT",
                              style: TextStyle(
                                  color: Colors.indigo[900],
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Montserrat',
                                  fontSize: 14.0),
                            ),
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (_) => _getEditPrompt(
                                      textStyle,
                                      "Name",
                                      _changeUserName,
                                      _userNameValidator,
                                      TextInputType.text,
                                      widget.userName));
                            }),
                      ),
                    ),
                    Card(
                      color: Colors.white,
                      elevation: 2.0,
                      child: ListTile(
                          title: Text(
                            widget.userPhone,
                          ),
                          leading: Icon(
                            Icons.phone,
                            color: Colors.blue,
                          ),
                          onTap: () {}),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 5.0, right: 5.0),
                      child: RaisedButton(
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(40.0),
                          side: BorderSide(
                            width: 0.5,
                            color: Colors.indigo[900],
                          ),
                        ),
                        color: Colors.white,
                        textColor: Colors.indigo[900],
                        onPressed: () {
                          showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return new AlertDialog(
                                title: new Text('Leave Flat'),
                                content: new Text(
                                    'Are you sure you want to leave this flat?'),
                                actions: <Widget>[
                                  new FlatButton(
                                    child: new Text('Cancel'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                  ),
                                  new FlatButton(
                                      child: new Text('Yes'),
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                        _exitFlat();
                                      }),
                                ],
                              );
                            },
                          );
                        },
                        child: Text('Exit Flat'),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 5.0, right: 5.0),
                      child: RaisedButton(
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(40.0),
                          side: BorderSide(
                            width: 0.5,
                            color: Colors.indigo[900],
                          ),
                        ),
                        color: Colors.white,
                        textColor: Colors.indigo[900],
                        onPressed: () {
                          showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return new AlertDialog(
                                title: new Text('Log out'),
                                content:
                                new Text('Are you sure you want to log out?'),
                                actions: <Widget>[
                                  new FlatButton(
                                    child: new Text('Cancel'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                  ),
                                  new FlatButton(
                                      child: new Text('Yes'),
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                        _signOut();
                                      }),
                                ],
                              );
                            },
                          );
                        },
                        child: Text('Logout'),
                      ),
                    ),
                  ]));
            })));
  }

  _moveToLastScreen(BuildContext _navigatorContext) {
    debugPrint("Back");
    Navigator.pop(_navigatorContext, {'editedData': editedData});
  }

  _getFromSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    uID = await prefs.get(globals.userId);
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    //SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    _backHome();
  }

  void _exitFlat() async {
    //remove sharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(globals.flatId);

    //update joinflat
    var data = {"status": -1};
    Firestore.instance
        .collection(globals.requests)
        .where("user_id", isEqualTo: uID)
        .where("flat_id", isEqualTo: flatId)
        .limit(1)
        .getDocuments()
        .then((checker) {
      debugPrint("CHECKING REQUEST EXISTS OR NOT");
      if (checker.documents != null && checker.documents.length != 0) {
        debugPrint("UPDATING REQUEST");
        Firestore.instance
            .collection(globals.requests)
            .document(checker.documents[0].documentID)
            .updateData(data);
      }
    });

    //update user table
    var data2 = {"flat_id": null};
    Firestore.instance.collection(globals.landlord).document(uID).updateData(data2);

    _backHome();
  }

  void _backHome() async {
    Navigator.pushAndRemoveUntil(
        _scaffoldContext,
        MaterialPageRoute(builder: (BuildContext context) => MyApp()),
            (Route<dynamic> route) => false);
  }

  Form _getEditPrompt(textStyle, fieldName, editHandler, validatorCallback,
      keyboardType, initialFieldValue) {
    textField.text = initialFieldValue;
    return new Form(
        key: _formKey1,
        child: AlertDialog(
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10.0),
              side: BorderSide(
                width: 1.0,
                color: Colors.indigo[900],
              ),
            ),
            title: new Text("Edit " + fieldName,
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Montserrat',
                    fontSize: 16.0)),
            content: Container(
              width: double.maxFinite,
              height: MediaQuery.of(_scaffoldContext).size.height / 3,
              child: Column(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(
                          top: _minimumPadding, bottom: _minimumPadding),
                      child: TextFormField(
                        autofocus: true,
                        keyboardType: keyboardType,
                        style: textStyle,
                        controller: textField,
                        validator: (String value) {
                          if (value.isEmpty) return "Please enter a value";
                          return null;
                        },
                        decoration: InputDecoration(
                            labelText: fieldName,
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 16.0,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700),
                            hintText: "Enter " + fieldName,
                            hintStyle: TextStyle(color: Colors.grey),
                            errorStyle: TextStyle(
                                color: Colors.red,
                                fontSize: 12.0,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700),
                            border: InputBorder.none),
                      )),
                  Padding(
                      padding: EdgeInsets.only(
                          top: _minimumPadding, bottom: _minimumPadding),
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
                                  if (_formKey1.currentState.validate()) {
                                    editHandler(textField);
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
                                  Navigator.of(_scaffoldContext, rootNavigator: true)
                                      .pop();
                                })
                          ]))
                ],
              ),
            )));
  }

  String _userNameValidator(String name) {
    if (name.isEmpty) {
      return "Cannot be empty";
    } else if (name == widget.userName) {
      return "Cannot be the same name";
    }
    return null;
  }

  _changeUserName(textField) async {
    String name = textField.text;
    var data = {"name": name};
    Firestore.instance
        .collection(globals.landlord)
        .document(uID)
        .updateData(data)
        .then((updated) {
      widget.userName = name;
      editedData.add("name");
      Utility.addToSharedPref(userName: name);
    });
    textField.clear();
    Navigator.of(_scaffoldContext, rootNavigator: true).pop();
    setState(() {
      debugPrint("Username changed");
    });
  }

  void _updateUsersView() async {
    debugPrint(flatId);

    Firestore.instance
        .collection("user")
        .where("flat_id", isEqualTo: flatId)
        .getDocuments()
        .then((snapshot) {
      if (snapshot == null || snapshot.documents.length == 0) {
        //addContacts
      } else {
        setState(() {
          snapshot.documents.sort(
                  (a, b) => b.data['updated_at'].compareTo(a.data['updated_at']));
          var responseArray = snapshot.documents
              .map((m) => new FlatUsersResponse.fromJson(m.data, m.documentID))
              .toList();
          this.usersCount = responseArray.length;
          this.existingUsers = responseArray;
        });
      }
    }, onError: (e) {
      debugPrint("ERROR IN UPDATE USERS VIEW");
      Utility.createErrorSnackBar(_scaffoldContext);
    });
  }

  ListView _getExistingUsers() {
    TextStyle titleStyle = Theme.of(_scaffoldContext).textTheme.subhead;
    return ListView.builder(
        itemCount: this.usersCount,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int position) {
          return SizedBox(
            width: 100,
            height: 105,
            child: Card(
              color: Colors.white30,
              elevation: 0.0,
              child: Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Column(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Utility.userIdColor(
                          this.existingUsers[position].userId),
                      child: Align(
                        child: Text(
                          this
                              .existingUsers[position]
                              .name == ""
                              ? "S"
                              : this
                              .existingUsers[position]
                              .name[0]
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 30.0,
                            fontFamily: 'Satisfy',
                            color: Colors.white,
                          ),
                        ),
                        alignment: Alignment.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 7.5),
                      child: Text(
                        this.existingUsers[position].name,
                        style:
                        TextStyle(fontSize: 14.0, fontFamily: 'Montserrat'),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

/*zString _phoneNumberValidator(String number) {
    if (number.isEmpty) {
      return "Cannot be empty";
    } else if ("+91" + number == widget.userPhone) {
      return "Cannot be the same number";
    } else if (number.length != 10) {
      return "Please enter a valid 10 digit number";
    }
    /*TODO: handle existing account with same number
      1. disallow number change
      2.  ask to choose between accounts
     */
    return null;
  }

  _changePhoneNumber(textField) async {
    String phoneNumber = "+91" + textField.text.trim();
    Map results = await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) {
        return SignUpOTP(phoneNumber, false);
      }),
    );

    if (results.containsKey('success')) {
      var data = {"phone": phoneNumber};
      Firestore.instance.collection(globals.landlord).document(uID).updateData(data);
      widget.userPhone = phoneNumber;
      editedData.add("phone");
    } else {
      Utility.createErrorSnackBar(_scaffoldContext,
          error: "Phone verification failed");
    }
    textField.clear();
    Navigator.of(context, rootNavigator: true).pop();
    setState(() {
      debugPrint("Phone changed");
    });
  }*/
}
