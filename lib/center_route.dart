import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:icafeplay/bank_cards_route.dart';
import 'package:icafeplay/booking_route.dart';
import 'package:icafeplay/dialogs.dart';
import 'package:icafeplay/error_route.dart';
import 'package:icafeplay/hero_routes.dart';
import 'package:icafeplay/loading_route.dart';
import 'package:icafeplay/storage.dart' as storage;
import 'package:icafeplay/gateway.dart' as gateway;
import 'package:icafeplay/models.dart' as models;
import 'package:icafeplay/localization.dart' as localization;
import 'package:url_launcher/url_launcher.dart';

class CenterRoute extends StatefulWidget {
  final int center_id;
  const CenterRoute({super.key, required this.center_id});

  @override
  State<CenterRoute> createState() => CenterRouteState();
}

class CenterRouteState extends State<CenterRoute> {
  String deviceLocale = Platform.localeName.split('_')[0].toUpperCase();
  bool dark_theme = true;

  TextEditingController accountFieldController = TextEditingController();
  TextEditingController passwordFieldController = TextEditingController();
  TextEditingController cardOTPFieldController = TextEditingController();
  TextEditingController memberAccountFieldController = TextEditingController();
  TextEditingController bankCardFieldController = TextEditingController();
  TextEditingController topupAmountFieldController = TextEditingController();
  String? errorHint;
  String paymentProcessor = '-';
  String currencyCode = '-';
  bool loadingState = false;
  bool allowLinkBankCard = false;
  bool allowTopup = false;
  bool waitingForOTP = false;
  bool allowCodeResend = false;
  int timerCounter = 60;
  RegExp regExp = RegExp(r"(\d+\.\d{2})");

  models.BankCardWithToken? bank_card_with_token;

  bool user_is_authenticated = false;
  Map<String, dynamic> centerData = {};
  Future<Map<String, dynamic>> fetchCenterData(int center_id) async {
    centerData["center"] = await gateway.fetchSingleCenter(center_id);
    centerData["user"] = await storage.readStringData("userToken");
    user_is_authenticated = centerData["user"] != "undefined";
    if (user_is_authenticated) {
      centerData["user"] = json.decode(centerData["user"]);
      deviceLocale = centerData["user"]["user"]["language"];
      centerData["member"] = await gateway.fetchUserMember(centerData["user"]["user"]["user_id"], centerData["center"].center_id);
      if (centerData["member"] != null) centerData["member"] = await gateway.fetchUserMemberBalance(centerData["member"].member_id);
    }
    return centerData;
  }

  int activeImage = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        future: fetchCenterData(widget.center_id),
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!["user"] != "undefined") {
              if (snapshot.data!["user"]["user"]["dark_theme"] != null) dark_theme = snapshot.data!["user"]["user"]["dark_theme"];
            }
            return Scaffold(
                extendBodyBehindAppBar: true,
                appBar: AppBar(
                  forceMaterialTransparency: true,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  leading: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.keyboard_backspace,
                      color: Colors.white,
                      shadows: <Shadow>[Shadow(color: Colors.black54, blurRadius: 10.0)],
                    ),
                  ),
                ),
                body: Container(
                    color: (dark_theme) ? Colors.black87 : Colors.white,
                    child: ListView(
                        padding: EdgeInsets.zero,
                        children: <Widget>[
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 1,
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: (snapshot.data!["center"].image_files.isEmpty) ? Image.asset("assets/image.jpg", fit: BoxFit.cover) : PageView.builder(
                              itemCount: snapshot.data!["center"].image_files.length,
                              pageSnapping: true,
                              onPageChanged: (page) {
                                setState(() {
                                  activeImage = page;
                                });
                              },
                              itemBuilder: (context, pagePosition) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) => ImageHero(
                                          image_path: snapshot.data!["center"].image_files[activeImage].path,
                                          image_id: snapshot.data!["center"].image_files[activeImage].image_file_id
                                        )
                                      )
                                    );
                                  },
                                  child: Hero(
                                    tag: "image-${snapshot.data!["center"].image_files[activeImage].image_file_id}",
                                    child: CachedNetworkImage(
                                      imageUrl: "${gateway.ENDPOINT}/${snapshot.data!["center"].image_files[activeImage].path}",
                                      placeholder: (context, url) => Image.asset("assets/image-placeholder.gif", fit: BoxFit.cover),
                                      errorWidget: (context, url, error) => Image.asset("assets/image-placeholder.gif", fit: BoxFit.cover),
                                      fit: BoxFit.cover
                                    ),
                                  ),
                                );
                              }
                            )
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List<Widget>.generate(snapshot.data!["center"].image_files.length, (int index) => Container(
                                height: 5.0,
                                width: 15.0,
                                decoration: BoxDecoration(
                                  color: (activeImage == index) ? (dark_theme) ? Colors.grey : Colors.black : (dark_theme) ? Colors.grey.shade50 : Colors.grey
                                ),
                                margin: const EdgeInsets.only(right: 5.0)
                              ))
                            )
                          ),
                          Padding(
                              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(snapshot.data!["center"].display_name, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black)),
                                    (snapshot.data!["center"].description == null) ? const SizedBox.shrink() : Text(snapshot.data!["center"].description, style: const TextStyle(fontSize: 14.0, color: Colors.grey)),
                                    Container(
                                        margin: const EdgeInsets.only(top: 20.0),
                                        width: MediaQuery.of(context).size.width * 0.9,
                                        child: FilledButton(
                                          style: FilledButton.styleFrom(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                              padding: const EdgeInsets.symmetric(vertical: 15.0),
                                              backgroundColor: (user_is_authenticated) ? (dark_theme) ? const Color(0xFFEEEEEE) : Colors.black : (dark_theme) ? Colors.black : Colors.black54
                                          ),
                                          onPressed: () {
                                            if (user_is_authenticated) {
                                              if (snapshot.data!["member"] == null) {
                                                showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) => Dialog(
                                                        shape: const RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                        ),
                                                        backgroundColor: Colors.white,
                                                        child: StatefulBuilder(
                                                            builder: (BuildContext context, StateSetter updateState) {
                                                              return Padding(
                                                                  padding: const EdgeInsets.only(top: 30.0, bottom: 20.0, left: 25.0, right: 25.0),
                                                                  child: Column(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: <Widget>[
                                                                        Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "link-account-title"), style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                                                                        (errorHint == null) ? const SizedBox.shrink() : Padding(
                                                                            padding: const EdgeInsets.only(top: 10.0),
                                                                            child: Text(errorHint!, style: const TextStyle(color: Colors.red))
                                                                        ),
                                                                        Padding(
                                                                            padding: const EdgeInsets.only(top: 20.0),
                                                                            child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "link-account-input-label"))
                                                                        ),
                                                                        Padding(
                                                                            padding: const EdgeInsets.only(top: 10.0),
                                                                            child: TextField(
                                                                                autocorrect: false,
                                                                                controller: accountFieldController,
                                                                                style: const TextStyle(fontWeight: FontWeight.normal),
                                                                                decoration: InputDecoration(
                                                                                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                                                                                    enabledBorder: OutlineInputBorder(
                                                                                        borderSide: const BorderSide(width: 1.0),
                                                                                        borderRadius: BorderRadius.circular(10.0)
                                                                                    ),
                                                                                    focusedBorder: OutlineInputBorder(
                                                                                        borderSide: const BorderSide(width: 1.0, color: Colors.black54),
                                                                                        borderRadius: BorderRadius.circular(10.0)
                                                                                    ),
                                                                                    hintText: localization.CivicLocale.translate(deviceLocale, "dialogs", "link-account-input-hint")
                                                                                )
                                                                            )
                                                                        ),
                                                                        Padding(
                                                                            padding: const EdgeInsets.only(top: 20.0),
                                                                            child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "link-account-password-input-label"))
                                                                        ),
                                                                        Padding(
                                                                            padding: const EdgeInsets.only(top: 10.0),
                                                                            child: TextField(
                                                                                autocorrect: false,
                                                                                obscureText: true,
                                                                                controller: passwordFieldController,
                                                                                style: const TextStyle(fontWeight: FontWeight.normal),
                                                                                decoration: InputDecoration(
                                                                                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                                                                                    enabledBorder: OutlineInputBorder(
                                                                                        borderSide: const BorderSide(width: 1.0),
                                                                                        borderRadius: BorderRadius.circular(10.0)
                                                                                    ),
                                                                                    focusedBorder: OutlineInputBorder(
                                                                                        borderSide: const BorderSide(width: 1.0, color: Colors.black54),
                                                                                        borderRadius: BorderRadius.circular(10.0)
                                                                                    ),
                                                                                    hintText: localization.CivicLocale.translate(deviceLocale, "dialogs", "link-account-password-input-hint")
                                                                                )
                                                                            )
                                                                        ),
                                                                        Padding(
                                                                            padding: const EdgeInsets.only(top: 20.0),
                                                                            child: Row(
                                                                                children: <Widget>[
                                                                                  Expanded(
                                                                                      child: TextButton(
                                                                                          onPressed: () {
                                                                                            Navigator.of(context).pop();
                                                                                          },
                                                                                          style: TextButton.styleFrom(
                                                                                              backgroundColor: Colors.white,
                                                                                              foregroundColor: Colors.black
                                                                                          ),
                                                                                          child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "link-account-cancel-button-label"), style: const TextStyle(fontSize: 14.0))
                                                                                      )
                                                                                  ),
                                                                                  Expanded(
                                                                                      child: TextButton(
                                                                                          onPressed: () {
                                                                                            if (accountFieldController.text.isNotEmpty && passwordFieldController.text.isNotEmpty) {
                                                                                              updateState(() {
                                                                                                loadingState = true;
                                                                                                errorHint = null;
                                                                                                gateway.linkMemberAccount({
                                                                                                  "account": accountFieldController.text,
                                                                                                  "password": passwordFieldController.text,
                                                                                                  "user_id": snapshot.data!["user"]["user"]["user_id"],
                                                                                                  "center_id": snapshot.data!["center"].center_id
                                                                                                }).then((member) {
                                                                                                  updateState(() {
                                                                                                    loadingState = false;
                                                                                                    errorHint = null;
                                                                                                    centerData["member"] = member;
                                                                                                    Navigator.of(context).pop();
                                                                                                  });
                                                                                                }).catchError((error) {
                                                                                                  updateState(() {
                                                                                                    errorHint = error.toString();
                                                                                                    loadingState = false;
                                                                                                  });
                                                                                                });
                                                                                              });
                                                                                            } else {
                                                                                              updateState(() {
                                                                                                errorHint = localization.CivicLocale.translate(deviceLocale, "dialogs", "link-account-error-hint");
                                                                                              });
                                                                                            }
                                                                                          },
                                                                                          style: TextButton.styleFrom(
                                                                                              backgroundColor: Colors.black,
                                                                                              foregroundColor: Colors.white,
                                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))
                                                                                          ),
                                                                                          child: (loadingState) ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)) : Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-no-card-modal-primary-button-label"), style: const TextStyle(fontSize: 14.0))
                                                                                      )
                                                                                  )
                                                                                ]
                                                                            )
                                                                        )
                                                                      ]
                                                                  )
                                                              );
                                                            }
                                                        )
                                                    )
                                                );
                                              } else {
                                                showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        shape: const RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                        ),
                                                        backgroundColor: Colors.white,
                                                        title: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "unlink-account-title")),
                                                        content: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "unlink-account-subtitle")),
                                                        actions: <TextButton>[
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(context).pop();
                                                            },
                                                            child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "unlink-account-cancel-button-label")),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              gateway.unlinkMemberAccount(snapshot.data!["member"].member_id).then((status) {
                                                                setState(() {
                                                                  centerData["member"] = null;
                                                                  Navigator.of(context).pop();
                                                                });
                                                              }).catchError((error) {
                                                                Navigator.of(context).pop();
                                                                showMessageDialog(context, localization.CivicLocale.translate(deviceLocale, "dialogs", "unlink-account-fail-message"), snapshot.data!["user"], success: false, comment: error.toString());
                                                              });
                                                            },
                                                            child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "unlink-account-primary-button"), style: const TextStyle(color: Colors.red)),
                                                          )
                                                        ],
                                                      );
                                                    }
                                                ).whenComplete(() {
                                                  setState(() {});
                                                });
                                              }
                                            } else {
                                              showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) => Dialog(
                                                      shape: const RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                      ),
                                                      backgroundColor: Colors.white,
                                                      child: Padding(
                                                          padding: const EdgeInsets.only(top: 25.0, bottom: 20.0, left: 20.0, right: 20.0),
                                                          child: Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: <Widget>[
                                                                Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "link-account-unavailable-title"), style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 10.0),
                                                                  child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "link-account-unavailable-subtitle")),
                                                                ),
                                                                Align(
                                                                    alignment: Alignment.bottomRight,
                                                                    child: TextButton(
                                                                        onPressed: () {
                                                                          Navigator.of(context).pop();
                                                                        },
                                                                        child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "show-message-primary-button-label"), style: const TextStyle(fontSize: 14.0))
                                                                    )
                                                                )
                                                              ]
                                                          )
                                                      )
                                                  )
                                              );
                                            }
                                          },
                                          child: (snapshot.data!["member"] == null) ? Text(localization.CivicLocale.translate(deviceLocale, "center-route", "link-account-button-label"), style: TextStyle(color: (dark_theme) ? Colors.black : Colors.white)) : Text(localization.CivicLocale.translate(deviceLocale, "center-route", "link-account-button-label-alt") + ": ${snapshot.data!["member"].account}", style: TextStyle(color: (dark_theme) ? Colors.black : Colors.white)),
                                        )
                                    )
                                  ]
                              )
                          ),
                          Container(
                            color: Colors.black12,
                            height: MediaQuery.of(context).size.height * 0.05,
                          ),
                          Padding(
                              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    (snapshot.data!["member"] == null) ? const SizedBox.shrink() : Padding(
                                      padding: const EdgeInsets.only(bottom: 10.0),
                                      child: Text(localization.CivicLocale.translate(deviceLocale, "center-route", "center-account-title"), style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black)),
                                    ),
                                    (snapshot.data!["member"] == null) ? const SizedBox.shrink() : ExpansionTile(
                                        shape: const Border(),
                                        title: Text(localization.CivicLocale.translate(deviceLocale, "center-route", "center-account-subtitle"), style: TextStyle(color: (dark_theme) ? Colors.white : Colors.black)),
                                        collapsedIconColor: Colors.grey,
                                        iconColor: Colors.grey,
                                        children: <ListTile>[
                                          ListTile(
                                            title: Text(localization.CivicLocale.translate(deviceLocale, "center-route", "center-account-cash-balance-label"), style: TextStyle(fontSize: 14.0, color: (dark_theme) ? Colors.white : Colors.black)),
                                            trailing: Text(snapshot.data!["member"].cash_balance, style: TextStyle(fontSize: 12.0, color: (dark_theme) ? Colors.white : Colors.black))
                                          ),
                                          ListTile(
                                            title: Text(localization.CivicLocale.translate(deviceLocale, "center-route", "center-account-bonus-balance-label"), style: TextStyle(fontSize: 14.0, color: (dark_theme) ? Colors.white : Colors.black)),
                                            trailing: Text(snapshot.data!["member"].bonus_balance, style: TextStyle(fontSize: 12.0, color: (dark_theme) ? Colors.white : Colors.black))
                                          ),
                                          ListTile(
                                            title: Text(localization.CivicLocale.translate(deviceLocale, "center-route", "center-account-points-balance-label"), style: TextStyle(fontSize: 14.0, color: (dark_theme) ? Colors.white : Colors.black)),
                                            trailing: Text(snapshot.data!["member"].points_balance, style: TextStyle(fontSize: 12.0, color: (dark_theme) ? Colors.white : Colors.black))
                                          ),
                                          ListTile(
                                            title: Text(localization.CivicLocale.translate(deviceLocale, "center-route", "center-account-coins-balance-label"), style: TextStyle(fontSize: 14.0, color: (dark_theme) ? Colors.white : Colors.black)),
                                            trailing: Text(snapshot.data!["member"].coins_balance, style: TextStyle(fontSize: 12.0, color: (dark_theme) ? Colors.white : Colors.black))
                                          )
                                        ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
                                      child: Text(localization.CivicLocale.translate(deviceLocale, "center-route", "center-details-title"), style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black)),
                                    ),
                                    ExpansionTile(
                                        shape: const Border(),
                                        title: Text(localization.CivicLocale.translate(deviceLocale, "center-route", "center-details-offers-label"), style: TextStyle(color: (dark_theme) ? Colors.white : Colors.black)),
                                        collapsedIconColor: Colors.grey,
                                        iconColor: Colors.grey,
                                        children: List<Widget>.generate(snapshot.data!["center"].products.length, (int index) {
                                          if (snapshot.data!["center"].products[index].is_visible) {
                                            return ListTile(
                                              title: Text(snapshot.data!["center"].products[index].display_name, style: TextStyle(fontSize: 14.0, color: (dark_theme) ? Colors.white : Colors.black)),
                                              subtitle: Text((snapshot.data!["center"].products[index].price.isEmpty) ? '-' : regExp.firstMatch(snapshot.data!["center"].products[index].price)?.group(0) ?? snapshot.data!["center"].products[index].price, style: const TextStyle(fontSize: 12.0, color: Colors.grey))
                                            );
                                          } else {
                                            return const SizedBox.shrink();
                                          }
                                        }),
                                    ),
                                    ExpansionTile(
                                        shape: const Border(),
                                        title: Text(localization.CivicLocale.translate(deviceLocale, "center-route", "center-details-zones-label"), style: TextStyle(color: (dark_theme) ? Colors.white : Colors.black)),
                                        collapsedIconColor: Colors.grey,
                                        iconColor: Colors.grey,
                                        children: List<ExpansionTile>.generate(snapshot.data!["center"].zones.length, (index) => ExpansionTile(
                                            leading: const Icon(Icons.chevron_right),
                                            title: Text(snapshot.data!["center"].zones[index].name, style: TextStyle(fontSize: 14.0, color: (dark_theme) ? Colors.white : Colors.black)),
                                            collapsedIconColor: Colors.grey,
                                            iconColor: Colors.grey,
                                            shape: const Border(),
                                            children: <ListTile>[
                                              ListTile(
                                                title: Text((snapshot.data!["center"].zones[index].description == null) ? '-' : snapshot.data!["center"].zones[index].description, style: TextStyle(fontSize: 12.0, color: (dark_theme) ? Colors.white : Colors.black))
                                              ),
                                              ListTile(
                                                title: Text(snapshot.data!["center"].zones[index].specifications, style: TextStyle(fontSize: 12.0, color: (dark_theme) ? Colors.white : Colors.black))
                                              ),
                                              ListTile(
                                                  title: Text((snapshot.data!["center"].zones[index].computer_count == null) ? "0 PCs" : "${snapshot.data!['center'].zones[index].computer_count} PCs", style: TextStyle(fontSize: 12.0, color: (dark_theme) ? Colors.white : Colors.black))
                                              ),
                                            ],
                                        ))
                                    ),
                                    (snapshot.data!["center"].address == null) ? const SizedBox.shrink() : ExpansionTile(
                                        shape: const Border(),
                                        title: Text(localization.CivicLocale.translate(deviceLocale, "center-route", "center-details-address-label"), style: TextStyle(color: (dark_theme) ? Colors.white : Colors.black)),
                                        collapsedIconColor: Colors.grey,
                                        iconColor: Colors.grey,
                                        children: <ListTile>[
                                          ListTile(
                                            title: Text(localization.CivicLocale.translate(deviceLocale, "center-route", "center-details-address-label"), style: const TextStyle(fontSize: 12.0, color: Colors.black87)),
                                            trailing: Text(snapshot.data!["center"].address, style: const TextStyle(fontSize: 12.0)),
                                          )
                                        ]
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.only(top: 10.0),
                                        child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                  child: Container(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: FilledButton(
                                                        style: FilledButton.styleFrom(
                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                                            backgroundColor: (snapshot.data!["center"].phone_number == null) ? (dark_theme) ? Colors.grey : Colors.black54 : (dark_theme) ? const Color(0xFFEEEEEE) : Colors.black,
                                                            padding: const EdgeInsets.symmetric(vertical: 15.0)
                                                        ),
                                                        onPressed: () async {
                                                          if (snapshot.data!["center"].phone_number == null) return;
                                                          Uri phone_number = Uri.parse("tel:" + snapshot.data!["center"].phone_number);
                                                          if (await canLaunchUrl(phone_number)) {
                                                            await launchUrl(phone_number);
                                                          } else {
                                                            showMessageDialog(context, localization.CivicLocale.translate(deviceLocale, "center-route", "center-call-failed-title"), snapshot.data!["user"], success: false, comment: localization.CivicLocale.translate(deviceLocale, "center-route", "center-call-failed-subtitle"));
                                                          }
                                                        },
                                                        child: Text(localization.CivicLocale.translate(deviceLocale, "center-route", "center-call-button-label"), style: TextStyle(color: (dark_theme) ? Colors.black : Colors.white))
                                                    ),
                                                  )
                                              ),
                                              Expanded(
                                                  child: Container(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: FilledButton(
                                                        style: FilledButton.styleFrom(
                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                                            backgroundColor: (dark_theme) ? const Color(0xFFEEEEEE) : Colors.black,
                                                            padding: const EdgeInsets.symmetric(vertical: 15.0)
                                                        ),
                                                        onPressed: () {
                                                          launchUrl(Uri.parse("https://www.google.com/maps/search/?api=1&query=${snapshot.data!['center'].name}"), mode: LaunchMode.externalApplication);
                                                        },
                                                        child: Text(localization.CivicLocale.translate(deviceLocale, "center-route", "center-location-button-label"), style: TextStyle(color: (dark_theme) ? Colors.black : Colors.white))
                                                    ),
                                                  )
                                              )
                                            ]
                                        )
                                    )
                                  ]
                              )
                          ),
                          (snapshot.data!["center"].subcenters.length == 0) ? const SizedBox.shrink() : Container(
                            color: Colors.black12,
                            height: MediaQuery.of(context).size.height * 0.05,
                          ),
                          (snapshot.data!["center"].subcenters.length == 0) ? const SizedBox.shrink() : Padding(
                              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 20.0),
                                      child: Text(localization.CivicLocale.translate(deviceLocale, "center-route", "center-subcenters-title"), style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black)),
                                    ),
                                    for (models.Subcenter subcenter in snapshot.data!["center"].subcenters)
                                      InkWell(
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => CenterRoute(center_id: subcenter.center_id)));
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.only(bottom: 20.0),
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Container(
                                                      clipBehavior: Clip.hardEdge,
                                                      width: MediaQuery.of(context).size.width * 0.9,
                                                      height: MediaQuery.of(context).size.height * 0.2,
                                                      margin: const EdgeInsets.only(bottom: 10.0),
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(10.0)
                                                      ),
                                                      child: (subcenter.image_files.isEmpty) ? Image.asset("assets/image.jpg", fit: BoxFit.cover) : CachedNetworkImage(
                                                          imageUrl: "${gateway.ENDPOINT}/${subcenter.image_files[0].path}",
                                                          placeholder: (context, url) => Image.asset("assets/image-placeholder.gif", fit: BoxFit.cover),
                                                          errorWidget: (context, url, error) => Image.asset("assets/image-placeholder.gif", fit: BoxFit.cover),
                                                          fit: BoxFit.cover
                                                      )
                                                  ),
                                                  Text(subcenter.display_name, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black)),
                                                  Text(subcenter.country.name, style: const TextStyle(fontSize: 14.0, color: Colors.grey))
                                                ]
                                            ),
                                          )
                                      )
                                  ]
                              )
                          )
                        ]
                    )
                ),
                bottomNavigationBar: BottomAppBar(
                    padding: EdgeInsets.zero,
                    height: MediaQuery.of(context).size.height * 0.1,
                    color: (dark_theme) ? Colors.black87 : Colors.white,
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(width: 2.0, color: Colors.black12))
                      ),
                      child: Row(
                          children: <Widget>[
                            Expanded(
                                child: Container(
                                  height: MediaQuery.of(context).size.height * 0.1,
                                  padding: const EdgeInsets.all(10.0),
                                  child: FilledButton(
                                      style: FilledButton.styleFrom(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                          backgroundColor: (dark_theme) ? const Color(0xFFEEEEEE) : Colors.black
                                      ),
                                      onPressed: () {
                                        if (user_is_authenticated == false) {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) => Dialog(
                                                  shape: const RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                  ),
                                                  backgroundColor: Colors.white,
                                                  child: Padding(
                                                      padding: const EdgeInsets.only(top: 25.0, bottom: 20.0, left: 20.0, right: 20.0),
                                                      child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: <Widget>[
                                                            Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "link-account-unavailable-title"), style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                                                            Padding(
                                                              padding: const EdgeInsets.only(top: 10.0),
                                                              child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "link-account-unavailable-subtitle")),
                                                            ),
                                                            Align(
                                                                alignment: Alignment.bottomRight,
                                                                child: TextButton(
                                                                    onPressed: () {
                                                                      Navigator.of(context).pop();
                                                                    },
                                                                    child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "link-account-unavailable-primary-button-label"), style: const TextStyle(fontSize: 14.0))
                                                                )
                                                            )
                                                          ]
                                                      )
                                                  )
                                              )
                                          );
                                          return;
                                        }
                                        if (snapshot.data!["center"].allow_topup == false) {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                shape: const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                ),
                                                backgroundColor: (dark_theme) ? const Color(0xFF292929) : Colors.white,
                                                title: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "center-disabled-title"), style: TextStyle(color: (dark_theme) ? Colors.white : Colors.black)),
                                                content: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "center-disabled-subtitle"), style: TextStyle(color: (dark_theme) ? Colors.white : Colors.black)),
                                                actions: <TextButton>[
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "center-disabled-subtitle-primary-button")),
                                                  ),
                                                ],
                                              );
                                            }
                                          );
                                          return;
                                        }
                                        // if (snapshot.data!["bank_card"] == null) {
                                        //   showDialog(
                                        //       context: context,
                                        //       builder: (BuildContext context) => Dialog(
                                        //           shape: const RoundedRectangleBorder(
                                        //             borderRadius: BorderRadius.all(Radius.circular(10.0))
                                        //           ),
                                        //           child: Padding(
                                        //               padding: const EdgeInsets.only(top: 25.0, bottom: 20.0, left: 20.0, right: 20.0),
                                        //               child: Column(
                                        //                   mainAxisSize: MainAxisSize.min,
                                        //                   crossAxisAlignment: CrossAxisAlignment.start,
                                        //                   children: <Widget>[
                                        //                     const Text("No available bank cards!", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                                        //                     const Padding(
                                        //                       padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                                        //                       child: Text("You don't have any bank cards added, would you like to add one?"),
                                        //                     ),
                                        //                     Row(
                                        //                         mainAxisAlignment: MainAxisAlignment.end,
                                        //                         children: <Widget>[
                                        //                           TextButton(
                                        //                               onPressed: () {
                                        //                                 Navigator.of(context).pop();
                                        //                               },
                                        //                               child: const Text("Close", style: TextStyle(fontSize: 14.0, color: Colors.black38))
                                        //                           ),
                                        //                           TextButton(
                                        //                               onPressed: () {
                                        //                                 Navigator.of(context).pop();
                                        //                                 Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => BankCardsRoute(center: snapshot.data!["center"]))).then((status) {
                                        //                                   setState(() {});
                                        //                                 });
                                        //                               },
                                        //                               child: const Text("Add", style: TextStyle(fontSize: 14.0, color: Colors.blueAccent))
                                        //                           )
                                        //                         ]
                                        //                     )
                                        //                   ]
                                        //               )
                                        //           )
                                        //       )
                                        //   );
                                        // }
                                        paymentProcessor = '-';
                                        allowTopup = false;
                                        allowLinkBankCard = false;
                                        allowCodeResend = false;
                                        waitingForOTP = false;
                                        showModalBottomSheet(
                                          backgroundColor: (dark_theme) ? const Color(0xFF292929) : Colors.white,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(topLeft: Radius.circular(5.0), topRight: Radius.circular(5.0))
                                          ),
                                          isScrollControlled: true,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return StatefulBuilder(
                                              builder: (BuildContext context, StateSetter updateState) {
                                                return Padding(
                                                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                                  child: Container(
                                                    height: MediaQuery.of(context).size.height * 0.8,
                                                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                                    child: ListView(
                                                      children: <Widget>[
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 20.0),
                                                          child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-payment-method-label"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0, color: (dark_theme) ? Colors.white : Colors.black))
                                                        ),
                                                        const SizedBox(height: 20.0, width: 1.0),
                                                        (snapshot.data!["center"].allow_topup_uz) ? ListTile(
                                                          leading: Image.asset("assets/payme.png", fit: BoxFit.fitHeight, height: 40.0),
                                                          trailing: (loadingState) ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black)) : (paymentProcessor == "PAYCOM") ? const Icon(Icons.circle) : const Icon(Icons.circle_outlined, color: Colors.black54),
                                                          tileColor: (dark_theme) ? Colors.white : Colors.grey.shade300,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(5.0)
                                                          ),
                                                          onTap: () {
                                                            updateState(() {
                                                              allowLinkBankCard = false;
                                                              allowTopup = false;
                                                              loadingState = true;
                                                              paymentProcessor = "PAYCOM";
                                                              currencyCode = "UZS";
                                                            });
                                                            gateway.acquireBankCardWithToken({
                                                              "user_id": snapshot.data!["user"]["user"]["user_id"],
                                                              "center_id": snapshot.data!["center"].center_id,
                                                              "country_code": "UZ",
                                                              "processor_name": "PAYCOM"
                                                            }).then((bank_card) {
                                                              if (bank_card == null) {
                                                                updateState(() {
                                                                  loadingState = false;
                                                                  showDialog(
                                                                    context: context,
                                                                    builder: (BuildContext context) => Dialog(
                                                                        shape: const RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                                        ),
                                                                        backgroundColor: (dark_theme) ? const Color(0xFF292929) : Colors.white,
                                                                        child: Padding(
                                                                            padding: const EdgeInsets.only(top: 25.0, bottom: 20.0, left: 20.0, right: 20.0),
                                                                            child: Column(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: <Widget>[
                                                                                  Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-no-card-title"), style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black), textAlign: TextAlign.left),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                                                                                    child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-no-card-subtitle"), style: TextStyle(color: (dark_theme) ? Colors.white : Colors.black)),
                                                                                  ),
                                                                                  Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                                                      children: <Widget>[
                                                                                        TextButton(
                                                                                            onPressed: () {
                                                                                              Navigator.of(context).pop();
                                                                                            },
                                                                                            child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-no-card-secondary-button-label"), style: TextStyle(fontSize: 14.0, color: (dark_theme) ? Colors.grey : Colors.black38))
                                                                                        ),
                                                                                        TextButton(
                                                                                            onPressed: () {
                                                                                              Navigator.of(context).pop();
                                                                                              Navigator.of(context).pop();
                                                                                              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => BankCardsRoute(center: snapshot.data!["center"]))).then((status) {
                                                                                                setState(() {});
                                                                                              });
                                                                                            },
                                                                                            child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-no-card-primary-button-label"), style: const TextStyle(fontSize: 14.0, color: Colors.blueAccent))
                                                                                        )
                                                                                      ]
                                                                                  )
                                                                                ]
                                                                            )
                                                                        )
                                                                    )
                                                                  );
                                                                });
                                                              } else {
                                                                updateState(() {
                                                                  loadingState = false;
                                                                  allowLinkBankCard = true;
                                                                });
                                                                bank_card_with_token = bank_card;
                                                                for (models.BankCardToken token in bank_card.bank_card_tokens) {
                                                                  if (token.center_id == snapshot.data!["center"].center_id) {
                                                                    allowLinkBankCard = false;
                                                                  }
                                                                }
                                                                if (allowLinkBankCard == true) {
                                                                  showDialog(
                                                                    context: context,
                                                                    builder: (BuildContext context) => Dialog(
                                                                        shape: const RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                                        ),
                                                                        backgroundColor: (dark_theme) ? const Color(0xFF292929) : Colors.white,
                                                                        child: Padding(
                                                                            padding: const EdgeInsets.only(top: 25.0, bottom: 20.0, left: 20.0, right: 20.0),
                                                                            child: Column(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: <Widget>[
                                                                                  Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-no-card-modal-title"), style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black), textAlign: TextAlign.left),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                                                                                    child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-no-card-modal-subtitle"), style: TextStyle(color: (dark_theme) ? Colors.white : Colors.black)),
                                                                                  ),
                                                                                  Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                                                      children: <Widget>[
                                                                                        TextButton(
                                                                                            onPressed: () {
                                                                                              Navigator.of(context).pop();
                                                                                            },
                                                                                            child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-no-card-modal-secondary-button-label"), style: TextStyle(fontSize: 14.0, color: (dark_theme) ? Colors.white54 : Colors.black38))
                                                                                        ),
                                                                                        TextButton(
                                                                                            onPressed: () {
                                                                                              Navigator.of(context).pop();
                                                                                              Navigator.of(context).pop();
                                                                                              Navigator.push(
                                                                                                  context,
                                                                                                  MaterialPageRoute(
                                                                                                      builder: (BuildContext context) => BankCardsRoute(
                                                                                                          center: snapshot.data!["center"],
                                                                                                          bank_card: bank_card,
                                                                                                          processor: "PAYCOM"
                                                                                                      )
                                                                                                  )
                                                                                              ).then((status) {
                                                                                                setState(() {});
                                                                                              });
                                                                                            },
                                                                                            child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-no-card-modal-primary-button-label"), style: const TextStyle(fontSize: 14.0, color: Colors.blueAccent))
                                                                                        )
                                                                                      ]
                                                                                  )
                                                                                ]
                                                                            )
                                                                        )
                                                                    )
                                                                  );
                                                                  return;
                                                                }
                                                                updateState(() {
                                                                  allowTopup = true;
                                                                  bankCardFieldController.text = bank_card_with_token!.number;
                                                                  if (snapshot.data!["member"] != null) {
                                                                    memberAccountFieldController.text = snapshot.data!["member"].account;
                                                                  }
                                                                });
                                                              }
                                                            }).catchError((error) {
                                                              updateState(() {
                                                                loadingState = false;
                                                                showMessageDialog(context, localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-cards-load-failed"), snapshot.data!["user"], success: false, comment: error.toString());
                                                              });
                                                            });
                                                          }
                                                        ) : const SizedBox.shrink(),
                                                        const SizedBox(height: 10.0),
                                                        (snapshot.data!["center"].allow_topup_ru) ? ListTile(
                                                          leading: Image.asset("assets/ukassa.png", fit: BoxFit.fitHeight, height: 40.0),
                                                          trailing: (loadingState) ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black)) : (paymentProcessor == "YOOKASSA") ? const Icon(Icons.circle) : const Icon(Icons.circle_outlined, color: Colors.black54),
                                                          tileColor: (dark_theme) ? Colors.white : Colors.grey.shade300,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(5.0)
                                                          ),
                                                          onTap: () {
                                                            updateState(() {
                                                              allowLinkBankCard = false;
                                                              allowTopup = false;
                                                              loadingState = true;
                                                              paymentProcessor = "YOOKASSA";
                                                              currencyCode = "RUB";
                                                            });
                                                            gateway.acquireBankCardWithToken({
                                                              "user_id": snapshot.data!["user"]["user"]["user_id"],
                                                              "center_id": snapshot.data!["center"].center_id,
                                                              "country_code": "RU",
                                                              "processor_name": "YOOKASSA"
                                                            }).then((bank_card) {
                                                              if (bank_card == null) {
                                                                updateState(() {
                                                                  loadingState = false;
                                                                  showDialog(
                                                                    context: context,
                                                                    builder: (BuildContext context) => Dialog(
                                                                        shape: const RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                                        ),
                                                                        child: Padding(
                                                                            padding: const EdgeInsets.only(top: 25.0, bottom: 20.0, left: 20.0, right: 20.0),
                                                                            child: Column(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: <Widget>[
                                                                                  Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-no-card-title"), style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                                                                                    child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-no-card-subtitle")),
                                                                                  ),
                                                                                  Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                                                      children: <Widget>[
                                                                                        TextButton(
                                                                                            onPressed: () {
                                                                                              Navigator.of(context).pop();
                                                                                            },
                                                                                            child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-no-card-secondary-button-label"), style: const TextStyle(fontSize: 14.0, color: Colors.black38))
                                                                                        ),
                                                                                        TextButton(
                                                                                            onPressed: () {
                                                                                              Navigator.of(context).pop();
                                                                                              Navigator.of(context).pop();
                                                                                              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => BankCardsRoute(center: snapshot.data!["center"]))).then((status) {
                                                                                                setState(() {});
                                                                                              });
                                                                                            },
                                                                                            child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-no-card-primary-button-label"), style: const TextStyle(fontSize: 14.0, color: Colors.blueAccent))
                                                                                        )
                                                                                      ]
                                                                                  )
                                                                                ]
                                                                            )
                                                                        )
                                                                    )
                                                                  );
                                                                });
                                                              } else {
                                                                updateState(() {
                                                                  loadingState = false;
                                                                  allowLinkBankCard = true;
                                                                });
                                                                allowLinkBankCard = true;
                                                                bank_card_with_token = bank_card;
                                                                for (models.BankCardToken token in bank_card.bank_card_tokens) {
                                                                  if (token.center_id == snapshot.data!["center"].center_id) {
                                                                    allowLinkBankCard = false;
                                                                  }
                                                                }
                                                                if (allowLinkBankCard == true) {
                                                                  showDialog(
                                                                    context: context,
                                                                    builder: (BuildContext context) => Dialog(
                                                                        shape: const RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                                        ),
                                                                        child: Padding(
                                                                            padding: const EdgeInsets.only(top: 25.0, bottom: 20.0, left: 20.0, right: 20.0),
                                                                            child: Column(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: <Widget>[
                                                                                  Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-no-card-modal-title"), style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                                                                                    child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-no-card-modal-subtitle")),
                                                                                  ),
                                                                                  Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                                                      children: <Widget>[
                                                                                        TextButton(
                                                                                            onPressed: () {
                                                                                              Navigator.of(context).pop();
                                                                                            },
                                                                                            child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-no-card-modal-secondary-button-label"), style: const TextStyle(fontSize: 14.0, color: Colors.black38))
                                                                                        ),
                                                                                        TextButton(
                                                                                            onPressed: () {
                                                                                              updateState(() {
                                                                                                loadingState = true;
                                                                                                gateway.linkBankCard({
                                                                                                  "processor_name": "YOOKASSA",
                                                                                                  "bank_card_id": bank_card_with_token!.bank_card_id,
                                                                                                  "center_id": snapshot.data!["center"].center_id
                                                                                                }).then((status) {
                                                                                                  updateState(() {
                                                                                                    loadingState = false;
                                                                                                    allowLinkBankCard = false;
                                                                                                    allowTopup = true;
                                                                                                    bankCardFieldController.text = bank_card_with_token!.number;
                                                                                                    if (snapshot.data!["member"] != null) {
                                                                                                      memberAccountFieldController.text = snapshot.data!["member"].account;
                                                                                                    }
                                                                                                    Navigator.of(context).pop();
                                                                                                  });
                                                                                                }).catchError((error) {
                                                                                                  updateState(() {
                                                                                                    loadingState = false;
                                                                                                  });
                                                                                                  showMessageDialog(context, "Could not link", snapshot.data!["user"], success: false, comment: error.toString());
                                                                                                });
                                                                                              });
                                                                                            },
                                                                                            child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-no-card-modal-primary-button-label"), style: const TextStyle(fontSize: 14.0, color: Colors.blueAccent))
                                                                                        )
                                                                                      ]
                                                                                  )
                                                                                ]
                                                                            )
                                                                        )
                                                                    )
                                                                  );
                                                                  return;
                                                                }
                                                                updateState(() {
                                                                  loadingState = false;
                                                                  allowLinkBankCard = false;
                                                                  allowTopup = true;
                                                                  bankCardFieldController.text = bank_card_with_token!.number;
                                                                  if (snapshot.data!["member"] != null) {
                                                                    memberAccountFieldController.text = snapshot.data!["member"].account;
                                                                  }
                                                                });
                                                              }
                                                            }).catchError((error) {
                                                              updateState(() {
                                                                loadingState = false;
                                                                showMessageDialog(context, localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-cards-load-failed"), snapshot.data!["user"], success: false, comment: error.toString());
                                                              });
                                                            });
                                                          }
                                                        ) : const SizedBox.shrink(),
                                                        const SizedBox(height: 10.0),
                                                        (snapshot.data!["center"].allow_topup_uz) ? ListTile(
                                                          leading: Image.asset("assets/kaspi.png", fit: BoxFit.fitHeight, height: 40.0),
                                                          trailing: (loadingState) ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black)) : (paymentProcessor == "KASPI") ? const Icon(Icons.circle) : const Icon(Icons.circle_outlined, color: Colors.black54),
                                                          tileColor: (dark_theme) ? Colors.white : Colors.grey.shade300,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(5.0)
                                                          ),
                                                          onTap: () {
                                                            updateState(() {
                                                              allowLinkBankCard = false;
                                                              allowTopup = true;
                                                              // loadingState = true;
                                                              paymentProcessor = "KASPI";
                                                              currencyCode = "TEN";
                                                            });
                                                          }
                                                        ) : const SizedBox.shrink(),
                                                        const SizedBox(height: 20.0),

                                                        // ALLOW TOPUP
                                                        (allowTopup) ? Wrap(
                                                          children: <Widget>[
                                                            Padding(
                                                              padding: const EdgeInsets.only(bottom: 10.0, top: 20.0),
                                                              child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-member-account-label"), style: TextStyle(fontSize: 14.0, color: (dark_theme) ? Colors.white60 : Colors.black54))
                                                            ),
                                                            TextField(
                                                              autocorrect: false,
                                                              controller: memberAccountFieldController,
                                                              style: TextStyle(fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black),
                                                              decoration: InputDecoration(
                                                                contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                                                                enabledBorder: OutlineInputBorder(
                                                                  borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.white : Colors.black),
                                                                  borderRadius: BorderRadius.zero
                                                                ),
                                                                focusedBorder: OutlineInputBorder(
                                                                  borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.white70 : Colors.black54),
                                                                  borderRadius: BorderRadius.zero
                                                                ),
                                                                hintText: localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-member-account-input-hint"),
                                                                hintStyle: const TextStyle(color: Colors.grey)
                                                              )
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(bottom: 10.0, top: 20.0),
                                                              child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-bank-card-label"), style: TextStyle(fontSize: 14.0, color: (dark_theme) ? Colors.white60 : Colors.black54))
                                                            ),
                                                            TextField(
                                                              autocorrect: false,
                                                              enabled: false,
                                                              controller: bankCardFieldController,
                                                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                                                              decoration: InputDecoration(
                                                                contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                                                                disabledBorder: OutlineInputBorder(
                                                                  borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.white54 : Colors.black38),
                                                                  borderRadius: BorderRadius.zero
                                                                ),
                                                                hintText: localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-bank-card-input-hint"),
                                                                hintStyle: const TextStyle(color: Colors.grey)
                                                              )
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(bottom: 10.0, top: 20.0),
                                                              child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-amount-label"), style: TextStyle(fontSize: 14.0, color: (dark_theme) ? Colors.white60 : Colors.black54))
                                                            ),
                                                            TextField(
                                                              autocorrect: false,
                                                              keyboardType: TextInputType.number,
                                                              controller: topupAmountFieldController,
                                                              style: TextStyle(fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black),
                                                              decoration: InputDecoration(
                                                                contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                                                                enabledBorder: OutlineInputBorder(
                                                                  borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.white : Colors.black),
                                                                  borderRadius: BorderRadius.zero
                                                                ),
                                                                focusedBorder: OutlineInputBorder(
                                                                  borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.white70 : Colors.black54),
                                                                  borderRadius: BorderRadius.zero
                                                                ),
                                                                hintText: "0 $currencyCode",
                                                                hintStyle: const TextStyle(color: Colors.grey),
                                                              )
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                                                              child: SizedBox(
                                                                  width: MediaQuery.of(context).size.width * 0.9,
                                                                  height: MediaQuery.of(context).size.height * 0.06,
                                                                  child: OutlinedButton(
                                                                      onPressed: () {
                                                                        if (memberAccountFieldController.text.isNotEmpty && topupAmountFieldController.text.isNotEmpty) {
                                                                          updateState(() {
                                                                            loadingState = true;
                                                                          });
                                                                          gateway.topupAccount({
                                                                            "processor_name": paymentProcessor,
                                                                            "number": bank_card_with_token!.number,
                                                                            "member": memberAccountFieldController.text,
                                                                            "amount": topupAmountFieldController.text,
                                                                            "center_id": snapshot.data!["center"].center_id
                                                                          }).then((response) {
                                                                            updateState(() {
                                                                              loadingState = false;
                                                                              if (response["confirmation_url"] == null) {
                                                                                Navigator.of(context).pop();
                                                                                showMessageDialog(context, localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-successful-title"), snapshot.data!["user"], success: true, comment: localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-successful-subtitle"));
                                                                              } else {
                                                                                Navigator.of(context).pop();
                                                                                canLaunchUrl(Uri.parse(response["confirmation_url"])).then((status) {
                                                                                  if (status) {
                                                                                    launchUrl(Uri.parse(response["confirmation_url"]), mode: LaunchMode.platformDefault);
                                                                                  } else {
                                                                                    Navigator.of(context).pop();
                                                                                    showMessageDialog(context, localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-3d-security-fail-title"), snapshot.data!["user"], success: false, comment: localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-3d-security-fail-subtitle"));
                                                                                  }
                                                                                }).catchError((error) {
                                                                                  Navigator.of(context).pop();
                                                                                  showMessageDialog(context, localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-3d-security-fail-title"), snapshot.data!["user"], success: false, comment: localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-3d-security-fail-subtitle"));
                                                                                });
                                                                                // if () {
                                                                                //   await launchUrl(Uri.parse("https://t.me/icafeplay"), mode: LaunchMode.platformDefault);
                                                                                // } else {
                                                                                //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open telegram")));
                                                                                // }
                                                                              }
                                                                            });
                                                                          }).catchError((error) {
                                                                            updateState(() {
                                                                              loadingState = false;
                                                                            });
                                                                            showMessageDialog(context, localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-fail-title"), snapshot.data!["user"], success: false, comment: error.toString());
                                                                          });
                                                                        } else {
                                                                          showMessageDialog(context, localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-empty-inputs-title"), snapshot.data!["user"], success: false, comment: localization.CivicLocale.translate(deviceLocale, "dialogs", "center-topup-empty-inputs-subtitle"));
                                                                        }
                                                                      },
                                                                      style: OutlinedButton.styleFrom(
                                                                          foregroundColor: (dark_theme) ? Colors.black : Colors.white,
                                                                          backgroundColor: (dark_theme) ? const Color(0xFFEEEEEE) : Colors.black,
                                                                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0))
                                                                      ),
                                                                      child: (loadingState) ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)) : Text(localization.CivicLocale.translate(deviceLocale, "center-route", "center-footer-button-topup-button-label"))
                                                                  )
                                                              )
                                                            )
                                                          ]
                                                        ) : const SizedBox.shrink()
                                                      ]
                                                    )
                                                  ),
                                                );
                                              }
                                            );
                                          }
                                        );
                                      },
                                      child: Text(localization.CivicLocale.translate(deviceLocale, "center-route", "center-footer-button-topup-button-label"), style: TextStyle(color: (dark_theme) ? Colors.black : Colors.white))
                                  ),
                                )
                            ),
                            Expanded(
                                child: Container(
                                  height: MediaQuery.of(context).size.height * 0.1,
                                  padding: const EdgeInsets.all(10.0),
                                  child: FilledButton(
                                      style: FilledButton.styleFrom(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                          backgroundColor: (dark_theme) ? const Color(0xFFEEEEEE) : Colors.black
                                      ),
                                      onPressed: () {
                                        if (snapshot.data!["center"].allow_booking) {
                                          if (user_is_authenticated) {
                                            if (snapshot.data!["member"] == null) {
                                              showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) => Dialog(
                                                      shape: const RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                      ),
                                                      backgroundColor: (dark_theme) ? const Color(0xFF292929) : Colors.white,
                                                      child: Padding(
                                                          padding: const EdgeInsets.only(top: 25.0, bottom: 20.0, left: 20.0, right: 20.0),
                                                          child: Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: <Widget>[
                                                                Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "center-booking-member-required-title"), style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black), textAlign: TextAlign.left),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 10.0),
                                                                  child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "center-booking-member-required-subtitle"), style: TextStyle(color: (dark_theme) ? Colors.white : Colors.black)),
                                                                ),
                                                                Align(
                                                                    alignment: Alignment.bottomRight,
                                                                    child: TextButton(
                                                                        onPressed: () {
                                                                          Navigator.of(context).pop();
                                                                        },
                                                                        child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "center-booking-member-required-button-label"), style: const TextStyle(fontSize: 14.0))
                                                                    )
                                                                )
                                                              ]
                                                          )
                                                      )
                                                  )
                                              );
                                            } else {
                                              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => BookingRoute(center: snapshot.data!["center"], member: snapshot.data!["member"])));
                                            }
                                          } else {
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext context) => Dialog(
                                                    shape: const RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                    ),
                                                    backgroundColor: Colors.white,
                                                    child: Padding(
                                                        padding: const EdgeInsets.only(top: 25.0, bottom: 20.0, left: 20.0, right: 20.0),
                                                        child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: <Widget>[
                                                              Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "link-account-unavailable-title"), style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                                                              Padding(
                                                                padding: const EdgeInsets.only(top: 10.0),
                                                                child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "link-account-unavailable-subtitle")),
                                                              ),
                                                              Align(
                                                                  alignment: Alignment.bottomRight,
                                                                  child: TextButton(
                                                                      onPressed: () {
                                                                        Navigator.of(context).pop();
                                                                      },
                                                                      child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "link-account-unavailable-primary-button-label"), style: const TextStyle(fontSize: 14.0))
                                                                  )
                                                              )
                                                            ]
                                                        )
                                                    )
                                                )
                                            );
                                          }
                                        } else {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) => Dialog(
                                                shape: const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                ),
                                                backgroundColor: Colors.white,
                                                child: Padding(
                                                    padding: const EdgeInsets.only(top: 25.0, bottom: 20.0, left: 20.0, right: 20.0),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "center-booking-disabled-title"), style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                                                          Padding(
                                                            padding: const EdgeInsets.only(top: 10.0),
                                                            child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "center-booking-disabled-subtitle")),
                                                          ),
                                                          Align(
                                                              alignment: Alignment.bottomRight,
                                                              child: TextButton(
                                                                  onPressed: () {
                                                                    Navigator.of(context).pop();
                                                                  },
                                                                  child: Text(localization.CivicLocale.translate(deviceLocale, "dialogs", "center-booking-disabled-primary-button"), style: const TextStyle(fontSize: 14.0))
                                                              )
                                                          )
                                                        ]
                                                    )
                                                )
                                            )
                                          );
                                        }
                                      },
                                      child: Text(localization.CivicLocale.translate(deviceLocale, "center-route", "center-footer-button-booking-button-label"), style: TextStyle(color: (dark_theme) ? Colors.black : Colors.white))
                                  ),
                                )
                            )
                          ]
                      ),
                    )
                )
            );
          } else if (snapshot.hasError) {
            ErrorRoute(message: localization.CivicLocale.translate(deviceLocale, "center-route", "failed-to-load-data"), requestUpdate: setState);
          }
          return LoadingRoute(dark_theme: dark_theme);
        }
      )
    );
  }
}