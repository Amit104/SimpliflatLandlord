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
  List<String> ownerIdList;

  List<String> getOwnerIdList() {
    return this.ownerIdList;
  }

  void setOwnerIdList(List<String> ownerIdList) {
    this.ownerIdList = ownerIdList;
  }

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
    Map<String, dynamic> data = {
      'buildingId': this.buildingId,
      'blockId': this.blockName,
      'ownerFlatId': this.ownerFlatId,
      'tenantFlatId': this.tenantFlatId,
      'requestFromTenant': this.requestFromTenant,
      'status': this.status,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
      'ownerFlatName': this.ownerFlatName,
      'createdBy': {
        "userId": this.createdByUserId,
        'name': this.createdByUserName,
        'phone': this.createdByUserPhone
      },
      'tenantFlatName': this.tenantFlatName,
      'buildingDetails': {
        'buildingName': this.buildingName,
        'buildingZipcode': this.buildingZipcode,
        'buildingAddress': this.buildingAddress
      },
      'ownerIdList': new Map<String, bool>()
    };
    if (this.ownerIdList != null) {
      for (String owner in this.ownerIdList) {
        print(owner);
        data['ownerIdList'][owner] = true;
      }
    }

    return data;
  }

  static TenantRequest fromJson(Map<String, dynamic> data, String documentId) {
    TenantRequest tenantRequest = new TenantRequest();
    tenantRequest.setBlockName(data['blockId']);
    tenantRequest
        .setBuildingAddress(data['buildingDetails']['buildingAddress']);
    tenantRequest.setBuildingId(data['buildingId']);
    tenantRequest.setBuildingName(data['buildingDetails']['buildingName']);
    tenantRequest
        .setBuildingZipcode(data['buildingDetails']['buildingZipcode']);
    tenantRequest.setCreatedByUserId(data['createdBy']['userId']);
    tenantRequest.setCreatedByUserName(data['createdBy']['name']);
    tenantRequest.setCreatedByUserPhone(data['createdBy']['phone']);
    tenantRequest.setStatus(data['status']);
    tenantRequest.setOwnerFlatId(data['ownerFlatId']);
    tenantRequest.setTenantFlatId(data['tenantFlatId']);
    tenantRequest.setRequestFromTenant(data['requestFromTenant']);
    tenantRequest.setTenantFlatName(data['tenantFlatName']);
    tenantRequest.setCreatedAt(data['createdAt']);
    tenantRequest.setUpdatedAt(data['updatedAt']);
    tenantRequest.setOwnerFlatName(data['ownerFlatName']);
    tenantRequest.setRequestId(documentId);
    List<String> ownerIdList =
        Map<String, bool>.from(data['ownerIdList']).keys.toList();
    tenantRequest.setOwnerIdList(ownerIdList);
    return tenantRequest;
  }

  static Map<String, dynamic> toUpdateJson({int status}) {
    Map<String, dynamic> updateJson = new Map();
    if (status != null) updateJson['status'] = status;
    updateJson['updatedAt'] = Timestamp.now();
    return updateJson;
  }
}
