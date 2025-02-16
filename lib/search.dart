// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'add_new_light.dart';
import 'package:flutter/material.dart';
import 'control_panel.dart';
import 'package:provider/provider.dart';
import 'bloc.dart';
import 'dashboard.dart';

String fullReceived = "";

bool isFirst = true;

const String _start = "uzV85";
const String _end = "OQqYg";
String last = "";
String lastFive = "";
int startPoint = -1;

class Search extends StatefulWidget {
  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 2000),
    vsync: this,
  )..repeat();
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutCirc,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void navigate(Widget Function() page) {
    timer.cancel();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => page(),
        ),
      );
    });
  }

  late Timer timer, loadingTimer;
  bool inter = false;

  Future<void> checker() async {
    inter = !inter;
    Socket socket;
    String modemIP = "192.168.4.1";
    String configIP = "192.168.3.1";

    socket = await Socket.connect(
      inter ? modemIP : configIP,
      9999,
      timeout: Duration(seconds: 5),
    );

    String connectedIP = socket.remoteAddress.address;
    print("alright connected");

    if (connectedIP == modemIP) {
      socket.add(
        ascii.encode("{\"message\":\"app_connected\"}"),
      );
    }

    socket.listen(
      (data) {
        String received = utf8.decode(data);

        for (int i = 0; i < received.length; i++) {
          last += received[i];
          lastFive += received[i];
          if (lastFive.length > 5) {
            lastFive = lastFive.substring(1);
          }
          if (lastFive == _start) {
            startPoint = last.length;
          } else if (lastFive == _end) {
            Provider.of<Stat>(context, listen: false).setStat = last.substring(startPoint, last.length - 5);
            print("here modafaka: $last");
            last = "";
          }
        }
        if (jsonDecode(Provider.of<Stat>(context, listen: false).getStat).containsKey("config_devices")) {
          List<String> newList = [];
          for (String newDevice in jsonDecode(Provider.of<Stat>(context, listen: false).getStat)["config_devices"]) {
            newList.add(newDevice);
          }
          Provider.of<NewConfigDevicesList>(context, listen: false).setList = newList;
        }

        // if (!(received.contains("uzV85") || received.contains("OQqYg"))) {
        //   fullReceived += received;
        // } else {
        //   if (received.contains("uzV85")) {
        //     fullReceived = received.substring(5);
        //     if (received.contains("OQqYg")) {
        //       fullReceived = fullReceived.substring(0, fullReceived.length - 5);
        //       print("final shit: $fullReceived");
        //       Provider.of<Stat>(context, listen: false).setStat = fullReceived;
        //     }
        //   } else {
        //     fullReceived += received.substring(0, received.length - 5);
        //     print("final shit: $fullReceived");
        //     Provider.of<Stat>(context, listen: false).setStat = fullReceived;
        //   }
        // }
        // if (jsonDecode(Provider.of<Stat>(context, listen: false).getStat).containsKey("config_devices")) {
        //   List<String> newList = [];
        //   for (String newDevice in jsonDecode(Provider.of<Stat>(context, listen: false).getStat)["config_devices"]) {
        //     newList.add(newDevice);
        //   }
        //   Provider.of<NewConfigDevicesList>(context, listen: false).setList = newList;
        // }
      },
    );

    if (connectedIP == configIP) {
      navigate(
        () => ConfNewLight(socket: socket, deviceName: "",),
      );
    } else {
      Provider.of<Stat>(context, listen: false).setStat = "{\"temperature\":\"2147483647\",\"humidity\":\"2147483647\",\"config_devices\":[]}";
      navigate(
        () => Dashboard(socket),
      );
    }
  }

  @override
  void initState() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => checker());
    super.initState();
  }

  bool isFirst = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color.fromRGBO(242, 243, 248, 1),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "درحال اتصال",
              style: TextStyle(
                fontSize: 40,
                fontFamily: 'Peyda-Black',
                color: Color.fromRGBO(160, 30, 33, 1),
              ),
              textAlign: TextAlign.center,
            ),
            Transform.scale(
              scale: 0.4,
              child: Stack(
                children: [
                  Transform.scale(scale: 1.1, child: Image.asset("assets/whiteBackground.png")),
                  RotationTransition(
                    turns: _animation,
                    child: Image.asset("assets/red.png"),
                  ),
                  Transform.scale(scale: 0.95, child: Image.asset("assets/whiteForeground.png")),
                ],
              ),
            ),
            Text(
              "لطفاً کمی صبر کنید...",
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Peyda-regular',
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
