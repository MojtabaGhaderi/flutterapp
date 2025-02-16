// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:io';

import 'package:arend_controller_v3/add_new_light.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import 'about_us.dart';
import 'bloc.dart';
import 'config_modem.dart';
import 'control_panel.dart';
import 'default_page_mask.dart';

class ConfigQueue extends StatefulWidget {
  final Socket socket;

  const ConfigQueue({super.key, required this.socket});

  @override
  State<ConfigQueue> createState() => _ConfigQueueState();
}

class _ConfigQueueState extends State<ConfigQueue> {
  bool canClickRefresh = true;
  double turns = 0;

  @override
  Widget build(BuildContext context) {
    TextScaler textScale = TextScaler.linear(ScaleSize.textScaleFactor(context));
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

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
              Navigator.pop(context),
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
                height: (screenHeight - 120) * 0.84,
                child: Column(
                  children: [
                    Text(
                      "در انتظار پیکربندی",
                      style: TextStyle(
                        fontSize: 40,
                        fontFamily: 'Peyda-Black',
                        color: Color.fromRGBO(160, 30, 33, 1),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Consumer<NewConfigDevicesList>(builder: (context, value, child) {
                      return Expanded(
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
                                      for (String configDevice in value.getList)
                                        StaggeredGridTile.count(
                                          crossAxisCellCount: 12,
                                          mainAxisCellCount: 2,
                                          child: NeumorphicButton(
                                            onPressed: () => {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ConfNewLight(socket: widget.socket, deviceName: configDevice),
                                                ),
                                              )
                                            },
                                            style: NeumorphicStyle(color: maskColor, boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20))),
                                            child: Center(
                                              child: Text(
                                                configDevice,
                                                textScaler: textScale,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontFamily: "Peyda-Bold", fontSize: 20),
                                              ),
                                            ),
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
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
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Image.asset(
                            height: 35,
                            "assets/Home.png",
                          ),
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
