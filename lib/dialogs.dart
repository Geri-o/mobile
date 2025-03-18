import 'dart:io';
import 'package:flutter/material.dart';
import 'package:icafeplay/models.dart' as models;
import 'package:icafeplay/localization.dart' as localization;


void showMessageDialog(context, String message, user, {bool success = false, String comment = '', bool? popOnExit = false}) {
  String deviceLocale = Platform.localeName.split('_')[0].toUpperCase();
  bool dark_theme = true;
  if (user != "undefined") {
    if (user is! models.User) models.User.convert(user["user"]);
    if (user.language != null) deviceLocale = user.language!;
    if (user.dark_theme != null) dark_theme = user.dark_theme!;
  }

  if (success) {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))
          ),
          backgroundColor: (dark_theme) ? const Color(0xFF292929) : Colors.white,
          child: Padding(
              padding: const EdgeInsets.only(top: 30.0, bottom: 20.0, left: 20.0, right: 20.0),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100.0),
                          color: Colors.lightGreen
                        ),
                        padding: const EdgeInsets.all(30.0),
                        child: const Icon(Icons.done, color: Colors.white, size: 30.0)
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Center(child: Text(message, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: (dark_theme) ? Colors.white : Colors.black))),
                    ),
                    (comment.isNotEmpty) ? Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Center(child: Text(comment, textAlign: TextAlign.center, style: TextStyle(fontSize: 12.0, color: (dark_theme) ? Colors.white60 : Colors.black54))),
                    ) : const SizedBox.shrink(),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Align(
                          alignment: Alignment.bottomRight,
                          child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                if (popOnExit!) {
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "show-message-primary-button-label"), style: const TextStyle(fontSize: 14.0, color: Colors.grey))
                          )
                      ),
                    )
                  ]
              )
          )
      )
    );
  } else {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))
          ),
          backgroundColor: (dark_theme) ? const Color(0xFF292929) : Colors.white,
          child: Padding(
              padding: const EdgeInsets.only(top: 30.0, bottom: 20.0, left: 20.0, right: 20.0),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100.0),
                          color: Colors.red
                        ),
                        padding: const EdgeInsets.all(30.0),
                        child: const Icon(Icons.cancel, color: Colors.white, size: 30.0)
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Center(child: Text(message, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: (dark_theme) ? Colors.white : Colors.black))),
                    ),
                    (comment.isNotEmpty) ? Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Center(child: Text(comment, textAlign: TextAlign.center, style: TextStyle(fontSize: 12.0, color: (dark_theme) ? Colors.white60 : Colors.black54))),
                    ) : const SizedBox.shrink(),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Align(
                          alignment: Alignment.bottomRight,
                          child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                if (popOnExit!) {
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "show-message-primary-button-label"), style: const TextStyle(fontSize: 14.0, color: Colors.grey))
                          )
                      ),
                    )
                  ]
              )
          )
      )
    );
  }
}