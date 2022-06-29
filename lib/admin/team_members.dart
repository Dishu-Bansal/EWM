
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewm/member/member_home.dart';
import 'package:ewm/my_auth.dart';
import 'package:flutter/material.dart';

import '../member/my_tickets.dart';
import '../my_users.dart';
import '../util.dart';


class Members extends StatefulWidget {
  const Members({Key? key}) : super(key: key);

  @override
  State<Members> createState() => _MembersState();
}

class _MembersState extends State<Members> {

  bool loading  = true;
  List<MyUsers> members = List.empty(growable: true);
  getMembers () async {
    members = await getUsers("access", "Member", MyAuth().myuser.name);
    setState(() {
      loading = false;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMembers();
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
                Text("Team Members", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                Expanded(
                  child: ListView.builder(
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        MyUsers current = members.elementAt(index);
                        return MaterialButton(
                          onPressed: () {Navigator.of(context).push(MaterialPageRoute(builder: (_) => member_home(current)));},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(current.name + "(" + current.manager +")"),
                              Icon(Icons.arrow_forward, color: Colors.black,)
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
