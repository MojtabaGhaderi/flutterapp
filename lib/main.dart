// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, use_key_in_widget_constructors

import 'package:arend_controller_v3/about_us.dart';
import 'package:arend_controller_v3/config_modem.dart';
import 'package:arend_controller_v3/config_queue.dart';
import 'package:arend_controller_v3/login.dart';
import 'bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Stat(),
        ),
        ChangeNotifierProvider(
          create: (context) => IsSliderEnable(),
        ),
        ChangeNotifierProvider(
          create: (context) => RadioValue(),
        ),
        ChangeNotifierProvider(
          create: (context) => NewConfigDevicesList(),
        )
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Login(),
      ),
    );
  }
}
