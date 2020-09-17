import 'package:flutter/material.dart';
import 'package:simpliflat_landlord/screens/createOrJoin/JoinProperty.dart';
import 'package:simpliflat_landlord/screens/createOrJoin/createProperty.dart';
import 'package:simpliflat_landlord/screens/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/screens/models/Block.dart';
import 'package:simpliflat_landlord/screens/models/Building.dart';
import 'package:simpliflat_landlord/screens/models/Owner.dart';
import 'package:simpliflat_landlord/screens/models/OwnerFlat.dart';
import 'package:simpliflat_landlord/screens/widgets/loading_container.dart';


/// list of all buildings
class FlatList extends StatefulWidget {

  final Owner user;

  final bool join;


  FlatList(this.user, this.join);

  @override
  State<StatefulWidget> createState() {
    return FlatListState(this.user, this.join);
  }

}

class FlatListState extends State<FlatList> {

  final Owner user;

  bool loadingState = false;

  final bool join;

  Stream<QuerySnapshot> allFlatsStream;

  FlatListState(this.user, this.join);

  @override
  void initState() {
    super.initState();
    allFlatsStream = Firestore.instance.collection(globals.building).snapshots();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Flats'),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: <Widget>[Builder(builder: (BuildContext abContext){
                  return this.join?SizedBox():Container(padding: EdgeInsets.all(10.0),child:IconButton(icon:Icon(Icons.add), onPressed: () {navigateToCreateProperty(abContext, null);},));

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

  Widget getBody(BuildContext scaffoldC) {
    return StreamBuilder(
      stream: allFlatsStream,
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
    bool isAdd = building == null;
    if(this.join) {
      

      Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return JoinProperty(this.user, building);
      }),
    );

    }
    else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return CreateProperty(this.user, building, isAdd);
        }),
      );
    }
  }

  void createDataObjectAndNavigate(Map<String, dynamic> buildingData, documentId, BuildContext ctx) async {
    debugPrint("navigating");
    setState(() {
          loadingState = true;
        });
    Building b = Building.fromJson(buildingData, documentId);

    List<Block> blocks = b.getBlocks();

    Query query = Firestore.instance.collection(globals.ownerFlat).where('buildingId', isEqualTo: documentId);
    //query = query.where('verified', isEqualTo: false);

    QuerySnapshot snapshot = await query.getDocuments();

    
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

    setState(() {
          loadingState = false;
        });

    navigateToCreateProperty(ctx, b);
  }

}