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
import '../models/TenantFlat.dart';
import './CreateTenantRequest.dart';


class MyBuildingList extends StatefulWidget {

  final String userId;

  final TenantFlat tenantFlat;

  MyBuildingList(this.userId, this.tenantFlat);

  @override
  State<StatefulWidget> createState() {
    return MyBuildingListState(this.userId, this.tenantFlat);
  }

}

class MyBuildingListState extends State<MyBuildingList> {

  final String userId;

  bool loadingState = false;

  TenantFlat tenantFlat;

  Map<String, String> ownedBuildings = new Map();

  Map<String, String> ownedFlatIds = new Map();


  MyBuildingListState(this.userId, this.tenantFlat);

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
                onTap: () {navigateToCreateTenantRequest(snapshot.data[position]);},
                title: Text(buildingElems[0]),
                subtitle: Text(buildingElems[1]),
              ),
            );
          },
        );
      },
    );
  }

  void navigateToCreateTenantRequest(String id) async {
    
    String documentId = this.ownedFlatIds[id];

    if(documentId == null) {
      documentId = this.ownedBuildings[id];
    }

    Building b = new Building();
    b.setBuildingName(id.split(';-;')[0]);
    b.setZipcode(id.split(';-;')[1]);
    b.setBuildingId(documentId);

    List<Block> blocks = b.getBlocks();

    QuerySnapshot snapshot = await Firestore.instance.collection(globals.ownerFlat).where('buildingId', isEqualTo: documentId).getDocuments();

    
    for(int i = 0; i < snapshot.documents.length; i++) {
      OwnerFlat flat = OwnerFlat.fromJson(snapshot.documents[i].data, snapshot.documents[i].documentID);
      Block block = blocks.firstWhere((Block b) { return b.getBlockName() == flat.getBlockName();}, orElse: () {return null;});
      if(block != null) {
        if(block.getOwnerFlats() == null) {
          block.setOwnerFlats(new List());
        }
        block.getOwnerFlats().add(flat);
      }
    }
    Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return CreateTenantRequest(this.userId, b, this.tenantFlat);
                  }),
                 );

  }

  

}