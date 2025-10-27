import 'package:flutter/material.dart';

class OnLeavePage extends StatefulWidget {
  const OnLeavePage({super.key});

  @override
  State<OnLeavePage> createState() => _OnLeavePageState();
}

class _OnLeavePageState extends State<OnLeavePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Center(
          child: Text("On leave page"),
        ),
      ),
    );
  }
}
