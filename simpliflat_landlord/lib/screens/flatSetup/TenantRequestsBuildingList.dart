import 'package:flutter/material.dart';
import '../models/Building.dart';
import 'package:simpliflat_landlord/screens/globals.dart' as globals;
import 'package:simpliflat_landlord/screens/utility.dart';
import 'dart:math';
import '../models/OwnerFlat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/screens/widgets/loading_container.dart';
import './createProperty.dart';
import './PropertyRequests.dart';
import '../models/Block.dart';
import '../models/Owner.dart';
import '../models/OwnershipDetailsDBHandler.dart';
import './TenantRequests.dart';



class TenantRequestBuildingList extends StatefulWidget {

  final String userId;



  TenantRequestBuildingList(this.userId);

  @override
  State<StatefulWidget> createState() {
    return TenantRequestBuildingListState(this.userId);
  }

}

class TenantRequestBuildingListState extends State<TenantRequestBuildingList> {

  final String userId;

  bool loadingState = false;

  Map<String, String> ownedBuildings = new Map();

  Map<String, String> ownedFlatIds = new Map();


  TenantRequestBuildingListState(this.userId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your buildings'),
        centerTitle: true,
        backgroundColor: Colors.white,
        
      ),
      backgroundColor: Colors.white,
      body: Builder(builder: (BuildContext scaffoldC) {
        return loadingState == true?Container(alignment: Alignment.center, child: CircularProgressIndicator()):
        getBody(scaffoldC);
      }),
    );
  }

  Future<List<String>> getBuildingList() async {
    QuerySnapshot allFlats = await Firestore.instance.collection(globals.ownerFlat).where('ownerIdList', arrayContains:  this.userId).getDocuments();
    QuerySnapshot allBuildings = await Firestore.instance.collection(globals.building).where('ownerIdList', arrayContains:  this.userId).getDocuments();
    Set<String> buildings = new Set();
    for(int i = 0; i < allFlats.documents.length; i++) {
      DocumentSnapshot d1 = allFlats.documents[i];
      ownedFlatIds[d1.data['buildingName'] + ';-;' + d1.data['buildingDetails']] = d1.documentID;
      buildings.add(d1.data['buildingName'] + ';-;' + d1.data['buildingDetails']);
    }
    for(int i = 0; i < allBuildings.documents.length; i++) {
      DocumentSnapshot d2 = allBuildings.documents[i];
      ownedBuildings[d2.data['buildingName'] + ';-;' + d2.data['zipcode']] = d2.documentID;
      buildings.add(d2.data['buildingName'] + ';-;' + d2.data['zipcode']);
    }
    return buildings.toList();
  }

  Widget getBody(BuildContext scaffoldC) {
    return FutureBuilder (
      future: getBuildingList(),
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if(!snapshot.hasData) {
          return LoadingContainerVertical(2);
        }
        return ListView.separated(
          separatorBuilder: (BuildContext ctx, int pos){
            return Divider(height: 1.0);
          },
          itemCount: snapshot.data.length,
          itemBuilder: (BuildContext context, int position) {
            List<String> buildingElems = snapshot.data[position].split(';-;');
            return Card(
              child: ListTile(
                onTap: () {navigateToTenantRequests(snapshot.data[position]);},
                title: Text(buildingElems[0]),
                subtitle: Text(buildingElems[1]),
              ),
            );
          },
        );
      },
    );
  }

  void navigateToTenantRequests(String id) async {
    List<String> ownedFlatsList = new List();
    if(ownedBuildings.containsKey(id)) {
      QuerySnapshot flats = await Firestore.instance.collection(globals.ownerFlat).where('buildingId', isEqualTo: ownedBuildings[id]).getDocuments();
      flats.documents.forEach((DocumentSnapshot d) {ownedFlatsList.add(d.documentID);});
    }
    else {
      ownedFlatIds.forEach((String key, String value) {ownedFlatsList.add(value);});
    }

    Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return TenantRequests(this.userId, ownedFlatsList, ownedBuildings[id]);
                  }),
                 );

  }

  

}