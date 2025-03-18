import datetime
# import telegram

from sqlalchemy import Column, Integer, BigInteger, Float, String, Boolean, DateTime, Date, ForeignKey
from sqlalchemy.orm import declarative_base, relationship
# from sqlalchemy.event import listen

Base = declarative_base()

# def event_hook(mapper, connect, target):
# 	target.notify()

class Country(Base):
	__tablename__ = "countries"

	country_id = Column(Integer, primary_key = True)
	name = Column(String, nullable = False)
	is_visible = Column(Boolean, nullable = False, default = True)

	def __repr__(self):
		return self.name

class User(Base):
	__tablename__ = "users"

	user_id = Column(Integer, primary_key = True)
	name = Column(String, nullable = False)
	email = Column(String, nullable = False)
	password = Column(String, nullable = False)
	created_at = Column(BigInteger, nullable = True)

	language = Column(String, nullable = False, default = "EN", server_default = "EN")
	dark_theme = Column(Boolean, nullable = False, default = True, server_default = '1')

	confirmed = Column(Boolean, nullable = False, default = False)
	confirmation_code = Column(String, nullable = True)

	is_active = Column(Boolean, nullable = False, default = True)
	is_admin = Column(Boolean, nullable = False, default = False)
	is_root = Column(Boolean, nullable = False, default = False)

	country_id = Column(Integer, ForeignKey("countries.country_id"), nullable = False)
	country = relationship("Country", backref = "users")

	def __repr__(self):
		return self.email

class Member(Base):
	__tablename__ = "members"

	member_id = Column(Integer, primary_key = True)
	icafe_member_id = Column(BigInteger, nullable = False)
	account = Column(String, nullable = False)
	linked_at = Column(BigInteger, nullable = False)

	cash_balance = Column(String, nullable = False, server_default = '0')
	points_balance = Column(String, nullable = False, server_default = '0')
	coins_balance = Column(String, nullable = False, server_default = '0')
	bonus_balance = Column(String, nullable = False, server_default = '0')

	user_id = Column(Integer, ForeignKey("users.user_id"), nullable = False)
	center_id = Column(Integer, ForeignKey("centers.center_id"), nullable = False)

	user = relationship("User", backref = "members")
	center = relationship("Center", backref = "members")

	def __repr__(self):
		return self.account

class UserToken(Base):
	__tablename__ = "user_tokens"

	user_token_id = Column(Integer, primary_key = True)
	token = Column(String, nullable = False)
	is_active = Column(Boolean, nullable = False, default = True)

	user_id = Column(Integer, ForeignKey("users.user_id"), nullable = False)
	user = relationship("User", backref = "tokens")

	def __repr__(self):
		return self.token

class Center(Base):
	__tablename__ = "centers"

	center_id = Column(Integer, primary_key = True)
	name = Column(String, nullable = False)
	display_name = Column(String, nullable = False)

	description = Column(String, nullable = True)
	phone_number = Column(String, nullable = True)
	address = Column(String, nullable = True)

	cafe_id = Column(Integer, nullable = True)
	api_token = Column(String, nullable = True)
	license_number = Column(String, nullable = False)
	computer_count = Column(Integer, nullable = False)

	owner_id = Column(Integer, ForeignKey("users.user_id"), nullable = False)
	owner = relationship("User", backref = "centers")

	is_active = Column(Boolean, nullable = False, default = True)
	allow_topup = Column(Boolean, nullable = False, default = False)
	allow_booking = Column(Boolean, nullable = False, default = True)

	payme_cashbox_id = Column(String, nullable = True)
	payme_cashbox_key = Column(String, nullable = True)

	yookassa_shop_id = Column(String, nullable = True)
	yookassa_api_key = Column(String, nullable = True)

	kaspi_bin = Column(String, nullable = True)

	allow_topup_uz = Column(Boolean, nullable = False, default = False, server_default = '0')
	allow_topup_ru = Column(Boolean, nullable = False, default = False, server_default = '0')
	allow_topup_kz = Column(Boolean, nullable = False, default = False, server_default = '0')

	configured = Column(Boolean, nullable = False, default = False)
	join_date = Column(DateTime, nullable = False)

	is_subcenter = Column(Boolean, nullable = False, default = False)
	parent_center_id = Column(Integer, ForeignKey("centers.center_id"), nullable = True)
	parent_center = relationship("Center", remote_side = [center_id], backref = "subcenters")

	country_code = Column(String, nullable = False)

	country_id = Column(Integer, ForeignKey("countries.country_id"), nullable = False)
	country = relationship("Country", backref = "centers")

	def __repr__(self):
		return self.name

class ImageFile(Base):
	__tablename__ = "image_files"

	image_file_id = Column(Integer, primary_key = True)
	path = Column(String, nullable = False)

	center_id = Column(Integer, ForeignKey("centers.center_id"), nullable = False)
	center = relationship("Center", backref = "image_files")

	def __repr__(self):
		return self.path

class Booking(Base):
	__tablename__ = "bookings"

	booking_id = Column(Integer, primary_key = True)
	pc_name = Column(String, nullable = False)
	date = Column(String, nullable = False)
	timestamp = Column(BigInteger, nullable = False)
	time = Column(String, nullable = False)
	minutes = Column(Integer, nullable = False)
	member = Column(String, nullable = False)
	comment = Column(String, nullable = True)

	center_id = Column(Integer, ForeignKey("centers.center_id"), nullable = False)
	center = relationship("Center", backref = "bookings")

	user_id = Column(Integer, ForeignKey("users.user_id"), nullable = False)
	user = relationship("User", backref = "bookings")

	def __repr__(self):
		return self.pc_name

class Product(Base):
	__tablename__ = "products"

	product_id = Column(Integer, primary_key = True)
	icafe_product_id = Column(Integer, nullable = False)
	name = Column(String, nullable = False)
	display_name = Column(String, nullable = False)

	price = Column(String, nullable = False)
	is_visible = Column(Boolean, nullable = False, default = True)

	center_id = Column(Integer, ForeignKey("centers.center_id"))
	center = relationship("Center", backref = "products")

	def __repr__(self):
		return self.name

class Zone(Base):
	__tablename__ = "zones"

	zone_id = Column(Integer, primary_key = True)
	name = Column(String, nullable = False)
	description = Column(String, nullable = True)
	specifications = Column(String, nullable = False)
	computer_count = Column(Integer, nullable = True)

	center_id = Column(Integer, ForeignKey("centers.center_id"), nullable = False)
	center = relationship("Center", backref = "zones")

	def __repr__(self):
		return self.name

class BankCard(Base):
	__tablename__ = "bank_cards"

	bank_card_id = Column(Integer, primary_key = True)
	number = Column(String, nullable = False)
	expiry_date = Column(String, nullable = False)
	cvv = Column(String, nullable = True)
	holder = Column(String, nullable = False)
	phone_number = Column(String, nullable = False)
	country_code = Column(String, nullable = False)
	currency_code = Column(String, nullable = False)

	user_id = Column(Integer, ForeignKey("users.user_id"), nullable = False)
	user = relationship("User", backref = "bank_cards")

	def __repr__(self):
		return self.number

class BankCardToken(Base):
	__tablename__ = "bank_card_tokens"

	bank_card_token_id = Column(Integer, primary_key = True)
	processor_name = Column(String, nullable = False)

	verified = Column(Boolean, nullable = False, default = False)
	token = Column(String, nullable = False)

	bank_card_id = Column(Integer, ForeignKey("bank_cards.bank_card_id"), nullable = False)
	center_id = Column(Integer, ForeignKey("centers.center_id"), nullable = False)

	bank_card = relationship("BankCard", backref = "bank_card_tokens")
	center = relationship("Center", backref = "bank_card_tokens")

	def __repr__(self):
		return self.token

class Transaction(Base):
	__tablename__ = "transactions"

	transaction_id = Column(Integer, primary_key = True)
	processor_transaction_id = Column(String, nullable = True)
	processor_name = Column(String, nullable = False)

	amount = Column(Float, nullable = False)

	created_date = Column(DateTime, nullable = False)
	created_timestamp = Column(BigInteger, nullable = False)
	paid_timestamp = Column(BigInteger, nullable = True)
	canceled_timestamp = Column(BigInteger, nullable = True)

	status = Column(Integer, nullable = False)
	processor_state = Column(String, nullable = True)

	icafe_member_account = Column(String, nullable = False)
	icafe_member_id = Column(String, nullable = True)
	icafe_bill = Column(String, nullable = True)

	member_id = Column(Integer, ForeignKey("members.member_id"), nullable = True)
	bank_card_id = Column(Integer, ForeignKey("bank_cards.bank_card_id"), nullable = True)
	center_id = Column(Integer, ForeignKey("centers.center_id"), nullable = True)

	member = relationship("Member", backref = "transactions")
	bank_card = relationship("BankCard", backref = "transactions")
	center = relationship("Center", backref = "transactions")

	def __repr__(self):
		return str(self.processor_transaction_id)


class Event(Base):
	__tablename__ = "events"

	event_id = Column(Integer, primary_key = True)
	action = Column(String, nullable = False)
	alert = Column(Boolean, nullable = False, default = False)
	date = Column(DateTime, nullable = False)

	def notify(self):
		if self.alert:
			telegram.notify(self.action)

	def __repr__(self):
		return self.action

# listen(Event, "before_insert", event_hook)