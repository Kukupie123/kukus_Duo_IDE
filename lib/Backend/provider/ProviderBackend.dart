import 'package:flutter/foundation.dart';
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
      webRTCServices.dataMsgs[DataChannelType.GLOBAL.toString()] = data;
      await ldc?.send(data);
      notifyListeners();
    };
    ldc!.onMessage = (data) {
      webRTCServices.dataMsgs[DataChannelType.LOOPBACK.toString()] = data;
      notifyListeners();
    };
    notifyListeners();
  }
}
