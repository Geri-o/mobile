import time
import json
import random
import logging
import datetime

import xml.etree.ElementTree as XMLTree

from fastapi import FastAPI, HTTPException, Request, Response

import tables, icafe

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

webhook = FastAPI()
sessionbuilder = sessionmaker(bind = create_engine("postgresql://dev:ronin_dev@localhost:5432/icafeplay"))
# sessionbuilder = sessionmaker(bind = create_engine("postgresql://fedora:fedora@localhost:5432/icafeplay"))
transmitter = icafe.ICafe()
logger = logging.getLogger("webhook")

# =================================== YOOMONEY =================================== #

@webhook.post("/yoomoney", response_model = bool)
async def webhook_yoomoney(request: Request):
	with sessionbuilder() as session:
		payload = await request.json()
		if payload["event"] == "payment.succeeded":
			logger.info("WEBHOOK: YOOMONEY => ID: {}".format(payload["object"]["id"]))
			transaction = session.query(tables.Transaction).filter_by(processor_name = "YOOKASSA").filter_by(processor_transaction_id = payload["object"]["id"]).first()
			if transaction is not None:
				try:
					bill = transmitter.topup(transaction.icafe_member_id, transaction.amount, transaction.center.cafe_id, transaction.center.api_token)
					transaction.icafe_bill = bill[0]
				finally:
					transaction.paid_timestamp = time.time()
					transaction.status = 3
					transaction.processor_state = payload["object"]["status"]
					if payload["object"]["payment_method"]["saved"]:
						bank_card_token = session.query(tables.BankCardToken).filter_by(bank_card_id = transaction.bank_card.bank_card_id)
						bank_card_token = bank_card_token.filter_by(center_id = transaction.center.center_id)
						bank_card_token = bank_card_token.filter_by(processor_name = transaction.processor_name).first()
						bank_card_token.token = payload["object"]["payment_method"]["id"]
						bank_card_token.verified = True

		session.commit()
		return True

# =================================== YOOMONEY =================================== #

# =================================== KASPI =================================== #

@webhook.get("/kaspi/check")
async def kaspi_check(request: Request, command: str, txn_id: int, account: int, amount: float):
	with sessionbuilder() as session:
		logger.info("WEBHOOK: KASPI Check => ID: {}".format(txn_id))
		member_account = session.query(tables.Member).filter_by(icafe_member_id = account).first()

		exception_comment = None
		if member_account is None:
			exception_comment = "ERROR: 1, Account not found"

		try:
			icafe_member = transmitter.get_member(member_account.icafe_member_id, member_account.center.cafe_id, member_account.center.api_token)
			if not icafe_member:
				exception_comment = "ERROR: 1, Account not found"
		except:
			exception_comment = "ERROR: 5, Service Unavailable"

		if exception_comment is not None:
			response = XMLTree.Element("response")
			response_entry = XMLTree.SubElement(response, "txn_id")
			response_entry.text = str(random.randint(999, 99999))
			response_entry = XMLTree.SubElement(response, "result")
			response_entry.text = '1'
			response_entry = XMLTree.SubElement(response, "comment")
			response_entry.text = exception_comment

			response = XMLTree.tostring(response, encoding = "UTF8", method = "xml").decode()
			return Response(content = response, media_type = "application/xml", status_code = 400)

		response = XMLTree.Element("response")
		response_entry = XMLTree.SubElement(response, "txn_id")
		response_entry.text = str(random.randint(999, 99999))
		response_entry = XMLTree.SubElement(response, "result")
		response_entry.text = '0'
		response_entry = XMLTree.SubElement(response, "comment")
		response_entry.text = "iCafePlay"
		response_entry = XMLTree.SubElement(response, "bin")
		response_entry.text = member_account.center.kaspi_bin

		response = XMLTree.tostring(response, encoding = "UTF8", method = "xml").decode()
		return Response(content = response, media_type = "application/xml")

@webhook.get("/kaspi/pay")
async def kaspi_pay(request: Request, command: str, txn_id: int, txn_date: int, account: int, amount: float):
	with sessionbuilder() as session:
		logger.info("WEBHOOK: KASPI Pay => ID: {}".format(txn_id))
		member_account = session.query(tables.Member).filter_by(icafe_member_id = account).first()

		exception_comment = None
		if member_account is None:
			exception_comment = "ERROR: 1, Member not found"

		if exception_comment is not None:
			response = XMLTree.Element("response")
			response_entry = XMLTree.SubElement(response, "txn_id")
			response_entry.text = str(random.randint(999, 99999))
			response_entry = XMLTree.SubElement(response, "result")
			response_entry.text = '1'
			response_entry = XMLTree.SubElement(response, "comment")
			response_entry.text = exception_comment

			if member_account is not None:
				response_entry = XMLTree.SubElement(response, "bin")
				response_entry.text = member_account.center.kaspi_bin

			response = XMLTree.tostring(response, encoding = "UTF8", method = "xml").decode()
			return Response(content = response, media_type = "application/xml", status_code = 400)

		transaction = tables.Transaction(
			processor_name = "KASPI",
			processor_transaction_id = txn_id,
			amount = amount,

			created_date = datetime.datetime.now(),
			created_timestamp = time.time(),
			status = 1,
			processor_state = "CHECK",

			icafe_member_account = member_account.account,
			icafe_member_id = member_account.icafe_member_id,
			center_id = member_account.center.center_id,
			member_id = member_account.member_id
		)
		session.add(transaction)
		session.flush()

		try:
			bill = transmitter.topup(transaction.icafe_member_id, transaction.amount, transaction.center.cafe_id, transaction.center.api_token)
			transaction.icafe_bill = bill[0]
		finally:
			transaction.status = 3
			transaction.paid_timestamp = txn_date
			transaction.processor_state = "PAY"
		session.commit()
		session.refresh(transaction)

		response = XMLTree.Element("response")
		response_entry = XMLTree.SubElement(response, "txn_id")
		response_entry.text = str(random.randint(999, 99999))
		response_entry = XMLTree.SubElement(response, "prv_txn")
		response_entry.text = str(transaction.transaction_id)
		response_entry = XMLTree.SubElement(response, "sum")
		response_entry.text = str(transaction.amount)
		response_entry = XMLTree.SubElement(response, "result")
		response_entry.text = '0'
		response_entry = XMLTree.SubElement(response, "comment")
		response_entry.text = "OK"
		response_entry = XMLTree.SubElement(response, "bin")
		response_entry.text = transaction.center.kaspi_bin

		response = XMLTree.tostring(response, encoding = "UTF8", method = "xml").decode()
		return Response(content = response, media_type = "application/xml")

# =================================== KASPI =================================== #