import './BaseModel.dart';

class Block extends BaseModel {
  String blockName;
  String buildingId;
  String blockDisplayId;

	String getBlockName() {
		return this.blockName;
	}

	void setBlockName(String blockName) {
		this.blockName = blockName;
	}

	String getBuildingId() {
		return this.buildingId;
	}

	void setBuildingId(String buildingId) {
		this.buildingId = buildingId;
	}

  String getBlockDisplayId() {
		return this.blockDisplayId;
	}

	void setBlockDisplayId(String blockDisplayId) {
		this.blockDisplayId = blockDisplayId;
	}

}