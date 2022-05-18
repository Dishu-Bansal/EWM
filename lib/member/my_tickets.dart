import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewm/member/ticket.dart';
import 'package:ewm/my_users.dart';
import 'package:ewm/picture.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../util.dart';


class MyTickets extends StatefulWidget {
  MyUsers current;
  MyTickets(MyUsers this.current, {Key? key}) : super(key: key);

  @override
  State<MyTickets> createState() => _MyTicketsState();
}

class _MyTicketsState extends State<MyTickets> {

  List<Tickets> tickets = List.empty(growable: true);
  bool loading=true;

  getTickets() async {
    String id = widget.current.uid;
    await FirebaseFirestore.instance.collection("tickets").where('owner', isEqualTo: id).get().then((value)
    {
      tickets.clear();
      value.docs.forEach((e) {
        tickets.add(Tickets(e.id, e["name"], e["owner"], e["issue"], e["expiry"]));
      });
    });
    tickets.sort((t1, t2) {
      return t1.end - t2.end;
    });
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTickets();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(context),
      body: loading ? Center(child: CircularProgressIndicator(),) : Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text("Tickets", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                Row(
                  children: [
                    Expanded(child: Center(child: Text("Tickets"),),),
                    Expanded(child: Center(child: Text("Expiration"),),),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: tickets.length,
                      itemBuilder: (context, index) {
                        Tickets current = tickets.elementAt(index);
                        return MaterialButton(
                          onPressed: () {Navigator.of(context).push(MaterialPageRoute(builder: (_) => Ticket(current, widget.current.uid)));},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Center(child: Text(current.name))),
                              Expanded(child: Center(child: Text(DateFormat("dd/MM/yyyy").format(DateTime.fromMillisecondsSinceEpoch(current.end)), style: TextStyle(color: current.end <  DateTime.now().millisecondsSinceEpoch ? Colors.red : (DateTime.now().millisecondsSinceEpoch + Duration(days: 60).inMilliseconds > current.end ? Colors.yellow : Colors.black)),))),
                              IconButton(onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => picture(current)));
                              }, icon: Icon(Icons.restore_sharp, color: Colors.black,))
                            ],
                          ),
                        );
                      }),
                ),
                Row(
                  children: [
                    Expanded(
                      child: MaterialButton(
                        onPressed: (){
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => picture(null)));
                          setState(() {
                            getTickets();
                          });
                        },
                        child: Text("Upload a new Ticket", style: TextStyle(color: Colors.white),),
                        color: primaryColor,
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

