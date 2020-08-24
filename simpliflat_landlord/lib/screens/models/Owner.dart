import './BaseModel.dart';

class Owner extends BaseModel {
  String role;
  String name;
  String phone;
  String ownerId;

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

  static Owner fromJson(Map<String, dynamic> data, String documentId) {
    Owner owner = new Owner();
    owner.setName(data['name']);
    owner.setPhone(data['phone']);
    owner.setOwnerId(documentId);

    return owner;
  }
}