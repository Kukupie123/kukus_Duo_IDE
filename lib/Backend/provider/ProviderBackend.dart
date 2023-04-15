import 'package:flutter/foundation.dart';
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
    notifyListeners();
  }
}
