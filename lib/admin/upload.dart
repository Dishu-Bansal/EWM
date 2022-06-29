import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:ewm/admin/share_with.dart';
import 'package:ewm/my_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../my_users.dart';
import '../util.dart';

class Upload extends StatefulWidget {
  const Upload({Key? key}) : super(key: key);

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {

  List<MyFiles> history = List.empty(growable: true);
  bool loading = true;

  uploadFile(FilePickerResult res, List<MyUsers> selected) async {
    PlatformFile file = res.files.single;
    List<String> s = selected.map((MyUsers e) { return e.uid;}).toList();
    print("List is: " + s.toString());
    final storaferef = FirebaseStorage.instance.ref();
    try {
      DocumentReference ref = await FirebaseFirestore.instance.collection("files").add({
        'name' : res.files.first.name,
        'shared_with' : s,
        'time' : DateTime.now().millisecondsSinceEpoch,
        'shared_by' : MyAuth().uid,
        'sharer' : MyAuth().myuser.name,
        'seen' : false,
      });
      final userref = storaferef.child(MyAuth().uid);
      final fileref = userref.child(ref.id);
      await fileref.putFile(File(file.path!));
    } on FirebaseException catch (e) {
     print("Uploading Error");
    }
  }

  getHistory() async {
    await FirebaseFirestore.instance.collection("files").where("shared_by", isEqualTo: MyAuth().uid).get().then((value)
    {
      value.docs.forEach((e) {
        history.add(MyFiles(e.id, e["name"], e["shared_by"], e["shared_with"], e["time"], e["sharer"], e["seen"]));
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
    getHistory();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(context, true, true),
      body: Row(
        children: [
          Expanded(
              child: Column(
                children: [
                  Text("Upload Files", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25),),
                  GestureDetector(
                    onTap: () async {
                      FilePickerResult? res = await FilePicker.platform.pickFiles();
                      if(res != null) {
                        List<MyUsers> selected = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => share_with()));
                        await uploadFile(res, selected);
                        Navigator.pop(context);
                      }

                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DottedBorder(
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.add, color: Colors.black,),
                                Text("Select Files to Upload"),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: DefaultTabController(
                        length: 1,
                        child: Column(
                          children: [
                            TabBar(
                              indicatorColor: Colors.black,
                              tabs: [
                                Tab(child: Text("History", style: TextStyle(color: Colors.black),),),
                              ],
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height - 300,
                              child: TabBarView(
                                children: [
                                  loading? Center(child: CircularProgressIndicator(),) : ListView.builder(
                                    itemCount: history.length,
                                    itemBuilder: (context, index) {
                                      MyFiles current = history.elementAt(index);
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(fit: FlexFit.loose,child: Text(current.name, style: TextStyle(fontSize: 18),overflow: TextOverflow.fade,)),
                                            Text(DateFormat("dd/MM/yyyy").format(DateTime.fromMillisecondsSinceEpoch(current.time))),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ),
                  ),
                ],
              ),
          ),
        ],
      ),
    );
  }
}
