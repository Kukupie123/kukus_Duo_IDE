// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:convert';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:kukus_multi_user_ide/Backend/provider/ProviderBackend.dart';

import 'ReqRespAction.dart';

class ReqRespService {
  static Future<void> Order_OpenFile(String encodedFileData, String fileName,
      ProviderBackend providerBackend) async {
    if (providerBackend.webRTCServices.isCaller == false) {
      throw Exception(
          "You are not the Host/Caller. You are not allowed to do 'Order_OpenFile' Request.");
    }
    var map = {
      "uid": providerBackend.uid,
      "action": ReqRespAction.OPEN_FILE.toString(),
      "data": {
        "name": fileName,
        "encodedData": encodedFileData,
      }
    };
    var encodedResp = json.encode(map);
    RTCDataChannel dc = providerBackend.webRTCServices.globalDataChannel!;
    await dc.send(RTCDataChannelMessage(encodedResp));
  }

  static OpenFileModel? Process_OpenFile(String encodedResp) {
    var map = json.decode(encodedResp);
    if (map['action'] == ReqRespAction.OPEN_FILE.toString()) {
      return OpenFileModel(map['data']['name'], map['data']['encodedData']);
    }
    return null;
  }
}

class OpenFileModel {
  String name;
  String encodedData;

  OpenFileModel(this.name, this.encodedData);
}
