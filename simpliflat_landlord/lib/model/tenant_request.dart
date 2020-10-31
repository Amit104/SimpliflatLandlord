import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/model/base_model.dart';

class TenantRequest extends BaseModel {

  String buildingId;
  String blockName;
  String ownerFlatId;
  String tenantFlatId;
  bool requestFromTenant;
  int status;
  String createdByUserId;
  String createdByUserName;
  String createdByUserPhone;
  String tenantFlatName;
  String buildingName;
  String buildingZipcode;
  String buildingAddress;
  String requestId;
  String ownerFlatName;

	String getBuildingId() {
		return this.buildingId;
	}

	void setBuildingId(String buildingId) {
		this.buildingId = buildingId;
	}

	String getBlockName() {
		return this.blockName;
	}

	void setBlockName(String blockName) {
		this.blockName = blockName;
	}

	String getOwnerFlatId() {
		return this.ownerFlatId;
	}

	void setOwnerFlatId(String ownerFlatId) {
		this.ownerFlatId = ownerFlatId;
	}

	String getTenantFlatId() {
		return this.tenantFlatId;
	}

	void setTenantFlatId(String tenantFlatId) {
		this.tenantFlatId = tenantFlatId;
	}

	bool isRequestFromTenant() {
		return this.requestFromTenant;
	}

	void setRequestFromTenant(bool requestFromTenant) {
		this.requestFromTenant = requestFromTenant;
	}

	int getStatus() {
		return this.status;
	}

	void setStatus(int status) {
		this.status = status;
	}

	String getCreatedByUserId() {
		return this.createdByUserId;
	}

	void setCreatedByUserId(String createdByUserId) {
		this.createdByUserId = createdByUserId;
	}

	String getCreatedByUserName() {
		return this.createdByUserName;
	}

	void setCreatedByUserName(String createdByUserName) {
		this.createdByUserName = createdByUserName;
	}

	String getCreatedByUserPhone() {
		return this.createdByUserPhone;
	}

	void setCreatedByUserPhone(String createdByUserPhone) {
		this.createdByUserPhone = createdByUserPhone;
	}

	String getTenantFlatName() {
		return this.tenantFlatName;
	}

	void setTenantFlatName(String tenantFlatName) {
		this.tenantFlatName = tenantFlatName;
	}

	String getBuildingName() {
		return this.buildingName;
	}

	void setBuildingName(String buildingName) {
		this.buildingName = buildingName;
	}

	String getBuildingZipcode() {
		return this.buildingZipcode;
	}

	void setBuildingZipcode(String buildingZipcode) {
		this.buildingZipcode = buildingZipcode;
	}

	String getBuildingAddress() {
		return this.buildingAddress;
	}

	void setBuildingAddress(String buildingAddress) {
		this.buildingAddress = buildingAddress;
	}

  String getRequestId() {
		return this.requestId;
	}

	void setRequestId(String requestId) {
		this.requestId = requestId;
	}

  String getOwnerFlatName() {
		return this.ownerFlatName;
	}

	void setOwnerFlatName(String ownerFlatName) {
		this.ownerFlatName = ownerFlatName;
	}

  Map<String, dynamic> toJson() {
    return {'building_id' : this.buildingId,
          'block_id' : this.blockName,
          'owner_flat_id' : this.ownerFlatId,
          'tenant_flat_id': this.tenantFlatId,
          'request_from_tenant': this.requestFromTenant,
          'status': this.status,
          'created_at': Timestamp.now(),
          'updated_at': Timestamp.now(),
          'owner_flat_name': this.ownerFlatName,
          'created_by' : { "user_id" : this.createdByUserId, 'name' : this.createdByUserName, 'phone' : this.createdByUserPhone },
          'tenant_flat_name' : this.tenantFlatName,
          'building_details' : {'building_name' : this.buildingName, 'building_zipcode' : this.buildingZipcode, 'building_address' : this.buildingAddress}};
  }

  static TenantRequest fromJson(Map<String, dynamic> data, String documentId) {
    TenantRequest tenantRequest = new TenantRequest();
    tenantRequest.setBlockName(data['block_id']);
    tenantRequest.setBuildingAddress(data['building_details']['building_address']);
    tenantRequest.setBuildingId(data['building_id']);
    tenantRequest.setBuildingName(data['building_details']['building_name']);
    tenantRequest.setBuildingZipcode(data['building_details']['building_zipcode']);
    tenantRequest.setCreatedByUserId(data['created_by']['user_id']);
    tenantRequest.setCreatedByUserName(data['created_by']['user_id']);
    tenantRequest.setCreatedByUserPhone(data['created_by']['phone']);
    tenantRequest.setStatus(data['status']);
    tenantRequest.setOwnerFlatId(data['owner_flat_id']);
    tenantRequest.setTenantFlatId(data['tenant_flat_id']);
    tenantRequest.setRequestFromTenant(data['request_from_tenant']);
    tenantRequest.setTenantFlatName(data['tenant_flat_name']);
    tenantRequest.setCreatedAt(data['created_at']);
    tenantRequest.setUpdatedAt(data['updated_at']);
    tenantRequest.setOwnerFlatName(data['owner_flat_name']);
    tenantRequest.setRequestId(documentId);

    return tenantRequest;
  }

  static Map<String, dynamic> toUpdateJson({int status, dynamic ownerIdList}) {
    Map<String, dynamic> updateJson = new Map();
    if(status != null) updateJson['status'] = status;
    if(ownerIdList != null) updateJson['ownerIdList'] = ownerIdList;
    updateJson['updatedAt'] = Timestamp.now();
    return updateJson;
  }  
}