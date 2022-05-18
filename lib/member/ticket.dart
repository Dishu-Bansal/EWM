import 'dart:io';
import 'dart:typed_data';

import 'package:ewm/my_users.dart';
import 'package:ewm/util.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class Ticket extends StatefulWidget {
  Tickets ticket;
  String uid;
  Ticket(Tickets this.ticket, String this.uid, {Key? key}) : super(key: key);

  @override
  State<Ticket> createState() => _TicketState();
}

class _TicketState extends State<Ticket> {
  Uint8List? data = null;
  bool loading = true;
  File? file = null;

  getImage() async {
    final islandRef = FirebaseStorage.instance.ref(widget.uid).child(widget.ticket.id);
    Directory dir = await getApplicationDocumentsDirectory();
    file = File(dir.path +"/"+ widget.ticket.name+ ".jpg");

    try {
      final downloadTask = islandRef.writeToFile(file!);
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
          setState(() {
            loading = false;
          });
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
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getImage();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(context),
      body: loading ? Center(child: CircularProgressIndicator(),) : Row(
        children: [
          Expanded(child: Column(
            children: [
              Text(widget.ticket.name, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height *0.3,
                child: Image.file(file!, fit: BoxFit.fill,),
              ),
              Text(DateFormat("dd/MM/yyyy").format(DateTime.fromMillisecondsSinceEpoch(widget.ticket.start)) + " - " + DateFormat("dd/MM/yyyy").format(DateTime.fromMillisecondsSinceEpoch(widget.ticket.end))),
            ],
          ))
        ],
      ),
    );
  }
}
