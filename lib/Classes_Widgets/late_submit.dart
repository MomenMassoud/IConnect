import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/assigment_model.dart';
import '../models/groups.dart';

class LateSubmitt extends StatefulWidget {
  groups currentgroup;
  String id;
  LateSubmitt(this.currentgroup, this.id);
  _Submmit createState() => _Submmit();
}

class _Submmit extends State<LateSubmitt> {
  List<AssigmentModel> member = [];
  int dd = 0;
  int mm = 0;
  final _auth = FirebaseAuth.instance;
  late User SignInUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
    getAllSubmited();
  }

  void getUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        SignInUser = user;
        Map<String, dynamic>? usersMap2;
        await _firestore
            .collection('user')
            .where('email', isEqualTo: SignInUser.email)
            .get()
            .then((value) {
          usersMap2 = value.docs[0].data();
          String bio = usersMap2!['bio'];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void getAllSubmited() async {
    try {
      Map<String, dynamic>? usersMap;
      List<AssigmentModel> members=[];
      await for(var snapshot in _firestore.collection("Assigments").where('assigmentid',isEqualTo: widget.id).snapshots() ){
        for(var cont in snapshot.docs) {
          usersMap=cont.data();
          final msg = usersMap!['Msg'];
          final day = usersMap!['day'];
          final month = usersMap!['month'];
          final time = usersMap!['time'];
          final owner = usersMap!['owner'];
          final ownername = usersMap!['ownername'];
          final name = usersMap!['name'];
          AssigmentModel gg = AssigmentModel(
              owner: owner,
              ownername: ownername,
              msg: msg,
              assigmentid: widget.id,
              time: time,
              day: day,
              month: month,
              iddocument: widget.id);
          gg.name = name;
          if ("app" == gg.ownername) {
            dd = int.parse(gg.day);
            mm = int.parse(gg.month);
          } else {
            int month = int.parse(gg.month);
            int day = int.parse(gg.day);
            if (mm == month) {
              if (dd >= day) {
              } else {
                setState(() {
                  members.add(gg);
                });
              }
            } else if (mm > month) {
            } else {
              setState(() {
                members.add(gg);
              });
            }
          }
        }
        setState(() {
          member=members;
        });
      }

    } catch (e) {
      print(e);
    }
  }

  Future<bool?> _requestPermision(Permission per) async {
    if (await per.isGranted) {
      return true;
    } else {
      await per.request();
    }
  }

  Future<File?> downloadFile(String url, String Name) async {
    try {
      final appStorage = await getExternalStorageDirectory();
      final file = File('${appStorage?.path}/$Name');
      final response = await Dio().get(url,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
          ));
      final ref = file.openSync(mode: FileMode.write);
      ref.writeFromSync(response.data);
      await ref.close();
      return file;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future openFileUrl(String url, String fileName) async {
    try {
      final appStorage = await getExternalStorageDirectory();
      final test = File('${appStorage?.path}/$fileName');
      final cc = await test.exists();
      if (cc) {
        OpenFile.open(test.path);
      } else {
        await _requestPermision(Permission.storage);
        final file = await downloadFile(url, fileName);
        if (file == null) return null;
        OpenFile.open(file.path);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: member.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(member[index].ownername),
            subtitle: Text(member[index].owner),
            trailing: IconButton(
              onPressed: () async {
                openFileUrl(member[index].msg, member[index].name);
              },
              icon: Icon(Icons.open_in_new),
            ),
          );
        });
  }
}
