// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sized_box_for_whitespace

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:kukus_multi_user_ide/Backend/provider/ProviderBackend.dart';
import 'package:provider/provider.dart';

import '../../Backend/WebRTC/DataChannelType.dart';

class PageCreatePeer extends StatefulWidget {
  const PageCreatePeer({Key? key}) : super(key: key);

  @override
  State<PageCreatePeer> createState() => _PageCreatePeerState();
}

class _PageCreatePeerState extends State<PageCreatePeer> {
  var offerGeneratedTC = TextEditingController();
  var remoteSDPTC = TextEditingController();
  var candidateTC = TextEditingController();

  @override
  void initState() {
    super.initState();
    ProviderBackend providerBackend =
        Provider.of<ProviderBackend>(context, listen: false);
    providerBackend.webRTCServices.peerConnection?.onIceConnectionState =
        (state) async {
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected ||
          state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
        statusSC.add("Successfully Connected");
        await providerBackend.webRTCServices
            .addDataChannel(DataChannelType.GLOBAL);
      }
    };
    pasteOfferToTextField(providerBackend);
  }

  StreamController<String> statusSC = StreamController();

  @override
  Widget build(BuildContext context) {
    ProviderBackend providerBackend =
        Provider.of<ProviderBackend>(context, listen: false);

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: StreamBuilder<String>(
            stream: statusSC.stream,
            builder: (context, snapshot) {
              String? data = snapshot.data;
              return Column(
                children: [
                  Text(data == null ? "Idle" : snapshot.data!),
                  TextField(
                    controller: offerGeneratedTC,
                    decoration: InputDecoration(
                        hintText: "Generating Offer Please wait...."),
                  ),
                  Text(
                      "Copy the Generated Code above and paste it as the Remote Description in the Client that is trying to join"),
                  TextField(
                    controller: remoteSDPTC,
                    decoration: InputDecoration(
                        hintText:
                            "Paste Generated Answer of the Client trying to join...."),
                  ),
                  TextButton(
                      onPressed: () async {
                        if (remoteSDPTC.text.isEmpty) {
                          statusSC.add("Textfield is empty");
                          return;
                        }
                        statusSC.add("Setting Remote SDP");
                        await providerBackend.webRTCServices
                            .setRemoteSDP(remoteSDPTC.text);
                        statusSC.add(
                            "Setting Remote SDP Complete. Copy any Candidate from Joining Client and paste it below");
                      },
                      child: Text("Set Remote Description")),
                  TextField(
                    controller: candidateTC,
                    decoration: InputDecoration(
                        hintText:
                            "Paste Copied Candidate of the Client trying to join...."),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (candidateTC.text.isEmpty) {
                        statusSC.add("Textfield is empty");
                        return;
                      }
                      statusSC.add("Adding Candidate");
                      await providerBackend.webRTCServices
                          .addCandidate(candidateTC.text);
                      statusSC.add("Adding Candidate Complete.");
                    },
                    child: Text("Confirm Candidate"),
                  ),
                ],
              );
            }),
      ),
    );
  }

  void pasteOfferToTextField(ProviderBackend providerBackend) async {
    statusSC.add("Loading Offer");
    String? offerSDP = await providerBackend.webRTCServices.createOffer();
    setState(() {
      offerGeneratedTC.text = offerSDP!;
    });
    statusSC.add("Generated Offer");
  }
}
