import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:icafeplay/dialogs.dart';
import 'package:icafeplay/error_route.dart';
import 'package:icafeplay/loading_route.dart';
import 'package:icafeplay/models.dart' as models;
import 'package:icafeplay/gateway.dart' as gateway;
import 'package:icafeplay/storage.dart' as storage;
import 'package:icafeplay/localization.dart' as localization;

class SettingsRoute extends StatefulWidget {
  const SettingsRoute({super.key});

  @override
  State<SettingsRoute> createState() => SettingsRouteState();
}

class SettingsRouteState extends State<SettingsRoute> {
  String deviceLocale = Platform.localeName.split('_')[0].toUpperCase();
  bool dark_theme = true;
  bool loadingState = false;
  TextEditingController nameFieldController = TextEditingController();
  TextEditingController newPasswordFieldController = TextEditingController();
  TextEditingController oldPasswordFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        future: storage.readStringData("userToken"),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            models.UserToken token = models.UserToken.convert(json.decode(snapshot.data));
            if (token.user.dark_theme != null) {
              dark_theme = token.user.dark_theme!;
            }
            return Scaffold(
                resizeToAvoidBottomInset: true,
                appBar: AppBar(
                    backgroundColor: (dark_theme) ? Colors.black87 : Colors.white,
                    leading: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.arrow_back, color: (dark_theme) ? Colors.white : Colors.black),
                    )
                ),
                body: Container(
                  color: (dark_theme) ? Colors.black87 : Colors.white,
                  padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
                  child: ListView(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: Text(localization.CivicLocale.translate(token.user.language, "settings-route", "change-name-section-title"), style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black)),
                              ),
                              Text(localization.CivicLocale.translate(token.user.language, "settings-route", "change-name-section-label"), style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: (dark_theme) ? Colors.white : Colors.black)),
                              Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: TextField(
                                      autocorrect: false,
                                      controller: nameFieldController,
                                      style: TextStyle(fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black),
                                      decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.grey : Colors.black),
                                              borderRadius: BorderRadius.zero
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.grey : Colors.black54),
                                              borderRadius: BorderRadius.zero
                                          ),
                                          hintText: localization.CivicLocale.translate(token.user.language, "settings-route", "change-name-section-input-hint")
                                      )
                                  )
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(top: 15.0),
                                  child: SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.9,
                                      height: MediaQuery.of(context).size.height * 0.07,
                                      child: OutlinedButton(
                                          onPressed: (){
                                            setState(() {
                                              loadingState = true;
                                              gateway.editUser({"name": nameFieldController.text, "is_active": token.user.is_active, "language": token.user.language, "dark_theme": token.user.dark_theme}, token.user.user_id).then((status) {
                                                gateway.fetchUserToken(token.user_token_id).then((token) {
                                                  setState(() {
                                                    loadingState = false;
                                                    storage.writeStringData("userToken", json.encode(token));
                                                    showMessageDialog(context, localization.CivicLocale.translate(token["user"]["language"], "dialogs", "settings-success-title"), models.User.convert(token["user"]), success: true, comment: localization.CivicLocale.translate(token["user"]["language"], "dialogs", "settings-account-change-success-caption"));
                                                  });
                                                }).catchError((error) {
                                                  setState(() {
                                                    loadingState = false;
                                                    showMessageDialog(context, localization.CivicLocale.translate(token.user.language, "dialogs", "settings-fail-title"), token.user, success: false, comment: localization.CivicLocale.translate(token.user.language, "dialogs", "settings-account-change-fail-caption"));
                                                  });
                                                });
                                              }).catchError((error) {
                                                setState(() {
                                                  loadingState = false;
                                                  showMessageDialog(context, localization.CivicLocale.translate(token.user.language, "dialogs", "settings-fail-title"), token.user, success: false, comment: localization.CivicLocale.translate(token.user.language, "dialogs", "settings-account-change-fail-caption"));
                                                });
                                              });
                                            });
                                          },
                                          style: OutlinedButton.styleFrom(
                                              side: const BorderSide(width: 0.0, color: Colors.transparent),
                                              foregroundColor: (dark_theme) ? Colors.black : Colors.white,
                                              backgroundColor: (dark_theme) ? const Color(0xFFEEEEEE) : Colors.black,
                                              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))
                                          ),
                                          child: (loadingState) ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)) : Text(localization.CivicLocale.translate(token.user.language, "settings-route", "change-name-section-button-label"))
                                      )
                                  )
                              )
                            ]
                          ),
                        ),
                        Container(
                          color: (dark_theme) ? Colors.black26 : Colors.black12,
                          height: MediaQuery.of(context).size.height * 0.05,
                          margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02, bottom: MediaQuery.of(context).size.height * 0.02)
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: Text(localization.CivicLocale.translate(token.user.language, "settings-route", "language-section-title"), style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black)),
                              ),
                              Text(localization.CivicLocale.translate(token.user.language, "settings-route", "language-section-label"), style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: (dark_theme) ? Colors.white : Colors.black)),
                              Padding(
                                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                                  child: DropdownMenu(
                                    textStyle: TextStyle(color: (dark_theme) ? Colors.white : Colors.black),
                                    width: MediaQuery.of(context).size.width * 0.9,
                                    initialSelection: token.user.language,
                                    onSelected: (value) {
                                      setState(() {
                                        loadingState = true;
                                        gateway.editUser({"name": token.user.name, "is_active": token.user.is_active, "language": value, "dark_theme": token.user.dark_theme}, token.user.user_id).then((status) {
                                          gateway.fetchUserToken(token.user_token_id).then((token) {
                                            setState(() {
                                              loadingState = false;
                                              storage.writeStringData("userToken", json.encode(token));
                                              showMessageDialog(context, localization.CivicLocale.translate(token["user"]["language"], "dialogs", "settings-success-title"), models.User.convert(token["user"]), success: true, comment: localization.CivicLocale.translate(token["user"]["language"], "dialogs", "settings-language-change-success-caption"));
                                            });
                                          }).catchError((error) {
                                            setState(() {
                                              loadingState = false;
                                              showMessageDialog(context, localization.CivicLocale.translate(token.user.language, "dialogs", "settings-fail-title"), token.user, success: false, comment: localization.CivicLocale.translate(token.user.language, "dialogs", "settings-language-change-fail-caption"));
                                            });
                                          });
                                        }).catchError((error) {
                                          setState(() {
                                            loadingState = false;
                                            showMessageDialog(context, localization.CivicLocale.translate(token.user.language, "dialogs", "settings-fail-title"), token.user, success: false, comment: localization.CivicLocale.translate(token.user.language, "dialogs", "settings-language-change-fail-caption"));
                                          });
                                        });
                                      });
                                    },
                                    dropdownMenuEntries: const <DropdownMenuEntry>[
                                      DropdownMenuEntry(value: "EN", label: "English"),
                                      DropdownMenuEntry(value: "RU", label: "Русский")
                                    ],
                                  )
                              ),
                              Text(localization.CivicLocale.translate(token.user.language, "settings-route", "dark-theme-section-label"), style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: (dark_theme) ? Colors.white : Colors.black)),
                              Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: DropdownMenu(
                                    textStyle: TextStyle(color: (dark_theme) ? Colors.white : Colors.black),
                                    width: MediaQuery.of(context).size.width * 0.9,
                                    initialSelection: token.user.dark_theme,
                                    onSelected: (value) {
                                      setState(() {
                                        loadingState = true;
                                        gateway.editUser({"name": token.user.name, "is_active": token.user.is_active, "language": token.user.language, "dark_theme": value}, token.user.user_id).then((status) {
                                          gateway.fetchUserToken(token.user_token_id).then((token) {
                                            setState(() {
                                              loadingState = false;
                                              storage.writeStringData("userToken", json.encode(token));
                                              showMessageDialog(context, localization.CivicLocale.translate(token["user"]["language"], "dialogs", "settings-success-title"), models.User.convert(token["user"]), success: true, comment: localization.CivicLocale.translate(token["user"]["language"], "dialogs", "settings-theme-change-success-caption"));
                                            });
                                          }).catchError((error) {
                                            setState(() {
                                              loadingState = false;
                                              showMessageDialog(context, localization.CivicLocale.translate(token.user.language, "dialogs", "settings-fail-title"), token.user, success: false, comment: localization.CivicLocale.translate(token.user.language, "dialogs", "settings-theme-change-fail-caption"));
                                            });
                                          });
                                        }).catchError((error) {
                                          setState(() {
                                            loadingState = false;
                                            showMessageDialog(context, localization.CivicLocale.translate(token.user.language, "dialogs", "settings-fail-title"), token.user, success: false, comment: localization.CivicLocale.translate(token.user.language, "dialogs", "settings-theme-change-fail-caption"));
                                          });
                                        });
                                      });
                                    },
                                    dropdownMenuEntries: <DropdownMenuEntry>[
                                      DropdownMenuEntry(value: true, label: localization.CivicLocale.translate(token.user.language, "settings-route", "theme-option-dark-label")),
                                      DropdownMenuEntry(value: false, label: localization.CivicLocale.translate(token.user.language, "settings-route", "theme-option-bright-label"))
                                    ],
                                  )
                              )
                            ]
                          ),
                        ),
                        Container(
                          color: (dark_theme) ? Colors.black26 : Colors.black12,
                          height: MediaQuery.of(context).size.height * 0.05,
                          margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02, bottom: MediaQuery.of(context).size.height * 0.02)
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: Text(localization.CivicLocale.translate(token.user.language, "settings-route", "password-reset-section-title"), style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black)),
                              ),
                              Text(localization.CivicLocale.translate(token.user.language, "settings-route", "password-reset-section-old-label"), style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: (dark_theme) ? Colors.white : Colors.black)),
                              Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: TextField(
                                      autocorrect: false,
                                      controller: oldPasswordFieldController,
                                      obscureText: true,
                                      style: TextStyle(fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black),
                                      decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.grey.shade500 : Colors.black),
                                              borderRadius: BorderRadius.zero
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.grey.shade500 : Colors.black54),
                                              borderRadius: BorderRadius.zero
                                          ),
                                          hintText: localization.CivicLocale.translate(token.user.language, "settings-route", "password-reset-section-old-input-hint")
                                      )
                                  )
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Text(localization.CivicLocale.translate(token.user.language, "settings-route", "password-reset-section-new-label"), style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: (dark_theme) ? Colors.white : Colors.black)),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: TextField(
                                      autocorrect: false,
                                      controller: newPasswordFieldController,
                                      obscureText: true,
                                      style: TextStyle(fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black),
                                      decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.grey.shade500 : Colors.black),
                                              borderRadius: BorderRadius.zero
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.grey.shade500 : Colors.black54),
                                              borderRadius: BorderRadius.zero
                                          ),
                                          hintText: localization.CivicLocale.translate(token.user.language, "settings-route", "password-reset-section-new-input-hint")
                                      )
                                  )
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(top: 15.0),
                                  child: SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.9,
                                      height: MediaQuery.of(context).size.height * 0.07,
                                      child: OutlinedButton(
                                          onPressed: (){
                                            setState(() {
                                              loadingState = true;
                                              gateway.editUserPassword({
                                                "old": oldPasswordFieldController.text,
                                                "new": newPasswordFieldController.text
                                              }, token.user.user_id).then((status) {
                                                setState(() {
                                                  loadingState = false;
                                                  showMessageDialog(context, localization.CivicLocale.translate(token.user.language, "dialogs", "settings-success-title"), token.user, success: true, comment: localization.CivicLocale.translate(token.user.language, "dialogs", "settings-password-change-success-caption"));
                                                });
                                              }).catchError((error) {
                                                setState(() {
                                                  loadingState = false;
                                                  showMessageDialog(context, localization.CivicLocale.translate(token.user.language, "dialogs", "settings-fail-title"), token.user, success: false, comment: localization.CivicLocale.translate(token.user.language, "dialogs", "settings-password-change-fail-caption"));
                                                });
                                              });
                                            });
                                          },
                                          style: OutlinedButton.styleFrom(
                                              side: const BorderSide(width: 2.0, color: Colors.black),
                                              foregroundColor: (dark_theme) ? Colors.black : Colors.white,
                                              backgroundColor: (dark_theme) ? const Color(0xFFEEEEEE) : Colors.black,
                                              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))
                                          ),
                                          child: (loadingState) ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)) : Text(localization.CivicLocale.translate(token.user.language, "settings-route", "password-reset-section-button-label"))
                                      )
                                  )
                              )
                            ]
                          )
                        )
                      ]
                  ),
                )
            );
          } else if (snapshot.hasError) {
            return ErrorRoute(message: "Could not load user data", requestUpdate: setState);
          }
          return LoadingRoute();
        }
      )
    );
  }
}