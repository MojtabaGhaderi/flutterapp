// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, sized_box_for_whitespace, avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:ui';

import 'package:arend_controller_v3/default_page_mask.dart';
import 'package:flutter/cupertino.dart';

import 'search.dart';
import 'package:provider/provider.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'bloc.dart';

class ConfNewLight extends StatefulWidget {
  final Socket socket;
  final String deviceName;

  const ConfNewLight({required this.socket, required this.deviceName});

  @override
  _ConfNewLightState createState() => _ConfNewLightState();
}

class _ConfNewLightState extends State<ConfNewLight> with SingleTickerProviderStateMixin {
  bool isValid = false;
  bool hasError = false;
  bool isDef = true;
  TextEditingController   zone = TextEditingController(), name = TextEditingController(), consumption = TextEditingController();
  int _selectedIndex = 1;
  String dropDownValue = "";

  @override
  dispose() {
    zone.dispose();
    name.dispose();
    consumption.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    String errorText;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Color.fromRGBO(242, 243, 248, 1),
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
              child: IconButton(
                onPressed: () => {},
                icon: Icon(
                  Icons.menu,
                  size: 40,
                ),
              ),
            ),
          ],
          backgroundColor: maskColor,
        ),
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: screenHeight - 124),
            child: Column(
              children: [
                DefaultPageMask(
                  color: maskColor,
                  height: (MediaQuery.of(context).size.height - 120) * 0.84,
                  child: Column(
                    children: [
                      Text(
                        "پیکربندی دستگاه",
                        style: TextStyle(
                          fontSize: 40,
                          fontFamily: 'Peyda-Black',
                          color: Color.fromRGBO(160, 30, 33, 1),
                        ),
                        textAlign: TextAlign.center,
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
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 30.0),
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Consumer<Stat>(
                                      builder: (context, value, child) {
                                        List<String> zones = [];
                                        jsonDecode(value.getStat).forEach(
                                          (key, val) {
                                            if (key != "temperature" && key != "humidity" && key != "config_devices" && key != "روتر") {
                                              zones.add(key);
                                            }
                                          },
                                        );
                                        // dropDownValue = zones.isNotEmpty ? zones.first : "";
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                top: 0,
                                                bottom: 25,
                                                right: screenWidth * 0.15,
                                                left: screenWidth * 0.15,
                                              ),
                                              child: Text(
                                                textDirection: TextDirection.rtl,
                                                textAlign: TextAlign.center,
                                                widget.deviceName,
                                                style: TextStyle(fontFamily: "Peyda-Medium", fontSize: 23),
                                              ),
                                            ),
                                            CustomRadio(
                                              value: "role",
                                              value1: "اصلی",
                                              value2: "فرعی",
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                right: screenWidth * 0.25,
                                                left: screenWidth * 0.25,
                                              ),
                                              child: NeumorphicToggle(
                                                style: NeumorphicToggleStyle(backgroundColor: maskColor),
                                                selectedIndex: _selectedIndex,
                                                onChanged: (value) {
                                                  Provider.of<RadioValue>(context, listen: false).setStat = {"type": (value == 0 ? "روشنایی" : "سوییچ")};
                                                  setState(() {
                                                    _selectedIndex = value;
                                                  });
                                                },
                                                thumb: Neumorphic(
                                                  style: NeumorphicStyle(
                                                    color: maskColor,
                                                    boxShape: NeumorphicBoxShape.roundRect(
                                                      BorderRadius.all(
                                                        Radius.circular(12),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                children: [
                                                  ToggleElement(
                                                    background: Center(
                                                      child: Text(
                                                        "روشنایی",
                                                        style: TextStyle(fontFamily: "Peyda-Bold"),
                                                      ),
                                                    ),
                                                    foreground: Center(
                                                      child: Text(
                                                        "روشنایی",
                                                        style: TextStyle(fontFamily: "Peyda-Bold", color: Color.fromRGBO(160, 30, 33, 1)),
                                                      ),
                                                    ),
                                                  ),
                                                  ToggleElement(
                                                    background: Center(
                                                      child: Text(
                                                        "سوییچ",
                                                        style: TextStyle(fontFamily: "Peyda-Bold"),
                                                      ),
                                                    ),
                                                    foreground: Center(
                                                      child: Text(
                                                        "سوییچ",
                                                        style: TextStyle(fontFamily: "Peyda-Bold", color: Color.fromRGBO(160, 30, 33, 1)),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Consumer<RadioValue>(
                                              builder: (context, value, child) {
                                                return Visibility(
                                                  visible: value.getStat["role"] == "اصلی" ? false : true,
                                                  child: Padding(
                                                    padding: EdgeInsets.fromLTRB(screenWidth * 0.15, 25, screenWidth * 0.15, 0),
                                                    child: Center(
                                                      child: DropdownMenu<String>(
                                                        width: screenWidth * 0.7,
                                                        initialSelection: zones.isNotEmpty ? zones.first : "",
                                                        onSelected: (String? value) {
                                                          setState(() {
                                                            dropDownValue = value!;
                                                          });
                                                          print("here is what happening$dropDownValue");
                                                        },
                                                        dropdownMenuEntries: zones.map<DropdownMenuEntry<String>>((String value) {
                                                          return DropdownMenuEntry<String>(value: value, label: value);
                                                        }).toList(),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            ConfigTextField(
                                              text: zone,
                                              hint: "نام محدوده",
                                              opacity: 0.6,
                                            ),

                                            // ConfigTextField(
                                            //   text: ssid,
                                            //   hint: "شناسه",
                                            //   padding: 0.25,
                                            //   height: 45,
                                            //   fontSize: 18,
                                            // ),
                                            // ConfigTextField(
                                            //   text: password,
                                            //   hint: "رمز عبور",
                                            //   padding: 0.25,
                                            //   height: 45,
                                            //   fontSize: 18,
                                            // ),
                                            ConfigTextField(
                                              text: name,
                                              hint: "نام دستگاه",
                                              // padding: 0.25,
                                              // height: 45,
                                              // fontSize: 18,
                                            ),
                                            ConfigTextField(
                                              isNum: true,
                                              text: consumption,
                                              hint: "توان مصرفی دستگاه",
                                              padding: 0.25,
                                              height: 45,
                                              fontSize: 18,
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      final offsetAnimation = TweenSequence([
                        TweenSequenceItem(tween: Tween<Offset>(begin: Offset(0.0, 1), end: Offset(0.0, 0.0)), weight: 1),
                      ]).animate(animation);

                      if (hasError) {
                        return ClipRect(
                          child: SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          ),
                        );
                      } else {
                        return ClipRect(
                          child: SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          ),
                        );
                      }
                    },
                    duration: Duration(milliseconds: 350),
                    child: (hasError)
                        ? Center(
                            key: ValueKey<int>(1),
                            child: NeumorphicContainer(
                              depth: 8,
                              color: Color.fromRGBO(242, 243, 248, 1),
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
                                  child: Center(
                                    child: Text(
                                      "فیلدها را پر کنید",
                                      style: TextStyle(fontFamily: "Peyda-Regular", fontSize: 20, color: Color.fromRGBO(160, 30, 33, 1)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            key: ValueKey<int>(2),
                            child: SizedBox(
                              height: 55,
                              width: 100,
                              child: NeumorphicButton(
                                onPressed: () {
                                  var radioValStr = Provider.of<RadioValue>(context, listen: false).getStat;
                                  isValid = true;
                                  if (radioValStr["role"] == "فرعی") {
                                    if (name.text == "") {
                                      isValid = false;
                                      setState(() {
                                        hasError = true;
                                      });
                                      Timer(Duration(seconds: 3), () {
                                        setState(() {
                                          hasError = false;
                                        });
                                      });
                                    }
                                  } else if (radioValStr["role"] == "اصلی") {
                                    if (zone.text == "") {
                                      isValid = false;
                                      setState(() {
                                        hasError = true;
                                      });
                                      Timer(Duration(seconds: 3), () {
                                        setState(() {
                                          hasError = false;
                                        });
                                      });
                                    }
                                  }
                                  if (isValid) {
                                    // print(dropDownValue);
                                    Map<String, String> json = {
                                      "command": "config_new_device",
                                      "device_name": widget.deviceName,
                                      "device_type": (radioValStr["type"] == "روشنایی" ? "light" : "220v"),
                                      "consumption": consumption.text,
                                    };
                                    if (radioValStr["role"] == "فرعی") {
                                      json["type"] = "slave";
                                      json["name"] = name.text;
                                      json["zone"] = dropDownValue;
                                    } else if (radioValStr["role"] == "اصلی") {
                                      json["type"] = "daphi";
                                      json["zone"] = zone.text;
                                    }
                                    if (radioValStr["type"] == "روشنایی") {
                                      json["dim"] = "0";
                                    }

                                    print(jsonEncode(json));
                                    widget.socket.add(
                                      utf8.encode(jsonEncode(json)),
                                    );
                                    Navigator.pop(context);
                                  }
                                },
                                style: NeumorphicStyle(
                                  color: Color.fromRGBO(242, 243, 248, 1),
                                ),
                                child: Text(
                                  textAlign: TextAlign.center,
                                  "ثبت",
                                  style: TextStyle(
                                    fontFamily: 'Peyda-Medium',
                                    fontSize: 21,
                                    color: Color.fromRGBO(160, 30, 33, 1),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
