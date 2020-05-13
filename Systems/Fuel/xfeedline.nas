# CROSSFEED LINE CLASS
# Copyright Narendran Muraleedharan 2014

var xfeedline = {
	tank: {parents:[tank]},
	switch: "",
	enabled: func() {
		return getprop(me.switch);
	},
	new: func(tank, switch) {
		var t = {parents:[xfeedline]};
		t.tank = tank;
		t.switch = switch;
		return t;
	}
}
