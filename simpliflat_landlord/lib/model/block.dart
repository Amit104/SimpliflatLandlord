

import 'package:simpliflat_landlord/model/base_model.dart';
import 'package:simpliflat_landlord/model/owner_flat.dart';

class Block extends BaseModel {
  String blockName;

  List<OwnerFlat> ownerFlats;

	String getBlockName() {
		return this.blockName;
	}

	void setBlockName(String blockName) {
		this.blockName = blockName;
	}

  List<OwnerFlat> getOwnerFlats() {
		return this.ownerFlats;
	}

	void setOwnerFlats(List<OwnerFlat> ownerFlats) {
		this.ownerFlats = ownerFlats;
	}

	
  Map<String, dynamic> toJson() {
    return {
      'blockName': this.blockName,
    };
  }

  static Block fromJson(Map<String, dynamic> json, String documentId, List<OwnerFlat> ownerFlats) {
    Block block = new Block();
    block.setBlockName((json['blockName'] as String));
    block.setOwnerFlats(ownerFlats);

    return block;
  }



}