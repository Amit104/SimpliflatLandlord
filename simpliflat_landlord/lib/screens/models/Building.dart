import './BaseModel.dart';
import './Block.dart';


class Building extends BaseModel {
  String buildingName;
  String buildingAddress;
  String zipcode;
  String description;
  int type;
  List<String> ownerIdList;
  String buildingDisplayId;
  String buildingId;
  List<Block> blocks;
  List<String> ownerRoleList;
  bool isVerified;

	List<String> getOwnerRoleList() {
		return this.ownerRoleList;
	}

	void setOwnerRoleList(List<String> ownerRoleList) {
		this.ownerRoleList = ownerRoleList;
	}

	bool isIsVerified() {
		return this.isVerified;
	}

	void setIsVerified(bool isVerified) {
		this.isVerified = isVerified;
	}


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

	List<String> getOwnerIdList() {
		return this.ownerIdList;
	}

	void setOwnerIdList(List<String> ownerIdList) {
		this.ownerIdList = ownerIdList;
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
      'ownerIdList': this.ownerIdList,
      'description': this.description,
      'ownerRoleList': this.ownerRoleList,
      'verified': this.isVerified,
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
    List<String> ownerIdList = new List<String>.from(json['ownerIdList']);
    b.setOwnerIdList(ownerIdList);
    b.setBuildingId(documentId);
    List<String> ownerRoleList = new List<String>.from(json['ownerRoleList']);
    b.setOwnerRoleList(ownerRoleList);
    b.setIsVerified(json['verified']);
    List<String> blocks = new List<String>.from(json['blocks']);
    List<Block> blockList = new List();
    blocks.forEach((String blockName) {Block b = new Block(); b.setBlockName(blockName); blockList.add(b);});
    b.setBlock(blockList);

    return b;
  }

}
