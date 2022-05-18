import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewm/my_users.dart';
import 'package:ewm/ticket_details.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:ui';
import 'dart:core';

import 'my_auth.dart';

List<CameraDescription> cameras = List.empty(growable: true);

class picture extends StatefulWidget {
  Tickets? current;
  picture(Tickets? this.current, {Key? key}) : super(key: key);

  @override
  _pictureState createState()
  {
    WidgetsFlutterBinding.ensureInitialized();
    return _pictureState();
  }
}

class _pictureState extends State<picture> {

  TextEditingController _controller1 = TextEditingController();
  TextEditingController _controller2 = TextEditingController();

  late CameraController _controller;
  bool initialized = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _initializeCamera();
  }

  _initializeCamera() async {
    await availableCameras().then((value) {
      cameras = value;
      print("Camera Values are: " + value.toString());
    });

    _controller = CameraController(cameras[0], ResolutionPreset.max);
    _controller.initialize().then((value) {
      setState(() {
        initialized = true;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return initialized ? Scaffold(
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: CameraPreview(_controller),),
        ],
      ),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Take Picture", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),),
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () async {
          try {
            // Ensure that the camera is initialized.

            // Attempt to take a picture and then get the location
            // where the image file is saved.
            final image = await _controller.takePicture();
            // String name = "";int start=0, end=0;
            // await showDialog(
            //   context: context,
            //   builder: (context) {
            //     return AlertDialog(
            //       title: Text("Add Name"),
            //       content: Column(
            //         mainAxisSize: MainAxisSize.min,
            //         children: [
            //           TextField(
            //             decoration: InputDecoration(
            //                 hintText: "Enter Name"
            //             ),
            //             onChanged: (val) {
            //               name = val;
            //             },
            //           ),
            //           TextField(
            //             decoration: InputDecoration(
            //                 hintText: "Issue Date"
            //             ),
            //             controller: _controller1,
            //             onChanged: (val) {
            //               DatePicker.showDateTimePicker(context,
            //                   showTitleActions: true,
            //                   minTime: DateTime.now(),
            //                   onConfirm: (date) {
            //                     start = date!.millisecondsSinceEpoch;
            //                     _controller1.text = DateFormat("yyyy/MM/dd").format(date);
            //                   });
            //             },
            //           ),
            //           TextField(
            //             decoration: InputDecoration(
            //                 hintText: "Expiry Date"
            //             ),
            //             controller: _controller2,
            //             onChanged: (val) {
            //               DatePicker.showDateTimePicker(context,
            //                   showTitleActions: true,
            //                   minTime: DateTime.now(),
            //                   onConfirm: (date) {
            //                     end = date!.millisecondsSinceEpoch;
            //                     _controller2.text = DateFormat("yyyy/MM/dd").format(date);
            //                   });
            //             },
            //           ),
            //         ],
            //       ),
            //       actions: [
            //         MaterialButton(
            //           onPressed: () async {
            //               final storaferef = FirebaseStorage.instance.ref();
            //               try {
            //                 DocumentReference ref = await FirebaseFirestore.instance.collection("tickets").add({
            //                   'name' : name,
            //                   'issue' : start,
            //                   'expiry' : end,
            //                   'owner' : MyAuth().uid,
            //                 });
            //                 final userref = storaferef.child(MyAuth().uid);
            //                 final fileref = userref.child(ref.id);
            //                 await fileref.putFile(File(image.path!));
            //               } on FirebaseException catch (e) {
            //                 print("Uploading Error");
            //               }
            //               Navigator.pop(context);
            //           },
            //           child: Text("Save"),
            //         )
            //       ],
            //     );
            //   },
            // );
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => TicketDetails(image, widget.current)));
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        backgroundColor: Color.fromRGBO(46, 49, 146, 1),
        shape: CircleBorder(side: BorderSide(color: Colors.white, width: 3)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    ) : Scaffold(body: Center(child: CircularProgressIndicator(),),);
  }
}
