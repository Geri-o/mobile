from pydantic import BaseModel
from datetime import datetime

class Country(BaseModel):
	country_id: int
	name: str
	is_visible: bool

	class Config:
		from_attributes = True

class User(BaseModel):
	user_id: int
	name: str
	email: str
	created_at: int
	language: str
	dark_theme: bool
	confirmed: bool
	is_active: bool
	is_admin: bool
	is_root: bool
	country: Country

	class Config:
		from_attributes = True

class UserToken(BaseModel):
	user_token_id: int
	token: str
	is_active: bool
	user: User

	class Config:
		from_attributes = True

class Product(BaseModel):
	product_id: int
	icafe_product_id: int
	name: str
	display_name: str
	price: str
	is_visible: bool

	class Config:
		from_attributes = True

class Zone(BaseModel):
	zone_id: int
	name: str
	description: str | None = None
	specifications: str
	computer_count: int | None = None

	class Config:
		from_attributes = True

class BankCard(BaseModel):
	bank_card_id: int
	number: str
	expiry_date: str
	holder: str
	phone_number: str
	country_code: str
	currency_code: str
	user: User

	class Config:
		from_attributes = True

class BankCardToken(BaseModel):
	bank_card_token_id: int
	processor_name: str
	verified: bool
	token: str

	bank_card_id: int
	center_id: int

	class Config:
		from_attributes = True

class BankCardWithToken(BaseModel):
	bank_card_id: int
	number: str
	expiry_date: str
	holder: str
	phone_number: str
	country_code: str
	currency_code: str

	user: User
	bank_card_tokens: list[BankCardToken]

	class Config:
		from_attributes = True

class ImageFile(BaseModel):
	image_file_id: int
	path: str

	class Config:
		from_attributes = True

class Subcenter(BaseModel):
	center_id: int
	name: str
	display_name: str
	description: str | None = None
	cafe_id: int
	api_token: str | None = None
	license_number: str
	is_active: bool
	allow_topup: bool
	allow_booking: bool
	configured: bool
	is_subcenter: bool
	image_files: list[ImageFile]
	owner: User
	country: Country

	class Config:
		from_attributes = True

class Center(BaseModel):
	center_id: int
	name: str
	display_name: str

	description: str | None = None
	phone_number: str | None = None
	address: str | None = None

	cafe_id: int
	api_token: str | None = None
	license_number: str
	computer_count: int

	is_active: bool
	allow_topup: bool
	allow_booking: bool

	payme_cashbox_id: str | None = None
	payme_cashbox_key: str | None = None

	yookassa_shop_id: str | None = None
	yookassa_api_key: str | None = None

	kaspi_bin: str | None = None

	allow_topup_uz: bool
	allow_topup_ru: bool
	allow_topup_kz: bool

	configured: bool
	is_subcenter: bool
	owner: User

	image_files: list[ImageFile]
	zones: list[Zone]
	products: list[Product]
	subcenters: list[Subcenter]
	country: Country

	class Config:
		from_attributes = True

class CenterLite(BaseModel):
	center_id: int
	name: str
	display_name: str
	description: str | None = None
	phone_number: str | None = None
	address: str | None = None
	cafe_id: int
	computer_count: int
	is_active: bool
	allow_topup: bool
	allow_booking: bool
	configured: bool
	is_subcenter: bool

	class Config:
		from_attributes = True

class Booking(BaseModel):
	booking_id: int
	pc_name: str
	date: str
	timestamp: int
	time: str
	minutes: int
	member: str
	comment: str | None = None
	center: CenterLite
	user: User

	class Config:
		from_attributes = True

class Transaction(BaseModel):
	transaction_id: int
	processor_transaction_id: str
	processor_name: str
	amount: float
	created_date: datetime
	created_timestamp: int
	paid_timestamp: int | None = None
	cancel_timestamp: int | None = None
	status: int
	processor_state: str | None = None
	icafe_member_account: str
	icafe_bill: str | None = None

	bank_card: BankCard | None = None
	center: CenterLite | None = None

	class Config:
		from_attributes = True

class Member(BaseModel):
	member_id: int
	icafe_member_id: int
	account: str
	linked_at: int
	cash_balance: str
	points_balance: str
	coins_balance: str
	bonus_balance: str
	user: User
	center: CenterLite

	class Config:
		from_attributes = True


class Event(BaseModel):
	event_id: int
	date: datetime
	action: str