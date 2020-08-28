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
import './FlatList.dart';
import '../models/TenantFlat.dart';
import './MyBuildingList.dart';



class SearchTenant extends StatefulWidget {

  final String userId;

  SearchTenant(this.userId);

  @override
  State<StatefulWidget> createState() {
    return SearchTenantState(this.userId);
  }

}

class SearchTenantState extends State<SearchTenant> {

  final String userId;

  bool loadingState = false;

  bool searched = false;

  TenantFlat flat;

  bool mandatoryWarning = false;

  final TextEditingController tenantFlatDisplayIdCtlr = new TextEditingController();

  SearchTenantState(this.userId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Owner'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Builder(builder: (BuildContext scaffoldC) {
        return getBody(scaffoldC);
      }),
    );
  }

  Widget getBody(BuildContext scaffoldC) {

    return Column(
      children: <Widget>[
        getSearchBox(),
        getUserBox(),
      ],
    );
  }

  Widget getUserBox() {
    if(this.loadingState) {
      return Container(alignment: Alignment.center, child: CircularProgressIndicator(),);
    }
    if(this.flat == null && searched) {
      return Container(alignment: Alignment.center, child: Text('No results found'));
    }
    else if(this.flat == null) {
      return Container();
    }
    return ListTile(
      onTap: navigateToMyBuildingList,
      title: Text(this.flat.getFlatName()),
    );
  }

  Widget getSearchBox() {
    return Row(
      children: <Widget>[
        Expanded(child: TextField(controller: tenantFlatDisplayIdCtlr, onChanged: (String val) { if(this.flat != null)  {setState(() {
                   this.flat = null;
                });}
                setState(() {
                                            this.searched = false;
                                            this.mandatoryWarning = false;  
                                }); } , decoration: InputDecoration(labelText: 'Display Id', hintText: 'Enter Display Id', labelStyle: TextStyle(color: mandatoryWarning?Colors.red:Colors.grey)),)),
        Container(
          child:IconButton(icon: Icon(Icons.search), onPressed: () {getTenantFlatFromId();},)
        ),
      ],
    );
  }

  void getTenantFlatFromId() async {
        String displayId = this.tenantFlatDisplayIdCtlr.text;
        debugPrint(displayId);
    if(displayId == null || displayId == '') {
      debugPrint('mandatory warning set');
      setState(() {
              this.mandatoryWarning = true;
            });
      return;
    }
    setState(() {
          this.loadingState = true;
        });
    QuerySnapshot document = await Firestore.instance.collection(globals.flat).where('display_id', isEqualTo: displayId).getDocuments();
  
    setState(() {
          this.loadingState = false;
        });

    TenantFlat flatTemp;
    if(document.documents.length > 0 && document.documents[0].documentID != this.userId) {
      flatTemp = TenantFlat.fromJson(document.documents[0].data, document.documents[0].documentID);
    }
    
    setState(() {
          this.searched = true;
          this.flat = flatTemp;
        });
  }

  void navigateToMyBuildingList() async {
    
  
      Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return MyBuildingList(this.userId, this.flat);
      }),
    );
  }
  


}