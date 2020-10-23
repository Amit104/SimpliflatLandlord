import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/common_widgets/common.dart';
import 'package:simpliflat_landlord/dao/owner_dao.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/model/owner.dart';
import 'package:simpliflat_landlord/model/owner_flat.dart';
import 'package:simpliflat_landlord/services/owner_requests_service.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;
import 'package:simpliflat_landlord/utility/utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/ui/common_screens/my_building_list.dart';

/// page to search a owner user based on phone number
class SearchOwner extends StatefulWidget {

 

  final OwnerFlat ownerFlat;

  SearchOwner(this.ownerFlat);

  @override
  State<StatefulWidget> createState() {
    return SearchOwnerState(this.ownerFlat);
  }

}

class SearchOwnerState extends State<SearchOwner> {

  //final Owner user;

  final OwnerFlat ownerFlat;

  bool loadingState = false;


  bool searched = false;

  Owner owner;

  bool mandatoryWarning = false;

  final TextEditingController ownerPhoneController = new TextEditingController();

  SearchOwnerState(this.ownerFlat);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Owner', style: CommonWidgets.getAppBarTitleStyle(),),
        elevation: 0,
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
    if(this.owner == null && searched) {
      return Container(alignment: Alignment.center, child: Text('No results found'));
    }
    else if(this.owner == null) {
      return Container();
    }
    return ListTile(
       trailing: Icon(Icons.keyboard_arrow_right, color: Color(0xff2079FF),),
        contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 35.0),
        title: Text(this.owner.getName(), style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 20.0),),
      
        onTap: () {navigateToFlatList(scaffoldC);},
        subtitle: Text(this.owner.getPhone()),
      );
  }

  Widget getSearchBox() {
    return Container(
          margin: EdgeInsets.symmetric(vertical: 15.0, horizontal:  10.0),
          decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.all(Radius.circular(10.0))),
          child: Row(
        children: <Widget>[
          Expanded(child: TextField(controller: ownerPhoneController, onChanged: (String val) { if(this.owner != null)  {setState(() {
                     this.owner = null;
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
            EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),labelText: 'Phone Number', hintText: 'Enter Phone Number', labelStyle: TextStyle(color: mandatoryWarning?Colors.red:Color(0xff2079FF))),)),
          Container(
            child:IconButton(icon: Icon(Icons.search), onPressed: () {getUserFromPhoneNumber();},)
          ),
        ],
      ),
    );
  }

  void getUserFromPhoneNumber() async {
    User user = Provider.of<User>(context, listen: false);
        String phoneNumber = this.ownerPhoneController.text;
        debugPrint(phoneNumber);
    if(phoneNumber == null || phoneNumber == '') {
      setState(() {
              this.mandatoryWarning = true;
            });
      return;
    }
    setState(() {
          this.loadingState = true;
        });
    QuerySnapshot document = await OwnerDao.getOwnerByPhoneNumber(phoneNumber);
  
    setState(() {
          this.loadingState = false;
        });

    Owner ownerTemp;
    if(document.documents.length > 0 && document.documents[0].documentID != user.getUserId()) {
      ownerTemp = Owner.fromJson(document.documents[0].data, document.documents[0].documentID);
    }
    
    setState(() {
          this.searched = true;
          this.owner = ownerTemp;
        });
  }

  void navigateToFlatList(BuildContext ctx) async {
    User user = Provider.of<User>(context, listen: false);
      /** owner flat is not null in case when trying to add owner from within flat */
      if(this.ownerFlat != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          child: AlertDialog(
            title: Text('Confirm'),
            content: Text('Add owner to flat?'),
            actions: <Widget>[
              RaisedButton(
                onPressed: () {
                  sendRequestToCoOwner(ctx);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('Confirm'),
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              )
            ],
          ),
        );
      }
      else {
        Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return MyBuildingList(null, this.owner, false);
        }),
      );
      }
  }

  void sendRequestToCoOwner(BuildContext ctx) async {
    User user = Provider.of<User>(context, listen: false);
    setState(() {
      this.loadingState = true;
    });
    

    bool ifSuccess = await OwnerRequestsService.sendRequestToCoOwner(this.ownerFlat, user, this.owner);

    if(ifSuccess) {
      setState(() {
        this.loadingState = false;
      });
      Utility.createErrorSnackBar(ctx, error: 'Request created successfully');
    } else {
      setState(() {
        this.loadingState = false;
      });
      Utility.createErrorSnackBar(ctx, error: 'Error while creating request');
    }
  }
  


}