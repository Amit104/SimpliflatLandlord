


import 'package:simpliflat_landlord/screens/models/BaseModel.dart';
import 'package:simpliflat_landlord/screens/models/Block.dart';

class Building extends BaseModel {
  String buildingName;
  String buildingAddress;
  String zipcode;
  String description;
  int type;
  String buildingDisplayId;
  String buildingId;
  List<Block> blocks;

	String getBuildingName() {
		return this.buildingName;
	}

	void setBuildingName(String buildingName) {
		this.buildingName = buildingName;
	}

	String getBuildingAddress() {
		return this.buildingAddress;
	}

	void setBuildingAddress(String buildingAddress) {
		this.buildingAddress = buildingAddress;
	}

	String getZipcode() {
		return this.zipcode;
	}

	void setZipcode(String zipcode) {
		this.zipcode = zipcode;
	}

	String getDescription() {
		return this.description;
	}

	void setDescription(String description) {
		this.description = description;
	}

	int getType() {
		return this.type;
	}

	void setType(int type) {
		this.type = type;
	}

	String getBuildingDisplayId() {
		return this.buildingDisplayId;
	}

	void setBuildingDisplayId(String buildingDisplayId) {
		this.buildingDisplayId = buildingDisplayId;
	}

  List<Block> getBlocks() {
    return this.blocks;
  }

  void setBlock(List<Block> blocks) {
    this.blocks = blocks;
  }

  String getBuildingId() {
    return this.buildingId;
  }

  void setBuildingId(String buildingId) {
    this.buildingId = buildingId;
  }

  Map<String, dynamic> toJson() {
    List<String> blocknames = new List();
    this.blocks.forEach((Block block) {
      blocknames.add(block.getBlockName());
    });
    return {
      'buildingName': this.buildingName,
      'buildingAddress': this.buildingAddress,
      'zipcode': this.zipcode,
      'type': this.type,
      'buildingDisplayId': this.buildingDisplayId,
      'description': this.description,
      'blocks': blocknames
    };
  }

  static Building fromJson(Map<String, dynamic> json, String documentId) {
    Building b = new Building();
    b.setBuildingName((json['buildingName'] as String));
    b.setBuildingAddress((json['buildingAddress'] as String));
    b.setZipcode((json['zipcode'] as String));
    b.setDescription((json['description'] as String));
    b.setType((json['type'] as int));
    b.setBuildingDisplayId((json['buildingDisplayId'] as String));
    List<String> blocks = new List<String>.from(json['blocks']);
    List<Block> blockList = new List();
    blocks.forEach((String blockName) {Block b = new Block(); b.setBlockName(blockName); blockList.add(b);});
    b.setBlock(blockList);
    b.setBuildingId(documentId);

    return b;
  }

}
