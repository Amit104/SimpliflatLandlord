import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:simpliflat_landlord/screens/flatSetup/AddTenant.dart';
import 'package:simpliflat_landlord/screens/globals.dart' as globals;
import 'package:simpliflat_landlord/screens/home/Home.dart';
import 'package:simpliflat_landlord/screens/models/Owner.dart';
import 'package:simpliflat_landlord/screens/models/OwnerFlat.dart';
import 'package:simpliflat_landlord/screens/models/models.dart';
import 'package:simpliflat_landlord/screens/ownerRequests/SearchOwner.dart';
import 'package:simpliflat_landlord/screens/utility.dart';
import 'package:simpliflat_landlord/screens/widgets/loading_container.dart';
import 'package:simpliflat_landlord/service/OwnerRequestsService.dart';
import 'package:flutter/cupertino.dart';


class ProfileOptions extends StatefulWidget {


  final Owner owner;

  final OwnerFlat flat;

  ProfileOptions(this.owner, this.flat);

  @override
  State<StatefulWidget> createState() => new _ProfileOptions(this.owner, this.flat);
}

class _ProfileOptions extends State<ProfileOptions> {
  //var uID;
  Set editedData = Set();
  var _formKey1 = GlobalKey<FormState>();
  var _minimumPadding = 5.0;
  BuildContext _scaffoldContext;
  TextEditingController textField = TextEditingController();
  List existingUsers;
  int usersCount;
  //String userName;

  final Owner owner;
  final OwnerFlat flat;

  _ProfileOptions(this.owner, this.flat);

  void initLists() async {
    if (this.existingUsers == null) {
      existingUsers = new List();
      _updateUsersView();
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    initLists();
    return WillPopScope(
        onWillPop: () {
          _moveToLastScreen(context);
          return null;
        },
        child: Scaffold(
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
                    Padding(
                      padding: EdgeInsets.only(left: 10.0, top: 10.0),
                      child: Text(
                        "Owners",
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
                      child: _getOwners(scaffoldC),
                    ),
                    Card(
                      color: Colors.white,
                      elevation: 2.0,
                      child: ListTile(
                          title: Text(
                            this.flat.getFlatName()
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
                          this.owner.getName(),
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
                                      this.owner.getName()));
                            }),
                      ),
                    ),
                    Card(
                      color: Colors.white,
                      elevation: 2.0,
                      child: ListTile(
                          title: Text(
                            this.owner.getPhone(),
                          ),
                          leading: Icon(
                            Icons.phone,
                            color: Colors.blue,
                          ),
                          onTap: () {}),
                    ),
                    Card(
                        child: ListTile(
                          title: Text('Add Owner'),
                         
              onTap: () {
                                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return SearchOwner(this.owner, this.flat);
                  }),
                 );

              },
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
                                title: new Text('Evacuate Flat'),
                                content: new Text(
                                    'Are you sure you want to evacuate this flat?'),
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
                                        _evacuateFlat(scaffoldC);
                                      }),
                                ],
                              );
                            },
                          );
                        },
                        child: Text('Evacuate Flat'),
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

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    //SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    _backHome();
  }

  Widget _getOwners(BuildContext scaffoldC) {
    return ListView.builder(
        itemCount: this.flat.getOwners().length,
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
                    //TODO: on tapping this give an option to remove the owner
                    GestureDetector(
                      onLongPress: () {
                        debugPrint("on long press");
                        getOwnerActions(scaffoldC, this.flat.getOwners()[position]);
                      },
                                          child: CircleAvatar(
                        backgroundColor: Utility.userIdColor(
                            this.flat.getOwners()[position].getOwnerId()),
                        child: Align(
                          child: Text(
                            this.flat.getOwners()[position]
                                .getName() == ""
                                ? "S"
                                : 
                                this.flat.getOwners()[position]
                                .getName()[0]
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
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 7.5),
                      child: Text(
                        this.flat.getOwners()[position]
                              .getName(),
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

  void getOwnerActions(BuildContext scaffoldC, Owner ownerTemp) async {
 final action = CupertinoActionSheet(
      title: Text(
        "Actions",
        style: TextStyle(fontSize: 25),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text("Delete"),
          onPressed: () {
            Navigator.pop(context);
            _removeOwnerForFlat(scaffoldC, ownerTemp);
          },
        ),
        
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

  void _removeOwnerForFlat(BuildContext scaffoldC, Owner ownerTemp) async {
    /** check if user is allowed to remove owner */
    if(this.flat.getOwners() != null) {
      Owner allowed = this.flat.getOwners().firstWhere((Owner ownerTemp1) {
        return ownerTemp1.getOwnerId() == this.owner.getOwnerId() && ownerTemp1.getRole() == globals.OwnerRoles.Admin.index.toString();
      }, orElse: () {return null;});
      if(allowed == null) {
        //not allowed to remove as this user is not admin
        return;
      }
    }
    
    bool ifSuccess = await OwnerRequestsService.removeOwnerFromFlat(ownerTemp, flat);

    if(ifSuccess) {
      Utility.createErrorSnackBar(scaffoldC, error: 'Owner removed successfully');
    }
    else {
      Utility.createErrorSnackBar(scaffoldC, error: 'Error while removoing owner');
    }

  }

  void _exitFlat() async {

    var batch = Firestore.instance.batch();
    

      DocumentReference apartmentTenantDoc = Firestore.instance.collection(globals.ownerTenantFlat).document(this.flat.getApartmentTenantId());
        
        batch.updateData(apartmentTenantDoc, {'status': 1});

        batch.commit().then((res) async {
          debugPrint("Exit flat");
          //remove sharedPreferences
          _backHome();
        }, onError: (e) {
          _setErrorState(_scaffoldContext, "CALL ERROR");
        }).catchError((e) {
          _setErrorState(_scaffoldContext, "SERVER ERROR");
        });
      }

  void _setErrorState(scaffoldContext, error, {textToSend}) {
    setState(() {
      debugPrint(error);
      if (textToSend != null && textToSend != "")
        Utility.createErrorSnackBar(scaffoldContext, error: textToSend);
      else
        Utility.createErrorSnackBar(scaffoldContext);
    });
  }

  void _backHome() async {
    Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return Home(this.owner);
        }),
      );
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

  void _evacuateFlat(BuildContext scaffoldC) async {
    DocumentReference doc = Firestore.instance.collection(globals.ownerTenantFlat).document(this.flat.getApartmentTenantId());
    doc.updateData({'status': 1}).then((ret) {
      flat.setApartmentTenantId(null);
      flat.setTenantFlatId(null);
      flat.setTenantFlatName(null);
      Navigator.of(context).pop();
      Navigator.of(context).push(
        new MaterialPageRoute(
          builder: (BuildContext ctx) {
            return AddTenant(this.owner, this.flat);
          }
        )
      );
    }).catchError((e) {
      Utility.createErrorSnackBar(scaffoldC, error: 'Error while evacuating flat');
    });
  }

  String _userNameValidator(String name) {
    if (name.isEmpty) {
      return "Cannot be empty";
    } else if (name == this.owner.getName()) {
      return "Cannot be the same name";
    }
    return null;
  }

  _changeUserName(textField) async {
    String name = textField.text;
    var data = {"name": name};
    Firestore.instance
        .collection(globals.landlord)
        .document(this.owner.getOwnerId())
        .updateData(data)
        .then((updated) {
      this.owner.setName(name);
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
    debugPrint('tenant_flat_id - ' + this.flat.getTenantFlatId());
    Firestore.instance
        .collection("user")
        .where("flat_id", isEqualTo: this.flat.getTenantFlatId())
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
          debugPrint(this.usersCount.toString());
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
