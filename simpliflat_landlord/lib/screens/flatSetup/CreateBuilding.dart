import 'package:flutter/material.dart';
import '../models/Building.dart';
import 'package:simpliflat_landlord/screens/globals.dart' as globals;
import 'package:simpliflat_landlord/screens/utility.dart';
import 'dart:math';

class CreateBuilding extends StatefulWidget {

  final String userId;
  Building building;

  CreateBuilding(this.userId, this.building);

  @override
  State<StatefulWidget> createState() {
    return CreateBuildingState(this.userId, this.building);
  }
}

class CreateBuildingState extends State<CreateBuilding> {

  @override
  void initState() {
    super.initState();
    
  }

  final _formKey = GlobalKey<FormState>();  

  bool isPG = false;

  final TextEditingController nameCtlr = TextEditingController();
  final TextEditingController addressCtlr = TextEditingController();
  final TextEditingController zipcodeCtlr = TextEditingController();

  final String userId;

  Building building;

  CreateBuildingState(this.userId, this.building) {
    if(this.building != null) {
    isPG = (globals.BuildingType.PG.index == this.building.getType());
    nameCtlr.text = this.building.getBuildingName();
    addressCtlr.text = this.building.getBuildingAddress();
    zipcodeCtlr.text = this.building.getZipcode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Building'), centerTitle: true, backgroundColor: Colors.white,),
      backgroundColor: Colors.white,
      body: Builder(builder: (BuildContext scaffoldC) {
        return getBody();
      }),
    );
  }

  Widget getBody() {
    return Container(
      margin: EdgeInsets.all(10.0),
          child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:<Widget>[
          CheckboxListTile(value: isPG, title: Text('is the building a PG'), onChanged: (val) {setState(() {
                      isPG = !isPG;
                    });}),
          SizedBox(height: 10.0,),
          TextFormField(
            controller: nameCtlr,
              decoration: const InputDecoration(  
                hintText: 'Enter building name',  
                labelText: 'Name',
                 
              ),
              validator: (value) {  
                if (value.isEmpty) {  
                  return 'Please enter building name';  
                }  
                return null;  
              },    
            ),
            SizedBox(height: 10.0,),
           TextFormField(  
             controller: addressCtlr,
              decoration: const InputDecoration(  
                hintText: 'Enter building address',  
                labelText: 'Address',  
              ),  
               validator: (value) {  
                if (value.isEmpty) {  
                  return 'Please enter building address';  
                }  
                return null;  
              },  
            ),  
            SizedBox(height: 10.0,),
            TextFormField(  
              controller: zipcodeCtlr,
              decoration: const InputDecoration(  
              hintText: 'Enter zipcode',  
              labelText: 'Zipcode',  
              ),  
              validator: (value) {  
                if (value.isEmpty) {  
                  return 'Please enter zipcode';  
                }  
                return null;  
              },  
             ),  
            new Container(  
                padding: const EdgeInsets.only(left: 150.0, top: 40.0),  
                child: new RaisedButton(  
                  child: const Text('Done'),  
                   onPressed: () {  
                    // It returns true if the form is valid, otherwise returns false  
                    if (_formKey.currentState.validate()) {  
                      // If the form is valid, display a Snackbar.  
                      if(this.building == null) {
                        this.building = new Building();
                      }
                      this.building.setBuildingAddress(addressCtlr.text);
                      this.building.setBuildingName(nameCtlr.text);
                      this.building.setZipcode(zipcodeCtlr.text);
                      if(isPG) {
                        this.building.setType(globals.BuildingType.PG.index);
                      }
                      else {
                        this.building.setType(globals.BuildingType.Residential.index);
                      }
                      if(this.building.getBuildingDisplayId() == null) {
                        this.building.setBuildingDisplayId(Utility.getRandomString(globals.displayIdLength));
                      }
                      List<String> owners = new List();
                      owners.add(this.userId);
                      List<String> ownerRoles = new List();
                      ownerRoles.add(this.userId + ":" + globals.OwnerRoles.Admin.index.toString());
                      this.building.setOwnerIdList(owners);
                      this.building.setOwnerRoleList(ownerRoles);
                      this.building.setIsVerified(false);
                      
                      Navigator.of(context).pop(this.building);
                    }  
                  },    
                )),  
        ],
      )),
    );
  }

  @override
  void dispose() {
    nameCtlr.dispose();
    addressCtlr.dispose();
    zipcodeCtlr.dispose();
    super.dispose();
  }

}