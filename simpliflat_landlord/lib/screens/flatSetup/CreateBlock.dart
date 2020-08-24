import 'package:flutter/material.dart';
import '../models/Building.dart';
import '../models/Block.dart';
import 'package:simpliflat_landlord/screens/globals.dart' as globals;
import 'package:simpliflat_landlord/screens/utility.dart';

class CreateBlock extends StatefulWidget {

  final Function callBack;
  Block block;

  final List<Block> blocks;

  CreateBlock(this.callBack, this.block, this.blocks);

  @override
  State<StatefulWidget> createState() {
    return CreateBlockState(this.block,this.blocks);
  }
}

class CreateBlockState extends State<CreateBlock> {

  @override
  void initState() {
    super.initState();
    
  }

  final _formKey = GlobalKey<FormState>();  

  final TextEditingController nameCtlr = TextEditingController();

  Block block;

  List<Block> blocks;

  CreateBlockState(this.block, this.blocks) {
    if(this.block != null) {
      nameCtlr.text = this.block.getBlockName();
    }
  }

  @override
  Widget build(BuildContext context) {
    return getBody();
  }

  Widget getBody() {
    return Dialog (
          child: Container(
        margin: EdgeInsets.all(10.0),
            child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:<Widget>[
            
            TextFormField(
              controller: nameCtlr,
                decoration: const InputDecoration(  
                  hintText: 'Enter Block name',  
                  labelText: 'Name',
                   
                ),
                validator: (value) {  
                  if (value.isEmpty) {  
                    return 'Please enter block name';  
                  }
                  if(!ifBlockNameUnique(value)) {
                    return 'Block name must be unique';
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
                        bool isEdit = (this.block != null); 
                        if(this.block == null) {
                          this.block = new Block();
                        }
                        
                        this.block.setBlockName(nameCtlr.text);
                        
                       
                       
                        widget.callBack(this.block, isEdit);
                        Navigator.of(context, rootNavigator: true).pop();
                      }  
                    },    
                  )),  
          ],
        )),
      ),
    );
  }

  @override
  void dispose() {
    nameCtlr.dispose();
    super.dispose();
  }

  bool ifBlockNameUnique(String value) {
    if(this.blocks == null) {
      return true;
    }
    for(int i = 0; i < this.blocks.length; i++) {
      if(this.blocks[i].getBlockName() == value) {
        return false;
      }
    }
    return true;
  }

}