import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:icafeplay/authorization_route.dart';
import 'package:icafeplay/center_route.dart';
import 'package:icafeplay/dialogs.dart';
import 'package:icafeplay/error_route.dart';
import 'package:icafeplay/loading_route.dart';
import 'package:icafeplay/settings_rout.dart';
import 'package:icafeplay/storage.dart' as storage;
import 'package:icafeplay/gateway.dart' as gateway;
import 'package:icafeplay/models.dart' as models;
import 'package:icafeplay/localization.dart' as localization;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key});

  @override
  State<HomeRoute> createState() => HomeRouteState();
}

class HomeRouteState extends State<HomeRoute> {
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  int currentPage = 0;
  String deviceLocale = Platform.localeName.split('_')[0].toUpperCase();
  bool dark_theme = true;

  bool loadingState = false;

  Map<String, dynamic> profileData = {};
  List<models.Center> centers = [];
  List<models.Center> centersContainer = [];
  models.Center? spotlightCenter;
  bool fetchedHomeData = false;
  bool fetchedSearchData = false;
  bool fetchedProfileData = false;

  FocusNode searchFieldFocusNode = FocusNode();

  Future<List<models.Center>> fetchHomeData() async {
    if (fetchedHomeData == false) {
      centers = await gateway.fetchCenters();
      final randomizer = new Random();
      spotlightCenter = centers[randomizer.nextInt(centers.length)];
      fetchedHomeData = true;
    }
    return centers;
  }
  Future<List<models.Center>> fetchSearchData() async {
    if (fetchedSearchData == false) {
      centers = await gateway.fetchCenters();
      centersContainer = List.from(centers);
      fetchedSearchData = true;
    }
    return centersContainer;
  }
  Future<Map<String, dynamic>> fetchProfileData() async {
    if (fetchedProfileData == false) {
      profileData["user"] = await storage.readStringData("userToken");
      if (profileData["user"] == "undefined") {
        profileData["bookings"] = null;
        profileData["bank_cards"] = null;
        profileData["members"] = null;
      } else {
        profileData["bookings"] = await gateway.fetchUserBookings(json.decode(profileData["user"])["user"]["user_id"]);
        profileData["bank_cards"] = await gateway.fetchUserBankCards(json.decode(profileData["user"])["user"]["user_id"]);
        profileData["members"] = await gateway.fetchUserMembers(json.decode(profileData["user"])["user"]["user_id"]);
      }
      fetchedProfileData = true;
    }
    return profileData;
  }

  void resetFetch() {
    fetchedProfileData = false;
  }

  Widget selectPageByIndex(int index) {
    if (index == 0) {
      return FutureBuilder(
        future: storage.readStringData("userToken"),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != "undefined") {
              models.UserToken token = models.UserToken.convert(json.decode(snapshot.data!));
              deviceLocale = token.user.language!;
              if (token.user.dark_theme != null) dark_theme = token.user.dark_theme!;
            }
            return FutureBuilder(
              future: fetchHomeData(),
              builder: (BuildContext context, AsyncSnapshot<List<models.Center>> snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    color: (dark_theme) ? Colors.black87 : Colors.white,
                    child: ListView(
                        children: [
                          Padding(
                              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05, bottom: 20.0),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.6,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                              localization.CivicLocale.translate(deviceLocale, "home-route", "home-greeting-subtitle"),
                                              style: const TextStyle(color: Colors.grey)
                                          ),
                                          Text(localization.CivicLocale.translate(deviceLocale, "home-route", "home-greeting-title"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0, color: (dark_theme) ? Colors.white : Colors.black))
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 40.0,
                                      margin: const EdgeInsets.only(right: 20.0),
                                      child: Image.asset("assets/authorization_logo.png", fit: BoxFit.contain)
                                    ),
                                  ],
                                ),
                              )
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  currentPage = 1;
                                  searchFieldFocusNode.requestFocus();
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: (dark_theme) ? Colors.white60 : Colors.black),
                                  borderRadius: BorderRadius.circular(10.0)
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(localization.CivicLocale.translate(deviceLocale, "home-route", "home-search-button-label"), style: const TextStyle(color: Colors.grey, fontSize: 14.0)),
                                    Icon(Icons.search, size: 22.0, color: (dark_theme) ? Colors.grey : Colors.black)
                                  ],
                                )
                              ),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.only(top: 30.0, left: MediaQuery.of(context).size.width * 0.05, right: MediaQuery.of(context).size.width * 0.05),
                              child: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "home-top-centers-title"), style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black))
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                            child: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "home-top-centers-subtitle"), style: const TextStyle(fontSize: 12.0, color: Colors.grey)),
                          ),
                          Container(
                              margin: const EdgeInsets.only(top: 10.0),
                              height: MediaQuery.of(context).size.height * 0.3,
                              child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: <Widget>[
                                    SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                                    for (models.Center center in snapshot.data!)
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => CenterRoute(center_id: center.center_id)));
                                        },
                                        child: Container(
                                            width: MediaQuery.of(context).size.width * 0.4,
                                            height: MediaQuery.of(context).size.height * 0.3,
                                            margin: const EdgeInsets.only(right: 10.0),
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    clipBehavior: Clip.hardEdge,
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(10.0)
                                                    ),
                                                    width: MediaQuery.of(context).size.width * 0.4,
                                                    height: MediaQuery.of(context).size.width * 0.4,
                                                    child: (center.image_files.isEmpty) ? Image.asset("assets/image.jpg", fit: BoxFit.cover) : CachedNetworkImage(
                                                          imageUrl: "${gateway.ENDPOINT}/${center.image_files[0].path}",
                                                          placeholder: (context, url) => Image.asset("assets/image-placeholder.gif", fit: BoxFit.cover),
                                                          errorWidget: (context, url, error) => Image.asset("assets/image-placeholder.gif", fit: BoxFit.cover),
                                                          fit: BoxFit.cover
                                                      )
                                                  ),
                                                  Padding(
                                                      padding: const EdgeInsets.only(top: 10.0),
                                                      child: Text(center.display_name, style: TextStyle(fontSize: 16.0, color: (dark_theme) ? Colors.white : Colors.black), overflow: TextOverflow.ellipsis)
                                                  ),
                                                  Text(center.country.name, style: const TextStyle(fontSize: 14.0, color: Colors.grey))
                                                ]
                                            )
                                        )
                                      ),
                                    SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                                  ]
                              )
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                            child: Wrap(
                              direction: Axis.vertical,
                              children: <Widget>[
                                Padding(
                                    padding: const EdgeInsets.only(top: 30.0),
                                    child: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "home-center-of-the-day-title"), style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black))
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "home-center-of-the-day-subtitle"), style: const TextStyle(fontSize: 12.0, color: Colors.grey)),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => CenterRoute(center_id: spotlightCenter!.center_id)));
                                  },
                                  child: SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.9,
                                      height: MediaQuery.of(context).size.height * 0.3,
                                      child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              clipBehavior: Clip.hardEdge,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10.0)
                                              ),
                                              width: MediaQuery.of(context).size.width * 0.9,
                                              height: MediaQuery.of(context).size.width * 0.4,
                                              child: (spotlightCenter!.image_files.isEmpty) ? Image.asset("assets/image.jpg", fit: BoxFit.cover) : CachedNetworkImage(
                                                  imageUrl: "${gateway.ENDPOINT}/${spotlightCenter!.image_files[0].path}",
                                                  placeholder: (context, url) => Image.asset("assets/image-placeholder.gif", fit: BoxFit.cover),
                                                  errorWidget: (context, url, error) => Image.asset("assets/image-placeholder.gif", fit: BoxFit.cover),
                                                  fit: BoxFit.cover
                                              ),
                                            ),
                                            Padding(
                                                padding: const EdgeInsets.only(top: 10.0),
                                                child: Text(spotlightCenter!.display_name, style: TextStyle(fontSize: 16.0, color: (dark_theme) ? Colors.white : Colors.black), overflow: TextOverflow.ellipsis)
                                            ),
                                            Text(spotlightCenter!.country.name, style: const TextStyle(fontSize: 14.0, color: Colors.grey))
                                          ]
                                      )
                                  )
                                )
                              ],
                            ),
                          )
                        ]
                    )
                  );
                } else if (snapshot.hasError) {
                  return ErrorRoute(message: localization.CivicLocale.translate(deviceLocale, "home-route", "home-exception-hint"), requestUpdate: setState);
                }
                return LoadingRoute(dark_theme: dark_theme);
              }
            );
          } else if (snapshot.hasError) {
            return ErrorRoute(message: localization.CivicLocale.translate(deviceLocale, "home-route", "home-exception-hint"), requestUpdate: setState);
          }
          return LoadingRoute(dark_theme: dark_theme);
        }
      );
    } else if (index == 1) {
      return FutureBuilder(
        future: storage.readStringData("userToken"),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != "undefined") {
              models.UserToken token = models.UserToken.convert(json.decode(snapshot.data!));
              deviceLocale = token.user.language!;
              if (token.user.dark_theme != null) dark_theme = token.user.dark_theme!;
            }
            return FutureBuilder(
              future: fetchSearchData(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    color: (dark_theme) ? Colors.black87 : Colors.white,
                    child: ListView(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                        children: <Widget>[
                          Container(
                              padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.05),
                              child: TextField(
                                focusNode: searchFieldFocusNode,
                                onChanged: (query) {
                                  setState(() {
                                    centersContainer = centers.where((models.Center center) => center.name.toLowerCase().contains(query.toLowerCase())).toList();
                                  });
                                },
                                style: TextStyle(color: (dark_theme) ? Colors.white : Colors.black),
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0,),
                                      borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.white60 : Colors.black),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(width: 2.0, color: (dark_theme) ? Colors.white60 : Colors.black),
                                    ),
                                    hintText: localization.CivicLocale.translate(deviceLocale, "home-route", "search-input-hint"),
                                    hintStyle: TextStyle(color: (dark_theme) ? Colors.grey : Colors.grey)
                                ),
                              )
                          ),
                          SizedBox(height: MediaQuery.of(context).size.width * 0.05),
                          for (models.Center center in snapshot.data!)
                            InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => CenterRoute(center_id: center.center_id)));
                                },
                                child: SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.9,
                                    height: MediaQuery.of(context).size.height * 0.3,
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            clipBehavior: Clip.hardEdge,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10.0)
                                            ),
                                            width: MediaQuery.of(context).size.width * 0.9,
                                            height: MediaQuery.of(context).size.width * 0.4,
                                            child: (center.image_files.isEmpty) ? Image.asset("assets/image.jpg", fit: BoxFit.cover) : CachedNetworkImage(
                                                imageUrl: "${gateway.ENDPOINT}/${center.image_files[0].path}",
                                                placeholder: (context, url) => Image.asset("assets/image-placeholder.gif", fit: BoxFit.cover),
                                                errorWidget: (context, url, error) => Image.asset("assets/image-placeholder.gif", fit: BoxFit.cover),
                                                fit: BoxFit.cover
                                            ),
                                          ),
                                          Padding(
                                              padding: const EdgeInsets.only(top: 10.0),
                                              child: Text(center.display_name, style: TextStyle(fontSize: 16.0, color: (dark_theme) ? Colors.white : Colors.black), overflow: TextOverflow.ellipsis)
                                          ),
                                          Text(center.country.name, style: const TextStyle(fontSize: 14.0, color: Colors.grey))
                                        ]
                                    )
                                )
                            ),
                        ]
                    )
                  );
                } else if (snapshot.hasError) {
                  return ErrorRoute(message: localization.CivicLocale.translate(deviceLocale, "home-route", "home-exception-hint"), requestUpdate: setState);
                }
                return LoadingRoute(dark_theme: dark_theme);
              }
            );
          } else if (snapshot.hasError) {
            return ErrorRoute(message: localization.CivicLocale.translate(deviceLocale, "home-route", "home-exception-hint"), requestUpdate: setState);
          }
          return LoadingRoute(dark_theme: dark_theme);
        }
      );
    } else if (index == 2) {
      return FutureBuilder(
        future: fetchProfileData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data["user"] == "undefined") {
              return AuthorizationRoute(setParentState: setState, resetFunction: resetFetch);
            } else {
              models.UserToken token = models.UserToken.convert(json.decode(snapshot.data["user"]));
              if (token.user.dark_theme != null) dark_theme = token.user.dark_theme!;
              return Container(
                color: (dark_theme) ? Colors.black87 : Colors.white,
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.05),
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Text>[
                          Text(token.user.name, style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black)),
                          Text(token.user.email, style: const TextStyle(fontSize: 16.0, color: Colors.grey))
                        ]
                      )
                    ),
                    Container(
                      color: Colors.black12,
                      height: MediaQuery.of(context).size.height * 0.05,
                      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.01),
                      child: Column(
                        children: <ListTile>[
                          ListTile(
                              onTap: () {
                                showModalBottomSheet(
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero
                                    ),
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) {
                                      return Container(
                                          height: MediaQuery.of(context).size.height * 0.7,
                                          color: (dark_theme) ? Colors.black87 : Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                                          child: (snapshot.data["bookings"].isEmpty) ? Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.only(bottom: 15.0),
                                                  child: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "profile-modals-bookings-empty-title"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0, color: (dark_theme) ? Colors.white : Colors.black)),
                                                ),
                                                Text(
                                                    localization.CivicLocale.translate(deviceLocale, "home-route", "profile-modals-bookings-empty-hint"),
                                                    style: TextStyle(fontSize: 12.0, color: (dark_theme) ? Colors.white60 : Colors.grey)
                                                ),
                                              ]
                                          ) : ListView(
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.only(bottom: 15.0),
                                                  child: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "profile-modals-bookings-title"), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                                                ),
                                                for (models.Booking booking in snapshot.data["bookings"])
                                                  Wrap(
                                                      children: <Widget>[
                                                        Material(
                                                            child: ExpansionTile(
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(5.0)
                                                                ),
                                                                collapsedShape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(5.0)
                                                                ),
                                                                title: Text(booking.center.display_name),
                                                                trailing: const Icon(Icons.arrow_drop_down, color: Colors.black),
                                                                backgroundColor: (dark_theme) ? Colors.white60 : Colors.grey.shade300,
                                                                collapsedBackgroundColor: (dark_theme) ? Colors.white70 : Colors.grey.shade200,
                                                                children: <Widget>[
                                                                  ListTile(
                                                                    title: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "profile-modals-bookings-booking-date"), style: const TextStyle(fontSize: 12.0)),
                                                                    trailing: Text(booking.date),
                                                                  ),
                                                                  ListTile(
                                                                    title: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "profile-modals-bookings-booking-time"), style: const TextStyle(fontSize: 12.0)),
                                                                    trailing: Text(booking.time),
                                                                  ),
                                                                  ListTile(
                                                                    title: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "profile-modals-bookings-booking-pc"), style: const TextStyle(fontSize: 12.0)),
                                                                    trailing: Text(booking.pc_name),
                                                                  ),
                                                                  ListTile(
                                                                    title: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "profile-modals-bookings-booking-minutes"), style: const TextStyle(fontSize: 12.0)),
                                                                    trailing: Text(booking.minutes.toString()),
                                                                  )
                                                                ]
                                                            )
                                                        ),
                                                        const Divider(color: Colors.transparent, height: 5.0)
                                                      ]
                                                  ),
                                              ]
                                          )
                                      );
                                    }
                                );
                              },
                              title: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "profile-settings-bookings-label"), style: TextStyle(color: (dark_theme) ? Colors.white : Colors.black)),
                              trailing: Icon(Icons.chevron_right, color: (dark_theme) ? Colors.white : Colors.grey)
                          ),
                          ListTile(
                              onTap: () {
                                showModalBottomSheet(
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero
                                    ),
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) {
                                      return Container(
                                          height: MediaQuery.of(context).size.height * 0.7,
                                          color: (dark_theme) ? Colors.black87 : Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                                          child: (snapshot.data["bank_cards"].isEmpty) ? Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.only(bottom: 15.0),
                                                  child: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "profile-modals-bank-cards-empty-title"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0, color: (dark_theme) ? Colors.white : Colors.black)),
                                                ),
                                                Text(
                                                    localization.CivicLocale.translate(deviceLocale, "home-route", "profile-modals-bank-cards-empty-hint"),
                                                    style: const TextStyle(fontSize: 12.0, color: Colors.grey)
                                                )
                                              ]
                                          ) : ListView(
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.only(bottom: 15.0),
                                                  child: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "profile-modals-bank-cards-title"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0, color: (dark_theme) ? Colors.white : Colors.black)),
                                                ),
                                                for (models.BankCard bank_card in snapshot.data["bank_cards"])
                                                  Wrap(
                                                      children: <Widget>[
                                                        Material(
                                                            child: ListTile(
                                                                onTap: () {
                                                                  showDialog(
                                                                    context: context,
                                                                    builder: (BuildContext context) => Dialog(
                                                                      backgroundColor: (dark_theme) ? Colors.black87 : Colors.white,
                                                                      shape: const RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                                      ),
                                                                      child: Padding(
                                                                          padding: const EdgeInsets.only(top: 25.0, bottom: 20.0, left: 20.0, right: 20.0),
                                                                          child: Column(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: <Widget>[
                                                                                Text(localization.CivicLocale.translate(deviceLocale, "home-route", "profile-modals-bank-cards-warning-title"), style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black), textAlign: TextAlign.left),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                                                                                  child: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "profile-modals-bank-cards-warning-details"), style: TextStyle(color: (dark_theme) ? Colors.white60 : Colors.black)),
                                                                                ),
                                                                                Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                                    children: <Widget>[
                                                                                      TextButton(
                                                                                          onPressed: () {
                                                                                            Navigator.of(context).pop();
                                                                                          },
                                                                                          child: Text(localization.CivicLocale.translate(deviceLocale, "general", "close-button-label"), style: TextStyle(fontSize: 14.0, color: (dark_theme) ? Colors.white54 : Colors.black38))
                                                                                      ),
                                                                                      TextButton(
                                                                                          onPressed: () {
                                                                                            gateway.deleteUserBankCard(bank_card.bank_card_id).then((status) {
                                                                                              Navigator.of(context).pop();
                                                                                              setState(() {
                                                                                                fetchedProfileData = false;
                                                                                                Navigator.of(context).pop();
                                                                                              });
                                                                                            }).catchError((error) {
                                                                                              Navigator.of(context).pop();
                                                                                            });
                                                                                          },
                                                                                          child: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "profile-modals-bank-cards-remove-button-label"), style: const TextStyle(fontSize: 14.0, color: Colors.redAccent))
                                                                                      )
                                                                                    ]
                                                                                )
                                                                              ]
                                                                          )
                                                                      )
                                                                    )
                                                                  );
                                                                },
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(5.0)
                                                                ),
                                                                leading: Text(bank_card.country_code),
                                                                title: Text(bank_card.number),
                                                                trailing: const Icon(Icons.highlight_remove, color: Colors.black),
                                                                tileColor: (dark_theme) ? Colors.white60 : Colors.grey.shade300
                                                            )
                                                        ),
                                                        const Divider(color: Colors.transparent, height: 5.0)
                                                      ]
                                                  ),
                                              ]
                                          )
                                      );
                                    }
                                );
                              },
                              title: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "profile-settings-bank-cards-label"), style: TextStyle(color: (dark_theme) ? Colors.white : Colors.black)),
                              trailing: Icon(Icons.chevron_right, color: (dark_theme) ? Colors.white : Colors.grey)
                          ),
                          ListTile(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) => Dialog(
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(10.0))
                                      ),
                                      backgroundColor: (dark_theme) ? const Color(0xFF292929) : Colors.white,
                                      child: StatefulBuilder(
                                        builder: (BuildContext context, StateSetter updateState) {
                                          return Padding(
                                              padding: const EdgeInsets.only(top: 30.0, bottom: 20.0, left: 20.0, right: 20.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Padding(
                                                    padding: const EdgeInsets.only(bottom: 20.0),
                                                    child: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "profile-modals-transactions-dialog-title"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: (dark_theme) ? Colors.white : Colors.black)),
                                                  ),
                                                  for (models.BankCard bank_card in snapshot.data["bank_cards"])
                                                    Wrap(
                                                      children: <Widget>[
                                                        ListTile(
                                                            onTap: () {
                                                              updateState(() {
                                                                loadingState = true;
                                                                gateway.fetchUserTransactions(bank_card.bank_card_id).then((List<models.Transaction> transactions) {
                                                                  updateState(() {
                                                                    loadingState = false;
                                                                    Navigator.of(context).pop();
                                                                    showModalBottomSheet(
                                                                        shape: const RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.zero
                                                                        ),
                                                                        context: context,
                                                                        isScrollControlled: true,
                                                                        builder: (context) {
                                                                          return Container(
                                                                              height: MediaQuery.of(context).size.height * 0.75,
                                                                              color: (dark_theme) ? Colors.black87 : Colors.white,
                                                                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                                                                              child: (transactions.isEmpty) ? Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: <Widget>[
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(bottom: 15.0),
                                                                                      child: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "profile-modals-transactions-empty-title"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0, color: (dark_theme) ? Colors.white : Colors.black)),
                                                                                    ),
                                                                                    Text(
                                                                                        localization.CivicLocale.translate(deviceLocale, "home-route", "profile-modals-transactions-empty-hint"),
                                                                                        style: const TextStyle(fontSize: 12.0, color: Colors.grey)
                                                                                    )
                                                                                  ]
                                                                              ) : ListView(
                                                                                  children: <Widget>[
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(bottom: 15.0),
                                                                                      child: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "profile-modals-transactions-title"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0, color: (dark_theme) ? Colors.white : Colors.black)),
                                                                                    ),
                                                                                    for (models.Transaction transaction in transactions)
                                                                                      Wrap(
                                                                                          children: <Widget>[
                                                                                            Material(
                                                                                              child: ExpansionTile(
                                                                                                shape: RoundedRectangleBorder(
                                                                                                    borderRadius: BorderRadius.circular(5.0)
                                                                                                ),
                                                                                                collapsedShape: RoundedRectangleBorder(
                                                                                                    borderRadius: BorderRadius.circular(5.0)
                                                                                                ),
                                                                                                leading: Text(transaction.amount.toString()),
                                                                                                title: (transaction.center == null) ? Text(transaction.icafe_member_account) : Text(transaction.center!.display_name),
                                                                                                collapsedBackgroundColor: (dark_theme) ? Colors.white60 : Colors.grey.shade300,
                                                                                                backgroundColor: (dark_theme) ? Colors.white70 : Colors.grey.shade100,
                                                                                                children: <ListTile>[
                                                                                                  ListTile(
                                                                                                    title: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "profile-modals-transactions-transaction-center"), style: const TextStyle(fontSize: 12.0)),
                                                                                                    trailing: Text((transaction.center == null) ? '-' : transaction.center!.display_name, style: const TextStyle(fontSize: 14.0)),
                                                                                                  ),
                                                                                                  ListTile(
                                                                                                    title: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "profile-modals-transactions-transaction-amount"), style: const TextStyle(fontSize: 12.0)),
                                                                                                    trailing: Text(transaction.amount.toString(), style: const TextStyle(fontSize: 14.0)),
                                                                                                  ),
                                                                                                  ListTile(
                                                                                                    title: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "profile-modals-transactions-transaction-date"), style: const TextStyle(fontSize: 12.0)),
                                                                                                    trailing: Text(DateFormat("d MMMM, y").format(DateTime.fromMillisecondsSinceEpoch(transaction.created_timestamp * 1000)), style: const TextStyle(fontSize: 14.0)),
                                                                                                  ),
                                                                                                  ListTile(
                                                                                                    title: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "profile-modals-transactions-transaction-account"), style: const TextStyle(fontSize: 12.0)),
                                                                                                    trailing: Text(transaction.icafe_member_account, style: const TextStyle(fontSize: 14.0)),
                                                                                                  ),
                                                                                                  ListTile(
                                                                                                    title: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "profile-modals-transactions-transaction-status"), style: const TextStyle(fontSize: 12.0)),
                                                                                                    trailing: Text((transaction.status == 3) ? "Success" : "Pending", style: const TextStyle(fontSize: 14.0)),
                                                                                                  )
                                                                                                ],
                                                                                              )
                                                                                            ),
                                                                                            const Divider(color: Colors.transparent, height: 5.0)
                                                                                          ]
                                                                                      ),
                                                                                  ]
                                                                              )
                                                                          );
                                                                        }
                                                                    );
                                                                  });
                                                                }).catchError((error) {
                                                                  updateState(() {
                                                                    loadingState = false;
                                                                    showMessageDialog(context, localization.CivicLocale.translate(deviceLocale, "home-route", "profile-modals-transactions-exception-hint"), token.user, success: false, comment: error.toString());
                                                                  });
                                                                });
                                                              });
                                                            },
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(5.0)
                                                            ),
                                                            leading: Text(bank_card.country_code),
                                                            title: Text(bank_card.number),
                                                            trailing: (loadingState) ? const SizedBox(width: 20, height: 20, child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black)))) : const Icon(Icons.chevron_right, color: Colors.black),
                                                            tileColor: (dark_theme) ? Colors.white : Colors.grey.shade300
                                                        ),
                                                        const Divider(color: Colors.transparent, height: 5.0)
                                                      ],
                                                    )
                                                ]
                                              )
                                          );
                                        }
                                      )
                                  )
                                );
                              },
                              title: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "profile-settings-transactions-label"), style: TextStyle(color: (dark_theme) ? Colors.white : Colors.black)),
                              trailing: Icon(Icons.chevron_right, color: (dark_theme) ? Colors.white : Colors.grey)
                          ),
                          ListTile(
                              onTap: () {
                                showModalBottomSheet(
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero
                                    ),
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) {
                                      return Container(
                                          height: MediaQuery.of(context).size.height * 0.7,
                                          color: (dark_theme) ? Colors.black87 : Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                                          child: (snapshot.data["members"].isEmpty) ? Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.only(bottom: 15.0),
                                                  child: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "profile-modals-accounts-empty-title"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0, color: (dark_theme) ? Colors.white : Colors.black)),
                                                ),
                                                Text(
                                                    localization.CivicLocale.translate(deviceLocale, "home-route", "profile-modals-accounts-empty-hint"),
                                                    style: const TextStyle(fontSize: 12.0, color: Colors.grey)
                                                )
                                              ]
                                          ) : ListView(
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.only(bottom: 15.0),
                                                  child: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "profile-modals-accounts-title"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0, color: (dark_theme) ? Colors.white : Colors.black)),
                                                ),
                                                for (models.Member member in snapshot.data["members"])
                                                  Wrap(
                                                      children: <Widget>[
                                                        Material(
                                                            child: ListTile(
                                                                onTap: () {
                                                                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => CenterRoute(center_id: member.center.center_id)));
                                                                },
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(5.0)
                                                                ),
                                                                title: Text(member.account),
                                                                trailing: const Icon(Icons.chevron_right, color: Colors.black),
                                                                tileColor: (dark_theme) ? Colors.white70 : Colors.grey.shade300
                                                            )
                                                        ),
                                                        const Divider(color: Colors.transparent, height: 5.0)
                                                      ]
                                                  ),
                                              ]
                                          )
                                      );
                                    }
                                );
                              },
                              title: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "profile-settings-accounts-label"), style: TextStyle(color: (dark_theme) ? Colors.white : Colors.black)),
                              trailing: Icon(Icons.chevron_right, color: (dark_theme) ? Colors.white : Colors.grey)
                          ),
                          ListTile(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const SettingsRoute())).then((status) {
                                  setState(() {
                                    fetchedProfileData = false;
                                    fetchedHomeData = false;
                                    fetchedSearchData = false;
                                  });
                                });
                              },
                              title: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "profile-settings-settings-label"), style: TextStyle(color: (dark_theme) ? Colors.white : Colors.black)),
                              trailing: Icon(Icons.chevron_right, color: (dark_theme) ? Colors.white : Colors.grey)
                          ),
                          ListTile(
                              onTap: () async {
                                if (await canLaunchUrl(Uri.parse("https://t.me/icafeplay"))) {
                                  await launchUrl(Uri.parse("https://t.me/icafeplay"), mode: LaunchMode.platformDefault);
                                } else {
                                  showMessageDialog(context, localization.CivicLocale.translate(deviceLocale, "home-route", "profile-modals-support-exception-hint"), token.user, success: false, comment: localization.CivicLocale.translate(deviceLocale, "home-route", "profile-modals-support-exception-comment"));
                                }
                              },
                              title: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "profile-settings-support-label"), style: TextStyle(color: (dark_theme) ? Colors.white : Colors.black)),
                              trailing: Icon(Icons.chevron_right, color: (dark_theme) ? Colors.white : Colors.grey)
                          ),
                          ListTile(
                              textColor: Colors.red,
                              iconColor: Colors.red,
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      title: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "profile-modals-logout-confirm-title")),
                                      content: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "profile-modals-logout-confirm-hint")),
                                      actions: <TextButton>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(localization.CivicLocale.translate(deviceLocale, "general", "cancel-button-label")),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            storage.deleteData("userToken");
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "profile-modals-logout-confirm-button-label"), style: const TextStyle(color: Colors.red)),
                                        )
                                      ],
                                    );
                                  }
                                ).whenComplete(() {
                                  setState(() {
                                    fetchedProfileData = false;
                                  });
                                });
                              },
                              title: Text(localization.CivicLocale.translate(deviceLocale, "home-route", "profile-settings-logout-label")),
                              trailing: const Icon(Icons.chevron_right)
                          )
                        ]
                      )
                    )
                  ]
                )
              );
            }
          } else if (snapshot.hasError) {
            return ErrorRoute(message: localization.CivicLocale.translate(deviceLocale, "home-route", "profile-exception-hint"), requestUpdate: setState);
          }
          return LoadingRoute(dark_theme: dark_theme);
        }
      );
    }
    return ErrorRoute(message: localization.CivicLocale.translate(deviceLocale, "home-route", "profile-exception-hint"), requestUpdate: setState);
  }

  @override
  void dispose() {
    searchFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: storage.readStringData("userToken"),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data != "undefined") {
            models.UserToken token = models.UserToken.convert(json.decode(snapshot.data!));
            if (token.user.dark_theme != null) dark_theme = token.user.dark_theme!;
          }
          return GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: SafeArea(
              child: Scaffold(
                bottomNavigationBar: NavigationBarTheme(
                  data: NavigationBarThemeData(
                    labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((Set<WidgetState> states) => states.contains(WidgetState.selected) ? TextStyle(color: (dark_theme) ? Colors.white : Colors.black, fontSize: 12.0) : TextStyle(color: (dark_theme) ? Colors.white60 : Colors.black54, fontSize: 12.0))
                  ),
                  child: NavigationBar(
                    backgroundColor: (dark_theme) ? Colors.black87 : Colors.white,
                    shadowColor: Colors.black,
                    indicatorColor: (dark_theme) ? const Color(0xFFEEEEEE) : Colors.black,
                    onDestinationSelected: (int page) {
                      setState(() {
                        currentPage = page;
                      });
                    },
                    selectedIndex: currentPage,
                    destinations: <NavigationDestination>[
                      NavigationDestination(
                        selectedIcon: Icon(Icons.home, color: (dark_theme) ? Colors.black : Colors.white),
                        icon: Icon(Icons.home_outlined, color: (dark_theme) ? Colors.white : Colors.black),
                        label: localization.CivicLocale.translate(deviceLocale, "home-route", "bottom-navbar-home-label")
                      ),
                      NavigationDestination(
                        selectedIcon: Icon(Icons.search, color: (dark_theme) ? Colors.black : Colors.white),
                        icon: Icon(Icons.search, color: (dark_theme) ? Colors.white : Colors.black),
                        label: localization.CivicLocale.translate(deviceLocale, "home-route", "bottom-navbar-search-label")
                      ),
                      NavigationDestination(
                        selectedIcon: Icon(Icons.account_circle, color: (dark_theme) ? Colors.black : Colors.white),
                        icon: Icon(Icons.account_circle_outlined, color: (dark_theme) ? Colors.white : Colors.black),
                        label: localization.CivicLocale.translate(deviceLocale, "home-route", "bottom-navbar-profile-label")
                      )
                    ]
                  ),
                ),
                body: selectPageByIndex(currentPage)
              )
            )
          );
        }
        return const SizedBox.shrink();
      }
    );
  }
}