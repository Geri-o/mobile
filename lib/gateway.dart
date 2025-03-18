import "dart:convert";
import "package:http/http.dart" as http;
import "models.dart" as models;

const ENDPOINT = "https://cp.icafeplay.ru";
// const ENDPOINT = "http://192.168.0.107:8000";
// const ENDPOINT = "http://192.168.1.132:8000";

Future<Map<String, dynamic>> authenticateUser(dynamic payload) async {
  http.Response response = await http.post(Uri.parse("$ENDPOINT/user/mobile/authenticate"), body: json.encode(payload));

  if (response.statusCode == 200) {
    return json.decode(utf8.decode(response.bodyBytes));
  } else {
    Map<String, dynamic> error = json.decode(response.body);
    if (error.containsKey("detail")) {
      throw Exception(error["detail"]);
    }
    throw Exception("!UNKNOWN ERROR");
  }
}
Future<Map<String, dynamic>> registerUser(dynamic payload) async {
  http.Response response = await http.post(Uri.parse("$ENDPOINT/user/mobile/register"), body: json.encode(payload));

  if (response.statusCode == 200) {
    return json.decode(utf8.decode(response.bodyBytes));
  } else {
    Map<String, dynamic> error = json.decode(response.body);
    if (error.containsKey("detail")) {
      throw Exception(error["detail"]);
    }
    throw Exception("!UNKNOWN ERROR");
  }
}
Future<Map<String, dynamic>> editUser(dynamic payload, int user_id) async {
  http.Response response = await http.put(Uri.parse("$ENDPOINT/user/?user_id=$user_id"), body: json.encode(payload));

  if (response.statusCode == 200) {
    return json.decode(utf8.decode(response.bodyBytes));
  } else {
    Map<String, dynamic> error = json.decode(response.body);
    if (error.containsKey("detail")) {
      throw Exception(error["detail"]);
    }
    throw Exception("!UNKNOWN ERROR");
  }
}
Future<Map<String, dynamic>> editUserPassword(dynamic payload, int user_id) async {
  http.Response response = await http.put(Uri.parse("$ENDPOINT/user/password/?user_id=$user_id"), body: json.encode(payload));

  if (response.statusCode == 200) {
    return json.decode(utf8.decode(response.bodyBytes));
  } else {
    Map<String, dynamic> error = json.decode(response.body);
    if (error.containsKey("detail")) {
      throw Exception(error["detail"]);
    }
    throw Exception("!UNKNOWN ERROR");
  }
}
Future<models.Member> linkMemberAccount(dynamic payload) async {
  http.Response response = await http.post(Uri.parse("$ENDPOINT/user/member/link"), body: json.encode(payload));

  if (response.statusCode == 200) {
    return models.Member.convert(json.decode(utf8.decode(response.bodyBytes)));
  } else {
    Map<String, dynamic> error = json.decode(response.body);
    if (error.containsKey("detail")) {
      if (error["detail"].contains("401")) {
        throw Exception("Incorrect password!");
      } else if (error["detail"].contains("404")) {
        throw Exception("Member account not found!");
      } else if (error["detail"].contains("409")) {
        throw Exception("Member account is already linked to another account!");
      } else {
        throw Exception("!Something went wrong, please try again later.");
      }
    }
    throw Exception("!UNKNOWN ERROR");
  }
}
Future<bool> createBankCard(dynamic payload) async {
  http.Response response = await http.post(Uri.parse("$ENDPOINT/gateway/bank-card"), body: json.encode(payload));

  if (response.statusCode == 200) {
    return json.decode(utf8.decode(response.bodyBytes));
  } else {
    Map<String, dynamic> error = json.decode(response.body);
    if (error.containsKey("detail")) {
      throw Exception(error["detail"]);
    }
    throw Exception("!UNKNOWN ERROR");
  }
}
Future<bool> linkBankCard(dynamic payload) async {
  http.Response response = await http.post(Uri.parse("$ENDPOINT/gateway/bank-card/link"), body: json.encode(payload));

  if (response.statusCode == 200) {
    return json.decode(utf8.decode(response.bodyBytes));
  } else {
    Map<String, dynamic> error = json.decode(response.body);
    if (error.containsKey("detail")) {
      throw Exception(error["detail"]);
    }
    throw Exception("!UNKNOWN ERROR");
  }
}
Future<bool> resendVerificationCode(dynamic payload) async {
  http.Response response = await http.post(Uri.parse("$ENDPOINT/gateway/bank-card/resend"), body: json.encode(payload));

  if (response.statusCode == 200) {
    return json.decode(utf8.decode(response.bodyBytes));
  } else {
    Map<String, dynamic> error = json.decode(response.body);
    if (error.containsKey("detail")) {
      throw Exception(error["detail"]);
    }
    throw Exception("!UNKNOWN ERROR");
  }
}
Future<bool> verifyBankCard(dynamic payload) async {
  http.Response response = await http.post(Uri.parse("$ENDPOINT/gateway/bank-card/verify"), body: json.encode(payload));

  if (response.statusCode == 200) {
    return json.decode(utf8.decode(response.bodyBytes));
  } else {
    Map<String, dynamic> error = json.decode(response.body);
    if (error.containsKey("detail")) {
      throw Exception(error["detail"]);
    }
    throw Exception("!UNKNOWN ERROR");
  }
}
Future<models.BankCardToken?> acquireBankCardToken(dynamic payload) async {
  http.Response response = await http.post(Uri.parse("$ENDPOINT/gateway/bank-card/bank-card-token/acquire"), body: json.encode(payload));

  if (response.statusCode == 200) {
    return models.BankCardToken.convert(json.decode(utf8.decode(response.bodyBytes)));
  } else {
    return null;
  }
}
Future<models.BankCardWithToken?> acquireBankCardWithToken(dynamic payload) async {
  http.Response response = await http.post(Uri.parse("$ENDPOINT/gateway/bank-card/acquire"), body: json.encode(payload));

  if (response.statusCode == 200) {
    return models.BankCardWithToken.convert(json.decode(utf8.decode(response.bodyBytes)));
  } else {
    return null;
  }
}
Future<Map<String, dynamic>> topupAccount(dynamic payload) async {
  http.Response response = await http.post(Uri.parse("$ENDPOINT/gateway/transaction/topup"), body: json.encode(payload));

  if (response.statusCode == 200) {
    return json.decode(utf8.decode(response.bodyBytes));
  } else {
    Map<String, dynamic> error = json.decode(response.body);
    if (error.containsKey("detail")) {
      throw Exception(error["detail"]);
    }
    throw Exception("!UNKNOWN ERROR");
  }
}
Future<bool> placeBooking(dynamic payload) async {
  http.Response response = await http.post(Uri.parse("$ENDPOINT/gateway/booking"), body: json.encode(payload));

  if (response.statusCode == 200) {
    return true;
  } else {
    Map<String, dynamic> error = json.decode(response.body);
    if (error.containsKey("detail")) {
      throw Exception(error["detail"]);
    }
    throw Exception("!UNKNOWN ERROR");
  }
}

Future<Map<String, dynamic>> fetchUserToken(int user_token_id) async {
  http.Response response = await http.get(Uri.parse("$ENDPOINT/user/token/?user_token_id=$user_token_id"));

  if (response.statusCode == 200) {
    return json.decode(utf8.decode(response.bodyBytes));
  } else {
    Map<String, dynamic> error = json.decode(response.body);
    if (error.containsKey("detail")) {
      throw Exception(error["detail"]);
    }
    throw Exception("!UNKNOWN ERROR");
  }
}
Future<List<models.Country>> fetchCountries() async {
  http.Response response = await http.get(Uri.parse("$ENDPOINT/gateway/country/all"));

  if (response.statusCode == 200) {
    dynamic countries = json.decode(utf8.decode(response.bodyBytes));
    return List.generate(countries.length, (index) => models.Country.convert(countries[index]));
  } else {
    throw Exception("!Error");
  }
}
Future<List<models.Center>> fetchCenters() async {
  http.Response response = await http.get(Uri.parse("$ENDPOINT/gateway/center/all"));

  if (response.statusCode == 200) {
    dynamic centers = json.decode(utf8.decode(response.bodyBytes));
    return List.generate(centers.length, (index) => models.Center.convert(centers[index]));
  } else {
    throw Exception("!ERROR: COULD NOT LOAD CENTERS");
  }
}
Future<Map<String, dynamic>> fetchComputers(int center_id) async {
  http.Response response = await http.get(Uri.parse("$ENDPOINT/gateway/mobile/computer/demand/?center_id=$center_id"));

  if (response.statusCode == 200) {
    return json.decode(utf8.decode(response.bodyBytes));
  } else {
    throw Exception("!ERROR: COULD NOT LOAD PCS");
  }
}
Future<Map<String, dynamic>> fetchBookings(int center_id) async {
  http.Response response = await http.get(Uri.parse("$ENDPOINT/gateway/mobile/booking/demand/?center_id=$center_id"));

  if (response.statusCode == 200) {
    return json.decode(utf8.decode(response.bodyBytes));
  } else {
    throw Exception("!ERROR: COULD NOT LOAD BOOKINGS");
  }
}
Future<List<models.Booking>> fetchUserBookings(int user_id) async {
  http.Response response = await http.get(Uri.parse("$ENDPOINT/gateway/mobile/booking/user/?user_id=$user_id"));

  if (response.statusCode == 200) {
    dynamic bookings = json.decode(utf8.decode(response.bodyBytes));
    return List.generate(bookings.length, (index) => models.Booking.convert(bookings[index]));
  } else {
    throw Exception("!ERROR: COULD NOT LOAD BOOKINGS");
  }
}
Future<models.Booking?> fetchUserActiveBooking(int user_id) async {
  http.Response response = await http.get(Uri.parse("$ENDPOINT/gateway/mobile/booking/user/?user_id=$user_id"));

  if (response.statusCode == 200) {
    return models.Booking.convert(json.decode(utf8.decode(response.bodyBytes)));
  } else {
    return null;
  }
}
Future<models.Center> fetchSingleCenter(int center_id) async {
  http.Response response = await http.get(Uri.parse("$ENDPOINT/gateway/center/?center_id=$center_id"));

  if (response.statusCode == 200) {
    models.Center center = models.Center.convert(json.decode(utf8.decode(response.bodyBytes)));
    return center;
  } else {
    throw Exception("!ERROR: COULD NOT LOAD CENTER");
  }
}
Future<models.Member?> fetchUserMember(int user_id, int center_id) async {
  http.Response response = await http.get(Uri.parse("$ENDPOINT/user/member/user/center/?user_id=$user_id&center_id=$center_id"));

  if (response.statusCode == 200) {
    models.Member member = models.Member.convert(json.decode(utf8.decode(response.bodyBytes)));
    return member;
  } else {
    return null;
  }
}
Future<models.Member?> fetchUserMemberBalance(int member_id) async {
  http.Response response = await http.get(Uri.parse("$ENDPOINT/user/member/balance/?member_id=$member_id"));

  if (response.statusCode == 200) {
    models.Member member = models.Member.convert(json.decode(utf8.decode(response.bodyBytes)));
    return member;
  } else {
    return null;
  }
}
Future<models.BankCard?> fetchUserBankCard(int user_id) async {
  http.Response response = await http.get(Uri.parse("$ENDPOINT/gateway/bank-card/user/?user_id=$user_id"));

  if (response.statusCode == 200) {
    models.BankCard member = models.BankCard.convert(json.decode(utf8.decode(response.bodyBytes)));
    return member;
  } else {
    return null;
  }
}
Future<List<models.BankCard>> fetchUserBankCards(int user_id) async {
  http.Response response = await http.get(Uri.parse("$ENDPOINT/gateway/bank-card/user/all/?user_id=$user_id"));

  if (response.statusCode == 200) {
    dynamic bank_cards = json.decode(utf8.decode(response.bodyBytes));
    return List.generate(bank_cards.length, (index) => models.BankCard.convert(bank_cards[index]));
  } else {
    throw Exception("!ERROR: COULD NOT lOAD BANK CARDS LIST");
  }
}
Future<List<models.Transaction>> fetchUserTransactions(int bank_card_id) async {
  http.Response response = await http.get(Uri.parse("$ENDPOINT/gateway/transaction/bank-card/?bank_card_id=$bank_card_id"));

  if (response.statusCode == 200) {
    dynamic transactions = json.decode(utf8.decode(response.bodyBytes));
    return List.generate(transactions.length, (index) => models.Transaction.convert(transactions[index]));
  } else {
    throw Exception("!ERROR: COULD NOT lOAD BANK CARDS LIST");
  }
}
Future<List<models.Member>> fetchUserMembers(int user_id) async {
  http.Response response = await http.get(Uri.parse("$ENDPOINT/user/member/user/?user_id=$user_id"));

  if (response.statusCode == 200) {
    dynamic members = json.decode(utf8.decode(response.bodyBytes));
    members = List.generate(members.length, (index) => models.Member.convert(members[index]));
    return members;
  } else {
    throw Exception("!ERROR: COULD NOT LOAD MEMBERS LIST");
  }
}

Future<bool> unlinkMemberAccount(int member_id) async {
  http.Response response = await http.delete(Uri.parse("$ENDPOINT/user/member/?member_id=$member_id"));

  if (response.statusCode == 200) {
    return true;
  } else {
    Map<String, dynamic> error = json.decode(response.body);
    if (error.containsKey("detail")) {
      throw Exception(error["detail"]);
    }
    throw Exception("!UNKNOWN ERROR");
  }
}
Future<bool> deleteUserBankCard(int bank_card_id) async {
  http.Response response = await http.delete(Uri.parse("$ENDPOINT/gateway/bank-card/?bank_card_id=$bank_card_id"));

  if (response.statusCode == 200) {
    return true;
  } else {
    Map<String, dynamic> error = json.decode(response.body);
    if (error.containsKey("detail")) {
      throw Exception(error["detail"]);
    }
    throw Exception("!UNKNOWN ERROR");
  }
}