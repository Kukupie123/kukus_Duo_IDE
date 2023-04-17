// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:convert';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:kukus_multi_user_ide/Backend/WebRTC/DataChannelType.dart';
import 'package:kukus_multi_user_ide/Backend/provider/ProviderBackend.dart';

import 'ReqRespAction.dart';

class ReqRespService {
  static Future<void> Order_OpenFile(String encodedFileData, String fileName,
      ProviderBackend providerBackend) async {
    var map = {
      "uid": providerBackend.uid,
      "action": ReqRespAction.OPEN_FILE.toString(),
      "data": {
        "name": fileName,
        "encodedData": encodedFileData,
      }
    };
    var encodedResp = json.encode(map);
    RTCDataChannel dc =
        providerBackend.webRTCServices.getDataChannel(DataChannelType.GLOBAL)!;
    await dc.send(RTCDataChannelMessage(encodedResp));
  }

  static Future<OpenFileModel?> Process_OpenFileRequest(
      String encodedResp, ProviderBackend providerBackend) async {
    var map = json.decode(encodedResp);
    if (map['action'] == ReqRespAction.OPEN_FILE.toString()) {
      //Check if we are a caller or callee. If callee, loopback the data to caller as in webRTC p2p a msg can only be sent and received so a msg sent by caller will be sent to ONLY the callee and not the caller. So we setup a loop back data channel
      var fileModel =
          OpenFileModel(map['data']['name'], map['data']['encodedData']);
      return fileModel;
    }
    return null;
  }
}

class OpenFileModel {
  String name;
  String encodedData;

  OpenFileModel(this.name, this.encodedData);
}
