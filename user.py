import uuid
import time
import random
import hashlib
import datetime

from fastapi import FastAPI, HTTPException, Request

import models, tables, icafe

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

user = FastAPI()
sessionbuilder = sessionmaker(bind = create_engine("postgresql://dev:ronin_dev@localhost:5432/icafeplay"))
# sessionbuilder = sessionmaker(bind = create_engine("postgresql://fedora:fedora@localhost:5432/icafeplay"))
transmitter = icafe.ICafe()

# =================================== USERS =================================== #

@user.post('/', response_model = models.User)
async def user_create(request: Request):
	with sessionbuilder() as session:
		payload = await request.json()
		account = session.query(tables.User).filter_by(email = payload["owner"]["email"]).first()
		if account is not None:
			raise HTTPException(status_code = 409, detail = "!ERROR: USER ALREADY EXISTS")

		account = tables.User(
			name = payload["owner"]["name"],
			email = payload["owner"]["email"],
			password = hashlib.sha256(hashlib.md5(payload["owner"]["password"].encode()).hexdigest().encode()).hexdigest(),
			confirmed = True,
			is_active = True,
			is_admin = payload["owner"]["is_admin"],
			is_root = payload["owner"]["is_root"],
			created_at = time.time(),
			country_id = payload["owner"]["country_id"]
		)
		session.add(account)

		session.commit()
		session.refresh(account)
		models.User.from_orm(account)
		return account

@user.put('/', response_model = models.User)
async def user_edit(request: Request, user_id: int):
	with sessionbuilder() as session:
		payload = await request.json()
		account = session.get(tables.User, user_id)
		if account is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: USER NOT FOUND")

		account.name = payload["name"]
		account.is_active = payload["is_active"]
		account.language = payload["language"]
		account.dark_theme = payload["dark_theme"]

		session.commit()
		session.refresh(account)
		models.User.from_orm(account)
		return account

@user.put("/password/", response_model = models.User)
async def user_edit_password(request: Request, user_id: int):
	with sessionbuilder() as session:
		payload = await request.json()
		account = session.get(tables.User, user_id)
		if account is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: USER NOT FOUND")

		if account.password == hashlib.sha256(hashlib.md5(payload["old"].encode()).hexdigest().encode()).hexdigest():
			account.password = hashlib.sha256(hashlib.md5(payload["new"].encode()).hexdigest().encode()).hexdigest()
		else:
			raise HTTPException(status_code = 401, detail = "!ERROR: OLD PASSWORD IS INCORRECT")

		session.commit()
		session.refresh(account)
		models.User.from_orm(account)
		return account

@user.delete('/', response_model = bool)
async def user_delete(user_id: int):
	with sessionbuilder() as session:
		account = session.get(tables.User, user_id)
		if account is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: USER NOT FOUND")

		# session.delete(account)
		session.commit()
		return True

@user.get('/', response_model = models.User)
async def user_get(user_id: int):
	with sessionbuilder() as session:
		account = session.get(tables.User, user_id)
		if account is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: USER NOT FOUND")

		models.User.from_orm(account)
		return account

@user.get("/all", response_model = list[models.User])
async def user_get_all():
	with sessionbuilder() as session:
		accounts = session.query(tables.User).all()
		for account in accounts:
			models.User.from_orm(account)
		return accounts

@user.get("/owner/all", response_model = list[models.User])
async def user_get_all_owners():
	with sessionbuilder() as session:
		accounts = session.query(tables.User).filter_by(is_admin = True).all()
		for account in accounts:
			models.User.from_orm(account)
		return accounts

@user.get("/token/", response_model = models.UserToken)
async def token_get(user_token_id: int):
	with sessionbuilder() as session:
		user_token = session.get(tables.UserToken, user_token_id)
		if user_token is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: USER TOKEN NOT FOUND")

		models.UserToken.from_orm(user_token)
		return user_token

@user.post("/authorize", response_model = models.User)
async def user_authorize(request: Request):
	with sessionbuilder() as session:
		payload = await request.json()
		account = session.query(tables.User).filter_by(email = payload["email"]).first()
		if account is not None and account.password == hashlib.sha256(hashlib.md5(payload["password"].encode()).hexdigest().encode()).hexdigest():
			models.User.from_orm(account)
			return account
		raise HTTPException(status_code = 404, detail = "!ERROR: WRONG PASSWORD OR USERNAME")

@user.post("/mobile/register", response_model = models.UserToken)
async def user_mobile_register(request: Request):
	with sessionbuilder() as session:
		payload = await request.json()
		account = session.query(tables.User).filter_by(email = payload["email"]).first()
		if account is not None:
			raise HTTPException(status_code = 409, detail = "!ERROR: USER ALREADY EXISTS")

		account = tables.User(
			name = payload["name"],
			email = payload["email"],
			created_at = time.time(),
			is_admin = False,
			confirmed = False,
			confirmation_code = random.randint(1000, 9999),
			password = hashlib.sha256(hashlib.md5(payload["password"].encode()).hexdigest().encode()).hexdigest(),
			country_id = payload["country"]
		)
		session.add(account)
		session.flush()

		token = tables.UserToken(
			token = uuid.uuid4().hex,
			is_active = True,
			user_id = account.user_id
		)
		session.add(token)
		session.flush()

		session.commit()
		session.refresh(token)
		models.UserToken.from_orm(token)
		return token

@user.post("/mobile/authenticate", response_model = models.UserToken)
async def user_mobile_authenticate(request: Request):
	with sessionbuilder() as session:
		payload = await request.json()
		account = session.query(tables.User).filter_by(email = payload["email"]).first()
		if account is not None and account.password == hashlib.sha256(hashlib.md5(payload["password"].encode()).hexdigest().encode()).hexdigest():
			for token in account.tokens:
				token.is_active = False

			token = tables.UserToken(
				token = uuid.uuid4().hex,
				is_active = True,
				user_id = account.user_id
			)
			session.add(token)
			session.commit()
			session.refresh(token)
			models.UserToken.from_orm(token)
			return token
		raise HTTPException(status_code = 404, detail = "!ERROR: WRONG PASSWORD OR USERNAME")

# =================================== USERS =================================== #

# =================================== MEMBERS =================================== #

@user.post("/member", response_model = models.Member)
async def member_create(request: Request):
	with sessionbuilder() as session:
		payload = await request.json()
		member = session.query(tables.Member).filter_by(account = payload["account"]).filter_by(center_id = payload["center_id"]).first()
		if member is not None:
			raise HTTPException(status_code = 409, detail = "!ERROR: MEMBER ALREADY EXISTS")

		# member = tables.Member(
		# 	account = payload["account"],
		# 	linked_at = time.time(),
		# 	user_id = payload["user_id"],
		# 	center_id = payload["center_id"]
		# )
		# session.add(member)

		# session.commit()
		# session.refresh(member)
		# models.Member.from_orm(member)
		# return member

@user.post("/member/link", response_model = models.Member)
async def member_link(request: Request):
	with sessionbuilder() as session:
		payload = await request.json()
		center = session.get(tables.Center, payload["center_id"])
		if center is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: CENTER NOT FOUND")

		try:
			icafe_member = transmitter.demand_member(account = payload["account"], password = payload["password"], cafe_id = center.cafe_id, token = center.api_token)
			if icafe_member["data"]["member"] == None:
				raise HTTPException(status_code = 404, detail = "!ERROR: MEMBER ACCOUNT NOT FOUND")
			if icafe_member["data"]["member"] is not None and icafe_member["data"]["verify"] == False:
				raise HTTPException(status_code = 401, detail = "!ERROR: PASSWORD IS INCORRECT")

			member = session.query(tables.Member).filter_by(account = icafe_member["data"]["member"]["member_account"]).filter_by(center_id = payload["center_id"]).first()
			if member is not None:
				raise HTTPException(status_code = 409, detail = "!ERROR: MEMBER ALREADY LINKED TO ANOTHER ACCOUNT")

			member = tables.Member(
				account = icafe_member["data"]["member"]["member_account"],
				icafe_member_id = icafe_member["data"]["member"]["member_id"],
				cash_balance = icafe_member["data"]["member"]["member_balance"],
				points_balance = icafe_member["data"]["member"]["member_points"],
				coins_balance = icafe_member["data"]["member"]["member_coin_balance"],
				bonus_balance = icafe_member["data"]["member"]["member_balance_bonus"],
				linked_at = time.time(),
				user_id = payload["user_id"],
				center_id = payload["center_id"]
			)
			session.add(member)
			session.commit()
			session.flush()
			session.refresh(member)
			models.Member.from_orm(member)
			return member
		except HTTPException as error:
			raise HTTPException(status_code = 400, detail = str(error))
		except Exception as error:
			raise HTTPException(status_code = 503, detail = str(error))

@user.get("/member/user/", response_model = list[models.Member])
async def member_get_by_user(user_id: int):
	with sessionbuilder() as session:
		members = session.query(tables.Member).filter_by(user_id = user_id).all()
		for member in members:
			models.Member.from_orm(member)

		return members

@user.get("/member/center/", response_model = list[models.Member])
async def member_get_by_center(center_id: int):
	with sessionbuilder() as session:
		members = session.query(tables.Member).filter_by(center_id = center_id).all()
		for member in members:
			models.Member.from_orm(member)

		return members

@user.get("/member/user/center/", response_model = models.Member)
async def member_get_by_user_center(user_id: int, center_id: int):
	with sessionbuilder() as session:
		member = session.query(tables.Member).filter_by(user_id = user_id).filter_by(center_id = center_id).first()
		if member is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: MEMBER NOT FOUND")

		models.Member.from_orm(member)
		return member

@user.get("/member/balance/", response_model = models.Member)
async def member_read_balance(member_id: int):
	with sessionbuilder() as session:
		member = session.get(tables.Member, member_id)
		if member is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: MEMBER NOT FOUND")

		icafe_member = transmitter.demand_member(account = member.account, password = '-', cafe_id = member.center.cafe_id, token = member.center.api_token)
		member.cash_balance = icafe_member["data"]["member"]["member_balance"]
		member.points_balance = icafe_member["data"]["member"]["member_points"]
		member.coins_balance = icafe_member["data"]["member"]["member_coin_balance"]
		member.bonus_balance = icafe_member["data"]["member"]["member_balance_bonus"]
		session.commit()

		session.refresh(member)
		models.Member.from_orm(member)
		return member

@user.delete("/member/", response_model = bool)
async def member_delete(member_id: int):
	with sessionbuilder() as session:
		member = session.get(tables.Member, member_id)
		if member is None:
			raise HTTPException(status_code = 404, detail = "!ERROR: MEMBER NOT FOUND")

		session.delete(member)
		session.commit()
		return True

# =================================== MEMBERS =================================== #