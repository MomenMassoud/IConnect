import 'dart:async';
import 'package:camera/camera.dart';
import 'package:chatapp/Screens/Welcome_Screen.dart';
import 'package:chatapp/Screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'Screens/Camera_Screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'models/ChatModel.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
//This Only Test
ChatModel source=ChatModel("", "icon", false, "time", "currentMessage", 1, false);
bool log=false;
//This Only Test
List<ChatModel> contact=[
  ChatModel("Lily", "Images/p4.jpg", false, "13:20", "Hi There", 2,false),
  ChatModel("Mohamed", "Images/p2.png", false, "13:20", "Hi There", 3,false),
];
//Start App From Here
final _auth = FirebaseAuth.instance;
late User SignInUser;
void getUser() async {
  try {
    final user = _auth.currentUser;
    if (user != null) {
      SignInUser = user;
      source.email=SignInUser.email!;
      source.name = SignInUser.displayName!;
      source.icon="Images/pop.jpeg";
    }
  } catch (e) {
    print(e);
  }
}

Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await DotEnv().load();
  cameras=await availableCameras();
  getUser();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings androidInitializationSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  IOSInitializationSettings iosInitializationSettings =
  IOSInitializationSettings();
  InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);
  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  _MyApp createState()=>_MyApp();
}
class _MyApp extends State<MyApp> with WidgetsBindingObserver{
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics: analytics);
  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this as WidgetsBindingObserver);
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    WidgetsBinding.instance.removeObserver(this as WidgetsBindingObserver);
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.paused){
      FirebaseFirestore firestore=FirebaseFirestore.instance;
      FirebaseAuth auth = FirebaseAuth.instance;
      firestore.collection('user').where('email',isEqualTo: auth.currentUser?.email).get().then((value){
        String id =value.docs[0].id;
        String seen =DateTime.now().toString().substring(10, 16);
        final docRef = firestore.collection("user").doc(id);
        final updates = <String, dynamic>{
          "seen":seen,
        };
        docRef.update(updates);
        print('Seen = $seen');
      });
    }
    else if(state == AppLifecycleState.inactive){
      FirebaseFirestore firestore=FirebaseFirestore.instance;
      FirebaseAuth auth = FirebaseAuth.instance;
      firestore.collection('user').where('email',isEqualTo: auth.currentUser?.email).get().then((value){
        String id =value.docs[0].id;
        String seen =DateTime.now().toString().substring(10, 16);
        final docRef = firestore.collection("user").doc(id);
        final updates = <String, dynamic>{
          "seen":seen,
        };
        docRef.update(updates);
        print('Seen = $seen');
      });
    }
    else{
      FirebaseFirestore firestore=FirebaseFirestore.instance;
      FirebaseAuth auth = FirebaseAuth.instance;
      firestore.collection('user').where('email',isEqualTo: auth.currentUser?.email).get().then((value){
        String id =value.docs[0].id;
        String seen =DateTime.now().toString().substring(10, 16);
        final docRef = firestore.collection("user").doc(id);
        final updates = <String, dynamic>{
          "seen":"online",
        };
        docRef.update(updates);
        print('Seen = $seen');
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'IConnect',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home:_auth.currentUser!=null?HomeScreen(contact,source):WelcomeScreen()
    );
  }
}
