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
  RTCDataChannel? globalDataChannel;

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
    await addDataChannel(DataChannelType.GLOBAL);
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
    var encodedJSON = json.encode(sdp.sdp.toString());
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

  Future<void> addDataChannel(DataChannelType type) async {
    var d = RTCDataChannelInit();
    d.ordered = true;
    RTCDataChannel? dc =
        await peerConnection?.createDataChannel(type.toString(), d);
    if (dc == null) {
      throw Exception("Creating DataChannel of type ${type.toString()} failed");
    }
    _dataChannels[type.toString()] = dc;
    globalDataChannel = dc;

    globalDataChannel?.onMessage = (data) {
      print("Msg on DC ${type.toString()} : ${data.text}");
    };
    globalDataChannel?.onDataChannelState = (state) {
      print("DC State Changed to : ${state.toString()}");

      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        globalDataChannel?.send(RTCDataChannelMessage("DUMMY TEST"));
      }
    };
  }

  Future<void> closeDataChannel(DataChannelType type) async {
    if (_dataChannels.containsKey(type)) return;
    var dc = _dataChannels[type];

    await dc?.close();
  }
}
