// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:arend_controller_v3/about_us.dart';
import 'package:arend_controller_v3/bloc.dart';
import 'package:arend_controller_v3/default_page_mask.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:syncfusion_flutter_core/theme.dart';

import 'config_modem.dart';

class ControlPanel extends StatefulWidget {
  final String zoneName;
  final Socket socket;

  const ControlPanel({super.key, required this.zoneName, required this.socket});

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  TextEditingController newName = TextEditingController();
  double warmSliderValue = 0;
  double coldSliderValue = 0;
  double brightnessValue = 0;
  double warmnessValue = 0;
  double turns = 0;
  double lastDim = 100;
  int carouselIndex = 0;
  int warmnessRadio = 1;
  bool isLoop = false;
  bool isOnLoop = false;
  bool canClickRefresh = true;
  bool canSendRequest = true;
  bool isDimActive = false;
  bool isWarmnessActive = false;
  bool isNamePopUpVisible = false;
  bool isResetPopUpVisible = false;

  @override
  void initState() {
    setState(() {
      Future.delayed(Duration(milliseconds: 6480), () {
        isOnLoop = true;
      });
      carouselIndex = 0;
      var currentZone = jsonDecode(Provider.of<Stat>(context, listen: false).getStat)[widget.zoneName];
      String curDevice = currentZone.keys.toList()[0];
      String tmp = (currentZone[curDevice]["status"] ?? currentZone[curDevice]["dim"]);
      Provider.of<IsSliderEnable>(context, listen: false).setStat = (currentZone[curDevice]["device_type"] == "light" ? true : false);
      print(Provider.of<IsSliderEnable>(context, listen: false).getStat);
      if (currentZone[curDevice]["warmness"] != null) {
        warmnessRadio = int.parse(currentZone[curDevice]["warmness"]);
      }
      if (tmp == "on") {
        brightnessValue = 100;
      } else if (tmp == "off") {
        brightnessValue = 0;
      } else {
        brightnessValue = double.parse(tmp);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextScaler textScale = TextScaler.linear(ScaleSize.textScaleFactor(context));
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double sliderSize = screenWidth * 0.43;
    Color defaultGrey = Color.fromRGBO(209, 209, 209, 1);
    List<String> devices = [];
    List<String> warmnessRadioText = ["سرد", "طبیعی", "گرم"];
    List<Color> warmnessRadioColor = [Color(0xFF739BD0), Color(0xFF636466), Color(0xFFFEB237)];
    List<Color> warmnessRadioColorLessOpacity = [Color.fromRGBO(115, 155, 208, 0.2), Color.fromRGBO(99, 100, 102, 0.2), Color.fromRGBO(254, 178, 55, 0.2)];

    void backToLogin() {
      Provider.of<Stat>(context, listen: false).setStat = "";
      widget.socket.close();
      Navigator.popUntil(
        context,
        ModalRoute.withName('/'),
      );
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Color(0xFFF2F3F8),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 90,
            leading: Padding(
              padding: EdgeInsets.only(left: 20),
              child: IconButton(
                highlightColor: maskColor,
                onPressed: () => {Navigator.pop(context)},
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 35,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 5),
                child: PopupMenuButton(
                  icon: Icon(
                    Icons.more_vert,
                    size: 40,
                  ),
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem<int>(
                        value: 1,
                        child: Text(
                          "بروزرسانی",
                          style: TextStyle(fontFamily: "Peyda-Medium"),
                        ),
                      ),
                      PopupMenuItem<int>(
                        value: 2,
                        child: Text(
                          "تنظیمات اولیه",
                          style: TextStyle(fontFamily: "Peyda-Medium"),
                        ),
                      ),
                      PopupMenuItem<int>(
                        value: 3,
                        child: Text(
                          "تغییر نام دستگاه",
                          style: TextStyle(fontFamily: "Peyda-Medium"),
                        ),
                      ),
                      PopupMenuItem(
                        enabled: false,
                        child: Text(
                          "ورژن  ۳.۰",
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(fontFamily: "Peyda-Medium"),
                        ),
                      ),
                    ];
                  },
                  onSelected: (value) {
                    if (value == 1) {
                      widget.socket.add(
                        utf8.encode("{\"command\":\"refresh\"}"),
                      );
                    } else if (value == 2) {
                      setState(() {
                        isResetPopUpVisible = true;
                      });
                    } else if (value == 3) {
                      setState(() {
                        isNamePopUpVisible = true;
                        newName.text = "";
                      });
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
              child: Consumer<Stat>(builder: (context, value, child) {
                // print("you came here: ${jsonEncode(jsonDecode(value.getStat)[widget.zoneName])}");
                devices = [];
                if (!json.decode(value.getStat).containsKey(widget.zoneName)) {
                  Navigator.pop(context);
                }
                jsonDecode(value.getStat)[widget.zoneName].forEach((key, val) {
                  devices.add(key);
                });
                if (carouselIndex + 1 > devices.length) {
                  Navigator.pop(context);
                }
                return Column(
                  children: [
                    DefaultPageMask(
                      color: maskColor,
                      height: (MediaQuery.of(context).size.height - 90) * 0.84,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.zoneName,
                                  textScaler: textScale,
                                  style: TextStyle(
                                    color: Color.fromRGBO(160, 30, 33, 1),
                                    fontFamily: 'Peyda-Black',
                                    fontSize: 40,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: SizedBox(
                                child: CarouselSlider(
                                  options: CarouselOptions(
                                    enableInfiniteScroll: devices.length == 1 ? false : true,
                                    viewportFraction: 0.7,
                                    height: screenWidth * 0.6,
                                    onPageChanged: (index, reason) {
                                      var currentDevice = jsonDecode(value.getStat)[widget.zoneName][devices[index]];
                                      Provider.of<IsSliderEnable>(context, listen: false).setStat = (currentDevice["device_type"] == "light" ? true : false);
                                      print(currentDevice);
                                      setState(
                                        () {
                                          if (currentDevice["warmness"] != null) {
                                            warmnessRadio = int.parse(currentDevice["warmness"]);
                                          }
                                          carouselIndex = index;
                                          if (currentDevice.containsKey("status")) {
                                            if (currentDevice["status"] == "on") {
                                              brightnessValue = 100;
                                            } else if (currentDevice["status"] == "off") {
                                              brightnessValue = 0;
                                            }
                                          } else {
                                            brightnessValue = double.parse(currentDevice["dim"]);
                                          }
                                          print(index);
                                        },
                                      );
                                    },
                                  ),
                                  items: devices.map(
                                    (device) {
                                      return Builder(
                                        builder: (BuildContext context) {
                                          return SizedBox(
                                            width: screenWidth,
                                            child: NeumorphicContainer(
                                              color: maskColor,
                                              depth: -8,
                                              boxShape: NeumorphicBoxShape.circle(),
                                              child: Container(
                                                margin: EdgeInsets.symmetric(horizontal: 0.0),
                                                child: Center(
                                                  child: Transform.scale(
                                                    scale: 0.5,
                                                    child: jsonDecode(value.getStat)[widget.zoneName][device]["device_type"] == "light" ? Image.asset("assets/Magnet.png") : Image.asset("assets/Switch.png"),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ).toList(),
                                ),
                              ),
                            ),
                            ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: screenHeight - 90) * 0.42,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 30.0, left: 30.0, right: 30, top: 15),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Visibility(
                                      visible: jsonDecode(value.getStat)[widget.zoneName][devices[carouselIndex]]["device_type"] == "light",
                                      child: SizedBox(
                                        width: 55,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            for (int i = 1; i <= 3; i++)
                                              SizedBox(
                                                width: 55,
                                                height: 55,
                                                child: NeumorphicRadio(
                                                  style: NeumorphicRadioStyle(
                                                    selectedColor: maskColor,
                                                    unselectedColor: maskColor,
                                                  ),
                                                  onChanged: (value) {
                                                    if (canSendRequest) {
                                                      widget.socket.add(
                                                        utf8.encode("{\"command\":\"change_warmness\",\"zone\":\"${widget.zoneName}\",\"device_name\":\"${devices[carouselIndex]}\",\"warmness\":\"$i\"}"),
                                                      );
                                                      setState(() {
                                                        warmnessRadio = i;
                                                        canSendRequest = false;
                                                        Future.delayed(Duration(seconds: 1), () {
                                                          canSendRequest = true;
                                                        });
                                                      });
                                                    }
                                                  },
                                                  value: i,
                                                  groupValue: warmnessRadio,
                                                  child: Center(
                                                    child: Text(
                                                      warmnessRadioText[i - 1],
                                                      style: TextStyle(
                                                        color: warmnessRadioColor[i - 1],
                                                        fontSize: 15,
                                                        fontFamily: "Peyda-Medium",
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            SizedBox(
                                              width: 55,
                                              height: 55,
                                              child: Neumorphic(
                                                style: NeumorphicStyle(color: maskColor),
                                                child: Center(
                                                  child: Image.asset(
                                                    "assets/ColdIcon.png",
                                                    width: 22,
                                                    color: warmnessRadioColor[warmnessRadio - 1],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: screenWidth * 0.4,
                                          height: 55,
                                          child: Neumorphic(
                                            style: NeumorphicStyle(color: maskColor),
                                            child: Center(
                                              child: Text(
                                                devices[carouselIndex],
                                                style: TextStyle(
                                                  color: Color(0xFF636466),
                                                  fontSize: 20,
                                                  fontFamily: "Peyda-Medium",
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              SizedBox(
                                                width: sliderSize + 40,
                                                height: sliderSize + 40,
                                                child: Neumorphic(
                                                  style: NeumorphicStyle(boxShape: NeumorphicBoxShape.circle(), color: maskColor),
                                                  child: Image.asset("assets/Dotted Circle.png"),
                                                ),
                                              ),
                                              Stack(
                                                alignment: Alignment.topCenter,
                                                children: [
                                                  SizedBox(
                                                    width: sliderSize,
                                                    height: sliderSize,
                                                    child: RotatedBox(
                                                      quarterTurns: -1,
                                                      child: SfRadialGauge(
                                                        axes: [
                                                          RadialAxis(
                                                            pointers: [
                                                              RangePointer(
                                                                cornerStyle: CornerStyle.bothCurve,
                                                                color: Color.fromRGBO(160, 30, 33, 1.0),
                                                                width: 6,
                                                                value: brightnessValue,
                                                              ),
                                                            ],
                                                            interval: 12,
                                                            showLabels: false,
                                                            showTicks: false,
                                                            axisLineStyle: AxisLineStyle(thickness: 6, color: defaultGrey, cornerStyle: CornerStyle.bothCurve),
                                                            startAngle: 15,
                                                            endAngle: 345,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Transform.translate(
                                                    offset: Offset(0, -10),
                                                    child: SizedBox(
                                                      width: 3,
                                                      height: 25,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(screenHeight),
                                                          color: Color.fromRGBO(160, 30, 33, 1),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                width: sliderSize - 55,
                                                height: sliderSize - 55,
                                                child: Neumorphic(
                                                  style: NeumorphicStyle(boxShape: NeumorphicBoxShape.circle(), color: maskColor),
                                                  child: Image.asset("assets/DottedCircle2.png"),
                                                ),
                                              ),
                                              SizedBox(
                                                width: sliderSize * 0.7,
                                                height: sliderSize * 0.7,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Image.asset(
                                                    "assets/ColorTempArcs.png",
                                                    color: warmnessRadioColorLessOpacity[warmnessRadio - 1],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: sliderSize * 0.3,
                                                height: sliderSize * 0.3,
                                                child: NeumorphicButton(
                                                  onPressed: () {
                                                    if (canSendRequest) {
                                                      if (brightnessValue > 0) {
                                                        widget.socket.add(
                                                          utf8.encode("{\"command\":\"turn_off\",\"zone\":\"${widget.zoneName}\",\"device_name\":\"${devices[carouselIndex]}\"}"),
                                                        );
                                                        setState(() {
                                                          brightnessValue = 0;
                                                        });
                                                      } else {
                                                        widget.socket.add(
                                                          utf8.encode("{\"command\":\"turn_on\",\"zone\":\"${widget.zoneName}\",\"device_name\":\"${devices[carouselIndex]}\"}"),
                                                        );
                                                        setState(() {
                                                          brightnessValue = 100;
                                                        });
                                                      }
                                                      canSendRequest = false;
                                                      Future.delayed(Duration(milliseconds: 1000), () {
                                                        canSendRequest = true;
                                                      });
                                                    }
                                                  },
                                                  style: NeumorphicStyle(
                                                    color: maskColor,
                                                    boxShape: NeumorphicBoxShape.circle(),
                                                  ),
                                                  child: Transform.scale(
                                                    scale: 1.7,
                                                    child: Image.asset(
                                                      "assets/PowerIconOff.png",
                                                      color: brightnessValue > 0 ? Color(0xFFA01E21) : null,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Visibility(
                                        visible: jsonDecode(value.getStat)[widget.zoneName][devices[carouselIndex]]["device_type"] == "light",
                                        child: SizedBox(
                                          height: (MediaQuery.of(context).size.height - 120) * 0.35,
                                          width: 55,
                                          child: Neumorphic(
                                            style: NeumorphicStyle(
                                              color: maskColor,
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: SfSliderTheme(
                                                    data: SfSliderThemeData(
                                                      thumbColor: Color.fromRGBO(160, 30, 33, 1),
                                                      thumbStrokeColor: maskColor,
                                                      thumbStrokeWidth: 3,
                                                      activeTrackColor: Color.fromRGBO(160, 30, 33, 1),
                                                      inactiveTrackColor: Color.fromRGBO(209, 209, 209, 1),
                                                      activeTrackHeight: 6,
                                                      inactiveTrackHeight: 6,
                                                    ),
                                                    child: Consumer<IsSliderEnable>(
                                                      builder: (context, value, child) {
                                                        return Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            SfSlider.vertical(
                                                              showDividers: true,
                                                              enableTooltip: false,
                                                              value: brightnessValue,
                                                              max: 100,
                                                              min: 0,
                                                              onChangeEnd: (val) {
                                                                if (canSendRequest) {
                                                                  if (value.getStat == true) {
                                                                    setState(
                                                                      () {
                                                                        brightnessValue = (val.round() - (val.round() % (10))).toDouble();
                                                                      },
                                                                    );
                                                                    widget.socket.add(
                                                                      utf8.encode("{\"command\":\"change_dim\",\"zone\":\"${widget.zoneName}\",\"device_name\":\"${devices[carouselIndex]}\",\"dim\":\"${brightnessValue.round() - (brightnessValue.round() % 10)}\"}"),
                                                                    );
                                                                    canSendRequest = false;
                                                                    print("WTF");
                                                                    Future.delayed(Duration(seconds: 1), () {
                                                                      canSendRequest = true;
                                                                    });
                                                                  }
                                                                }
                                                              },
                                                              onChanged: (val) {
                                                                if (canSendRequest) {
                                                                  if (value.getStat == true) {
                                                                    setState(
                                                                      () {
                                                                        brightnessValue = val;
                                                                      },
                                                                    );
                                                                  }
                                                                }
                                                              },
                                                            ),
                                                            Image.asset("assets/DottedLine.png")
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(bottom: 15.0),
                                                  child: Image.asset(
                                                    "assets/WarmIcon.png",
                                                    width: 22,
                                                    color: Color.fromRGBO(99, 100, 102, min(brightnessValue * 0.01 + 0.2, 1)),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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
                );
              }),
            ),
          ),
        ),
        Visibility(
          visible: isNamePopUpVisible,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
            child: Center(
              child: SizedBox(
                width: screenWidth * 0.8,
                height: 300,
                child: NeumorphicContainer(
                  color: maskColor,
                  borderRadius: 50,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 45.0),
                            child: Text(
                              "نام جدید:",
                              textDirection: TextDirection.rtl,
                              style: TextStyle(fontFamily: "Peyda-Bold", fontSize: 26),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(screenWidth * 0.15, 15, screenWidth * 0.15, 0),
                            child: Neumorphic(
                              style: NeumorphicStyle(
                                color: Color.fromRGBO(232, 232, 232, 1),
                                lightSource: LightSource(0.87, 0.8),
                                shadowLightColorEmboss: Colors.white,
                                oppositeShadowLightSource: true,
                                depth: -5,
                              ),
                              child: SizedBox(
                                height: 55,
                                child: Material(
                                  color: maskColor,
                                  child: TextField(
                                    controller: newName,
                                    style: TextStyle(fontFamily: 'Peyda-Medium', fontSize: 22),
                                    textAlign: TextAlign.center,
                                    cursorColor: Colors.black,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(color: Color.fromRGBO(99, 100, 102, 0.5)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 55.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: SizedBox(
                                width: 100,
                                height: 55,
                                child: NeumorphicButton(
                                  onPressed: () {
                                    setState(() {
                                      isNamePopUpVisible = false;
                                    });
                                  },
                                  style: NeumorphicStyle(color: maskColor),
                                  child: Image.asset(
                                    "assets/Cross.png",
                                    color: Color(0xFFCC1919),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: SizedBox(
                                width: 100,
                                height: 55,
                                child: NeumorphicButton(
                                  onPressed: () {
                                    widget.socket.add(
                                      utf8.encode("{\"command\":\"change_device_name\",\"zone\":\"${widget.zoneName}\",\"current_name\":\"${devices[carouselIndex]}\",\"new_name\":\"${newName.text}\"}"),
                                    );
                                    setState(() {
                                      isNamePopUpVisible = false;
                                    });
                                  },
                                  style: NeumorphicStyle(color: maskColor),
                                  child: Image.asset(
                                    "assets/Check.png",
                                    color: Color(0xFF1E9E5E),
                                  ),
                                ),
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
          ),
        ),
        Visibility(
          visible: isResetPopUpVisible,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
            child: Center(
              child: SizedBox(
                width: screenWidth * 0.8,
                height: 300,
                child: NeumorphicContainer(
                  color: maskColor,
                  borderRadius: 50,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 45.0),
                        child: Text(
                          "می‌خواهید به تنظیمات\nاولیه برگردید؟",
                          style: TextStyle(fontFamily: "Peyda-Medium", fontSize: 26),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 55.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: SizedBox(
                                width: 100,
                                height: 55,
                                child: NeumorphicButton(
                                  onPressed: () {
                                    setState(() {
                                      isResetPopUpVisible = false;
                                    });
                                  },
                                  style: NeumorphicStyle(color: maskColor),
                                  child: Image.asset(
                                    "assets/Cross.png",
                                    color: Color(0xFFCC1919),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: SizedBox(
                                width: 100,
                                height: 55,
                                child: NeumorphicButton(
                                  onPressed: () {
                                    print("{\"command\":\"reset_factory\",\"zone\":\"${widget.zoneName}\",\"device_name\":\"${devices[carouselIndex]}\"}");
                                    widget.socket.add(
                                      utf8.encode("{\"command\":\"reset_factory\",\"zone\":\"${widget.zoneName}\",\"device_name\":\"${devices[carouselIndex]}\"}"),
                                    );
                                    Navigator.pop(context);
                                  },
                                  style: NeumorphicStyle(color: maskColor),
                                  child: Image.asset(
                                    "assets/Check.png",
                                    color: Color(0xFF1E9E5E),
                                  ),
                                ),
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
          ),
        ),
      ],
    );
  }
}
