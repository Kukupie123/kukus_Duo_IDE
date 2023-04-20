import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kukus_multi_user_ide/Backend/util/ReqRespService.dart';

class PageFileEditor extends StatefulWidget {
  const PageFileEditor(this.fileModel, {Key? key}) : super(key: key);
  final OpenFileModel fileModel;

  @override
  State<PageFileEditor> createState() => _PageFileEditorState();
}

class _PageFileEditorState extends State<PageFileEditor> {
  TextEditingController controller = TextEditingController();
  FocusNode _focusNode = FocusNode();
  bool _shouldFocus = false;

  @override
  void initState() {
    super.initState();
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
    controller.text = utf8.decode(base64.decode(widget.fileModel.encodedData));
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text("SAVE"),
                  ),
                ],
              ),
              TextField(
                controller: controller,
                autofocus: _shouldFocus,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
