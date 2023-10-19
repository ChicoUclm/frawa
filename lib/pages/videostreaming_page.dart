import 'package:excursiona/controllers/excursion_controller.dart';
import 'package:excursiona/widgets/loader.dart';
import 'package:flutter/material.dart';
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
      body: _isJoined
          ? widget.mode == Mode.CONFERENCE
              ? StreamerView(_room)
              : ViewerView(_room)
          : const Loader(),
    );
  }
}

class StreamerView extends StatefulWidget {
  final Room room;
  const StreamerView(this.room, {super.key});

  @override
  State<StreamerView> createState() => _StreamerViewState();
}

class _StreamerViewState extends State<StreamerView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
            onPressed: () => widget.room.leave(), child: const Text('Terminar'))
      ],
    );
  }
}

class ViewerView extends StatefulWidget {
  final Room room;
  const ViewerView(this.room, {super.key});

  @override
  State<ViewerView> createState() => _ViewerViewState();
}

class _ViewerViewState extends State<ViewerView> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
