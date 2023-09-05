import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/models/ChatModel.dart';
import 'package:chatapp/models/call_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../AudioCall_VideoCall/audiocall.dart';
import '../AudioCall_VideoCall/videocall.dart';
import 'make_new_call.dart';

class Call_History extends StatefulWidget {
  @override
  _Call_History createState() => _Call_History();
}

class _Call_History extends State<Call_History> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late User SignInUser;
  ChatModel source =
      ChatModel("", "icon", false, "time", "currentMessage", 1, false);
  List<CallModel> calls=[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('callhistory')
              .where('myemail', isEqualTo: source.email)
              .snapshots(),
          builder: (context, snapshot) {
            List<CallModel> massegeWidget = [];
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.blue,
                ),
              );
            }
            final masseges = snapshot.data?.docs;
            for (var massege in masseges!.reversed) {
              final mycontactemail = massege.get('mycontactemail');
              final mycontactname = massege.get('mycontactname');
              final prodileimg = massege.get('profileIMG');
              final sendtype = massege.get('sendtype');
              final time = massege.get('time');
              final type = massege.get('type');
              final callid = massege.get('callid');
              final id = massege.id;
              CallModel call = CallModel(
                  myemail: source.email,
                  mycontactemail: mycontactemail,
                  profileIMG: prodileimg,
                  type: type,
                  time: time,
                  sendtype: sendtype,
                  mycontactname: mycontactname,
                  callid: callid);
              call.id = id;
              calls.add(call);
              massegeWidget.add(call);
            }
            return massegeWidget.length > 0
                ? ListView.builder(
                    itemCount: massegeWidget.length,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Column(
                          children: [
                            ListTile(
                              title: Text("Call History"),
                              leading: Icon(Icons.history),
                              subtitle: Text("All Your Calls Here"),
                              trailing: IconButton(
                                onPressed: () async {
                                  for (int i = 0;
                                      i < massegeWidget.length;
                                      i++) {
                                    _firestore
                                        .collection("callhistory")
                                        .doc(massegeWidget[i].id)
                                        .delete()
                                        .then((value) => print("deleted"));
                                  }
                                },
                                icon: Icon(Icons.delete),
                              ),
                            ),
                            Divider(
                              thickness: 4,
                            ),
                            ListTile(
                              title: Text(massegeWidget[index].mycontactname),
                              subtitle: Row(
                                children: [
                                  massegeWidget[index].sendtype == "outline"
                                      ? Icon(
                                          Icons.call_made,
                                          color: Colors.green,
                                        )
                                      : Icon(
                                          Icons.call_received,
                                          color: Colors.blueAccent,
                                        ),
                                  Text(massegeWidget[index].time)
                                ],
                              ),
                              leading: CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                                    massegeWidget[index].profileIMG),
                              ),
                              trailing: massegeWidget[index].type == "audiocall"
                                  ? IconButton(
                                      onPressed: () async {
                                        String chatroomID = "";
                                        if (massegeWidget[index].type ==
                                            "audiocall") {
                                          try {
                                            String id =
                                                DateTime.now().toString();
                                            String idd = "$id-${source.email}";
                                            await _firestore
                                                .collection("callhistory")
                                                .doc(idd)
                                                .set({
                                              'profileIMG': massegeWidget[index]
                                                  .profileIMG,
                                              'time': DateTime.now()
                                                  .toString()
                                                  .substring(10, 16),
                                              'myemail': source.email,
                                              'mycontactemail':
                                                  massegeWidget[index]
                                                      .mycontactemail,
                                              'type': 'audiocall',
                                              'sendtype': 'outline',
                                              'mycontactname':
                                                  massegeWidget[index]
                                                      .mycontactname,
                                              'callid':
                                                  massegeWidget[index].callid
                                            });
                                            id = DateTime.now().toString();
                                            idd =
                                                "$id-${massegeWidget[index].mycontactemail}";
                                            await _firestore
                                                .collection("callhistory")
                                                .doc(idd)
                                                .set({
                                              'profileIMG': source.icon,
                                              'time': DateTime.now()
                                                  .toString()
                                                  .substring(10, 16),
                                              'myemail': massegeWidget[index]
                                                  .mycontactemail,
                                              'mycontactemail': source.email,
                                              'type': 'audiocall',
                                              'sendtype': 'incoming',
                                              'mycontactname':
                                                  SignInUser.displayName,
                                              'callid':
                                                  massegeWidget[index].callid
                                            });
                                          } catch (e) {
                                            print(e);
                                          }
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (builder) =>
                                                      AudioCallOneToOne(
                                                        massegeWidget[index]
                                                            .callid,
                                                        source.name,
                                                        source.email,
                                                      )));
                                        } else {
                                          try {
                                            String id =
                                                DateTime.now().toString();
                                            String idd = "$id-${source.email}";
                                            await _firestore
                                                .collection("callhistory")
                                                .doc(idd)
                                                .set({
                                              'profileIMG': massegeWidget[index]
                                                  .profileIMG,
                                              'time': DateTime.now()
                                                  .toString()
                                                  .substring(10, 16),
                                              'myemail': source.email,
                                              'mycontactemail':
                                                  massegeWidget[index]
                                                      .mycontactemail,
                                              'type': 'vediocall',
                                              'sendtype': 'outline',
                                              'mycontactname':
                                                  massegeWidget[index]
                                                      .mycontactname,
                                              'callid':
                                                  massegeWidget[index].callid
                                            });
                                            id = DateTime.now().toString();
                                            idd =
                                                "$id-${massegeWidget[index].mycontactemail}";
                                            await _firestore
                                                .collection("callhistory")
                                                .doc(idd)
                                                .set({
                                              'profileIMG': source.icon,
                                              'time': DateTime.now()
                                                  .toString()
                                                  .substring(10, 16),
                                              'myemail': massegeWidget[index]
                                                  .mycontactemail,
                                              'mycontactemail': source.email,
                                              'type': 'vediocall',
                                              'sendtype': 'incoming',
                                              'mycontactname':
                                                  SignInUser.displayName,
                                              'callid':
                                                  massegeWidget[index].callid
                                            });
                                          } catch (e) {
                                            print(e);
                                          }
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (builder) =>
                                                      CallPage(
                                                        CallID:
                                                            massegeWidget[index]
                                                                .callid,
                                                        UserName: source.name,
                                                        email: source.email,
                                                      )));
                                        }
                                      },
                                      icon: Icon(
                                        Icons.call,
                                        color: Colors.blueAccent,
                                      ))
                                  : IconButton(
                                      onPressed: () async {
                                        String chatroomID = "";
                                        if (massegeWidget[index].type ==
                                            "audiocall") {
                                          try {
                                            String id =
                                                DateTime.now().toString();
                                            String idd = "$id-${source.email}";
                                            await _firestore
                                                .collection("callhistory")
                                                .doc(idd)
                                                .set({
                                              'profileIMG': massegeWidget[index]
                                                  .profileIMG,
                                              'time': DateTime.now()
                                                  .toString()
                                                  .substring(10, 16),
                                              'myemail': source.email,
                                              'mycontactemail':
                                                  massegeWidget[index]
                                                      .mycontactemail,
                                              'type': 'audiocall',
                                              'sendtype': 'outline',
                                              'mycontactname':
                                                  massegeWidget[index]
                                                      .mycontactname,
                                              'callid':
                                                  massegeWidget[index].callid
                                            });
                                            id = DateTime.now().toString();
                                            idd =
                                                "$id-${massegeWidget[index].mycontactemail}";
                                            await _firestore
                                                .collection("callhistory")
                                                .doc(idd)
                                                .set({
                                              'profileIMG': source.icon,
                                              'time': DateTime.now()
                                                  .toString()
                                                  .substring(10, 16),
                                              'myemail': massegeWidget[index]
                                                  .mycontactemail,
                                              'mycontactemail': source.email,
                                              'type': 'audiocall',
                                              'sendtype': 'incoming',
                                              'mycontactname':
                                                  SignInUser.displayName,
                                              'callid':
                                                  massegeWidget[index].callid
                                            });
                                          } catch (e) {
                                            print(e);
                                          }
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (builder) =>
                                                      AudioCallOneToOne(
                                                        massegeWidget[index]
                                                            .callid,
                                                        source.name,
                                                        source.email,
                                                      )));
                                        } else {
                                          try {
                                            String id =
                                                DateTime.now().toString();
                                            String idd = "$id-${source.email}";
                                            await _firestore
                                                .collection("callhistory")
                                                .doc(idd)
                                                .set({
                                              'profileIMG': massegeWidget[index]
                                                  .profileIMG,
                                              'time': DateTime.now()
                                                  .toString()
                                                  .substring(10, 16),
                                              'myemail': source.email,
                                              'mycontactemail':
                                                  massegeWidget[index]
                                                      .mycontactemail,
                                              'type': 'vediocall',
                                              'sendtype': 'outline',
                                              'mycontactname':
                                                  massegeWidget[index]
                                                      .mycontactname,
                                              'callid':
                                                  massegeWidget[index].callid
                                            });
                                            id = DateTime.now().toString();
                                            idd =
                                                "$id-${massegeWidget[index].mycontactemail}";
                                            await _firestore
                                                .collection("callhistory")
                                                .doc(idd)
                                                .set({
                                              'profileIMG': source.icon,
                                              'time': DateTime.now()
                                                  .toString()
                                                  .substring(10, 16),
                                              'myemail': massegeWidget[index]
                                                  .mycontactemail,
                                              'mycontactemail': source.email,
                                              'type': 'vediocall',
                                              'sendtype': 'incoming',
                                              'mycontactname':
                                                  SignInUser.displayName,
                                              'callid':
                                                  massegeWidget[index].callid
                                            });
                                          } catch (e) {
                                            print(e);
                                          }
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (builder) =>
                                                      CallPage(
                                                        CallID:
                                                            massegeWidget[index]
                                                                .callid,
                                                        UserName: source.name,
                                                        email: source.email,
                                                      )));
                                        }
                                      },
                                      icon: Icon(
                                        Icons.video_camera_back,
                                        color: Colors.blueAccent,
                                      )),
                              onLongPress: () async {

                              },
                              onTap: () async {
                                try {
                                  _firestore
                                      .collection("callhistory")
                                      .doc(massegeWidget[index].id)
                                      .delete()
                                      .then((value) => print("deleted"));
                                } catch (e) {
                                  print(e);
                                }
                              },
                            )
                          ],
                        );
                      } else {
                        return ListTile(
                          title: Text(massegeWidget[index].mycontactname),
                          subtitle: Row(
                            children: [
                              massegeWidget[index].sendtype == "outline"
                                  ? Icon(
                                      Icons.call_made,
                                      color: Colors.green,
                                    )
                                  : Icon(
                                      Icons.call_received,
                                      color: Colors.blueAccent,
                                    ),
                              Text(massegeWidget[index].time)
                            ],
                          ),
                          leading: CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                                massegeWidget[index].profileIMG),
                          ),
                          trailing: massegeWidget[index].type == "audiocall"
                              ? Icon(
                                  Icons.call,
                                  color: Colors.blueAccent,
                                )
                              : Icon(
                                  Icons.video_camera_back,
                                  color: Colors.blueAccent,
                                ),
                          onTap: () async {
                            String chatroomID = "";
                            if (massegeWidget[index].type == "audiocall") {
                              try {
                                String id = DateTime.now().toString();
                                String idd = "$id-${source.email}";
                                await _firestore
                                    .collection("callhistory")
                                    .doc(idd)
                                    .set({
                                  'profileIMG': massegeWidget[index].profileIMG,
                                  'time': DateTime.now()
                                      .toString()
                                      .substring(10, 16),
                                  'myemail': source.email,
                                  'mycontactemail':
                                      massegeWidget[index].mycontactemail,
                                  'type': 'audiocall',
                                  'sendtype': 'outline',
                                  'mycontactname':
                                      massegeWidget[index].mycontactname,
                                  'callid': massegeWidget[index].callid
                                });
                                id = DateTime.now().toString();
                                idd =
                                    "$id-${massegeWidget[index].mycontactemail}";
                                await _firestore
                                    .collection("callhistory")
                                    .doc(idd)
                                    .set({
                                  'profileIMG': source.icon,
                                  'time': DateTime.now()
                                      .toString()
                                      .substring(10, 16),
                                  'myemail':
                                      massegeWidget[index].mycontactemail,
                                  'mycontactemail': source.email,
                                  'type': 'audiocall',
                                  'sendtype': 'incoming',
                                  'mycontactname': SignInUser.displayName,
                                  'callid': massegeWidget[index].callid
                                });
                              } catch (e) {
                                print(e);
                              }
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => AudioCallOneToOne(
                                            massegeWidget[index].callid,
                                            source.name,
                                            source.email,
                                          )));
                            } else {
                              try {
                                String id = DateTime.now().toString();
                                String idd = "$id-${source.email}";
                                await _firestore
                                    .collection("callhistory")
                                    .doc(idd)
                                    .set({
                                  'profileIMG': massegeWidget[index].profileIMG,
                                  'time': DateTime.now()
                                      .toString()
                                      .substring(10, 16),
                                  'myemail': source.email,
                                  'mycontactemail':
                                      massegeWidget[index].mycontactemail,
                                  'type': 'vediocall',
                                  'sendtype': 'outline',
                                  'mycontactname':
                                      massegeWidget[index].mycontactname,
                                  'callid': massegeWidget[index].callid
                                });
                                id = DateTime.now().toString();
                                idd =
                                    "$id-${massegeWidget[index].mycontactemail}";
                                await _firestore
                                    .collection("callhistory")
                                    .doc(idd)
                                    .set({
                                  'profileIMG': source.icon,
                                  'time': DateTime.now()
                                      .toString()
                                      .substring(10, 16),
                                  'myemail':
                                      massegeWidget[index].mycontactemail,
                                  'mycontactemail': source.email,
                                  'type': 'vediocall',
                                  'sendtype': 'incoming',
                                  'mycontactname': SignInUser.displayName,
                                  'callid': massegeWidget[index].callid
                                });
                              } catch (e) {
                                print(e);
                              }
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => CallPage(
                                            CallID: massegeWidget[index].callid,
                                            UserName: source.name,
                                            email: source.email,
                                          )));
                            }
                          },
                        );
                      }
                    },
                  )
                : Center(
                    child: Text("You Don't Have Any Call History"),
                  );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (builder) => MakeNewCall(
                    source
                  )));
        },
        child: Icon(Icons.add_ic_call_sharp),
        backgroundColor: Colors.lightBlueAccent[350],
      ),
    );
  }

  void getUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        SignInUser = user;
        setState(() {
          source.name = SignInUser.displayName!;
          source.email = SignInUser.email!;
          source.icon = SignInUser.photoURL!;
        });
        Map<String, dynamic>? usersMap2;
        await _firestore
            .collection('user')
            .where('email', isEqualTo: source.email)
            .get()
            .then((value) {
          usersMap2 = value.docs[0].data();
          String bio = usersMap2!['bio'];
          setState(() {
            source.BIO = bio;
          });
        });
      }
    } catch (e) {
      print(e);
    }
  }
}
