class Country{
  final int country_id;
  final String name;
  final bool is_visible;

  const Country({
    required this.country_id,
    required this.name,
    required this.is_visible
  });

  factory Country.convert(Map<String, dynamic> json) {
    return Country(
        country_id: json["country_id"],
        name: json["name"],
        is_visible: json["is_visible"]
    );
  }
}

class User{
  final int user_id;
  final String name;
  final String email;
  final String? language;
  final bool? dark_theme;
  final bool confirmed;
  final bool is_active;
  final bool is_admin;
  final Country country;

  const User({
    required this.user_id,
    required this.name,
    required this.email,
    required this.language,
    required this.dark_theme,
    required this.confirmed,
    required this.is_active,
    required this.is_admin,
    required this.country
  });

  factory User.convert(Map<String, dynamic> json) {
    return User(
      user_id: json["user_id"],
      name: json["name"],
      email: json["email"],
      language: json["language"],
      dark_theme: json["dark_theme"],
      confirmed: json["confirmed"],
      is_active: json["is_active"],
      is_admin: json["is_admin"],
      country: Country.convert(json["country"])
    );
  }
}

class UserToken{
  final int user_token_id;
  final String token;
  final bool is_active;
  final User user;

  const UserToken({
    required this.user_token_id,
    required this.token,
    required this.is_active,
    required this.user
  });

  factory UserToken.convert(Map<String, dynamic> json) {
    return UserToken(
        user_token_id: json["user_token_id"],
        token: json["token"],
        is_active: json["is_active"],
        user: User.convert(json["user"])
    );
  }
}

class ImageFile{
  final int image_file_id;
  final String path;

  const ImageFile({
    required this.image_file_id,
    required this.path
  });

  factory ImageFile.convert(Map<String, dynamic> json) {
    return ImageFile(
        image_file_id: json["image_file_id"],
        path: json["path"]
    );
  }
}

class Zone{
  final int zone_id;
  final String name;
  final String? description;
  final String specifications;
  final int? computer_count;

  const Zone({
    required this.zone_id,
    required this.name,
    required this.description,
    required this.specifications,
    required this.computer_count
  });

  factory Zone.convert(Map<String, dynamic> json) {
    return Zone(
        zone_id: json["zone_id"],
        name: json["name"],
        description: json["description"],
        specifications: json["specifications"],
        computer_count: json["computer_count"]
    );
  }
}

class Product{
  final int product_id;
  final String name;
  final String display_name;
  final String price;
  final bool is_visible;

  const Product({
    required this.product_id,
    required this.name,
    required this.display_name,
    required this.price,
    required this.is_visible
  });

  factory Product.convert(Map<String, dynamic> json) {
    return Product(
        product_id: json["product_id"],
        name: json["name"],
        display_name: json["display_name"],
        price: json["price"],
        is_visible: json["is_visible"]
    );
  }
}

class Subcenter{
  final int center_id;
  final String name;
  final String display_name;
  final String? description;
  final String? phone_number;
  final String? address;
  final bool is_active;
  final bool allow_booking;
  final bool allow_topup;
  final bool configured;
  final bool is_subcenter;
  final List<ImageFile> image_files;
  final User owner;
  final Country country;

  const Subcenter({
    required this.center_id,
    required this.name,
    required this.display_name,
    required this.description,
    required this.phone_number,
    required this.address,
    required this.is_active,
    required this.allow_booking,
    required this.allow_topup,
    required this.configured,
    required this.is_subcenter,
    required this.image_files,
    required this.owner,
    required this.country
  });

  factory Subcenter.convert(Map<String, dynamic> json) {
    return Subcenter(
        center_id: json["center_id"],
        name: json["name"],
        display_name: json["display_name"],
        description: json["description"],
        phone_number: json["phone_number"],
        address: json["address"],
        is_active: json["is_active"],
        allow_booking: json["allow_booking"],
        allow_topup: json["allow_topup"],
        configured: json["configured"],
        is_subcenter: json["is_subcenter"],
        image_files: List<ImageFile>.generate(json["image_files"].length, (index) => ImageFile.convert(json["image_files"][index])),
        owner: User.convert(json["owner"]),
        country: Country.convert(json["country"])
    );
  }
}

class Center{
  final int center_id;
  final String name;
  final String display_name;
  final String? description;
  final String? phone_number;
  final String? address;
  final int computer_count;
  final bool is_active;
  final bool allow_booking;
  final bool allow_topup;
  final bool allow_topup_uz;
  final bool allow_topup_ru;
  final bool allow_topup_kz;
  final bool configured;
  final bool is_subcenter;
  final User owner;
  final List<ImageFile> image_files;
  final List<Zone> zones;
  final List<Product> products;
  final List<Subcenter> subcenters;
  final Country country;

  const Center({
    required this.center_id,
    required this.name,
    required this.display_name,
    required this.description,
    required this.phone_number,
    required this.address,
    required this.computer_count,
    required this.is_active,
    required this.allow_booking,
    required this.allow_topup,
    required this.allow_topup_uz,
    required this.allow_topup_ru,
    required this.allow_topup_kz,
    required this.configured,
    required this.is_subcenter,
    required this.owner,
    required this.image_files,
    required this.zones,
    required this.products,
    required this.subcenters,
    required this.country
  });

  factory Center.convert(Map<String, dynamic> json) {
    return Center(
        center_id: json["center_id"],
        name: json["name"],
        display_name: json["display_name"],
        description: json["description"],
        phone_number: json["phone_number"],
        address: json["address"],
        computer_count: json["computer_count"],
        is_active: json["is_active"],
        allow_booking: json["allow_booking"],
        allow_topup: json["allow_topup"],
        allow_topup_uz: json["allow_topup_uz"],
        allow_topup_ru: json["allow_topup_ru"],
        allow_topup_kz: json["allow_topup_kz"],
        configured: json["configured"],
        is_subcenter: json["is_subcenter"],
        owner: User.convert(json["owner"]),
        image_files: List<ImageFile>.generate(json["image_files"].length, (index) => ImageFile.convert(json["image_files"][index])),
        zones: List<Zone>.generate(json["zones"].length, (index) => Zone.convert(json["zones"][index])),
        products: List<Product>.generate(json["products"].length, (index) => Product.convert(json["products"][index])),
        subcenters: List<Subcenter>.generate(json["subcenters"].length, (index) => Subcenter.convert(json["subcenters"][index])),
        country: Country.convert(json["country"])
    );
  }
}

class CenterLite{
  final int center_id;
  final String name;
  final String display_name;
  final String? description;
  final String? phone_number;
  final String? address;
  final int computer_count;
  final bool is_active;
  final bool allow_booking;
  final bool allow_topup;
  final bool configured;
  final bool is_subcenter;

  const CenterLite({
    required this.center_id,
    required this.name,
    required this.display_name,
    required this.description,
    required this.phone_number,
    required this.address,
    required this.computer_count,
    required this.is_active,
    required this.allow_booking,
    required this.allow_topup,
    required this.configured,
    required this.is_subcenter,
  });

  factory CenterLite.convert(Map<String, dynamic> json) {
    return CenterLite(
        center_id: json["center_id"],
        name: json["name"],
        display_name: json["display_name"],
        description: json["description"],
        phone_number: json["phone_number"],
        address: json["address"],
        computer_count: json["computer_count"],
        is_active: json["is_active"],
        allow_booking: json["allow_booking"],
        allow_topup: json["allow_topup"],
        configured: json["configured"],
        is_subcenter: json["is_subcenter"]
    );
  }
}

class Member{
  final int member_id;
  final String account;
  final String cash_balance;
  final String points_balance;
  final String coins_balance;
  final String bonus_balance;
  final User user;
  final CenterLite center;

  const Member({
    required this.member_id,
    required this.account,
    required this.cash_balance,
    required this.points_balance,
    required this.coins_balance,
    required this.bonus_balance,
    required this.user,
    required this.center
  });

  factory Member.convert(Map<String, dynamic> json) {
    return Member(
        member_id: json["member_id"],
        account: json["account"],
        cash_balance: json["cash_balance"],
        points_balance: json["points_balance"],
        coins_balance: json["coins_balance"],
        bonus_balance: json["bonus_balance"],
        user: User.convert(json["user"]),
        center: CenterLite.convert(json["center"])
    );
  }
}

class BankCard{
  final int bank_card_id;
  final String number;
  final String phone_number;
  final String expiry_date;
  final String country_code;
  final String currency_code;
  final User user;

  const BankCard({
    required this.bank_card_id,
    required this.number,
    required this.phone_number,
    required this.expiry_date,
    required this.country_code,
    required this.currency_code,
    required this.user
  });

  factory BankCard.convert(Map<String, dynamic> json) {
    return BankCard(
        bank_card_id: json["bank_card_id"],
        number: json["number"],
        phone_number: json["phone_number"],
        expiry_date: json["expiry_date"],
        country_code: json["country_code"],
        currency_code: json["currency_code"],
        user: User.convert(json["user"])
    );
  }
}

class BankCardToken{
  final int bank_card_token_id;
  final String processor_name;
  final bool verified;
  final String token;
  final int bank_card_id;
  final int center_id;

  const BankCardToken({
    required this.bank_card_token_id,
    required this.processor_name,
    required this.verified,
    required this.token,
    required this.bank_card_id,
    required this.center_id
  });

  factory BankCardToken.convert(Map<String, dynamic> json) {
    return BankCardToken(
        bank_card_token_id: json["bank_card_token_id"],
        processor_name: json["processor_name"],
        verified: json["verified"],
        token: json["token"],
        bank_card_id: json["bank_card_id"],
        center_id: json["center_id"]
    );
  }
}

class BankCardWithToken{
  final int bank_card_id;
  final String number;
  final String phone_number;
  final String expiry_date;
  final String country_code;
  final String currency_code;
  final User user;
  final List<BankCardToken> bank_card_tokens;

  const BankCardWithToken({
    required this.bank_card_id,
    required this.number,
    required this.phone_number,
    required this.expiry_date,
    required this.country_code,
    required this.currency_code,
    required this.user,
    required this.bank_card_tokens
  });

  factory BankCardWithToken.convert(Map<String, dynamic> json) {
    return BankCardWithToken(
        bank_card_id: json["bank_card_id"],
        number: json["number"],
        phone_number: json["phone_number"],
        expiry_date: json["expiry_date"],
        country_code: json["country_code"],
        currency_code: json["currency_code"],
        user: User.convert(json["user"]),
        bank_card_tokens: List.generate(json["bank_card_tokens"].length, (int index) => BankCardToken.convert(json["bank_card_tokens"][index]))
    );
  }
}

class Transaction{
  final int transaction_id;
  final String processor_transaction_id;
  final String processor_name;
  final double amount;
  final int created_timestamp;
  final int? paid_timestamp;
  final int? canceled_timestamp;
  final int status;
  final String? processor_state;
  final String icafe_member_account;
  final String?  icafe_bill;
  final BankCard? bank_card;
  final CenterLite? center;

  const Transaction({
    required this.transaction_id,
    required this.processor_transaction_id,
    required this.processor_name,
    required this.amount,
    required this.created_timestamp,
    required this.paid_timestamp,
    required this.canceled_timestamp,
    required this.status,
    required this.processor_state,
    required this.icafe_member_account,
    required this.icafe_bill,
    required this.bank_card,
    required this.center
  });

  factory Transaction.convert(Map<String, dynamic> json) {
    return Transaction(
        transaction_id: json["transaction_id"],
        processor_transaction_id: json["processor_transaction_id"],
        processor_name: json["processor_name"],
        amount: json["amount"],
        created_timestamp: json["created_timestamp"],
        paid_timestamp: json["paid_timestamp"],
        canceled_timestamp: json["canceled_timestamp"],
        status: json["status"],
        processor_state: json["processor_state"],
        icafe_member_account: json["icafe_member_account"],
        icafe_bill: json["icafe_bill"],
        bank_card: BankCard.convert(json["bank_card"]),
        center: CenterLite.convert(json["center"])
    );
  }
}

class Booking{
  final int booking_id;
  final String pc_name;
  final String date;
  final int timestamp;
  final String time;
  final int minutes;
  final String member;
  final String? comment;
  final CenterLite center;
  final User user;

  const Booking({
    required this.booking_id,
    required this.pc_name,
    required this.date,
    required this.timestamp,
    required this.time,
    required this.minutes,
    required this.member,
    required this.comment,
    required this.center,
    required this.user
  });

  factory Booking.convert(Map<String, dynamic> json) {
    return Booking(
        booking_id: json["booking_id"],
        pc_name: json["pc_name"],
        date: json["date"],
        timestamp: json["timestamp"],
        time: json["time"],
        minutes: json["minutes"],
        member: json["member"],
        comment: json["comment"],
        center: CenterLite.convert(json["center"]),
        user: User.convert(json["user"])
    );
  }
}