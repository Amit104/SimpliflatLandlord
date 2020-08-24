library simpliflat.globals;

String myIP = "http://192.168.0.102";
int port = 5000;

String userName = 'userName';
String userPhone = 'userPhone';
String userId = 'userId';
String displayId = 'displayId';
String flatIdList = 'flatIdList';
String flatIdDefault = 'flatIdDefault';
String isSyncedNote = 'isSyncedNote';
String notificationToken = "notificationToken";
String flatName = "flatName";


//collection names

String taskHistory = "taskHistory";
String noticeBoard = "noticeboard";
String flat = "flat";
String landlord = "landlord";
String tasks = "tasks";
String flatContacts = "flatContacts";
String requests = "joinflat_landlord";

String messageBoard = "messageboard";
String documentManager = "documentmanager";

String readNoticeIds = "readNoticeIds";
String readTaskIds = 'readTaskIds';

String lists="lists";
String listItems="items";

String userIdValue;

enum BuildingType {
  PG,
  Residential
}

int displayIdLength = 8;

enum OwnerRoles {
  Admin,
  Manager
}

String building = 'building';

String block = 'block';

String ownerFlat = 'ownerFlat';

enum RequestStatus {
  Pending,
  Accepted,
  Rejected
}

String ownerOwnerJoin = 'owner_owner_join';