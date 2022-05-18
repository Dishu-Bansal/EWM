// import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
// //import 'package:amplify_flutter/amplify.dart';
// import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:ewm/admin/admin_home.dart';
import 'package:ewm/member/member_home.dart';
import 'package:ewm/my_auth.dart';
import 'package:ewm/operator/operator_home.dart';
import 'package:ewm/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'my_users.dart';

String access = "Member";
class Login extends StatelessWidget {
  String acces;
  Login(String this.acces, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    access = acces;
    return Scaffold(
      //resizeToAvoidBottomInset: false,
      appBar: createAppBar(context),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 100,),
              Credentials(),
            ],
          ),
        ),
      ),
    );
  }
}

String email="", password="";
class Credentials extends StatefulWidget {
  const Credentials({Key? key}) : super(key: key);

  @override
  _CredentialsState createState() => _CredentialsState();
}

class _CredentialsState extends State<Credentials> {
  TextEditingController _controller1 = new TextEditingController();
  TextEditingController _controller2 = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
              child: Text("Email", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.start,),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _controller1,
            onChanged: (val) {
              email=val.trim().toLowerCase();
            },
            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), gapPadding: 2), label: Text("Email")),
          ),
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
              child: Text("Password", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.start,),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _controller2,
            obscureText: true,
            onChanged: (val) {
              password=val.trim();
            },
            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), gapPadding: 2), label: Text("Password")),
          ),
        ),
        Row(
          children: [
            Expanded(child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 3.0),
              child: login_button(),
            )),
          ],
        )
      ],
    );
  }
}

class login_button extends StatefulWidget
{
  login_button({Key? key}) : super(key: key);

  @override
  _login_buttonState createState() => _login_buttonState();
}

class _login_buttonState extends State<login_button> {

  _ShowToast(String msg) {
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

  bool loading=false;
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () async {
        if(!loading)
          {
            setState(() {
              loading = true;
            });
            bool success = await MyAuth().signInUser(email, password, access);
            if(success)
            {
              if(access == "Admin")
              {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)  => admin_home()));
              }
              else if(access == "Operator")
              {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)  => operator_home(MyAuth().myuser)));
              }
              else
              {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)  => member_home(MyAuth().myuser)));
              }
            }
            else
            {
              _ShowToast("Error!");
              setState(() {
                loading = false;
              });
            }
          }
      },
      color: Color.fromRGBO(46, 49, 146, 1),
      child: Text("Log In", style: TextStyle(fontSize: 20),),
      textColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
      height: 45,);
  }
}


