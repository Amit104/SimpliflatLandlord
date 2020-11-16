
import 'package:simpliflat_landlord/model/base_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Owner extends BaseModel {
  String role;
  String name;
  String phone;
  String ownerId;
  String notificationToken;

	String getRole() {
		return this.role;
	}

	void setRole(String role) {
		this.role = role;
	}

	String getName() {
		return this.name;
	}

	void setName(String name) {
		this.name = name;
	}

	String getPhone() {
		return this.phone;
	}

	void setPhone(String phone) {
		this.phone = phone;
	}

  String getOwnerId() {
    return this.ownerId;
  }

  void setOwnerId(String ownerId) {
    this.ownerId = ownerId;
  }

  String getNotificationToken() {
    return this.notificationToken;
  }

  void setNotificationToken(String notificationToken) {
    this.notificationToken = notificationToken;
  }

  static Owner fromJson(Map<String, dynamic> data, String documentId) {
    Owner owner = new Owner();
    owner.setName(data['name']);
    owner.setPhone(data['phone']);
    owner.setOwnerId(documentId);
    owner.setNotificationToken(data['notificationToken']);
    owner.setCreatedAt(data['createdAt']);
    owner.setUpdatedAt(data['updatedAt']);

    return owner;
  }

  static Map<String, dynamic> toUpdateJson({String notificationToken, String name, String phoneNumber}) {
    Map<String, dynamic> updateJson = new Map();
    if(notificationToken != null) updateJson['notificationToken'] = notificationToken;
    if(name != null) updateJson['name'] = name;
    if(phoneNumber != null) updateJson['phone'] = phoneNumber;
    updateJson['updatedAt'] = Timestamp.now();
    return updateJson;
  }
}