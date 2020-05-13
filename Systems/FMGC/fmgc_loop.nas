# A380 Flight Management and Guidance Computer
# Based on the A320neo/A330s FMGC minor change by ph-cor jan2016
# Copyright Narendran Muraleedharan 2014 

var fmgc = "/flight-management/control/";
var settings = "/flight-management/settings/";
var fcu = "/flight-management/fcu-values/";
var fmgc_val = "/flight-management/fmgc-values/";
var servo = "/flight-management/outputs/";

setprop("/flight-management/text/qnh", "QNH");

setprop("/flight-management/end-flight", 0);

# Start with empty active flight-plan
var active_fpln = fms.flightplan.new();

# After modifying the flight plan, the specific flight plan is copied onto the active flight plan

var fmgc_loop = {
       init : func {
            me.UPDATE_INTERVAL = 0.05;
            
            # ALT SELECT MODE
            
            setprop(fmgc~ "alt-sel-mode", "100"); # AVAIL MODES : 100 1000
            
            # AUTO-THROTTLE
            
            setprop(fmgc~ "spd-mode", "ias"); # AVAIL MODES : ias mach
            setprop(fmgc~ "spd-ctrl", "man-set"); # AVAIL MODES : --- fmgc man-set
            
            setprop(fmgc~ "a-thr/ias", 0);
            setprop(fmgc~ "a-thr/mach", 0);
            
            setprop(fmgc~ "fmgc/ias", 0);
            setprop(fmgc~ "fmgc/mach", 0);
            
            # AUTOPILOT (LATERAL)
            
            setprop(fmgc~ "lat-mode", "hdg"); # AVAIL MODES : hdg nav1
            setprop(fmgc~ "lat-ctrl", "man-set"); # AVAIL MODES : --- fmgc man-set
            
            # AUTOPILOT (VERTICAL)
            
            setprop(fmgc~ "ver-mode", "alt"); # AVAIL MODES : alt (vs/fpa) ils
            setprop(fmgc~ "ver-sub", "vs"); # AVAIL MODES : vs fpa
            setprop(fmgc~ "ver-ctrl", "man-set"); # AVAIL MODES : --- fmgc man-set
            
            # FLIGHT DIRECTOR
            setprop(fmgc~ "fd", "off");
            
            # AUTOPILOT (MASTER)
            
            setprop(fmgc~ "ap1-master", "off");
            setprop(fmgc~ "ap2-master", "off");
            setprop(fmgc~ "a-thrust", "off");
            
            # Rate/Load Factor Configuration
            
            setprop(settings~ "pitch-norm", 0.1);
            setprop(settings~ "roll-norm", 0.2);
            
            # Terminal Procedure
            
            # setprop("/flight-management/procedures/active", "off"); # AVAIL MODES : off sid star iap
            
            # Terminal Procedures are integrated into the flightplan system
            
            # Set Flight Control Unit Initial Values
            
            setprop(fcu~ "ias", 250);
            setprop(fcu~ "mach", 0.78);
            
            setprop(fcu~ "alt", 10000);
            setprop(fcu~ "vs", 1800);
            setprop(fcu~ "fpa", 5);
            
            setprop(fcu~ "hdg", 0);
            
            setprop(fmgc_val~ "ias", 250);
            setprop(fmgc_val~ "mach", 0.78);
            
            # Servo Control Settings
            
            setprop(servo~ "aileron", 0);
            setprop(servo~ "aileron-nav1", 0);
            setprop(servo~ "target-bank", 0);
            
            setprop(servo~ "elevator-vs", 0);
            setprop(servo~ "elevator", 0);
            setprop(servo~ "target-pitch", 0);
            
            me.timer = maketimer(me.UPDATE_INTERVAL, me, me.update);
            me.timer.start();
    },
    	update : func {
    	
    	# Active flightplan waypoint transition
    	
    	if(active_fpln.active == 1) {
    		active_fpln.transit();
    	}
    	
    	var altitude = getprop("/instrumentation/altimeter/indicated-altitude-ft");
    	
    	me.flight_phase();
    	
    	# FIXME
    	
    	me.get_settings();
    	
    	me.lvlch_check();
    	
    	me.knob_sum();
    	
    	me.hdg_disp();
    	
    	me.fcu_lights();
    	
    	setprop(fcu~ "alt-100", me.alt_100());
    	
    	# SET OFF IF NOT USED
    	
    	if (me.lat_ctrl != "fmgc") {
    	
    		setprop("/flight-management/hold/init", 0);
    	
    	}
    	
    	# Turn off rudder control when AP is off
    	
    	if ((me.ap1 == "off") and (me.ap2 == "off")) {
    		setprop("/autoland/rudder", 0);
    		setprop("/autoland/phase", "disengaged")
    	}
    	
    	if ((me.spd_ctrl == "off") or (me.a_thr == "off")) {
    	
    		setprop(fmgc~ "a-thr/ias", 0);
            setprop(fmgc~ "a-thr/mach", 0);
            
            setprop(fmgc~ "fmgc/ias", 0);
            setprop(fmgc~ "fmgc/mach", 0);
    	
    	}
    	
    	if ((me.lat_ctrl == "off") or ((me.ap1 == "off") and (me.ap2 == "off"))) {
    	
    		setprop(servo~ "aileron", 0);
    		setprop(servo~ "aileron-nav1", 0);
            setprop(servo~ "target-bank", 0);
    	
    	}
    	
    	if ((me.ver_ctrl == "off") or ((me.ap1 == "off") and (me.ap2 == "off"))) {
    	
    		setprop(servo~ "elevator-vs", 0);
    		setprop(servo~ "elevator-gs", 0);
    		setprop(servo~ "elevator", 0);
            setprop(servo~ "target-pitch", 0);
    	
    	}
    	
    	# MANUAL SELECT MODE ===================================================

		## AUTO-THROTTLE -------------------------------------------------------
    	
    	if ((me.spd_ctrl == "man-set") and (me.a_thr == "eng")) {
    	
    		if (me.spd_mode == "ias") {
    		
    			setprop(fmgc~ "a-thr/ias", 1);
    			setprop(fmgc~ "a-thr/mach", 0);
    			
    			setprop(fmgc~ "fmgc/ias", 0);
            	setprop(fmgc~ "fmgc/mach", 0);
    		
    		} else {
    		
    			setprop(fmgc~ "a-thr/ias", 0);
    			setprop(fmgc~ "a-thr/mach", 1);
    			
    			setprop(fmgc~ "fmgc/ias", 0);
        	    setprop(fmgc~ "fmgc/mach", 0);
    		
    		}
    		
    		# Help slow down with speed-brakes
    		# getprop("/instrumentation/airspeed-indicator/indicated-speed-kt")
    		# var spd_lookahead = getprop("/instrumentation/pfd/speed-lookahead");
    		# if((spd_lookahead > getprop(fcu~"ias") + 5) and (getprop("/controls/engines/engine/throttle") < 0.02)) {
    		#	var spd_brk_cmd = (spd_lookahead - 5 - getprop(fcu~"ias"))/35;
    		#	if(spd_brk_cmd > 1) {
    		#		spd_brk_cmd = 1;
    		#	}
    		#	setprop("/controls/flight/speedbrake-add", spd_brk_cmd);
    		# } else {
    		#	if((getprop("/controls/flight/speedbrake") < 1 ) and (getprop("/controls/flight/speedbrake") > 0)) {
    		#		setprop("/controls/flight/speedbrake", 0);
    		#	}
    		# }
    	
    	}
    	
    	if ((me.ap1 == "eng") or (me.ap2 == "eng")) {
    	
    	## LATERAL CONTROL -----------------------------------------------------
    	
    	if (me.lat_ctrl == "man-set") {
    	
    		if (me.lat_mode == "hdg") {
    		
    			# Find Heading Deflection
    			
    			var bug = getprop(fcu~ "hdg");
    			
    			var bank = -1 * defl(bug, 20);
    			
    			var deflection = defl(bug, 180);
    			
    			
    			setprop(servo~  "aileron", 1);
    			setprop(servo~ "aileron-nav1", 0);
    			
    			if (math.abs(deflection) <= 1)
    				setprop(servo~ "target-bank", 0);
    			else
    				setprop(servo~ "target-bank", bank);
    		
    		} elsif (me.lat_mode == "nav1") {
    		
    			var nav1_error = getprop("/autopilot/internal/nav1-track-error-deg");
    			
    			var agl = getprop("/position/altitude-agl-ft");
    			
    			var bank = limit(nav1_error*2, 30);
    			
    			if (agl < 100) {
    			
    				bank = 0; # Level the wings for AUTOLAND
    				
    				setprop(servo~ "target-rudder", bank);	
    				
    			}
    			
    			setprop(servo~ "aileron", 0);
    			
    			setprop(servo~ "aileron-nav1", 1); 	
    			
    			setprop(servo~ "target-bank", bank);
    		
    		} # else, this is handed over from fcu to fmgc
    	
    	}
    	
    	## VERTICAL CONTROL ----------------------------------------------------
    	
    	var vs_setting = getprop(fcu~ "vs");
    	
    	var fpa_setting = getprop(fcu~ "fpa");
    	
    	if (me.ver_ctrl == "man-set") {
    	
    		if (me.ver_mode == "alt-hold") {
    		
    			var target = getprop(fmgc_val~"alt-hold-ft");
    			
    			var trgt_vs = 0;
    				
				if (((altitude - target) * vs_setting) > 0) {
				
					trgt_vs = limit((target - altitude) * 2, 200);
				
				} else {
			
					trgt_vs = limit2((target - altitude) * 2, vs_setting);
				
				}
				
				setprop(servo~ "target-vs", trgt_vs / 60);
				
				setprop(servo~ "elevator-vs", 1);
				
				setprop(servo~ "elevator", 0);
				
				setprop(servo~ "elevator-gs", 0);
    		
    		} elsif (me.ver_mode == "alt") {
    		
    			if (me.ver_sub == "vs") {
    		
    				var target = getprop(fcu~ "alt");
    				
    				var trgt_vs = 0;
    				
    				if (((altitude - target) * vs_setting) > 0) {
    				
    					trgt_vs = limit((target - altitude) * 2, 200);
    				
    				} else {
    			
    					trgt_vs = limit2((target - altitude) * 2, vs_setting);
    				
    				}
    				
    				setprop(servo~ "target-vs", trgt_vs / 60);
    				
    				setprop(servo~ "elevator-vs", 1);
    				
    				setprop(servo~ "elevator", 0);
    				
    				setprop(servo~ "elevator-gs", 0);
    				
    			} else {
    			
    				var target_alt = getprop(fcu~ "alt");
    				
    				var trgt_fpa = limit2((target_alt - altitude) * 2, fpa_setting);
    				
    				setprop(servo~ "target-pitch", trgt_fpa);
    				
    				setprop(servo~ "elevator-vs", 0);
    				
    				setprop(servo~ "elevator", 1);
    				
    				setprop(servo~ "elevator-gs", 0);
    			
    			}
    		
    		} elsif (me.ver_mode == "ils") {
    		
    			# Main stuff are done on the PIDs
    			
    			autoland.phase_check();
    			
    			var agl = getprop("/position/altitude-agl-ft");
    			
    			# if (agl > 100) {
    			
    			# Using 1000 ft for the early descent scenario
    			
    			if (agl > 100) {
    			
    				setprop(servo~ "elevator-gs", 1);
    				
    				setprop(servo~ "elevator-vs", 0);
    			
    			} else {
    			
    				setprop(servo~ "elevator-gs", 0);
    				
    				setprop(servo~ "elevator-vs", 1);
    			
    			}
    				
    			setprop(servo~ "elevator", 0);
    		    		
    		}
    	
    	} # End of Manual Setting Check
    	
    	} # End of AP1 Master Check
    	
    	# FMGC CONTROL MODE ====================================================
    	
    	if ((me.spd_ctrl == "fmgc") and (me.a_thr == "eng")) {
    	
    	## AUTO-THROTTLE -------------------------------------------------------
    	
    	var agl = getprop("/position/altitude-agl-ft");
    	
    	if ((me.ver_mode == "ils") and (agl < 3000) and (getprop("/flight-management/spd-manager/approach/mode") == "MANAGED (AUTO)")) {

    		setprop(fmgc~ "fmgc/ias", 1);
    		setprop(fmgc~ "fmgc/mach", 0);
    		
    		setprop(fmgc~ "a-thr/ias", 0);
		    setprop(fmgc~ "a-thr/mach", 0);
    	
    	} else {
    	
    		if (((getprop("/flight-management/phase") == "CLB") and (getprop("/flight-management/spd-manager/climb/mode") == "MANAGED (F-PLN)")) or ((getprop("/flight-management/phase") == "CRZ") and (getprop("/flight-management/spd-manager/cruise/mode") == "MANAGED (F-PLN)")) or ((getprop("/flight-management/phase") == "DES") and (getprop("/flight-management/spd-manager/descent/mode") == "MANAGED (F-PLN)")) and (me.ver_mode != "ils")) {
    	
			var spd = 250;
			
			if(active_fpl.active == 1) {
				spd = active_fpln.getTargetSpeed();
			}
			
			if (spd == nil) {
			
				if (altitude <= 20000)
					spd = 250;
				else
					spd = 0.78;
			
			}
			
			setprop(fmgc_val~ "target-spd", spd);
			
			}
			
			# Performance and Automatic Calculated speeds from the PERF page on the mCDU are managed separately
			
			manage_speeds();
			
			setprop(fmgc~ "a-thr/ias", 0);
		    setprop(fmgc~ "a-thr/mach", 0);
			
			var spd = getprop(fmgc_val~ "target-spd");
			
			if (spd == nil) {
			
				if (altitude <= 10000)
					spd = 250;
				else
					spd = 0.78;
			
			}
			
			if (spd < 1) {
			
				setprop(fmgc~ "fmgc/ias", 0);
		        setprop(fmgc~ "fmgc/mach", 1);
			
			} else {
			
				setprop(fmgc~ "fmgc/ias", 1);
		        setprop(fmgc~ "fmgc/mach", 0);
			
			}
    	
    	}
    	
    	}
    	
    	if ((me.ap1 == "eng") or (me.ap2 == "eng")) {
    	
    	## LATERAL CONTROL -----------------------------------------------------
    	
    	if (me.lat_ctrl == "fmgc") {
    	
    		# If A procedure's NOT being flown, we'll fly the active F-PLN (unless it's a hold pattern)
    		
			if (((getprop("/flight-management/hold/wp_id") == getprop("/flight-management/current-wp")) or (getprop("/flight-management/hold/init") == 1)) and (getprop("/flight-management/hold/wp_id") != 0)) {
			
#				if (getprop("/flight-management/hold/init") != 1) {
					
#					hold_pattern.init();
				
#				} else {
				
#					if (getprop("/flight-management/hold/phase") == 5) {
					
#						hold_pattern.entry();
						
#					} else {
						
#						hold_pattern.transit();
					
#					}
					
					# Now, fly the actual hold
					
					# var bug = getprop("/flight-management/hold/fly/course");
			
					# var bank = -1 * defl(bug, 30);
				
					# var deflection = defl(bug, 180);
				
					var deflection = getprop("/autopilot/internal/true-heading-error-deg");
					
					var bank = 0;
					
					if(getprop("/velocities/groundspeed-kt") > 270) {
						if(deflection < -15) {
							bank = -15;
						} elsif(deflection > 15) {
							bank = 15;
						} else {
							bank = deflection;
						}
					} else {
						if(deflection < -10) {
							bank = -25;
						} elsif(deflection > 10) {
							bank = 25;
						} else {
							bank = deflection*2.5;
						}
					}
				
				
					setprop(servo~  "aileron", 1);
					setprop(servo~ "aileron-nav1", 0);
				
					# if (math.abs(deflection) <= 0.5)
					# 	setprop(servo~ "target-bank", 0);
					# else
						setprop(servo~ "target-bank", bank);
				
#				}
			
			} else {
			
				setprop("/flight-management/hold/init", 0);
		
				var bug = 0;
				
				if(active_fpln.active == 1) {
					bug = active_fpln.getHdgToFollow();
				}
		
				var accuracy = getprop(settings~ "gps-accur");

				var bank = 0; 
		
				if (accuracy == "HIGH")
					bank = limit(bug, 25);
				else
					bank = limit(bug, 15);
		
				setprop(servo~  "aileron", 1);
		
				setprop(servo~ "aileron-nav1", 0);
		
				setprop(servo~ "target-bank", bank);
		
			}
			
			# Procedures are added to the flightplan
    	
    	}
    	
    	## VERTICAL CONTROL ----------------------------------------------------

		if (me.ver_ctrl == "fmgc") {
			
			var target_fps = 0;
			
			if(active_fpln.active == 1) {
				target_fps = active_fpln.getTargetVS();
			}
			
			var	final_vs = limit(target_fps, 50);
			
			setprop(servo~ "target-vs", final_vs);
    				
			setprop(servo~ "elevator-vs", 1);
			
			setprop(servo~ "elevator", 0);
			
			setprop(servo~ "elevator-gs", 0);
			
		}
		
		} # End of AP1 MASTER CHECK

	},
		get_settings : func {
		
		me.spd_mode = getprop(fmgc~ "spd-mode");
		me.spd_ctrl = getprop(fmgc~ "spd-ctrl");
		
		me.lat_mode = getprop(fmgc~ "lat-mode");
		me.lat_ctrl = getprop(fmgc~ "lat-ctrl");
		
		me.ver_mode = getprop(fmgc~ "ver-mode");
		me.ver_ctrl = getprop(fmgc~ "ver-ctrl");
		
		me.ver_sub = getprop(fmgc~ "ver-sub");
		
		me.ap1 = getprop(fmgc~ "ap1-master");
		me.ap2 = getprop(fmgc~ "ap2-master");
		me.a_thr = getprop(fmgc~ "a-thrust");
		me.fd = getprop(fmgc~ "fd");
	
	},
	
		lvlch_check : func {
		
		if ((me.ap1 == "eng") or (me.ap2 == "eng")) {
		
			var vs_fps = getprop("/velocities/vertical-speed-fps");
		
			if (math.abs(vs_fps) > 8)
				setprop("/flight-management/fcu/level_ch", 1);
			else
				setprop("/flight-management/fcu/level_ch", 0);
		
		} else
			setprop("/flight-management/fcu/level_ch", 0);
		
	},
	
		knob_sum : func {

		var ias = getprop(fcu~ "ias");
		
		var mach = getprop(fcu~ "mach");
		
		setprop(fcu~ "spd-knob", ias + (100 * mach));
		
		var vs = getprop(fcu~ "vs");
		
		var fpa = getprop(fcu~ "fpa");
		
		setprop(fcu~ "vs-knob", fpa + (vs/100));
		
	},
		hdg_disp : func {
		
		var hdg = getprop(fcu~ "hdg");
		
		if (hdg < 10)
			setprop(fcu~ "hdg-disp", "00" ~ hdg);
		elsif (hdg < 100)
			setprop(fcu~ "hdg-disp", "0" ~ hdg);
		else
			setprop(fcu~ "hdg-disp", "" ~ hdg);
		
	},
	
		fcu_lights : func {
		
		if (me.lat_mode == "nav1")
			setprop(fmgc~ "fcu/nav1", 1);
		else
			setprop(fmgc~ "fcu/nav1", 0);
			
		if (me.ver_mode == "ils")
			setprop(fmgc~ "fcu/ils", 1);
		else
			setprop(fmgc~ "fcu/ils", 0);
			
		if (me.ver_mode == "alt-hold")
			setprop(fmgc~ "fcu/alt", 1);
		else
			setprop(fmgc~ "fcu/alt", 0);
			
		if (me.a_thr == "eng")
			setprop(fmgc~ "fcu/a-thrust", 1);
		else
			setprop(fmgc~ "fcu/a-thrust", 0);
			
		if (me.ap1 == "eng")
			setprop(fmgc~ "fcu/ap1", 1);
		else
			setprop(fmgc~ "fcu/ap1", 0);
			
		if (me.fd == "eng")
			setprop(fmgc~ "fcu/fd", 1);
		else
			setprop(fmgc~ "fcu/fd", 0);
			
		if (me.ap2 == "eng")
			setprop(fmgc~ "fcu/ap2", 1);
		else
			setprop(fmgc~ "fcu/ap2", 0);
		
		
		
	},
	
		alt_100 : func {
		
		var alt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
		
		return int(alt/100);
		
	},
	
		flight_phase : func {
		
		var phase = getprop("/flight-management/phase");
		
		if ((phase == "T/O") and (!getprop("/gear/gear[3]/wow"))) {
		
			setprop("/flight-management/phase", "CLB");
		
		} elsif (phase == "CLB") {
		
			if(!getprop("/gear/gear[3]/wow")) {
		
				var crz_fl = getprop("/flight-management/crz_fl");
			
				if (crz_fl != 0) {
			
					if (getprop("/position/altitude-ft") >= ((crz_fl * 100) - 500))
						setprop("/flight-management/phase", "CRZ");
			
				} else {
			
					if (getprop("/position/altitude-ft") > 26000)
						setprop("/flight-management/phase", "CRZ");
			
				}
				
			} else {
				setprop("/flight-management/phase", "T/O");
			}
		
		} elsif (phase == "CRZ") {
		
			var crz_fl = getprop("/flight-management/crz_fl");
			
			if (crz_fl != 0) {
			
				if (getprop("/position/altitude-ft") < ((crz_fl * 100) - 500))
					setprop("/flight-management/phase", "DES");
			
			} else {
			
				if (getprop("/position/altitude-ft") < 26000)
					setprop("/flight-management/phase", "DES");
			
			}
		
		} elsif ((phase == "DES") and (getprop("/position/altitude-ft") <= 3000 or getprop("/flight-management/control/ver-mode") == "ils")) {
		
			setprop("/flight-management/phase", "APP");
		
		} elsif (((phase == "APP") or (phase == "DES")) and (getprop("/gear/gear/wow"))) {
		
			setprop("/flight-management/phase", "T/O");
			
			new_flight();
			
			me.current_wp = 0;
		
		}
		
	}

};

setlistener("sim/signals/fdm-initialized", func
 {
 fmgc_loop.init();
 print("Flight Management and Guidance Computer Initialized");
 });
