import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewm/admin/operators.dart';
import 'package:ewm/admin/team_members.dart';
import 'package:ewm/admin/upload.dart';
import 'package:ewm/main.dart';
import 'package:ewm/member/my_tickets.dart';
import 'package:ewm/my_auth.dart';
import 'package:ewm/my_users.dart';
import 'package:ewm/operator/documents.dart';
import 'package:ewm/util.dart';
import 'package:flutter/material.dart';


class member_home extends StatefulWidget {
  MyUsers current;
  member_home(MyUsers this.current, {Key? key}) : super(key: key);

  @override
  State<member_home> createState() => _member_homeState();
}

class _member_homeState extends State<member_home> {
  String? access=null, manager=null;
  List<String> accesstypes = ["Member", "Operator", "Admin"];
  List<MyUsers> managers = List.empty(growable: true);
  bool loading = true;
  double height=0;

  getManagers() async {
    height = MediaQuery.of(context).size.height;
    access = widget.current.access;
    manager = widget.current.manager;
    managers = await getUsers('access', 'Operator');
    managers.add(MyUsers("None", "None", "None", "None", "Member", "None", "None"));
    print("Managers: " + managers.toString());
    //managers.add("None");
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getManagers();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(context),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text("Welcome " + widget.current.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),),
                Text("Where to now?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                MyAuth().access == "Admin" ? ( loading ? Center(child: CircularProgressIndicator(),) : Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: DropdownButton<String>(
                        value: access,
                        hint: Text("Select an option"),
                        onChanged: (String? val) {
                          access = val.toString();
                          print("Change is: " + widget.current.did + "," + access!);
                          FirebaseFirestore.instance.collection("users").doc(widget.current.did).set(
                              {
                               'access' : access,
                              }, SetOptions(merge: true));
                          setState(() {
                            access = val.toString();
                          });
                        },
                        underline: DropdownButtonHideUnderline(child: Container()),
                        items: accesstypes.map((t) {
                          return DropdownMenuItem<String>(
                            child: Text(t, style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.5)),),
                            value: t,
                          );
                        }).toList(),
                        borderRadius: BorderRadius.circular(15),
                        isExpanded: true,
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: DropdownButton<String>(
                        value: manager,
                        hint: Text("Select an option"),
                        onChanged: (String? val) {
                          manager =val;
                          FirebaseFirestore.instance.collection("users").doc(widget.current.did).set(
                              {
                                'manager' : managers.firstWhere((element)
                                {return element.uid == manager;}).name,
                              }, SetOptions(merge: true));
                          setState(() {
                            manager =val;
                          });
                        },
                        underline: DropdownButtonHideUnderline(child: Container()),
                        items: managers.map((t) {
                          return DropdownMenuItem<String>(
                            child: Text(t.name, style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.5)),),
                            value: t.name,
                          );
                        }).toList(),
                        borderRadius: BorderRadius.circular(15),
                        isExpanded: true,
                      ),
                    )
                  ],
                )) : SizedBox(),
                createButton(Icons.refresh, "My Tickets", () {Navigator.of(context).push(MaterialPageRoute(builder: (_) => MyTickets(widget.current)));}, height),
                createButton(Icons.refresh, "My Documents", () {Navigator.of(context).push(MaterialPageRoute(builder: (_) => MyDocuments(widget.current)));}, height),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
