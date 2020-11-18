import 'package:cloud_functions/cloud_functions.dart';
import 'package:simpliflat_landlord/model/owner.dart';
import 'package:simpliflat_landlord/model/owner_tenant.dart';

class ProfileOptionsService {
  static Future<bool> makeOwnerAdminForFlat(Owner owner, OwnerTenant flat) async {
    HttpsCallable func = CloudFunctions.instance.getHttpsCallable(
                      functionName: "makeOwnerAdminForFlat",
                  );

                  try {
                 HttpsCallableResult res = await func.call(<String, dynamic> {'ownerId': owner.getOwnerId(), 'ownerFlatId': flat.getOwnerFlat().getFlatId()});
                  if((res.data as Map)['code'] == 0) {
                    return true;
                  }
                  else {
                    print((res.data as Map)['message']);
                    return false;
                  }
                  }
                  catch(e) {
                    return false;
                  }
  }
}