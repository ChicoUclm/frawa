import 'dart:convert';
import 'package:excursiona/shared/constants.dart';
import 'package:http/http.dart' as http;

class HLSService {
  Future<String> createRoom() async {
    final http.Response httpResponse = await http.post(
      Uri.parse("https://api.videosdk.live/v2/rooms"),
      headers: {'Authorization': Constants.tempStreamingToken},
    );

    if (httpResponse.statusCode == 200) {
      return json.decode(httpResponse.body)['roomId'];
    } else {
      throw Exception(httpResponse.reasonPhrase);
    }
  }
}
