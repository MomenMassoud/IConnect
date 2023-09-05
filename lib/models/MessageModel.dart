import 'ChatModel.dart';
import 'group_user.dart';

class MessageModel {
  GroupUserModel groupuser=GroupUserModel("", "", "", "");
  late String delete1;
  late String delete2;
  late String id;
  late String photo;
  String type;
  String message;
  String time;
  late String sender;
  late String seen;
  late String typemsg;
  late ChatModel us;
  late String assigmentid;
  MessageModel(this.message, this.type, this.time);
}
