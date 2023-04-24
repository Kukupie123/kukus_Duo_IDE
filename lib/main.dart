import 'package:flutter/material.dart';
import 'package:kukus_multi_user_ide/Backend/provider/ProviderBackend.dart';
import 'package:kukus_multi_user_ide/Pages/ChosePage/PageChoose.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ProviderBackend(),
        )
      ],
      child: MaterialApp(
        title: "Kuku's Multi-User IDE",
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const PageChoose(),
      ),
    );
  }
}

//TODO: Better UI and comment and clean code
//TODO: Move file editor messages to its custom channel not global channel
