import './BaseModel.dart';


class Building extends BaseModel {
  String buildingName;
  String buildingAddress;
  String zipcode;
  String description;
  String type;
  List<String> ownerIdList;
  String buildingDisplayId;

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

	String getType() {
		return this.type;
	}

	void setType(String type) {
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

}
