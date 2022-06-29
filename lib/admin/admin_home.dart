import 'package:ewm/admin/operators.dart';
import 'package:ewm/admin/team_members.dart';
import 'package:ewm/admin/upload.dart';
import 'package:ewm/main.dart';
import 'package:ewm/my_auth.dart';
import 'package:ewm/util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class admin_home extends StatefulWidget {
  const admin_home({Key? key}) : super(key: key);

  @override
  State<admin_home> createState() => _admin_homeState();
}

class _admin_homeState extends State<admin_home> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: createAppBar(context, false, false),
      body: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Text("Welcome " + MyAuth().myuser.name + "!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),),
                  Text("Where to now?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                  createButton(Icons.supervisor_account, "Operators", () {Navigator.of(context).push(MaterialPageRoute(builder: (_) => Operators()));}, height),
                  createButton(Icons.groups, "Team Members", () {Navigator.of(context).push(MaterialPageRoute(builder: (_) => Members()));}, height),
                  createButton(Icons.cloud_upload, "Files", () {Navigator.of(context).push(MaterialPageRoute(builder: (_) => Upload()));}, height),
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
