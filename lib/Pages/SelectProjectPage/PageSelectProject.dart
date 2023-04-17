// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:kukus_multi_user_ide/Backend/WebRTC/DataChannelType.dart';
import 'package:kukus_multi_user_ide/Backend/WebRTC/WebRTCService.dart';
import 'package:kukus_multi_user_ide/Backend/provider/ProviderBackend.dart';
import 'package:kukus_multi_user_ide/Backend/util/ReqRespService.dart';
import 'package:provider/provider.dart';

class PageSelectProject extends StatefulWidget {
  const PageSelectProject({Key? key}) : super(key: key);

  @override
  State<PageSelectProject> createState() => _PageSelectProjectState();
}

class _PageSelectProjectState extends State<PageSelectProject> {
  RTCDataChannel? globalDC;
  ProviderBackend? providerBackend;
  OpenFileModel? openFileModel;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (providerBackend == null) {
      initialSetup(context);
    }
    return Scaffold(
      body: Container(
          height: double.infinity,
          width: double.infinity,
          child: widgetDecider(Navigator.of(context))),
    );
  }

  Widget widgetDecider(NavigatorState navigatorState) {
    return Consumer<ProviderBackend>(
        builder: (context, value, child) {
          //Check if we have valid RTCMessage in dataMsgs map variable
          var dcMsg = value.webRTCServices.getDataMsg(DataChannelType.GLOBAL);
          if (dcMsg == null) {
            print("Data Msg of Global DC is null");
            return child!;
          }
          return Text(dcMsg.text);
        },
        child: _childDecider(navigatorState));
  }

  Widget _childDecider(NavigatorState navigatorState) {
    if (providerBackend == null) return Text("Provider Backend is null");
    if (providerBackend?.webRTCServices == null) {
      return Text("webRTCServices of Provider backend is null");
    }

    ProviderBackend validBackendProvider =
        providerBackend!; //Fight against no null system of dart
    WebRTCService webRTCService = validBackendProvider.webRTCServices;
    if (webRTCService.isCaller) {
      return SingleChildScrollView(
        child: Column(
          children: [
            TextButton(
                onPressed: () {
                  _pickFile(navigatorState);
                },
                child: Text("Open File")),
            TextButton(
                onPressed: () async {
                  await providerBackend?.webRTCServices
                      .getDataChannel(DataChannelType.GLOBAL)!
                      .send(RTCDataChannelMessage(
                          json.encode({"action": "Hello", "data": "dummy"})));
                },
                child: Text("Open Folder (WIP)"))
          ],
        ),
      );
    }
    return Text("Waiting for host to select an action");
  }

  initialSetup(BuildContext context) {
    providerBackend = Provider.of<ProviderBackend>(context, listen: false);
    setState(() {});
  }

  Future<void> _pickFile(NavigatorState navigatorState) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      PlatformFile file = result.files.first;
      //Now transfer the file p2p
      //Create response model
      var bytes = file.bytes;
      List<int>? integerList = bytes?.toList();
      final encodedContents = base64Encode(integerList!);
      String fileName = file.name;
      //Send it
      await ReqRespService.Order_OpenFile(
          encodedContents, fileName, providerBackend!);
    }
  }
}
