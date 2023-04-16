import 'package:flutter_webrtc/flutter_webrtc.dart';

class GlobalDataChannelService {
  static void SetupGlobalDCEvents(RTCDataChannel dataChannel) {
    //Use ReqRespModel for creating response/request model
    dataChannel.onMessage = (RTCDataChannelMessage msg) {};
  }
}
