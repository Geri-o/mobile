import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:icafeplay/error_route.dart';
import 'package:icafeplay/loading_route.dart';
import 'package:icafeplay/models.dart' as models;
import 'package:icafeplay/storage.dart' as storage;

class SuccessfulTransactionRoute extends StatefulWidget {
  const SuccessfulTransactionRoute({super.key});

  @override
  State<SuccessfulTransactionRoute> createState() => SuccessfulTransactionRouteRouteState();
}

class SuccessfulTransactionRouteRouteState extends State<SuccessfulTransactionRoute> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: SafeArea(
          child: FutureBuilder(
              future: storage.readStringData("userToken"),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  models.UserToken token = models.UserToken.convert(json.decode(snapshot.data));
                  return Scaffold(
                      resizeToAvoidBottomInset: true,
                      body: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        color: Colors.white,
                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              height: MediaQuery.of(context).size.width * 0.3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.lightGreen
                              ),
                              child: Icon(Icons.done, size: MediaQuery.of(context).size.width * 0.1, color: Colors.white)
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 40.0),
                              child: Text("Transaction completed\nsuccessfully", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 40.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.6,
                                height: MediaQuery.of(context).size.height * 0.06,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))
                                  ),
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(context, "/home");
                                  },
                                  child: const Text("Home Page", style: TextStyle(color: Colors.white))
                                )
                              )
                            )
                          ]
                        )
                      )
                  );
                } else if (snapshot.hasError) {
                  return ErrorRoute(message: "Could not load user data", requestUpdate: setState);
                }
                return LoadingRoute();
              }
          )
      ),
    );
  }
}