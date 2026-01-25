
import 'package:adhaar/admin/add.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore, QuerySnapshot;
import 'package:flutter/material.dart';

import '../model/user.dart';

class SeeAllAdmin extends StatefulWidget {
  final String cons;
  const SeeAllAdmin({super.key,required this.cons});

  @override
  State<SeeAllAdmin> createState() => _SeeAllAdminState();
}

class _SeeAllAdminState extends State<SeeAllAdmin> {
  Future<void> updateField(
      String id,
      String field,
      bool value,
      ) async {
    await FirebaseFirestore.instance
        .collection(widget.cons).doc("logins").collection("logins")
        .doc(id)
        .update({field: value});
  }
  Future<void> deleteField(
      String id,
      String field,
      bool value,
      ) async {
    await FirebaseFirestore.instance
        .collection(widget.cons).doc("logins").collection("logins")
        .doc(id)
        .delete();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Admins"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(widget.cons).doc("logins").collection("logins")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs
              .map((e) => LoginModel.fromMap(
            e.data() as Map<String, dynamic>,
          ))
              .toList();

          if (users.isEmpty) {
            return const Center(child: Text("No Users Found"));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (_, i) {
              final u = users[i];
              return Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage("assets/images (9).png"),
                        ),
                        title: Text(
                          u.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        trailing: IconButton(onPressed: (){
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0), // Rectangle (no rounded edges)
                                ),
                                title: const Text("Log out ?"),
                                content: const Text("You sure to Log out from the App"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false), // Cancel
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      deleteField(u.id, "isadmin", false);
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.resolveWith(
                                            (states) => Colors.red,   // your color here
                                      ),
                                    ),
                                    child: const Text("OK",style: TextStyle(color: Colors.white)),
                                  )
                                ],
                              );
                            },
                          );
                        }, icon: Icon(Icons.delete)),
                        subtitle: Text("Created User on : ${formatFromMicroseconds(u.id.toString())}",
                          style: TextStyle(fontSize: 11),),
                      ),
                      SwitchListTile(
                        title: const Text("Active"),
                        value: u.ison,
                        onChanged: (v) =>
                            updateField(u.id, "ison", v),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (_)=>AddUser(cons: widget.cons)));
        },child: Icon(Icons.add_reaction_sharp,color: Colors.white,),),
    );
  }
  String formatFromMicroseconds(String microsecondss) {
    try {
      int microseconds = int.parse(microsecondss);
      final dt = DateTime.fromMicrosecondsSinceEpoch(microseconds);

      final dd = dt.day.toString().padLeft(2, '0');
      final mm = dt.month.toString().padLeft(2, '0');
      final yy = (dt.year % 100).toString().padLeft(2, '0');
      final hh = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');

      return "$dd/$mm/$yy on $hh:$min";
    }catch(e){
      return "No Data Exist";
    }
  }

}
