import './BaseModel.dart';

class OwnerFlat extends BaseModel {
  String buildingDetails;
  String buildingId;
  String blockName;
  String flatName;
  List<String> ownerIdList;
  List<String> ownerRoleList;
  String flatDisplayId;
  String flatId;
  String buildingName;

	String getBuildingDetails() {
		return this.buildingDetails;
	}

	void setBuildingDetails(String buildingDetails) {
		this.buildingDetails = buildingDetails;
	}

	String getBuildingId() {
		return this.buildingId;
	}

	void setBuildingId(String buildingId) {
		this.buildingId = buildingId;
	}

  String getBuildingName() {
		return this.buildingName;
	}

	void setBuildingName(String buildingName) {
		this.buildingName = buildingName;
	}

	String getFlatName() {
		return this.flatName;
	}

	void setFlatName(String flatName) {
		this.flatName = flatName;
	}

	List<String> getOwnerIdList() {
		return this.ownerIdList;
	}

	void setOwnerIdList(List<String> ownerIdList) {
		this.ownerIdList = ownerIdList;
	}

	List<String> getOwnerRoleList() {
		return this.ownerRoleList;
	}

	void setOwnerRoleList(List<String> ownerRoleList) {
		this.ownerRoleList = ownerRoleList;
	}

	String getFlatDisplayId() {
		return this.flatDisplayId;
	}

	void setFlatDisplayId(String flatDisplayId) {
		this.flatDisplayId = flatDisplayId;
	}

	String getBlockName() {
		return this.blockName;
	}

	void setBlockName(String blockName) {
		this.blockName = blockName;
	}

  String getFlatId() {
		return this.flatId;
	}

	void setFlatId(String flatId) {
		this.flatId = flatId;
	}

  Map<String, dynamic> toJson() {
    return {
      'flatName': this.flatName,
      'flatDisplayId': this.flatDisplayId,
      'ownerIdList': this.ownerIdList,
      'ownerRoleList': this.ownerRoleList,
      'buildingDetails': this.buildingDetails,
      'buildingId': this.buildingId,
      'blockName': this.blockName,
      'buildingName': this.buildingName

    };
  }
  
  static OwnerFlat fromJson(Map<String, dynamic> json, String documentId) {
    OwnerFlat flat = new OwnerFlat();
    flat.setFlatDisplayId((json['flatDisplayId'] as String));
    flat.setFlatName((json['flatName'] as String));
    List<String> ownerIdList = new List<String>.from(json['ownerIdList']);
    flat.setOwnerIdList(ownerIdList);
    List<String> ownerRoleList = new List<String>.from(json['ownerRoleList']);
    flat.setOwnerRoleList(ownerRoleList);
    flat.setFlatId(documentId);
    flat.setBuildingDetails(json['buildingDetails']);
    flat.setBlockName(json['blockName']);
    flat.setBuildingId(json['buildingId']);
    flat.setBuildingName(json['buildingName']);
    return flat;

  }


}