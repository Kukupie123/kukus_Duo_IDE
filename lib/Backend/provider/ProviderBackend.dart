import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:kukus_multi_user_ide/Backend/WebRTC/DataChannelType.dart';
import 'package:uuid/uuid.dart';

import '../WebRTC/WebRTCService.dart';

class ProviderBackend extends ChangeNotifier {
  String uid = const Uuid().v1(); //Used to identify every Application
  WebRTCService webRTCServices = WebRTCService();

  ProviderBackend() {
    _setupPeer();
  }

  void _setupPeer() async {
    await webRTCServices.asyncConstructor();
    var gdc = webRTCServices.getDataChannel(DataChannelType.GLOBAL);
    var ldc = webRTCServices.getDataChannel(DataChannelType.LOOPBACK);

    //Setup global handler as well as loop back handler
    gdc!.onMessage = (data) async {
      webRTCServices.setDataMsg(DataChannelType.GLOBAL, data);
      await ldc?.send(data);
      print("Global DC : ${data.text}");
      notifyListeners();
    };
    ldc!.onMessage = (data) {
      var decodedResp = json.decode(data.text);
      decodedResp['uid'] = "loop";
      var newData = RTCDataChannelMessage(json.encode(decodedResp));
      webRTCServices.setDataMsg(DataChannelType.GLOBAL,
          newData); //Saving the Message to Global DC NOT Loopback DC
      print("Loopback DC : ${newData.text}");
      notifyListeners();
    };
    notifyListeners();
  }
}
