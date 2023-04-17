import 'dart:convert';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:kukus_multi_user_ide/Backend/WebRTC/DataChannelType.dart';

class WebRTCService {
  RTCPeerConnection? peerConnection;
  bool isCaller = false;
  String meteredTurnAPIKey =
      "https://kukukode.metered.live/api/v1/turn/credentials?apiKey=9a5291dbc60a034b7a899a94ee60f2e02453";

  Map<String, RTCDataChannel> _dataChannels = {};

  Future<void> asyncConstructor() async {
    await _createPeer();
  }

  Future<void> _createPeer() async {
    Map<String, dynamic> config =
        await _createPeerConfig(); //Create config for peer
    final Map<String, dynamic> sDPConstraints = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": true,
      },
      "optional": [],
    };
    peerConnection = await createPeerConnection(
        config, sDPConstraints); //Create peer connection
    await addDataChannel(DataChannelType.GLOBAL, 0); //Add global Data channel
    await addDataChannel(
        DataChannelType.LOOPBACK, 1); //Add loopback data channel

    //Add loopback listener for global DC. We do this because we need the caller to also get back the data it sends to callee
    var gdc = _dataChannels[DataChannelType.GLOBAL];
    var ldc = _dataChannels[DataChannelType.LOOPBACK];
    gdc?.onMessage = (data) async => await ldc?.send(data);
  }

  Future<Map<String, dynamic>> _createPeerConfig() async {
    List? turnServerResp = await _getDataFromTurnServer();
    Map<String, dynamic> config = {"iceServers": turnServerResp};
    return config;
  }

  Future<List<dynamic>?> _getDataFromTurnServer() async {
    http.Response resp = await http.get(Uri.parse(meteredTurnAPIKey));
    if (resp.statusCode != 200) return null;
    List<dynamic> decodedResp = jsonDecode(resp.body);
    return decodedResp;
  }

  Future<String?> createOffer() async {
    RTCSessionDescription? offer =
        await peerConnection?.createOffer({"offerToReceiveVideo": 1});
    var encodedOffer = json.encode(offer?.sdp.toString());
    await peerConnection?.setLocalDescription(offer!);
    isCaller = true;
    return encodedOffer;
  }

  Future<String?> createAnswer() async {
    RTCSessionDescription? ans =
        await peerConnection?.createAnswer({"offerToReceiveVideo": 1});
    var encodedAns = json.encode(ans?.sdp.toString());
    await peerConnection?.setLocalDescription(ans!);
    return encodedAns;
  }

  Future<String?> setRemoteSDP(String jsonSDP) async {
    var decodedSDP = jsonDecode(jsonSDP);
    RTCSessionDescription sdp =
        RTCSessionDescription(decodedSDP, isCaller ? "answer" : "offer");
    //var encodedJSON = json.encode(sdp.sdp.toString());
    await peerConnection?.setRemoteDescription(sdp);

    if (!isCaller) {
      var answerSDP = await createAnswer();
      return answerSDP;
    }
    return null;
  }

  Future<void> addCandidate(String jsonString) async {
    dynamic session = await jsonDecode(jsonString);
    dynamic candidate = RTCIceCandidate(
        session['candidate'], session['sdpMid'], session['sdpMlineIndex']);
    await peerConnection?.addCandidate(candidate);
  }

  RTCDataChannel? getDataChannel(DataChannelType type) {
    return _dataChannels[type.toString()];
  }

  Future<void> addDataChannel(DataChannelType dataChannelType, int id) async {
    var d = RTCDataChannelInit();
    d.id = id;
    d.ordered = true;
    d.negotiated =
        true; //THIS WAS THE ISSUE!!!! THIS WAS CAUSING THE MESSAGE TO NOT BE DELIVERED
    RTCDataChannel? dc =
        await peerConnection?.createDataChannel(dataChannelType.toString(), d);
    if (dc == null) {
      throw Exception(
          "Creating DataChannel of type ${dataChannelType.toString()} failed");
    }
    _dataChannels[dataChannelType.toString()] = dc;
    var gdc = _dataChannels[dataChannelType.toString()];
    if (gdc == null) {
      throw Exception(
          "Creating DataChannel of type ${dataChannelType.toString()} failed cuz GDC is null");
    }
  }

  Future<void> closeDataChannel(DataChannelType type) async {
    if (_dataChannels.containsKey(type)) return;
    var dc = _dataChannels[type];
    await dc?.close();
  }
}
