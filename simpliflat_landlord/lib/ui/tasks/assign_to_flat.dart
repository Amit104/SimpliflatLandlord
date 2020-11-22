import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/model/owner_flat.dart';
import 'package:simpliflat_landlord/model/owner_tenant.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/utility/utility.dart';
import 'package:simpliflat_landlord/common_widgets/loading_container.dart';
import 'dart:async';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;

class AssignToFlat extends StatefulWidget {
  final List<String> assignedToList;
  final List flatIdNameList;
  final OwnerTenant flat;

  AssignToFlat(this.assignedToList, this.flatIdNameList, this.flat);

  @override
  State<StatefulWidget> createState() {
    return AssignToFlatState(this.assignedToList, this.flatIdNameList, this.flat);
  }
}

class AssignToFlatState extends State<AssignToFlat> {
  List<String> assignedFlatIds;
  final List flatIdNameList;
  final OwnerTenant flat;

  AssignToFlatState(this.assignedFlatIds, this.flatIdNameList, this.flat);

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

  Widget getFlatNamesListWidget() {
    Map<String, List<OwnerFlat>> ownedFlats = this.flat.getOwnedFlats();
        List<OwnerFlat> buildingFlats = ownedFlats[this.flat.getOwnerFlat().getBuildingId()];
        buildingFlats.removeWhere((OwnerFlat flat) => flat.getOwnerTenantId() == null || flat.getOwnerTenantId() == '');
        return ListView.builder(
          shrinkWrap: true,
          itemCount: buildingFlats.length,
          itemBuilder: (context, position) {
            return CheckboxListTile(
              title: Text(buildingFlats[position].getFlatName()),
              value: assignedFlatIds
                  .contains(buildingFlats[position].getOwnerTenantId()),
              onChanged: (value) {
                /*if (position == 0 && assignedFlatIds.contains('ALL')) {
                  assignedFlatIds = new List();
                } else if (position == 0 && !assignedFlatIds.contains('ALL')) {
                  assignedFlatIds = new List();
                  for (int i = 0; i < buildingFlats.length; i++) {
                    assignedFlatIds.add(buildingFlats[i].getOwnerTenantId());
                  }
                } else*/ if (assignedFlatIds
                    .contains(buildingFlats[position].getOwnerTenantId())) {
                  assignedFlatIds
                      .remove(buildingFlats[position].getOwnerTenantId());
                  //assignedFlatIds.remove("ALL");
                } else {
                  assignedFlatIds.add(buildingFlats[position].getOwnerTenantId());
                }
                setState(() {
                  assignedFlatIds = assignedFlatIds;
                });
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
