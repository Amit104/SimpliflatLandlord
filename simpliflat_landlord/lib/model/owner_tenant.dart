
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/model/base_model.dart';
import 'package:simpliflat_landlord/model/owner_flat.dart';
import 'package:simpliflat_landlord/model/tenant_flat.dart';

class OwnerTenant extends BaseModel {
  int status;
  OwnerFlat ownerFlat;
  TenantFlat tenantFlat;
  String ownerTenantId;

	OwnerFlat getOwnerFlat() {
		return this.ownerFlat;
	}

	void setOwnerFlat(OwnerFlat ownerFlat) {
		this.ownerFlat = ownerFlat;
	}

	TenantFlat getTenantFlat() {
		return this.tenantFlat;
	}

	void setTenantFlat(TenantFlat tenantFlat) {
		this.tenantFlat = tenantFlat;
	}

  int getStatus() {
    return this.status;
  }

  void setStatus(int status) {
    this.status = status;
  }

  String getOwnerTenantId() {
    return this.ownerTenantId;
  }

  void setOwnerTenantId(String ownerTenantId) {
    this.ownerTenantId = ownerTenantId;
  }

  static Map<String, dynamic> toUpdateJson({status}) {
    Map<String, dynamic> updateJson = new Map();
    if(status != null) updateJson['status'] = status;
    updateJson['updatedAt'] = Timestamp.now();
    return updateJson;
  }

}