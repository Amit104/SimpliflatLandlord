
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/model/base_model.dart';

class OwnerTenant extends BaseModel {
  String ownerFlatId;
  String tenantFlatId;
  int status;

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

  int getStatus() {
    return this.status;
  }

  void setStatus(int status) {
    this.status = status;
  }

  static Map<String, dynamic> toUpdateJson({status}) {
    Map<String, dynamic> updateJson = new Map();
    if(status != null) updateJson['status'] = status;
    updateJson['updatedAt'] = Timestamp.now();
    return updateJson;
  }

}