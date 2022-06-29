import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewm/admin/admin_home.dart';
import 'package:ewm/main.dart';
import 'package:ewm/member/member_home.dart';
import 'package:ewm/my_auth.dart';
import 'package:ewm/my_users.dart';
import 'package:ewm/operator/operator_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


showToast(String msg) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.black,
      fontSize: 16.0
  );
}

createAppBar(BuildContext context, bool showBack, bool showHome) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;
  return AppBar(
    leading: Container(
      width: width * 0.1,
      height: height *0.1,
      child: Image.asset("lib/images/aim.png", fit: BoxFit.fill,),
    ),
    actions: [
      Container(
        width: width * 0.1,
        height: height * 0.1,
        child: Image.asset("lib/images/ewm.jpg"),
      )
    ],
    elevation: 0,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        !showBack ? SizedBox() : IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 40,),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        !showHome ? SizedBox() : IconButton(
          icon: Icon(Icons.home, color: Colors.black, size: 40,),
          onPressed: () async {
            // await MyAuth().signOut();
            if(MyAuth().access == "Admin")
              {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => admin_home()));
              }
            else if(MyAuth().access == "Operator")
              {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => operator_home(MyAuth().myuser)));
              }
            else
              {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => member_home(MyAuth().myuser)));
              }
          },
        ),
      ],
    ),
    centerTitle: true,
    foregroundColor: Colors.transparent,
    backgroundColor: Colors.transparent,
  );
}

Color primaryColor = Color.fromRGBO(48, 49, 146, 1.0);
Color white = Colors.white;

createButton(IconData icon, String text, Function() f, double height) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: GestureDetector(
      onTap: f,
      child: CircleAvatar(
        radius: height * 0.1,
        backgroundColor: primaryColor,
        child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20,color: white,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(text, style: TextStyle(color: white, fontSize: 20,), textAlign: TextAlign.center,),
                ),
              ],
            ),
      ),
    ),
  );
  //   MaterialButton(
  //   onPressed: f,
  //   child: Container(
  //     // margin: EdgeInsets.all(5),
  //     // decoration: BoxDecoration(
  //     //   shape: BoxShape.circle,
  //     // ),
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Icon(icon, size: 20,color: white,),
  //         Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: Text(text, style: TextStyle(color: white, fontSize: 20),),
  //         ),
  //       ],
  //     ),
  //   ),
  //   padding: EdgeInsets.all(5),
  //   color: primaryColor,
  //   // shape: CircleBorder(),
  //   height: height * 0.2,
  // );
}
Future<List<MyUsers>> getUsers(String field, String value, String manager) async {
  List<MyUsers> users = List.empty(growable: true);
  await FirebaseFirestore.instance.collection("users").where(field, isEqualTo: value).get().then((value) =>
  {
    value.docs.forEach((element) {
      users.add(MyUsers(element["id"], element["name"], element["email"], element["password"], element["access"], element["manager"], element.id, element["company"]));
    })
  });
  if(manager != "")
    {
      users.removeWhere((element) {return element.manager != manager;});
    }
  return users;
}
