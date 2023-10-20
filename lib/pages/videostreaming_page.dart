import 'package:excursiona/controllers/excursion_controller.dart';
import 'package:excursiona/widgets/loader.dart';
import 'package:excursiona/widgets/streamer_view.dart';
import 'package:excursiona/widgets/viewer_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:videosdk/videosdk.dart';

class VideoStreamingPage extends StatefulWidget {
  final String roomId;
  final String token;
  final Mode mode;
  final ExcursionController excursionController;
  const VideoStreamingPage(
      {super.key,
      required this.roomId,
      required this.token,
      required this.mode,
      required this.excursionController});

  @override
  State<VideoStreamingPage> createState() => _VideoStreamingPageState();
}

class _VideoStreamingPageState extends State<VideoStreamingPage> {
  late Room _room;
  bool _isJoined = false;

  @override
  void initState() {
    _room = VideoSDK.createRoom(
        roomId: widget.roomId,
        displayName: 'Directo',
        token: widget.token,
        mode: widget.mode);

    setMeetingEventListener();
    _room.join();
    super.initState();
  }

  // _closeStreaming() async {
  //   try {
  //     await widget.excursionController.deleteStreamingRoom(widget.roomId);
  //     _room.leave();
  //   } catch (e) {
  //     showSnackBar(context, Colors.red,
  //         'Hubo un error al parar la retransmisión: ${e.toString()}');
  //   }
  // }

  void setMeetingEventListener() {
    _room.on(Events.roomJoined, () {
      if (widget.mode == Mode.CONFERENCE) {
        _room.localParticipant.pin();
      }
      setState(() {
        _isJoined = true;
      });
    });

    _room.on(Events.roomLeft, () async {
      if (widget.mode == Mode.CONFERENCE) {
        await widget.excursionController.deleteStreamingRoom(widget.roomId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Panel de retransmisión",
          style: GoogleFonts.inter(),
        ),
        foregroundColor: Colors.black,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isJoined
          ? widget.mode == Mode.CONFERENCE
              ? StreamerView(_room)
              : ViewerView(_room)
          : const Loader(),
    );
  }
}
