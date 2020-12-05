const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);

var msgData;

//////////////////////////////////////////////////////////////////////////////////////////
// Noticeboard  Notifications
//////////////////////////////////////////////////////////////////////////////////////////

exports.createNotice =
    functions
        .firestore
        .document('flat/{flat_id}/noticeboard/{id}')
        .onCreate((snapshot, context) => {
            msgData = snapshot.data();

            admin.firestore().collection('user').where('flat_id', '==', context.params.flat_id).get().then((userSnapshots) => {
                var tokens = []
                var userName = "";
                if (userSnapshots.empty) {
                    console.error("No User [DOCUMENT] /flat/" + context.params.flat_id + "/noticeboard/" + context.params.id);
                } else {
                    for (var document of userSnapshots.docs) {
                        if (document.id == msgData.user_id) {
                            userName = document.data().name;
                        } else {
                            tokens.push(document.data().notification_token);
                        }
                    }
                    if (tokens.length == 0) {
                        console.error("No Tokens [DOCUMENT] /flat/" + context.params.flat_id + "/noticeboard/" + context.params.id);
                    } else {
                        var payload = {
                            "notification": {
                                "title": userName != ""
                                    ? "New Notice Created By " + userName
                                    : "New Notice",
                                "body": msgData.note,
                                "sound": "default"
                            },
                            "data": {
                                "sendername": userName,
                                "click_action": "FLUTTER_NOTIFICATION_CLICK",
                                "screen": "noticeboard",
                                "message": msgData.note
                            }
                        }
                        return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                            console.log("Notice notification pushed [TYPE] onCreate [DOCUMENT] /flat/" + context.params.flat_id + "/noticeboard/" + context.params.id);
                        }).catch((err) => {
                            console.error(err);
                        });
                    }
                }
            });
        });

//////////////////////////////////////////////////////////////////////////////////////////
// Tasks  Notifications
//////////////////////////////////////////////////////////////////////////////////////////

exports.createTask =
    functions
        .firestore
        .document('flat/{flat_id}/tasks/{id}')
        .onCreate((snapshot, context) => {
            msgData = snapshot.data();

            admin.firestore().collection('user').where('flat_id', '==', context.params.flat_id).get().then((userSnapshots) => {
                var tokens = []
                var userName = "";
                if (userSnapshots.empty) {
                    console.error("No User [DOCUMENT] /flat/" + context.params.flat_id + "/tasks/" + context.params.id);
                } else {
                    for (var document of userSnapshots.docs) {
                        if (document.id == msgData.user_id) {
                            userName = document.data().name;
                        } else if (msgData.assignee.includes(document.id)) {
                            tokens.push(document.data().notification_token);
                        }
                    }
                    if (tokens.length == 0) {
                        console.error("No Tokens [DOCUMENT] /flat/" + context.params.flat_id + "/tasks/" + context.params.id);
                    } else {
                        var payload = {
                            "notification": {
                                "title": userName != ""
                                    ? "New Task Created By " + userName
                                    : "New Task",
                                "body": msgData.title,
                                "sound": "default"
                            },
                            "data": {
                                "sendername": userName,
                                "click_action": "FLUTTER_NOTIFICATION_CLICK",
                                "screen": "tasks",
                                "message": msgData.title
                            }
                        }
                        return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                            console.log("Tasks notification pushed [TYPE] onCreate [DOCUMENT] /flat/" + context.params.flat_id + "/tasks/" + context.params.id);
                        }).catch((err) => {
                            console.error(err);
                        });
                    }
                }
            });
        });

exports.updateTask =
    functions
        .firestore
        .document('flat/{flat_id}/tasks/{id}')
        .onUpdate((snapshot, context) => {
            msgData = snapshot.after.data();

            admin.firestore().collection('user').where('flat_id', '==', context.params.flat_id).get().then((userSnapshots) => {
                var tokens = []
                var userName = "";
                if (userSnapshots.empty) {
                    console.error("No User [DOCUMENT] /flat/" + context.params.flat_id + "/tasks/" + context.params.id);
                } else {
                    for (var document of userSnapshots.docs) {
                        if (document.id == msgData.user_id) {
                            userName = document.data().name;
                        } else if (msgData.assignee.includes(document.id)) {
                            tokens.push(document.data().notification_token);
                        }
                    }
                    if (tokens.length == 0) {
                        console.error("No Tokens [DOCUMENT] /flat/" + context.params.flat_id + "/tasks/" + context.params.id);
                    } else {
                        var payload = {
                            "notification": {
                                "title": userName != ""
                                    ? "Task Updated By " + userName
                                    : "Task Updated",
                                "body": msgData.title,
                                "sound": "default"
                            },
                            "data": {
                                "sendername": userName,
                                "click_action": "FLUTTER_NOTIFICATION_CLICK",
                                "screen": "tasks",
                                "message": msgData.title
                            }
                        }
                        return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                            console.log("Tasks notification pushed [TYPE] onUpdate [DOCUMENT] /flat/" + context.params.flat_id + "/tasks/" + context.params.id);
                        }).catch((err) => {
                            console.error(err);
                        });
                    }
                }
            });
        });

//////////////////////////////////////////////////////////////////////////////////////////
// Lists  Notifications
//////////////////////////////////////////////////////////////////////////////////////////

exports.createList =
    functions
        .firestore
        .document('flat/{flat_id}/lists/{id}')
        .onCreate((snapshot, context) => {
            msgData = snapshot.data();

            admin.firestore().collection('user').where('flat_id', '==', context.params.flat_id).get().then((userSnapshots) => {
                var tokens = []
                var userName = "";
                if (userSnapshots.empty) {
                    console.error("No User [DOCUMENT] /flat/" + context.params.flat_id + "/lists/" + context.params.id);
                } else {
                    for (var document of userSnapshots.docs) {
                        if (document.id == msgData.user_id) {
                            userName = document.data().name;
                        } else {
                            tokens.push(document.data().notification_token);
                        }
                    }
                    if (tokens.length == 0) {
                        console.error("No Tokens [DOCUMENT] /flat/" + context.params.flat_id + "/lists/" + context.params.id);
                    } else {
                        var payload = {
                            "notification": {
                                "title": userName != ""
                                    ? "New list Created By " + userName
                                    : "New list",
                                "body": msgData.title,
                                "sound": "default"
                            },
                            "data": {
                                "sendername": userName,
                                "click_action": "FLUTTER_NOTIFICATION_CLICK",
                                "screen": "lists",
                                "message": msgData.title
                            }
                        }
                        return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                            console.log("List notification pushed [TYPE] onCreate [DOCUMENT] /flat/" + context.params.flat_id + "/lists/" + context.params.id);
                        }).catch((err) => {
                            console.error(err);
                        });
                    }
                }
            });
        });


//////////////////////////////////////////////////////////////////////////////////////////
// flatContacts  Notifications
//////////////////////////////////////////////////////////////////////////////////////////

exports.createFlatContacts =
    functions
        .firestore
        .document('flat/{flat_id}/flatContacts/{id}')
        .onCreate((snapshot, context) => {
            msgData = snapshot.data();

            admin.firestore().collection('user').where('flat_id', '==', context.params.flat_id).get().then((userSnapshots) => {
                var tokens = []
                var userName = "";
                if (userSnapshots.empty) {
                    console.error("No User [DOCUMENT] /flat/" + context.params.flat_id + "/flatContacts/" + context.params.id);
                } else {
                    for (var document of userSnapshots.docs) {
                        if (document.id == msgData.user_id) {
                            userName = document.data().name;
                        } else {
                            tokens.push(document.data().notification_token);
                        }
                    }
                    if (tokens.length == 0) {
                        console.error("No Tokens [DOCUMENT] /flat/" + context.params.flat_id + "/flatContacts/" + context.params.id);
                    } else {
                        var payload = {
                            "notification": {
                                "title": userName != ""
                                    ? "New Contact Created By " + userName
                                    : "New Contact created",
                                "body": msgData.name,
                                "sound": "default"
                            },
                            "data": {
                                "sendername": userName,
                                "click_action": "FLUTTER_NOTIFICATION_CLICK",
                                "screen": "flatContacts",
                                "message": msgData.name
                            }
                        }
                        return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                            console.log("List notification pushed [TYPE] onCreate [DOCUMENT] /flat/" + context.params.flat_id + "/flatContacts/" + context.params.id);
                        }).catch((err) => {
                            console.error(err);
                        });
                    }
                }
            });
        });

//////////////////////////////////////////////////////////////////////////////////////////
// messageboard Notifications (landlord related)
//////////////////////////////////////////////////////////////////////////////////////////

exports.createMessageBoard =
    functions
        .firestore
        .document('owner_tenant_flat/{owner_tenant_flat_id}/messageboard/{id}')
        .onCreate(async (snapshot, context) => {
            var msgData = snapshot.data();
            var userName = "";
            var tokens = [];
            var ownerFlatId;
            var tenantFlatId;

			console.info(context.params.owner_tenant_flat_id);

            var atd = await getApartmentTenantDocument(context.params.owner_tenant_flat_id);

            if (atd == null) {
                console.error("owner_tenant_flat/" + context.params.owner_tenant_flat_id + "/messageboard/" + context.params.id +  " - No owner tenant flat document found for id: " + context.params.owner_tenant_flat_id);
                return;
            }
            else {
                ownerFlatId = atd['ownerFlatId'];
                tenantFlatId = atd['tenantFlatId'];
				console.info(tenantFlatId);
            }



            // notification to tenants
            var ret = getTenantTokensAndUserNameUsingDoc(atd, msgData.user_id);
			console.info("after getting tenant tokens");
            if (ret != null) {
                tokens = tokens.concat(ret.tokens);
                userName = ret.userName;
            }
            else {
                console.error("owner_tenant_flat/" + context.params.owner_tenant_flat_id + "/messageboard/" + context.params.id +  " - No tenants found for flatid: " + tenantFlatId);
            }


            var ret12 = getOwnerTokensAndUserNameUsingDoc(atd, msgData.user_id);

			console.info("after getting owner tokens");
            if (ret12 != null) {
                tokens = tokens.concat(ret12.tokens);
                userName = ret12.userName;
            }
            else {
                console.error("owner_tenant_flat/" + context.params.owner_tenant_flat_id + "/messageboard/" + context.params.id +  " - No owners found for owner flat id: " + ownerFlatId);
            }

            if (tokens.length == 0) {
                console.error("No Tokens [DOCUMENT] /owner_tenant_flat/" + context.params.owner_tenant_flat_id + '/messageboard/' + context.params.id);
            } else {
                var title = userName != ""
                    ? "New Message By " + userName
                    : "New Message in Message board";
                var payload = createPayload(title, msgData.message, userName, "messaageboard", msgData.message);

                createActivity(title, msgData.message, userName, context.params.id, ownerFlatId, tenantFlatId, context.params.owner_tenant_flat_id, ret12.owners, atd.buildingName, atd.ownerFlatName);

                return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                    console.log("messageboard notification pushed [TYPE] onCreate [DOCUMENT] /owner_tenant_flat/" + context.params.owner_tenant_flat_id + '/messageboard/' + context.params.id);
                }).catch((err) => {
                    console.error(err);
                });
            }
        });

//////////////////////////////////////////////////////////////////////////////////////////
// documentmanager Notifications (landlord related)
//////////////////////////////////////////////////////////////////////////////////////////

exports.createDocumentManager =
    functions
        .firestore
        .document('owner_tenant_flat/{owner_tenant_flat_id}/documentmanager/{id}')
        .onCreate(async (snapshot, context) => {
            msgData = snapshot.data();
            var userName = "";
            var tokens = [];
            var ownerFlatId;
            var tenantFlatId;

            var atd = await getApartmentTenantDocument(context.params.owner_tenant_flat_id);

            if (atd == null) {
                console.error("owner_tenant_flat/" + context.params.owner_tenant_flat_id + "/documentmanager/" + context.params.id +  "No owner tenant flat document found for id: " + context.params.owner_tenant_flat_id);
                return;
            }
            else {
                ownerFlatId = atd['ownerFlatId'];
                tenantFlatId = atd['tenantFlatId'];
            }

            // notification to tenants
            var ret = await getTenantTokensAndUserNameUsingDoc(atd, msgData.user_id);
            if (ret != null) {
                tokens = tokens.concat(ret.tokens);
                userName = ret.userName;
            }
            else {
                console.error("owner_tenant_flat/" + context.params.owner_tenant_flat_id + "/documentmanager/" + context.params.id +  " - No tenants found for flatid: " + tenantFlatId);
            }
            // notification to landlord
            var ret11 = await getOwnerTokensAndUserNameUsingDoc(atd, msgData.user_id);

            if (ret11 != null) {
                tokens = tokens.concat(ret11.tokens);
                userName = ret11.userName;
            }
            else {
                console.error("owner_tenant_flat/" + context.params.owner_tenant_flat_id + "/documentmanager/" + context.params.id +  " - No owners found for owner flat id: " + ownerFlatId);
            }

            if (tokens.length == 0) {
                console.error("No Tokens [DOCUMENT] /owner_tenant_flat/" + context.params.owner_tenant_flat_id + "/documentmanager/" + context.params.id);
            } else {
                var title = userName != ""
                    ? "New Document uploaded By " + userName
                    : "New document in Document Manager";
                var payload = createPayload(title, msgData.file_name, userName, "documentmanager", msgData.file_name);

                createActivity(title, msgData.file_name, userName, context.params.id, ownerFlatId, tenantFlatId, context.params.owner_tenant_flat_id, ret11.owners, atd.buildingName, atd.ownerFlatName);

                return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                    console.log("documentmanager notification pushed [TYPE] onCreate [DOCUMENT] /owner_tenant_flat/" + context.params.owner_tenant_flat_id + "/documentmanager/" + context.params.id);
                }).catch((err) => {
                    console.error(err);
                });
            }


        });

//////////////////////////////////////////////////////////////////////////////////////////
// Tasks  Notifications (landlord related)
//////////////////////////////////////////////////////////////////////////////////////////

exports.createLandlordTask =
    functions
        .firestore
        .document('owner_tenant_flat/{owner_tenant_flat_id}/tasks_landlord/{id}')
        .onCreate(async (snapshot, context) => {
            msgData = snapshot.data();
            var userName = "";
            var tokens = [];
            var ownerFlatId;
            var tenantFlatId;

            var atd = await getApartmentTenantDocument(context.params.owner_tenant_flat_id);
            if (atd == null) {
                console.error("owner_tenant_flat/" + context.params.owner_tenant_flat_id + "/tasks_landlord/" + context.params.id +  "No owner tenant flat document found for id: " + context.params.owner_tenant_flat_id);
                return;
            }
            else {
                ownerFlatId = atd['ownerFlatId'];
                tenantFlatId = atd['tenantFlatId'];
            }

			for(var key of Object.keys(atd)) {
                if(key.startsWith("t_")) {
                    var ownerId = key.substr(2);
                    var elems = atd[key].split('::');
                    if (ownerId == msgData.user_id) {
                        userName = elems[0];
                    }
                    else if (msgData.assignee.includes(ownerId)) {
                        tokens.push(elems[1]);
                    }
                }
            }
                    
             

            // notification to landlord
            var ret13 = await getOwnerTokensAndUserNameUsingDoc(atd, msgData.user_id);

            if (ret13 != null) {
                tokens = tokens.concat(ret13.tokens);
                userName = ret13.userName;
            } else {
                console.error("owner_tenant_flat/" + context.params.owner_tenant_flat_id + "/tasks_landlord/" + context.params.id +  " - No owners found for owner flat id: " + ownerFlatId);
            }

            if (tokens.length == 0) {
                console.error("No Tokens [DOCUMENT] /owner_tenant_flat/" + context.params.owner_tenant_flat_id + "/tasks_landlord/" + context.params.id);
            } else {
                var title = userName != ""
                    ? "New Task Created By " + userName
                    : "New Task";
                var payload = createPayload(title, msgData.title, userName, "tasks_landlord", msgData.title);

                createActivity(title, msgData.title, userName, context.params.id, ownerFlatId, tenantFlatId, context.params.owner_tenant_flat_id, ret13.owners, atd.buildingName, atd.ownerFlatName);

                return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                    console.log("Landlord-Tenant Tasks notification pushed [TYPE] onCreate [DOCUMENT] /owner_tenant_flat/" + context.params.owner_tenant_flat_id + "/tasks_landlord/" + context.params.id);
                }).catch((err) => {
                    console.error(err);
                });
            }

        });

exports.updateLandlordTask =
    functions
        .firestore
        .document('owner_tenant_flat/{owner_tenant_flat_id}/tasks_landlord/{id}')
        .onUpdate(async (snapshot, context) => {
            //do we need to read document?
            msgData = snapshot.after.data();
            var userName = "";
            var tokens = [];
            var ownerFlatId;
            var tenantFlatId;

            var atd = await getApartmentTenantDocument(context.params.owner_tenant_flat_id);
            if (atd == null) {
                console.error("owner_tenant_flat/" + context.params.owner_tenant_flat_id + "/tasks_landlord/" + context.params.id +  " - No owner tenant flat document found during update for id: " + context.params.owner_tenant_flat_id);
                return;
            }
            else {
                ownerFlatId = atd['ownerFlatId'];
                tenantFlatId = atd['tenantFlatId'];
            }
            
            // notification to tenants
            for(var key of Object.keys(atd)) {
                if(key.startsWith("t_")) {
                    var ownerId = key.substr(2);
                    var elems = atd[key].split('::');
                    if (ownerId == msgData.user_id) {
                        userName = elems[0];
                    }
                    else if (msgData.assignee.includes(ownerId)) {
                        tokens.push(elems[1]);
                    }
                }
            }

            // notification to landlord
            var ret8 = await getOwnerTokensAndUserNameUsingDoc(atd, msgData.user_id);
            if (ret8 != null) {
                tokens = tokens.concat(ret8.tokens);
                userName = ret8.userName;
            } else {
                console.error("owner_tenant_flat/" + context.params.owner_tenant_flat_id + "/tasks_landlord/" + context.params.id +  " - No owners found for owner flat id: " + ownerFlatId);
            }

            if (tokens.length == 0) {
                console.error("No Tokens [DOCUMENT] /owner_tenant_flat/" + context.params.owner_tenant_flat_id + "/tasks_landlord/" + context.params.id);
            } else {
                var title = userName != ""
                    ? "Task Updated By " + userName
                    : "Update to Task";
                var payload = createPayload(title, msgData.title, userName, "tasks_landlord", msgData.title);

                createActivity(title, msgData.title, userName, context.params.id, ownerFlatId, tenantFlatId, context.params.owner_tenant_flat_id, ret8.owners, atd.buildingName, atd.ownerFlatName);

                return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                    console.log("Landlord-Tenant Tasks notification pushed [TYPE] onUpdate [DOCUMENT] /owner_tenant_flat/" + context.params.owner_tenant_flat_id + "/tasks_landlord/" + context.params.id);
                }).catch((err) => {
                    console.error(err);
                });
            }

        });

//////////////////////////////////////////////////////////////////////////////////////////
// Owner Owner  Notifications (landlord related)
//////////////////////////////////////////////////////////////////////////////////////////
exports.createOwnerOwnerJoin =
    functions
        .firestore
        .document('owner_owner_join/{id}')
        .onCreate(async (snapshot, context) => {
            msgData = snapshot.data();
            var tokens = [];
            var userName = msgData.requesterUserName;
            if (msgData.toUserId == null || msgData.toUserId == "") {  //request from coowner to ownerFlat

                var ret8 = await getOwnerTokens(msgData.ownerIdList);
                if (ret8 != null) {
                    tokens = tokens.concat(ret8);
                }
                else {
                    console.error("owner_owner_join/" + context.params.id +  " - No owners found for owner id list");
                }

                if (tokens.length == 0) {
                    console.error("No Tokens [DOCUMENT] /owner_owner_join/" + context.params.id);
                } else {
                    var body = userName != ""
                        ? userName + " wants to join as coowner"
                        : "You have a new request";
                    var payload = createPayload("New join request", body, userName, "owner_owner_join", body);
					var owners = msgData.ownerIdList;
					owners.push(msgData.requesterId);

                    createActivity("New join request", body, userName, context.params.id, msgData.flatId, null, null, owners, msgData.buildingName, msgData.flatName);

                    return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                        console.log("Landlord-Tenant Tasks notification pushed [TYPE] onUpdate [DOCUMENT] /owner_owner_join/" + context.params.id);
                    }).catch((err) => {
                        console.error(err);
                    });
                }
            }
            else {  //request from owner to coowner
                var landlordSnapshot = await admin.firestore().collection('landlord').doc(msgData.toUserId).get();
                if (landlordSnapshot.empty) {
                    console.error("No Landlord User [DOCUMENT] /owner_owner_join/" + context.params.id);
                } else {


                    tokens.push(landlordSnapshot.data().notificationToken);

                }
                var ret14 = await getOwnerTokensAndUserNameFromOwnerFlat(msgData.flatId, "");

                if (ret14 != null) {
                    tokens = tokens.concat(ret14);
                } else {
                    console.error("owner_owner_join/" + context.params.id +  " - No owners found for owner id list");
                }

                if (tokens.length == 0) {
                    console.error("No Tokens [DOCUMENT] /owner_owner_join/" + context.params.id);
                } else {
                    var body = userName != ""
                        ? userName + " has sent a coowner request"
                        : "You have a new request";
                    var payload = createPayload("New join request", body, userName, "owner_owner_join", body);
					var owners = ret14.owners;
					owners.push(msgData.toUserId);
                    createActivity("New join request", body, userName, context.params.id, msgData.flatId, null, null, owners, msgData.buildingName, msgData.flatName);

                    return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                        console.log("Landlord-Tenant Tasks notification pushed [TYPE] onUpdate [DOCUMENT] /owner_owner_join/" + context.params.id);
                    }).catch((err) => {
                        console.error(err);
                    });
                }
            }


        });

//////////////////////////////////////////////////////////////////////////////////////////
// Update Owner Owner  Notifications (landlord related)
//////////////////////////////////////////////////////////////////////////////////////////
exports.updateOwnerOwnerJoin =
    functions
        .firestore
        .document('owner_owner_join/{id}')
        .onUpdate(async (snapshot, context) => {
            msgData = snapshot.after.data();
            var tokens = [];
            var userName = "";
            if ("status" in msgData) { //update is either accept or reject and not add or delete from owner id list
                var statusStr = msgData.status == 1 ? "accepted" : "rejected";
                var requestSnapshot = await admin.firestore().collection('owner_owner_join').doc(context.params.id).get();
                if (requestSnapshot.data().toUserId == null) {  //one of the owners either accepted or rejected request

                    var ret7 = await getOwnerTokensAndUserName(requestSnapshot.data().ownerIdList, msgData.user_id);

                    if (ret7 != null) {
                        tokens = tokens.concat(ret7.tokens);
                        userName = ret7.userName;
                    }
                    else {
                        console.error("owner_owner_join/" + context.params.id +  " - No owners found during update for owner id list");
                    }

                    var landlordSnapshot1 = await admin.firestore().collection('landlord').doc(requestSnapshot.data().requesterId).get();
                    if (landlordSnapshot1.empty) {
                        console.error("No Landlord User [DOCUMENT] /owner_owner_join/" + context.params.id);
                    } else {


                        tokens.push(landlordSnapshot1.data().notificationToken);

                    }

                    if (tokens.length == 0) {
                        console.error("No Tokens [DOCUMENT] /owner_owner_join/" + context.params.id);
                    } else {
                        var body = userName != ""
                            ? userName + " has " + statusStr + " a coowner request from" + requestSnapshot.data().requesterUserName
                            : "An owner request was updated";
                        var payload = createPayload("Update to join request", body, userName, "owner_owner_join", body);
						var owners = requestSnapshot.data().ownerIdList;
						owners.push(requestSnapshot.data().toUserId);
                        createActivity("Update to join request", body, userName, context.params.id, requestSnapshot.data().flatId, null, null, owners, requestSnapshot.data().buildingName, requestSnapshot.data().flatName);

                        return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                            console.log("Landlord-Tenant Tasks notification pushed [TYPE] onUpdate [DOCUMENT] /owner_owner_join/" + context.params.id);
                        }).catch((err) => {
                            console.error(err);
                        });
                    }

                }
                else {  //coowner accepted or rejected request from one of the owners
                    var ret6 = await getOwnerTokens(requestSnapshot.data().ownerIdList);
                    if (ret6 != null) {
                        tokens = tokens.concat(ret6);
                    }
                    else {
                        console.error("owner_owner_join/" + context.params.id +  " - No owners found during update for owner id list");
                    }

                    userName = requestSnapshot.data().toUserName;
                    if (tokens.length == 0) {
                        console.error("No Tokens [DOCUMENT] /owner_owner_join/" + context.params.id);
                    } else {
                        var body = userName != ""
                            ? userName + " has " + statusStr + " an owner request from" + requestSnapshot.data().requesterUserName
                            : "An owner request was updated";
                        var payload = createPayload("Update to join request", body, userName, "owner_owner_join", body);
						var owners = requestSnapshot.data().ownerIdList;
						owners.push(requestSnapshot.data().requesterId);
                        createActivity("Update to join request", body, userName, context.params.id, requestSnapshot.data().flatId, null, null, owners, requestSnapshot.data().buildingName, requestSnapshot.data().flatName);

                        return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                            console.log("Landlord-Tenant Tasks notification pushed [TYPE] onUpdate [DOCUMENT] /owner_owner_join/" + context.params.id);
                        }).catch((err) => {
                            console.error(err);
                        });
                    }
                }

            }


        });

//////////////////////////////////////////////////////////////////////////////////////////
// Owner Tenant  Notifications
//////////////////////////////////////////////////////////////////////////////////////////
exports.createOwnerTenantJoin =
    functions
        .firestore
        .document('joinflat_landlord_tenant/{id}')
        .onCreate(async (snapshot, context) => {
            msgData = snapshot.data();
            var tokens = [];
            var userName = "";

            if (msgData.requestFromTenant == true) {
                var ret5 = await getOwnerTokens(msgData.ownerIdList);
                if (ret5 != null) {
                    tokens = tokens.concat(ret5);
                } else {
                    console.error("joinflat_landlord_tenant/" + context.params.id +  " - No owners found for owner id list");
                }

                var ret2 = await getTenantTokensAndUserName(msgData.tenantFlatId, msgData.user_id);

                if (ret2 != null) {
                    tokens = tokens.concat(ret2.tokens);
                    userName = ret2.userName;
                } else {
                    console.error("joinflat_landlord_tenant/" + context.params.id +  " - No tenants found for flatid: " + msgData.tenantFlatId);
                }

            }
            else {  //request from owner to tenant

                var ret1 = await getOwnerTokensAndUserNameFromOwnerFlat(msgData.ownerFlatId, msgData.user_id);
                if (ret1 != null) {
                    tokens = tokens.concat(ret1.tokens);
                    userName = ret1.userName;
                }
                else {
                    console.error("joinflat_landlord_tenant/" + context.params.id +  " - No owners found for owner flat id: " + msgData.ownerFlatId);
                }


                var tokensTemp = await getTenantTokens(msgData.tenantFlatId);
                if (tokensTemp != null) {
                    tokens = tokens.concat(tokensTemp);
                }
                else {
                    console.error("joinflat_landlord_tenant/" + context.params.id +  " - No tenants found for flatid: " + msgData.tenantFlatId);
                }




            }

            if (tokens.length == 0) {
                console.error("No Tokens [DOCUMENT] /joinflat_landlord_tenant/" + context.params.id);
            } else {
                var body = userName != ""
                    ? userName + " has sent a tenant request"
                    : "You have a new request";
                var payload = createPayload("New join request", body, userName, "joinflat_landlord_tenant", body);

                createActivity("New join request", body, userName, context.params.id, msgData.ownerFlatId, msgData.tenantFlatId, context.params.id, msgData.ownerIdList, msgData.buildingName, msgData.ownerFlatName);

                return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                    console.log("Tenant join notification pushed [TYPE] onUpdate [DOCUMENT] /joinflat_landlord_tenant/" + context.params.id);
                }).catch((err) => {
                    console.error(err);
                });
            }

        });

//////////////////////////////////////////////////////////////////////////////////////////
// Update Landlord Tenant  Notifications
//////////////////////////////////////////////////////////////////////////////////////////
exports.updateOwnerTenantJoin =
    functions
        .firestore
        .document('joinflat_landlord_tenant/{id}')
        .onUpdate(async (snapshot, context) => {
            msgData = snapshot.after.data();
            var tokens = [];
            var userName = "";
            if ("status" in msgData) { //update is either accept or reject and not add or delete from owner id list
                var statusStr = msgData.status == 1 ? "accepted" : "rejected";
                var requestSnapshot = await admin.firestore().collection('joinflat_landlord_tenant').doc(context.params.id).get();
                if (requestSnapshot.data().requestFromTenant == true) {  //one of the owners either accepted or rejected request
                    var ret4 = await getOwnerTokensAndUserName(requestSnapshot.data().ownerIdList, msgData.user_id);

                    if (ret4 != null) {
                        tokens = tokens.concat(ret4.tokens);
                        userName = ret4.userName;
                    }
                    else {
                        console.error("joinflat_landlord_tenant/" + context.params.id +  " - No owners found during update for owner id list");
                    }

                    var tokensTemp = await getTenantTokens(requestSnapshot.data().tenantFlatId);
                    if (tokensTemp != null) {
                        tokens = tokens.concat(tokensTemp);
                    }
                    else {
                        console.error("joinflat_landlord_tenant/" + context.params.id +  " - No tenants found during update for flatid: " + requestSnapshot.data().tenantFlatId);
                    }



                    if (tokens.length == 0) {
                        console.error("No Tokens [DOCUMENT] /joinflat_landlord_tenant/" + context.params.id);
                    } else {
                        var body = userName != ""
                            ? userName + " has " + statusStr + " a tenant request from" + requestSnapshot.data().createdBy.name
                            : "A tenant request was updated";
                        var payload = createPayload("Update to tenant join request", body, userName, "joinflat_tenant_landlord", body);

                        createActivity("Update to tenant join request", body, userName, context.params.id, requestSnapshot.data().ownerFlatId, requestSnapshot.data().tenantFlatId, context.params.id, requestSnapshot.data().ownerIdList, requestSnapshot.data().buildingName, requestSnapshot.data().ownerFlatName);

                        return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                            console.log("Landlord-Tenant join notification pushed [TYPE] onUpdate [DOCUMENT] /joinflat_landlord_tenant/" + context.params.id);
                        }).catch((err) => {
                            console.error(err);
                        });
                    }
                }
            }
            else {  //tenant accepted or rejected request from one of the owners
                var ret15 = await getOwnerTokensAndUserNameFromOwnerFlat(requestSnapshot.data().ownerFlatId, "");
                if (ret15 != null) {
                    tokens = tokens.concat(ret15.tokens);
                }
                else {
                    console.error("joinflat_landlord_tenant/" + context.params.id +  " - No owners found during update for owner flat id: " + requestSnapshot.data().ownerFlatId);
                }

                var ret = await getTenantTokensAndUserName(requestSnapshot.data().tenantFlatId, msgData.user_id);
                if (ret != null) {
                    tokens = tokens.concat(ret.tokens);
                    userName = ret.userName;
                }
                else {
                    console.error("joinflat_landlord_tenant/" + context.params.id +  " - No tenants found during update for flatid: " + requestSnapshot.data().tenantFlatId);
                }

                if (tokens.length == 0) {
                    console.error("No Tokens [DOCUMENT] /joinflat_landlord_tenant/" + context.params.id);
                } else {
                    var body = userName != ""
                        ? userName + " has " + statusStr + " an owner request from" + requestSnapshot.data().createdBy.name
                        : "A tenant request was updated";
                    var payload = createPayload("Update to tenant join request", body, userName, "joinflat_landlord_tenant", body);

                    createActivity("Update to tenant join request", body, userName, context.params.id, requestSnapshot.data().ownerFlatId, requestSnapshot.data().tenantFlatId, context.params.id, requestSnapshot.data().ownerIdList, requestSnapshot.data().buildingName, requestSnapshot.data().ownerFlatName);

                    return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                        console.log("Tenant join notification pushed [TYPE] onUpdate [DOCUMENT] /joinflat_landlord_tenant/" + context.params.id);
                    }).catch((err) => {
                        console.error(err);
                    });
                }
            }

        });


async function getTenantTokens(flatId) {
    var token = [];
    var userSnapshots = admin.firestore().collection('user').where('flat_id', '==', flatId).get();
    if (userSnapshots.empty) {
        return null;
    } else {
        for (var document in userSnapshots.docs) {

            tokens.push(document.data().notification_token);
        }
        return token;
    }
}

async function getTenantTokensAndUserName(flatId, userId) {
    var tokens = [];
    var userName = "";
    var userSnapshots = await admin.firestore().collection('user').where('flat_id', '==', flatId).get();
    if (userSnapshots.empty) {
        return null;
    } else {
        for (var document of userSnapshots.docs) {
            if (document.id == userId) {
                userName = document.data().name;
            } else {
                tokens.push(document.data().notification_token);
            }
        }

        return { tokens: tokens, userName: userName };
    }

}

async function getOwnerTokens(ownerIdList) {
    var tokens = [];
    if (ownerIdList != null) {
        for (var owner in ownerIdList) {
            var landlordSnapshot = await admin.firestore().collection('landlord').doc(owner).get();
            if (landlordSnapshot.empty || landlordSnapshot.data() == undefined) {
                return null;
            } else {


                tokens.push(landlordSnapshot.data().notificationToken);	//error here, cannot read ntfn of undefined


            }

        }

        return tokens;
    }
}

async function getOwnerTokensAndUserNameFromOwnerFlat(ownerFlatId, userId) {
    var userId;
    var tokens = [];
    var userName = "";
	var owners = [];
    var flatSnapshot = await admin.firestore().collection('ownerFlat').doc(ownerFlatId).get();
    if (flatSnapshot.empty) {
        return null;
    } else {
        var ownerIdList = flatSnapshot.data().ownerIdList;
		owners = ownerIdList;
        for (var owner in ownerIdList) {
			console.info(owner);
            var landlordSnapshot = await admin.firestore().collection('landlord').doc(owner).get();
			console.info(landlordSnapshot);
            if (landlordSnapshot.empty || landlordSnapshot.data() == undefined) {
            } else {
                if (owner == userId) {
                    userName = landlordSnapshot.data().name;
                } else {
                    tokens.push(landlordSnapshot.data().notificationToken);
                }

            }

        }

        return { tokens: tokens, userName: userName, owners: owners };
    }
}

async function getOwnerTokensAndUserName(ownerIdList, userId) {
    var tokens = [];
    var userName = "";
    if (ownerIdList != null) {
        for (var owner in ownerIdList) {
            var landlordSnapshot = await admin.firestore().collection('landlord').doc(owner).get();
            if (landlordSnapshot.empty) {
            } else {

                if (owner == userId) {
                    userName = landlordSnapshot.data().name;
                }
                else {
                    tokens.push(landlordSnapshot.data().notificationToken);
                }

            }

        }
        return { tokens: tokens, userName: userName };
    }
    else {
        return null;
    }



}


async function getApartmentTenantDocument(owner_tenant_flat_id) {
    ownerTenantSnapshots = await admin.firestore().collection('notification_tokens').doc(owner_tenant_flat_id).get();
    if (ownerTenantSnapshots.empty) {
        return null;
    } else {

        return ownerTenantSnapshots.data();
    }
}

function getOwnerTokensAndUserNameUsingDoc(userList, userId) {
    var tokens = [];
    var userName = "";
	var owners = [];
    if (userList != null) {
		for(var key of Object.keys(userList)) {
            if(key.startsWith("o_")) {
                var ownerId = key.substr(2);
                owners.push(ownerId);
                var elems = userList[key].split('::');
                if (ownerId == userId) {
                    userName = elems[0];
                }
                else if(elems[1] != undefined && elems[1] != ''){
                    tokens.push(elems[1]);
                }
            }
        }
            
        return { tokens: tokens, userName: userName, owners: owners};
    }
    else {
        return null;
    }

}

function getTenantTokensAndUserNameUsingDoc(userList, userId) {
    var tokens = [];
    var userName = "";
    if (userList != null) {
        for(var key of Object.keys(userList)) {
            if(key.startsWith("t_")) {
                var ownerId = key.substr(2);
                var elems = userList[key].split('::');
                if (ownerId == userId) {
                    userName = elems[0];
                }
                else if(elems[1] != undefined && elems[1] != '') {
                    tokens.push(elems[1]);
                }
            }
        }
            
        return { tokens: tokens, userName: userName };
    }
    else {
        return null;
    }

}


function createPayload(title, body, sendername, screen, message) {
    return {
        "notification": {
            "title": title,
            "body": body,
            "sound": "default"
        },
        "data": {
            "sendername": sendername,
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "screen": screen,
            "message": message
        }
    }
}

function createActivity(title, message, sendername, documentId, ownerFlatId, tenantFlatId, ownerTenantFlatId, userList, buildingName, ownerFlatName) {

	if(ownerFlatName == undefined)
		ownerFlatName = '';
	if(buildingName == undefined)
		buildingName = '';
	if(userList == undefined)
		userList = [];
    
    var data = {title: title, message: message, sendername: sendername, documentId: documentId, ownerFlatId: ownerFlatId, ownerFlatName: ownerFlatName, buildingName: buildingName, tenantFlatId: tenantFlatId, ownerTenantFlatId: ownerTenantFlatId, timestamp: admin.firestore.Timestamp.fromDate(new Date()), userList: userList};

    admin.firestore().collection('activity').add(data);


}

async function processTenantRequest(data, context, tenantRequestDoc) {
    try {
        var batch = admin.firestore().batch();

        //accept request
        var tenantReqDocRef = admin.firestore().collection('joinflat_landlord_tenant').doc(data["requestId"]);
        batch.update(tenantReqDocRef, {'status': 1});
        
        //reject all other requests received by landlord for that owner flat
        var tenantRequestsQs = await admin.firestore().collection('joinflat_landlord_tenant')
        .where('ownerFlatId', '==', tenantRequestDoc.data()["ownerFlatId"])
        .where('status', '==', 0)
        .where('requestFromTenant', '==', true)
        .get();
        
        for(var doc of tenantRequestsQs.docs) {
            if(doc.id != data["requestId"]) {
                var tenantReqToRej = admin.firestore().collection('joinflat_landlord_tenant').doc(doc.id);
                batch.update(tenantReqToRej, {'status': 2});
            }
        }

        //reject all other requests received by tenant for that tenant flat
        var tenantRequestsQsT = await admin.firestore().collection('joinflat_landlord_tenant')
        .where('tenantFlatId', '==', tenantRequestDoc.data()["tenantFlatId"])
        .where('status', '==', 0)
        .where('requestFromTenant', '==', false)
        .get();
        
        for(var doc of tenantRequestsQsT.docs) {
            if(doc.id != data["requestId"]) {
                var tenantReqToRej = admin.firestore().collection('joinflat_landlord_tenant').doc(doc.id);
                batch.update(tenantReqToRej, {'status': 2});
            }
        }

        //delete all other sent requests by landlord for that owner flat
        var tenantReqQs1 = await admin.firestore().collection('joinflat_landlord_tenant')
        .where('ownerFlatId', '==', tenantRequestDoc.data()["ownerFlatId"])
        .where('status', '==', 0)
        .where('requestFromTenant', '==', false)
        .get();

        for(var doc of tenantReqQs1.docs) {
            if(doc.id != data["requestId"]) {
                var tenantReqToRej = admin.firestore().collection('joinflat_landlord_tenant').doc(doc.id);
                batch.delete(tenantReqToRej);
            }
        }

        //delete all other sent requests by tenant for that tenant flat
        var tenantReqQs1T = await admin.firestore().collection('joinflat_landlord_tenant')
        .where('tenantFlatId', '==', tenantRequestDoc.data()["tenantFlatId"])
        .where('status', '==', 0)
        .where('requestFromTenant', '==', true)
        .get();

        for(var doc of tenantReqQs1T.docs) {
            if(doc.id != data["requestId"]) {
                var tenantReqToRej = admin.firestore().collection('joinflat_landlord_tenant').doc(doc.id);
                batch.delete(tenantReqToRej);
            }
        }

        //create owner tenant and notification tokens documents
        var notificationTokensDocRef = admin.firestore().collection('notification_tokens').doc();
        var ownerTenantDocRef = admin.firestore().collection('owner_tenant_flat').doc(notificationTokensDocRef.id);
        var ownerTenantData = {};
        var notificationsData = {};

        ownerTenantData['ownerFlatId'] = tenantRequestDoc.data()['ownerFlatId'];
        ownerTenantData['tenantFlatId'] =  tenantRequestDoc.data()['tenantFlatId'];
        ownerTenantData['status'] = 0;
        ownerTenantData['tenantFlatName'] = tenantRequestDoc.data()['tenantFlatName'];
        ownerTenantData['buildingName'] = tenantRequestDoc.data()['buildingDetails']['buildingName'];
        ownerTenantData['buildingAddress'] = tenantRequestDoc.data()['buildingDetails']['buildingAddress'];
        ownerTenantData['zipcode'] = tenantRequestDoc.data()['buildingDetails']['buildingZipcode'];
        ownerTenantData['ownerFlatName'] = tenantRequestDoc.data()['ownerFlatName'];

        notificationsData['ownerFlatId'] = tenantRequestDoc.data()['ownerFlatId'];
        notificationsData['tenantFlatId'] =  tenantRequestDoc.data()['tenantFlatId'];
        notificationsData['status'] = 0;
        notificationsData['tenantFlatName'] = tenantRequestDoc.data()['tenantFlatName'];
        notificationsData['buildingName'] = tenantRequestDoc.data()['buildingDetails']['buildingName'];
        notificationsData['buildingAddress'] = tenantRequestDoc.data()['buildingDetails']['buildingAddress'];
        notificationsData['zipcode'] = tenantRequestDoc.data()['buildingDetails']['buildingZipcode'];
        notificationsData['ownerFlatName'] = tenantRequestDoc.data()['ownerFlatName'];

        //add owner list
        var ownerFlatDoc = await admin.firestore().collection('ownerFlat').doc(tenantRequestDoc.data()["ownerFlatId"]).get();
        for(var ownerId of ownerFlatDoc.data().ownerIdList) {
            var landlordRef = await admin.firestore().collection('landlord').doc(ownerId).get();
            ownerTenantData['o_' + ownerId] = landlordRef.data()['name'] + '::' + landlordRef.data()['phone'];
            notificationsData['o_' + ownerId] = landlordRef.data()['name'] + '::' + landlordRef.data()['notificationToken'];
        }

        //add tenant list
        var TenantQs = await admin.firestore().collection('user').where('flat_id', '==', tenantRequestDoc.data()['tenantFlatId']).get();
        for(var doc of TenantQs.docs) {
            ownerTenantData['t_' + doc.id] = doc.data()['name'] + '::' + doc.data()['phone'];
            notificationsData['t_' + doc.id] = doc.data()['name'] + '::' + doc.data()['notification_token'];
        }
        batch.set(ownerTenantDocRef, ownerTenantData);
        batch.set(notificationTokensDocRef, notificationsData);

        //update owner flat with owner tenant id
        var ownerFlatStatusRef = admin.firestore().collection('ownerFlat').doc(tenantRequestDoc.data()['ownerFlatId']);
        batch.update(ownerFlatStatusRef, {'ownerTenantId': notificationTokensDocRef.id});

        await batch.commit();

        return {'code': 0};
    } catch (e) {
        console.info(e);
        return {'code': -1};
    }
}

async function isUserTenantOfFlat(userId, tenantFlatId) {
    var userDoc = await admin.firestore().collection('user').doc(userId).get();
    return (userDoc.exists && userDoc.data()['flat_id'] == tenantFlatId);
}

exports.acceptLandlordRequest = functions.https.onCall(async (data, context) => {
    var tenantRequestDoc = await admin.firestore().collection('joinflat_landlord_tenant').doc(data["requestId"]).get();
    var isTenant = await isUserTenantOfFlat(context.auth.uid, tenantRequestDoc.data()['tenantFlatId']);
    if(isTenant) {
        var ret = await processTenantRequest(data, context, tenantRequestDoc);
    } else {
        console.info("user not authorized");
        return {'code': -1};
    }

    return ret;
});

exports.acceptTenantRequest = functions.https.onCall(async (data, context) => {
    var tenantRequestDoc = await admin.firestore().collection('joinflat_landlord_tenant').doc(data["requestId"]).get();
	var trOwnerIdList = tenantRequestDoc.data()["ownerIdList"];
    if(trOwnerIdList != null && trOwnerIdList != undefined && tenantRequestDoc.data()["ownerIdList"] != null && tenantRequestDoc.data()["ownerIdList"] != undefined && tenantRequestDoc.data()["ownerIdList"].includes(context.auth.uid)) {
        var ret = await processTenantRequest(data, context, tenantRequestDoc);    
    } else {
        console.info("user not authorized");
        return {'code': -1};
    }

    return ret;
});

exports.acceptRequestFromOwner = functions.https.onCall(async (data, context) => {
    var ownerRequestDoc = await admin.firestore().collection('owner_owner_join').doc(data["requestId"]).get();
    if(ownerRequestDoc.data()["toUserId"] == context.auth.uid) {
        try {
            var batch = admin.firestore().batch();

            var landlordDoc = await admin.firestore().collection('landlord').doc(context.auth.uid).get();

            //accept request
            var ownerReqDocRef = admin.firestore().collection('owner_owner_join').doc(data["requestId"]);
            batch.update(ownerReqDocRef, {'status': 1});

            //update ownerIdList map in owner flat to include new owner
            var ownerFlatRef = admin.firestore().collection('ownerFlat').doc(ownerRequestDoc.data()["flatId"]);
            batch.update(ownerFlatRef, {'ownerIdList': admin.firestore.FieldValue.arrayUnion(ownerRequestDoc.data()["toUserId"]), 'ownerRoleList': admin.firestore.FieldValue.arrayUnion(ownerRequestDoc.data()["toUserId"] + ':' + landlordDoc.data()["name"] + ':' + '1')});

            //delete all owner requests sent by that coowner for that owner flat
            var mySentReqQS = await admin.firestore().collection('owner_owner_join')
            .where('status', '==', 0)
            .where('flatId', '==', ownerRequestDoc.data()["flatId"])
            .where('requesterId', '==', context.auth.uid)
            .where('requestToOwner', '==', true).get();

            for(var doc of mySentReqQS.docs) {
                if(doc.id != data["requestId"]) {
                    var ownerReqRefTemp = admin.firestore().collection('owner_owner_join').doc(doc.id);
                    batch.delete(ownerReqRefTemp);
                }
            }
            
            //add new owner in ownerIdList map in all tenant requests for that owner flat
            var tenantRefQS = await admin.firestore()
            .collection('joinflat_landlord_tenant')
            .where('ownerFlatId', '==', ownerRequestDoc.data()["flatId"])
            .where('status', '==', 0).get();

            for(var doc of tenantRefQS.docs) {
                var tenantDocRef = admin.firestore().collection('joinflat_landlord_tenant').doc(doc.id);
                batch.update(tenantDocRef, {'ownerIdList': admin.firestore.FieldValue.arrayUnion(ownerRequestDoc.data()["toUserId"])});
            }

            //add new owner in ownerIdList map in all owner requests for that owner flat
            var recOwnerReqQS = await admin.firestore().collection('owner_owner_join')
            .where('status', '==', 0)
            .where('flatId', '==', ownerRequestDoc.data()["flatId"])
            .get();

            for(var doc of recOwnerReqQS.docs) {
				if(doc.id != data["requestId"]) {
                	var recOwnerDocRef = admin.firestore().collection('owner_owner_join').doc(doc.id);
                	batch.update(recOwnerDocRef, {'ownerIdList': admin.firestore.FieldValue.arrayUnion(ownerRequestDoc.data()["toUserId"])});
				}
            }

            //update owner tenant and notification tokens documents to include new owner
            var ownerTenantQS = await admin.firestore().collection('owner_tenant_flat')
            .where('status', '==', 0)
            .where('ownerFlatId', '==', ownerRequestDoc.data()["flatId"]).get();

            if(ownerTenantQS != undefined && ownerTenantQS != null && !ownerTenantQS.empty) {
                for(var doc of ownerTenantQS.docs) {
                    var ownerTenantDocRef = admin.firestore().collection('owner_tenant_flat').doc(doc.id);
                    var ntfnDocRef = admin.firestore().collection('notification_tokens').doc(doc.id);
                    var key = "o_" + context.auth.uid;

                    batch.update(ownerTenantDocRef, {[key]: landlordDoc.data()["name"] + landlordDoc.data()["phone"]});
                    batch.update(ntfnDocRef, {[key]: landlordDoc.data()["name"] + landlordDoc.data()["notificationToken"]});
                }
            }

            await batch.commit();
            return {'code': 0};
        }
        catch(e) {
            console.info(e);
            return {'code': -1};
        }
    }
    else {
		console.info("user not authorized");
        return {'code': -1};
    }
});


exports.acceptRequestFromCoOwner = functions.https.onCall(async (data, context) => {
    var ownerRequestDoc = await admin.firestore().collection('owner_owner_join').doc(data["requestId"]).get();
    if(ownerRequestDoc.data()["ownerIdList"] != null && ownerRequestDoc.data()["ownerIdList"] != undefined && ownerRequestDoc.data()["ownerIdList"].includes(context.auth.uid)) {
        try {
            var batch = admin.firestore().batch();

            var landlordDoc = await admin.firestore().collection('landlord').doc(ownerRequestDoc.data()["requesterId"]).get();

            //accept request
            var ownerReqDocRef = admin.firestore().collection('owner_owner_join').doc(data["requestId"]);
            batch.update(ownerReqDocRef, {'status': 1});

            //update ownerIdList map in owner flat to include new owner
            var ownerFlatRef = admin.firestore().collection('ownerFlat').doc(ownerRequestDoc.data()["flatId"]);
            batch.update(ownerFlatRef, {'ownerIdList': admin.firestore.FieldValue.arrayUnion(ownerRequestDoc.data()["requesterId"]), 'ownerRoleList': admin.firestore.FieldValue.arrayUnion(ownerRequestDoc.data()["requesterId"] + ':' + landlordDoc.data()["name"] + ':' + '1')});

            //delete all other owner requests sent by the owner to that coowner for that owner flat
            var mySentReqQS = await admin.firestore().collection('owner_owner_join')
            .where('status', '==', 0)
            .where('flatId', '==', ownerRequestDoc.data()["flatId"])
            .where('toUserId', '==', landlordDoc.id)
            .where('requestToOwner', '==', false).get();

            for(var doc of mySentReqQS.docs) {
                if(doc.id != data["requestId"]) {
                    var ownerReqRefTemp = admin.firestore().collection('owner_owner_join').doc(doc.id);
                    batch.delete(ownerReqRefTemp);
                }
            }
            
            //add new owner in ownerIdList map in all tenant requests for that owner flat
            var tenantRefQS = await admin.firestore()
            .collection('joinflat_landlord_tenant')
            .where('ownerFlatId', '==', ownerRequestDoc.data()["flatId"])
            .where('status', '==', 0).get();

            for(var doc of tenantRefQS.docs) {
                var tenantDocRef = admin.firestore().collection('joinflat_landlord_tenant').doc(doc.id);
                batch.update(tenantDocRef, {'ownerIdList': admin.firestore.FieldValue.arrayUnion(landlordDoc.id)});
            }

            //add new owner in ownerIdList map in all owner requests for that owner flat
            var recOwnerReqQS = await admin.firestore().collection('owner_owner_join')
            .where('status', '==', 0)
            .where('flatId', '==', ownerRequestDoc.data()["flatId"])
            .get();

            for(var doc of recOwnerReqQS.docs) {
				if(doc.id != data["requestId"]) {
                	var recOwnerDocRef = admin.firestore().collection('owner_owner_join').doc(doc.id);
                	batch.update(recOwnerDocRef, {'ownerIdList': admin.firestore.FieldValue.arrayUnion(landlordDoc.id)});
				}
            }

            //add new owner in owner tenant flat and notification tokens documents
            var ownerTenantQS = await admin.firestore().collection('owner_tenant_flat')
            .where('status', '==', 0)
            .where('ownerFlatId', '==', ownerRequestDoc.data()["flatId"]).get();

            if(ownerTenantQS != undefined && ownerTenantQS != null && !ownerTenantQS.empty) {
                for(var doc of ownerTenantQS.docs) {
                    var ownerTenantDocRef = admin.firestore().collection('owner_tenant_flat').doc(doc.id);
                    var ntfnDocRef = admin.firestore().collection('notification_tokens').doc(doc.id);
                    var key = "o_" + landlordDoc.id;

                    batch.update(ownerTenantDocRef, {[key]: landlordDoc.data()["name"] + landlordDoc.data()["phone"]});
                    batch.update(ntfnDocRef, {[key]: landlordDoc.data()["name"] + landlordDoc.data()["notificationToken"]});
                }
            }

            await batch.commit();
            return {'code': 0};
        }
        catch(e) {
            console.info(e);
            return {'code': -1};
        }
    }
    else {
		console.info("user not authorized");
        return {'code': -1};
    }
});

exports.makeOwnerAdminForFlat = functions.https.onCall(async (data, context) => {
    try {
        var ownerFlatDoc = await admin.firestore().collection('ownerFlat').doc(data["ownerFlatId"]).get();
        if(!ownerFlatDoc.exists) {
            return {'code': -1, 'message': 'Owner flat does not exist'};
        }

        var ownerRoleList = ownerFlatDoc.data()["ownerRoleList"].slice(0);

        var userRole = null;
        var newOwnerRole = null;
		var userRole1 = null;
		var newOwnerRole1 = null;
        for(var role of ownerRoleList) {
            var elems = role.split(':');
            if(elems[0] == context.auth.uid) {
                if(elems[2] != 0) {
                    return {'code': -1, 'message': 'User needs admin privileges'};
                }
                else {
                    userRole = role;
                    userRole1 = elems[0] + ':' + elems[1] + ':' + '1';
                }
            }
            else if(elems[0] == data["ownerId"]) {
                newOwnerRole = role;
                newOwnerRole1 = elems[0] + ':' + elems[1] + ':' + '0';
            }
        }

        if(userRole == null || newOwnerRole == null) {
            return {'code': -1, 'message': 'Could not find roles for users'};
        }

        //remove role of old admin
		var index = ownerRoleList.indexOf(userRole);
		if (index !== -1) {
  			ownerRoleList.splice(index, 1);
        }
        
        //remove role of new admin
		index = ownerRoleList.indexOf(newOwnerRole);
		if (index !== -1) {
  			ownerRoleList.splice(index, 1);
		}

        //push new roles of old and new admins
		ownerRoleList.push(userRole1);
		ownerRoleList.push(newOwnerRole1);

        
        var ownerFlatRef = admin.firestore().collection('ownerFlat').doc(data["ownerFlatId"]);
        await ownerFlatRef.update({'ownerRoleList':  ownerRoleList});
        return {'code': 0, 'message': 'Successful'};
    }
    catch(e) {
        console.info(e);
        return {'code': -1, 'message': 'Error'};
    }
});

exports.removeOwnerFromFlat = functions.https.onCall(async (data, context) => {
    var ownerFlatId = data["ownerFlatId"];
    var ownerId = data["ownerId"];
    var db = admin.firestore();
    var batch = db.batch();
    var ownerRole;
    try {
        var userDoc = await db.collection('landlord').doc(context.auth.uid).get();
        var ownerFlatDoc = await db.collection('ownerFlat').doc(ownerFlatId).get();
        var ownerRoleList = ownerFlatDoc.data()["ownerRoleList"];
        for(var role of ownerRoleList) {
            var elems = role.split(':');
            if(elems[0] == context.auth.uid) {
                if(elems[2] != 0) {
                    return {'code': -1, 'message': 'User needs admin privileges'};
                }
            } else if(elems[0] == ownerId) {
                ownerRole = role; 
            }
        }

        //remove owner from ownerIdList map and ownerRoleList array in owner flat
        var ownerFlatRef = db.collection('ownerFlat').doc(ownerFlatId);
        batch.update(ownerFlatRef, {'ownerIdList': admin.firestore.FieldValue.arrayRemove(ownerId), 'ownerRoleList': admin.firestore.FieldValue.arrayRemove(ownerRole)});

        //remove owner from ownerIdList map in all owner requests for that owner flat. Also, change requester details of requests created by removed owner to user performing remove owner action
        var ownerRequestsRef = await db.collection('owner_owner_join').where('status', '==', 0)
    .where('flatId', '==', ownerFlatId).get();

        for(var oReq of ownerRequestsRef.docs) {
            var data = {'ownerIdList': admin.firestore.FieldValue.arrayRemove(ownerId)};
            if(oReq.data()['requesterId'] == ownerId) {
                data['requesterId'] = context.auth.uid;
                data['requesterUserName'] = userDoc.data()['name'];
                data['requesterPhone'] = userDoc.data()['phone'];
            }
            batch.update(db.collection('owner_owner_join').doc(oReq.id), data);
        }

        //remove owner from ownerIdList map in all tenant requests for that owner flat. Also, change createdBy details of requests created by removed owner to user performing remove owner action
        var tenantRequestsRef = await db.collection('joinflat_landlord_tenant').where('status', '==', 0)
    .where('ownerFlatId', '==', ownerFlatId).get();

        for(var tReq of tenantRequestsRef.docs) {
            var data = {'ownerIdList': admin.firestore.FieldValue.arrayRemove(ownerId)};
            if(tReq.data()['createdBy']['userId'] == ownerId) {
                data['createdBy']['userId'] = context.auth.uid;
                data['createdBy']['name'] = userDoc.data()['name'];
                data['createdBy']['phone'] = userDoc.data()['phone'];
            }
            batch.update(db.collection('joinflat_landlord_tenant').doc(tReq.id), data);
        }

        //remove owner from owner tenant and notification tokens documents
        var ownerTenantQS = await admin.firestore().collection('owner_tenant_flat')
        .where('status', '==', 0)
        .where('ownerFlatId', '==', ownerFlatId).get();

        if(ownerTenantQS != undefined && ownerTenantQS != null && !ownerTenantQS.empty) {
            for(var doc of ownerTenantQS.docs) {
                var ownerTenantDocRef = admin.firestore().collection('owner_tenant_flat').doc(doc.id);
                var ntfnDocRef = admin.firestore().collection('notification_tokens').doc(doc.id);
                var key = "o_" + ownerId;

                batch.update(ownerTenantDocRef, {[key]: admin.firestore.FieldValue.delete()});
                batch.update(ntfnDocRef, {[key]: admin.firestore.FieldValue.delete()});
            }
        }

        await batch.commit();
        return {'code': 0, 'message': 'Successful'};

    } catch(e) {
        console.info(e);
        return {'code': -1, 'message': 'Error'};
    }
});

exports.evacuateFlat = functions.https.onCall(async (data, context) => {
    try {
        var db = admin.firestore();
        var batch = db.batch();
        var ownerTenantId = data['ownerTenantId'];

        //check if user performing action is owner of owner flat
        var ownerTenantDocRef =  db.collection('owner_tenant_flat').doc(ownerTenantId);
        var ownerTenantDoc = await ownerTenantDocRef.get();

        var owner = ownerTenantDoc.data()['o_' + context.auth.uid];
        if(owner == null || owner == undefined) {
            return {'code': -1, 'message': 'User lacks authorization. User is not an owner of the flat'};
        }

        //change status to 1 in owner tenant and notification tokens documents for the received owner tenant id
        var ntfnDocRef =  db.collection('notification_tokens').doc(ownerTenantId);

        batch.update(ownerTenantDocRef, {'status': 1});
        batch.update(ntfnDocRef, {'status': 1});

        //make owner tenant id in owner flat document blank
        var ownerFlatRef = db.collection('ownerFlat').doc(ownerTenantDoc.data()['ownerFlatId']);
        batch.update(ownerFlatRef, {'ownerTenantId': ''});

        await batch.commit();
        return {'code': 0, 'message': 'Successful'};

    } catch(e) {
        console.info(e);
        return {'code': -1, 'message': 'Error'};
    }
});