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

  Future<List<Map<String, dynamic>>> getBuildingList() async {
    List<Map<String, dynamic>> result = await OwnershipDetailsDBHelper.instance.queryAllOwnerBuildings();
    debugPrint(result.length.toString());
    return result;
  }

  Widget getBody(BuildContext scaffoldC) {
    return FutureBuilder(
      future: getBuildingList(),
      builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snaphot) {
        if(!snaphot.hasData) {
          return LoadingContainerVertical(2);
        }
        return ListView.separated(
          separatorBuilder: (BuildContext ctx, int pos){
            return Divider(height: 1.0);
          },
          itemCount: snaphot.data.length,
          itemBuilder: (BuildContext context, int position) {
            Map<String, dynamic> buildingData = snaphot.data[position];
            return Card(
              child: ListTile(
                title: Text(buildingData['buildingName'].toString()),
              ),
            );
          },
        );
      },
    );
  }

  

}