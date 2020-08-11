import './BaseModel.dart';

class OwnerFlat extends BaseModel {
  String buildingAddress;
  String buildingName;
  String buildingId;
  String buildingDisplayId;
  String blockName;
  String blockDisplayId;
  String blockId;
  String zipcode;
  String flatNumber;
  List<String> ownerIdList;
  List<String> ownerRoleList;
  String flatDisplayId;

	String getBuildingAddress() {
		return this.buildingAddress;
	}

	void setBuildingAddress(String buildingAddress) {
		this.buildingAddress = buildingAddress;
	}

	String getBuildingName() {
		return this.buildingName;
	}

	void setBuildingName(String buildingName) {
		this.buildingName = buildingName;
	}

	String getBuildingId() {
		return this.buildingId;
	}

	void setBuildingId(String buildingId) {
		this.buildingId = buildingId;
	}

	String getBuildingDisplayId() {
		return this.buildingDisplayId;
	}

	void setBuildingDisplayId(String buildingDisplayId) {
		this.buildingDisplayId = buildingDisplayId;
	}

	String getZipcode() {
		return this.zipcode;
	}

	void setZipcode(String zipcode) {
		this.zipcode = zipcode;
	}

	String getFlatNumber() {
		return this.flatNumber;
	}

	void setFlatNumber(String flatNumber) {
		this.flatNumber = flatNumber;
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

	String getBlockDisplayId() {
		return this.blockDisplayId;
	}

	void setBlockDisplayId(String blockDisplayId) {
		this.blockDisplayId = blockDisplayId;
	}

	String getBlockId() {
		return this.blockId;
	}

	void setBlockId(String blockId) {
		this.blockId = blockId;
	}


}