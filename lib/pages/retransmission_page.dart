import 'package:excursiona/controllers/excursion_controller.dart';
import 'package:excursiona/controllers/hls_controller.dart';
import 'package:excursiona/pages/videostreaming_page.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:videosdk/videosdk.dart';

class RetransmissionsPage extends StatefulWidget {
  const RetransmissionsPage({super.key, required this.excursionController});

  final ExcursionController excursionController;

  @override
  State<RetransmissionsPage> createState() => _RetransmissionsPageState();
}

class _RetransmissionsPageState extends State<RetransmissionsPage> {
  String? roomId;

  @override
  void initState() {
    super.initState();
    _checkActiveStreamingRoom();
  }

  _createVideoStreaming() async {
    try {
      final roomId =
          await HLSController(excursionController: widget.excursionController)
              .createRoom();
      nextScreen(
          context,
          VideoStreamingPage(
              roomId: roomId,
              token: Constants.tempStreamingToken,
              mode: Mode.CONFERENCE,
              excursionController: widget.excursionController),
          PageTransitionType.fade);
    } on Exception catch (e) {
      print(e.toString());
      showSnackBar(context, Colors.red, e.toString());
    }
  }

  void _checkActiveStreamingRoom() async {
    var roomId = await HLSController().getActiveStreamingRoom();
    setState(() {
      this.roomId = roomId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Retransmisiones",
          style: GoogleFonts.inter(),
        ),
        foregroundColor: Colors.black,
        backgroundColor: Constants.darkWhite,
        elevation: 0,
      ),
      backgroundColor: Constants.darkWhite,
      body: Column(children: [
        if (roomId != null)
          Container(
            // color: Colors.grey[200],
            color: Constants.indigoDye,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tienes una retransmisión activa',
                      style: TextStyle(color: Colors.white)),
                  IconButton(
                    onPressed: () {
                      nextScreen(
                          context,
                          VideoStreamingPage(
                              roomId: roomId!,
                              token: Constants.tempStreamingToken,
                              mode: Mode.CONFERENCE,
                              excursionController: widget.excursionController),
                          PageTransitionType.fade);
                    },
                    icon: const Icon(Icons.arrow_forward_ios_rounded),
                    color: Colors.white,
                    iconSize: 22,
                  ),
                ],
              ),
            ),
          )
      ]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Constants.indigoDye,
        onPressed: _createVideoStreaming,
        child: const Icon(Icons.video_call_rounded),
      ),
    );
  }
}
