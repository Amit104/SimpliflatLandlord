import 'package:flutter/material.dart';
import 'package:simpliflat_landlord/screens/commonScreens/MyBuildingList.dart';
import 'package:simpliflat_landlord/screens/models/Owner.dart';
import 'package:simpliflat_landlord/screens/models/OwnerFlat.dart';
import 'package:simpliflat_landlord/service/OwnerRequestsService.dart';
import 'package:simpliflat_landlord/screens/globals.dart' as globals;
import 'package:simpliflat_landlord/screens/utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// page to search a owner user based on phone number
class SearchOwner extends StatefulWidget {

  final Owner user;

  final OwnerFlat ownerFlat;

  SearchOwner(this.user, this.ownerFlat);

  @override
  State<StatefulWidget> createState() {
    return SearchOwnerState(this.user, this.ownerFlat);
  }

}

class SearchOwnerState extends State<SearchOwner> {

  final Owner user;

  final OwnerFlat ownerFlat;

  bool loadingState = false;


  bool searched = false;

  Owner owner;

  bool mandatoryWarning = false;

  final TextEditingController ownerPhoneController = new TextEditingController();

  SearchOwnerState(this.user, this.ownerFlat);

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
    if(this.owner == null && searched) {
      return Container(alignment: Alignment.center, child: Text('No results found'));
    }
    else if(this.owner == null) {
      return Container();
    }
    return ListTile(
      onTap: () {navigateToFlatList(scaffoldC);},
      title: Text(this.owner.getName()),
      subtitle: Text(this.owner.getPhone()),
    );
  }

  Widget getSearchBox() {
    return Row(
      children: <Widget>[
        Expanded(child: TextField(controller: ownerPhoneController, onChanged: (String val) { if(this.owner != null)  {setState(() {
                   this.owner = null;
                });}
                setState(() {
                                            this.searched = false;
                                            this.mandatoryWarning = false;  
                                }); } , decoration: InputDecoration(labelText: 'Phone number', hintText: 'Enter Phone number', labelStyle: TextStyle(color: mandatoryWarning?Colors.red:Colors.grey)),)),
        Container(
          child:IconButton(icon: Icon(Icons.search), onPressed: () {getUserFromPhoneNumber();},)
        ),
      ],
    );
  }

  void getUserFromPhoneNumber() async {
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
    QuerySnapshot document = await Firestore.instance.collection(globals.landlord).where('phone', isEqualTo: phoneNumber).getDocuments();
  
    setState(() {
          this.loadingState = false;
        });

    Owner ownerTemp;
    if(document.documents.length > 0 && document.documents[0].documentID != this.user.getOwnerId()) {
      ownerTemp = Owner.fromJson(document.documents[0].data, document.documents[0].documentID);
    }
    
    setState(() {
          this.searched = true;
          this.owner = ownerTemp;
        });
  }

  void navigateToFlatList(BuildContext ctx) async {
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
          return MyBuildingList(this.user, null, this.owner);
        }),
      );
      }
  }

  void sendRequestToCoOwner(BuildContext ctx) async {
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