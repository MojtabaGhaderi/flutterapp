// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:provider/provider.dart';

import 'bloc.dart';
import 'default_page_mask.dart';

class ConfigModem extends StatefulWidget {
  final Socket socket;

  const ConfigModem({super.key, required this.socket});

  @override
  State<ConfigModem> createState() => _ConfigModemState();
}

class _ConfigModemState extends State<ConfigModem> {
  TextEditingController ssid = TextEditingController(), password = TextEditingController();
  int _selectedIndex = 1;
  bool isValid = false;
  bool hasError = false;

  @override
  void dispose() {
    ssid.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
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
          automaticallyImplyLeading: false,
          toolbarHeight: 90,
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
                  height: (screenHeight - 120) * 0.84,
                  child: Column(
                    children: [
                      Text(
                        "تنظیمات روتر",
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
                            child: Padding(
                              padding: const EdgeInsets.only(top: 30.0),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Column(
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
                                        textAlign: TextAlign.justify,
                                        "شناسه و رمز عبور روتر را عوض کنید.",
                                        style: TextStyle(fontFamily: "Peyda-Medium", fontSize: 20),
                                      ),
                                    ),
                                    ConfigTextField(text: ssid, hint: "شناسه جدید"),
                                    ConfigTextField(text: password, hint: "رمز عبور جدید"),
                                  ],
                                ),
                              ),
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
                              depth: -8,
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
                                  if (ssid.text == "" || password.text == "") {
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
                                  if (isValid) {
                                    Map<String, String> json = {
                                      "command": "change_modem",
                                      "ssid": ssid.text,
                                      "password": password.text,
                                    };

                                    print(jsonEncode(json));
                                    widget.socket.add(
                                      utf8.encode(jsonEncode(json)),
                                    );
                                    ssid.text = "";
                                    password.text = "";
                                    Provider.of<Stat>(context, listen: false).setStat = "{\"temperature\":\"2147483647\",\"humidity\":\"2147483647\",\"config_devices\":[]}";
                                    Future.delayed(Duration(seconds: 1), () {
                                      widget.socket.close();
                                      Navigator.popUntil(
                                        context,
                                        ModalRoute.withName('/'),
                                      );
                                    });
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
