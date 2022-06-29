import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewm/my_users.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../util.dart';

class MyDocuments extends StatefulWidget {
  MyUsers current;
  MyDocuments(MyUsers this.current, {Key? key}) : super(key: key);

  @override
  State<MyDocuments> createState() => _MyDocumentsState();
}

class _MyDocumentsState extends State<MyDocuments> {

  List<MyFiles> files = List.empty(growable: true);
  bool loading = true;

  getDocs() async {
    String id = widget.current.uid;
    await FirebaseFirestore.instance.collection("files").where('shared_with', arrayContainsAny: [id]).get().then((value)
    {
      value.docs.forEach((e) {
        files.add(MyFiles(e.id, e["name"], e["shared_by"], e["shared_with"], e["time"], e["sharer"], e["seen"]));
      });
    });
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDocs();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(context, true, true),
      body: loading ? Center(child: CircularProgressIndicator(),) : Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text("Documents", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                Expanded(
                  child: ListView.builder(
                      itemCount: files.length,
                      itemBuilder: (context, index) {
                        MyFiles current = files.elementAt(index);
                        return MaterialButton(
                          onPressed: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(fit: FlexFit.loose,child: Text(current.name, overflow: TextOverflow.fade, style: TextStyle(fontWeight: current.seen ? FontWeight.normal : FontWeight.bold),)),
                              Flexible(fit: FlexFit.loose,child: Text(current.sharer, overflow: TextOverflow.fade, style: TextStyle(fontWeight: current.seen ? FontWeight.normal : FontWeight.bold),)),
                              Flexible(fit: FlexFit.loose,child: Text(DateFormat("dd/MM/yyyy").format(DateTime.fromMillisecondsSinceEpoch(current.time)), overflow: TextOverflow.fade,)),
                              IconButton(
                                  onPressed: () async {
                                    final islandRef = FirebaseStorage.instance.ref(current.shared_by).child(current.id);
                                    Directory? dir = Platform.isAndroid
                                        ? await getExternalStorageDirectory() //FOR ANDROID
                                        : await getApplicationSupportDirectory(); //FOR iOS
                                    File file = File(dir!.path +"/"+ current.name);

                                    try {
                                      showToast("Downloading file..");
                                      final downloadTask = islandRef.writeToFile(file);
                                      downloadTask.snapshotEvents.listen((taskSnapshot) {
                                        switch (taskSnapshot.state) {
                                          case TaskState.running:
                                          // TODO: Handle this case.
                                            break;
                                          case TaskState.paused:
                                          // TODO: Handle this case.
                                            break;
                                          case TaskState.success:
                                          // TODO: Handle this case.
                                          FirebaseFirestore.instance.collection("files").doc(current.id).set(
                                              {
                                                'seen' : true,
                                              }, SetOptions(merge: true));
                                            Share.shareFiles([file.path]);
                                            break;
                                          case TaskState.canceled:
                                          // TODO: Handle this case.
                                            break;
                                          case TaskState.error:
                                          // TODO: Handle this case.
                                            break;
                                        }
                                      });
                                    } on FirebaseException catch (e) {
                                      // Handle any errors.
                                    }
                                  },
                                  icon: Icon(Icons.share, color: Colors.black,)
                              ),
                              IconButton(
                                  onPressed: () async {
                                    final islandRef = FirebaseStorage.instance.ref(current.shared_by).child(current.id);
                                    Directory? dir = Platform.isAndroid
                                        ? await getExternalStorageDirectory() //FOR ANDROID
                                        : await getApplicationSupportDirectory(); //FOR iOS
                                    File file = File(dir!.path +"/"+ current.name);

                                    try {
                                      showToast("Starting Download...");
                                      final downloadTask = islandRef.writeToFile(file);
                                      downloadTask.snapshotEvents.listen((taskSnapshot) {
                                        switch (taskSnapshot.state) {
                                          case TaskState.running:
                                          // TODO: Handle this case.
                                            break;
                                          case TaskState.paused:
                                          // TODO: Handle this case.
                                            break;
                                          case TaskState.success:
                                          // TODO: Handle this case.
                                            showToast("Download Complete!");
                                            FirebaseFirestore.instance.collection("files").doc(current.id).set(
                                                {
                                                  'seen' : true,
                                                }, SetOptions(merge: true));
                                            break;
                                          case TaskState.canceled:
                                          // TODO: Handle this case.
                                            break;
                                          case TaskState.error:
                                          // TODO: Handle this case.
                                            break;
                                        }
                                      });
                                    } on FirebaseException catch (e) {
                                      // Handle any errors.
                                    }
                                  },
                                  icon: Icon(Icons.download_rounded, color: Colors.black,)
                              ),
                            ],
                          ),
                        );
                      }),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
