import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:simpliflat_landlord/utility/utility.dart';
import 'package:simpliflat_landlord/common_widgets/loading_container.dart';
import 'dart:async';

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

  Future<dynamic> getFlatIdAndNamesList() async {
    if (flatIdNameList != null && flatIdNameList.isNotEmpty) {
      return flatIdNameList;
    }
    debugPrint("here = ");
    List<Map> flatIdNameListTemp = new List();
    flatIdNameListTemp.add({'id': 'ALL', 'name': 'ALL'});
    List flatIdList = await Utility.getFlatIdList();
    for (int i = 0; i < flatIdList.length; i++) {
      var id = flatIdList[i];
      if (id.contains("Name=")) {
        flatIdNameListTemp
            .add({'id': id.split("Name=")[0], 'name': id.split("Name=")[1]});
      }
    }
    return flatIdNameListTemp;
  }

  Widget getFlatNamesListWidget() {
    return FutureBuilder(
      future: getFlatIdAndNamesList(),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return LoadingContainerVertical(1);
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data.length,
          itemBuilder: (context, position) {
            return CheckboxListTile(
              title: Text((snapshot.data as List)[position]['name']),
              value: assignedFlatIds
                  .contains((snapshot.data as List)[position]['id']),
              onChanged: (value) {
                if (position == 0 && assignedFlatIds.contains('ALL')) {
                  assignedFlatIds = new List();
                } else if (position == 0 && !assignedFlatIds.contains('ALL')) {
                  assignedFlatIds = new List();
                  for (int i = 0; i < snapshot.data.length; i++) {
                    assignedFlatIds.add(snapshot.data[i]['id']);
                  }
                } else if (assignedFlatIds
                    .contains((snapshot.data as List)[position]['id'])) {
                  assignedFlatIds
                      .remove((snapshot.data as List)[position]['id']);
                  assignedFlatIds.remove("ALL");
                } else {
                  assignedFlatIds.add((snapshot.data as List)[position]['id']);
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
