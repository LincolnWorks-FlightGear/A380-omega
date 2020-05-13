# A380 Flightplan management system
# Copyright Narendran Muraleedharan 2014 - shared under CC-BY-NC v3.0

# Depends: FG positioned API

var flightplan = {
	set_cpny_rte: func() {
		#FIXME
	},
	altn_rte: "",
	set_altn_rte: func() {
		#FIXME
	},
	fly_altn_rte: func() {
		#FIXME
	},
	transit: func() {
		if(me.getDistToNextWpt() < 2) {
			me.nextWpt();
		}
	},
	dirTo: func(id) {
		me.currentWptId = id;
	},
	setAltitude: func(id, alt) {
		me.wpts[id].setAltitude(alt);
	},
	setSpeed: func(id, spd) {
		me.wpts[id].setSpeed(spd);
	},
	nextWpt: func() {
		if(me.currentWptId < size(me.wpts)-1) {
			me.currentWptId = me.currentWptId + 1;
		} else {
			print("[FMS] END OF F-PLN");
		}
	},
	appendWpt: func(wpt) {
		setsize(me.wpts, size(me.wpts) + 1);
		if(wpt.altitude == 0) {
			wpt.altitude = getprop("/flight-management/crz_fl")*100;
		}
		if(wpt.speed == 0) {
			wpt.speed = "0.85";
		}
		me.wpts[size(me.wpts) - 1] = wpt;
	},
	insertWpt: func(id, wpt) {
		var _wpts = [];
		setsize(_wpts, size(me.wpts) + 1);
		forindex(var i; me.wpts) {
			if(i < id) {
				_wpts[i] = me.wpts[i];
			} else {
				_wpts[i+1] = me.wpts[i];
			}
		}
		if(wpt.altitude == 0) {
			wpt.altitude = getprop("/flight-management/crz_fl")*100;
		}
		if(wpt.speed == 0) {
			wpt.speed = "0.85";
		}
		_wpts[id] = wpt;
		me.wpts = _wpts;
	},
	deleteWpt: func(id) {
		var _wpts = [];
		setsize(_wpts, size(me.wpts)-1);
		forindex(var i; _wpts) {
			if(i < id) {
				_wpts[i] = me.wpts[i];
			} else {
				_wpts[i] = me.wpts[i+1];
			}
		}
		me.wpts = _wpts;
	},
	getHdgToFollow: func() {
		if(me.currentWptId < size(me.wpts)) {
			return me.wpts[me.currentWptId].getDctHeading;
		} else {
			return me.wpts[size(me.wpts) - 1].getDctHeading; # Else return last waypoint
		}
	},
	getTargetSpeed: func() {
		if(me.currentWptId < size(me.wpts)) {
			return me.wpts[me.currentWptId].speed;
		} else {
			return me.wpts[size(me.wpts) - 1].speed; # Else return last waypoint
		}
	},
	getTargetVS: func() {
		if(me.currentWptId < size(me.wpts)) {
			return me.wpts[me.currentWptId].getTargetVS;
		} else {
			return me.wpts[size(me.wpts) - 1].getTargetVS; # Else return last waypoint
		}
	},
	getRouteDistance: func() {
		var distance = 0;
		forindex(var i; me.wpts) {
			if(i == 0) {
				distance += me.wpts[i].getDctDistance;
			} else {
				distance += me.wpts[i].getDistFrom(me.wpts[i-1]);
			}
		}
		return distance;
	},
	getRemainingDist: func() {
		var distance = 0;
		for(var i=me.currentWptId; i<size(me.wpts); i=i+1) {
			if(i == 0) {
				distance += me.wpts[i].getDctDistance;
			} else {
				distance += me.wpts[i].getDistFrom(me.wpts[i-1]);
			}
		}
		return distance;
	},
	getDistToNextWpt: func() {
		if(me.currentWptId < size(me.wpts)) {
			return me.wpts[me.currentWptId].getDctDistance;
		} else {
			return me.wpts[size(me.wpts) - 1].getDctDistance; # Else return last waypoint
		}
	},
	new: func() {
		var t = {parents:[flightplan]};
		t.active = 0;
		t.currentWptId = 0;
		t.wpts = []; # Array of wpt objects
		t.flt_nbr = "";
		t.depICAO = "";
		t.arrICAO = "";
		t.depRwy = "";
		t.arrRwy = "";
		t.alternate = "";
		t.crz_FL = 0;
		t.cpny_rte = "";
		return t;
	}
};
