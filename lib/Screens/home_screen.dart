import 'dart:async';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/Screens/select_contact.dart';
import 'package:chatapp/Screens/send_share_msg.dart';
import 'package:chatapp/Screens/show_notifications.dart';
import 'package:chatapp/Screens/star_massege_screen.dart';
import 'package:chatapp/Screens/story_screen.dart';
import 'package:chatapp/Screens/view_notes.dart';
import 'package:chatapp/models/groups.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../CustomUI/CustomSetting.dart';
import '../models/ChatModel.dart';
import '../models/notification_model.dart';
import 'ChatPage.dart';
import 'call_history.dart';
import 'class-room-screen.dart';
import 'create_group.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
class HomeScreen extends StatefulWidget {
  String _sharedText="";
  List<ChatModel> chat;
  List<groups> group = [];
  ChatModel source;
  HomeScreen(this.chat, this.source);
  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> with SingleTickerProviderStateMixin{
  late StreamSubscription _intentDataStreamSubscription;
  late SharedMediaFile _sharedFiles;
  String _sharedText="";
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final flutterloacl =FlutterLocalNotificationsPlugin();
  int countNotification = 0;
  FirebaseMessaging fcm = FirebaseMessaging.instance;
  int _selectedIndex = 0;
  Map<String, dynamic>? usersMap;
  List<NotificationData> data = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late User SignInUser;
  String prof = "Images/profile.png";
  XFile? image;
  String path = "";
  final ImagePicker picker = ImagePicker();
  String profileurl = "";
  double value = 0;
  void _getCountNotification() async {
    try {
      await for(var snapshot in _firestore.collection('Notifications').where('owner',isEqualTo: SignInUser.email).snapshots()){
        setState(() {
          countNotification=snapshot.docs.length;
        });
      }
    } catch (e) {
      print(e);
    }
  }
  void getGroups() async {
    await _firestore
        .collection('Groups')
        .where('User', isEqualTo: SignInUser.email)
        .get()
        .then((value) {
      for (int i = 0; i < value.docs.length; i++) {
        usersMap = value.docs[i].data();
        String id = usersMap!['GroupID'];
        String type = usersMap!['typeGroup'];
        String ustype = usersMap!['typeUser'];
        String name = usersMap!['groupName'];
        String info = usersMap!['info'];
        String photo = usersMap!['profileIMG'];
        groups gg = groups(id, name, type, ustype, info);
        gg.photo = photo;
        widget.group.add(gg);
      }
    });
  }

  void setDeviceToken()async{
    try{

      String id="";
      await _firestore.collection('user').where('email',isEqualTo: _auth.currentUser!.email).get().then((value){
        id = value.docs[0].id;
      });
      fcm.getToken().then((value){
        final docRef = _firestore.collection("user").doc(id);
        final updates = <String, dynamic>{
          "token":value,
        };
        widget.source.device=value.toString();
        docRef.update(updates);
        print('Update Token \n new Token is $value');
      });
    }
    catch(e){
      print(e);
    }
  }

  void notificationSettings()async{
    NotificationSettings settings = await fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }
  Future getImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);
    setState(() {
      image = img;
    });
  }

  void getUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        SignInUser = user;
        widget.source.name = SignInUser.displayName!;
        widget.source.email = SignInUser.email!;
        widget.source.icon = SignInUser.photoURL!;
        Map<String, dynamic>? usersMap2;
        String idd="";
        await _firestore
            .collection('user')
            .where('email', isEqualTo: widget.source.email)
            .get()
            .then((value) {
          usersMap2 = value.docs[0].data();
          String bio = usersMap2!['bio'];
          widget.source.BIO = bio;
          idd=value.docs[0].id;
        });
        final docRef = _firestore.collection("user").doc(idd);
        final updates = <String, dynamic>{
          "seen":"online",
        };
        widget.source.seen="online";
        docRef.update(updates);
        print("Update Seen To Online");
      }
    } catch (e) {
      print(e);
    }
  }

  void getPicture() async {
    Map<String, dynamic>? usersMap;
    await _firestore
        .collection("user")
        .where('email', isEqualTo: _auth.currentUser!.email)
        .get()
        .then((value) {
      usersMap = value.docs[0].data();
      setState(() {
        profileurl = usersMap!['profileIMG'];
      });
    });
  }

  void myName() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Enter Your New Name"),
            content: Container(
              height: 130,
              child: Column(
                children: [
                  myTextfield(),
                ],
              ),
            ),
          );
        });
  }

  Widget myTextfield() {
    return Column(
      children: [
        TextField(
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          cursorColor: Colors.blue[900],
          onChanged: (value) {
            setState(() {
              widget.chat[0].name = value;
            });
            decoration:
            InputDecoration(
              prefixIcon: Icon(Icons.account_circle),
              hintText: "Enter Your Name",
              contentPadding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 20,
              ),
            );
          },
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Sava Data"),
        )
      ],
    );
  }

  void myAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text('Please choose image'),
            content: Container(
              height: 130,
              child: Column(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        getImage(ImageSource.gallery);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.image),
                          Text("From Gallery"),
                        ],
                      )),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        getImage(ImageSource.camera);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.camera_alt),
                          Text("From Camera"),
                        ],
                      ))
                ],
              ),
            ),
          );
        });
  }

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
void lisetnew(){
  print("we lisetn");
}
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getUser();
    getGroups();
    getPicture();
    _getCountNotification();
    _getPermesion();
    initInfo();
    setDeviceToken();
    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((value) {
          setState(() {
            _sharedText = _sharedText = value?.trim() ?? '';
            print(_sharedText);
          });
          if(_sharedText.isNotEmpty){
            Navigator.push(context, MaterialPageRoute(builder: (builder)=> SendShareMSG(widget.source,_sharedText)));
          }
        }, onError: (err) {
          print("getLinkStream error: $err");
        });
    ReceiveSharingIntent.getInitialMedia().then((value) {
      String type="";
      setState(() {
        _sharedFiles = value.first;
        String type=value.first.type.toString();
        if(_sharedFiles.path!=null){
          Navigator.push(context, MaterialPageRoute(builder: (builder)=> SendShareMSG(widget.source,_sharedFiles.path)));
        }
      });
    });

// For sharing files coming from outside the app while the app is open
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> value) {
          String type="";
          setState(() {
            _sharedFiles = value.first;

          });
          if(_sharedFiles.path!=null){
            Navigator.push(context, MaterialPageRoute(builder: (builder)=> SendShareMSG(widget.source,_sharedFiles.path)));
          }
        }, onError: (err) {
          print("getMediaStream error: $err");
        });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((value) {

      setState(() {
        _sharedText = _sharedText = value?.trim() ?? '';
        print(_sharedText);
      });
      if(_sharedText.isNotEmpty){
        Navigator.push(context, MaterialPageRoute(builder: (builder)=> SendShareMSG(widget.source,_sharedText)));
      }
    });
    // if (ModalRoute.of(context)?.settings?.name == '/') {
    //   if (_sharedFiles != null) {
    //     Navigator.push(context, MaterialPageRoute(builder: (builder)=> SendShareMSG(widget.source,_sharedFiles.path)));
    //   }
    // }

}
void getScreen(){
  if(_sharedText!=""){
    Navigator.push(context, MaterialPageRoute(builder: (builder)=> SendShareMSG(widget.source,_sharedText)));
  }
}
@override
  void dispose() {
    // TODO: implement dispose
  _intentDataStreamSubscription.cancel();
  _sharedFiles=SharedMediaFile("", "thumbnail", "duration" as int?, "type" as SharedMediaType);
    super.dispose();
  }
void sharedFiles(){

}
void _getPermesion()async{
    NotificationSettings settings =  await fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if(settings.authorizationStatus==AuthorizationStatus.authorized){
      print("User Granted Permesion");
    }
    else if(settings.authorizationStatus==AuthorizationStatus.provisional){
      print("User Granted Provisional ");
    }
    else{
      print("User Declind");
    }
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {

      print('A new onMessageOpenedApp event was published!');
      print('Message data: ${message.data}');

      if (message.notification != null && message.notification!.title != null && message.notification!.body != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null && message.notification!.title != null && message.notification!.body != null) {
        print('Message also contained a notification: ${message.notification}');
        showNotification(message.notification!.title!, message.notification!.body!);
      }
    });

}
  Future<void> showNotification(String title, String body) async {
    var androidDetails = AndroidNotificationDetails(
        'channelId', 'channelName', 'channelDescription',
        importance: Importance.max, priority: Priority.high, ticker: 'ticker');
    var iosDetails = IOSNotificationDetails();
    var platformDetails =
    NotificationDetails(android: androidDetails, iOS: iosDetails);
    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformDetails,
        payload: 'item x');
  }
void initInfo(){
    var androidinti=const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosinit=const IOSInitializationSettings();
    var initSetting=InitializationSettings(android: androidinti,iOS: iosinit);
    flutterloacl.initialize(initSetting,onSelectNotification: (String ? payload)async{
      try{
        if(payload != null && payload.isNotEmpty){

        }
        else{

        }
      }
      catch(e){
        print(e);
      }
    });
}

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      ChatPage(widget.chat, widget.source),
      Story(widget.source, widget.chat),
      Call_History(),
      ClassRoom(widget.chat, widget.source, widget.group, widget.chat)
    ];
    return Scaffold(
      drawer: Padding(
        padding: const EdgeInsets.only(top: 45, right: 10),
        child: Drawer(
          width: 290,
          child: Stack(
            children: [
              ListView(
                children: [
                  Container(
                    child: Column(
                      children: [
                        profileurl == ""
                            ? CircleAvatar(
                                radius: 70,
                                backgroundImage: AssetImage("Images/pop.jpg"),
                              )
                            : CircleAvatar(
                                radius: 70,
                                backgroundImage:
                                    CachedNetworkImageProvider(profileurl),
                              ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              SignInUser.displayName!,
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        SignInUser.email!,
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                  CustomSetting(Icons.group_add, "New Group", "", false, false,
                      widget.source),
                  CustomSetting(
                      Icons.person, "Contact", "", false, false, widget.source),
                  CustomSetting(
                      Icons.call, "Calls", "", false, false, widget.source),
                  CustomSetting(Icons.bookmark_outlined, "Saved Messages", "",
                      false, false, widget.source),
                  CustomSetting(Icons.settings, "Setting", "", false, true,
                      widget.source),
                  CustomSetting(Icons.star_rate_rounded, "IConnect Premuim", "",
                      false, false, widget.source),
                  CustomSetting(Icons.question_mark, "IConnect Features", "",
                      false, true, widget.source),
                ],
              ),
              TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: value),
                  duration: Duration(milliseconds: 500),
                  builder: (_, double val, __) {
                    return (Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..setEntry(0, 3, 200 * val)
                          ..rotateY((pi / 6) * val)));
                  })
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(40),
              top: Radius.circular(40),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(40),
          ),
        ),
        backgroundColor: Colors.lightBlueAccent,
        title: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundImage: AssetImage("Images/logo.jpeg"),
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  'IConncet',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ],
        ),
        actions: [
          countNotification != 0
              ? Stack(
                  alignment: Alignment.topRight,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) =>
                                      ShowNotifications(data)));
                        },
                        icon: Icon(Icons.notifications_active)),
                    CircleAvatar(
                      child: Text(countNotification.toString()),
                      radius: 9,
                      backgroundColor: Colors.red,
                    )
                  ],
                )
              : IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => ShowNotifications(data)));
                  },
                  icon: Icon(Icons.notifications)),
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (builder) => ViewNotes(widget.source)));
              },
              icon: Icon(Icons.note_add_outlined)),
          PopupMenuButton<String>(onSelected: (value) {
            print(value);

            if (value == "Logout") {
              _auth.signOut();
              Navigator.pop(context);
            }
            else if (value == "Show Notifications") {}
            else if (value == "New Group") {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) =>
                          CreateGroup(widget.chat, widget.source)));
            }
            else if(value=="Started Massege"){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) =>
                          StarMassege( widget.source)));
            }
          }, itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(
                      Icons.group_add,
                      color: Colors.blue,
                    ),
                    Text("New Group"),
                  ],
                ),
                value: "New Group",
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(
                      Icons.broadcast_on_home_outlined,
                      color: Colors.blue,
                    ),
                    Text("New broadcast"),
                  ],
                ),
                value: "New broadcast",
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.blue,
                    ),
                    Text("Started Massege"),
                  ],
                ),
                value: "Started Massege",
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      color: Colors.red,
                    ),
                    Text(
                      "Logout",
                      style: TextStyle(color: Colors.red),
                    )
                  ],
                ),
                value: "Logout",
              ),
            ];
          })
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        enableFeedback: true,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_toggle_off),
            label: 'Story',
            backgroundColor: Colors.blueAccent,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call),
            label: 'Call',
            backgroundColor: Colors.blueAccent,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Groups',
            backgroundColor: Colors.blueAccent,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
