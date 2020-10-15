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
    }
    else {
      print('userId is  - ' + userId);
      User user = await StartupService._getUserObject(userId);
      bool propertyRegistered = await Utility.getPropertyRegistered();

      if(propertyRegistered == null ) {
        propertyRegistered = await StartupService._getAndSetIfPropertyRegistred(userId);
      }
      user.setPropertyRegistered(propertyRegistered);
      return user;
    }
  }

  static Future<User> _getUserObject(String userId) async {
    User user = new User();
    String _userPhone = await Utility.getUserPhone();
      String _userName = await Utility.getUserName();
      if (_userName == null ||
          _userName == "" ||
          _userPhone == null ||
          _userPhone == "") {
        DocumentSnapshot userDoc = await OwnerDao.getDocument(userId);

        if (userDoc.exists) {
          _userName = userDoc.data['name'];
          _userPhone = userDoc.data['phone'];
          Utility.addToSharedPref(userName: _userName);
          Utility.addToSharedPref(userPhone: _userPhone);
        }
      }

      user.setName(_userName);
      user.setPhone(_userPhone);
      user.setUserId(userId);

      return user;
  }

  static Future<bool> _getAndSetIfPropertyRegistred(String userId) async {
    QuerySnapshot docs = await OwnerFlatDao.getAnOwnerFlatForUser(userId);
    bool propertyRegistered = docs.documents != null && docs.documents.length > 0;
    Utility.addToSharedPref(propertyRegistered: propertyRegistered);
    return propertyRegistered;
  }
}