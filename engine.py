import logging

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import RedirectResponse, FileResponse

import user, gateway, view, webhook

root = FastAPI(title = "iCafePlay", version = "1.0.1")
root.mount("/static", StaticFiles(directory = "static"), name = "static")

logging.basicConfig(filename = "event.log", level = logging.INFO)
logger = logging.getLogger("engine")

@root.get('/', response_class = RedirectResponse)
async def template():
	return "/view"

root.mount("/view", view.view)
root.mount("/user", user.user)
root.mount("/gateway", gateway.gateway)
root.mount("/webhook", webhook.webhook)