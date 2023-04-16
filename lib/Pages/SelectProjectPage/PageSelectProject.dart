// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:kukus_multi_user_ide/Backend/WebRTC/DataChannelType.dart';
import 'package:kukus_multi_user_ide/Backend/provider/ProviderBackend.dart';
import 'package:kukus_multi_user_ide/Backend/util/ReqRespAction.dart';
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
    if (providerBackend!.webRTCServices.isCaller) {
      if (openFileModel == null) {
        return SingleChildScrollView(
          child: Column(
            children: [
              TextButton(
                  onPressed: () {
                    _pickFile(navigatorState);
                  },
                  child: Text("Open File")),
              TextButton(onPressed: () {}, child: Text("Open Folder (WIP)"))
            ],
          ),
        );
      } else {
        return Text("Loaded file with name ${openFileModel?.name}");
      }
    } else {
      if (openFileModel == null) {
        return Text("Waiting for host to select an action");
      } else {
        return Text("Loaded file with name ${openFileModel?.name}");
      }
    }
  }

  initialSetup(BuildContext context) {
    //Retrieve provider
    providerBackend = Provider.of<ProviderBackend>(context, listen: false);
    //Setup Global listener events
    _addListenerToGlobalDC();
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

  void _addListenerToGlobalDC() {
    if (providerBackend == null) {
      throw Exception("Provider Backend is NULL");
    }
    globalDC =
        providerBackend?.webRTCServices.getDataChannel(DataChannelType.GLOBAL);
    globalDC?.onMessage = (data) {
      print(data.text);
      var decodedMap = json.decode(data.text);
      String action = decodedMap['action'];
      //PROCESS OPEN FILE
      if (action == ReqRespAction.OPEN_FILE.toString()) {
        setState(() {
          openFileModel = ReqRespService.Process_OpenFile(decodedMap);
        });
      }
    };
  }
}
