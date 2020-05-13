# MODIFIED AIRBUS BRAKING SYSTEM FOR A380
# Narendran Muraleedharan (c) 2014

setprop("/hydraulics/brakes/autobrake-rto", 0);

var brakes = {

	rto_active: 0,

	# Manual Brakes get hydraulic power supply from crew stepping on brake pedals. Autobrakes get power from yellow hydraulic system. The yellow hydraulic system needs to provide atleast 1400 PSI hydraulic power to get autobrakes to work. An accumulator is used with auto-brakes to maintain constant hydraulic flow.
	
	# BRAKE SYSTEM INDICATOR
	# > Left Brake Press : Pressure applied on left main gear brakes
	# > Right Brake Press : Pressure applied on right main gear brakes
	# > Accumulator Press : Pressure of hydraulic fluid stored in hydraulic accumulator
	
	# The air pressure in accumulator (without any hydraulic fluid) is by defauly, 600 psi. The maximum pressure in there would be 4000 and the optimal pressure zone would be from 2500 to 3500 PSI.
	
	pressurize : func() {
	
		var brake_l = getprop("/controls/gear/brake-left");
		var brake_r = getprop("/controls/gear/brake-right");
		
		setprop("/hydraulics/brakes/pressure-left-psi", brake_l * 3000);
		setprop("/hydraulics/brakes/pressure-right-psi", brake_r * 3000);
		
		# NOTE: Max pressure available from brake pedals = 3000, but for auto-brakes the equation would be brake_x * yellow_hyd_press
	
	},
	
	rto: func() {
	
		# Check if RTO is enabled
		if(getprop("/hydraulics/brakes/autobrake-rto") > 0) {
		
			# Disable if already took-off
			if(getprop("/position/altitude-agl-ft") > 50) {
				me.rto_active = 0;
				setprop("/hydraulics/brakes/autobrake-rto", 0);
			}
		
			var throttle = getprop("/controls/engines/engine[0]/throttle");
			
			if(throttle == 1 and me.rto_active == 0) {
				me.rto_active = 1;
			}
			
			if(me.rto_active > 0 and throttle <= 0.5) { # Power down after starting take-off roll
				if(getprop("/velocities/groundspeed-kt") > 5) {
					setprop("/hydraulics/brakes/autobrake-rto", 2);
					setprop("/controls/flight/speedbrake", 1);
					me.abs_active(1,1,hydraulics.yellow_psi);
				} else {
					setprop("/hydraulics/brakes/autobrake-rto", 0);
					me.rto_active = 0;
				}
			}
		
		}
	
	},
	
	autobrake : func(setting) { # 0 > DISARM, 1 > BTV, 2 > LO, 3 > 2, 4 > 3, 5 > HI
	
		var brake_norm = 0;
		
		# BTV - Brake To Vacate [FIXME]
		
		if(setting > 1) {
			brake_norm = (setting-1) * 0.25;
		}
		
		var accum_press = 600;
		
		if (hydraulics.yellow_psi > 1600)
			accum_press = hydraulics.yellow_psi - 1200;
		elsif (hydraulics.yellow_psi > 600)
			accum_press = hydraulics.yellow_psi;
			
		setprop("/hydraulics/brakes/accumulator-pressure-psi", accum_press);
		
		if ((setting != 0) and (getprop("/gear/gear/wow"))) {
		
			var gspeed = getprop("/velocities/groundspeed-kt");
			
			if (gspeed >= 40)
				me.abs_active(brake_norm, brake_norm, hydraulics.yellow_psi);
			else
				setprop("/hydraulics/brakes/autobrake-setting", 0);
		
		}
		
		me.rto();
	
	},
	
	abs_active : func(brake_l, brake_r, press) {
	
		if (press <= 3000) {
			setprop("/controls/gear/brake-left", brake_l * (press / 3000));
			setprop("/controls/gear/brake-right", brake_r * (press / 3000));
		} else {
			setprop("/controls/gear/brake-left", brake_l);
			setprop("/controls/gear/brake-right", brake_r);
		}
		
		# Update brake pressures
    	setprop("/hydraulics/brakes/pressure-left-psi", brake_l * press);
		setprop("/hydraulics/brakes/pressure-right-psi", brake_r * press);
	
	}

};
