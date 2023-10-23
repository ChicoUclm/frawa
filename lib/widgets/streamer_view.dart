import 'dart:developer';

import 'package:excursiona/controllers/hls_controller.dart';
import 'package:excursiona/enums/hls_states.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/widgets/participant_streaming_tile.dart';
import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';

class StreamerView extends StatefulWidget {
  final Room room;
  const StreamerView(this.room, {super.key});

  @override
  State<StreamerView> createState() => _StreamerViewState();
}

class _StreamerViewState extends State<StreamerView> {
  bool micEnabled = true;
  bool camEnabled = true;
  var hlsState = HLS.stopped;
  Map<String, Participant> participants = {};

  @override
  void initState() {
    setMeetingEventListener();
    participants.putIfAbsent(
        widget.room.localParticipant.id, () => widget.room.localParticipant);
    for (var participant in widget.room.participants.values) {
      if (participant.mode == Mode.CONFERENCE) {
        participants.putIfAbsent(participant.id, () => participant);
      }
    }
    hlsState = HLS.fromString(widget.room.hlsState);
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void setMeetingEventListener() {
    widget.room.on(
      Events.participantJoined,
      (Participant participant) {
        if (participant.mode == Mode.CONFERENCE) {
          setState(
            () => participants.putIfAbsent(participant.id, () => participant),
          );
        }
      },
    );

    widget.room.on(Events.participantLeft, (String participantId) {
      if (participants.containsKey(participantId)) {
        setState(
          () => participants.remove(participantId),
        );
      }
    });
    widget.room.on(
      Events.hlsStateChanged,
      (Map<String, dynamic> data) {
        setState(
          () => hlsState = HLS.fromString(data['status']),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ParticipantStreamingTile(
              participant: participants.values.elementAt(0),
            ),
          ),
        ),
        Flexible(
            flex: 1,
            fit: FlexFit.loose,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: hlsButtonHandler())),
      ],
    );
  }

  Widget hlsButtonHandler() {
    switch (hlsState) {
      case HLS.stopped:
        return ElevatedButton(
          onPressed: () {
            // var config = {

            // };
            widget.room.startHls();
            HLSController().setActiveStreamingRoom(widget.room.id);
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              fixedSize: Size(MediaQuery.of(context).size.width, 50)),
          child: const Text(
            'Comenzar retransmisión',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        );
      case HLS.playable:
        return ElevatedButton(
            onPressed: () {
              widget.room.stopHls();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Constants.redColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                fixedSize: Size(MediaQuery.of(context).size.width, 50)),
            child: const Text(
              'Finalizar retransmisión',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ));
      default:
        return ElevatedButton(
          onPressed: () {
            log(hlsState.toString());
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              fixedSize: Size(MediaQuery.of(context).size.width, 50)),
          child: const CircularProgressIndicator(
            color: Colors.white,
          ),
        );
    }
  }
}
