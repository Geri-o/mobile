import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:icafeplay/error_route.dart';
import 'package:icafeplay/loading_route.dart';
import 'package:icafeplay/gateway.dart' as gateway;
import 'package:icafeplay/models.dart' as models;
import 'package:icafeplay/storage.dart' as storage;
import 'package:icafeplay/localization.dart' as localization;

class RegistrationRoute extends StatefulWidget {
  final Function setParentState;
  final Function resetFunction;
  const RegistrationRoute({super.key, required this.setParentState, required this.resetFunction});

  @override
  State<RegistrationRoute> createState() => RegistrationRouteState();
}

class RegistrationRouteState extends State<RegistrationRoute> {
  String deviceLocale = Platform.localeName.split('_')[0].toUpperCase();
  bool dark_theme = true;

  bool loadingState = false;

  TextEditingController nameFieldController = TextEditingController();
  TextEditingController emailFieldController = TextEditingController();
  TextEditingController passwordFieldController = TextEditingController();
  int selectedCountryID = -1;
  String selectedCountryHint = "Choose country";
  bool hintsLoaded = false;

  List<models.Country> countryContainer = [];

  String? validateEmail(String? value) {
    const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);

    return value!.isNotEmpty && !regex.hasMatch(value)
        ? 'Enter a valid email address'
        : null;
  }

  @override
  Widget build(BuildContext context) {
    if (hintsLoaded == false) selectedCountryHint = localization.CivicLocale.translate(deviceLocale, "registration-route", "country-input-hint");
    hintsLoaded = true;
    return GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: SafeArea(
            child: Scaffold(
                appBar: AppBar(
                  backgroundColor: (dark_theme) ? Colors.black87 : Colors.white,
                  leading: IconButton(
                    icon: Icon(Icons.keyboard_backspace, color: (dark_theme) ? Colors.white : Colors.black),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ),
                resizeToAvoidBottomInset: false,
                body: FutureBuilder(
                  future: gateway.fetchCountries(),
                  builder: (context, AsyncSnapshot<List<models.Country>> snapshot) {
                    if (snapshot.hasData) {
                      countryContainer = snapshot.data!;
                      return Container(
                          color: (dark_theme) ? Colors.black87 : Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                          child: Column(
                              children: [
                                Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(localization.CivicLocale.translate(deviceLocale, "registration-route", "registration-route-title"), style: TextStyle(fontSize: 34.0, fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black))
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: TextField(
                                        autocorrect: false,
                                        controller: nameFieldController,
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
                                            hintText: localization.CivicLocale.translate(deviceLocale, "registration-route", "name-input-hint"),
                                            hintStyle: const TextStyle(color: Colors.grey)
                                        )
                                    )
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: InkWell(
                                        onTap: () {
                                          showModalBottomSheet(
                                              backgroundColor: (dark_theme) ? const Color(0xFF292929) : Colors.white,
                                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                              context: context,
                                              builder: (BuildContext context) {
                                                return StatefulBuilder(
                                                  builder: (BuildContext context, StateSetter updateState) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        FocusManager.instance.primaryFocus?.unfocus();
                                                      },
                                                      child: Container(
                                                        height: MediaQuery.of(context).size.height * 0.6,
                                                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.05),
                                                        child: ListView(
                                                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                                                          children: [
                                                            TextField(
                                                                style: TextStyle(color: (dark_theme) ? Colors.white : Colors.black),
                                                                decoration: InputDecoration(
                                                                    hintText: localization.CivicLocale.translate(deviceLocale, "registration-route", "choose-country-search-hint"),
                                                                    hintStyle: const TextStyle(color: Colors.grey),
                                                                    enabledBorder: OutlineInputBorder(
                                                                        borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.white : Colors.black)
                                                                    ),
                                                                    focusedBorder: OutlineInputBorder(
                                                                        borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.white : Colors.black)
                                                                    )
                                                                ),
                                                                onChanged: (value) {
                                                                  updateState(() {
                                                                    countryContainer = snapshot.data!.where((country) => country.name.toLowerCase().contains(value.toLowerCase())).toList();
                                                                  });
                                                                }
                                                            ),
                                                            for (models.Country country in countryContainer)
                                                              ListTile(
                                                                onTap: () {
                                                                  selectedCountryHint = country.name;
                                                                  selectedCountryID = country.country_id;
                                                                  Navigator.of(context).pop();
                                                                },
                                                                title: Text(country.name, style: TextStyle(color: (dark_theme) ? Colors.white : Colors.black))
                                                              )
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                );
                                              }
                                          ).whenComplete(() {
                                            setState(() {});
                                          });
                                        },
                                        child: Container(
                                            width: MediaQuery.of(context).size.width * 0.9,
                                            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 18.0),
                                            decoration: BoxDecoration(
                                                border: Border.all(color: (dark_theme) ? Colors.white : Colors.black, width: 2.0)
                                            ),
                                            child: Text(selectedCountryHint, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: (dark_theme) ? Colors.white : Colors.black))
                                        )
                                    )
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Form(
                                      autovalidateMode: AutovalidateMode.always,
                                      child: TextFormField(
                                          autocorrect: false,
                                          validator: validateEmail,
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
                                              errorBorder: const OutlineInputBorder(
                                                  borderSide: BorderSide(width: 2.0, color: Colors.red),
                                                  borderRadius: BorderRadius.zero
                                              ),
                                              focusedErrorBorder: const OutlineInputBorder(
                                                  borderSide: BorderSide(width: 2.0, color: Colors.red),
                                                  borderRadius: BorderRadius.zero
                                              ),
                                              hintText: localization.CivicLocale.translate(deviceLocale, "registration-route", "email-input-hint"),
                                              hintStyle: const TextStyle(color: Colors.grey)
                                          )
                                      ),
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
                                            hintText: localization.CivicLocale.translate(deviceLocale, "registration-route", "password-input-hint"),
                                            hintStyle: const TextStyle(color: Colors.grey)
                                        )
                                    )
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.9,
                                        height: MediaQuery.of(context).size.height * 0.08,
                                        child: OutlinedButton(
                                            onPressed: () async {
                                              if (nameFieldController.text.isNotEmpty && !(selectedCountryHint.length > 2) && emailFieldController.text.isNotEmpty && passwordFieldController.text.isNotEmpty) {
                                                setState(() {
                                                  loadingState = true;
                                                });
                                                gateway.registerUser({
                                                  "name": nameFieldController.text,
                                                  "email": emailFieldController.text,
                                                  "password": passwordFieldController.text,
                                                  "country": selectedCountryID
                                                }).then((token) {
                                                  storage.writeStringData("userToken", json.encode(token));
                                                  Navigator.of(context).pop();
                                                  widget.resetFunction();
                                                  widget.setParentState(() {});
                                                }).catchError((error) {
                                                  setState(() {
                                                    loadingState = false;
                                                  });
                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
                                                });
                                              }
                                              else {
                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localization.CivicLocale.translate(deviceLocale, "registration-route", "empty-input-title"))));
                                              }
                                            },
                                            style: OutlinedButton.styleFrom(
                                                side: BorderSide(width: 2.0, color: (dark_theme) ? Colors.white : Colors.black),
                                                foregroundColor: (dark_theme) ? Colors.black : Colors.white,
                                                backgroundColor: (dark_theme) ? Colors.white : Colors.black,
                                                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))
                                            ),
                                            child: (loadingState) ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)) : Text(localization.CivicLocale.translate(deviceLocale, "registration-route", "login-button-label"))
                                        )
                                    )
                                )
                              ]
                          )
                      );
                    } else if (snapshot.hasError) {
                      return ErrorRoute(message: localization.CivicLocale.translate(deviceLocale, "registration-route", "failed-to-fetch"), requestUpdate: setState);
                    }
                    return LoadingRoute();
                  }
                )
            )
        )
    );
  }
}