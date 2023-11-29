import 'package:excursiona/controllers/excursion_controller.dart';
import 'package:excursiona/services/hls_service.dart';

class HLSController {
  final ExcursionController? excursionController;
  final HLSService _hlsService = HLSService();

  HLSController({this.excursionController});
  Future<String> createRoom() async {
    try {
      final String roomId = await _hlsService.createRoom();
      return roomId;
    } catch (e) {
      throw Exception(
          'Hubo un error al crear la retransmisión: ${e.toString()}');
    }
  }
}
