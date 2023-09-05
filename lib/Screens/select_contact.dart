import 'dart:convert';
import 'package:chatapp/Screens/call_history.dart';
import 'package:chatapp/models/MessageModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/ChatModel.dart';
class SelectContact extends StatefulWidget{
  List<ChatModel> us;
  ChatModel source;
  SelectContact(this.us,this.source);
  @override
  _SelectContact createState()=>_SelectContact();
}
Map<String,dynamic>?usersMap;
class _SelectContact extends State<SelectContact>{
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  FirebaseMessaging fcm = FirebaseMessaging.instance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getPermesion();
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
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {

      print('A new onMessageOpenedApp event was published!');
      print('Message data: ${message.data}');

      if (message.notification != null && message.notification!.title != null && message.notification!.body != null) {
        print('Message also contained a notification: ${message.notification}');
      }

    });
    await for(var massege in FirebaseMessaging.onMessage){
      print('Got a message whilst in the foreground!');
      print('Message data: ${massege.data}');
      if (massege.notification != null && massege.notification!.title != null && massege.notification!.body != null) {
        print('Message also contained a notification: ${massege.notification}');
        showNotification(massege.notification!.title!, massege.notification!.body!);
      }
    }
  }
  void handleNotificationClick(RemoteMessage message) {
    String title = message.notification?.title ?? '';
    String body = message.notification?.body ?? '';
    String data = message.data['data'] ?? '';
    myFunction(title, body, data);
}
  void myFunction(String title, String body, String data) {
    // Handle the notification data as desired
    print('Received notification with title: $title, body: $body, data: $data');
  }
  void openScreen(List<String> user)async{
    ChatModel chat=ChatModel("name", "icon", false, "time", "currentMessage", 1, false);
    await _firestore.collection('user').where('email',isEqualTo: user[2]).get().then((value) {
      Map<String,dynamic>?usersMap2;
      usersMap2=value.docs[0].data();
      final name = usersMap2!['name'];
      final bio = usersMap2!['bio'];
      final profileImg = usersMap2!['profileIMG'];
      chat=ChatModel(name, profileImg, false, "time", "currentMessage", 1, false);
      chat.email=user[2];
      chat.BIO=bio;
    });
    List<MessageModel> messages=[];
    Navigator.push(context, MaterialPageRoute(builder: (builder)=>Call_History()));
  }
  Future<void> showNotification(String title, String body) async {
    var androidDetails = AndroidNotificationDetails(
        'channelId', 'channelName', 'channelDescription',
        importance: Importance.max, priority: Priority.high, ticker: 'ticker',);
    var iosDetails = IOSNotificationDetails();
    List<String> user=body.split('-');
    var platformDetails =
    NotificationDetails(android: androidDetails, iOS: iosDetails);
    await flutterLocalNotificationsPlugin.show(
        0, title, user[0], platformDetails,
        payload: 'item x');
  }
  bool searchstart=false;
  final _auth =FirebaseAuth.instance;
  late User SignInUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
   String searchEmail="";
  void getUser() async{
    try{
      final user = _auth.currentUser;
      if(user!=null){
        SignInUser = user;
        print("User Email!");
        print(SignInUser.email);
        print(SignInUser.displayName);
      }
    }
    catch(e){
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(40),
          ),
        ),
        backgroundColor: Colors.lightBlueAccent,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Contact",style: TextStyle(
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic
            ),),
            Text("265 Contact",style: TextStyle(
              fontSize: 18,
              fontStyle: FontStyle.italic
            ),)
          ],
        ),
        actions: [
          PopupMenuButton<String>(
              onSelected: (value){
                print(value);
                if(value=="Setting"){
                  Navigator.pushNamed(context,'setting_screen');
                }
              },
              itemBuilder: (BuildContext context){
                return[
                  PopupMenuItem(child: Text("Invite a Freind"),value: "Invite a Freind",),
                  PopupMenuItem(child: Text("Contacts"),value: "Contacts",),
                  PopupMenuItem(child: Text("Refreash"),value: "Refreash",),
                  PopupMenuItem(child: Text("help"),value: "help",),
                ];
              })
        ],
      ) ,
      body: Column(
        children: [
          TextField(
            onChanged: (value){
              setState(() {
                searchEmail=value;
                onSearch();
              });
            },
            decoration: InputDecoration(
              hintText: 'Enter Email Of Contact',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)
              )
            ),
          ),
          ElevatedButton(onPressed: (){
            onSearch();
          }, child: Text("Search")),
          usersMap!=null ? ListTile(
            title: Text(usersMap!['name']),
            subtitle: Text(usersMap!['email']),
            trailing: Icon(Icons.message),
            leading: Icon(Icons.person),
            onTap: () async{
              setState(() async{
                ChatModel value=ChatModel(usersMap!['name'], "Images/pop.jpg", false, DateTime.now().toString().substring(10, 16), "", 5, false);
                value.email=usersMap!['email'];
                widget.us.add(value);
                try{
                  final newUser=_auth.currentUser;
                  final id =DateTime.now().toString();
                  String? sourceId=newUser?.email;
                  String? name=newUser?.displayName;
                  String idd="$id-$sourceId";
                  await _firestore.collection('Notifications').doc(idd).set({
                    'sender':newUser?.email,
                    'owner':value.email,
                    'senderName':newUser?.displayName,
                    'msg':"Contact  $name Send you Request to Add you in Contact!",
                    'type':"request",
                    'time':id,
                  });
                  await _firestore.collection('user').where('email',isEqualTo: value.email).get().then((value2){
                    final token=value2.docs[0].get('token');
                    String body="${value.name} send Friend Request";
                    sendNotification(token, widget.source.name,body);
                  });
                  Navigator.pop(context);
                }
                catch (e){
                  print(e);
                }
              });
            },
          ):Container()
        ],
      )
    );
  }
  Future<void> sendNotification(String deviceToken, String title, String body) async {

    String serverKey = 'AAAA8zqSgR0:APA91bHjvWusiXeUAcHfL_61mXoBwiYGOuev5b1f4KrHsR3L03ssODwyWTdooABf1O9M4pKtUdvYUpaqIF3uX-Ut2HAfS2ITholY5EGorFAam3Iomx4r3X3y60QJrneaCfEQnkaRefkP';
    String url = 'https://fcm.googleapis.com/fcm/send';
    // Create the JSON payload for the notification
    Map<String, dynamic> notification = {
      'title': title,
      'body': body,
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
    };
    Map<String, dynamic> data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'message': body,
    };
    Map<String, dynamic> payload = {
      'notification': notification,
      'data': data,
      'to': deviceToken
    };

    // Send the HTTP request
    await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode(payload),
    );
  }
  void onSearch()async{
    FirebaseFirestore _firestore=FirebaseFirestore.instance;
    await _firestore.collection('user').where('email',isEqualTo:  searchEmail).get()
    .then((value){
      setState(() {
        usersMap=value.docs[0].data();
      });
      print(usersMap);
    });
  }

  Future<void> showTestNotification() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    FirebaseMessaging fcm = FirebaseMessaging.instance;
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'channel_id', 'channel_name', 'channel_description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    var platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'Test Notification', 'This is a test notification', platformChannelSpecifics,
        payload: 'item x');
  }

}