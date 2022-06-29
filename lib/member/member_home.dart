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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';


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
    access = widget.current.access;
    manager = widget.current.manager;
    managers = await getUsers('access', 'Operator', "");
    managers.add(MyUsers("None", "None", "None", "None", "Member", "None", "None", "None"));
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
      appBar: createAppBar(context, (MyAuth().access == "Admin" || MyAuth().access == "Operator") ? true : false, (MyAuth().access == "Admin" || MyAuth().access == "Operator") ? true : false),
      body: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
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
                        child: dropdown1(access, accesstypes, widget.current),
                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        child: dropdown2(manager, managers, widget.current),
                      )
                    ],
                  )) : SizedBox(),
                  createButton(Icons.photo_library, "My Tickets", () {Navigator.of(context).push(MaterialPageRoute(builder: (_) => MyTickets(widget.current)));}, MediaQuery.of(context).size.height),
                  createButton(Icons.filter_none, "My Documents", () {Navigator.of(context).push(MaterialPageRoute(builder: (_) => MyDocuments(widget.current)));}, MediaQuery.of(context).size.height),
                  createButton(Icons.logout, "Logout", () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MyHomePage()));
                  }, MediaQuery.of(context).size.height),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class dropdown1 extends StatefulWidget {
  String? access=null;
  List<String> accesstypes = ["Member", "Operator", "Admin"];
  MyUsers current;

  dropdown1(String? this.access, List<String> this.accesstypes, MyUsers this.current, {Key? key}) : super(key: key);

  @override
  State<dropdown1> createState() => _dropdown1State();
}

class _dropdown1State extends State<dropdown1> {

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: widget.access,
      hint: Text("Select an option"),
      onChanged: (String? val) {
        widget.access = val.toString();
        print("Change is: " + widget.current.did + "," + widget.access!);
        FirebaseFirestore.instance.collection("users").doc(widget.current.did).set(
            {
              'access' : widget.access,
            }, SetOptions(merge: true));
        setState(() {
          widget.access = val.toString();
        });
      },
      underline: DropdownButtonHideUnderline(child: Container()),
      items: widget.accesstypes.map((t) {
        return DropdownMenuItem<String>(
          child: Text(t, style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.5)),),
          value: t,
        );
      }).toList(),
      borderRadius: BorderRadius.circular(15),
      isExpanded: true,
    );
  }
}

class dropdown2 extends StatefulWidget {
  List<MyUsers> managers = List.empty(growable: true);
  String? manager=null;
  MyUsers current;
  dropdown2(String? this.manager, List<MyUsers> this.managers, MyUsers this.current, {Key? key}) : super(key: key);

  @override
  State<dropdown2> createState() => _dropdown2State();
}

class _dropdown2State extends State<dropdown2> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: widget.manager,
      hint: Text("Select an option"),
      onChanged: (String? val) {
        widget.manager =val;
        FirebaseFirestore.instance.collection("users").doc(widget.current.did).set(
            {
              'manager' : widget.managers.firstWhere((element)
              {return element.uid == widget.manager;}).name,
            }, SetOptions(merge: true));
        setState(() {
          widget.manager =val;
        });
      },
      underline: DropdownButtonHideUnderline(child: Container()),
      items: widget.managers.map((t) {
        return DropdownMenuItem<String>(
          child: Text(t.name, style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.5)),),
          value: t.name,
        );
      }).toList(),
      borderRadius: BorderRadius.circular(15),
      isExpanded: true,
    );
  }
}


