import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/colors.dart';
import '../../utils/api.dart';
import '../../utils/spacer.dart';
import '../../utils/toast.dart';
import '../../widgets/common/joining_details/joining_details.dart';
import '../conference-call/conference_meeting_screen.dart';
import '../one-to-one/one_to_one_meeting_screen.dart';

class JoinScreen extends StatefulWidget {
  final String  id;
   JoinScreen({Key? key , required this.id}) : super(key: key);

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _token = "";

  // Control Status
  bool isMicOn = false;
  bool isCameraOn = false;

  bool  isJoinMeetingSelected=true;
  bool isCreateMeetingSelected=true;

  // Camera Controller
  CameraController? cameraController;

  @override
  void initState() {
    initCameraPreview();
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = await fetchToken(context);
      setState(() => _token = token);
    });
  }

  @override
  setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPopScope,
        child: Scaffold(
          backgroundColor: primaryColor,
          body: SafeArea(
            child: LayoutBuilder(
              builder:
                  (BuildContext context, BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minHeight: viewportConstraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Camera Preview
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 100, horizontal: 36),
                            child: SizedBox(
                              height: 300,
                              width: 200,
                              child: Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  (cameraController == null) && isCameraOn
                                      ? !(cameraController
                                                  ?.value.isInitialized ??
                                              false)
                                          ? Container(
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                            )
                                          : Container(
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                            )
                                      : AspectRatio(
                                          aspectRatio: 1 / 1.55,
                                          child: isCameraOn
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: CameraPreview(
                                                    cameraController!,
                                                  ))
                                              : Container(
                                                  child: const Center(
                                                    child: Text(
                                                      "Camera is turned off",
                                                    ),
                                                  ),
                                                  decoration: BoxDecoration(
                                                      color: black800,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12)),
                                                ),
                                        ),
                                  Positioned(
                                    bottom: 16,

                                    // Meeting ActionBar
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Mic Action Button
                                          ElevatedButton(
                                            onPressed: () => setState(
                                              () => isMicOn = !isMicOn,
                                            ),
                                            child: Icon(
                                                isMicOn
                                                    ? Icons.mic
                                                    : Icons.mic_off,
                                                color: isMicOn
                                                    ? grey
                                                    : Colors.white),
                                            style: ElevatedButton.styleFrom(
                                              shape: const CircleBorder(),
                                              padding: const EdgeInsets.all(12),
                                              primary:
                                                  isMicOn ? Colors.white : red,
                                              onPrimary: Colors.black,
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (isCameraOn) {
                                                cameraController?.dispose();
                                                cameraController = null;
                                              } else {
                                                initCameraPreview();
                                                // cameraController?.resumePreview();
                                              }
                                              setState(() =>
                                                  isCameraOn = !isCameraOn);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              shape: const CircleBorder(),
                                              padding: const EdgeInsets.all(12),
                                              primary: isCameraOn
                                                  ? Colors.white
                                                  : red,
                                            ),
                                            child: Icon(
                                              isCameraOn
                                                  ? Icons.videocam
                                                  : Icons.videocam_off,
                                              color: isCameraOn
                                                  ? grey
                                                  : Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(36.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // if (isJoinMeetingSelected == null &&
                                //     isCreateMeetingSelected == null)
                                //   MaterialButton(
                                //       shape: RoundedRectangleBorder(
                                //           borderRadius:
                                //               BorderRadius.circular(12)),
                                //       padding: const EdgeInsets.symmetric(
                                //           vertical: 16),
                                //       color: purple,
                                //       child: const Text("Create Meeting",
                                //           style: TextStyle(fontSize: 16)),
                                //       onPressed: () => {
                                //             setState(() => {
                                //                   isCreateMeetingSelected =
                                //                       true,
                                //                   isJoinMeetingSelected = true
                                //                 })
                                //           }),
                                // const VerticalSpacer(16),
                                // if (isJoinMeetingSelected == null &&
                                //     isCreateMeetingSelected == null)
                                //   MaterialButton(
                                //       shape: RoundedRectangleBorder(
                                //           borderRadius:
                                //               BorderRadius.circular(12)),
                                //       padding: const EdgeInsets.symmetric(
                                //           vertical: 16),
                                //       color: black750,
                                //       child: const Text("Join Meeting",
                                //           style: TextStyle(fontSize: 16)),
                                //       onPressed: () => {
                                //             setState(() => {
                                //                   isCreateMeetingSelected =
                                //                       false,
                                //                   isJoinMeetingSelected = true
                                //                 })
                                //           }),
                                // if (isJoinMeetingSelected != null &&
                                //     isCreateMeetingSelected != null)
                                  JoiningDetails(
                                    isCreateMeeting: isCreateMeetingSelected!,
                                    onClickMeetingJoin: (meetingId, callType,
                                            displayName) =>
                                        _onClickMeetingJoin(
                                            meetingId, callType, displayName),
                                  ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ));
  }

  Future<bool> _onWillPopScope() async {
    if (isJoinMeetingSelected != null && isCreateMeetingSelected != null) {
      setState(() {
        isJoinMeetingSelected = true;
        isCreateMeetingSelected = true;
      });
      return false;
    } else {
      return true;
    }
  }

  void initCameraPreview() {
    // Get available cameras
    availableCameras().then((availableCameras) {
      // stores selected camera id
      int selectedCameraId = availableCameras.length > 1 ? 1 : 0;

      cameraController = CameraController(
        availableCameras[selectedCameraId],
        ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      log("Starting Camera");
      cameraController!.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    }).catchError((err) {
      log("Error: $err");
    });
  }

  void _onClickMeetingJoin(meetingId, callType, displayName) async {
    cameraController?.dispose();
    cameraController = null;
    if (displayName.toString().isEmpty) {
      displayName = "Guest";
    }
    if (isCreateMeetingSelected!) {
      createAndJoinMeeting(callType, displayName);
    } else {

      joinMeeting(callType, displayName, meetingId);
    }
  }

  Future<void> createAndJoinMeeting(callType, displayName) async {
    try {
      var _meetingID = await createMeeting(_token);
      String docs="${DateTime.now().toString()}-${_auth.currentUser?.email}";
      await _firestore.collection('MassegeGroup').doc(docs).set({
        'GroupID':widget.id,
        'Msg':_meetingID,
        'assigmentid':'',
        'name':_auth.currentUser?.displayName,
        'sender':_auth.currentUser?.email,
        'type':'meeting',
        'time':'start'
      });
      await _firestore.collection("Groups").where('GroupID',isEqualTo: widget.id).get().then((value){
        for(int i=0;i<value.size;i++){
          String email=value.docs[i].get("User");
          final idd = DateTime.now().toString();
          final ids = '$idd-${email}';
          final ref = _firestore.collection('MassegeGroup');
          final doc = ref
              .doc(docs)
              .collection('users')
              .doc(ids)
              .set({'email': email, 'seen': 'false', 'delete': 'false', 'time': ''});
        }
      });
      if (callType == "GROUP") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ConfereneceMeetingScreen(
                  token: _token,
                  meetingId: _meetingID,
                  displayName: displayName,
                  micEnabled: isMicOn,
                  camEnabled: isCameraOn,
                ),
          ),
        );
      }
    }catch (error) {
      showSnackBarMessage(message: error.toString(), context: context);
    }
  }

  Future<void> joinMeeting(callType, displayName, meetingId) async {
    if (meetingId.isEmpty) {
      showSnackBarMessage(
          message: "Please enter Valid Meeting ID", context: context);
      return;
    }
    var validMeeting = await validateMeeting(_token, meetingId);
    if (validMeeting) {
      if (callType == "GROUP") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfereneceMeetingScreen(
              token: _token,
              meetingId: meetingId,
              displayName: displayName,
              micEnabled: isMicOn,
              camEnabled: isCameraOn,
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OneToOneMeetingScreen(
              token: _token,
              meetingId: meetingId,
              displayName: displayName,
              micEnabled: isMicOn,
              camEnabled: isCameraOn,
            ),
          ),
        );
      }
    } else {
      showSnackBarMessage(message: "Invalid Meeting ID", context: context);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }
}
