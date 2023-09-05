import 'package:chatapp/models/note_models.dart';
import 'package:chatapp/models/story_model.dart';

class ChatModel {
  late String device;
  late String block;
  late String phoneNumber;
  String name;
  String icon;
  bool isGroup;
  String time;
  String currentMessage;
  late String email;
  late String typegroup="";
  late String typeLast;
  String seen="false";
  int id;
  late List<Notes> note=[];
  bool select;
  late String BIO="";
  List<StoryModel> storys=[];
  ChatModel(
      this.name,
      this.icon,
      this.isGroup,
      this.time,
      this.currentMessage,
      this.id,
      this.select
      );
}
