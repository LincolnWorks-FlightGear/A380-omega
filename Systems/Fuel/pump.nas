# FUEL PUMP CONTROLLER CLASS
# Copyright Narendran Muraleedharan 2014

var pump = {
	inlet: {parents:[tank]},
	outlet: {parents:[tank]},
	rate_galps: 0,
	switch: "",
	servicable: 1, # Control with electric system
	update: func() {
		var dt = getprop("/sim/time/delta-sec");
		if((getprop(me.switch) == 1) and (me.inlet.level_gal() - me.rate_galps*dt > 0) and (me.outlet.level_gal() + me.rate_galps*dt < me.outlet.capacity_gal())) {
			# Move fuel from inlet tank to outlet tank
			me.inlet.rm_gal(me.rate_galps*dt);
			me.outlet.add_gal(me.rate_galps*dt);
		}
		# This allows for some fuel to be left out in the tanks - this is a litte more realisitic than completely emptying the tanks, so I left it like that
	},
	new: func(switch, rate, inlet, outlet) {
		var t = {parents:[pump]};
		t.switch = switch;
		t.rate_galps = rate;
		t.inlet = inlet;
		t.outlet = outlet;
		return t;
	}
};
