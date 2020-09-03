
import 'package:simpliflat_landlord/screens/models/BaseModel.dart';

class LandlordRequest extends BaseModel {
  String flatId;
  int status;
  String buildingAddress;
  String buildingName;
  String buildingId;
  String buildingDisplayId;
  String blockName;
  String zipcode;
  String flatNumber;
  String flatDisplayId;
  String requesterPhone;
  bool requestToOwner;
  String requesterId;
  String requesterUserName;
  String requestId;
  String toUserId;
  String toPhoneNumber;
  String toUsername;
  List<String> ownerIdList;


	List<String> getOwnerIdList() {
		return this.ownerIdList;
	}

	void setOwnerIdList(List<String> ownerIdList) {
		this.ownerIdList = ownerIdList;
	}

	String getToUserId() {
		return this.toUserId;
	}

	void setToUserId(String toUserId) {
		this.toUserId = toUserId;
	}

	String getToPhoneNumber() {
		return this.toPhoneNumber;
	}

	void setToPhoneNumber(String toPhoneNumber) {
		this.toPhoneNumber = toPhoneNumber;
	}

	String getToUsername() {
		return this.toUsername;
	}

	void setToUsername(String toUsername) {
		this.toUsername = toUsername;
	}


	String getRequesterUserName() {
		return this.requesterUserName;
	}

	void setRequesterUserName(String requesterUserName) {
		this.requesterUserName = requesterUserName;
	}

	String getFlatId() {
		return this.flatId;
	}

	void setFlatId(String flatId) {
		this.flatId = flatId;
	}

	int getStatus() {
		return this.status;
	}

	void setStatus(int status) {
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

	String getRequesterPhone() {
		return this.requesterPhone;
	}

	void setRequesterPhone(String requesterPhone) {
		this.requesterPhone = requesterPhone;
	}

	bool isRequestToOwner() {
		return this.requestToOwner;
	}

	void setRequestToOwner(bool requestToOwner) {
		this.requestToOwner = requestToOwner;
	}

	String getRequesterId() {
		return this.requesterId;
	}

	void setRequesterId(String requesterId) {
		this.requesterId = requesterId;
	}

  String getRequestId() {
		return this.requestId;
	}

	void setRequestId(String requestId) {
		this.requestId = requestId;
	}

  Map<String, dynamic> toJson() {
    return {
      'buildingId': this.buildingId,
      'buildingAddress': this.buildingAddress,
      'buildingDisplayId' : this.buildingDisplayId,
      'buildingName' : this.buildingName,
      'zipcode' : this.zipcode,
      'blockName' : this.blockName,
      'flatDisplayId' : this.flatDisplayId,
      'flatId' : this.flatId,
      'flatNumber' : this.flatNumber,
      'status' : this.status,
      'requesterId' : this.requesterId,
      'requesterPhone' : this.requesterPhone,
      'requesterUserName' : this.requesterUserName,
      'requestToOwner' : this.requestToOwner,
      'createdAt' : this.createdAt,
      'updatedAt' : this.updatedAt,
      'toUserId': this.toUserId,
      'toPhoneNumber': this.toPhoneNumber,
      'toUsername': this.toUsername,
      'ownerIdList': this.ownerIdList
    };
  }

  static LandlordRequest fromJson(Map<String, dynamic> data, String documentId) {
    LandlordRequest request = new LandlordRequest();
    request.setBlockName(data['blockName']);
    request.setBuildingAddress(data['buildingAddress']);
    request.setBuildingName(data['buildingName']);
    request.setBuildingId(data['buildingId']);
    request.setFlatDisplayId(data['flatDisplayId']);
    request.setFlatId(data['flatId']);
    request.setFlatNumber(data['flatNumber']);
    request.setRequesterId(data['requesterId']);
    request.setRequesterPhone(data['requesterPhone']);
    request.setRequesterUserName(data['requesterUserName']);
    request.setRequestToOwner(data['requestToOwner']);
    request.setZipcode(data['zipcode']);
    request.setStatus(data['status']);
    request.setBuildingDisplayId(data['buildingDisplayId']);
    request.setToPhoneNumber(data['toPhoneNumber']);
    request.setToUserId(data['toUserId']);
    request.setToUsername(data['toUsername']);
    request.setRequestId(documentId);
    List<String> ownerIdList = new List<String>.from(data['ownerIdList']);
    request.setOwnerIdList(ownerIdList);

    return request;
  }
}