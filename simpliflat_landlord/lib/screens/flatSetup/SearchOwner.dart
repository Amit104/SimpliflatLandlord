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
import './FlatList.dart';



class SearchOwner extends StatefulWidget {

  final String userId;

  final bool join;

  SearchOwner(this.userId, this.join);

  @override
  State<StatefulWidget> createState() {
    return SearchOwnerState(this.userId, this.join);
  }

}

class SearchOwnerState extends State<SearchOwner> {

  final String userId;

  bool loadingState = false;

  final bool join;

  bool searched = false;

  Owner owner;

  bool mandatoryWarning = false;

  final TextEditingController ownerPhoneController = new TextEditingController();

  SearchOwnerState(this.userId, this.join);

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
    if(this.owner == null && searched) {
      return Container(alignment: Alignment.center, child: Text('No results found'));
    }
    else if(this.owner == null) {
      return Container();
    }
    return ListTile(
      onTap: navigateToFlatList,
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
      debugPrint('mandatory warning set');
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
    if(document.documents.length > 0 && document.documents[0].documentID != this.userId) {
      ownerTemp = Owner.fromJson(document.documents[0].data, document.documents[0].documentID);
    }
    
    setState(() {
          this.searched = true;
          this.owner = ownerTemp;
        });
  }

  void navigateToFlatList() async {
    
  
      Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return FlatList(this.userId, true, this.owner);
      }),
    );
  }
  


}