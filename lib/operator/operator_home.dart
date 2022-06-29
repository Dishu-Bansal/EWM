import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewm/admin/operators.dart';
import 'package:ewm/admin/team_members.dart';
import 'package:ewm/admin/upload.dart';
import 'package:ewm/main.dart';
import 'package:ewm/operator/documents.dart';
import 'package:ewm/util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../member/my_tickets.dart';
import '../my_auth.dart';
import '../my_users.dart';
import '../register.dart';


class operator_home extends StatefulWidget {
  MyUsers current;
  operator_home(MyUsers this.current, {Key? key}) : super(key: key);

  @override
  State<operator_home> createState() => _operator_homeState();
}

class _operator_homeState extends State<operator_home> {
  String? access=null, manager=null, company=null;
  List<String> accesstypes = ["Member", "Operator", "Admin"];
  List<MyUsers> managers = List.empty(growable: true);
  List<String> companies = List.empty(growable: true);
  bool loading = true;

  getManagers() async {
    access = widget.current.access;
    manager = widget.current.manager;
    company = widget.current.company;
    managers = await getUsers('access', 'Admin', "");
    await FirebaseFirestore.instance.collection("companies").get().then((value) =>
    {value.docs.forEach((element) {companies.add(element["name"]);})});
    managers.add(MyUsers("None", "None", "None", "None", "None", "None", "None", "None"));
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
      appBar: createAppBar(context, MyAuth().access == "Admin" ? true : false, MyAuth().access == "Admin" ? true : false),
      body: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Text("Welcome " + widget.current.name + "!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),),
                  Text("Where to now?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                  MyAuth().access == "Admin" ? ( loading ? Center(child: CircularProgressIndicator(),) :
                  Row(
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
                            manager = val!;
                            String sel = managers.firstWhere((element) {return element.uid == manager;}).name;
                            print("Selected is: " + manager! + "," + sel);
                            FirebaseFirestore.instance.collection("users").doc(widget.current.did).set(
                                {
                                  'manager' : sel,
                                }, SetOptions(merge: true));
                            setState(() {
                              manager = val;
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
                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        child: DropdownButton<String>(
                          value: company,
                          hint: Text("Select an option"),
                          onChanged: (String? val) {
                            company = val!;
                            String sel = companies.firstWhere((element) {return element == company;});
                            FirebaseFirestore.instance.collection("users").doc(widget.current.did).set(
                                {
                                  'company' : sel,
                                }, SetOptions(merge: true));
                            setState(() {
                              company = val;
                            });
                          },
                          underline: DropdownButtonHideUnderline(child: Container()),
                          items: companies.map((t) {
                            return DropdownMenuItem<String>(
                              child: Text(t, style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.5)),),
                              value: t,
                            );
                          }).toList(),
                          borderRadius: BorderRadius.circular(15),
                          isExpanded: true,
                        ),
                      )
                    ],
                  )) : SizedBox(),
                  createButton(Icons.groups, "Team Members", () {Navigator.of(context).push(MaterialPageRoute(builder: (_) => Members()));}, MediaQuery.of(context).size.height),
                  createButton(Icons.photo_library, "My Tickets", () {Navigator.of(context).push(MaterialPageRoute(builder: (_) => MyTickets(widget.current)));}, MediaQuery.of(context).size.height),
                  createButton(Icons.filter_none, "Documents", () {Navigator.of(context).push(MaterialPageRoute(builder: (_) => MyDocuments(widget.current)));}, MediaQuery.of(context).size.height),
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
