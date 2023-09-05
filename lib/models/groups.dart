import 'ChatModel.dart';

class groups{
  late String photo;
  String groupid;
  String typegroup;
  String typeuser;
  String NameGroup;
  late ChatModel users;
  String info;
  late String LastMSG;
  late String time;
  late String createdby;
  late String typeLast;
  groups(this.groupid,this.NameGroup,this.typegroup,this.typeuser,this.info);
}