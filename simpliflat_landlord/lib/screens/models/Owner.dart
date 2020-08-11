import './BaseModel.dart';

class Owner extends BaseModel {
  String role;
  String name;
  String phone;

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

}