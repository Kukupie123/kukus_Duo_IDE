import 'package:flutter/material.dart';
import 'package:kukus_multi_user_ide/Backend/provider/ProviderBackend.dart';
import 'package:provider/provider.dart';

class PageSelectProject extends StatefulWidget {
  const PageSelectProject({Key? key}) : super(key: key);

  @override
  State<PageSelectProject> createState() => _PageSelectProjectState();
}

class _PageSelectProjectState extends State<PageSelectProject> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

ProviderBackend _getBackendProvider(BuildContext context) {
  return Provider.of<ProviderBackend>(context, listen: false);
}
