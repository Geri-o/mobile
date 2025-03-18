import 'package:flutter/material.dart';

class ErrorRoute extends StatefulWidget {
  final String message;
  final void Function(void Function()) requestUpdate;
  const ErrorRoute({super.key, required this.message, required this.requestUpdate});

  @override
  State<ErrorRoute> createState() => ErrorRouteState();
}

class ErrorRouteState extends State<ErrorRoute> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset("assets/error.gif"),
          const SizedBox(height: 25.0),
          Text(
            widget.message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18.0, color: Colors.black, decoration: TextDecoration.none)
          ),
          const SizedBox(height: 45.0),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: FilledButton(
              onPressed: () {
                widget.requestUpdate((){});
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))
              ),
              child: const Text("Update", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))
            )
          )
        ]
      )
    );
  }
}