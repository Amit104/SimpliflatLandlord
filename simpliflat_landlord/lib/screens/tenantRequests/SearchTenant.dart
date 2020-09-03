import 'package:flutter/material.dart';
import 'package:simpliflat_landlord/screens/commonScreens/MyBuildingList.dart';
import 'package:simpliflat_landlord/screens/models/Owner.dart';
import 'package:simpliflat_landlord/screens/models/OwnerFlat.dart';
import 'package:simpliflat_landlord/screens/models/TenantFlat.dart';
import 'package:simpliflat_landlord/service/TenantRequestsService.dart';
import 'package:simpliflat_landlord/screens/globals.dart' as globals;
import 'package:simpliflat_landlord/screens/utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// page to search tenant flat based on its display id
class SearchTenant extends StatefulWidget {

  final Owner user;

  final OwnerFlat ownerFlat;

  SearchTenant(this.user, this.ownerFlat);

  @override
  State<StatefulWidget> createState() {
    return SearchTenantState(this.user, this.ownerFlat);
  }

}

class SearchTenantState extends State<SearchTenant> {

  final Owner user;

  bool loadingState = false;

  bool searched = false;

  TenantFlat flat;

  OwnerFlat ownerFlat;

  bool mandatoryWarning = false;

  final TextEditingController tenantFlatDisplayIdCtlr = new TextEditingController();

  SearchTenantState(this.user, this.ownerFlat) {
    debugPrint("in search tenant");
  }

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
        getUserBox(scaffoldC),
      ],
    );
  }

  Widget getUserBox(BuildContext scaffoldC) {
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
      onTap: () {navigateToMyBuildingList(scaffoldC);},
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
    if(document.documents.length > 0 && document.documents[0].documentID != this.user.getOwnerId()) {
      flatTemp = TenantFlat.fromJson(document.documents[0].data, document.documents[0].documentID);
    }
    
    setState(() {
          this.searched = true;
          this.flat = flatTemp;
        });
  }

  void navigateToMyBuildingList(BuildContext scaffoldC) async {
      /** owner flat is not null in case when owner has initiated request from inside flat */
      if(this.ownerFlat != null) {
        bool ifSuccess = await TenantRequestsService.createTenantRequest(this.ownerFlat, user, this.flat);
        if(ifSuccess) {
          Navigator.of(context).pop();
        }
        else {
          Utility.createErrorSnackBar(scaffoldC, error: 'Error while creating request');
        }
      }
      /** owner flat is null when owner has initiated request from home */
      else {
        Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return MyBuildingList(this.user, this.flat, null);
      }),
    );
      }

      
  }
  


}