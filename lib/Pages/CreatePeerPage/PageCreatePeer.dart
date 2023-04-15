// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:kukus_multi_user_ide/Backend/provider/ProviderBackend.dart';
import 'package:provider/provider.dart';

class PageCreatePeer extends StatefulWidget {
  const PageCreatePeer({Key? key}) : super(key: key);

  @override
  State<PageCreatePeer> createState() => _PageCreatePeerState();
}

class _PageCreatePeerState extends State<PageCreatePeer> {
  var offerGeneratedTC = TextEditingController();

  @override
  void initState() {
    super.initState();
    ProviderBackend providerBackend =
        Provider.of<ProviderBackend>(context, listen: false);
    pasteOfferToTextField(providerBackend);
  }

  @override
  Widget build(BuildContext context) {
    ProviderBackend providerBackend =
        Provider.of<ProviderBackend>(context, listen: false);

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            TextField(
              controller: offerGeneratedTC,
              decoration:
                  InputDecoration(hintText: "Generating Offer Please wait...."),
            ),
            Text(
                "Copy the Generated Code above and paste it as the Remote Description in the Client that is trying to join"),
            TextField(
              controller: offerGeneratedTC,
              decoration: InputDecoration(
                  hintText:
                      "Paste Generated Answer of the Client trying to join...."),
            ),
            TextButton(
                onPressed: () {}, child: Text("Confirm Generated Answer")),
            TextField(
              controller: offerGeneratedTC,
              decoration: InputDecoration(
                  hintText:
                      "Paste Copied Candidate of the Client trying to join...."),
            ),
            TextButton(
              onPressed: () {},
              child: Text("Confirm Candidate"),
            ),
          ],
        ),
      ),
    );
  }

  void pasteOfferToTextField(ProviderBackend providerBackend) async {
    String? offerSDP = await providerBackend.webRTCServices.createOffer();
    setState(() {
      offerGeneratedTC.text = offerSDP!;
    });
  }
}
