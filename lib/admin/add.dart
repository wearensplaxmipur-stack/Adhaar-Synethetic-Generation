import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/user.dart' show LoginModel;


class AddUser extends StatefulWidget {
  const AddUser({super.key,required this.cons});
  final String cons;
  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();

  bool isAdmin = false;
  bool isUploadData = false;

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> createUser() async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();

    final user = LoginModel(
      id: id,
      username: username.text.trim(),
      password: password.text.trim(),
      isadmin: isAdmin,
      isuploaddata: isUploadData,
    );

    await FirebaseFirestore.instance
        .collection(widget.cons).doc("logins").collection("logins")
        .doc(id)
        .set(user.toMap());

    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add User")),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextFormField(
                controller: username,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: password,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text("Admin User"),
                value: isAdmin,
                onChanged: (v) => setState(() => isAdmin = v),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: (){
                  if (_formKey.currentState!.validate()) {
                    createUser();
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width - 20,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 8),
                      Text(
                        "Yes, Create this User",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}