
import 'package:simpliflat_landlord/model/base_model.dart';

class Tenant extends BaseModel {
  String name;
  String phone;
  String flatId;

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

	String getFlatId() {
		return this.flatId;
	}

	void setFlatId(String flatId) {
		this.flatId = flatId;
	}
}