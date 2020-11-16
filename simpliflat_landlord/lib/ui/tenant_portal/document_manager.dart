import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/dao/upload_document_dao.dart';
import 'package:simpliflat_landlord/model/upload_document.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/utility/utility.dart';
import 'package:simpliflat_landlord/common_widgets/common.dart';
import 'package:simpliflat_landlord/common_widgets/loading_container.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;

class DocumentManager extends StatefulWidget {
  final _flatId;

  DocumentManager(this._flatId);

  @override
  State<StatefulWidget> createState() {
    return _DocumentManager(_flatId);
  }
}

class _DocumentManager extends State<DocumentManager> {
  final _flatId;
  String _userId, _userName;
  BuildContext _navigatorContext;
  
  FileType _pickingType = FileType.ANY;

  _DocumentManager(this._flatId);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context, listen: false);
    _userId = user.getUserId();
    _userName = user.getName();
    return Scaffold(
      appBar: AppBar(
          title: Text('Document Manager', style: CommonWidgets.getAppBarTitleStyle(),),
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          _openFileExplorer();
        },
        tooltip: 'New Document',
        backgroundColor: Colors.red[900],
        child: new Icon(Icons.add),
      ),
      body: Builder(
        builder: (BuildContext scaffoldC) {
          _navigatorContext = scaffoldC;
          return Column(
            children: <Widget>[
              Expanded(
                child: getLists(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget getLists() {
    return StreamBuilder<QuerySnapshot>(
      stream: UploadDocumentDao.getAllDocuments(_flatId),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return LoadingContainerVertical(3);
        if (snapshot.data.documents.length == 0)
          return Container(
            child: CommonWidgets.textBox("", 22),
          );

        List<UploadDocument> uploadDocuments =  snapshot.data.documents.map((DocumentSnapshot doc) => UploadDocument.fromJson(doc.data, doc.documentID)).toList();
        
        uploadDocuments.sort((UploadDocument a, UploadDocument b) => b.getCreatedAt().compareTo(a.getCreatedAt()));

        return ListView.builder(
            itemCount: uploadDocuments.length,
            itemBuilder: (BuildContext context, int position) {
              return _buildListItem(
                  uploadDocuments[position], position);
            });
      },
    );
  }

  Widget _buildListItem(UploadDocument doc, index) {
    DateTime datetime = doc.getCreatedAt().toDate();
    Map<int, String> numToMonth = {
      1: 'Jan',
      2: 'Feb',
      3: 'Mar',
      4: 'Apr',
      5: 'May',
      6: 'Jun',
      7: 'Jul',
      8: 'Aug',
      9: 'Sep',
      10: 'Oct',
      11: 'Nov',
      12: 'Dec'
    };
    final f = new DateFormat.jm();
    String datetimeString = datetime.day.toString() +
        " " +
        numToMonth[datetime.month.toInt()] +
        " " +
        datetime.year.toString() +
        " - " +
        f.format(datetime);

    String userName =
        doc.getCreatedByUserName()== null ? "" : doc.getCreatedByUserName().trim();

    int color = doc.getCreatedByUserId().trim().hashCode;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0, left: 8.0),
      child: SizedBox(
        width: MediaQuery.of(_navigatorContext).size.width * 0.85,
        child: Card(
          color: Colors.white,
          elevation: 1.0,
          child: Slidable(
            key: new Key(index.toString()),
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            dismissal: SlidableDismissal(
              child: SlidableDrawerDismissal(),
              closeOnCanceled: true,
              dismissThresholds: <SlideActionType, double>{
                SlideActionType.primary: 1.0
              },
              onWillDismiss: (actionType) {
                return showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return new AlertDialog(
                      title: new Text('Delete'),
                      content: new Text(
                          'Are you sure you want to delete this document?'),
                      actions: <Widget>[
                        new FlatButton(
                          child: new Text('Cancel'),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        new FlatButton(
                          child: new Text('Ok'),
                          onPressed: () => Navigator.of(context).pop(true),
                        ),
                      ],
                    );
                  },
                );
              },
              onDismissed: (actionType) {
                _deleteList(_navigatorContext, doc.getDocumentId());
              },
            ),
            secondaryActions: <Widget>[
              new IconSlideAction(
                caption: 'Delete',
                color: Colors.red,
                icon: Icons.delete,
                onTap: () async {
                  SlidableState state = Slidable.of(context);
                  bool dismiss = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return new AlertDialog(
                        title: new Text('Delete'),
                        content: new Text(
                            'Are you sure you want to delete this document?'),
                        actions: <Widget>[
                          new FlatButton(
                            child: new Text('Cancel'),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          new FlatButton(
                            child: new Text('Ok'),
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ],
                      );
                    },
                  );

                  if (dismiss) {
                    _deleteList(_navigatorContext, doc.getDocumentId());
                    if(state != null)
                      state.dismiss();
                  }
                },
              ),
            ],
            child: ListTile(
              title: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    child: Text(userName,
                        style: TextStyle(
                          fontSize: 12.0,
                          fontFamily: 'Montserrat',
                          color:
                              Colors.primaries[color % Colors.primaries.length],
                        )),
                    padding: EdgeInsets.only(bottom: 5.0),
                  ),
                  Text(doc.getFileName().replaceAll("_" + doc.getFileName().split("_").last, "").trim(),
                      style: TextStyle(
                        fontSize: 12.0,
                        fontFamily: 'Montserrat',
                        color: Colors.black,
                      )),
                ],
              ),
              subtitle: Padding(
                child: Text(datetimeString,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 11.0,
                      fontFamily: 'Montserrat',
                      color: Colors.black45,
                    )),
                padding: EdgeInsets.only(top: 6.0),
              ),
              trailing: InkWell(
                child: Icon(Icons.file_download),
                onTap: () {
                  downloadFile(doc.getFileUrl(), doc.getFileName());
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  _deleteList(scaffoldContext, documentId) async {
    DocumentSnapshot freshDoc = await UploadDocumentDao.getDocument(_flatId, documentId);
      if (freshDoc == null) {
        Utility.createErrorSnackBar(_navigatorContext);
      } else {
        UploadDocument doc = UploadDocument.fromJson(freshDoc.data, freshDoc.documentID);
        String _fileName = doc.getFileName();
        debugPrint(_fileName);
        StorageReference storageReference = FirebaseStorage.instance
            .ref()
            .child("TenantDocuments/" + _fileName);
        storageReference.delete().then((deleted) async {
          bool ifSuccess = await UploadDocumentDao.delete(_flatId, doc.getDocumentId());
          
          if (mounted) {
            if(ifSuccess)
              Utility.createErrorSnackBar(context, error: "Document Deleted");
            else
              Utility.createErrorSnackBar(_navigatorContext);
          }
        }, onError: (e){
          if (mounted) Utility.createErrorSnackBar(_navigatorContext);
        });
      }
  }

  void _openFileExplorer() async {
    File file;
    String _fileName;
    int fileLength;

    try {
      file = await FilePicker.getFile(type: _pickingType);
      _fileName = file.path?.split("/")?.last;
      Random rng = new Random();
      if (_fileName == null || _fileName == "") {
        _fileName = _userName +
            DateTime.now()
                .toLocal()
                .toString()
                .replaceAll(":", "")
                .replaceAll(" ", "")
                .replaceAll(".", "")
                .replaceAll("-", "") +
            rng.nextInt(100).toString();
      } else {
        if (_fileName.contains(".")) {
          _fileName = _fileName +
              "_" +
              DateTime.now()
                  .toLocal()
                  .toString()
                  .replaceAll(":", "")
                  .replaceAll(" ", "")
                  .replaceAll(".", "")
                  .replaceAll("-", "") +
              rng.nextInt(100).toString();
        } else {
          _fileName = _fileName +
              "_" +
              DateTime.now()
                  .toLocal()
                  .toString()
                  .replaceAll(":", "")
                  .replaceAll(" ", "")
                  .replaceAll(".", "")
                  .replaceAll("-", "") +
              rng.nextInt(100).toString();
        }
      }
      debugPrint(_fileName + " is uploading");
      debugPrint("File size is " + file.lengthSync().toString());
      fileLength = file.lengthSync();
      await uploadFile(file, _fileName, fileLength);
    } catch (e) {
      print("Unsupported operation" + e.toString());
    }
  }

  uploadFile(file, _fileName, fileLength) async {
    String fileUrl;
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child("TenantDocuments/" + _fileName);
    StorageUploadTask uploadTask = storageReference.putFile(file);
    if (mounted)
      Utility.createErrorSnackBar(_navigatorContext, error: "Uploading...");
    await uploadTask.onComplete;

    storageReference.getDownloadURL().then((fileURL) {
      if (fileURL != null || fileURL != "") {
        if (mounted) {
          Utility.createErrorSnackBar(_navigatorContext,
              error: "Upload Complete");
          fileUrl = fileURL;
        }
        addDocument(_fileName, fileUrl, fileLength);
      }
    });
  }

  downloadFile(fileUrl, name) async {
    String _localPath =
        (await _findLocalPath()) + Platform.pathSeparator + 'Download';
    debugPrint(_localPath + " - Saved");
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }

    final taskId = await FlutterDownloader.enqueue(
      url: fileUrl,
      savedDir: _localPath,
      fileName: name.toString().replaceAll("_" + name.split("_").last, "").trim(),
      showNotification: true,
      openFileFromNotification: true,
    );
  }

  Future<String> _findLocalPath() async {
    final directory =
        Theme.of(_navigatorContext).platform == TargetPlatform.android
            ? await getExternalStorageDirectory()
            : await getApplicationDocumentsDirectory();
    return directory.path;
  }

  addDocument(_fileName, fileUrl, fileLength) {
    UploadDocument data = new UploadDocument();
    data.setFileName(_fileName);
    data.setFileUrl(fileUrl);
    data.setFileSize(fileLength);
    data.setCreatedByTenant(0);
    data.setCreatedByUserId(_userId);
    data.setCreatedByUserName(_userName);
    
    DocumentReference addNoteRef = UploadDocumentDao.getDocumentReference(_flatId, null);
    addNoteRef.setData(data.toJson()).then((v) {}, onError: (e) {});
  }
}
