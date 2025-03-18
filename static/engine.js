let _HEADERS_ = {
	"Content-Type": "application/json"
}

let root = angular.module("root", ["ngRoute"])

root.config(['$interpolateProvider', function($interpolateProvider) {
	$interpolateProvider.startSymbol('[[');
	$interpolateProvider.endSymbol(']]');
}]);

root.config($routeProvider => {
	$routeProvider.when('/', {
		templateUrl: "/view/login"
	}).when("/dashboard", {
		templateUrl: "/view/dashboard"
	}).when("/listing", {
		templateUrl: "/view/listing"
	}).when("/subcenters", {
		templateUrl: "/view/subcenters"
	}).when("/subcenters/configure/:subcenterID", {
		templateUrl: "/view/subcenters/configure"
	}).when("/bookings", {
		templateUrl: "/view/bookings"
	}).when("/members", {
		templateUrl: "/view/members"
	}).when("/transactions", {
		templateUrl: "/view/transactions"
	})
	.when("/owners", {
		templateUrl: "/view/owners"
	}).when("/centers", {
		templateUrl: "/view/centers"
	}).when("/config-transactions", {
		templateUrl: "/view/config-transactions"
	})
	.when("/event/log", {
		templateUrl: "/view/event/log"
	});
});

function authenticate($location) {
	if (window.localStorage.getItem("owner") == null) $location.url('/');
	else return JSON.parse(window.localStorage.getItem("owner"));
}