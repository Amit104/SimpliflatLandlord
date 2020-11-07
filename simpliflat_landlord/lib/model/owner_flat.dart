
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/model/base_model.dart';
import 'package:simpliflat_landlord/model/owner.dart';

class OwnerFlat extends BaseModel {
  String buildingId;
  String blockName;
  String flatName;
  List<String> ownerIdList;
  List<String> ownerRoleList;
  String flatDisplayId;
  String flatId;
  String buildingName;
  String buildingAddress;
  String zipcode;
  String buildingDisplayId;
  bool verified;
  List<Owner> owners;
  bool modified;

	bool isModified() {
		return this.modified;
	}

	void setModified(bool modified) {
		this.modified = modified;
	}

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


	/*String getTenantFlatId() {
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
	}*/

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

  List<Owner> getOwners() {
		return this.owners;
	}

	void setOwners(List<Owner> owners) {
		this.owners = owners;
	}

  Map<String, dynamic> toJson() {
    return {
      'flatName': this.flatName,
      'flatDisplayId': this.flatDisplayId,
      'ownerIdList': this.ownerIdList,
      'ownerRoleList': this.ownerRoleList,
      'buildingId': this.buildingId,
      'blockName': this.blockName,
      'buildingName': this.buildingName,
      'verified': this.verified,
      'createdAt': this.createdAt,
      'updatedAt': this.updatedAt,
      'buildingAddress': this.buildingAddress,
      'zipcode': this.zipcode

    };
  }
  
  static OwnerFlat fromJson(Map<String, dynamic> json, String documentId) {
    OwnerFlat flat = new OwnerFlat();
    flat.setFlatDisplayId((json['flatDisplayId'] as String));
    flat.setFlatName((json['flatName'] as String));
    List<String> ownerIdList = new List<String>.from(json['ownerIdList']);
    flat.setOwnerIdList(ownerIdList);
    List<String> ownerRoleList = new List<String>.from(json['ownerRoleList']);
    flat.setOwners(new List());
    try {
    if(ownerRoleList != null) {
      ownerRoleList.forEach((String e) {
        List<String> val = e.split(':');
        Owner o = new Owner();
        o.setOwnerId(val[0]);
        o.setName(val[1]);
        o.setRole(val[2]);
        flat.getOwners().add(o);
      });
    }
    }
    catch(e) {

    }
    flat.setOwnerRoleList(ownerRoleList);
    flat.setFlatId(documentId);
    flat.setBuildingAddress(json['buildingAddress']);
    flat.setBlockName(json['blockName']);
    flat.setBuildingId(json['buildingId']);
    flat.setBuildingName(json['buildingName']);
    flat.setVerified(json['verified']);
    flat.setZipcode(json['zipcode']);
    if(flat.getZipcode() == null) {
      flat.setZipcode(json['buildingDetails']);
    }
    flat.setCreatedAt(json['createdAt']);
    flat.setUpdatedAt(json['updatedAt']);
    return flat;

  }

  static Map<String, dynamic> toUpdateJson({dynamic ownerIdList, dynamic ownerRoleList}) {
    Map<String, dynamic> updateJson = new Map();
    if(ownerIdList != null) updateJson['ownerIdList'] = ownerIdList;
    if(ownerRoleList != null) updateJson['ownerRoleList'] = ownerRoleList;
    updateJson['updatedAt'] = Timestamp.now();
    return updateJson;
  }
}