// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:arend_controller_v3/default_page_mask.dart';
import 'package:arend_controller_v3/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    TextScaler textScale = TextScaler.linear(ScaleSize.textScaleFactor(context));

    return Scaffold(
      body: Column(
        children: [
          DefaultPageMask(
            color: Color.fromRGBO(188, 32, 32, 1),
            height: screenHeight * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: Image.asset(
                    "assets/Logo.png",
                    width: 150,
                    height: 150,
                  ),
                ),
                Text(
                  "اپلیکیشن\nهوشمند",
                  textScaler: textScale,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontFamily: "Peyda-Bold",
                    color: Colors.white,

                  ),
                ),
                Text(
                  "آرند",
                  textScaler: textScale,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 60,
                    fontFamily: "Peyda-Black",
                    color: Colors.white,

                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 40,
                  child: Image.asset("assets/Gear.png"),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                  child: SizedBox(
                    width: screenWidth * 0.3,
                    child: NeumorphicButton(
                      onPressed: () => {
                        Future.delayed(Duration(milliseconds: 600), () {
                          // widget.socket.close();
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Search()));
                        })
                      },
                      style: NeumorphicStyle(
                        depth: 10,
                        color: Color.fromRGBO(188, 32, 32, 1),
                      ),
                      child: Text(
                        "ورود",
                        textAlign: TextAlign.center,
                        textScaler: textScale,
                        style: TextStyle(color: Colors.white, fontFamily: "Peyda-Medium", fontSize: 25),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    exit(0);
                  },
                  child: SizedBox(
                    height: 37,
                    child: Image.asset("assets/Exit.png"),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
