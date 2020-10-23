import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/common_widgets/common.dart';
import 'package:simpliflat_landlord/dao/tenant_flat_dao.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/model/owner_flat.dart';
import 'package:simpliflat_landlord/model/tenant_flat.dart';
import 'package:simpliflat_landlord/services/tenant_requests_service.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;
import 'package:simpliflat_landlord/utility/utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/ui/common_screens/my_building_list.dart';

/// page to search tenant flat based on its display id
class SearchTenant extends StatefulWidget {


  final OwnerFlat ownerFlat;

  SearchTenant(this.ownerFlat);

  @override
  State<StatefulWidget> createState() {
    return SearchTenantState(this.ownerFlat);
  }

}

class SearchTenantState extends State<SearchTenant> {


  bool loadingState = false;

  bool searched = false;

  TenantFlat flat;

  OwnerFlat ownerFlat;

  bool mandatoryWarning = false;

  final TextEditingController tenantFlatDisplayIdCtlr = new TextEditingController();

  SearchTenantState(this.ownerFlat) {
    debugPrint("in search tenant");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Tenant', style: CommonWidgets.getAppBarTitleStyle()),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
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
        trailing: Icon(Icons.keyboard_arrow_right, color: Color(0xff2079FF),),
        contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 35.0),
        onTap: () {navigateToMyBuildingList(scaffoldC);},
        title: Text(this.flat.getFlatName(), style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 20.0),),
      );
  }

  Widget getSearchBox() {
    return Container(
          margin: EdgeInsets.symmetric(vertical: 15.0, horizontal:  10.0),
          decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.all(Radius.circular(10.0))),
          child: Row(
        children: <Widget>[
          Expanded(child: TextField(controller: tenantFlatDisplayIdCtlr, onChanged: (String val) { if(this.flat != null)  {setState(() {
                     this.flat = null;
                  });}
                  setState(() {
                                              this.searched = false;
                                              this.mandatoryWarning = false;  
                                  }); } , decoration: InputDecoration(border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        contentPadding:
            EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),labelText: 'Display Id', hintText: 'Enter Display Id', labelStyle: TextStyle(color: mandatoryWarning?Colors.red:Color(0xff2079FF))),)),
          Container(
            child:IconButton(icon: Icon(Icons.search), onPressed: () {getTenantFlatFromId();},)
          ),
        ],
      ),
    );
  }

  void getTenantFlatFromId() async {
    User user = Provider.of<User>(context, listen: false);
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
    //TODO: in below query check if tenant flat is already assigned to some ownerflat, if yes, then dont show it or show that it is already linked
    QuerySnapshot document = await TenantFlatDao.getByDisplayId(displayId);
  
    setState(() {
          this.loadingState = false;
        });

    TenantFlat flatTemp;
    if(document.documents.length > 0 && document.documents[0].documentID != user.getUserId()) {
      flatTemp = TenantFlat.fromJson(document.documents[0].data, document.documents[0].documentID);
    }
    
    setState(() {
          this.searched = true;
          this.flat = flatTemp;
        });
  }

  void navigateToMyBuildingList(BuildContext scaffoldC) async {
    User user = Provider.of<User>(context, listen: false);
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
        return MyBuildingList(this.flat, null, false);
      }),
    );
      }

      
  }
  


}