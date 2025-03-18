import uuid
import time
import hashlib
import logging
import datetime

from fastapi import FastAPI, HTTPException, Request

import models, tables, icafe, datapath, transactions

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

gateway = FastAPI()
sessionbuilder = sessionmaker(bind = create_engine("postgresql://dev:ronin_dev@localhost:5432/icafeplay"))
# sessionbuilder = sessionmaker(bind = create_engine("postgresql://fedora:fedora@localhost:5432/icafeplay"))
transmitter = icafe.ICafe()
filesystem = datapath.DataPath()
logger = logging.getLogger("gateway")

# =================================== COUNTRIES =================================== #

@gateway.get("/country/all", response_model = list[models.Country])
async def country_get_all(request: Request):
	with sessionbuilder() as session:
		countries = session.query(tables.Country).all()
		for country in countries:
			models.Country.from_orm(country)

		return countries

# =================================== COUNTRIES =================================== #

# =================================== CENTERS =================================== #

@gateway.post("/center", response_model = models.Center)
async def center_create(request: Request):
	with sessionbuilder() as session:
		payload = await request.json()
		owner = session.get(tables.User, payload["owner"]["user_id"])
		if owner is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: OWNER NOT FOUND")

		center = tables.Center(
			name = payload["center"]["name"],
			display_name = payload["center"]["display_name"],
			cafe_id = payload["center"]["cafe_id"],
			api_token = payload["center"]["token"],
			license_number = payload["center"]["license_number"],
			computer_count = payload["center"]["computer_count"],
			country_code = payload["center"]["country"],
			is_active = payload["center"]["is_active"],
			allow_topup = payload["center"]["allow_topup"],
			allow_booking = payload["center"]["allow_booking"],
			configured = True,
			join_date = datetime.datetime.now(),
			is_subcenter = False,
			owner_id = owner.user_id,
			country_id = owner.country.country_id
		)
		session.add(center)
		session.flush()

		for product in payload["center"]["products"]:
			offer = tables.Product(
				icafe_product_id = product["icafe_product_id"],
				name = product["name"],
				display_name = product["display_name"],
				price = product["price"],
				is_visible = product["is_visible"],
				center_id = center.center_id
			)
			session.add(offer)

		for subcenter in payload["center"]["subcenters"]:
			subcafe = tables.Center(
				name = subcenter["name"],
				display_name = subcenter["name"],
				cafe_id = subcenter["cafe_id"],
				license_number = subcenter["license_number"],
				computer_count = subcenter["computer_count"],
				country_code = subcenter["country"],
				is_active = False,
				allow_topup = False,
				allow_booking = False,
				configured = False,
				join_date = datetime.datetime.now(),
				is_subcenter = True,
				parent_center_id = center.center_id,
				owner_id = owner.user_id,
				country_id = owner.country.country_id
			)
			session.add(subcafe)

		event = tables.Event(action = "Center created: {}. Owner: {}".format(center.name, owner.name), date = datetime.datetime.now())
		session.add(event)

		session.commit()
		session.refresh(center)
		models.Center.from_orm(center)
		return center

@gateway.put("/center/configure/", response_model = models.Center)
async def center_configure(request: Request, center_id: int):
	with sessionbuilder() as session:
		payload = await request.json()
		center = session.get(tables.Center, center_id)
		if center is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: CENTER NOT FOUND")

		center.api_token = payload["center"]["api_token"]
		center.configured = payload["center"]["configured"]
		center.display_name = payload["center"]["display_name"]
		center.description = payload["center"]["description"]
		center.is_active = payload["center"]["is_active"]
		center.allow_topup = payload["center"]["allow_topup"]
		center.allow_booking = payload["center"]["allow_booking"]

		for product in payload["center"]["products"]:
			offer = tables.Product(
				icafe_product_id = product["icafe_product_id"],
				name = product["name"],
				display_name = product["display_name"],
				price = product["price"],
				is_visible = product["is_visible"],
				center_id = center.center_id
			)
			session.add(offer)

		event = tables.Event(action = "Center configured: {}. Owner: {}".format(center.name, center.owner.name), date = datetime.datetime.now())
		session.add(event)

		session.commit()
		session.refresh(center)
		models.Center.from_orm(center)
		return center

@gateway.get("/center/", response_model = models.Center)
async def center_get(center_id: int):
	with sessionbuilder() as session:
		center = session.get(tables.Center, center_id)
		if center is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: CENTER NOT FOUND")

		models.Center.from_orm(center)
		return center


@gateway.put("/center/", response_model = models.Center)
async def center_edit(request: Request, center_id: int):
	with sessionbuilder() as session:
		payload = await request.json()
		center = session.get(tables.Center, center_id)
		if center is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: CENTER NOT FOUND")

		center.api_token = payload["center"]["api_token"]

		center.display_name = payload["center"]["display_name"]
		center.description = payload["center"]["description"]
		center.phone_number = payload["center"]["phone_number"]
		center.address = payload["center"]["address"]
		center.is_active = payload["center"]["is_active"]
		center.allow_topup = payload["center"]["allow_topup"]
		center.allow_booking = payload["center"]["allow_booking"]

		for zone in center.zones:
			session.delete(zone)

		for zone in payload["center"]["zones"]:
			zone = tables.Zone(
				name = zone["name"],
				description = zone["description"],
				specifications = zone["specifications"],
				computer_count = zone["computer_count"],
				center_id = center.center_id
			)
			session.add(zone)

		for image in payload["center"]["images"]:
			image = tables.ImageFile(
				path = filesystem.create_file(image),
				center_id = center.center_id
			)
			session.add(image)

		for product in payload["center"]["products"]:
			offer = session.get(tables.Product, product["product_id"])
			if offer is None:
				continue

			offer.display_name = product["display_name"]
			offer.is_visible = product["is_visible"]

		event = tables.Event(action = "Center edited: {}. Owner: {}".format(center.name, center.owner.name), date = datetime.datetime.now())
		session.add(event)

		session.commit()
		models.Center.from_orm(center)
		return center

@gateway.put("/center/payway/", response_model = models.Center)
async def center_edit_payway(request: Request, center_id: int):
	with sessionbuilder() as session:
		payload = await request.json()
		center = session.get(tables.Center, center_id)
		if center is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: CENTER NOT FOUND")

		center.payme_cashbox_id = payload["center"]["payme_cashbox_id"]
		center.payme_cashbox_key = payload["center"]["payme_cashbox_key"]
		center.allow_topup_uz = False

		center.yookassa_shop_id = payload["center"]["yookassa_shop_id"]
		center.yookassa_api_key = payload["center"]["yookassa_api_key"]
		center.allow_topup_ru = False

		center.kaspi_bin = payload["center"]["kaspi_bin"]
		center.allow_topup_kz = False

		if center.payme_cashbox_id is not None or center.payme_cashbox_key is not None:
			center.allow_topup_uz = True

		if center.yookassa_shop_id is not None or center.yookassa_api_key is not None:
			center.allow_topup_ru = True

		if center.kaspi_bin is not None:
			center.allow_topup_kz = True

		if center.allow_topup_uz == False and center.allow_topup_ru == False and center.allow_topup_kz == False:
			center.allow_topup = False

		event = tables.Event(action = "Center edited: {}. Owner: {}".format(center.name, center.owner.name), date = datetime.datetime.now())
		session.add(event)

		session.commit()
		models.Center.from_orm(center)
		return center

@gateway.delete("/center/", response_model = bool)
async def center_delete(request: Request, center_id: int):
	with sessionbuilder() as session:
		raise HTTPException(status_code = 409, detail = "!ERROR: NOT ALLOWED")
		center = session.get(tables.Center, center_id)
		if center is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: CENTER NOT FOUND")

		event = tables.Event(action = "Center deleted: {}. Owner: {}".format(center.name, owner.name), date = datetime.datetime.now())
		session.add(event)
		return True

@gateway.get("/center/all", response_model = list[models.Center])
async def center_get_all(request: Request):
	with sessionbuilder() as session:
		centers = session.query(tables.Center).filter_by(is_active = True).all()
		for center in centers:
			models.Center.from_orm(center)

		return centers

@gateway.get("/center/owner/primary/", response_model = models.Center)
async def center_get_primary_by_owner(request: Request, owner_id: int):
	with sessionbuilder() as session:
		center = session.query(tables.Center).filter_by(owner_id = owner_id).filter_by(is_subcenter = False).first()
		if center is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: CENTER NOT FOUND")

		models.Center.from_orm(center)
		return center

@gateway.get("/center/owner/", response_model = list[models.Center])
async def center_get_by_owner(request: Request, owner_id: int):
	with sessionbuilder() as session:
		centers = session.query(tables.Center).filter_by(owner_id = owner_id).all()
		for center in centers:
			models.Center.from_orm(center)

		return centers

@gateway.post("/center/demand", response_model = dict)
async def center_demand(request: Request):
	payload = await request.json()
	try:
		return transmitter.demand_center(cafe_id = payload["cafe_id"], token = payload["token"])
	except Exception as error:
		raise HTTPException(status_code = 503, detail = str(error))

@gateway.post("/center/subcenter/demand", response_model = dict)
async def center_subcenter_demand(request: Request):
	payload = await request.json()
	try:
		return transmitter.demand_subcenters(cafe_id = payload["cafe_id"], token = payload["token"])
	except Exception as error:
		raise HTTPException(status_code = 503, detail = str(error))

# =================================== CENTERS =================================== #

# =================================== COMPUTERS =================================== #

@gateway.post("/computer/demand", response_model = dict)
async def computer_demand(request: Request):
	payload = await request.json()
	return transmitter.demand_computers(cafe_id = payload["cafe_id"], token = payload["token"])

@gateway.get("/mobile/computer/demand/", response_model = dict)
async def mobile_computer_demand(center_id: int):
	with sessionbuilder() as session:
		center = session.get(tables.Center, center_id)
		if center is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: CENTER NOT FOUND")
		return transmitter.demand_computers(cafe_id = center.cafe_id, token = center.api_token)

# =================================== COMPUTERS =================================== #

# =================================== IMAGE FILES =================================== #

@gateway.delete("/image-file/", response_model = bool)
async def image_file_delete(image_file_id: int):
	with sessionbuilder() as session:
		image_file = session.get(tables.ImageFile, image_file_id)
		if image_file is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: IMAGE NOT FOUND")

		filesystem.remove_file(image_file.path)
		session.delete(image_file)
		session.commit()
		return True

# =================================== IMAGE FILES =================================== #

# =================================== PRODUCTS =================================== #

@gateway.post("/product/demand", response_model = dict)
async def product_demand(request: Request):
	payload = await request.json()
	return transmitter.demand_products(cafe_id = payload["cafe_id"], token = payload["token"])

# =================================== PRODUCTS =================================== #

# =================================== BOOKINGS =================================== #

@gateway.post("/booking", response_model = bool)
async def booking_create(request: Request):
	with sessionbuilder() as session:
		payload = await request.json()
		center = session.get(tables.Center, payload["center_id"])
		if center is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: CENTER NOT FOUND")

		member = session.get(tables.Member, payload["member_id"])
		if member is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: MEMBER NOT FOUND")

		try:
			result = transmitter.place_booking(
				pc_name = payload["computer"],
				date = payload["date"],
				time = payload["time"],
				minutes = payload["minutes"],
				member = member.account,
				comment = "Received from iCafePlay",
				cafe_id = center.cafe_id,
				token = center.api_token
			)

			booking = tables.Booking(
				pc_name = payload["computer"],
				timestamp = datetime.datetime.timestamp(datetime.datetime.strptime("{} {}".format(payload["date"], payload["time"]), "%Y-%m-%d %H:%M")),
				date = payload["date"],
				time = payload["time"],
				minutes = int(payload["minutes"]),
				member = member.account,
				comment = "Received from iCafePlay",
				center_id = center.center_id,
				user_id = member.user.user_id
			)
			session.add(booking)
			session.commit()
		except Exception as error:
			raise HTTPException(status_code = 503, detail = str(error))

		return True

@gateway.post("/booking/demand", response_model = dict)
async def booking_demand(request: Request):
	payload = await request.json()
	return transmitter.demand_bookings(cafe_id = payload["cafe_id"], token = payload["api_token"])

@gateway.get("/mobile/booking/demand/", response_model = dict)
async def mobile_booking_demand(center_id: int):
	with sessionbuilder() as session:
		center = session.get(tables.Center, center_id)
		if center is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: CENTER NOT FOUND")
		return transmitter.demand_bookings(cafe_id = center.cafe_id, token = center.api_token)

@gateway.get("/mobile/booking/user/", response_model = list[models.Booking])
async def mobile_user_bookings(user_id: int):
	with sessionbuilder() as session:
		today = datetime.datetime.now()
		today = today.replace(minute = 0, hour = 0, second = 0)
		today = datetime.datetime.timestamp(today)
		bookings = session.query(tables.Booking).order_by(tables.Booking.booking_id.desc()).filter(tables.Booking.timestamp > today).all()
		for booking in bookings:
			models.Booking.from_orm(booking)

		return bookings

@gateway.get("/mobile/booking/active/", response_model = models.Booking | None)
async def mobile_active_booking(user_id: int):
	with sessionbuilder() as session:
		today = datetime.datetime.now()
		today = datetime.datetime.timestamp(today)
		booking = session.query(tables.Booking).filter(tables.Booking.timestamp > today).first()
		if booking is None:
			return booking
		models.Booking.from_orm(booking)
		return booking

@gateway.delete("/booking", response_model = dict)
async def booking_delete(request: Request):
	with sessionbuilder() as session:
		payload = await request.json()
		center = session.get(tables.Center, payload["center_id"])
		return transmitter.delete_booking(pc_name = payload["pc_name"], offer_id = payload["offer_id"], cafe_id = center.cafe_id, token = center.api_token)

# =================================== BOOKINGS =================================== #

# =================================== REPORTS =================================== #

@gateway.get("/report/data/", response_model = dict)
async def report_data_get(center_id: int, start_date: str, end_date: str):
	with sessionbuilder() as session:
		center = session.get(tables.Center, center_id)
		if center is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: CENTER NOT FOUND")
		return transmitter.demand_report_data(start = start_date, end = end_date, cafe_id = center.cafe_id, token = center.api_token)

# =================================== REPORTS =================================== #

# =================================== BANK CARDS =================================== #

@gateway.post("/bank-card", response_model = bool)
async def bank_card_create(request: Request):
	with sessionbuilder() as session:
		payload = await request.json()
		bank_card = session.query(tables.BankCard).filter_by(number = payload["number"]).first()
		if bank_card is not None:
			raise HTTPException(status_code = 409, detail = "!ERROR: BANK CARD ALREADY EXISTS")

		center = session.get(tables.Center, payload["center_id"])
		if center is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: CENTER NOT FOUND")

		bank_card = tables.BankCard(
			number = payload["number"].replace(' ', ''),
			expiry_date = payload["expiry_date"],
			cvv = payload["cvv"],
			holder = payload["holder"],
			phone_number = payload["phone_number"],
			country_code = payload["country_code"],
			currency_code = payload["currency_code"],
			user_id = payload["user_id"]
		)
		session.add(bank_card)
		session.flush()

		bank_card_token = tables.BankCardToken(
			processor_name = payload["processor_name"],
			token = '-',
			bank_card_id = bank_card.bank_card_id,
			center_id = payload["center_id"]
		)
		session.add(bank_card_token)

		if bank_card.country_code == "UZ":
			try:
				headers = transactions.PaycomSubscribeAPI.authorize(center.payme_cashbox_id, center.payme_cashbox_key, 1)
				result = transactions.PaycomSubscribeAPI.cards_create(headers, bank_card.bank_card_id, bank_card.number, bank_card.expiry_date)
				bank_card_token.token = result["result"]["card"]["token"]
				result = transactions.PaycomSubscribeAPI.cards_get_verify_code(headers, bank_card.bank_card_id, bank_card_token.token)
			except Exception as error:
				raise HTTPException(status_code = 424, detail = "!ERROR: PROCESSOR RETURNED ERROR, PLEASE CHECK CARD DETAILS")

		event = tables.Event(action = "BankCard created: {} ({}). User: {}".format(bank_card.number, bank_card.country_code, bank_card.user_id), date = datetime.datetime.now())
		session.add(event)
		session.commit()
		return True

@gateway.post("/bank-card/link", response_model = bool)
async def bank_card_link(request: Request):
	with sessionbuilder() as session:
		payload = await request.json()
		bank_card = session.get(tables.BankCard, payload["bank_card_id"])
		if bank_card is None:
			raise HTTPException(status_code = 409, detail = "!ERROR: BANK CARD NOT FOUND")

		center = session.get(tables.Center, payload["center_id"])
		if center is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: CENTER NOT FOUND")

		bank_card_token = tables.BankCardToken(
			processor_name = payload["processor_name"],
			token = '-',
			bank_card_id = bank_card.bank_card_id,
			center_id = center.center_id
		)
		session.add(bank_card_token)

		if bank_card.country_code == "UZ":
			try:
				headers = transactions.PaycomSubscribeAPI.authorize(center.payme_cashbox_id, center.payme_cashbox_key, 1)
				result = transactions.PaycomSubscribeAPI.cards_create(headers, bank_card.bank_card_id, bank_card.number, bank_card.expiry_date)
				bank_card_token.token = result["result"]["card"]["token"]
				result = transactions.PaycomSubscribeAPI.cards_get_verify_code(headers, bank_card.bank_card_id, bank_card_token.token)
			except Exception as error:
				raise HTTPException(status_code = 424, detail = "!ERROR: PROCESSOR RETURNED ERROR, PLEASE CHECK CARD DETAILS")

		event = tables.Event(action = "BankCard created: {}. User: {}".format(bank_card.number, bank_card.user_id), date = datetime.datetime.now())
		session.add(event)
		session.commit()
		return True

@gateway.post("/bank-card/resend", response_model = bool)
async def bank_card_resend_code(request: Request):
	with sessionbuilder() as session:
		payload = await request.json()
		bank_card = session.query(tables.BankCard).filter_by(number = payload["number"]).first()
		if bank_card is None:
			raise HTTPException(status_code = 409, detail = "!ERROR: BANK CARD NOT FOUND")

		bank_card_token = session.query(tables.BankCardToken).filter_by(bank_card_id = bank_card.bank_card_id)
		bank_card_token = bank_card_token.filter_by(center_id = payload["center_id"])
		bank_card_token = bank_card_token.filter_by(processor_name = payload["processor_name"]).first()

		try:
			headers = transactions.PaycomSubscribeAPI.authorize(bank_card_token.center.payme_cashbox_id, bank_card_token.center.payme_cashbox_key, 1)
			token = transactions.PaycomSubscribeAPI.cards_get_verify_code(headers, bank_card.bank_card_id, bank_card_token.token)
		except Exception as error:
			raise HTTPException(status_code = 424, detail = "!ERROR: PROCESSOR RETURNED ERROR, PLEASE CHECK CARD DETAILS")

		return True

@gateway.post("/bank-card/verify", response_model = bool)
async def bank_card_verify(request: Request):
	with sessionbuilder() as session:
		payload = await request.json()
		bank_card = session.query(tables.BankCard).filter_by(number = payload["number"]).first()
		if bank_card is None:
			raise HTTPException(status_code = 409, detail = "!ERROR: BANK CARD NOT FOUND")

		bank_card_token = session.query(tables.BankCardToken).filter_by(bank_card_id = bank_card.bank_card_id)
		bank_card_token = bank_card_token.filter_by(center_id = payload["center_id"])
		bank_card_token = bank_card_token.filter_by(processor_name = payload["processor_name"]).first()

		try:
			headers = transactions.PaycomSubscribeAPI.authorize(bank_card_token.center.payme_cashbox_id, bank_card_token.center.payme_cashbox_key, 1)
			token = transactions.PaycomSubscribeAPI.cards_verify(headers, bank_card.bank_card_id, bank_card_token.token, payload["code"])
			bank_card_token.verified = True
		except Exception as error:
			if "code" in str(error):
				raise HTTPException(status_code = 424, detail = "!ERROR: VERIFICATION CODE IS INCORRECT")
			else:
				raise HTTPException(status_code = 424, detail = "!ERROR: PROCESSOR RETURNED ERROR, PLEASE CHECK CARD DETAILS")

		session.commit()
		return True

@gateway.get("/bank-card/", response_model = models.BankCard)
async def bank_card_get(bank_card_id: int):
	with sessionbuilder() as session:
		bank_card = session.get(tables.BankCard, bank_card_id)
		if bank_card is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: BANK CARD NOT FOUND")

		models.BankCard.from_orm(bank_card)
		return bank_card

@gateway.put("/bank-card/", response_model = models.BankCard)
async def bank_card_edit(request: Request, bank_card: int):
	with sessionbuilder() as session:
		bank_card = session.get(tables.BankCard, bank_card)
		if bank_card is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: BANK CARD NOT FOUND")

		bank_card.country_code = payload["country_code"]
		bank_card.currency_code = payload["currency_code"]

		session.commit()
		session.refresh(bank_card)
		models.BankCard.from_orm(bank_card)
		return bank_card

@gateway.delete("/bank-card/", response_model = bool)
async def bank_card_delete(bank_card_id: int):
	with sessionbuilder() as session:
		bank_card = session.get(tables.BankCard, bank_card_id)
		if bank_card is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: BANK CARD NOT FOUND")

		# @TODO => DELETE RELATED TRANSACTIONS
		for bank_card_token in bank_card.bank_card_tokens:
			session.delete(bank_card_token)

		for transaction in bank_card.transactions:
			session.delete(transaction)

		session.delete(bank_card)
		session.commit()
		return True

@gateway.get("/bank-card/user/", response_model = models.BankCard)
async def bank_card_get_by_user(user_id: int):
	with sessionbuilder() as session:
		bank_card = session.query(tables.BankCard).filter_by(user_id = user_id).first()
		if bank_card is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: BANK CARD NOT FOUND")

		models.BankCard.from_orm(bank_card)
		return bank_card

@gateway.get("/bank-card/user/all/", response_model = list[models.BankCard])
async def bank_card_get_all_by_user(user_id: int):
	with sessionbuilder() as session:
		bank_cards = session.query(tables.BankCard).filter_by(user_id = user_id).all()
		for bank_card in bank_cards:
			models.BankCard.from_orm(bank_card)

		return bank_cards

@gateway.post("/bank-card/acquire", response_model = models.BankCardWithToken)
async def bank_card_acquire(request: Request):
	with sessionbuilder() as session:
		payload = await request.json()
		bank_card = session.query(tables.BankCard).filter_by(user_id = payload["user_id"]).filter_by(country_code = payload["country_code"]).first()
		if bank_card is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: BANK CARD NOT FOUND")

		models.BankCardWithToken.from_orm(bank_card)
		return bank_card

@gateway.post("/bank-card/bank-card-token/acquire", response_model = models.BankCardToken)
async def bank_card_token_acquire(request: Request):
	with sessionbuilder() as session:
		payload = await request.json()
		bank_card_token = session.query(tables.BankCardToken).filter_by(center_id = payload["center_id"]).filter_by(bank_card_id = payload["bank_card_id"])
		bank_card_token = bank_card_token.filter_by(processor_name = payload["processor_name"]).first()
		if bank_card_token is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: BANK CARD TOKEN NOT FOUND")

		models.BankCardToken.from_orm(bank_card_token)
		return bank_card_token

# =================================== BANK CARDS =================================== #

# =================================== TRANSACTIONS =================================== #

@gateway.post("/transaction", response_model = models.Transaction)
async def transaction_create(request: Request):
	with sessionbuilder() as session:
		pass

@gateway.post("/transaction/topup", response_model = dict)
async def transaction_create_topup(request: Request):
	with sessionbuilder() as session:
		payload = await request.json()
		bank_card = session.query(tables.BankCard).filter_by(number = payload["number"]).first()
		if bank_card is None:
			raise HTTPException(status_code = 409, detail = "!ERROR: BANK CARD NOT FOUND")

		bank_card_token = session.query(tables.BankCardToken).filter_by(bank_card_id = bank_card.bank_card_id)
		bank_card_token = bank_card_token.filter_by(center_id = payload["center_id"])
		bank_card_token = bank_card_token.filter_by(processor_name = payload["processor_name"]).first()

		center = session.get(tables.Center, bank_card_token.center_id)

		try:
			member = transmitter.search(payload["member"], center.cafe_id, center.api_token)

			confirmation_url = None

			transaction = tables.Transaction(
				processor_name = payload["processor_name"],
				amount = payload["amount"],

				created_date = datetime.datetime.now(),
				created_timestamp = time.time(),
				status = 1,
				icafe_member_account = payload["member"],
				icafe_member_id = member["member_id"],
				bank_card_id = bank_card.bank_card_id,
				center_id = center.center_id
			)

			if bank_card.country_code == "UZ":
				headers = transactions.PaycomSubscribeAPI.authorize(center.payme_cashbox_id, center.payme_cashbox_key, 2)
				receipt = transactions.PaycomSubscribeAPI.receipts_create(headers, bank_card.bank_card_id, int(payload["amount"]) * 100)
				receipt = transactions.PaycomSubscribeAPI.receipts_pay(headers, bank_card.bank_card_id, bank_card_token.token, receipt["result"]["receipt"]["_id"])
				transaction.processor_transaction_id = receipt["result"]["receipt"]["_id"]
				transaction.processor_state = receipt["result"]["receipt"]["state"]
				transaction.paid_timestamp = time.time()
				transaction.status = 3
				try:
					notification = transactions.PaycomSubscribeAPI.receipts_send(headers, bank_card.bank_card_id, bank_card, receipt["result"]["receipt"]["_id"], bank_card.phone_number)
				except Exception as error:
					logger.error(error)
					pass # Not that crucial
			elif bank_card.country_code == "RU":
				transactions.YooMoney.authorize(center.yookassa_shop_id, center.yookassa_api_key)
				receipt = transactions.YooMoney.create_payment(bank_card, payload["amount"])
				transaction.processor_transaction_id = receipt.id
				transaction.processor_state = receipt.status
				confirmation_url = receipt.confirmation.confirmation_url

			if transaction.status == 3:
				bill = transmitter.topup(member["member_id"], transaction.amount, center.cafe_id, center.api_token)
				transaction.icafe_bill = bill[0]

			session.add(transaction)
		except Exception as error:
			logger.error(error)
			raise HTTPException(status_code = 424, detail = "!ERROR: PROCESSOR RETURNED ERROR, PLEASE CHECK YOUR DETAILS")

		event = tables.Event(action = "Transaction created: {}. Member: {}".format(transaction.processor_name, transaction.member), date = datetime.datetime.now())
		session.add(event)
		session.commit()
		return {"status": 200, "confirmation_url": confirmation_url}

@gateway.get("/transaction/", response_model = models.Transaction)
async def transaction_get(transaction_id: int):
	with sessionbuilder() as session:
		transaction = session.get(tables.Transaction, transaction_id)
		if transaction is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: TRANSACTION NOT FOUND")

		models.Transaction.from_orm(transaction)
		return transaction

@gateway.put("/transaction", response_model = bool)
async def transaction_edit(transaction_id: int, request: Request):
	with sessionbuilder() as session:
		return False

@gateway.delete("/transaction", response_model = bool)
async def transaction_delete(transaction_id: int):
	with sessionbuilder() as session:
		transaction = session.get(tables.Transaction, transaction_id)
		if transaction is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: TRANSACTION NOT FOUND")

		session.delete(transaction)
		session.commit()
		return True

@gateway.get("/transaction/last", response_model = list[models.Transaction])
async def transaction_get_last_all():
	with sessionbuilder() as session:
		transactions = session.query(tables.Transaction).order_by(tables.Transaction.transaction_id.desc()).limit(100).all()
		for transaction in transactions:
			models.Transaction.from_orm(transaction)

		return transactions

@gateway.get("/transaction/bank-card/", response_model = list[models.Transaction])
async def transaction_get_by_bank_card(bank_card_id: int):
	with sessionbuilder() as session:
		transactions = session.query(tables.Transaction).filter_by(bank_card_id = bank_card_id).order_by(tables.Transaction.transaction_id.desc()).limit(50).all()
		for transaction in transactions:
			models.Transaction.from_orm(transaction)

		return transactions

@gateway.get("/transaction/center/", response_model = list[models.Transaction])
async def transaction_get_by_center(center_id: int):
	with sessionbuilder() as session:
		transactions = session.query(tables.Transaction).filter_by(center_id = center_id).order_by(tables.Transaction.transaction_id.desc()).limit(50).all()
		for transaction in transactions:
			models.Transaction.from_orm(transaction)

		return transactions

# =================================== TRANSACTIONS =================================== #