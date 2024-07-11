import 'package:flutter/material.dart';

import 'package:videosdk/videosdk.dart';

class ParticipantStreamingTile extends StatefulWidget {
  final Participant participant;
  const ParticipantStreamingTile({super.key, required this.participant});

  @override
  State<ParticipantStreamingTile> createState() =>
      _ParticipantStreamingTileState();
}

class _ParticipantStreamingTileState extends State<ParticipantStreamingTile> {
  Stream? videoStream;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    // initialze video stream for the participant if they are present
    widget.participant.streams.forEach((key, Stream stream) {
      setState(() {
        if (stream.kind == 'video') {
          videoStream = stream;
        }
      });
    });
    _initStreamListeners();
    super.initState();
  }

  //Event listener for the video stream of the participant
  _initStreamListeners() {
    widget.participant.on(Events.streamEnabled, (Stream stream) {
      if (stream.kind == 'video') {
        setState(() => videoStream = stream);
      }
    });

    widget.participant.on(Events.streamDisabled, (Stream stream) {
      if (stream.kind == 'video') {
        setState(() => videoStream = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: videoStream != null
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              child: RTCVideoView(
                videoStream?.renderer as RTCVideoRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            )
          : Container(
              color: Colors.grey,
              child: const Center(
                child: Icon(
                  Icons.person,
                  size: 100,
                ),
              ),
            ),
    );
  }
}
