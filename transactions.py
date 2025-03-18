import uuid
import random
import requests
import yookassa

class PaycomSubscribeAPI:
	# endpoint = "https://checkout.test.paycom.uz/api"
	endpoint = "https://checkout.paycom.uz/api"
	processor = "paycom.uz"

	@classmethod
	def authorize(self, cashbox_id: str, cashbox_key: str, scenario: int):
		if scenario == 1:
			return {"X-Auth": "{}".format(cashbox_id)}
		else:
			return {"X-Auth": "{}:{}".format(cashbox_id, cashbox_key)}

	@classmethod
	def cards_create(self, headers: dict, request_id: int, number: str, expire: str):
		payload = {
			"id": request_id,
			"method": "cards.create",
			"params": {
				"card": {
					"number": number,
					"expire": expire.replace('/', '')
				},
				"save": True
			}
		}
		response = requests.post(self.endpoint, json = payload, headers = headers)
		response = response.json()
		if "result" in response:
			return response
		else:
			raise Exception(response["error"])

	@classmethod
	def cards_get_verify_code(self, headers: dict, request_id: int, token: str):
		payload = {
			"id": request_id,
			"method": "cards.get_verify_code",
			"params": {
				"token": token
			}
		}
		response = requests.post(self.endpoint, json = payload, headers = headers)
		response = response.json()
		if "result" in response:
			return True
		else:
			raise Exception(response["error"])

	@classmethod
	def cards_verify(self, headers: dict, request_id: int, token: str, code: str):
		payload = {
			"id": request_id,
			"method": "cards.verify",
			"params": {
				"token": token,
				"code": code
			}
		}
		response = requests.post(self.endpoint, json = payload, headers = headers)
		response = response.json()
		# RAISES ERROR IF CONFIMATION CODE IS INCORRECT
		if "result" in response:
			return response
		else:
			raise Exception(response["error"])

	@classmethod
	def cards_check(self, headers: dict, request_id: int, token: str):
		payload = {
			"id": request_id,
			"method": "cards.check",
			"params": {
				"token": token
			}
		}
		response = requests.post(self.endpoint, json = payload, headers = headers)
		response = response.json()
		if "result" in response:
			return response
		else:
			raise Exception(response["error"])

	@classmethod
	def cards_remove(self, headers: dict, request_id: int, token: str):
		payload = {
			"id": request_id,
			"method": "cards.remove",
			"params": {
				"token": token
			}
		}
		response = requests.post(self.endpoint, json = payload, headers = headers)
		response = response.json()
		if "result" in response:
			return response
		else:
			raise Exception(response["error"])

	@classmethod
	def receipts_create(self, headers: dict, request_id: int, amount: int):
		payload = {
			"id": request_id,
			"method": "receipts.create",
			"params": {
				"amount": amount,
				"details": {
					"receipt_type": 0,
					"items": [
						{
							"title": "TOPUP FROM ICAFEPLAY",
							"price": amount,
							"count": 1,
							"code": "11703002001000000", # Computer Entertainment Industry
							"package_code": "-1",
							"vat_percent": 0
						}
					]
				}
			}
		}
		response = requests.post(self.endpoint, json = payload, headers = headers)
		response = response.json()
		if "result" in response:
			return response
		else:
			raise Exception(response["error"])

	@classmethod
	def receipts_pay(self, headers: dict, request_id: int, token: str, receipt: str):
		payload = {
			"id": request_id,
			"method": "receipts.pay",
			"params": {
				"id": receipt,
				"token": token
				# "payer": {
				# 	"phone": None,
				# 	"email": None,
				# 	"ip": None
				# }
			}
		}
		response = requests.post(self.endpoint, json = payload, headers = headers)
		response = response.json()
		if "result" in response:
			return response
		else:
			raise Exception(response["error"])

	@classmethod
	def receipts_send(self, headers: dict, request_id: int, receipt_id: str, phone: str):
		payload = {
			"id": request_id,
			"method": "receipts.send",
			"params": {
				"id": receipt_id,
				"phone": phone
			}
		}
		response = requests.post(self.endpoint, json = payload, headers = headers)
		response = response.json()
		if "result" in response:
			return response
		else:
			raise Exception(response["error"])

	@classmethod
	def receipts_cancel(self, headers: dict, request_id: int, receipt_id: str):
		payload = {
			"id": request_id,
			"method": "receipts.cancel",
			"params": {
				"id": receipt_id
			}
		}
		response = requests.post(self.endpoint, json = payload, headers = headers)
		response = response.json()
		if "result" in response:
			return response
		else:
			raise Exception(response["error"])

	@classmethod
	def receipts_check(self, headers: dict, request_id: int, receipt_id: str):
		payload = {
			"id": request_id,
			"method": "receipts.check",
			"params": {
				"id": receipt_id
			}
		}
		response = requests.post(self.endpoint, json = payload, headers = headers)
		response = response.json()
		if "result" in response:
			return response
		else:
			raise Exception(response["error"])

	@classmethod
	def receipts_get(self, headers: dict, request_id: int, receipt_id: str):
		payload = {
			"id": request_id,
			"method": "receipts.get",
			"params": {
				"id": receipt_id
			}
		}
		response = requests.post(self.endpoint, json = payload, headers = headers)
		response = response.json()
		if "result" in response:
			return response
		else:
			raise Exception(response["error"])

	@classmethod
	def receipts_get_all(self, headers: dict, request_id: int, limit: int, _from: int, _to: int, offset: int):
		# limit = 50 max
		payload = {
			"id": request_id,
			"method": "receipts.get_all",
			"params": {
				"count": limit,
				"from": _from,
				"to": _to,
				"offset": offset
			}
		}
		response = requests.post(self.endpoint, json = payload, headers = headers)
		response = response.json()
		if "result" in response:
			return response
		else:
			raise Exception(response["error"])

	@classmethod
	def receipts_set_fiscal_data(self):
		pass


class YooMoney:
	processor = "yookassa.ru"

	def __init__(self):
		pass

	@classmethod
	def generate_idempotence_key(self):
		return uuid.uuid4().hex

	@classmethod
	def authorize(self, shop_id: int, api_key: str):
		yookassa.Configuration.account_id = shop_id
		yookassa.Configuration.secret_key = api_key

	@classmethod
	def acquire_payment(self, payment_id: str):
		payment = yookassa.Payment.find_one(payment_id)
		return payment

	@classmethod
	def create_payment(self, bank_card, amount: int):
		payment = yookassa.Payment.create({
			"amount": {
				"value": str(amount),
				"currency": "RUB"
			},
			# "payment_method_data": {
				# "type": "bank_card"
				# "card": {
				# 	"cardholder": bank_card.holder,
				# 	"csc": bank_card.cvv,
				# 	"expiry_month": bank_card.expiry_date.split('/')[0],
				# 	"expiry_year": "20" + bank_card.expiry_date.split('/')[1],
				# 	"number": bank_card.number
				# }
			# },
			"confirmation": {
				"type": "redirect",
				"return_url": "https://cp.icafeplay.ru/view/transaction/success",
				"enforce": True
			},
			"capture": True,
			# "save_payment_method": True,
			"decription": "TOPUP FROM ICAFEPLAY"
		}, self.generate_idempotence_key())
		return payment

	@classmethod
	def cancel_payment(self, payment_id: str):
		payment = yookassa.Payment.cancel(payment_id, self.generate_idempotence_key())
		return payment

	@classmethod
	def capture_payment(self, transaction_id: str):
		result = yookassa.Payment.capture(transaction_id, self.generate_idempotence_key())
		return result

# if __name__ == "__main__":
	# yoomoney = YooMoney()
	# yoomoney.authorize(437481, "test_txq3FjIAgnzJnIoHcbHEPTrlEK90T9micEoVWLKG_gc")
	# yoomoney.authorize(455347, "live_pjakF1GJ0_fKYBgox1tnltGib3gpivJ2Ycp36XL-Xqc")
	# payment = yoomoney.create_redirect_payment()
	# payment = yoomoney.acquire_payment("2e7924b5-000f-5000-9000-118f9bcc9ef9")
	# payment = yoomoney.cancel_payment("2e7924b5-000f-5000-9000-118f9bcc9ef9")
	# print(payment.confirmation)
	# print(payment.json())