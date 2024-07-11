import 'package:flutter/material.dart';

import 'package:videosdk/videosdk.dart';

import 'package:excursiona/enums/hls_states.dart';

import 'package:excursiona/view/widgets/livestream_player.dart';

class ViewerView extends StatefulWidget {
  final Room room;
  const ViewerView(this.room, {super.key});

  @override
  State<ViewerView> createState() => _ViewerViewState();
}

class _ViewerViewState extends State<ViewerView> {
  HLS hlsState = HLS.stopped;
  String? downstreamUrl;

  @override
  void initState() {
    super.initState();
    hlsState = HLS.fromString(widget.room.hlsState);
    downstreamUrl = widget.room.hlsDownstreamUrl;
    setMeetingEventListener();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      // mainAxisSize: MainAxisSize.max,
      children: [
        downstreamUrl != null
            ? LivestreamPlayer(downstreamUrl: downstreamUrl!)
            : const Center(
                child: Text(
                  "La retransmisión no está disponible",
                ),
              ),
      ],
    );
  }

  void setMeetingEventListener() {
    widget.room.on(
      Events.hlsStateChanged,
      (Map<String, dynamic> data) {
        var status = HLS.fromString(data['status']);
        if (mounted) {
          setState(() {
            hlsState = status;
            if (status == HLS.playable || status == HLS.stopped) {
              downstreamUrl = data['downstreamUrl'];
            }
          });
        }
      },
    );
  }
}
