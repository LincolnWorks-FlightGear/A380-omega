# AIRBUS A380 FUEL MANAGEMENT SYSTEM
# Copyright Narendran Muraleedharan 2014

# tank.nas, pump.nas and xfeedline.nas must be called prior to this script

# PATHS
var ctl = "/controls/fuel/";

setprop(ctl~"jettison/arm", 0);
setprop(ctl~"jettison/arm-prot", 0);
setprop(ctl~"jettison/active", 0);
setprop(ctl~"jettison/active-prot", 0);

var fuel_system = {
	
	init : func { 
		me.UPDATE_INTERVAL = 0.001; 
		me.loopid = 0;
		
		# Initialize tank interfaces
		me.feed_tk1 = tank.new(0, "FEED TK 1");
		me.feed_tk2 = tank.new(1, "FEED TK 2");
		me.feed_tk3 = tank.new(2, "FEED TK 3");
		me.feed_tk4 = tank.new(3, "FEED TK 4");
		me.l_inr_tk = tank.new(4, "L INR TK");
		me.r_inr_tk = tank.new(5, "R INR TK");
		me.l_mid_tk = tank.new(6, "L MID TK");
		me.r_mid_tk = tank.new(7, "R MID TK");
		me.l_outr_tk = tank.new(8, "L OUTR TK");
		me.r_outr_tk = tank.new(9, "R OUTR TK");
		me.trim_tk = tank.new(10, "TRIM TK");
		me.l_vent_tk = tank.new(11, "L VENT TK");
		me.r_vent_tk = tank.new(12, "R VENT TK");
		
		# Initialize fuel pumps
		me.fuel_pumps = [pump.new(ctl~"l-outer-tk/pump", 8, me.l_outr_tk, me.feed_tk1),
				 pump.new(ctl~"r-outer-tk/pump", 8, me.r_outr_tk, me.feed_tk4),
				 pump.new(ctl~"l-mid-tk/pump-fwd", 8, me.l_mid_tk, me.feed_tk1),
				 pump.new(ctl~"r-mid-tk/pump-fwd", 8, me.r_mid_tk, me.feed_tk4),
				 pump.new(ctl~"l-mid-tk/pump-aft", 6, me.l_mid_tk, me.l_inr_tk),
				 pump.new(ctl~"r-mid-tk/pump-aft", 6, me.r_mid_tk, me.r_inr_tk),
				 pump.new(ctl~"l-inr-tk/pump-fwd", 9, me.l_inr_tk, me.feed_tk2),
				 pump.new(ctl~"r-inr-tk/pump-fwd", 9, me.r_inr_tk, me.feed_tk3),
				 pump.new(ctl~"l-inr-tk/pump-aft", 6, me.l_inr_tk, me.l_mid_tk),
				 pump.new(ctl~"r-inr-tk/pump-aft", 6, me.r_inr_tk, me.r_mid_tk),
				 pump.new(ctl~"jettison/arm", 4, me.l_mid_tk, me.l_vent_tk),
				 pump.new(ctl~"jettison/arm", 4, me.r_mid_tk, me.r_vent_tk),
				 pump.new(ctl~"jettison/arm", 4, me.l_outr_tk, me.l_vent_tk),
				 pump.new(ctl~"jettison/arm", 4, me.r_outr_tk, me.r_vent_tk),
				 pump.new(ctl~"jettison/arm", 5, me.feed_tk1, me.l_vent_tk),
				 pump.new(ctl~"jettison/arm", 5, me.feed_tk2, me.r_vent_tk),
				 pump.new(ctl~"jettison/arm", 5, me.feed_tk3, me.l_vent_tk),
				 pump.new(ctl~"jettison/arm", 5, me.feed_tk4, me.r_vent_tk),
				 pump.new(ctl~"trim-tk/fwd-l", 8, me.trim_tk, me.feed_tk2),
				 pump.new(ctl~"trim-tk/fwd-r", 8, me.trim_tk, me.feed_tk3),
				 pump.new(ctl~"trim-tk/aft-l", 8, me.feed_tk2, me.trim_tk),
				 pump.new(ctl~"trim-tk/aft-r", 8, me.feed_tk3, me.trim_tk)];
		
		me.feedtanks = [xfeedline.new(me.feed_tk1, ctl~"crossfeed/pump-1"),
				xfeedline.new(me.feed_tk2, ctl~"crossfeed/pump-2"),
				xfeedline.new(me.feed_tk3, ctl~"crossfeed/pump-3"),
				xfeedline.new(me.feed_tk4, ctl~"crossfeed/pump-4")];
		
		me.feedtank_total_gal = 0;
		me.feedtank_xfeed_num = 0;
		me.feedline_gal = 0;
		me.feedline_pull_num = 0;
		
		me.reset();
	},
	update : func {

		# Update fuel pumps
		foreach(var fuel_pump; me.fuel_pumps) {
			fuel_pump.update();
		}
		
		# Control cross feed line [RATE: 18 US_GAL/S]
		me.feedtank_total_gal = 0;
		me.feedtank_xfeed_num = 0;
		me.feedline_pull_num = 0;
		me.feedline_gal = 0;
		
		# If crossfeed is enabled, check contents and add to total for average calculation
		foreach(var feedtank; me.feedtanks) {
			if(feedtank.enabled() == 1) {
				me.feedtank_total_gal += feedtank.tank.level_gal();
				me.feedtank_xfeed_num += 1;
			}
		}
		
		var dt = getprop("/sim/time/delta-sec");
		
		if(me.feedtank_xfeed_num >= 2) { # Proceed only if atleast 2 crossfeed valves are open
			var feedtank_avg = me.feedtank_total_gal/me.feedtank_xfeed_num;
			# If the tank has more than the average, move to the cross feed line
			foreach(var feedtank; me.feedtanks) {
				if((feedtank.enabled()) and (feedtank.tank.level_gal() > feedtank_avg + (18*dt))) {
					feedtank.tank.rm_gal(18*dt);
					me.feedline_gal += 18*dt;
				}
			}
			# Count the number of tanks averaging under the crossfeed line contents
			foreach(var feedtank; me.feedtanks) {
				if((feedtank.enabled()) and (feedtank.tank.level_gal() < feedtank_avg)) {
					me.feedline_pull_num += 1;
				}
			}
			# Move equal quantities of fuel into the feed tanks below the average line
			foreach(var feedtank; me.feedtanks) {
				if((feedtank.enabled()) and (feedtank.tank.level_gal() < feedtank_avg)) {
					feedtank.tank.add_gal(me.feedline_gal/me.feedline_pull_num);
				}
			}
		}
		
		# Control trim tank pumps
################################################################################

		var gwcg = (getprop("/fdm/jsbsim/inertia/cg-x-in")-1350)*0.15;
		var phase = getprop("/flight-management/phase");
		var cg_trgt = 32; # %MAC
		if(phase == "T/O") {
			cg_trgt = 32; # 32% MAC - use pitch trim for take-off
			# Suggest pitch trim for take-off
			setprop("/flight-management/to-trim", (gwcg-37)*0.07);
		} elsif(phase == "CLB" or phase == "CRZ") {
			cg_trgt = 35; # 32% MAC
		} else { # DES, APP
			cg_trgt = 37; # 38% MAC
		}

		if(getprop(ctl~"trim-tk/pump-l") == 1) {
			if(cg_trgt < gwcg) {
				# Move CG Forward
				setprop(ctl~"trim-tk/fwd-l", 1);
				setprop(ctl~"trim-tk/aft-l", 0);
			} else {
				# Move CG Backward
				setprop(ctl~"trim-tk/fwd-l", 0);
				setprop(ctl~"trim-tk/aft-l", 1);
			}
		} else {
			setprop(ctl~"trim-tk/fwd-l", 0);
			setprop(ctl~"trim-tk/aft-l", 0);
		}
		
		if(getprop(ctl~"trim-tk/pump-r") == 1) {
			if(cg_trgt < gwcg) {
				# Move CG Forward
				setprop(ctl~"trim-tk/fwd-r", 1);
				setprop(ctl~"trim-tk/aft-r", 0);
			} else {
				# Move CG Backward
				setprop(ctl~"trim-tk/fwd-r", 0);
				setprop(ctl~"trim-tk/aft-r", 1);
			}
		} else {
			setprop(ctl~"trim-tk/fwd-r", 0);
			setprop(ctl~"trim-tk/aft-r", 0);
		}

################################################################################
		
		# Control fuel jettison - As simple as "dumping" fuel, the pump system takes care of moving fuel into the vent tanks
		if(getprop(ctl~"jettison/active") == 1) {
			# Set ARM functions on too
			setprop(ctl~"jettison/arm", 1);
			# Vent fuel at 6 gal/s (not exactly sure about this number, but it works)
			me.l_vent_tk.rm_gal(6*dt);
			me.r_vent_tk.rm_gal(6*dt);
			
			if(me.l_vent_tk.level_norm() > 0.1) {
				setprop(ctl~"jettison/left", 1);
			} else {
				setprop(ctl~"jettison/left", 0);
			}
			
			if(me.r_vent_tk.level_norm() > 0.1) {
				setprop(ctl~"jettison/right", 1);
			} else {
				setprop(ctl~"jettison/right", 0);
			}
			
		} else {
			setprop(ctl~"jettison/left", 0);
			setprop(ctl~"jettison/right", 0);
		}
		
		
		
	}, # Update Fuction end

	reset : func {
		me.loopid += 1;
		me._loop_(me.loopid);
	},

	_loop_ : func(id) {
		id == me.loopid or return;
		me.update();
		settimer(func { me._loop_(id); }, me.UPDATE_INTERVAL);
	}

};
###
# END fuel_system var
###

fuel_system.init();
print("Fuel Management System Initialized");
