import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class AudioCallOneToOne extends StatelessWidget{
  final String CallID;
  final String UserName;
  final String email;
  AudioCallOneToOne(this.CallID, this.UserName,this.email);
  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: 1886800311,
      appSign: "ee536e8a09f9f3b31cf5b33d0ce2416709e45f079f89b7aa023a27a6f0fd8b54",
      userID: email,
      userName: UserName,
      callID: CallID,
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
         ..onOnlySelfInRoom=(context) => Navigator.of(context).pop(),

    );
  }

}