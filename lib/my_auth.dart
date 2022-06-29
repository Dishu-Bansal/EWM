import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewm/admin/admin_home.dart';
import 'package:ewm/member/member_home.dart';
import 'package:ewm/my_users.dart';
import 'package:ewm/operator/operator_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyAuth
{

  static final MyAuth _myAuth = MyAuth.m();

  CollectionReference users = FirebaseFirestore.instance.collection("users");
  String uid="", access="";

  MyUsers myuser=MyUsers("", "", "", "", "", "", "", "");

  factory MyAuth()
  {
    return _myAuth;
  }

  MyAuth.m(){}

  User? user;

  bool signedIn = false;

  registerListener(BuildContext context) async
  {
    await FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if(user == null)
      {
        signedIn = false;
        print("User Signed Out!");
      }
      else
      {
        signedIn = true;
        this.user = user;
        await getUser();
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => myuser.access == "Admin" ? admin_home() : (myuser.access == "Operator" ? operator_home(myuser) : member_home(myuser))));
        print("User Signed In!");
      }
    });
  }

  signUpUser(String email, String password, String name) async
  {
    try
    {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await users.add({
        'id' : user!.uid,
        'email' : email,
        'password' : password,
        'access' : 'Member',
        'manager' : 'None',
        'name' : name,
        'company' : 'None'
      });
      await getUser();
      return true;
    }
    on FirebaseAuthException catch (e)
    {
      if (e.code == 'weak-password')
      {
        print('The password provided is too weak.');
      }
      else if (e.code == 'email-already-in-use')
      {
        print('The account already exists for that email.');
      }
    }
    catch (e)
    {
      print(e);
    }
    return false;
  }

  signInUser(String email, String password, String access) async {
    try
    {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      await getUser();
      if(this.access == access)
        {
          return true;
        }
      else
        {
          print("Access level is " + this.access + "," + access);
          await signOut();
          return false;
        }
    }
    on FirebaseAuthException catch (e)
    {
      if (e.code == 'user-not-found')
      {
        print('No user found for that email.');
      }
      else if (e.code == 'wrong-password')
      {
        print('Wrong password provided for that user.');
      }
    }
    return false;
  }

  signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  getUser() async {
    user = await FirebaseAuth.instance.currentUser;
    await users.where('id', isEqualTo: user!.uid).get().then((QuerySnapshot querySnapshot)
    {
      access = querySnapshot.docs.first["access"];
      uid = querySnapshot.docs.first["id"];
      myuser = MyUsers(querySnapshot.docs.first["id"], querySnapshot.docs.first["name"], querySnapshot.docs.first["email"], querySnapshot.docs.first["password"], querySnapshot.docs.first["access"], querySnapshot.docs.first["manager"], querySnapshot.docs.first.id, querySnapshot.docs.first["company"]);
    }
    );
  }

  isSignedIn() {
    return signedIn;
  }
}