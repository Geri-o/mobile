import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:icafeplay/registration_route.dart';
import 'package:icafeplay/gateway.dart' as gateway;
import 'package:icafeplay/storage.dart' as storage;
import 'package:icafeplay/localization.dart' as localization;

class AuthorizationRoute extends StatefulWidget {
  final Function setParentState;
  final Function resetFunction;
  const AuthorizationRoute({super.key, required this.setParentState, required this.resetFunction});

  @override
  State<AuthorizationRoute> createState() => AuthorizationRouteState();
}

class AuthorizationRouteState extends State<AuthorizationRoute> {
  String deviceLocale = Platform.localeName.split('_')[0].toUpperCase();
  bool dark_theme = true;

  bool loadingState = false;
  TextEditingController emailFieldController = TextEditingController();
  TextEditingController passwordFieldController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SingleChildScrollView(
            child: Container(
              color: (dark_theme) ? Colors.black87 : Colors.white,
              height: MediaQuery.of(context).size.height * 0.9,
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05),
                    height: MediaQuery.of(context).size.height * 0.25,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Align(
                      alignment: Alignment.center,
                      child: (dark_theme) ? Image.asset("assets/authorization_logo_white.png") : Image.asset("assets/authorization_logo.png")
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: TextField(
                      autocorrect: false,
                      controller: emailFieldController,
                      style: TextStyle(fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.white : Colors.black),
                          borderRadius: BorderRadius.zero
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.white54 : Colors.black54),
                          borderRadius: BorderRadius.zero
                        ),
                        hintText: localization.CivicLocale.translate(deviceLocale, "authorization-route", "email-input-hint"),
                        hintStyle: const TextStyle(color: Colors.grey)
                      )
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: TextField(
                      autocorrect: false,
                      obscureText: true,
                      controller: passwordFieldController,
                      style: TextStyle(fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.white : Colors.black),
                          borderRadius: BorderRadius.zero
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.white54 : Colors.black54),
                          borderRadius: BorderRadius.zero
                        ),
                        hintText: localization.CivicLocale.translate(deviceLocale, "authorization-route", "password-input-hint"),
                        hintStyle: const TextStyle(color: Colors.grey)
                      )
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: (dark_theme) ? Colors.white : Colors.black,
                          textStyle: const TextStyle(fontWeight: FontWeight.bold)
                        ),
                        child: Text(localization.CivicLocale.translate(deviceLocale, "authorization-route", "forgot-password-button-label"))
                      ),
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      height: MediaQuery.of(context).size.height * 0.08,
                      child: OutlinedButton(
                        onPressed: () {
                          if (emailFieldController.text.isNotEmpty && passwordFieldController.text.isNotEmpty) {
                            setState(() {
                              loadingState = true;
                            });
                            gateway.authenticateUser({
                              "email": emailFieldController.text,
                              "password": passwordFieldController.text
                            }).then((token) {
                              storage.writeStringData("userToken", json.encode(token));
                              setState(() {
                                loadingState = false;
                              });
                              widget.resetFunction();
                              widget.setParentState(() {});
                            }).catchError((error) {
                              setState(() {
                                loadingState = false;
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
                              });
                            });
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(width: 2.0, color: (dark_theme) ? Colors.white : Colors.black),
                          foregroundColor: (dark_theme) ? Colors.white : Colors.black,
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))
                        ),
                        child: (loadingState) ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black)) : Text(localization.CivicLocale.translate(deviceLocale, "authorization-route", "login-button-label"))
                      )
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      height: MediaQuery.of(context).size.height * 0.08,
                      child: OutlinedButton(
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => RegistrationRoute(setParentState: widget.setParentState, resetFunction: widget.resetFunction)));
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(width: 2.0, color: (dark_theme) ? Colors.white : Colors.black),
                          foregroundColor: (dark_theme) ? Colors.black : Colors.white,
                          backgroundColor: (dark_theme) ? Colors.white : Colors.black,
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))
                        ),
                        child: Text(localization.CivicLocale.translate(deviceLocale, "authorization-route", "register-button-label"))
                      )
                    )
                  )
                ]
              )
            ),
          )
        )
      )
    );
  }
}