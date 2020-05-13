# GPS 'Positioned API' Functions

## getBearing(lat,lon) - returns bearing to position

var getBearing = func(lat,lon) {
	var ac_pos = geo.aircraft_position();
	var wpt = geo.Coord.new();
	wpt.set_latlon(lat,lon);
	return ac_pos.course_to(wpt);
}

## getDistance(lat,lon) - returns distance to position

var getDistance = func(lat,lon) {
	var NM2M = 1852;
	var ac_pos = geo.aircraft_position();
	var wpt = geo.Coord.new();
	wpt.set_latlon(lat,lon);
	return (ac_pos.distance_to(wpt))/NM2M;
}

var searchWpt = func(ident) {
	foreach(var type; ["fix", "vor", "ndb"]) {
		var results = positioned.sortByRange(positioned.findByIdent(ident, type));
		if(size(results) > 0) {
			return fms.wpt.new(ident, "", results[0].lat, results[0].lon);
		}
	}
	return -1;
}

var getArptElev = func(icao) {
	var results = positioned.sortByRange(positioned.findByIdent(icao, 'airport'));
	return results[0].elevation * M2FT;
}
