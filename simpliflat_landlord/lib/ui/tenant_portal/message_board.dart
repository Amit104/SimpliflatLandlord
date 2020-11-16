import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/common_widgets/common.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;
import 'package:simpliflat_landlord/dao/message_dao.dart';
import 'package:simpliflat_landlord/model/message.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/utility/utility.dart';
import 'package:simpliflat_landlord/common_widgets/loading_container.dart';

class MessageBoard extends StatefulWidget {
  final _flatId;

  MessageBoard(this._flatId);

  @override
  State<StatefulWidget> createState() {
    return _MessageBoard(_flatId);
  }
}

class _MessageBoard extends State<MessageBoard> {
  final _flatId;
  String currentUserId;
  BuildContext _navigatorContext;
  double _minimumPadding = 5.0;
  DateFormat date = DateFormat("yyyy-MM-dd");
  GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();
  GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();
  TextEditingController note = TextEditingController();
  TextEditingController addNote = TextEditingController();
  bool showAssignToAllFlatsoption = false;
  bool sendToAllFlats = false;

  _MessageBoard(this._flatId);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context, listen: false);
    this.currentUserId = user.getUserId();
    return Scaffold(
      appBar: AppBar(
          title: Text('Notice Board', style: CommonWidgets.getAppBarTitleStyle(),),
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
      body: Builder(
        builder: (BuildContext scaffoldC) {
          _navigatorContext = scaffoldC;

          return Column(
            children: <Widget>[
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: MessageDao.getAllForFlat(_flatId),
                  builder:
                      (context, AsyncSnapshot<QuerySnapshot> notesSnapshot) {
                    
                    if (!notesSnapshot.hasData || currentUserId == null)
                      return LoadingContainerVertical(3);
                    addReadNotices();
                    List<Message> messages = notesSnapshot.data.documents.map((DocumentSnapshot doc) => 
                      Message.fromJson(doc.data, doc.documentID)).toList();

                    messages.sort((Message a, Message b) => b.getCreatedAt().compareTo(a.getCreatedAt()));

                    return GroupedListView<dynamic, String>(
                      groupBy: (dynamic message) => date
                          .format((message as Message).getCreatedAt()
                              .toDate()
                              .toLocal())
                          .toString(),
                      sort: false,
                      elements: messages,
                      groupSeparatorBuilder: (String value) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Container(
                            child: new Text(getDateValue(value),
                                style: new TextStyle(
                                    color: Colors.indigo[900],
                                    fontSize: 14.0,
                                    fontFamily: 'Robato')),
                            decoration: new BoxDecoration(
                                borderRadius: new BorderRadius.all(
                                    new Radius.circular(6.0)),
                                color: Colors.indigo[100]),
                            padding:
                                new EdgeInsets.fromLTRB(8.0, 6.0, 8.0, 6.0),
                          ),
                        ),
                      ),
                      itemBuilder: (BuildContext context, dynamic element) {
                        return _buildNoticeListItem(element);
                      },
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: 10.0,
                    top: 5.0,
                  ),
                  child: Column(
                    children: [
                      showAssignToAllFlatsoption
                          ? Opacity(
                              opacity: 0.5,
                              child: Container(
                                color: Colors.black,
                                child: ListTile(
                                  leading: Theme(
                                    data: ThemeData(
                                        unselectedWidgetColor: Colors.white),
                                    child: Checkbox(
                                      tristate: false,
                                      activeColor: Colors.green,
                                      onChanged: (value) {
                                        sendToAllFlats = !sendToAllFlats;
                                      },
                                      value: sendToAllFlats,
                                    ),
                                  ),
                                  title: Text('Send to all flats',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            )
                          : Container(),
                      Row(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.all(10.0),
                          ),
                          Expanded(
                            child: Form(
                              key: _formKey1,
                              child: TextFormField(
                                onTap: () {
                                  showAssignToAllFlatsoption = true;
                                },
                                onEditingComplete: () {
                                  showAssignToAllFlatsoption = false;
                                },
                                keyboardType: TextInputType.text,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.0,
                                  fontFamily: 'Montserrat',
                                ),
                                controller: addNote,
                                validator: (String value) {
                                  if (value.isEmpty)
                                    return "Cannot add empty note!";
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: "Add Message...",
                                  hintStyle: TextStyle(color: Colors.black87),
                                  focusedBorder: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(20.0),
                                    borderSide: new BorderSide(),
                                  ),
				border: new OutlineInputBorder(
                                	borderRadius: new BorderRadius.circular(20.0),
                                	borderSide: new BorderSide(),
                              	),
                                  errorStyle: TextStyle(
                                      color: Colors.red,
                                      fontSize: 10.0,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w700),
                                  //border: InputBorder.none
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(5.0),
                          ),
                          ClipOval(
                            child: Material(
                              color: Colors.indigo, // button color
                              child: InkWell(
                                splashColor: Colors.indigo, // inkwell color
                                child: SizedBox(
                                    width: 56,
                                    height: 56,
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    )),
                                onTap: () async {
                                  if (_formKey1.currentState.validate()) {
                                    _addOrUpdateNote(
                                        _navigatorContext, 1); //1 is add
                                  }
                                },
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(5.0),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void addReadNotices() async {
    Utility.updateReadNoticesLastSeen(
        _flatId, Timestamp.now().millisecondsSinceEpoch);
  }

  String getDateValue(value) {
    var numToMonth = {
      1: 'JANUARY',
      2: 'FEBRUARY',
      3: 'MARCH',
      4: 'APRIL',
      5: 'MAY',
      6: 'JUNE',
      7: 'JULY',
      8: 'AUGUST',
      9: 'SEPTEMBER',
      10: 'OCTOBER',
      11: 'NOVEMBER',
      12: 'DECEMBER'
    };
    DateTime separatorDate = DateTime.parse(value);
    DateTime currentDate =
        DateTime.parse(date.format(DateTime.now().toLocal()).toString());
    String yesterday = date.format(
        DateTime(currentDate.year, currentDate.month, currentDate.day - 1));
    if (value == date.format(DateTime.now().toLocal()).toString()) {
      return "TODAY";
    } else if (value == yesterday) {
      return "YESTERDAY";
    } else {
      return separatorDate.day.toString() +
          " " +
          numToMonth[separatorDate.month.toInt()] +
          " " +
          separatorDate.year.toString();
    }
  }

  Widget _buildNoticeListItem(Message notice) {
    TextStyle textStyle = Theme.of(context).textTheme.subhead;
    DateTime datetime = notice.getCreatedAt().toDate();
    final DateFormat f = new DateFormat.jm();

    String datetimeString = f.format(datetime);

    String userName = notice.getCreatedByUserName() == null
        ? ""
        : notice.getCreatedByUserName().trim();

    int color = notice.getCreatedByUserId().trim().hashCode;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0, left: 8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Card(
          color: Colors.white,
          elevation: 1.0,
          child: Slidable(
            key: new Key(notice.getMessageId()),
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            enabled: currentUserId.toString().trim() ==
                notice.getCreatedByUserId().trim(),
            dismissal: SlidableDismissal(
              child: SlidableDrawerDismissal(),
              closeOnCanceled: true,
              dismissThresholds: <SlideActionType, double>{
                SlideActionType.primary: 1.0
              },
              onWillDismiss: (actionType) {
                return showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return new AlertDialog(
                      title: new Text('Delete'),
                      content: new Text(
                          'Are you sure you want to delete this notice?'),
                      actions: <Widget>[
                        new FlatButton(
                          child: new Text('Cancel'),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        new FlatButton(
                          child: new Text('Ok'),
                          onPressed: () => Navigator.of(context).pop(true),
                        ),
                      ],
                    );
                  },
                );
              },
              onDismissed: (actionType) {
                _deleteNote(context, notice);
              },
            ),
            secondaryActions: <Widget>[
              new IconSlideAction(
                caption: 'Delete',
                color: Colors.red,
                icon: Icons.delete,
                onTap: () async {
                  SlidableState state = Slidable.of(context);
                  bool dismiss = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return new AlertDialog(
                        title: new Text('Delete'),
                        content: new Text(
                            'Are you sure you want to delete this notice?'),
                        actions: <Widget>[
                          new FlatButton(
                            child: new Text('Cancel'),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          new FlatButton(
                            child: new Text('Ok'),
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ],
                      );
                    },
                  );

                  if (dismiss) {
                    _deleteNote(context, notice);
                    state.dismiss();
                  }
                },
              ),
            ],
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
                  Text(notice.getMessage().trim(),
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
                      fontSize: 11.0,
                      fontFamily: 'Montserrat',
                      color: Colors.black45,
                    )),
                padding: EdgeInsets.only(top: 6.0),
              ),
              onTap: () {
                setState(() {
                  if (currentUserId == notice.getCreatedByUserId().trim())
                    note.text = notice.getMessage().trim();
                });
                String dialogTitle =
                    currentUserId == notice.getCreatedByUserId().trim()
                        ? "Edit Message"
                        : "Notice";
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
                      title: new Text(dialogTitle,
                          style: TextStyle(
                              color: Colors.indigo[900],
                              fontFamily: 'Montserrat',
                              fontSize: 18.0)),
                      content: Container(
                        width: double.maxFinite,
                        height: MediaQuery.of(context).size.height / 3,
                        child: currentUserId !=
                                notice.getCreatedByUserId().trim()
                            ? Text(notice.getMessage().trim())
                            : Column(
                                children: <Widget>[
                                  Padding(
                                      padding: EdgeInsets.only(
                                          top: _minimumPadding,
                                          bottom: _minimumPadding),
                                      child: TextFormField(
                                        keyboardType: TextInputType.multiline,
                                        maxLines: 2,
                                        minLines: 1,
                                        style: textStyle,
                                        controller: note,
                                        validator: (String value) {
                                          if (value.isEmpty)
                                            return "Cannot add empty note!";
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          labelText: "Note",
                                          hintText:
                                              "Eg. Maid is not coming today",
                                          hintStyle:
                                              TextStyle(color: Colors.grey),
                                          labelStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16.0,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w700),
                                          errorStyle: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12.0,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w700),
                                        ),
                                      )),
                                  Padding(
                                      padding: EdgeInsets.only(
                                          top: _minimumPadding,
                                          bottom: _minimumPadding),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            OutlineButton(
                                                shape:
                                                    new RoundedRectangleBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          10.0),
                                                  side: BorderSide(
                                                    width: 1.0,
                                                    color: Colors.indigo[900],
                                                  ),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                textColor: Colors.black,
                                                child: Text('Save',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14.0,
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontWeight:
                                                            FontWeight.w700)),
                                                onPressed: () {
                                                  debugPrint("UPDATE");
                                                  if (_formKey2.currentState
                                                      .validate()) {
                                                    debugPrint("MESSAGEID IS" +
                                                        notice.getMessageId()
                                                            .toString());
                                                    _addOrUpdateNote(context, 2,
                                                        notice:
                                                            notice);
                                                    Navigator.of(context,
                                                            rootNavigator: true)
                                                        .pop();
                                                  }
                                                }),
                                            OutlineButton(
                                                shape:
                                                    new RoundedRectangleBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          10.0),
                                                  side: BorderSide(
                                                    width: 1.0,
                                                    color: Colors.indigo[900],
                                                  ),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                textColor: Colors.black,
                                                child: Text('Cancel',
                                                    style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 14.0,
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontWeight:
                                                            FontWeight.w700)),
                                                onPressed: () {
                                                  Navigator.of(context,
                                                          rootNavigator: true)
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
            ),
          ),
        ),
      ),
    );
  }

  _addOrUpdateNote(scaffoldContext, addOrUpdate, {Message notice}) async {
    DateTime timeNow = DateTime.now();
    String userId = await Utility.getUserId();
    String userName = await Utility.getUserName();
    if (addOrUpdate == 1) {
      /// add Message
      Message message = new Message();
      message.setMessage(addNote.text.toString().trim());
      message.setCreatedByUserId(userId);
      message.setCreatedAt(Timestamp.fromDate(timeNow));
      message.setUpdatedAt(Timestamp.fromDate(timeNow));
      message.setCreatedByUserName(userName);
      message.setCreatedByTenant(0);

      setState(() {
        addNote.text = '';
      });
      if (sendToAllFlats) {
        List<String> allflatsList = new List();
        List<String> flatList = await Utility.getFlatIdList();
        for (String id in flatList) {
          if (id.contains("Name=")) {
            allflatsList.add(id.split("Name=")[0]);
          } else {
            allflatsList.add(id);
          }
        }
        WriteBatch batch = Firestore.instance.batch();
        allflatsList.forEach((doc) {
          debugPrint("add to flat - " + doc.toString());
          DocumentReference docRef = MessageDao.getDocumentReference(doc, null);
          batch.setData(docRef, message.toJson());
        });
        await batch.commit().then((v) {
          if (mounted)
            Utility.createErrorSnackBar(scaffoldContext,
                error: 'Message Saved');
        }, onError: (e) {
          debugPrint("ERROR IN UPDATE CONTACT VIEW");
          if (mounted) Utility.createErrorSnackBar(_navigatorContext);
        });
      } else {
        DocumentReference addNoteRef = MessageDao.getDocumentReference(_flatId, null);
        addNoteRef.setData(message.toJson()).then((v) {
          if (mounted)
            Utility.createErrorSnackBar(scaffoldContext,
                error: 'Message Saved');
        }, onError: (e) {
          debugPrint("ERROR IN UPDATE CONTACT VIEW");
          if (mounted) Utility.createErrorSnackBar(_navigatorContext);
        });
      }
    } else {
      /// Update Message
      debugPrint("updated = " + note.text);
      Map<String, dynamic> data = {
        'message': note.text.toString().trim(),
        'updated_at': timeNow,
        'user_name': userName
      };

      DocumentSnapshot freshNote = await MessageDao.getMessage(notice.getMessageId(), _flatId);
      
        if (freshNote == null) {
          if (mounted) Utility.createErrorSnackBar(_navigatorContext);
        } else {
          bool ifSuccess = await MessageDao.update(_flatId, freshNote.documentID, data);
          if(!ifSuccess && mounted) {
            Utility.createErrorSnackBar(_navigatorContext);
          }
        }
    }
  }

  _deleteNote(scaffoldContext, Message notice) async {
    DocumentSnapshot freshNote = await MessageDao.getMessage(notice.getMessageId(), _flatId);
      if (freshNote == null) {
        Utility.createErrorSnackBar(_navigatorContext);
      } else {
        bool ifSuccess = await MessageDao.delete(_flatId, freshNote.documentID);
          if(mounted) {
            if (ifSuccess)
              Utility.createErrorSnackBar(context, error: "Note Deleted");
            else
              Utility.createErrorSnackBar(_navigatorContext);
          }
      }
  }
}
