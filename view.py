from fastapi import FastAPI, Request
from fastapi.templating import Jinja2Templates
from fastapi.responses import HTMLResponse

view = FastAPI()
templates = Jinja2Templates(directory = "templates")

@view.get('/', response_class = HTMLResponse)
async def root(request: Request):
	return templates.TemplateResponse("root.html", {"request": request})

@view.get("/login", response_class = HTMLResponse)
async def login(request: Request):
	return templates.TemplateResponse("login.html", {"request": request})

@view.get("/dashboard", response_class = HTMLResponse)
async def dashboard(request: Request):
	return templates.TemplateResponse("dashboard.html", {"request": request})

@view.get("/listing", response_class = HTMLResponse)
async def listing(request: Request):
	return templates.TemplateResponse("listing.html", {"request": request})

@view.get("/subcenters", response_class = HTMLResponse)
async def subcenters(request: Request):
	return templates.TemplateResponse("subcenters.html", {"request": request})

@view.get("/subcenters/configure", response_class = HTMLResponse)
async def subcenters_configure(request: Request):
	return templates.TemplateResponse("subcenters_configure.html", {"request": request})

@view.get("/bookings", response_class = HTMLResponse)
async def bookings(request: Request):
	return templates.TemplateResponse("bookings.html", {"request": request})

@view.get("/members", response_class = HTMLResponse)
async def members(request: Request):
	return templates.TemplateResponse("members.html", {"request": request})

@view.get("/transactions", response_class = HTMLResponse)
async def transactions(request: Request):
	return templates.TemplateResponse("transactions.html", {"request": request})

@view.get("/owners", response_class = HTMLResponse)
async def view_owners(request: Request):
	return templates.TemplateResponse("owners.html", {"request": request})

@view.get("/centers", response_class = HTMLResponse)
async def view_centers(request: Request):
	return templates.TemplateResponse("centers.html", {"request": request})

@view.get("/config-transactions", response_class = HTMLResponse)
async def view_config_transactions(request: Request):
	return templates.TemplateResponse("config-transactions.html", {"request": request})


@view.get("/transaction/success", response_class = HTMLResponse)
async def transaction_success(request: Request):
	return templates.TemplateResponse("transaction-success.html", {"request": request})

@view.get("/event/log", response_class = HTMLResponse)
async def event_log(request: Request):
	return templates.TemplateResponse("events.log.html", {"request": request})