import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:icafeplay/dialogs.dart';
import 'package:icafeplay/error_route.dart';
import 'package:icafeplay/loading_route.dart';
import 'package:icafeplay/models.dart' as models;
import 'package:icafeplay/gateway.dart' as gateway;
import 'package:icafeplay/storage.dart' as storage;
import 'package:icafeplay/localization.dart' as localization;

class BankCardsRoute extends StatefulWidget {
  final models.Center center;
  final models.BankCardWithToken? bank_card;
  final String? processor;
  const BankCardsRoute({super.key, required this.center, this.bank_card, this.processor});

  @override
  State<BankCardsRoute> createState() => BankCardsRouteRouteState();
}

class BankCardsRouteRouteState extends State<BankCardsRoute> {
  String deviceLocale = Platform.localeName.split('_')[0].toUpperCase();
  bool dark_theme = true;

  bool loadingState = false;
  bool waitingForOTP = false;
  bool allowCodeResend = false;
  int timerCounter = 60;

  TextEditingController cardNumberFieldController = TextEditingController();
  TextEditingController expiryDateFieldController = TextEditingController();
  TextEditingController cardHolderFieldController = TextEditingController();
  TextEditingController phoneNumberFieldController = TextEditingController();
  TextEditingController cardCVVFieldController = TextEditingController();
  TextEditingController cardOTPFieldController = TextEditingController();

  String? paymentProcessor = "PAYCOM";
  String? countryCode = "UZ";
  String? currencyCode = "UZS";

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
                  deviceLocale = token.user.language!;
                  if (token.user.dark_theme != null) dark_theme = token.user.dark_theme!;
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
                        child: (widget.bank_card == null) ? ListView(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(localization.CivicLocale.translate(deviceLocale, "bank-cards-route", "bank-cards-route-title"), style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black)),
                                      // Padding(
                                      //   padding: const EdgeInsets.only(bottom: 10.0),
                                      //   child: Text(localization.CivicLocale.translate(deviceLocale, "bank-cards-route", "bank-cards-route-subtitle"), style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold))
                                      // ),
                                      // Wrap(
                                      //   children: <Widget>[
                                      //     Row(
                                      //       children: <Widget>[
                                      //         (widget.center.allow_topup_uz) ? Expanded(
                                      //           child: InkWell(
                                      //             onTap: () {
                                      //               setState(() {
                                      //                 paymentProcessor = "PAYCOM";
                                      //                 countryCode = "UZ";
                                      //                 currencyCode = "UZS";
                                      //               });
                                      //             },
                                      //             child: Container(
                                      //               padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                      //               decoration: BoxDecoration(
                                      //                 color: (paymentProcessor == "PAYCOM") ? Colors.grey.shade300 : Colors.transparent,
                                      //                 borderRadius: BorderRadius.circular(10.0),
                                      //               ),
                                      //               child: Image.asset("assets/payme.png", fit: BoxFit.contain)
                                      //             ),
                                      //           )
                                      //         ) : const SizedBox.shrink()
                                      //       ]
                                      //     )
                                      //   ]
                                      // ),
                                      (paymentProcessor == null) ? const SizedBox.shrink() : Wrap(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 10.0, top: 20.0),
                                            child: Text(localization.CivicLocale.translate(deviceLocale, "bank-cards-route", "bank-cards-card-details-label"), style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black))
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: TextField(
                                                    autocorrect: false,
                                                    keyboardType: TextInputType.number,
                                                    controller: cardNumberFieldController,
                                                    style: TextStyle(fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black),
                                                    decoration: InputDecoration(
                                                        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                                                        enabledBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.white : Colors.black),
                                                            borderRadius: BorderRadius.zero
                                                        ),
                                                        focusedBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.white54 : Colors.black54),
                                                            borderRadius: BorderRadius.zero
                                                        ),
                                                        hintText: localization.CivicLocale.translate(deviceLocale, "bank-cards-route", "bank-cards-card-details-input-hint"),
                                                        hintStyle: const TextStyle(color: Colors.grey)
                                                    )
                                                ),
                                              ),
                                              const SizedBox(width: 10.0),
                                              Expanded(
                                                flex: 1,
                                                child: TextField(
                                                    autocorrect: false,
                                                    keyboardType: TextInputType.number,
                                                    controller: expiryDateFieldController,
                                                    onChanged: (value) {
                                                      if (value.length == 2) {
                                                        expiryDateFieldController.text = value + '/';
                                                      }
                                                    },
                                                    style: TextStyle(fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black),
                                                    decoration: InputDecoration(
                                                        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                                                        enabledBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.white : Colors.black),
                                                            borderRadius: BorderRadius.zero
                                                        ),
                                                        focusedBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.white54 : Colors.black54),
                                                            borderRadius: BorderRadius.zero
                                                        ),
                                                        hintText: localization.CivicLocale.translate(deviceLocale, "bank-cards-route", "bank-cards-card-expiry-input-hint"),
                                                        hintStyle: const TextStyle(color: Colors.grey)
                                                    )
                                                )
                                              )
                                            ]
                                          ),
                                          (paymentProcessor == "YOOKASSA") ? Padding(
                                            padding: const EdgeInsets.only(top: 10.0),
                                            child: TextField(
                                              autocorrect: false,
                                              keyboardType: TextInputType.number,
                                              controller: cardCVVFieldController,
                                              style: TextStyle(fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black),
                                              decoration: InputDecoration(
                                                contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.white : Colors.black),
                                                  borderRadius: BorderRadius.zero
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.white54 : Colors.black54),
                                                  borderRadius: BorderRadius.zero
                                                ),
                                                hintText: "CVV/CSC",
                                                hintStyle: const TextStyle(color: Colors.grey)
                                              )
                                            )
                                          ) : const SizedBox.shrink(),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10.0),
                                            child: TextField(
                                              autocorrect: false,
                                              controller: cardHolderFieldController,
                                              style: TextStyle(fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black),
                                              decoration: InputDecoration(
                                                contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.white : Colors.black),
                                                  borderRadius: BorderRadius.zero
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.white54 : Colors.black54),
                                                  borderRadius: BorderRadius.zero
                                                ),
                                                hintText: localization.CivicLocale.translate(deviceLocale, "bank-cards-route", "bank-cards-name-on-card-input-hint"),
                                                hintStyle: const TextStyle(color: Colors.grey)
                                              )
                                            )
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10.0),
                                            child: TextField(
                                              autocorrect: false,
                                              onTap: () {
                                                phoneNumberFieldController.text += '+';
                                              },
                                              onChanged: (value) {
                                                if (value.isEmpty) {
                                                  phoneNumberFieldController.text += '+';
                                                }
                                              },
                                              keyboardType: TextInputType.number,
                                              controller: phoneNumberFieldController,
                                              style: TextStyle(fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black),
                                              decoration: InputDecoration(
                                                contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.white : Colors.black),
                                                  borderRadius: BorderRadius.zero
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.white54 : Colors.black54),
                                                  borderRadius: BorderRadius.zero
                                                ),
                                                hintText: localization.CivicLocale.translate(deviceLocale, "bank-cards-route", "bank-cards-phone-input-hint"),
                                                hintStyle: const TextStyle(color: Colors.grey)
                                              )
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10.0),
                                            child: SizedBox(
                                                width: MediaQuery.of(context).size.width * 0.9,
                                                height: MediaQuery.of(context).size.height * 0.06,
                                                child: OutlinedButton(
                                                    onPressed: () {
                                                      if (cardNumberFieldController.text.isNotEmpty && expiryDateFieldController.text.isNotEmpty && cardHolderFieldController.text.isNotEmpty && phoneNumberFieldController.text.isNotEmpty) {
                                                        setState(() {
                                                          cardNumberFieldController.text = cardNumberFieldController.text.replaceAll(' ', '');
                                                          loadingState = true;
                                                        });
                                                        gateway.createBankCard({
                                                          "processor_name": paymentProcessor,
                                                          "number": cardNumberFieldController.text,
                                                          "expiry_date": expiryDateFieldController.text,
                                                          "cvv": cardCVVFieldController.text,
                                                          "holder": cardHolderFieldController.text,
                                                          "phone_number": phoneNumberFieldController.text,
                                                          "country_code": countryCode,
                                                          "currency_code": currencyCode,
                                                          "user_id": token.user.user_id,
                                                          "center_id": widget.center.center_id
                                                        }).then((status) {
                                                          if (countryCode == "UZ") {
                                                            setState(() {
                                                              waitingForOTP = true;
                                                              loadingState = false;
                                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localization.CivicLocale.translate(deviceLocale, "bank-cards-route", "verification-code-sent-text"))));
                                                              Timer.periodic(const Duration(seconds: 1), (timer) {
                                                                if (context.mounted) {
                                                                  setState(() {
                                                                    timer.tick;
                                                                    timerCounter--;
                                                                    if (timerCounter <= 0) {
                                                                      allowCodeResend = true;
                                                                      timer.cancel();
                                                                    }
                                                                  });
                                                                }
                                                              });
                                                            });
                                                          } else if (countryCode == "RU") {
                                                            setState(() {
                                                              Navigator.of(context).pop(true);
                                                              loadingState = false;
                                                            });
                                                          }
                                                        }).catchError((error) {
                                                          setState(() {
                                                            loadingState = false;
                                                          });
                                                          showMessageDialog(context, localization.CivicLocale.translate(deviceLocale, "dialogs", "bank-cards-route-card-create-error-title"), token.user, success: false, comment: error.toString());
                                                        });
                                                      }
                                                      else {
                                                        showMessageDialog(context, localization.CivicLocale.translate(deviceLocale, "dialogs", "bank-cards-empty-inputs-title"), token.user, success: false, comment: localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-empty-inputs-subtitle"));
                                                      }
                                                    },
                                                    style: OutlinedButton.styleFrom(
                                                        side: BorderSide(width: 2.0, color: (dark_theme) ? Colors.white : Colors.black),
                                                        foregroundColor: (dark_theme) ? Colors.black : Colors.white,
                                                        backgroundColor: (dark_theme) ? const Color(0xFFEEEEEE) : Colors.black,
                                                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0))
                                                    ),
                                                    child: (loadingState) ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)) : Text(localization.CivicLocale.translate(deviceLocale, "bank-cards-route", "bank-cards-first-step-button-label"))
                                                )
                                            )
                                          ),
                                          (waitingForOTP) ? Padding(
                                            padding: const EdgeInsets.only(bottom: 10.0, top: 20.0),
                                            child: Text(localization.CivicLocale.translate(deviceLocale, "bank-cards-route", "verification-code-timeout-label") + " ($timerCounter)", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black))
                                          ) : const SizedBox.shrink(),
                                          (waitingForOTP) ? TextField(
                                            autocorrect: false,
                                            keyboardType: TextInputType.number,
                                            controller: cardOTPFieldController,
                                            style: TextStyle(fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black),
                                            decoration: InputDecoration(
                                              contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.white : Colors.black),
                                                borderRadius: BorderRadius.zero
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.white54 : Colors.black54),
                                                borderRadius: BorderRadius.zero
                                              ),
                                              hintText: localization.CivicLocale.translate(deviceLocale, "bank-cards-route", "verification-code-input-label"),
                                              hintStyle: const TextStyle(color: Colors.grey)
                                            )
                                          ) : const SizedBox.shrink(),
                                          (waitingForOTP) ? Padding(
                                            padding: const EdgeInsets.only(top: 10.0),
                                            child: SizedBox(
                                                width: MediaQuery.of(context).size.width * 0.9,
                                                height: MediaQuery.of(context).size.height * 0.06,
                                                child: OutlinedButton(
                                                    onPressed: () {
                                                      if (cardOTPFieldController.text.isNotEmpty) {
                                                        setState(() {
                                                          loadingState = true;
                                                        });
                                                        gateway.verifyBankCard({
                                                          "processor_name": paymentProcessor,
                                                          "number": cardNumberFieldController.text,
                                                          "expiry_date": expiryDateFieldController.text,
                                                          "holder": cardHolderFieldController.text,
                                                          "phone_number": phoneNumberFieldController.text,
                                                          "country_code": countryCode,
                                                          "currency_code": currencyCode,
                                                          "code": cardOTPFieldController.text,
                                                          "user_id": token.user.user_id,
                                                          "center_id": widget.center.center_id
                                                        }).then((status) {
                                                          setState(() {
                                                            Navigator.of(context).pop(true);
                                                            loadingState = false;
                                                          });
                                                        }).catchError((error) {
                                                          setState(() {
                                                            loadingState = false;
                                                          });
                                                          showMessageDialog(context, localization.CivicLocale.translate(deviceLocale, "dialogs", "bank-cards-verify-card-fail-title"), token.user, success: false, comment: error.toString());
                                                        });
                                                      }
                                                      else {
                                                        showMessageDialog(context, localization.CivicLocale.translate(deviceLocale, "dialogs", "bank-cards-empty-inputs-title"), token.user, success: false, comment: localization.CivicLocale.translate(deviceLocale, "dialogs", "bank-cards-empty-inputs-subtitle"));
                                                      }
                                                    },
                                                    style: OutlinedButton.styleFrom(
                                                        side: BorderSide(width: 2.0, color: (dark_theme) ? const Color(0xFFEEEEEE) : Colors.black),
                                                        foregroundColor: (dark_theme) ? Colors.black : Colors.white,
                                                        backgroundColor: (dark_theme) ? const Color(0xFFEEEEEE) : Colors.black,
                                                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0))
                                                    ),
                                                    child: (loadingState) ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)) : Text(localization.CivicLocale.translate(deviceLocale, "bank-cards-route", "bank-cards-second-step-button-label"))
                                                )
                                            )
                                          ) : const SizedBox.shrink(),
                                          (waitingForOTP) ? Padding(
                                            padding: const EdgeInsets.only(top: 10.0),
                                            child: SizedBox(
                                                width: MediaQuery.of(context).size.width * 0.9,
                                                height: MediaQuery.of(context).size.height * 0.06,
                                                child: OutlinedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        loadingState = true;
                                                      });
                                                      gateway.resendVerificationCode({
                                                        "processor_name": paymentProcessor,
                                                        "number": cardNumberFieldController.text,
                                                        "center_id": widget.center.center_id
                                                      }).then((status) {
                                                        setState(() {
                                                          loadingState = false;
                                                          allowCodeResend = false;
                                                          timerCounter = 60;
                                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localization.CivicLocale.translate(deviceLocale, "bank-cards-route", "verification-code-resent-text"))));
                                                          Timer.periodic(const Duration(seconds: 1), (timer) {
                                                            if (context.mounted) {
                                                              setState(() {
                                                                timer.tick;
                                                                timerCounter--;
                                                                if (timerCounter <= 0) {
                                                                  allowCodeResend = true;
                                                                  timer.cancel();
                                                                }
                                                              });
                                                            }
                                                          });
                                                        });
                                                      }).catchError((error) {
                                                        setState(() {
                                                          loadingState = false;
                                                        });
                                                        showMessageDialog(context, localization.CivicLocale.translate(deviceLocale, "dialogs", "bank-cards-verification-code-send-fail"), token.user, success: false, comment: error.toString());
                                                      });
                                                    },
                                                    style: OutlinedButton.styleFrom(
                                                        foregroundColor: (dark_theme) ? Colors.black : Colors.white,
                                                        backgroundColor: (allowCodeResend) ? (dark_theme) ? const Color(0xFFEEEEEE) : Colors.black : (dark_theme) ? Colors.white38 : Colors.black38,
                                                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0))
                                                    ),
                                                    child: (loadingState) ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)) : Text(localization.CivicLocale.translate(deviceLocale, "bank-cards-route", "verification-code-resend-button-label") + " ($timerCounter)")
                                                )
                                            )
                                          ) : const SizedBox.shrink(),
                                        ]
                                      )
                                    ]
                                  )
                              )
                            ]
                        )
                        : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Text(localization.CivicLocale.translate(deviceLocale, "bank-cards-route", "link-bank-card-title"), style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black)),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Text(localization.CivicLocale.translate(deviceLocale, "bank-cards-route", "link-bank-card-subtitle"), style: TextStyle(fontSize: 14.0, color: Colors.grey))
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  height: MediaQuery.of(context).size.height * 0.06,
                                  child: OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          loadingState = true;
                                        });
                                        gateway.linkBankCard({
                                          "processor_name": widget.processor!,
                                          "bank_card_id": widget.bank_card!.bank_card_id,
                                          "center_id": widget.center.center_id
                                        }).then((status) {
                                          setState(() {
                                            waitingForOTP = true;
                                            loadingState = false;
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localization.CivicLocale.translate(deviceLocale, "bank-cards-route", "verification-code-sent-text"))));
                                            Timer.periodic(const Duration(seconds: 1), (timer) {
                                              if (context.mounted) {
                                                setState(() {
                                                  timer.tick;
                                                  timerCounter--;
                                                  if (timerCounter <= 0) {
                                                    allowCodeResend = true;
                                                    timer.cancel();
                                                  }
                                                });
                                              }
                                            });
                                          });
                                        }).catchError((error) {
                                          setState(() {
                                            loadingState = false;
                                          });
                                          showMessageDialog(context, localization.CivicLocale.translate(deviceLocale, "dialogs", "bank-cards-failed-to-link"), token.user, success: false, comment: error.toString());
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                          side: BorderSide(width: 2.0, color: (dark_theme) ? const Color(0xFFEEEEEE) : Colors.black),
                                          foregroundColor: (dark_theme) ? Colors.black : Colors.white,
                                          backgroundColor: (dark_theme) ? const Color(0xFFEEEEEE) : Colors.black,
                                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0))
                                      ),
                                      child: (loadingState) ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)) : Text(localization.CivicLocale.translate(deviceLocale, "bank-cards-route", "link-bank-card-button-label"))
                                  )
                              )
                            ),
                            (waitingForOTP) ? Padding(
                              padding: const EdgeInsets.only(bottom: 10.0, top: 20.0),
                              child: Text(localization.CivicLocale.translate(deviceLocale, "bank-cards-route", "verification-code-timeout-label") + " ($timerCounter)", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black))
                            ) : const SizedBox.shrink(),
                            (waitingForOTP) ? TextField(
                              autocorrect: false,
                              keyboardType: TextInputType.number,
                              controller: cardOTPFieldController,
                              style: TextStyle(fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.white : Colors.black),
                                  borderRadius: BorderRadius.zero
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.white54 : Colors.black54),
                                  borderRadius: BorderRadius.zero
                                ),
                                hintText: localization.CivicLocale.translate(deviceLocale, "bank-cards-route", "verification-code-input-label")
                              )
                            ) : const SizedBox.shrink(),
                            (waitingForOTP) ? Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  height: MediaQuery.of(context).size.height * 0.06,
                                  child: OutlinedButton(
                                      onPressed: () {
                                        if (cardOTPFieldController.text.isNotEmpty) {
                                          setState(() {
                                            loadingState = true;
                                          });
                                          gateway.verifyBankCard({
                                            "processor_name": widget.processor!,
                                            "number": widget.bank_card!.number,
                                            "code": cardOTPFieldController.text,
                                            "center_id": widget.center.center_id
                                          }).then((status) {
                                            setState(() {
                                              waitingForOTP = false;
                                              loadingState = false;
                                              allowCodeResend = false;
                                              timerCounter = 0;

                                              Navigator.of(context).pop();
                                            });
                                          }).catchError((error) {
                                            setState(() {
                                              loadingState = false;
                                            });
                                            showMessageDialog(context, localization.CivicLocale.translate(deviceLocale, "dialogs", "bank-cards-verify-card-fail-title"), token.user, success: false, comment: error.toString());
                                          });
                                        }
                                        else {
                                          showMessageDialog(context, localization.CivicLocale.translate(deviceLocale, "dialogs", "bank-cards-empty-inputs-title"), token.user, success: false, comment: localization.CivicLocale.translate(deviceLocale, "dialogs", "bank-cards-empty-inputs-subtitle"));
                                        }
                                      },
                                      style: OutlinedButton.styleFrom(
                                          side: BorderSide(width: 2.0, color: (dark_theme) ? const Color(0xFFEEEEEE) : Colors.black),
                                          foregroundColor: Colors.white,
                                          backgroundColor: (dark_theme) ? const Color(0xFFEEEEEE) : Colors.black,
                                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0))
                                      ),
                                      child: (loadingState) ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)) : Text(localization.CivicLocale.translate(deviceLocale, "bank-cards-route", "bank-cards-second-step-button-label"), style: TextStyle(color: (dark_theme) ? Colors.black : Colors.white))
                                  )
                              )
                            ) : const SizedBox.shrink(),
                            (waitingForOTP) ? Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  height: MediaQuery.of(context).size.height * 0.06,
                                  child: OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          loadingState = true;
                                        });
                                        gateway.resendVerificationCode({
                                          "processor_name": widget.processor!,
                                          "number": widget.bank_card!.number,
                                          "center_id": widget.center.center_id
                                        }).then((status) {
                                          setState(() {
                                            loadingState = false;
                                            allowCodeResend = false;
                                            timerCounter = 60;
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localization.CivicLocale.translate(deviceLocale, "bank-cards-route", "verification-code-resent-text"))));
                                            Timer.periodic(const Duration(seconds: 1), (timer) {
                                              if (context.mounted) {
                                                setState(() {
                                                  timer.tick;
                                                  timerCounter--;
                                                  if (timerCounter <= 0) {
                                                    allowCodeResend = true;
                                                    timer.cancel();
                                                  }
                                                });
                                              }
                                            });
                                          });
                                        }).catchError((error) {
                                          setState(() {
                                            loadingState = false;
                                          });
                                          showMessageDialog(context, localization.CivicLocale.translate(deviceLocale, "dialogs", "bank-cards-verification-code-send-fail"), token.user, success: false, comment: error.toString());
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                          foregroundColor: (dark_theme) ? Colors.black : Colors.white,
                                          backgroundColor: (allowCodeResend) ? (dark_theme) ? Colors.white : Colors.black : (dark_theme) ? Colors.white38 : Colors.black38,
                                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0))
                                      ),
                                      child: (loadingState) ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)) : Text(localization.CivicLocale.translate(deviceLocale, "bank-cards-route", "verification-code-resend-button-label") + " ($timerCounter)", style: TextStyle(color: (dark_theme) ? Colors.black : Colors.white))
                                  )
                              )
                            ) : const SizedBox.shrink(),
                          ]
                        )
                      )
                  );
                } else if (snapshot.hasError) {
                  return ErrorRoute(message: localization.CivicLocale.translate(deviceLocale, "bank-cards-route", "link-bank-card-failed-to-fetch"), requestUpdate: setState);
                }
                return LoadingRoute(dark_theme: dark_theme);
              }
          )
      ),
    );
  }
}