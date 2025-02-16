// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:arend_controller_v3/about_us.dart';
import 'package:arend_controller_v3/config_modem.dart';
import 'package:arend_controller_v3/config_queue.dart';
import 'package:arend_controller_v3/control_panel.dart';
import 'package:arend_controller_v3/default_page_mask.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'bloc.dart';
import 'login.dart';

class Dashboard extends StatefulWidget {
  Socket socket;

  Dashboard(this.socket);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int allDevicesNumber = 0;
  int onDevicesNumber = 0;
  int consumption = 0;
  double turns = 0;
  bool canClickRefresh = true;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double defaultBorderRadius = 30;
    const Color textColor = Color.fromRGBO(99, 100, 102, 1);
    const Color textColorY = Color.fromRGBO(140, 140, 140, 1);
    TextScaler textScale = TextScaler.linear(ScaleSize.textScaleFactor(context));
    List<String> zones;

    void backToLogin() {
      Provider.of<Stat>(context, listen: false).setStat = "";
      widget.socket.close();
      Navigator.popUntil(
        context,
        ModalRoute.withName('/'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 90,
        leading: Padding(
          padding: EdgeInsets.only(left: 20),
          child: IconButton(
            highlightColor: maskColor,
            onPressed: () => {
              backToLogin(),
            },
            icon: Icon(
              Icons.arrow_back_ios,
              size: 35,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: PopupMenuButton(
              icon: Icon(
                Icons.menu,
                size: 40,
              ),
              itemBuilder: (context) {
                return [
                  PopupMenuItem<int>(
                    value: 1,
                    child: Text(
                      "تنظیمات روتر",
                      style: TextStyle(fontFamily: "Peyda-Medium"),
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: 4,
                    child: Text(
                      "بروزرسانی",
                      style: TextStyle(fontFamily: "Peyda-Medium"),
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: 5,
                    child: Text(
                      "در انتظار پیکربندی",
                      style: TextStyle(fontFamily: "Peyda-Medium"),
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: 2,
                    child: Text(
                      "خروج",
                      style: TextStyle(fontFamily: "Peyda-Medium"),
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: 3,
                    child: Text(
                      "درباره ما",
                      style: TextStyle(fontFamily: "Peyda-Medium"),
                    ),
                  ),
                  PopupMenuItem(
                    enabled: false,
                    child: Text(
                      "ورژن  ۳.۰",
                      style: TextStyle(fontFamily: "Peyda-Medium"),
                    ),
                  ),
                ];
              },
              onSelected: (value) {
                if (value == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConfigModem(socket: widget.socket),
                    ),
                  );
                } else if (value == 2) {
                  backToLogin();
                } else if (value == 3) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AboutUs(widget.socket),
                    ),
                  );
                } else if (value == 4) {
                  widget.socket.add(
                    utf8.encode("{\"command\":\"refresh\"}"),
                  );
                } else if (value == 5) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConfigQueue(socket: widget.socket),
                    ),
                  );
                }
              },
            ),
          ),
        ],
        backgroundColor: Color.fromRGBO(232, 232, 232, 1),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: screenHeight - 124),
          child: Column(
            children: [
              DefaultPageMask(
                color: maskColor,
                height: (MediaQuery.of(context).size.height - 90) * 0.84,
                child: Consumer<Stat>(
                  builder: (context, value, child) {
                    print("here is the received value: ${value.getStat}");
                    zones = [];
                    onDevicesNumber = 0;
                    allDevicesNumber = 0;
                    consumption = 0;
                    jsonDecode(value.getStat).forEach(
                      (key, val) {
                        if (key != "temperature" && key != "humidity" && key != "config_devices") {
                          zones.add(key);
                          jsonDecode(value.getStat)[key].forEach(
                            (key1, val1) {
                              allDevicesNumber++;
                              var jsonVal1 = jsonDecode(value.getStat)[key][key1];
                              if (!(jsonVal1["status"] == "off" || jsonVal1["dim"] == "0.00" || jsonVal1["dim"] == "0")) {
                                if (jsonVal1["consumption"] != null) {
                                  consumption += int.parse(jsonVal1["consumption"].toString());
                                }
                                onDevicesNumber++;
                              }
                            },
                          );
                        }
                      },
                    );
                    return Column(
                      children: [
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    width: screenWidth * 0.28,
                                    height: screenWidth * 0.28,
                                    child: NeumorphicContainer(
                                      color: maskColor,
                                      borderRadius: defaultBorderRadius,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Transform.translate(
                                            offset: Offset(0, 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Transform.translate(
                                                  offset: Offset(0, -3),
                                                  child: Text(
                                                    "وات\nساعت",
                                                    textAlign: TextAlign.center,
                                                    textScaler: textScale,
                                                    style: TextStyle(fontFamily: "Peyda-Regular", fontSize: 10, color: textColor),
                                                  ),
                                                ),
                                                Text(
                                                  consumption.toString(),
                                                  textScaler: textScale,
                                                  style: TextStyle(fontFamily: "Peyda-SemiBold", fontSize: 27, color: textColor),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Stack(
                                              alignment: Alignment.bottomCenter,
                                              children: [
                                                Image.asset("assets/Consumption.png"),
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    "مصرف",
                                                    textScaler: textScale,
                                                    style: TextStyle(color: Colors.white, fontFamily: "Peyda-Regular", fontSize: 20),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: screenWidth * 0.55,
                                  height: screenWidth * 0.28,
                                  child: NeumorphicContainer(
                                    color: maskColor,
                                    borderRadius: defaultBorderRadius,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Expanded(child: Transform.scale(scale: 0.5, child: Image.asset("assets/Temp.png"))),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "${(!(int.parse(jsonDecode(value.getStat)["temperature"]) > 100 || int.parse(jsonDecode(value.getStat)["temperature"]) < -50)) ? jsonDecode(value.getStat)["temperature"] : "23"}°C",
                                                    textScaler: textScale,
                                                    style: TextStyle(fontSize: 27, fontFamily: "Peyda-SemiBold", color: textColor),
                                                  ),
                                                  Text(
                                                    "دما",
                                                    textScaler: textScale,
                                                    style: TextStyle(fontSize: 15, fontFamily: "Peyda-SemiBold", color: textColorY),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        NeumorphicDivider(color: maskColor),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "${(!(int.parse(jsonDecode(value.getStat)["humidity"]) > 100 || int.parse(jsonDecode(value.getStat)["humidity"]) < 0)) ? jsonDecode(value.getStat)["humidity"] : "46"}%",
                                                    textScaler: textScale,
                                                    style: TextStyle(fontSize: 27, fontFamily: "Peyda-SemiBold", color: textColor),
                                                  ),
                                                  Text(
                                                    "رطوبت",
                                                    textScaler: textScale,
                                                    style: TextStyle(fontSize: 15, fontFamily: "Peyda-SemiBold", color: textColorY),
                                                  )
                                                ],
                                              ),
                                              Expanded(child: Transform.scale(scale: 0.5, child: Image.asset("assets/Humid.png"))),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 15.0),
                              child: SizedBox(
                                height: screenWidth * .28 * 0.45,
                                width: screenWidth * 0.83 + 8,
                                child: NeumorphicContainer(
                                  color: maskColor,
                                  borderRadius: 20,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        allDevicesNumber == 0 ? "0%" : "${(onDevicesNumber / allDevicesNumber * 100).round()}%",
                                        textScaler: textScale,
                                        style: TextStyle(fontSize: 27, fontFamily: "Peyda-SemiBold", color: textColor),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 8.0, right: 8.0),
                                        child: NeumorphicDivider(color: maskColor),
                                      ),
                                      Text(
                                        "دستگاه\nروشن",
                                        textScaler: textScale,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          height: 1,
                                          fontSize: 18,
                                          fontFamily: "Peyda-SemiBold",
                                          color: textColor,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 20.0, right: 10.0),
                                        child: Row(
                                          children: [
                                            Transform.translate(
                                              offset: Offset(0.0, -7),
                                              child: Text(
                                                onDevicesNumber.toString(),
                                                textScaler: textScale,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  height: 1,
                                                  fontSize: 25,
                                                  fontFamily: "Peyda-SemiBold",
                                                  color: textColor,
                                                ),
                                              ),
                                            ),
                                            Transform.translate(
                                              offset: Offset(0.0, 7),
                                              child: Text(
                                                "/${allDevicesNumber.toString()}",
                                                textScaler: textScale,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  height: 1,
                                                  fontSize: 15,
                                                  fontFamily: "Peyda-SemiBold",
                                                  color: textColorY,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Transform.scale(scale: 0.75, child: Image.asset("assets/Outlet.png"))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: ShaderMask(
                            shaderCallback: (Rect rect) {
                              return LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: const [Colors.purple, Colors.transparent, Colors.transparent, Colors.purple],
                                stops: const [0.0, 0.1, 0.9, 1.0], // 10% purple, 80% transparent, 10% purple
                              ).createShader(rect);
                            },
                            blendMode: BlendMode.dstOut,
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: EdgeInsets.only(top: 50.0, bottom: 50.0),
                                child: Center(
                                  child: SizedBox(
                                    width: screenWidth * 0.83 + 8,
                                    child: StaggeredGrid.count(
                                      crossAxisCount: 12,
                                      mainAxisSpacing: 12,
                                      crossAxisSpacing: 15,
                                      children: [
                                        for (String zoneName in zones)
                                          StaggeredGridTile.count(
                                            crossAxisCellCount: 6,
                                            mainAxisCellCount: 6,
                                            child: NeumorphicButton(
                                              onPressed: () => {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => ControlPanel(
                                                      zoneName: zoneName,
                                                      socket: widget.socket,
                                                    ),
                                                  ),
                                                ),
                                              },
                                              style: NeumorphicStyle(color: maskColor, boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20))),
                                              child: Center(
                                                child: Text(
                                                  zoneName,
                                                  textScaler: textScale,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(fontFamily: "Peyda-Bold", fontSize: 26),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(screenWidth * 0.15, 0, screenWidth * 0.15, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          height: 35,
                          "assets/Home.png",
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ConfigModem(socket: widget.socket),
                              ),
                            );
                          },
                          child: Image.asset(
                            height: 35,
                            "assets/wifi.png",
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            backToLogin();
                          },
                          child: Image.asset(
                            height: 35,
                            "assets/Lock.png",
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (canClickRefresh) {
                              canClickRefresh = false;
                              setState(() {
                                turns++;
                              });
                              widget.socket.add(
                                utf8.encode("{\"command\":\"refresh\"}"),
                              );
                              Future.delayed(Duration(seconds: 5), () {
                                setState(() {
                                  canClickRefresh = true;
                                });
                              });
                            }
                          },
                          child: AnimatedRotation(
                            duration: Duration(seconds: 1),
                            turns: turns,
                            child: Image.asset(
                              height: 35,
                              "assets/Refresh.png",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
