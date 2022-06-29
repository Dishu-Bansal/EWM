import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewm/member/member_home.dart';
import 'package:ewm/util.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';

import 'my_auth.dart';
import 'my_users.dart';

class TicketDetails extends StatefulWidget {
  XFile image;
  Tickets? current;
  MyUsers currentuser;
  TicketDetails(XFile this.image, Tickets? this.current, MyUsers this.currentuser, {Key? key}) : super(key: key);

  @override
  State<TicketDetails> createState() => _TicketDetailsState();
}

class _TicketDetailsState extends State<TicketDetails> {

  String name=""; String? type = null;
  List<String> tickettypes = ["Bear Awareness",
    "Coiled Tubing Well Servicing Blowout Prevention",
    "Common Safety Orientation (CSO)",
    "Detection and Control of Flammable Substances",
    "Emergency First Aid - Level A CPR",
    "Fall Protection for Rig Work",
    "Fall Rescue for Rig Work",
    "H2S Alive",
    "Hazard Management",
    "Incident and Accident Investigation",
    "Safety Management and Regulatory Awareness for Wellsite Supervision (SARA)",
      "Second Line Supervisor's Well Control (Test Well)",
    "Second Line Supervisor's Well Control Refresher",
    "Standard First Aid - Level A CPR",
    "Supervisor Leadership for Health and Safety in the Workplace",
    "Transportation of Dangerous Goods",
    "Well Service Blowout Prevention",
    "Wildlife Awareness",
    "Workplace Hazardous Materials Information System (WHMIS)", "Other"];
  int start=0, end=0;

  TextEditingController _controller1 = TextEditingController();
  TextEditingController _controller2 = TextEditingController();
  TextEditingController _controller3 = TextEditingController();
  TextEditingController _controller4 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if(widget.current != null)
      {
        if(tickettypes.contains(widget.current!.name))
          {
            type = widget.current!.name;
          }
        else
          {
            type = "Other";
            name = widget.current!.name;
          }
      }
    return Scaffold(
      appBar: createAppBar(context, true, true, ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height *0.3,
            child: Image.file(File(widget.image.path), fit: BoxFit.fill,),
          ),
          DropdownButton<String>(
            value: type,
            hint: Text("Select an option"),
            onChanged: (String? val) {
              type=val.toString();
              setState(() {
                type = val.toString();
              });
            },
            underline: DropdownButtonHideUnderline(child: Container()),
            items: tickettypes.map((t) {
              return DropdownMenuItem<String>(
                child: Text(t, style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.5)),),
                value: t,
              );
            }).toList(),
            borderRadius: BorderRadius.circular(15),
            isExpanded: true,
          ),
          type != "Other" ? SizedBox() : TextField(
            decoration: InputDecoration(
                hintText: "Enter Name"
            ),
            onChanged: (val) {
              name = val;
            },
          ),
          TextField(
            decoration: InputDecoration(
                hintText: "Issue Date"
            ),
            controller: _controller1,
            onTap: () {
              DatePicker.showDatePicker(context,
                  showTitleActions: true,
                  onConfirm: (date) {
                    start = date.millisecondsSinceEpoch;
                    _controller1.text = DateFormat("yyyy/MM/dd").format(date);
                  });
            },
          ),
          TextField(
            decoration: InputDecoration(
                hintText: "Expiry Date",
                helperText: "If there is no expiry, leave blank"
            ),
            controller: _controller2,
            onTap: () {
              DatePicker.showDatePicker(context,
                  showTitleActions: true,
                  onConfirm: (date) {
                    end = date.millisecondsSinceEpoch;
                    _controller2.text = DateFormat("yyyy/MM/dd").format(date);
                  });
            },
          ),
          MaterialButton(
              onPressed: () async {
                {
                final storaferef = FirebaseStorage.instance.ref();
                if(widget.current == null)
                  {
                    try {
                      DocumentReference ref = await FirebaseFirestore.instance
                          .collection("tickets")
                          .add({
                        'name': type == "Other" ? name : type,
                        'issue': start,
                        'expiry': end,
                        'owner': widget.currentuser.uid,
                      });
                      final userref = storaferef.child(MyAuth().uid);
                      final fileref = userref.child(ref.id);
                      await fileref.putFile(File(widget.image.path));
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => member_home(widget.currentuser)));
                    } on FirebaseException catch (e) {
                      print("Uploading Error");
                      showToast(e.message ?? "Unknown Error");
                    }
                  }
                else
                  {
                    try {
                      await FirebaseFirestore.instance
                          .collection("tickets")
                          .doc(widget.current!.id).set({
                        'name': type == "Other" ? name : type,
                        'issue': start,
                        'expiry': end,
                        'owner': widget.currentuser.uid,
                      });
                      final userref = storaferef.child(MyAuth().uid);
                      final fileref = userref.child(widget.current!.id);
                      await fileref.putFile(File(widget.image.path));
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => member_home(widget.currentuser)));
                    } on FirebaseException catch (e) {
                      print("Uploading Error");
                      showToast(e.message ?? "Unknown Error");
                    }
                  }
              }
            },
            child: Text("Save", style: TextStyle(color: Colors.white),),
            color: primaryColor,
          )
        ],
      ),
    );
  }
}
