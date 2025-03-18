root.controller("master", ($rootScope, $location) => {
	$rootScope.today = new Date().toLocaleString();
	$rootScope.loading = true;
	$rootScope.loadingHint = "Loading";

	$rootScope.menus = [
		{route: "/dashboard", icon: "fas fa-grid-2", controller: "dashboard", name: "Dashboard", is_ready: false, is_root: false, visible: true},
		{route: "/bookings", icon: "fas fa-calendar-users", controller: "bookings", name: "Bookings", is_ready: true, is_root: false},
		{route: "/members", icon: "fas fa-users", controller: "members", name: "Members", is_ready: true, is_root: false},
		{route: "/transactions", icon: "fas fa-receipt", controller: "transactions", name: "Transactions", is_ready: true, is_root: false},
		{route: "/listing", icon: "fas fa-window-maximize", controller: "listing", name: "Listing", is_ready: true, is_root: false},
		{route: "/subcenters", icon: "fas fa-building-flag", controller: "subcenters", name: "Subcenters", is_ready: true, is_root: false}
	];
	$rootScope.superMenus = [
		{route: "/owners", icon: "fas fa-users-between-lines", controller: "owners", name: "Owners", is_root: true},
		{route: "/centers", icon: "fas fa-building-flag", controller: "centers", name: "Centers", is_root: true},
		{route: "/config-transactions", icon: "fas fa-receipt", controller: "config-transactions", name: "Transactions", is_root: true}
	];

	$rootScope.logout = function(owner) {
		if (owner && window.confirm("Do you really want to logout?")) {
			window.localStorage.clear();
			$location.url('/');
		}
	}

	$rootScope.shape = number => {
		if (typeof number == "string") {
			try {
				number = parseFloat(number);
			} catch (error) {}
		}
		if (number != undefined) return number.toLocaleString("ru-RU");
	}
	$rootScope.epsilonRounding = number => {
		if (typeof number == "string") {
			try {
				number = parseFloat(number);
			} catch (error) {}
		}
		return $rootScope.shape(Math.round((number + Number.EPSILON) * 100) / 100);
	}
	$rootScope.mutateDate = function(date) {
		return new Date(date).toLocaleDateString("ru-RU", {day: "numeric", month: "long", year: "numeric"});
	}
	$rootScope.mutateTime = function(date) {
		return new Date(date).toLocaleTimeString("ru-RU");
	}

	$rootScope.notificationSystem = {
		visible: false,
		success: false,
		message: undefined,
		timer: undefined
	};
	$rootScope.dismissNotifiction = function() {
		$rootScope.notificationSystem.visible = false;
	}
	$rootScope.pushNotification = function(success, message, timeout = 3000) {
		if ($rootScope.notificationSystem.timer != undefined) {
			$rootScope.dismissNotifiction();
			clearTimeout($rootScope.notificationSystem.timer);
			$rootScope.notificationSystem.timer = undefined;
		}

		$rootScope.notificationSystem.success = success;
		$rootScope.notificationSystem.message = message;
		$rootScope.notificationSystem.visible = true;
		$rootScope.notificationSystem.timer = setTimeout(() => {
			$rootScope.dismissNotifiction();
			$rootScope.$apply();
		}, timeout);
	}

	$rootScope.modals = {
		owner: {
			visible: false
		},
		settings: {
			visible: false
		}
	};
});
root.controller("login", ($scope, $http, $location, $rootScope) => {
	$rootScope.loading = false;
	$rootScope.error = undefined;

	$scope.authorize = function() {
		$scope.loading = true;
		$scope.error = undefined;
		if ($scope.phone && $scope.password) {
			$http.post(
				"/user/authorize",
				{
					email: $scope.phone,
					password: $scope.password
				},
				{_HEADERS_}
			).then(response => {
				let user = response.data;
				$scope.loading = false;
				if (user.is_admin == false) $scope.error = "User is not owner";
				window.localStorage.setItem("owner", JSON.stringify(response.data));
				$rootScope.pushNotification(true, "Sign In Successfull!");
				if (user.is_root) {
					$location.url("/owners");
					return;
				}
				$location.url("/dashboard");
			}, exception => {
				$scope.loading = false;
				$scope.error = exception.data.detail;
				$rootScope.pushNotification(false, exception.data.detail);
			});
		} else {
			$scope.loading = false;
			$scope.error = "* All fields must be filled";
		}
	}

	if (window.localStorage.getItem("owner") != null) {
		$location.url("/dashboard");
	}
});
root.controller("dashboard", ($scope, $rootScope, $http, $location, $route) => {
	$scope.owner = authenticate($location);
	$scope.controllerName = "dashboard";
	$rootScope.loading = false;
	$rootScope.exception = false;
	$scope.center = undefined;
	$scope.inputs = {
		start: {
			cafeid: undefined,
			token: undefined
		},
		report: {
			startDate: new Date(),
			endDate: new Date
		},
		settings: {
			old: undefined,
			new: undefined
		}
	};
	$scope.inputs.report.startDate.setDate($scope.inputs.report.startDate.getDate() - 1);
	$scope.relations = new Object();
	$scope.charts = new Object();

	$scope.demandCenter = function() {
		if ($scope.inputs.start.cafeid && $scope.inputs.start.token) {
			$rootScope.loading = true;
			$rootScope.loadingHint = "Loading center";
			$http.post(
				"/gateway/center/demand",
				{
					cafe_id: $scope.inputs.start.cafeid,
					token: $scope.inputs.start.token,
				}
			).then(response => {
				$scope.center = {
					cafe_id: $scope.inputs.start.cafeid,
					token: $scope.inputs.start.token,
					name: response.data.data.info.license_icafename,
					display_name: response.data.data.info.license_icafename,
					license_number: response.data.data.info.license_name,
					computer_count: response.data.data.info.license_pcs,
					country: response.data.data.info.license_country,
					is_active: true,
					allow_topup: false,
					allow_booking: true
				};
				window.onbeforeunload = event => "reload";
				$rootScope.loadingHint = "Loading Products";
				$http.post(
					"/gateway/product/demand",
					{
						cafe_id: $scope.inputs.start.cafeid,
						token: $scope.inputs.start.token,
					}
				).then(response => {
					$scope.center.products = response.data.data.items.map(product => {
						return {
							icafe_product_id: product.product_id,
							name: product.product_name,
							display_name: product.product_name,
							price: product.product_price,
							is_visible: true
						};
					});
					$rootScope.loadingHint = "Loading Subcafes";
					$http.post(
						"/gateway/center/subcenter/demand",
						{
							cafe_id: $scope.inputs.start.cafeid,
							token: $scope.inputs.start.token,
						}
					).then(response => {
						$scope.center.subcenters = response.data.data.child.map(cafe => {
							return {
								name: cafe.license_icafename,
								display_name: cafe.license_icafename,
								cafe_id: cafe.object_id,
								license_number: cafe.license_name,
								computer_count: cafe.license_pcs,
								country: cafe.license_country,
								include: true
							};
						});
						$rootScope.loading = false;
						$rootScope.loadingHint = "Loading";
					}, exception => {
						$rootScope.loading = false;
						$rootScope.loadingHint = "Loading";
						$rootScope.pushNotification(false, exception.data.detail);
					});
				}, exception => {
					$rootScope.loading = false;
					$rootScope.loadingHint = "Loading";
					$rootScope.pushNotification(false, exception.data.detail);
				});
			}, exception => {
				$rootScope.loading = false;
				$rootScope.loadingHint = "Loading";
				$rootScope.pushNotification(false, exception.data.detail);
			});
		}
	}
	$scope.renderCharts = function(update = false) {
		if (update) {
			$scope.charts.top_topups.chart.updateSeries(
				$scope.relations.reports.data.top_five_members_topup.map(entry => {
					return {
						x: entry.member,
						y: parseInt(entry.amount)
					};
				})
			);
			$scope.charts.top_pcs.chart.updateSeries(
				$scope.relations.reports.data.top_five_pc_spend.map(entry => {
					return {
						x: entry.member,
						y: parseInt(entry.amount)
					};
				})
			);
		}
		else {
			$scope.charts.top_topups = {
				options: {
					chart: {
						type: "bar"
					},
					plotOptions: {
						bar: {
							vertical: true
						}
					},
					series: [{
						data: $scope.relations.reports.data.top_five_members_topup.map(entry => {
							return {
								x: entry.member,
								y: parseInt(entry.amount)
							};
						})
					}],
					colors: ["#292929"],
					title: {
						text: "Top 5 Topups",
						align: "center"
					}
				}
			};
			$scope.charts.top_pcs = {
				options: {
					chart: {
						type: "bar"
					},
					plotOptions: {
						bar: {
							horizontal: false
						}
					},
					series: [{
						data: $scope.relations.reports.data.top_five_pc_spend.map(entry => {
							return {
								x: entry.pc_name,
								y: parseInt(entry.total_spend)
							};
						})
					}],
					colors: ["#292929"],
					title: {
						text: "Top 5 PC Spend",
						align: "center"
					}
				}
			};
			$scope.charts.top_topups.chart = new ApexCharts(document.querySelector("#chart-top-topups"), $scope.charts.top_topups.options);
			$scope.charts.top_pcs.chart = new ApexCharts(document.querySelector("#chart-top-pcs"), $scope.charts.top_pcs.options);
			$scope.charts.top_topups.chart.render();
			$scope.charts.top_pcs.chart.render();
		}
	}
	$scope.fetchReportData = function(update = true) {
		$rootScope.loading = true;
		$http.get(
			"/gateway/report/data/",
			{
				params: {
					center_id: $scope.owner.center.center_id,
					start_date: $scope.inputs.report.startDate.toISOString().slice(0, 10),
					end_date: $scope.inputs.report.endDate.toISOString().slice(0, 10)
				}
			}
		).then(response => {
			$scope.relations.reports = response.data;
			$scope.renderCharts(update);
			$rootScope.loading = false;
		}, exception => {
			$rootScope.loading = false;
			$rootScope.pushNotification(false, exception.data.detail);
		});
	}

	$scope.createCenter = function() {
		$rootScope.loading = true;
		$rootScope.loadingHint = "Saving";
		$http.post(
			"/gateway/center",
			{
				center: $scope.center,
				owner: $scope.owner
			}
		).then(response => {
			$rootScope.pushNotification(true, "Saved!");
			$rootScope.loading = false;
			$rootScope.loadingHint = "Loading";
			window.onbeforeunload = event => undefined;
			$route.reload();
		}, exception => {
			$rootScope.loading = false;
			$rootScope.loadingHint = "Loading";
			$rootScope.pushNotification(false, exception.data.detail);
		})
	}
	$scope.editOwner = function() {
		if ($scope.owner.name) {
			$rootScope.loading = true;
			$rootScope.errorHint = undefined;
			$http.put(
				"/user/",
				{
					name: $scope.owner.name,
					is_active: $scope.owner.is_active,
					language: $scope.owner.language
				},
				{
					params: {user_id: $scope.owner.user_id}
				}
			).then(response => {
				window.localStorage.setItem("owner", JSON.stringify(response.data));
				$rootScope.loading = false;
				$rootScope.modals.settings.visible = false;
				$rootScope.pushNotification(true, "Saved!");
			}, exception => {
				$rootScope.loading = false;
				$rootScope.pushNotification(false, exception.data.detail);
			});
		} else {
			$rootScope.errorHint = "* All fields must be filled!";
		}
	}
	$scope.resetPassword = function() {
		$rootScope.loading = true;
		$rootScope.errorHint = undefined;
		$http.put(
			"/user/password/",
			{
				old: $scope.inputs.settings.old,
				new: $scope.inputs.settings.new
			},
			{
				params: {user_id: $scope.owner.user_id}
			}
		).then(response => {
			window.localStorage.setItem("owner", JSON.stringify(response.data));
			$rootScope.loading = false;
			$rootScope.modals.settings.visible = false;
			$rootScope.pushNotification(true, "New password is set!");
		}, exception => {
			$rootScope.loading = false;
			$rootScope.pushNotification(false, exception.data.detail);
		});
	}

	$rootScope.loading = true;
	$http.get("/gateway/center/owner/primary/", {params: {owner_id: $scope.owner.user_id}}).then(response => {
		$scope.owner.is_ready = true;
		$scope.owner.center = response.data;
		$http.post(
			"/gateway/booking/demand",
			{
				cafe_id: $scope.owner.center.cafe_id,
				api_token: $scope.owner.center.api_token
			}
		).then(response => {
			$scope.bookings = response.data.data;
			$http.get("/user/member/center/", {params: {center_id: $scope.owner.center.center_id}}).then(response => {
				$scope.members = response.data;
				$rootScope.loading = false;
				$scope.fetchReportData(false);
			}, exception => {
				$rootScope.loading = false;
				$rootScope.pushNotification(false, exception.data.detail);
			});
		}, exception => {
			$rootScope.loading = false;
			$rootScope.pushNotification(false, exception.data.detail);
		});
	}, exception => {
		$rootScope.loading = false;
		$scope.owner.is_ready = false;
	});
});
root.controller("bookings", ($scope, $rootScope, $http, $location, $route) => {
	$scope.owner = authenticate($location);
	$scope.controllerName = "bookings";
	$rootScope.loading = false;
	$rootScope.exception = false;
	$scope.today = new Date().toLocaleDateString("en-EN", {day: "numeric", month: "long", year: "numeric"});

	$scope.cancelBooking = function(booking) {
		if (window.confirm("Do you really want to cancel this booking?")) {
			$rootScope.loading = true;
			$http.delete(
				"/gateway/booking",
				{
					data: {
						center_id: $scope.owner.center.center_id,
						pc_name: booking.product_pc_name,
						offer_id: booking.member_offer_id
					}
				}
			).then(response => {
				$rootScope.loading = false;
				$rootScope.pushNotification(true, "Booking cancelled!");
				window.location.reload();
			}, exception => {
				$rootScope.loading = false;
				$rootScope.pushNotification(false, exception.data.detail);
			});
		}
	}

	$rootScope.loading = true;
	$http.get("/gateway/center/owner/primary/", {params: {owner_id: $scope.owner.user_id}}).then(response => {
		$scope.owner.is_ready = true;
		$scope.owner.center = response.data;
		$http.post(
			"/gateway/booking/demand",
			{
				cafe_id: $scope.owner.center.cafe_id,
				api_token: $scope.owner.center.api_token
			}
		).then(response => {
			$scope.bookings = response.data.data;
			$rootScope.loading = false;
		}, exception => {
			$rootScope.loading = false;
			$rootScope.pushNotification(false, exception.data.detail);
		});
	}, exception => {
		$rootScope.loading = false;
		$scope.owner.is_ready = false;
	});
});
root.controller("members", ($scope, $rootScope, $http, $location, $route) => {
	$scope.owner = authenticate($location);
	$scope.controllerName = "members";
	$rootScope.loading = false;
	$rootScope.exception = false;

	$scope.mutateTimestamp = function(timestamp) {
		return new Date(timestamp * 1000);
	}

	$rootScope.loading = true;
	$http.get("/gateway/center/owner/primary/", {params: {owner_id: $scope.owner.user_id}}).then(response => {
		$scope.owner.is_ready = true;
		$scope.owner.center = response.data;
		$http.get("/user/member/center/", {params: {center_id: $scope.owner.center.center_id}}).then(response => {
			$scope.members = response.data;
			$rootScope.loading = false;
		}, exception => {
			$rootScope.loading = false;
			$rootScope.pushNotification(false, exception.data.detail);
		});
	}, exception => {
		$rootScope.loading = false;
		$scope.owner.is_ready = false;
	});
});
root.controller("transactions", ($scope, $rootScope, $http, $location, $route) => {
	$scope.owner = authenticate($location);
	$scope.controllerName = "transactions";
	$rootScope.loading = false;
	$rootScope.exception = false;

	$scope.editCenter = function() {
		$rootScope.loading = true;
		if ($scope.owner.center.payme_cashbox_id.length == 0) $scope.owner.center.payme_cashbox_id = null;
		if ($scope.owner.center.payme_cashbox_key.length == 0) $scope.owner.center.payme_cashbox_key = null;
		$http.put(
			"/gateway/center/payway/",
			{
				center: $scope.owner.center
			},
			{
				params: {center_id: $scope.owner.center.center_id}
			}
		).then(response => {
			$rootScope.loading = false;
			$rootScope.pushNotification(true, "Saved!");
		}, exception => {
			$rootScope.loading = false;
			$rootScope.pushNotification(false, exception.data.detail);
		});
	}

	$rootScope.loading = true;
	$http.get("/gateway/center/owner/primary/", {params: {owner_id: $scope.owner.user_id}}).then(response => {
		$scope.owner.is_ready = true;
		$scope.owner.center = response.data;
		$http.get("/gateway/transaction/center/", {params: {center_id: $scope.owner.center.center_id}}).then(response => {
			$scope.transactions = response.data;
			$rootScope.loading = false;
		}, exception => {
			$rootScope.loading = false;
			$scope.owner.is_ready = false;
		});
	}, exception => {
		$rootScope.loading = false;
		$scope.owner.is_ready = false;
	});
});
root.controller("listing", ($scope, $rootScope, $http, $location, $route) => {
	$scope.owner = authenticate($location);
	$scope.controllerName = "listing";
	$rootScope.loading = false;
	$rootScope.exception = false;
	$scope.origin = window.location.origin + '/';
	$scope.centerImagesField = document.querySelector("#center-images-field");

	$scope.pushCenterZone = function() {
		$scope.owner.center.zones.push({
			name: null,
			description: null,
			specifications: null,
			computer_count: null
		});
	}
	$scope.popCenterZone = function(zone) {
		$scope.owner.center.zones.splice($scope.owner.center.zones.indexOf(zone), 1);
	}

	$scope.editCenter = function() {
		$rootScope.loading = true;
		$scope.owner.center.images = new Array();
		if ($scope.centerImagesField.files.length > 0) {
			window.centerImageCounter = 0;
			window.readerResultLoaded = event => {
				$scope.owner.center.images.push(event.target.result);
				window.centerImageCounter++;
				if ($scope.centerImagesField.files.length == window.centerImageCounter) {
					$http.put(
						"/gateway/center/",
						{
							center: $scope.owner.center
						},
						{
							params: {center_id: $scope.owner.center.center_id}
						}
					).then(response => {
						$rootScope.loading = false;
						window.location.reload();
						$rootScope.pushNotification(true, "Saved!");
					}, exception => {
						$rootScope.loading = false;
						$rootScope.pushNotification(false, exception.data.detail);
					});
				}
			}
			Array.from($scope.centerImagesField.files).forEach(file => {
				let reader = new FileReader();
				reader.addEventListener("load", window.readerResultLoaded);
				reader.readAsDataURL(file);
			});
		} else {
			$http.put(
				"/gateway/center/",
				{
					center: $scope.owner.center
				},
				{
					params: {center_id: $scope.owner.center.center_id}
				}
			).then(response => {
				$rootScope.loading = false;
				$rootScope.pushNotification(true, "Saved!");
			}, exception => {
				$rootScope.loading = false;
				$rootScope.pushNotification(false, exception.data.detail);
			});
		}
	}
	$scope.removeCenterImage = function(image) {
		if (window.confirm("Do you really want to remove image?")) {
			$rootScope.loading = true;
			$http.delete("/gateway/image-file/", {params: {image_file_id: image.image_file_id}}).then(response => {
				$rootScope.loading = false;
				window.location.reload();
			}, exception => {
				$rootScope.pushNotification(false, exception.data.detail);
			});
		}
	}

	$rootScope.loading = true;
	$http.get("/gateway/center/owner/primary/", {params: {owner_id: $scope.owner.user_id}}).then(response => {
		$scope.owner.is_ready = true;
		$scope.owner.center = response.data;
		$rootScope.loading = false;
	}, exception => {
		$rootScope.loading = false;
		$scope.owner.is_ready = false;
	});
});
root.controller("subcenters", ($scope, $rootScope, $http, $location, $route, $routeParams) => {
	$scope.owner = JSON.parse(window.localStorage.getItem("owner"));
	$scope.controllerName = "subcenters";
	$rootScope.loading = false;
	$rootScope.exception = false;
	$scope.inProgress = false;

	$scope.explain = function(subcenter, scenario) {
		if (scenario == 1) {
			if (subcenter.configured) {
				$rootScope.pushNotification(true, "Your center is configured and visible in application");
			} else {
				$rootScope.pushNotification(false, "Your center is not configured yet");
			}
		} else if (scenario == 2) {
			if (subcenter.allow_topup) {
				$rootScope.pushNotification(true, "Your center is accepting online payments, you can disable it in center configurations page");
			} else {
				$rootScope.pushNotification(false, "Your center is not accepting online payments, you can configure online payments in center configurations page");
			}
		} else if (scenario == 3) {
			if (subcenter.allow_booking) {
				$rootScope.pushNotification(true, "Your center allows online booking, you can disable it in center configurations page");
			} else {
				$rootScope.pushNotification(false, "Your center does not allow online booking, you can configure online booking in center configurations page");
			}
		}
	}

	$scope.gotoSubcenter = function(subcenter) {
		$location.url("/subcenters/configure/" + subcenter.center_id);
	}

	$scope.demandCenter = function() {
		if ($scope.subcenter.cafe_id && $scope.subcenter.api_token) {
			$rootScope.loading = true;
			$rootScope.loadingHint = "Loading center";
			$http.post(
				"/gateway/center/demand",
				{
					cafe_id: $scope.subcenter.cafe_id,
					token: $scope.subcenter.api_token,
				}
			).then(response => {
				$scope.subcenter.configured = true;
				$scope.subcenter.is_active = true;
				$scope.subcenter.allow_topup = true;
				$scope.subcenter.allow_booking = true;
				window.onbeforeunload = event => "reload";
				$scope.inProgress = true;
				$rootScope.loadingHint = "Loading Products";
				$http.post(
					"/gateway/product/demand",
					{
						cafe_id: $scope.subcenter.cafe_id,
						token: $scope.subcenter.api_token,
					}
				).then(response => {
					$scope.subcenter.products = response.data.data.items.map(product => {
						return {
							icafe_product_id: product.product_id,
							name: product.product_name,
							display_name: product.product_name,
							price: product.product_price,
							is_visible: true
						};
					});
					$rootScope.loading = false;
					$rootScope.loadingHint = "Loading";
				}, exception => {
					$rootScope.loading = false;
					$rootScope.loadingHint = "Loading";
					$rootScope.pushNotification(false, exception.data.detail);
				});
			}, exception => {
				$rootScope.loading = false;
				$rootScope.loadingHint = "Loading";
				$rootScope.pushNotification(false, exception.data.detail);
			});
		}
	}

	$scope.editCenter = function(center) {
		$rootScope.loading = true;
		$http.put(
			"/gateway/center/",
			{
				center: center
			},
			{
				params: {center_id: center.center_id}
			}
		).then(response => {
			$rootScope.loading = false;
			$rootScope.pushNotification(true, "Saved!");
		}, exception => {
			$rootScope.loading = false;
			$rootScope.pushNotification(false, exception.data.detail);
		});
	}
	$scope.editSubcenter = function() {
		$rootScope.loading = true;
		$http.put(
			"/gateway/center/configure/",
			{
				center: $scope.subcenter
			},
			{
				params: {center_id: $scope.subcenter.center_id}
			}
		).then(response => {
			$rootScope.loading = false;
			$scope.inProgress = false;
			$location.url("/subcenters");
			window.onbeforeunload = event => undefined;
			$rootScope.pushNotification(true, "Saved!");
		}, exception => {
			$rootScope.loading = false;
			$rootScope.pushNotification(false, exception.data.detail);
		});
	}

	$rootScope.loading = true;
	$http.get("/gateway/center/owner/primary/", {params: {owner_id: $scope.owner.user_id}}).then(response => {
		$scope.owner.is_ready = true;
		$scope.owner.center = response.data;
		$rootScope.loading = false;
	}, exception => {
		$rootScope.loading = false;
		$scope.owner.is_ready = false;
	});
	if ($routeParams.subcenterID != undefined) {
		$rootScope.loading = true;
		$http.get("/gateway/center/", {params: {center_id: $routeParams.subcenterID}}).then(response => {
			$scope.subcenter = response.data;
			$rootScope.loading = false;
		}, exception => {
			$rootScope.loading = false;
		});
	}
});

root.controller("owners", ($scope, $rootScope, $http, $location, $route) => {
	$scope.superuser = authenticate($location);
	$scope.controllerName = "owners";
	$rootScope.loading = false;
	$rootScope.exception = false;
	$scope.inputs = {
		owner: {
			name: undefined,
			email: undefined,
			password: undefined,
			cpassword: undefined,
			is_admin: true,
			is_root: false,
			country_id: null
		}
	};

	$scope.mutateTimestamp = function(timestamp) {
		return new Date(timestamp * 1000);
	}

	$scope.createOwner = function() {
		if ($scope.inputs.owner.name && $scope.inputs.owner.email && $scope.inputs.owner.password && $scope.inputs.owner.cpassword && $scope.inputs.owner.country_id) {
			if ($scope.inputs.owner.password == $scope.inputs.owner.cpassword) {
				$rootScope.loading = true;
				$scope.errorHint = undefined;
				$http.post(
					"/user",
					{
						owner: $scope.inputs.owner
					}
				).then(response => {
					$rootScope.modals.owner.visible = false;
					$rootScope.pushNotification(true, "Created successfully!");
					$scope.owners.push(response.data);
					$rootScope.loading = false;
				}, exception => {
					$rootScope.loading = false;
					$rootScope.pushNotification(false, exception.data.detail);
				})
			}
			else {
				$scope.errorHint = "* Passwords don't match";
			}
		} else {
			$scope.errorHint = "* All fields must be filled";
		}
	}
	$scope.alterActivation = function(owner, is_active) {
		if (is_active) {
			if (!window.confirm("Do you really want to activate this owner account?")) return;
		} else {
			if (!window.confirm("Do you really want to deactivate this owner account?")) return;
		}
		$rootScope.loading = false;
		$http.put(
			"/user/",
			{
				name: owner.name,
				is_active: is_active
			},
			{
				params: {user_id: owner.user_id}
			}
		).then(response => {
			owner.is_active = response.data.is_active;
			$rootScope.loading = false;
		}, exception => {
			$rootScope.loading = false;
			$rootScope.pushNotification(false, exception.data.detail);
		});
	}

	$rootScope.loading = true;
	$http.get("/user/owner/all").then(response => {
		$scope.owners = response.data;
		$rootScope.relations = new Object();
		$http.get("/gateway/country/all").then(response => {
			$scope.relations.countries = response.data;
			$rootScope.loading = false;
		}, exception => {
			$rootScope.loading = false;
			$rootScope.pushNotification(false, exception.data.detail);
		});
	}, exception => {
		$rootScope.loading = false;
		$rootScope.pushNotification(false, exception.data.detail);
	});
});
root.controller("centers", ($scope, $rootScope, $http, $location, $route) => {
	$scope.superuser = authenticate($location);
	$scope.controllerName = "centers";
	$rootScope.loading = false;
	$rootScope.exception = false;

	$scope.mutateTimestamp = function(timestamp) {
		return new Date(timestamp * 1000);
	}

	$rootScope.loading = true;
	$http.get("/gateway/center/all").then(response => {
		$scope.centers = response.data;
		$rootScope.relations = new Object();
		$rootScope.loading = false;
	}, exception => {
		$rootScope.loading = false;
		$rootScope.pushNotification(false, exception.data.detail);
	});
});
root.controller("config-transactions", ($scope, $rootScope, $http, $location, $route) => {
	$scope.superuser = authenticate($location);
	$scope.controllerName = "config-transactions";
	$rootScope.loading = false;
	$rootScope.exception = false;

	$scope.mutateTimestamp = function(timestamp) {
		return new Date(timestamp * 1000);
	}

	$rootScope.loading = true;
	$http.get("/gateway/transaction/last").then(response => {
		$scope.transactions = response.data;
		$rootScope.relations = new Object();
		$rootScope.loading = false;
	}, exception => {
		$rootScope.loading = false;
		$rootScope.pushNotification(false, exception.data.detail);
	});
});