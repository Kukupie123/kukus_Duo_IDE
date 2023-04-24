import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kukus_multi_user_ide/Backend/WebRTC/DataChannelType.dart';
import 'package:kukus_multi_user_ide/Backend/provider/ProviderBackend.dart';
import 'package:kukus_multi_user_ide/Backend/util/ReqRespService.dart';
import 'package:provider/provider.dart';

class PageFileEditor extends StatefulWidget {
  const PageFileEditor(this.fileModel, {Key? key}) : super(key: key);
  final OpenFileModel fileModel;

  @override
  State<PageFileEditor> createState() => _PageFileEditorState();
}

class _PageFileEditorState extends State<PageFileEditor> {
  TextEditingController controller = TextEditingController();
  late TextSelection textPos;
  final FocusNode _focusNode = FocusNode();
  bool _shouldFocus = false;
  ProviderBackend? providerBackend;
  late OpenFileModel fileModel;

  initialSetup(BuildContext context) {
    providerBackend = Provider.of<ProviderBackend>(context, listen: false);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    textPos = controller.selection;
    fileModel = widget.fileModel;
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _shouldFocus = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (providerBackend == null) {
      initialSetup(context);
    }
    return Scaffold(
      body: Consumer<ProviderBackend>(
        builder: (context, value, child) {
          var msg = value.webRTCServices.getDataMsg(DataChannelType.GLOBAL);
          if (msg != null) {
            var updatedFile = ReqRespService.Process_UpdateFileRequest(
                msg.text, providerBackend!);
            if (updatedFile != null) {
              fileModel = updatedFile;
            } else {
              print("updatedFile is null");
            }
          }
          controller.text = utf8.decode(base64.decode(fileModel.encodedData));
          controller.selection = textPos;
          return child!;
        },
        child: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text("SAVE/SAVE IN HOST/ SAVE LOCAL"),
                    ),
                  ],
                ),
                SizedBox(
                  height: 1000,
                  child: Expanded(
                    child: TextField(
                      controller: controller,
                      autofocus: _shouldFocus,
                      onChanged: onTextUpdate,
                      maxLines: 5000000,

                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onTextUpdate(String updatedText) async {
    textPos = controller.selection;
    var encodedText = utf8.encode(updatedText);
    fileModel.encodedData = base64Encode(encodedText);
    await ReqRespService.Order_UpdateFile(fileModel, providerBackend!);
  }
}
