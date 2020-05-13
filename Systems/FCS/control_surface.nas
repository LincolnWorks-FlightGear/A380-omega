########################################
## AIRBUS A380 CONTROL SURFACE        ##
########################################
## Written by Narendran Muraleedharan ##
########################################

var control_surface = {
	prop: "",
	norm: 0,
	relax: -1,
	speed: 0.05,
	addVal: 0,
	hyd_system: [],
	add: func(val) {
		me.addVal = val;
	},
	actuator_pressure: 3000, # default everything to working perfectly well
	move_pos: func(target) {
		if(abs(target + me.addVal) <= 1) {
			target = target + me.addVal;
		} else {
			if(target + me.addVal > 1) {
				target = 1;
			} else {
				target = -1;
			}
		}
		var dt = getprop("/sim/time/delta-sec")*30;
		if(me.norm < target - me.speed*dt) {
			me.norm += me.speed*dt;
		} elsif(me.norm > target + me.speed*dt) {
			me.norm -= me.speed*dt;
		} else {
			me.norm = target;
		}
		var aspd = getprop("/velocities/airspeed-kt");
		var relax = me.relax*(1 - (aspd/140)); # Actual relax position
		if(aspd >= 140) { # Set relax position to 0
			relax = 0;
		}
		var act_norm = me.actuator_pressure*((me.norm - relax)/3000) + relax;
		if(me.actuator_pressure > 3000) {
			act_norm = me.norm;
		}
		setprop("/fdm/jsbsim/fcs/"~me.prop, act_norm);
	},
	pressurize: func() {
		var pressure = 0;
		foreach(var system; me.hyd_system) {
			var system_pressure_psi = getprop("/systems/hydraulics/"~system~"/pressure-psi");
			if(system_pressure_psi != nil) {
				pressure += system_pressure_psi;
			}
		}
		if(pressure > 3000) {
			me.actuator_pressure = 3000;
		} else {
			me.actuator_pressure = pressure;
		}
	},
	get_norm: func() {
		return getprop("/fdm/jsbsim/fcs/"~me.prop);
	},
	# Constructor
	new: func(prop, relax, speed, hyd_system) {
		var t = {parents:[control_surface]};
		t.prop = prop;
		t.relax = relax;
		t.speed = speed;
		t.hyd_system = hyd_system;
		return t;
	}
};
