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



class FlatList extends StatefulWidget {

  final String userId;

  final bool join;

  final Owner owner;

  FlatList(this.userId, this.join, this.owner);

  @override
  State<StatefulWidget> createState() {
    return FlatListState(this.userId, this.join, this.owner);
  }

}

class FlatListState extends State<FlatList> {

  final String userId;

  bool loadingState = false;

  final Owner owner;

  final bool join;

  FlatListState(this.userId, this.join, this.owner);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Flats'),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: <Widget>[Builder(builder: (BuildContext abContext){
                  return Container(padding: EdgeInsets.all(10.0),child:IconButton(icon:Icon(Icons.add), onPressed: () {navigateToCreateProperty(abContext, null);},));

        },),
      ],
      ),
      backgroundColor: Colors.white,
      body: Builder(builder: (BuildContext scaffoldC) {
        return loadingState == true?Container(alignment: Alignment.center, child: CircularProgressIndicator()):
        getBody(scaffoldC);
      }),
    );
  }

  Stream<QuerySnapshot> getFlatList() {
    Query q = Firestore.instance.collection(globals.building).where('verified', isEqualTo: false);


    if(this.owner != null) {
      q = q.where('ownerIdList', arrayContains: this.userId);
    }


    return q.snapshots();
  }

  Widget getBody(BuildContext scaffoldC) {
    return StreamBuilder(
      stream: getFlatList(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snaphot) {
        if(!snaphot.hasData) {
          return LoadingContainerVertical(2);
        }
        return ListView.separated(
          separatorBuilder: (BuildContext ctx, int pos){
            return Divider(height: 1.0);
          },
          itemCount: snaphot.data.documents.length,
          itemBuilder: (BuildContext context, int position) {
            Map<String, dynamic> buildingData = snaphot.data.documents[position].data;
            return Card(
              child: ListTile(
                onTap: () {createDataObjectAndNavigate(buildingData, snaphot.data.documents[position].documentID, scaffoldC);},
                title: Text(buildingData['buildingName']),
                subtitle: Text(buildingData['buildingAddress'] + ' ' + buildingData['zipcode']),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  void navigateToCreateProperty(BuildContext abContext, Building building) async {
    //bool isAdd = building == null;
    /*if(!this.join) {
      bool ifSuccess = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return CreateProperty(this.userId, building, isAdd, this.join);
        }),
      );

      if(ifSuccess) {
        Utility.createErrorSnackBar(abContext, error: 'Saved Successfully!');
      }
    }
    else {*/
      Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return PropertyRequests(this.userId, building, this.owner == null, this.owner);
      }),
    );
    //}
  }

  void createDataObjectAndNavigate(Map<String, dynamic> buildingData, documentId, BuildContext ctx) async {

    setState(() {
          loadingState = true;
        });
    Building b = Building.fromJson(buildingData, documentId);

    List<Block> blocks = b.getBlocks();

    QuerySnapshot snapshot = await Firestore.instance.collection(globals.ownerFlat).getDocuments();

    
    for(int i = 0; i < snapshot.documents.length; i++) {
      OwnerFlat flat = OwnerFlat.fromJson(snapshot.documents[i].data, snapshot.documents[i].documentID);
      Block block = blocks.firstWhere((Block b) { return b.getBlockName() == flat.getBlockName();});
      if(block.getOwnerFlats() == null) {
        block.setOwnerFlats(new List());
      }
      block.getOwnerFlats().add(flat);
    }

    setState(() {
          loadingState = false;
        });

    navigateToCreateProperty(ctx, b);
  }

}