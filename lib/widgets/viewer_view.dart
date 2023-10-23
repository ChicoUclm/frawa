import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';

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
