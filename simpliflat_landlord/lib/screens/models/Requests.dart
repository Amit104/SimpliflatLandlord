import './BaseModel.dart';

class Requests extends BaseModel {
  String flatId;
  String status;
  String buildingAddress;
  String buildingName;
  String buildingId;
  String buildingDisplayId;
  String blockName;
  String blockId;
  String blockDisplayId;
  String zipcode;
  String flatNumber;
  String flatDisplayId;
  String phone;
  bool requestToOwner;
  String tenantId;

	String getFlatId() {
		return this.flatId;
	}

	void setFlatId(String flatId) {
		this.flatId = flatId;
	}

	String getStatus() {
		return this.status;
	}

	void setStatus(String status) {
		this.status = status;
	}

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

	String getBlockName() {
		return this.blockName;
	}

	void setBlockName(String blockName) {
		this.blockName = blockName;
	}

	String getBlockId() {
		return this.blockId;
	}

	void setBlockId(String blockId) {
		this.blockId = blockId;
	}

	String getBlockDisplayId() {
		return this.blockDisplayId;
	}

	void setBlockDisplayId(String blockDisplayId) {
		this.blockDisplayId = blockDisplayId;
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

	String getFlatDisplayId() {
		return this.flatDisplayId;
	}

	void setFlatDisplayId(String flatDisplayId) {
		this.flatDisplayId = flatDisplayId;
	}

	String getPhone() {
		return this.phone;
	}

	void setPhone(String phone) {
		this.phone = phone;
	}

	bool isRequestToOwner() {
		return this.requestToOwner;
	}

	void setRequestToOwner(bool requestToOwner) {
		this.requestToOwner = requestToOwner;
	}

	String getTenantId() {
		return this.tenantId;
	}

	void setTenantId(String tenantId) {
		this.tenantId = tenantId;
	}


}