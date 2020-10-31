import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/utility/utility.dart';
import 'package:simpliflat_landlord/common_widgets/loading_container.dart';
import 'dart:async';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;

class AssignToFlat extends StatefulWidget {
  final List<String> assignedToList;
  final List flatIdNameList;

  AssignToFlat(this.assignedToList, this.flatIdNameList);

  @override
  State<StatefulWidget> createState() {
    return AssignToFlatState(this.assignedToList, this.flatIdNameList);
  }
}

class AssignToFlatState extends State<AssignToFlat> {
  List<String> assignedFlatIds;
  final List flatIdNameList;

  AssignToFlatState(this.assignedFlatIds, this.flatIdNameList);

  @override
  Widget build(BuildContext context) {
    debugPrint(flatIdNameList.length.toString());
    for (int i = 0; i < flatIdNameList.length; i++) {
      debugPrint('names = ' + flatIdNameList[i]['name']);
    }
    return WillPopScope(
      onWillPop: () {
        goToPreviousScreen();
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text('Assign to Flat'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.save),
                onPressed: () {
                  saveList();
                },
              )
            ],
          ),
          body: Builder(
            builder: (BuildContext scaffoldC) {
              return getFlatNamesListWidget();
            },
          )),
    );
  }

  void goToPreviousScreen() {
    Navigator.of(context).pop(null);
  }

  Future<QuerySnapshot> getFlatIdAndNamesList(String userId) async {
    //TODO: get these values from local db or shared pref instead of firestore 
    return Firestore.instance.collection(globals.ownerFlat).where('ownerIdList', arrayContains: userId).getDocuments();
  }

  Widget getFlatNamesListWidget() {
    User user = Provider.of<User>(context, listen: false);
    return FutureBuilder(
      future: getFlatIdAndNamesList(user.getUserId()),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return LoadingContainerVertical(1);
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data.documents.length,
          itemBuilder: (context, position) {
            return CheckboxListTile(
              title: Text(snapshot.data.documents[position]['flatName']),
              value: assignedFlatIds
                  .contains(snapshot.data.documents[position].documentID),
              onChanged: (value) {
                if (position == 0 && assignedFlatIds.contains('ALL')) {
                  assignedFlatIds = new List();
                } else if (position == 0 && !assignedFlatIds.contains('ALL')) {
                  assignedFlatIds = new List();
                  for (int i = 0; i < snapshot.data.documents.length; i++) {
                    assignedFlatIds.add(snapshot.data.documents[i].documentID);
                  }
                } else if (assignedFlatIds
                    .contains(snapshot.data.documents[position].documentID)) {
                  assignedFlatIds
                      .remove(snapshot.data.documents[position].documentID);
                  assignedFlatIds.remove("ALL");
                } else {
                  assignedFlatIds.add(snapshot.data.documents[position].documentID);
                }
                setState(() {
                  assignedFlatIds = assignedFlatIds;
                });
              },
            );
          },
        );
      },
    );
  }

  void saveList() {
    debugPrint("in save");
    debugPrint(assignedFlatIds.length.toString());
    Navigator.of(context).pop(assignedFlatIds);
  }
}
