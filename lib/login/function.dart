

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show ScaffoldMessenger, SnackBar;

import '../model/user.dart' show LoginModel;
class Users{
  static Future<void> signup(BuildContext context,{
    required String username,
    required String password,
    required String name,
    bool isadmin = false,

  }) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();

    final model = LoginModel(
      id: id,
      username: username,
      password: password,
      isadmin: isadmin,
      ison: true,
    );

    try {
      await FirebaseFirestore.instance
          .collection(name).doc("logins").collection("logins")
          .doc(id)
          .set(model.toMap());
      send(context, "Success");
    }catch(e){
      send(context, "${e}");
    }
  }

  static Future<LoginModel> login(BuildContext context,{
    required String username,
    required String password,
    required String name,
  }) async {
    final snap = await FirebaseFirestore.instance
        .collection(name).doc("logins").collection("logins")
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) {
      send(context, "Username not found");

      throw 'Username not found';
    }

    final data = snap.docs.first.data();
    final user = LoginModel.fromMap(data);

    if (!user.ison) {
      send(context, "Account disabled");

      throw 'Account disabled';
    }

    if (user.password != password) {
      send(context, "Incorrect password");
      throw 'Incorrect password';
    }
    print("----------------------------------------->");
    print(user);

    return user;
  }

  static void send(BuildContext context, String e){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e)),
    );
  }
  static Future<LoginModel?> getUserByUsername(
      BuildContext context, {
        required String username,
        required String name,
      }) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection(name)
          .doc("logins")
          .collection("logins")
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        send(context, "User not found");
        return null;
      }

      final data = snap.docs.first.data();
      final user = LoginModel.fromMap(data);

      // ✅ Save globally
      thisUser = user;

      send(context, "User loaded");
      print("----------------------------------------->");
      print(user);

      return user;
    } catch (e) {
      send(context, e.toString());
      return null;
    }
  }
  static LoginModel? thisUser;
}
