import 'package:cached_network_image/cached_network_image.dart';
import 'package:excursiona/controllers/excursion_controller.dart';
import 'package:excursiona/controllers/hls_controller.dart';
import 'package:excursiona/controllers/user_controller.dart';
import 'package:excursiona/model/livestreaming_room.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/pages/videostreaming_page.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/widgets/account_avatar.dart';
import 'package:excursiona/widgets/loader.dart';
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
                      nextScreenReplace(
                          context,
                          VideoStreamingPage(
                            roomId: roomId!,
                            token: Constants.tempStreamingToken,
                            mode: Mode.CONFERENCE,
                            excursionController: widget.excursionController,
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
                              'No hay ninguna retransmisión en directo ahora mismo',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            var room = snapshot.data![index];
                            return StreamingRoomTile(room);
                          });
                } else {
                  return const Loader();
                }
              }),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Constants.indigoDye,
        onPressed: _createVideoStreaming,
        child: const Icon(Icons.video_call_rounded),
      ),
    );
  }
}

class StreamingRoomTile extends StatefulWidget {
  final LiveStreamingRoom room;
  const StreamingRoomTile(this.room, {super.key});

  @override
  State<StreamingRoomTile> createState() => _StreamingRoomTileState();
}

class _StreamingRoomTileState extends State<StreamingRoomTile> {
  late UserModel userInfo;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    UserController().getUserDataById(widget.room.userId).then((userModel) {
      setState(() {
        userInfo = userModel;
        _hasLoaded = true;
      });
    }).catchError((e) {
      showSnackBar(context, Colors.red, e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return !_hasLoaded
        ? Container()
        : ListTile(
            leading: userInfo.profilePic == ''
                ? CircleAvatar(
                    foregroundColor: Colors.grey,
                    backgroundColor: Colors.transparent,
                    radius: 30,
                    child: AccountAvatar(radius: 30, name: userInfo.name))
                : CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.transparent,
                    child: CachedNetworkImage(
                      imageUrl: userInfo.profilePic,
                      placeholder: (context, url) => const Loader(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                      placeholderFadeInDuration:
                          const Duration(milliseconds: 300),
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
            trailing: IconButton(
              icon: const Icon(Icons.play_arrow_rounded),
              onPressed: () => nextScreenReplace(
                  context,
                  VideoStreamingPage(
                    roomId: widget.room.roomId,
                    token: Constants.tempStreamingToken,
                    mode: Mode.VIEWER,
                  ),
                  PageTransitionType.rightToLeft),
            ),
            title: Text(userInfo.name),
          );
  }
}
