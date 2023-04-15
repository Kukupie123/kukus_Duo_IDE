// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sized_box_for_whitespace

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kukus_multi_user_ide/Backend/provider/ProviderBackend.dart';
import 'package:kukus_multi_user_ide/Pages/CreatePeerPage/PageCreatePeer.dart';
import 'package:provider/provider.dart';

class PageChoose extends StatelessWidget {
  const PageChoose({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Consumer<ProviderBackend>(
          builder: (context, value, child) {
            if (value.webRTCServices.peerConnection == null) {
              return Column(
                children: [
                  CircularProgressIndicator(
                    color: Colors.black26,
                  ),
                  Text("Creating Peer Connection Please wait")
                ],
              );
            } else {
              return child!;
            }
          },
          child: Column(
            children: [
              TextButton(onPressed: () {}, child: const Text("Join Peer")),
              TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => PageCreatePeer(),
                        ));
                  },
                  child: const Text("Create Peer"))
            ],
          ),
        ),
      ),
    );
  }
}
