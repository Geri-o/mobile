import time
import logging
import requests

import tables

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

sessionbuilder = sessionmaker(bind = create_engine("postgresql://fedora:fedora@localhost:5432/icafeplay"))

logger = logging.getLogger("icafe")

class ICafe:
	def __init__(self):
		self.headers = {"Accept": "*/*", "Connection": "keep-alive"}
		self.api_endpoint = "https://api.icafecloud.com/api"

	def demand_center(self, cafe_id: int, token: str) -> dict:
		logger.info("Icafe: Demanding Center: {}".format(cafe_id))
		self.headers["Authorization"] = "Bearer {}".format(token)
		response = requests.get("{}/v2/cafe/{}/license/info".format(self.api_endpoint, cafe_id), headers = self.headers)
		response = response.json()
		if response["code"] == 200:
			return response
		raise Exception("Received error from iCafe")

	def demand_pc_groups(self, cafe_id: int, token: str) -> dict:
		logger.info("Icafe: Demanding PC Groups: {}".format(cafe_id))
		self.headers["Authorization"] = "Bearer {}".format(token)
		response = requests.get("{}/v2/cafe/{}/pcGroups".format(self.api_endpoint, cafe_id) , headers = self.headers)
		response = response.json()
		if response["code"] == 200:
			return response
		raise Exception("Received error from iCafe")

	def demand_computers(self, cafe_id: int, token: str) -> dict:
		logger.info("Icafe: Demanding PCs: {}".format(cafe_id))
		self.headers["Authorization"] = "Bearer {}".format(token)
		response = requests.get("{}/v2/cafe/{}/pcs".format(self.api_endpoint, cafe_id) , headers = self.headers)
		response = response.json()
		if response["code"] == 200:
			return response
		raise Exception("Received error from iCafe")

	def demand_member_groups(self, cafe_id: int, token: str) -> dict:
		logger.info("Icafe: Demanding Member Groups: {}".format(cafe_id))
		self.headers["Authorization"] = "Bearer {}".format(token)
		response = requests.get("{}/v2/cafe/{}/memberGroups".format(self.api_endpoint, cafe_id) , headers = self.headers)
		response = response.json()
		if response["code"] == 200:
			return response
		raise Exception("Received error from iCafe")

	def demand_product_groups(self, cafe_id: int, token: str) -> dict:
		logger.info("Icafe: Demanding Product Groups: {}".format(cafe_id))
		self.headers["Authorization"] = "Bearer {}".format(token)
		response = requests.get("{}/v2/cafe/{}/productGroups".format(self.api_endpoint, cafe_id) , headers = self.headers)
		response = response.json()
		if response["code"] == 200:
			return response
		raise Exception("Received error from iCafe")

	def demand_products(self, cafe_id: int, token: str) -> dict:
		logger.info("Icafe: Demanding Products: {}".format(cafe_id))
		self.headers["Authorization"] = "Bearer {}".format(token)
		response = requests.get("{}/v2/cafe/{}/products".format(self.api_endpoint, cafe_id) , headers = self.headers)
		response = response.json()
		if response["code"] == 200:
			return response
		raise Exception("Received error from iCafe")

	def demand_subcenters(self, cafe_id: int, token: str) -> dict:
		logger.info("Icafe: Demanding Subcenters: {}".format(cafe_id))
		self.headers["Authorization"] = "Bearer {}".format(token)
		response = requests.get("{}/v2/cafe/{}/subcafes".format(self.api_endpoint, cafe_id) , headers = self.headers)
		response = response.json()
		if response["code"] == 200:
			return response
		raise Exception("Received error from iCafe")

	def demand_bookings(self, cafe_id: int, token: str) -> dict:
		logger.info("Icafe: Demanding Bookings: {}".format(cafe_id))
		self.headers["Authorization"] = "Bearer {}".format(token)
		response = requests.get("{}/v2/cafe/{}/bookings".format(self.api_endpoint, cafe_id) , headers = self.headers)
		response = response.json()
		if response["code"] == 200:
			return response
		raise Exception("Received error from iCafe")

	def demand_member(self, account: str, password: str, cafe_id: int, token: str) -> dict:
		logger.info("Icafe: Member Info: {}".format(account))
		self.headers["Authorization"] = "Bearer {}".format(token)
		params = {"member_account": account, "member_password": password}
		response = requests.post("{}/v2/cafe/{}/members/action/memberInfo".format(self.api_endpoint, cafe_id), params = params, headers = self.headers)
		response = response.json()
		if response["code"] == 200:
			return response
		raise Exception("Received error from iCafe")

	def place_booking(self, pc_name: str, date: str, time: str, minutes: str, member: str, comment: str, cafe_id: int, token: str) -> dict:
		logger.info("Icafe: Booking Create: {}".format(member))
		self.headers["Authorization"] = "Bearer {}".format(token)
		payload = {
			"pc_name": pc_name,
			"start_date": date,
			"start_time": time,
			"mins": minutes,
			"member_account": member,
			"comment": comment,
			"guest_booking": 0
		}
		response = requests.post("{}/v2/cafe/{}/bookings".format(self.api_endpoint, cafe_id), json = payload, headers = self.headers)
		response = response.json()
		if response["code"] == 200:
			return response
		raise Exception("Received error from iCafe")

	def delete_booking(self, pc_name: str, offer_id: str, cafe_id: int, token: str) -> dict:
		logger.info("Icafe: Booking Delete: {}".format(pc_name))
		self.headers["Authorization"] = "Bearer {}".format(token)
		payload = {
			"pc_name": pc_name,
			"member_offer_id": offer_id
		}
		response = requests.delete("{}/v2/cafe/{}/bookings".format(self.api_endpoint, cafe_id), json = payload, headers = self.headers)
		response = response.json()
		if response["code"] == 200:
			return response
		raise Exception("Received error from iCafe")

	def demand_report_data(self, start: str, end: str, cafe_id: int, token: str) -> dict:
		logger.info("Icafe: Demanding report data: {}".format(cafe_id))
		self.headers["Authorization"] = "Bearer {}".format(token)
		response = requests.get("{}/v2/cafe/{}/reports/reportData?date_start={}&date_end={}&time_start=00:00&time_end=23:59".format(self.api_endpoint, cafe_id, start, end), headers = self.headers)
		response = response.json()
		if response["code"] == 200:
			return response
		raise Exception("Received error from iCafe")

	def get_member(self, member_id: int, cafe_id: int, token: str) -> dict | None:
		logger.info(f"Icafe getting details of member, {member_id}")
		self.headers["Authorization"] = "Bearer {}".format(token)
		url = "{}/v2/cafe/{}/members/{}".format(self.api_endpoint, cafe_id, member_id)
		response = requests.get(url, headers = self.headers)
		response = response.json()
		if response["code"] == 200:
			return response
		else:
			return None

	def search(self, user: str, cafe_id: int, token: str):
		logger.info(f"Icafe searching {user}")
		self.headers["Authorization"] = "Bearer {}".format(token)
		url = "{}/v2/cafe/{}/members/action/suggestMembers".format(self.api_endpoint, cafe_id)
		parameters = {"search_text": user}
		response = requests.get(url, params = parameters, headers = self.headers)
		response = response.json()
		if len(response["data"]) == 0:
			raise Exception("No users found")

		# Find matching or return 1st
		for account in response["data"]:
			if account["member_account"] == user:
				logger.info(f"Found {user}, returning id")
				return account

		raise Exception("User does not match")

	def topup(self, user: str, amount: int, cafe_id: int, token: str):
		logger.info(f"Top up on {user}")
		self.headers["Authorization"] = "Bearer {}".format(token)
		url = "{}/v2/cafe/{}/members/action/topup".format(self.api_endpoint, cafe_id)
		payload = {"topup_ids": int(user), "topup_value": amount, "comment": "TOPUP FROM iCafePlay"}
		response = requests.post(url, payload, headers = self.headers)
		response = response.json()
		if response["code"] == 200:
			logger.info(f"Topup successful, user => {user}")
			return response["data"]["order_ids"]

		raise Exception("Failed to place an order")