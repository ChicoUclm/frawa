import 'package:excursiona/controllers/excursion_controller.dart';
import 'package:excursiona/controllers/hls_controller.dart';
import 'package:excursiona/view/states/streamingroom_provider.dart';
import 'package:excursiona/view/videostreaming_page.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/view/widgets/loader.dart';
import 'package:excursiona/view/widgets/streaming_room_tile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
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
  }

  _createVideoStreaming() async {
    try {
      final roomId =
          await HLSController(excursionController: widget.excursionController)
              .createRoom();
      nextScreenReplace(
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
        backgroundColor: Constants.darkWhite,
        elevation: 0,
      ),
      backgroundColor: Constants.darkWhite,
      body: Consumer<StreamingRoomProvider>(
        builder: (context, value, child) {
          var activeRoom = value.room;
          return Column(children: [
            if (activeRoom != null)
              Container(
                // color: Colors.grey[200],
                color: Constants.indigoDye,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tienes una retransmisión activa',
                          style: TextStyle(color: Colors.white)),
                      IconButton(
                        onPressed: () {
                          nextScreenReplace(
                              context,
                              VideoStreamingPage(
                                activeRoom: activeRoom,
                                token: Constants.tempStreamingToken,
                                excursionController: widget.excursionController,
                                mode: Mode.CONFERENCE,
                              ),
                              PageTransitionType.fade);
                        },
                        icon: const Icon(Icons.arrow_forward_ios_rounded),
                        color: Colors.white,
                        iconSize: 22,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: FutureBuilder(
                  future: widget.excursionController.getStreamingRooms(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data!.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 26.0),
                              child: Center(
                                child: Text(
                                  'No hay ninguna retransmisión en directo',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: snapshot.data!.length,
                              padding: const EdgeInsets.all(8.0),
                              itemBuilder: (context, index) {
                                var room = snapshot.data![index];
                                return StreamingRoomTile(room);
                              });
                    } else {
                      return const Loader();
                    }
                  }),
            ),
          ]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Constants.indigoDye,
        onPressed: _createVideoStreaming,
        child: const Icon(Icons.video_call_rounded),
      ),
    );
  }
}
