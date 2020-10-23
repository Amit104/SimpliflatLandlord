import 'package:flutter/material.dart';
import 'package:simpliflat_landlord/common_widgets/common.dart';
import 'package:simpliflat_landlord/model/building.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;
import 'package:simpliflat_landlord/utility/utility.dart';


/// create building form
class CreateBuilding extends StatefulWidget {

  Building building;

  CreateBuilding(this.building);

  @override
  State<StatefulWidget> createState() {
    return CreateBuildingState(this.building);
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


  Building building;

  CreateBuildingState(this.building) {
    if(this.building != null) {
    isPG = (globals.BuildingType.PG.index == this.building.getType());
    nameCtlr.text = this.building.getBuildingName();
    addressCtlr.text = this.building.getBuildingAddress();
    zipcodeCtlr.text = this.building.getZipcode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()  {Navigator.of(context).pop(this.building);},
          child: Scaffold(
        appBar: AppBar(title: Text('Create Building', style: CommonWidgets.getAppBarTitleStyle()), elevation: 0, centerTitle: true, backgroundColor: Colors.white,),
        backgroundColor: Colors.white,
        body: Builder(builder: (BuildContext scaffoldC) {
          return getBody();
        }),
      ),
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
                    if (_formKey.currentState.validate()) {  
                      createBuilding(addressCtlr.text, nameCtlr.text, zipcodeCtlr.text, isPG);                 
                      debugPrint(this.building.getBuildingName());
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

  createBuilding(String address, String name,
      String zipcode, bool isPG) {
    if (this.building == null) {
      this.building = new Building();
    }
    this.building.setBuildingAddress(address);
    this.building.setBuildingName(name);
    this.building.setZipcode(zipcode);
    if (isPG) {
      this.building.setType(globals.BuildingType.PG.index);
    } else {
      this.building.setType(globals.BuildingType.Residential.index);
    }
    if (this.building.getBuildingDisplayId() == null) {
      this.building.setBuildingDisplayId(Utility.getRandomString(globals.displayIdLength));
    }
  }

}