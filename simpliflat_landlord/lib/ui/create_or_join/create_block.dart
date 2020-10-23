import 'package:flutter/material.dart';
import 'package:simpliflat_landlord/model/block.dart';


/// a dialog box to enter block name
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
        height: 150,
            child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  if(!ifBlockNameUnique(value, this.blocks)) {
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
                        setBlock(nameCtlr.text);
                        debugPrint(this.block.getBlockName());
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

  bool ifBlockNameUnique(String value, List<Block> blocks) {
    if(blocks == null) {
      return true;
    }
    for(int i = 0; i < blocks.length; i++) {
      if(blocks[i].getBlockName() == value) {
        return false;
      }
    }
    return true;
  }

  void setBlock(String value) {
    if(this.block == null) {
      this.block = new Block();
    }
    this.block.setBlockName(value);
  }

}