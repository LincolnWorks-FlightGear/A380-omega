# Waypoint class for flightplan management system - similar to the geo.Coord class but with speed
# NOTE - EQUATION FROM: http://www.movable-type.co.uk/scripts/latlong.html

var wpt = {
	new: func(ident, via, lat, lon) {
		var t = {parents:[wpt]};
		t.ident = ident;
		t.via = via;
		t.latitude = lat;
		t.longitude = lon;
		t.altitude = 0;
		t.speed = 0; # If speed < 1 : use mach, else use KIAS
		return t;
	},
	setAltitude: func(alt) {
		me.altitude = alt;
	},
	setSpeed: func(spd) {
		me.speed = spd;
	},
	getBearingFrom: func(_wpt) {
		# This returns the "initial" bearing (aka. forward azimuth) from the minimizing geodesic path equation
		var phi1 = _wpt.latitude*D2R;
		var phi2 = me.latitude*D2R;
		var dlambda = (me.longitude - _wpt.longitude)*D2R;
		return math.atan2(math.sin(dlambda)*math.cos(phi2), math.cos(phi1)*math.sin(phi2) - math.sin(phi1)*math.cos(phi2)*math.cos(dlambda));
	},
	getDistFrom: func(_wpt) {
		# Haversine forumula for minimizing geodesic distance
		var phi1 = _wpt.latitude*D2R;
		var phi2 = me.latitude*D2R;
		var dphi = ph2 - phi1;
		var dlambda = (me.longitude - _wpt.longitude)*D2R;
		var a = math.sin(dlambda/2)*math.sin(dlambda/2) + math.cos(phi1)*math.cos(phi2)*math.sin(dlambda/2)*math.sin(dlambda/2);
		var c = 2*math.atan2(math.sqrt(a), math.sqrt(1-a));
		return 3443.8985*c; # R*c in nautical miles from http://www.google.com
	},
	getDctHeading: func() {
		# Interface aircraft position to forward azimuth equation
		var phi1 = getprop("/position/latitude-deg")*D2R;
		var phi2 = me.latitude*D2R;
		var dlambda = (me.longitude - getprop("/position/longitude-deg"))*D2R;
		return math.atan2(math.sin(dlambda)*math.cos(phi2), math.cos(phi1)*math.sin(phi2) - math.sin(phi1)*math.cos(phi2)*math.cos(dlambda));
	},
	getDctDistance: func() {
		# Interface aircraft position to haversine equation
		var phi1 = getprop("/position/latitude-deg")*D2R;
		var phi2 = me.latitude*D2R;
		var dphi = ph2 - phi1;
		var dlambda = (me.longitude - getprop("/position/longitude-deg"))*D2R;
		var a = math.sin(dlambda/2)*math.sin(dlambda/2) + math.cos(phi1)*math.cos(phi2)*math.sin(dlambda/2)*math.sin(dlambda/2);
		var c = 2*math.atan2(math.sqrt(a), math.sqrt(1-a));
		return 3443.8985*c;
	},
	getTargetVS: func() { # VNAV FUNCTIONALITY
		var h = getprop("/instrumentation/indicated-altitude-ft");
		var dh = me.altitude() - h;
		var dt = me.getDctDistance()/getprop("/velocities/groundspeed-kt"); # seconds
		return dh/dt; # feet/second
	}
};
