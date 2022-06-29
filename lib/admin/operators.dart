

import 'package:ewm/operator/operator_home.dart';
import 'package:flutter/material.dart';

import '../my_users.dart';
import '../util.dart';


class Operators extends StatefulWidget {
  const Operators({Key? key}) : super(key: key);

  @override
  State<Operators> createState() => _OperatorsState();
}

class _OperatorsState extends State<Operators> {

  List<MyUsers> operator = List.empty(growable: true);
  bool loading = true;
  getOperators() async {
    operator = await getUsers("access", "Operator", "");
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getOperators();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(context, true, true),
      body: loading? Center(child: CircularProgressIndicator(),) : Row(
        children: [
          Expanded(
              child: Column(
                children: [
                  Text("Operators", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                  Expanded(
                    child: ListView.builder(
                        itemCount: operator.length,
                        itemBuilder: (context, index) {
                          MyUsers current = operator.elementAt(index);
                          return MaterialButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => operator_home(current)));
                              },
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
