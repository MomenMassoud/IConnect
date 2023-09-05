import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallPage extends StatelessWidget{
  final String CallID;
  final String UserName;
  final String email;
  const CallPage({Key? key, required this.CallID,required this.UserName,required this.email}) : super(key: key);
  @override
  Widget build(BuildContext context) {
  //   return Scaffold();
  // }
    return ZegoUIKitPrebuiltCall(
        appID: 1886800311,
        appSign: "ee536e8a09f9f3b31cf5b33d0ce2416709e45f079f89b7aa023a27a6f0fd8b54",
        userID: email,
        userName: UserName,
        callID: CallID,
        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
          ..onOnlySelfInRoom=(context) => Navigator.of(context).pop(),
    );
  }

}