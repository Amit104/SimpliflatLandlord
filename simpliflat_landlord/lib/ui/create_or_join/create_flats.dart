import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/common_widgets/common.dart';
import 'package:simpliflat_landlord/model/owner_flat.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;
import 'package:simpliflat_landlord/utility/utility.dart';

/// createFlats form to create flats using name and range
class CreateFlats extends StatefulWidget {
  List<OwnerFlat> ownerFlats;

  final bool join;

  CreateFlats(this.ownerFlats, this.join);

  @override
  State<StatefulWidget> createState() {
    return CreateFlatsState(this.ownerFlats, this.join);
  }
}

class CreateFlatsState extends State<CreateFlats> {
  @override
  void initState() {
    super.initState();
  }

  bool isPG = false;

  bool withRange = false;

  final bool join;

  List<OwnerFlat> ownerFlatsTemp;

  TextEditingController nameCtlr = new TextEditingController();
  TextEditingController rangeFromCtlr = new TextEditingController();
  TextEditingController rangeToCtlr = new TextEditingController();

  List<OwnerFlat> ownerflats;

  final _rangeFormKey = GlobalKey<FormState>();
  final _nameFormKey = GlobalKey<FormState>();

  String errorMsg;

  CreateFlatsState(this.ownerflats, this.join) {
    if (this.ownerflats == null) {
      this.ownerflats = new List();
    }

    this.ownerFlatsTemp = List.from(this.ownerflats);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop(this.ownerflats);
        return null;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Create Flats', style: CommonWidgets.getAppBarTitleStyle(),),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: Builder(builder: (BuildContext scaffoldC) {
          return getBody();
        }),
      ),
    );
  }

  Widget getOptionsButtonsWidget() {
    if (this.join) return Container();
    return Container(
      height: 40.0,
      margin: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      child: Row(
        children: [
          ButtonTheme(
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    bottomLeft: Radius.circular(15.0))),
            minWidth: 80.0,
            height: 40.0,
            child: RaisedButton(
              padding: EdgeInsets.all(1.0),
              color: !withRange ? Color(0xff2079FF) : Colors.white,
              child: Text('Name', style: TextStyle(fontSize: 12.0, color: !withRange?Colors.white: Color(0xff2079FF))),
              onPressed: () {
                setState(() {
                  withRange = false;
                });
              },
            ),
          ),
          ButtonTheme(
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.only(
                    topRight: Radius.circular(15.0),
                    bottomRight: Radius.circular(15.0))),
            minWidth: 80.0,
            height: 40.0,
            child: RaisedButton(
              padding: EdgeInsets.all(1.0),
              color: withRange ? Color(0xff2079FF) : Colors.white,
              child: Text('Range', style: TextStyle(fontSize: 12.0, color: withRange?Colors.white:Color(0xff2079FF))),
              onPressed: () {
                setState(() {
                  withRange = true;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget getOptionsWidget() {
    if (this.join) return Container();
    if (!withRange) {
      return Container(
        height: 100.0,
        margin: EdgeInsets.only(bottom: 20.0),
        child: Form(
          key: _nameFormKey,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.7,
              child: TextFormField(
                  controller: nameCtlr,
                  decoration: const InputDecoration(
                    hintText: 'Enter flat name/number',
                    labelText: 'Name/Number',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Name/Number is mandatory';
                    }
                    if (!flatNameUnique(value)) {
                      return 'Name/Number must be unique';
                    }
                    return null;
                  }),
            ),
            RaisedButton(
              color: Color(0xff2079FF),
              child: Text('Add', style: TextStyle(color: Colors.white),),
              onPressed: () => addFlat(),
            )
          ]),
        ),
      );
    } else {
      return Container(
        height: 100.0,
        margin: EdgeInsets.only(bottom: 20.0),
        child: Form(
          key: _rangeFormKey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.3,
                child: TextFormField(
                    controller: rangeFromCtlr,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'From',
                      labelText: 'From',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    }),
              ),
              SizedBox(
                width: 20.0,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.3,
                child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: rangeToCtlr,
                    decoration: const InputDecoration(
                      hintText: 'To',
                      labelText: 'To',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    }),
              ),
              RaisedButton(
                color: Color(0xff2079FF),
                child: Text('Add', style: TextStyle(color: Colors.white),),
                onPressed: () => addFlatsWithRange(),
              )
            ],
          ),
        ),
      );
    }
  }

  Widget getBody() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(children: [
        getOptionsButtonsWidget(),
        getOptionsWidget(),
        this.errorMsg != null && this.errorMsg != ''
            ? Text(
                this.errorMsg,
                style: TextStyle(color: Colors.red),
              )
            : Container(),
        this.join
            ? Container()
            : RaisedButton(
              color: Color(0xff2079FF),
                child: Text('Done', style: TextStyle(color: Colors.white),),
                onPressed: () {
                  Navigator.of(context).pop(this.ownerFlatsTemp);
                },
              ),
        Expanded(child: getFlatsListWidget()),
      ]),
    );
  }

  Widget getFlatsListWidget() {
    User user = Provider.of<User>(context, listen: false);

    return ListView.separated(
      separatorBuilder: (_, int pos) {
        return Divider(height: 1);
      },
      scrollDirection: Axis.vertical,
      itemCount: this.ownerFlatsTemp.length,
      itemBuilder: (BuildContext context, int index) {
        return this.ownerFlatsTemp[index].getOwnerRoleList().contains(
                    user.getUserId() +
                        ":" +
                        globals.OwnerRoles.Admin.index.toString()) &&
                !this.join
            ? Dismissible(
                key: Key(this
                    .ownerFlatsTemp[this.ownerFlatsTemp.length - index - 1]
                    .getFlatDisplayId()),
                onDismissed: (direction) {
                  setState(() {
                    this
                        .ownerFlatsTemp
                        .removeAt(this.ownerFlatsTemp.length - index - 1);
                  });
                },
                child: ListTile(
                  title: Text(this
                      .ownerFlatsTemp[this.ownerFlatsTemp.length - index - 1]
                      .getFlatName()),
                ),
              )
            : ListTile(
                title: Text(this
                    .ownerFlatsTemp[this.ownerFlatsTemp.length - index - 1]
                    .getFlatName()),
              );
      },
    );
  }

  @override
  void dispose() {
    nameCtlr.dispose();
    rangeFromCtlr.dispose();
    rangeToCtlr.dispose();
    super.dispose();
  }

  void addFlatsWithRange() {
    User user = Provider.of<User>(context, listen: false);
    if (_rangeFormKey.currentState.validate()) {
      int from = int.parse(rangeFromCtlr.text);
      int to = int.parse(rangeToCtlr.text);
      for (int i = from; i <= to; i++) {
        if (!flatNameUnique(i.toString())) {
          setState(() {
            this.errorMsg = 'From and To range must produce unique flats';
          });
          return;
        }
      }
      for (int i = from; i <= to; i++) {
        OwnerFlat flat = new OwnerFlat();
        flat.setModified(true);
        flat.setFlatName(i.toString());
        flat.setFlatDisplayId(Utility.getRandomString(globals.displayIdLength));
        List<String> owners = new List();
        owners.add(user.getUserId());

        flat.setOwnerIdList(owners);

        flat.setVerified(false);

        List<String> ownerRoleList = new List();
        ownerRoleList.add(user.getUserId() +
            ':' +
            user.getName() +
            ':' +
            globals.OwnerRoles.Admin.index.toString());
        flat.setOwnerRoleList(ownerRoleList);

        this.ownerFlatsTemp.add(flat);
        this.rangeFromCtlr.text = '';
        this.rangeToCtlr.text = '';
      }
      setState(() {
        this.errorMsg = null;
        this.ownerFlatsTemp = this.ownerFlatsTemp;
      });
    }
  }

  void addFlat() {
    User user = Provider.of<User>(context, listen: false);
    if (_nameFormKey.currentState.validate()) {
                  OwnerFlat flat = new OwnerFlat();
                  flat.setModified(true);
                  flat.setFlatName(nameCtlr.text);
                  flat.setFlatDisplayId(
                      Utility.getRandomString(globals.displayIdLength));
                  List<String> owners = new List();
                  owners.add(user.getUserId());

                  flat.setOwnerIdList(owners);

                  flat.setVerified(false);

                  List<String> ownerRoleList = new List();
                  ownerRoleList.add(user.getUserId() +
                      ':' +
                      user.getName() +
                      ':' +
                      globals.OwnerRoles.Admin.index.toString());
                  flat.setOwnerRoleList(ownerRoleList);

                  this.ownerFlatsTemp.add(flat);
                  this.nameCtlr.text = '';
                  setState(() {
                    this.errorMsg = null;
                    this.ownerFlatsTemp = this.ownerFlatsTemp;
                  });
                }
              
  }

  bool flatNameUnique(String flatName) {
    if (this.ownerFlatsTemp == null) {
      return true;
    }

    for (int i = 0; i < this.ownerFlatsTemp.length; i++) {
      if (this.ownerFlatsTemp[i].getFlatName() == flatName) {
        return false;
      }
    }

    return true;
  }
}
