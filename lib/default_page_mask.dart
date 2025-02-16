// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:arend_controller_v3/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class DefaultPageMask extends StatelessWidget {
  final Color color;
  final double height;
  final Widget child;

  const DefaultPageMask({required this.child, required this.color, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
        color: color,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: child,
    );
  }
}

class NeumorphicDivider extends StatelessWidget {
  final Color color;

  const NeumorphicDivider({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleY: 0.7,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8),
        child: Neumorphic(
          style: NeumorphicStyle(color: color),
          child: Opacity(
            opacity: 0,
            child: VerticalDivider(
              width: 5,
            ),
          ),
        ),
      ),
    );
  }
}

class NeumorphicContainer extends StatelessWidget {
  final Color color;
  final double? borderRadius;
  final Widget child;
  final double? depth;
  final NeumorphicBoxShape? boxShape;

  const NeumorphicContainer({super.key, required this.color, required this.child, this.borderRadius, this.depth, this.boxShape});

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.concave,
        boxShape: borderRadius != null ? NeumorphicBoxShape.roundRect(BorderRadius.circular(borderRadius!)) : boxShape,
        depth: depth ?? 8,
        lightSource: LightSource.topLeft,
        color: color,
      ),
      child: child,
    );
  }
}

class CustomRadio extends StatefulWidget {
  final String value;
  final String value1;
  final String value2;
  final double? scale;

  const CustomRadio({required this.value1, required this.value2, required this.value, this.scale});

  @override
  State<CustomRadio> createState() => _CustomRadioState();
}

class _CustomRadioState extends State<CustomRadio> {
  int radioValue = 1;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.width;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => RadioValue(),
        )
      ],
      child: Transform.scale(
        scale: widget.scale ?? 1,
        child: Padding(
          padding: EdgeInsets.only(
            right: screenWidth * 0.18,
            left: screenWidth * 0.18,
            bottom: 25,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: screenWidth * 0.3,
                height: 55,
                child: NeumorphicRadio(
                  value: 1,
                  groupValue: radioValue,
                  onChanged: (value) {
                    setState(() {
                      Provider.of<RadioValue>(context, listen: false).setStat = {widget.value: widget.value1};
                      radioValue = 1;
                      // print(radioValStr);
                    });
                  },
                  style: NeumorphicRadioStyle(
                    selectedColor: maskColor,
                    unselectedColor: maskColor,
                  ),
                  child: Center(
                    child: Text(
                      widget.value1,
                      style: TextStyle(
                        color: radioValue == 1 ? Color.fromRGBO(160, 30, 33, 1) : Colors.black,
                        fontFamily: "Peyda-Medium",
                        fontSize: 21,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: screenWidth * 0.3,
                height: 55,
                child: NeumorphicRadio(
                  value: 2,
                  groupValue: radioValue,
                  onChanged: (value) {
                    setState(() {
                      Provider.of<RadioValue>(context, listen: false).setStat = {widget.value: widget.value2};
                      radioValue = 2;
                      // print(radioValStr);
                    });
                  },
                  style: NeumorphicRadioStyle(
                    selectedColor: maskColor,
                    unselectedColor: maskColor,
                  ),
                  child: Center(
                    child: Text(
                      widget.value2,
                      style: TextStyle(
                        color: radioValue == 2 ? Color.fromRGBO(160, 30, 33, 1) : Colors.black,
                        fontFamily: "Peyda-Medium",
                        fontSize: 21,
                      ),
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

class ConfigTextField extends StatefulWidget {
  final TextEditingController text;
  final String hint;
  final double? padding;
  final double? height;
  final double? fontSize;
  final double? opacity;
  final bool? isNum;

  const ConfigTextField({required this.text, required this.hint, this.padding, this.height, this.fontSize, this.opacity, this.isNum});

  @override
  _ConfigTextFieldState createState() => _ConfigTextFieldState();
}

class _ConfigTextFieldState extends State<ConfigTextField> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Consumer<RadioValue>(
      builder: (context, value, child) {
        print("here is it: ${value.getStat}");
        return Visibility(
          visible: (value.getStat["role"] == "اصلی" && widget.hint == "نام دستگاه") || (value.getStat["role"] == "فرعی" && widget.hint == "نام محدوده") ? false : true,
          child: Padding(
            padding: EdgeInsets.fromLTRB(screenWidth * (widget.padding ?? 0.15), 25, screenWidth * (widget.padding ?? 0.15), 0),
            child: Neumorphic(
              style: NeumorphicStyle(
                color: Color.fromRGBO(232, 232, 232, 1),
                lightSource: LightSource(0.87, 0.8),
                shadowLightColorEmboss: Colors.white,
                oppositeShadowLightSource: true,
                depth: -5,
              ),
              child: SizedBox(
                height: widget.height ?? 55,
                child: TextField(
                  keyboardType: widget.isNum == true ? TextInputType.number : TextInputType.text,
                  controller: widget.text,
                  style: TextStyle(fontFamily: 'Peyda-Medium', fontSize: widget.fontSize ?? 22),
                  textAlign: TextAlign.center,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: widget.hint,
                    hintStyle: TextStyle(color: Color.fromRGBO(99, 100, 102, (widget.opacity ?? 0.5))),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ScaleSize {
  static double textScaleFactor(BuildContext context, {double maxTextScaleFactor = 2}) {
    final width = MediaQuery.of(context).size.width;
    double val = (width / 1400) * maxTextScaleFactor;
    return max(1, min(val, maxTextScaleFactor));
  }
}

Color maskColor = Color.fromRGBO(232, 232, 232, 1);
