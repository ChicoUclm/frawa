import 'package:cached_network_image/cached_network_image.dart';
import 'package:excursiona/controllers/excursion_controller.dart';
import 'package:excursiona/controllers/user_controller.dart';
import 'package:excursiona/model/excursion.dart';
import 'package:excursiona/model/livestreaming_room.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/view/videostreaming_page.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/view/widgets/account_avatar.dart';
import 'package:excursiona/view/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:videosdk/videosdk.dart';

class StreamingRoomTile extends StatefulWidget {
  final LiveStreamingRoom room;
  final bool detailed;
  const StreamingRoomTile(this.room, {super.key, this.detailed = false});

  @override
  State<StreamingRoomTile> createState() => _StreamingRoomTileState();
}

class _StreamingRoomTileState extends State<StreamingRoomTile> {
  late UserModel userInfo;
  bool _hasLoaded = false;
  Excursion? excursion;

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  _loadData() async {
    try {
      var userModel =
          await UserController().getUserDataById(widget.room.userId);
      setState(() {
        userInfo = userModel;
      });
    } on Exception catch (e) {
      showSnackBar(context, Colors.red, e.toString());
    }
    if (widget.detailed) {
      var excursion =
          await ExcursionController().getExcursionById(widget.room.excursionId);
      setState(() {
        this.excursion = excursion;
      });
    }
    setState(() {
      _hasLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return !_hasLoaded
        ? Container()
        : widget.detailed
            ? _detailedTile()
            : _compactTile();
  }

  Widget _detailedTile() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
          border: Constants.border,
          boxShadow: Constants.boxShadow,
          color: Constants.darkWhite,
          borderRadius: BorderRadius.circular(15.0)),
      child: ListTile(
        leading: userInfo.profilePic == ''
            ? CircleAvatar(
                foregroundColor: Colors.grey,
                backgroundColor: Colors.transparent,
                radius: 25,
                child: AccountAvatar(radius: 30, name: userInfo.name))
            : CircleAvatar(
                radius: 25,
                backgroundColor: Colors.transparent,
                child: CachedNetworkImage(
                  imageUrl: userInfo.profilePic,
                  placeholder: (context, url) => const Loader(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  placeholderFadeInDuration: const Duration(milliseconds: 300),
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
          onPressed: () => nextScreen(
              context,
              VideoStreamingPage(
                roomId: widget.room.roomId,
                token: Constants.tempStreamingToken,
                mode: Mode.VIEWER,
              ),
              PageTransitionType.rightToLeft),
        ),
        title: Text(
          userInfo.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          excursion!.title,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _compactTile() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
          border: Constants.border,
          boxShadow: Constants.boxShadow,
          color: Constants.darkWhite,
          borderRadius: BorderRadius.circular(15.0)),
      child: ListTile(
        leading: userInfo.profilePic == ''
            ? CircleAvatar(
                foregroundColor: Colors.grey,
                backgroundColor: Colors.transparent,
                radius: 25,
                child: AccountAvatar(radius: 30, name: userInfo.name))
            : CircleAvatar(
                radius: 25,
                backgroundColor: Colors.transparent,
                child: CachedNetworkImage(
                  imageUrl: userInfo.profilePic,
                  placeholder: (context, url) => const Loader(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  placeholderFadeInDuration: const Duration(milliseconds: 300),
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
      ),
    );
  }
}
