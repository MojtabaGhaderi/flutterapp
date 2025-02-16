// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bloc.dart';
import 'default_page_mask.dart';

class AboutUs extends StatefulWidget {
  final Socket socket;

  const AboutUs(this.socket);

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  double turns = 0;

  @override
  Widget build(BuildContext context) {
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
            onPressed: () => {Navigator.pop(context)},
            icon: Icon(
              Icons.arrow_back_ios,
              size: 35,
            ),
          ),
        ),
        backgroundColor: Color.fromRGBO(232, 232, 232, 1),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: screenHeight - 124),
          child: Column(
            children: [
              DefaultPageMask(
                color: maskColor,
                height: (screenHeight - 90) * 0.84,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "درباره ما",
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
                                padding: EdgeInsets.only(
                                  top: 50.0,
                                  right: screenWidth * 0.1,
                                  left: screenWidth * 0.1,
                                ),
                                child: Text(
                                  "ما کارمان را از طراحی و تولید چراغ‌های روشنایی شروع کردیم، اما حالا با اضافه دن بازوهای جدید به گروه روشنایی آرند، تلاش می‌کنیم با هراهی شما بهترین پلتفرم هوشمند کنترل WiFi باشیم. برای تحقق این ماموریت به لبخند شما  ارزش‌هایی الهام‌بخش باور داریم.",
                                  style: TextStyle(fontFamily: "Peyda-Medium", fontSize: 17),
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                              Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Center(
                                    child: Text(
                                      "ورژن  ۳.۰",
                                      style: TextStyle(fontFamily: "Peyda-Bold"),
                                    ),
                                  ))
                            ],
                          ),
                        ),
                      ),
                    ),
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
                        Image.asset(
                          height: 35,
                          "assets/WiFi.png",
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
                            setState(() {
                              turns++;
                            });
                            widget.socket.add(
                              utf8.encode("{\"command\":\"refresh\"}"),
                            );
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
