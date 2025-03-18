import 'package:flutter/material.dart';

class LoadingRoute extends StatefulWidget {
  bool dark_theme = false;
  LoadingRoute({super.key, bool this.dark_theme = false});

  @override
  State<LoadingRoute> createState() => LoadingRouteState();
}

class LoadingRouteState extends State<LoadingRoute> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: (widget.dark_theme) ? const Color(0xFF292929) : Colors.white,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Align(
        alignment: Alignment.center,
        child: (widget.dark_theme) ? Image.asset("assets/loading.gif") : Image.asset("assets/loading-white.gif")
      )
    );
  }
}