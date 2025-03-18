import 'dart:io';

import 'package:flutter/material.dart';
import 'package:icafeplay/dialogs.dart';
import 'package:icafeplay/error_route.dart';
import 'package:icafeplay/loading_route.dart';
import 'package:icafeplay/models.dart' as models;
import 'package:icafeplay/gateway.dart' as gateway;
import 'package:icafeplay/localization.dart' as localization;
import 'package:intl/intl.dart';

class BookingRoute extends StatefulWidget {
  final models.Center center;
  final models.Member member;
  const BookingRoute({super.key, required this.center, required this.member});

  @override
  State<BookingRoute> createState() => BookingRouteState();
}

class BookingRouteState extends State<BookingRoute> {
  String deviceLocale = Platform.localeName.split('_')[0].toUpperCase();
  bool dark_theme = true;

  bool loadingState = false;

  TextEditingController memberFieldController = TextEditingController();
  TextEditingController centerFieldController = TextEditingController();
  DateTime selectedDate = DateTime(1999);
  String selectedDateHint = "Date";
  TimeOfDay selectedTime = TimeOfDay(hour: -1, minute: -1);
  String selectedTimeHint = "Time";
  bool hintsLoaded = false;
  TextEditingController minutesFieldController = TextEditingController();
  String selectedComputer = '';

  bool fetchedBookingData = false;
  Map<String, dynamic> cachedBookingData = <String, dynamic>{};
  Future<Map<String, dynamic>> fetchBookingData(int center_id) async {
    if (fetchedBookingData == false) {
      cachedBookingData = <String, dynamic>{
        "bookings": await gateway.fetchBookings(center_id),
        "computers": await gateway.fetchComputers(center_id)
      };
      fetchedBookingData = true;
    }
    return cachedBookingData;
  }


  @override
  Widget build(BuildContext context) {
    memberFieldController.text = widget.member.account;
    centerFieldController.text = widget.center.display_name;
    deviceLocale = widget.member.user.language!;
    dark_theme = (widget.member.user.dark_theme != null) ? widget.member.user.dark_theme! : dark_theme;
    if (hintsLoaded == false) {
      selectedDateHint = localization.CivicLocale.translate(deviceLocale, "booking-route", "date-input-hint");
      selectedTimeHint = localization.CivicLocale.translate(deviceLocale, "booking-route", "time-input-hint");
    }
    hintsLoaded = true;
    return FutureBuilder(
      future: fetchBookingData(widget.center.center_id),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: (dark_theme) ? Colors.black87 : Colors.white,
                leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.arrow_back, color: (dark_theme) ? Colors.white : Colors.black)
                )
              ),
              body: Container(
                color: (dark_theme) ? Colors.black87 : Colors.white,
                child: ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                            child: Text(localization.CivicLocale.translate(deviceLocale, "booking-route", "booking-route-title"), style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black)),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20.0, right: 10.0),
                                  child: TextField(
                                    autocorrect: false,
                                    controller: memberFieldController,
                                    enabled: false,
                                    style: TextStyle(fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                                      disabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(width: 1.0, color: (dark_theme) ? Colors.white : Colors.grey),
                                        borderRadius: BorderRadius.zero
                                      ),
                                      hintText: localization.CivicLocale.translate(deviceLocale, "booking-route", "member-input-hint"),
                                      hintStyle: const TextStyle(color: Colors.grey)
                                    )
                                  )
                                )
                              ),
                              Expanded(
                                  child: Padding(
                                      padding: const EdgeInsets.only(left: 10.0, right: 20.0),
                                      child: TextField(
                                          autocorrect: false,
                                          controller: centerFieldController,
                                          enabled: false,
                                          style: TextStyle(fontWeight: FontWeight.bold, color: (dark_theme) ? Colors.white : Colors.black),
                                          decoration: InputDecoration(
                                              contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                                              disabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(width: 1.0, color: (dark_theme) ? Colors.white : Colors.grey),
                                                  borderRadius: BorderRadius.zero
                                              ),
                                              hintText: localization.CivicLocale.translate(deviceLocale, "booking-route", "center-input-hint"),
                                              hintStyle: const TextStyle(color: Colors.grey)
                                          )
                                      )
                                  )
                              )
                            ]
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Row(
                                children: [
                                  Expanded(
                                      child: Padding(
                                          padding: const EdgeInsets.only(left: 20.0, right: 10.0),
                                          child: FilledButton(
                                            onPressed: () {
                                              showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime(DateTime.now().year),
                                                lastDate: DateTime(DateTime.now().year + 1),
                                                builder: (BuildContext context, child) {
                                                  return Theme(
                                                    data: Theme.of(context).copyWith(
                                                      colorScheme: const ColorScheme.light(
                                                        primary: Colors.black,
                                                        onPrimary: Colors.white,
                                                        onSurface: Colors.black
                                                      )
                                                    ),
                                                    child: child!,
                                                  );
                                                }
                                              ).then((pickedDate) {
                                                setState(() {
                                                  if (pickedDate == null) {
                                                    selectedDate = DateTime.now();
                                                  } else {
                                                    selectedDate = pickedDate;
                                                  }
                                                  selectedDateHint = DateFormat("d-M-y").format(selectedDate);
                                                });
                                              });
                                            },
                                            style: FilledButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(width: 1.0, color: (dark_theme) ? Colors.white : Colors.black)),
                                              backgroundColor: Colors.transparent,
                                              foregroundColor: (dark_theme) ? Colors.white : Colors.black,
                                            ),
                                            child: Align(alignment: Alignment.topLeft, child: Text(selectedDateHint)),
                                          )
                                      )
                                  ),
                                  Expanded(
                                      child: Padding(
                                          padding: const EdgeInsets.only(left: 10.0, right: 20.0),
                                          child: FilledButton(
                                            onPressed: () {
                                              showTimePicker(
                                                context: context,
                                                initialTime: TimeOfDay.now(),
                                                initialEntryMode: TimePickerEntryMode.input,
                                                builder: (BuildContext context, child) {
                                                  return Theme(
                                                    data: Theme.of(context).copyWith(
                                                      colorScheme: const ColorScheme.light(
                                                        primary: Colors.black,
                                                        onPrimary: Colors.white,
                                                        onSurface: Colors.black
                                                      )
                                                    ),
                                                    child: child!,
                                                  );
                                                }
                                              ).then((pickedTime) {
                                                setState(() {
                                                  if (pickedTime == null) {
                                                    selectedTime = TimeOfDay(hour: TimeOfDay.now().hour, minute: TimeOfDay.now().minute + 30);
                                                    if (selectedTime.minute > 60) {
                                                      selectedTime = TimeOfDay(hour: selectedTime.hour + 1, minute: selectedTime.minute - 60);
                                                    }
                                                  } else {
                                                    selectedTime = pickedTime;
                                                  }
                                                  selectedTimeHint = selectedTime.format(context);
                                                });
                                              });
                                            },
                                            style: FilledButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(width: 1.0, color: (dark_theme) ? Colors.white : Colors.black)),
                                              backgroundColor: Colors.transparent,
                                              foregroundColor: (dark_theme) ? Colors.white : Colors.black,
                                            ),
                                            child: Align(alignment: Alignment.topLeft, child: Text(selectedTimeHint)),
                                          )
                                      )
                                  ),
                                ]
                            )
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Row(
                                children: [
                                  Expanded(
                                      child: Padding(
                                          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                                          child: TextField(
                                              autocorrect: false,
                                              controller: minutesFieldController,
                                              keyboardType: TextInputType.number,
                                              style: TextStyle(fontWeight: FontWeight.normal, color: (dark_theme) ? Colors.white : Colors.black),
                                              decoration: InputDecoration(
                                                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                                                  enabledBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(width: 1.0, color: (dark_theme) ? Colors.white : Colors.black),
                                                      borderRadius: BorderRadius.zero
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(width: 1.0, color: (dark_theme) ? Colors.white54 : Colors.black54),
                                                      borderRadius: BorderRadius.zero
                                                  ),
                                                  hintText: localization.CivicLocale.translate(deviceLocale, "booking-route", "minutes-input-hint"),
                                                  hintStyle: const TextStyle(color: Colors.grey)
                                              )
                                          )
                                      )
                                  )
                                ]
                            )
                          ),
                          Container(
                            color: Colors.black12,
                            margin: const EdgeInsets.symmetric(vertical: 20.0),
                            height: MediaQuery.of(context).size.height * 0.05,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Wrap(
                              children: <Widget>[
                                for (int index = 0; index < snapshot.data!["computers"]["data"].length; index++)
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        if ((selectedComputer == snapshot.data!["computers"]["data"][index]["pc_name"])) {
                                          selectedComputer = '';
                                        } else {
                                          selectedComputer = snapshot.data!["computers"]["data"][index]["pc_name"];
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                      margin: const EdgeInsets.only(right: 15.0, bottom: 15.0),
                                      decoration: BoxDecoration(
                                        color: (selectedComputer == snapshot.data!["computers"]["data"][index]["pc_name"]) ? (dark_theme) ? Colors.white : Colors.black : (dark_theme) ? Colors.grey : Colors.white,
                                        borderRadius: BorderRadius.circular(5.0),
                                        border: Border.all(width: 1.0, color: Colors.black)
                                      ),
                                      child: Text(
                                        snapshot.data!["computers"]["data"][index]["pc_name"],
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                            color: (selectedComputer == snapshot.data!["computers"]["data"][index]["pc_name"]) ? (dark_theme) ? Colors.black : Colors.white : Colors.black
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.clip,
                                      )
                                    )
                                  )
                              ]
                            )
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            margin: const EdgeInsets.only(top: 10.0),
                            width: MediaQuery.of(context).size.width,
                            child: FilledButton(
                              onPressed: () {
                                if (selectedComputer.isNotEmpty && selectedDate.isAfter(DateTime(1999)) && selectedTime.hour > -1 && minutesFieldController.text.isNotEmpty) {
                                  setState(() {
                                    loadingState = true;
                                    gateway.placeBooking({
                                      "member_id": widget.member.member_id,
                                      "center_id": widget.center.center_id,
                                      "date": DateFormat("y-M-d").format(selectedDate),
                                      "time": selectedTime.format(context),
                                      "minutes": minutesFieldController.text,
                                      "computer": selectedComputer
                                    }).then((result) {
                                      setState(() {
                                        loadingState = false;
                                      });
                                      showMessageDialog(context, localization.CivicLocale.translate(deviceLocale, "dialogs", "booking-success-title"), widget.member.user, success: true, comment: localization.CivicLocale.translate(deviceLocale, "dialogs", "booking-success-caption"), popOnExit: true);
                                    }).catchError((error) {
                                      setState(() {
                                        loadingState = false;
                                        showMessageDialog(context, localization.CivicLocale.translate(deviceLocale, "dialogs", "booking-failed-to-book"), widget.member.user, success: false, comment: error.toString());
                                      });
                                    });
                                  });
                                } else {
                                  showMessageDialog(context, localization.CivicLocale.translate(deviceLocale, "dialogs", "booking-empty-inputs-title"), widget.member.user, success: false, comment: localization.CivicLocale.translate(deviceLocale, "dialogs", "booking-empty-inputs-subtitle"));
                                }
                              },
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                padding: const EdgeInsets.symmetric(vertical: 15.0),
                                backgroundColor: (dark_theme) ? const Color(0xFFEEEEEE) : Colors.black,
                                foregroundColor: (dark_theme) ? Colors.black : Colors.white
                              ),
                              child: (loadingState) ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)) : Text(localization.CivicLocale.translate(deviceLocale, "booking-route", "booking-primary-button-label")),
                            )
                          )
                        ]
                      )
                    )
                  ]
                )
              )
            ),
          );
        } else if (snapshot.hasError) {
          return ErrorRoute(message: localization.CivicLocale.translate(deviceLocale, "booking-route", "booking-failed-to-fetch-list"), requestUpdate: setState);
        }
        return LoadingRoute(dark_theme: dark_theme);
      }
    );
  }
}