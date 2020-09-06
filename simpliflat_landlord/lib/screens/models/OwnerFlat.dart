
import 'package:simpliflat_landlord/screens/models/BaseModel.dart';

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
  String tenantFlatId;
  String tenantFlatName;
  String apartmentTenantId;
  String buildingAddress;
  String zipcode;
  String buildingDisplayId;
  bool verified;

	bool isVerified() {
		return this.verified;
	}

	void setVerified(bool verified) {
		this.verified = verified;
	}

	String getBuildingAddress() {
		return this.buildingAddress;
	}

	void setBuildingAddress(String buildingAddress) {
		this.buildingAddress = buildingAddress;
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


	String getTenantFlatId() {
		return this.tenantFlatId;
	}

	void setTenantFlatId(String tenantFlatId) {
		this.tenantFlatId = tenantFlatId;
	}

	String getTenantFlatName() {
		return this.tenantFlatName;
	}

	void setTenantFlatName(String tenantFlatName) {
		this.tenantFlatName = tenantFlatName;
	}

  String getApartmentTenantId() {
		return this.apartmentTenantId;
	}

	void setApartmentTenantId(String apartmentTenantId) {
		this.apartmentTenantId = apartmentTenantId;
	}

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
      'buildingName': this.buildingName,
      'verified': this.verified

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
    flat.setVerified(json['verified']);
    return flat;

  }


}