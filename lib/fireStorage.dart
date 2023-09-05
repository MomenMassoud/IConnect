import 'dart:io';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
class Storage{
   Future <void> uploadFile(String filepath,File filename) async{
     File file = File(filepath);
     try{
        final storage=firebase_storage.FirebaseStorage.instance.ref().child('profile_photos/${filepath}');
        await storage.putFile(filename).whenComplete(() async{
          await storage.getDownloadURL().then((value) => print(value));
        });
     }
     catch(e){
       print(e);
     }
   }
}