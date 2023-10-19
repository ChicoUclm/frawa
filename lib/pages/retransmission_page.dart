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
  final ExcursionController excursionController;
  const RetransmissionsPage({super.key, required this.excursionController});

  @override
  State<RetransmissionsPage> createState() => _RetransmissionsPageState();
}

class _RetransmissionsPageState extends State<RetransmissionsPage> {
  _createVideoStreaming() async {
    try {
      final roomId =
          await HLSController(widget.excursionController).createRoom();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Retransmisiones",
          style: GoogleFonts.inter(),
        ),
        foregroundColor: Colors.black,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Constants.indigoDye,
        onPressed: _createVideoStreaming,
        child: const Icon(Icons.video_call_rounded),
      ),
    );
  }
}
