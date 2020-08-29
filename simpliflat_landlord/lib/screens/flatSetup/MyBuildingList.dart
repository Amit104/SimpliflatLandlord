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
import '../models/Owner.dart';


class MyBuildingList extends StatefulWidget {

  final String userId;

  final TenantFlat tenantFlat;

  final Owner owner;

  MyBuildingList(this.userId, this.tenantFlat, this.owner);

  @override
  State<StatefulWidget> createState() {
    return MyBuildingListState(this.userId, this.tenantFlat, this.owner);
  }

}

class MyBuildingListState extends State<MyBuildingList> {

  final String userId;

  bool loadingState = false;

  TenantFlat tenantFlat;

  Owner owner;

  Map<String, List<OwnerFlat>> ownedFlatIds = new Map();


  MyBuildingListState(this.userId, this.tenantFlat, this.owner);

  @override
  Widget build(BuildContext context) {
    debugPrint(this.userId);
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

  Future<List<OwnerFlat>> getBuildingList() async {
    ownedFlatIds = new Map();
    QuerySnapshot allFlats = await Firestore.instance.collection(globals.ownerFlat).where('ownerIdList', arrayContains:  this.userId).getDocuments();
    List<OwnerFlat> buildings = new List();
    for(int i = 0; i < allFlats.documents.length; i++) {
      DocumentSnapshot d1 = allFlats.documents[i];
      OwnerFlat flatTemp = OwnerFlat.fromJson(d1.data, d1.documentID);
      if(ownedFlatIds[flatTemp.getBuildingId()] == null) {
        ownedFlatIds[flatTemp.getBuildingId()] = new List();
      }
      ownedFlatIds[flatTemp.getBuildingId()].add(flatTemp);
      OwnerFlat alreadyAdded = buildings.firstWhere((OwnerFlat b) {
        return (b.getBuildingId() == d1.data['buildingId']);
      }, orElse: () {return null;});
      if(alreadyAdded == null) {
        buildings.add(flatTemp);
      }
    }
    return buildings;
  }

  Widget getBody(BuildContext scaffoldC) {
    return FutureBuilder (
      future: getBuildingList(),
      builder: (BuildContext context, AsyncSnapshot<List<OwnerFlat>> buildings) {
        if(!buildings.hasData) {
          return LoadingContainerVertical(2);
        }
        return ListView.separated(
          separatorBuilder: (BuildContext ctx, int pos){
            return Divider(height: 1.0);
          },
          itemCount: buildings.data.length,
          itemBuilder: (BuildContext context, int position) {
            return Card(
              child: ListTile(
                onTap: () {navigate(buildings.data[position]);},
                title: Text(buildings.data[position].getBuildingName()),
                subtitle: Text(buildings.data[position].getBuildingDetails()),
              ),
            );
          },
        );
      },
    );
  }

  void navigate(OwnerFlat flat) async {
    

    Building b = new Building();
    b.setBuildingName(flat.getBuildingName());
    b.setZipcode(flat.getBuildingDetails());
    b.setBuildingId(flat.getBuildingId());

    List<Block> blocks = new List();

  
    List<OwnerFlat> flats = ownedFlatIds[flat.getBuildingId()];

    debugPrint(flats.length.toString());
    for(int i = 0; i < flats.length; i++) {

      OwnerFlat flat = flats[i];
      
      Block block = blocks.firstWhere((Block b) { return b.getBlockName() == flat.getBlockName();}, orElse: () {return null;});
      if(block == null) {
        block = new Block();
        block.setBlockName(flats[i].getBlockName());
        blocks.add(block);
      }
      if(block != null) {
        if(block.getOwnerFlats() == null) {
          block.setOwnerFlats(new List());
        }
        block.getOwnerFlats().add(flat);
      }
    }


    b.setBlock(blocks);


    if(this.tenantFlat !=null) {
      Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return CreateTenantRequest(this.userId, b, this.tenantFlat);
                  }),
                 );
    }
    else if(this.owner != null) {
      Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return PropertyRequests(this.userId, b, this.owner);
                  }),
                 );
    }

  }

  

}