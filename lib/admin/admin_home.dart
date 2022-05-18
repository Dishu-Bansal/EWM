import 'package:ewm/admin/operators.dart';
import 'package:ewm/admin/team_members.dart';
import 'package:ewm/admin/upload.dart';
import 'package:ewm/main.dart';
import 'package:ewm/util.dart';
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
      appBar: createAppBar(context),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text("Welcome Dishu!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),),
                Text("Where to now?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                createButton(Icons.refresh, "Operatos", () {Navigator.of(context).push(MaterialPageRoute(builder: (_) => Operators()));}, height),
                createButton(Icons.refresh, "Team Members", () {Navigator.of(context).push(MaterialPageRoute(builder: (_) => Members()));}, height),
                createButton(Icons.refresh, "Files", () {Navigator.of(context).push(MaterialPageRoute(builder: (_) => Upload()));}, height),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
