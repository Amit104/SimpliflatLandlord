import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/dao/building_dao.dart';
import 'package:simpliflat_landlord/dao/owner_flat_dao.dart';
import 'package:simpliflat_landlord/model/block.dart';
import 'package:simpliflat_landlord/model/building.dart';
import 'package:simpliflat_landlord/model/owner_flat.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;

class PropertyService {
  static Future<bool> saveProperty(Building building) async {
    /** Pre-conditions:
     * 1. Only create building, block or ownerFlat
     * 2. Not allowed to modify details of building, existing blocks and flats
     */
    var db = Firestore.instance;

    var batch = db.batch();
    /** update building if blocks added. Create building if building does not have id. Building document need not be updated if no blocks added */
    /** check if any block has been added */
    Block modifiedBlock = building.getBlocks().firstWhere((Block block) =>
      (block.isModified() == null ? false : block.isModified()), orElse: () => null);

    if (building.getBuildingId() != null && modifiedBlock != null) {
      /** if building exists and blocks added, then add blocks in block list */
      batch.updateData(BuildingDao.getDocumentReference(building.getBuildingId()), Building.toUpdateJson(blockList:
                  FieldValue.arrayUnion(getAddedBlockNamesList(building.getBlocks()))));

    } else if (building.getBuildingId() == null) {
      /** if building is new then create building */
      DocumentReference dr = BuildingDao.getDocumentReference(null);
      batch.setData(dr, building.toJson());
      building.setBuildingId(dr.documentID);
      
    }

    /** for ownerFlat */

    List<Block> blocks = building.getBlocks();
    if (blocks != null) {
      for (int i = 0; i < building.getBlocks().length; i++) {
        List<OwnerFlat> flats = blocks[i].getOwnerFlats();

        if (flats != null) {
          for (int j = 0; j < flats.length; j++) {
            if (flats[j].getFlatId() == null) {
              /** new flat created. Add ownerFlat document to collection */
              addBuildingDetailsToFlat(flats[j], building);
              batch.setData(OwnerFlatDao.getDocumentReference(null), flats[j].toJson());
            }
          }
        }
      }
    }

    return batch.commit().then((retVal) {
      return true;
    }).catchError((e) {
      return false;
    });
  }

  static List<String> getAddedBlockNamesList(List<Block> blocks) {
    return blocks.where((Block b) {
            return b.isModified();
          }).map((Block blk) => blk.getBlockName()).toList();
  }

  static void addBuildingDetailsToFlat(OwnerFlat flat, Building building) {
    flat.setZipcode(building.getZipcode());
    flat.setBuildingName(building.getBuildingName());
    flat.setBuildingId(building.getBuildingId());
  }
}
