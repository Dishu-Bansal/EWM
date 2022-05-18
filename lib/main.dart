import 'package:ewm/login.dart';
import 'package:ewm/member/member_home.dart';
import 'package:ewm/my_auth.dart';
import 'package:ewm/register.dart';
import 'package:ewm/util.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  initialize() async {
    await MyAuth().registerListener(context);
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            children: [
              Expanded(
                child: Center(
                  child: MaterialButton(
                      onPressed: () {Navigator.of(context).push(MaterialPageRoute(builder: (_) => Register()));},
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20.0, 8, 20, 8),
                        child: Text("Register", style: TextStyle(color: white, fontSize: 20),),
                      ),
                      color: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: Colors.black,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("or"),
              ),
              Expanded(
                child: Divider(
                  color: Colors.black,
                ),
              ),
            ],
          ),
          createButton(Icons.email, "Admin", () {Navigator.of(context).push(MaterialPageRoute(builder: (_) => Login("Admin")));}, MediaQuery.of(context).size.height),
          createButton(Icons.email, "Operator", () {Navigator.of(context).push(MaterialPageRoute(builder: (_) => Login("Operator")));}, MediaQuery.of(context).size.height),
          createButton(Icons.email, "Member", () {Navigator.of(context).push(MaterialPageRoute(builder: (_) => Login("Member")));}, MediaQuery.of(context).size.height),
        ],
      ),
    );
  }
}
