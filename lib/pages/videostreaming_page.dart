import 'package:excursiona/controllers/excursion_controller.dart';
import 'package:excursiona/enums/hls_states.dart';
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
  final ExcursionController? excursionController;
  const VideoStreamingPage({
    super.key,
    required this.roomId,
    required this.token,
    required this.mode,
    this.excursionController,
  });

  @override
  State<VideoStreamingPage> createState() => _VideoStreamingPageState();
}

class _VideoStreamingPageState extends State<VideoStreamingPage> {
  late Room _room;
  bool _isJoined = false;

  @override
  void initState() {
    widget.mode == Mode.CONFERENCE
        ? _room = VideoSDK.createRoom(
            roomId: widget.roomId,
            displayName: 'Streamer',
            token: widget.token,
            mode: widget.mode,
            defaultCameraIndex: 0,
            micEnabled: true,
          )
        : _room = VideoSDK.createRoom(
            roomId: widget.roomId,
            displayName: 'Viewer',
            token: widget.token,
            mode: widget.mode,
            micEnabled: false,
            camEnabled: false);

    setMeetingEventListener();
    _room.join();
    super.initState();
  }

  @override
  void dispose() {
    if (HLS.fromString(_room.hlsState) == HLS.stopped ||
        widget.mode == Mode.VIEWER) {
      _room.leave();
    }
    super.dispose();
  }

  void setMeetingEventListener() {
    _room.on(Events.roomJoined, () {
      if (widget.mode == Mode.CONFERENCE) {
        _room.localParticipant.pin();
      }
      setState(() {
        _isJoined = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Sala de retransmisión",
          style: GoogleFonts.inter(),
        ),
        foregroundColor: Colors.black,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isJoined
          ? widget.mode == Mode.CONFERENCE
              ? StreamerView(_room,
                  excursionController: widget.excursionController!)
              : ViewerView(_room)
          : const Loader(),
    );
  }
}
