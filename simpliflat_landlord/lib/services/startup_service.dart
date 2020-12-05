import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/dao/owner_dao.dart';
import 'package:simpliflat_landlord/dao/owner_flat_dao.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/utility/utility.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;

class StartupService {
  static Future<User> getUser() async {
    String userId = await Utility.getUserId();

    if (userId == null) {
      return null;
    } else {
      print('userId is  - ' + userId);
      User user = await StartupService._getUserObject(userId);
      bool propertyRegistered; // = await Utility.getPropertyRegistered();

      if (propertyRegistered == null) {
        propertyRegistered =
            await StartupService._getAndSetIfPropertyRegistred(userId);
      }
      user.setPropertyRegistered(propertyRegistered);
      return user;
    }
  }

  static Future<User> _getUserObject(String userId) async {
    DocumentSnapshot userDoc = await OwnerDao.getDocument(userId);

    return User.fromJson(userDoc.data, userDoc.documentID);
  }

  static Future<bool> _getAndSetIfPropertyRegistred(String userId) async {
    QuerySnapshot docs = await OwnerFlatDao.getAnOwnerFlatForUser(userId);
    bool propertyRegistered =
        docs.documents != null && docs.documents.length > 0;
    Utility.addToSharedPref(propertyRegistered: propertyRegistered);
    return propertyRegistered;
  }
}
