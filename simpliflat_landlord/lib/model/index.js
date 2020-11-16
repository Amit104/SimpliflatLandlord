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
            var ret = getTenantTokensAndUserName(atd, msgData.user_id);
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
            var ret = await getTenantTokensAndUserName(atd, msgData.user_id);
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
// joinflat Notifications
//////////////////////////////////////////////////////////////////////////////////////////

exports.joinFlat =
    functions
        .firestore
        .document('joinflat/{id}')
        .onCreate((snapshot, context) => {
            msgData = snapshot.data();
            var tokens = []

            if (msgData.status == 0) {
                // join request to flat
                if (msgData.request_from_flat == 0) {
                    admin.firestore().collection('user').where('flat_id', '==', msgData.flat_id).get().then((userSnapshots) => {
                        if (userSnapshots.empty) {
                            console.error("No User [DOCUMENT] /joinflat/" + context.params.id);
                        } else {
                            for (var document of userSnapshots.docs) {
                                tokens.push(document.data().notification_token);
                            }
                        }

                        if (tokens.length == 0) {
                            console.error("No Tokens [DOCUMENT] /joinflat/" + context.params.id);
                        } else {
                            var payload = {
                                "notification": {
                                    "title": "New Join Request",
                                    "body": msgData.request_from_flat == 0 ? "A user wants to join the flat" : "you have a join request from a flat",
                                    "sound": "default"
                                },
                                "data": {
                                    "sendername": userName,
                                    "click_action": "FLUTTER_NOTIFICATION_CLICK",
                                    "screen": "joinflat",
                                    "message": msgData.request_from_flat == 0 ? "A user wants to join the flat" : "you have a join request from a flat"
                                }
                            }
                            return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                                console.log("joinflat notification pushed [TYPE] onCreate [DOCUMENT] /joinflat/" + context.params.id);
                            }).catch((err) => {
                                console.error(err);
                            });
                        }
                    });
                } else {
                    // Join request to user
                    admin.firestore().collection('user').doc(msgData.user_id).get().then((userSnapshot) => {
                        if (userSnapshot.empty) {
                            console.error("No User [DOCUMENT] /joinflat/" + context.params.id);
                        } else {
                            tokens.push(userSnapshot.data().notification_token);
                        }

                        if (tokens.length == 0) {
                            console.error("No Tokens [DOCUMENT] /joinflat/" + context.params.id);
                        } else {
                            var payload = {
                                "notification": {
                                    "title": "New Join Request",
                                    "body": msgData.request_from_flat == 0 ? "A user wants to join the flat" : "you have a join request from a flat",
                                    "sound": "default"
                                },
                                "data": {
                                    "sendername": userName,
                                    "click_action": "FLUTTER_NOTIFICATION_CLICK",
                                    "screen": "joinflat",
                                    "message": msgData.request_from_flat == 0 ? "A user wants to join the flat" : "you have a join request from a flat"
                                }
                            }
                            return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                                console.log("joinflat notification pushed [TYPE] onCreate [DOCUMENT] /joinflat/" + context.params.id);
                            }).catch((err) => {
                                console.error(err);
                            });
                        }
                    });
                }
            }
        });


//////////////////////////////////////////////////////////////////////////////////////////
// joinflat_landlord Notifications (landlord related)
//////////////////////////////////////////////////////////////////////////////////////////

exports.joinFlatLandlord =
    functions
        .firestore
        .document('joinflat_landlord/{id}')
        .onCreate((snapshot, context) => {
            msgData = snapshot.data();
            var tokens = []
            if (msgData.status == 0) {
                // join request to flat
                if (msgData.request_from_flat == 0) {
                    admin.firestore().collection('user').where('flat_id', '==', msgData.flat_id).get().then((userSnapshots) => {
                        if (userSnapshots.empty) {
                            console.error("No User [DOCUMENT] /joinflat_landlord/" + context.params.id);
                        } else {
                            for (var document of userSnapshots.docs) {
                                tokens.push(document.data().notification_token);
                            }
                        }

                        if (tokens.length == 0) {
                            console.error("No Tokens [DOCUMENT] /joinflat_landlord/" + context.params.id);
                        } else {
                            var payload = {
                                "notification": {
                                    "title": "New Join Request",
                                    "body": msgData.request_from_flat == 0 ? "A landlord wants to join the flat" : "you have a join request from a flat",
                                    "sound": "default"
                                },
                                "data": {
                                    "sendername": userName,
                                    "click_action": "FLUTTER_NOTIFICATION_CLICK",
                                    "screen": "joinflat_landlord",
                                    "message": msgData.request_from_flat == 0 ? "A landlord wants to join the flat" : "you have a join request from a flat"
                                }
                            }
                            return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                                console.log("joinflat_landlord notification pushed [TYPE] onCreate [DOCUMENT] /joinflat_landlord/" + context.params.id);
                            }).catch((err) => {
                                console.error(err);
                            });
                        }
                    });
                } else {
                    // Join request to user
                    admin.firestore().collection('landlord').doc(msgData.user_id).get().then((userSnapshot) => {
                        if (userSnapshot.empty) {
                            console.error("No User [DOCUMENT] /joinflat_landlord/" + context.params.id);
                        } else {
                            tokens.push(userSnapshot.data().notificationToken);
                        }

                        if (tokens.length == 0) {
                            console.error("No Tokens [DOCUMENT] /joinflat_landlord/" + context.params.id);
                        } else {
                            var payload = {
                                "notification": {
                                    "title": "New Join Request",
                                    "body": msgData.request_from_flat == 0 ? "A landlord wants to join the flat" : "you have a join request from a flat",
                                    "sound": "default"
                                },
                                "data": {
                                    "sendername": userName,
                                    "click_action": "FLUTTER_NOTIFICATION_CLICK",
                                    "screen": "joinflat_landlord",
                                    "message": msgData.request_from_flat == 0 ? "A landlord wants to join the flat" : "you have a join request from a flat"
                                }
                            }
                            return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                                console.log("joinflat_landlord notification pushed [TYPE] onCreate [DOCUMENT] /joinflat_landlord/" + context.params.id);
                            }).catch((err) => {
                                console.error(err);
                            });
                        }
                    });
                }
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

            Object.keys(atd).forEach(function(key) {
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
            });
                    
             

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
            Object.keys(atd).forEach(function(key) {
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
            });

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
            if (msgData.toUserId == null) {  //request from coowner to ownerFlat

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

            if (msgData.request_from_tenant == true) {
                var ret5 = await getOwnerTokens(msgData.ownerIdList);
                if (ret5 != null) {
                    tokens = tokens.concat(ret5);
                } else {
                    console.error("joinflat_landlord_tenant/" + context.params.id +  " - No owners found for owner id list");
                }

                var ret2 = await getTenantTokensAndUserName(msgData.tenant_flat_id, msgData.user_id);

                if (ret2 != null) {
                    tokens = tokens.concat(ret2.tokens);
                    userName = ret2.userName;
                } else {
                    console.error("joinflat_landlord_tenant/" + context.params.id +  " - No tenants found for flatid: " + msgData.tenant_flat_id);
                }

            }
            else {  //request from owner to tenant

                var ret1 = await getOwnerTokensAndUserNameFromOwnerFlat(msgData.owner_flat_id, msgData.user_id);
                if (ret1 != null) {
                    tokens = tokens.concat(ret1.tokens);
                    userName = ret1.userName;
                }
                else {
                    console.error("joinflat_landlord_tenant/" + context.params.id +  " - No owners found for owner flat id: " + msgData.owner_flat_id);
                }


                var tokensTemp = await getTenantTokens(msgData.tenant_flat_id);
                if (tokensTemp != null) {
                    tokens = tokens.concat(tokensTemp);
                }
                else {
                    console.error("joinflat_landlord_tenant/" + context.params.id +  " - No tenants found for flatid: " + msgData.tenant_flat_id);
                }




            }

            if (tokens.length == 0) {
                console.error("No Tokens [DOCUMENT] /joinflat_landlord_tenant/" + context.params.id);
            } else {
                var body = userName != ""
                    ? userName + " has sent a tenant request"
                    : "You have a new request";
                var payload = createPayload("New join request", body, userName, "joinflat_landlord_tenant", body);

                createActivity("New join request", body, userName, context.params.id, msgData.owner_flat_id, msgData.tenant_flat_id, context.params.id, msgData.ownerIdList, msgData.buildingName, msgData.ownerFlatName);

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
                if (requestSnapshot.data().request_from_tenant == true) {  //one of the owners either accepted or rejected request
                    var ret4 = await getOwnerTokensAndUserName(requestSnapshot.data().ownerIdList, msgData.user_id);

                    if (ret4 != null) {
                        tokens = tokens.concat(ret4.tokens);
                        userName = ret4.userName;
                    }
                    else {
                        console.error("joinflat_landlord_tenant/" + context.params.id +  " - No owners found during update for owner id list");
                    }

                    var tokensTemp = await getTenantTokens(requestSnapshot.tenant_flat_id);
                    if (tokensTemp != null) {
                        tokens = tokens.concat(tokensTemp);
                    }
                    else {
                        console.error("joinflat_landlord_tenant/" + context.params.id +  " - No tenants found during update for flatid: " + requestSnapshot.tenant_flat_id);
                    }



                    if (tokens.length == 0) {
                        console.error("No Tokens [DOCUMENT] /joinflat_landlord_tenant/" + context.params.id);
                    } else {
                        var body = userName != ""
                            ? userName + " has " + statusStr + " a tenant request from" + requestSnapshot.data().created_by.name
                            : "A tenant request was updated";
                        var payload = createPayload("Update to tenant join request", body, userName, "joinflat_tenant_landlord", body);

                        createActivity("Update to tenant join request", body, userName, context.params.id, requestSnapshot.data().owner_flat_id, requestSnapshot.data().tenant_flat_id, context.params.id, requestSnapshot.data().ownerIdList, requestSnapshot.data().buildingName, requestSnapshot.data().ownerFlatName);

                        return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                            console.log("Landlord-Tenant join notification pushed [TYPE] onUpdate [DOCUMENT] /joinflat_landlord_tenant/" + context.params.id);
                        }).catch((err) => {
                            console.error(err);
                        });
                    }
                }
            }
            else {  //tenant accepted or rejected request from one of the owners
                var ret15 = await getOwnerTokensAndUserNameFromOwnerFlat(requestSnapshot.data().owner_flat_id, "");
                if (ret15 != null) {
                    tokens = tokens.concat(ret15.tokens);
                }
                else {
                    console.error("joinflat_landlord_tenant/" + context.params.id +  " - No owners found during update for owner flat id: " + requestSnapshot.owner_flat_id);
                }

                var ret = await getTenantTokensAndUserName(requestSnapshot.data().tenant_flat_id, msgData.user_id);
                if (ret != null) {
                    tokens = tokens.concat(ret.tokens);
                    userName = ret.userName;
                }
                else {
                    console.error("joinflat_landlord_tenant/" + context.params.id +  " - No tenants found during update for flatid: " + requestSnapshot.tenant_flat_id);
                }

                if (tokens.length == 0) {
                    console.error("No Tokens [DOCUMENT] /joinflat_landlord_tenant/" + context.params.id);
                } else {
                    var body = userName != ""
                        ? userName + " has " + statusStr + " an owner request from" + requestSnapshot.data().created_by.name
                        : "A tenant request was updated";
                    var payload = createPayload("Update to tenant join request", body, userName, "joinflat_landlord_tenant", body);

                    createActivity("Update to tenant join request", body, userName, context.params.id, requestSnapshot.data().owner_flat_id, requestSnapshot.data().tenant_flat_id, context.params.id, requestSnapshot.data().ownerIdList, requestSnapshot.data().buildingName, requestSnapshot.data().ownerFlatName);

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
            if (landlordSnapshot.empty) {
                return null;
            } else {


                tokens.push(landlordSnapshot.data().notificationToken);


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
        Object.keys(userList).forEach(function(key) {
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
        });
            
        return { tokens: tokens, userName: userName, owners: owners};
    }
    else {
        return null;
    }

}

function getTenantTokensAndUserName(userList, userId) {
    var tokens = [];
    var userName = "";
    if (userList != null) {
        Object.keys(userList).forEach(function(key) {
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
        });
            
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
    
    var data = {title: title, message: message, sendername: sendername, documentId: documentId, ownerFlatId: ownerFlatId, ownerFlatName: ownerFlatName, buildingName: buildingName, tenantFlatId: tenantFlatId, ownerTenantFlatId: ownerTenantFlatId, timestamp: Date.now(), userList: userList};

    admin.firestore().collection('activity').add(data);


}

exports.acceptTenantRequest = functions.https.onCall(async (data, context) => {
    var tenantRequestDoc = await admin.firestore.collection('joinflat_landlord_tenant').doc(data["requestId"]);
    if(context.auth.id in tenantRequestDoc.data()["ownerIdList"]) {
        try {
        var batch = admin.firestore.batch();
        var tenantReqDocRef = admin.firestore.collection('joinflat_landlord_tenant').doc(data["requestId"]);
        batch.update(tenantReqDocRef, {'status': 1});
        
        var tenantRequestsQs = await admin.firestore.collection('joinflat_landlord_tenant')
        .where('owner_flat_id', '==', tenantRequestDoc.data()["ownerFlatId"])
        .where('status', '==', 0)
        .where('request_from_tenant', '==', true)
        .get();
        
        tenantRequestsQs.forEach(function(doc) {
            if(doc.id != data["requestId"]) {
                var tenantReqToRej = admin.firestore.collection('joinflat_landlord_tenant').doc(doc.id);
                batch.update(tenantReqToRej, {'status': 2});
            }
        });

        var tenantReqQs1 = await admin.firestore.collection(globals.joinFlatLandlordTenant)
        .where('owner_flat_id', '==', tenantRequestDoc.data()["ownerFlatId"])
        .where('status', '==', 0)
        .where('request_from_tenant', '==', false)
        .get();

        tenantReqQs1.forEach(function(doc) {
            if(doc.id != data["requestId"]) {
                var tenantReqToRej = admin.firestore.collection('joinflat_landlord_tenant').doc(doc.id);
                batch.delete(tenantReqToRej);
            }
        });
        var notificationTokensDocRef = admin.firestore.collection('notification_tokens').doc();
        var ownerTenantDocRef = admin.firestore.collection('owner_tenant_flat').doc(notificationTokensDocRef.id);
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

        var ownerFlatDocRef = await admin.firestore.collection('ownerFlat').doc(tenantRequestDoc.data()["ownerFlatId"]).get();
        ownerFlatDocRef.data().ownerIdList.forEach(function (ownerId) {
            var landlordRef = await admin.firestore.collection('landlord').doc(ownerId).get();
            ownerTenantData['o_' + ownerId] = landlordRef.data()['name'] + '::' + landlordRef.data()['phone'];
            notificationsData['o_' + ownerId] = landlordRef.data()['name'] + '::' + landlordRef.data()['notificationToken'];
        });
        var TenantQs = await admin.firestore.collection('tenant').where('tenant_flat_id', '==', tenantRequestDoc.data()['tenantFlatId']).get();
        TenantQs.forEach(function (tenant) {
            ownerTenantData['t_' + tenant.id] = tenant.data()['name'] + '::' + tenant.data()['phone'];
            notificationsData['t_' + tenant.id] = tenant.data()['name'] + '::' + tenant.data()['notification_token'];
        });
        batch.set(ownerTenantDocRef, ownerTenantData);
        batch.set(notificationTokensDocRef, notificationsData);

        await batch.commit();

        return {'code': 0};
    } catch (e) {
        return {'code': -1};
    }

    
} else {
    return {'code': -1};
}
});

exports.acceptRequestFromOwner = functions.https.onCall(async (data, context) => {
    var ownerRequestDoc = await admin.firestore.collection('owner_owner_join').doc(data["requestId"]);
    if(context.auth.id in ownerRequestDoc.data()["ownerIdList"]) {
        try {
            var batch = admin.firestore.batch();

            var landlordDoc = await admin.firestore.collection('landlord').doc(context.auth.id).get();

            var ownerReqDocRef = admin.firestore.collection('owner_owner_join').doc(data["requestId"]);
            batch.update(ownerReqDocRef, {'status': 1});

            var ownerFlatRef = admin.firestore.collection('ownerFlat').doc(ownerRequestDoc.data()["flatId"]);
            batch.update(ownerFlatRef, {'ownerIdList': admin.firestore.FieldValue.arrayUnion(ownerRequestDoc.data()["toUserId"]), 'ownerRoleList': admin.firestore.FieldValue.arrayUnion(ownerRequestDoc.data()["toUserId"] + ':' + landlordDoc.data()["name"] + ':' + '1')});

            var mySentReqQS = await admin.firestore.collection('owner_owner_join')
            .where('status', '==', 0)
            .where('flatId', '==', ownerRequestDoc.data()["flatId"])
            .where('requesterId', '==', context.auth.id)
            .where('requestToOwner', '==', true).get();

            mySentReqQS.forEach(function(doc) {
                if(doc.id != data["requestId"]) {
                    var ownerReqRefTemp = admin.firestore.collection('owner_owner_join').doc(doc.id);
                    batch.delete(ownerReqRefTemp);
                }
            });
            
            var tenantRefQS = await admin.firestore
            .collection('joinflat_landlord_tenant')
            .where('ownerFlatId', '==', ownerRequestDoc.data()["flatId"])
            .where('status', '==', 0).get();

            tenantRefQS.forEach(function(doc) {
                var tenantDocRef = admin.firestore.collection('joinflat_landlord_tenant').doc(doc.id);
                batch.update(tenantDocRef, {'ownerIdList': admin.firestore.FieldValue.arrayUnion(ownerRequestDoc.data()["toUserId"])});
            });

            var recOwnerReqQS = await admin.firestore.collection('owner_owner_join')
            .where('status', '==', 0)
            .where('flatId', '==', ownerRequestDoc.data()["flatId"])
            .get();

            recOwnerReqQS.forEach(function(doc) {
                var recOwnerDocRef = admin.firestore.collection('owner_owner_join').doc(doc.id);
                batch.update(recOwnerDocRef, {'ownerIdList': admin.firestore.FieldValue.arrayUnion(ownerRequestDoc.data()["toUserId"])});
            });


            var ownerTenantQS = await admin.firestore.collection('owner_tenant_flat')
            .where('status', '==', 0)
            .where('ownerFlatId', '==', ownerRequestDoc.data()["flatId"]).get();

            if(ownerTenantQS != undefined && ownerTenantQS != null && !ownerTenantQS.empty) {
                ownerTenantQS.forEach(function(doc) {
                    var ownerTenantDocRef = admin.firestore.collection('owner_tenant_flat').doc(doc.id);
                    var ntfnDocRef = admin.firestore.collection('notification_tokens').doc(doc.id);
                    var key = "o_" + context.auth.id;

                    batch.update(ownerTenantDocRef, {[key]: landlordDoc.data()["name"] + landlordDoc.data()["phone"]});
                    batch.update(ntfnDocRef, {[key]: landlordDoc.data()["name"] + landlordDoc.data()["notificationToken"]});
                });
            }

            await batch.commit();
            return {'code': 0};
        }
        catch(e) {
            return {'code': -1};
        }
    }
    else {
        return {'code': -1};
    }
});


exports.acceptRequestFromCoOwner = functions.https.onCall(async (data, context) => {
    var ownerRequestDoc = await admin.firestore.collection('owner_owner_join').doc(data["requestId"]);
    if(context.auth.id in ownerRequestDoc.data()["ownerIdList"]) {
        try {
            var batch = admin.firestore.batch();

            var landlordDoc = await admin.firestore.collection('landlord').doc(ownerRequestDoc.data()["requesterId"]).get();

            var ownerReqDocRef = admin.firestore.collection('owner_owner_join').doc(data["requestId"]);
            batch.update(ownerReqDocRef, {'status': 1});

            var ownerFlatRef = admin.firestore.collection('ownerFlat').doc(ownerRequestDoc.data()["flatId"]);
            batch.update(ownerFlatRef, {'ownerIdList': admin.firestore.FieldValue.arrayUnion(ownerRequestDoc.data()["requesterId"]), 'ownerRoleList': admin.firestore.FieldValue.arrayUnion(ownerRequestDoc.data()["requesterId"] + ':' + landlordDoc.data()["name"] + ':' + '1')});

            var mySentReqQS = await admin.firestore.collection('owner_owner_join')
            .where('status', '==', 0)
            .where('flatId', '==', ownerRequestDoc.data()["flatId"])
            .where('toUserId', '==', landlordDoc.id)
            .where('requestToOwner', '==', false).get();

            mySentReqQS.forEach(function(doc) {
                if(doc.id != data["requestId"]) {
                    var ownerReqRefTemp = admin.firestore.collection('owner_owner_join').doc(doc.id);
                    batch.delete(ownerReqRefTemp);
                }
            });
            
            var tenantRefQS = await admin.firestore
            .collection('joinflat_landlord_tenant')
            .where('ownerFlatId', '==', ownerRequestDoc.data()["flatId"])
            .where('status', '==', 0).get();

            tenantRefQS.forEach(function(doc) {
                var tenantDocRef = admin.firestore.collection('joinflat_landlord_tenant').doc(doc.id);
                batch.update(tenantDocRef, {'ownerIdList': admin.firestore.FieldValue.arrayUnion(landlordDoc.id)});
            });

            var recOwnerReqQS = await admin.firestore.collection('owner_owner_join')
            .where('status', '==', 0)
            .where('flatId', '==', ownerRequestDoc.data()["flatId"])
            .get();

            recOwnerReqQS.forEach(function(doc) {
                var recOwnerDocRef = admin.firestore.collection('owner_owner_join').doc(doc.id);
                batch.update(recOwnerDocRef, {'ownerIdList': admin.firestore.FieldValue.arrayUnion(landlordDoc.id)});
            });


            var ownerTenantQS = await admin.firestore.collection('owner_tenant_flat')
            .where('status', '==', 0)
            .where('ownerFlatId', '==', ownerRequestDoc.data()["flatId"]).get();

            if(ownerTenantQS != undefined && ownerTenantQS != null && !ownerTenantQS.empty) {
                ownerTenantQS.forEach(function(doc) {
                    var ownerTenantDocRef = admin.firestore.collection('owner_tenant_flat').doc(doc.id);
                    var ntfnDocRef = admin.firestore.collection('notification_tokens').doc(doc.id);
                    var key = "o_" + landlordDoc.id;

                    batch.update(ownerTenantDocRef, {[key]: landlordDoc.data()["name"] + landlordDoc.data()["phone"]});
                    batch.update(ntfnDocRef, {[key]: landlordDoc.data()["name"] + landlordDoc.data()["notificationToken"]});
                });
            }

            await batch.commit();
            return {'code': 0};
        }
        catch(e) {
            return {'code': -1};
        }
    }
    else {
        return {'code': -1};
    }
});