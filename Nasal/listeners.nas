# A380 systems
# S.Hamilton and N.Muraleedharan
# NOTE - I've removed a lot of the older instrument based code as I've made new instruments with their own scripts. ~Naru

setprop("/controls/lighting/emer-exit-lt", 0);

for(var n=0; n<5; n=n+1) {
	setprop("/engines/engine["~n~"]/fuel-used-kg", 0);
}

var beacon_switch = props.globals.getNode("controls/switches/beacon", 2);
var beacon = aircraft.light.new("sim/model/lights/beacon", [0.015, 3], "controls/lighting/beacon");

var strobe_switch = props.globals.getNode("controls/switches/strobe", 2);
var strobe = aircraft.light.new("sim/model/lights/strobe", [0.025, 1.5], "controls/lighting/strobe");

# Control slats and flaps together - F1 = Slat full
setlistener("/controls/flight/flaps", func(n) {
	var flaps = n.getValue();
	
	if(flaps > 0) {
		setprop("/fdm/jsbsim/fcs/slat-cmd-norm", 1);
	} else {
		setprop("/fdm/jsbsim/fcs/slat-cmd-norm", 0);
	}
});

init_controls = func {
  setprop("/engines/engine[4]/off-start-run",0);     # APU state, 0=OFF, 1=START, 2=RUN
  setprop("/controls/engines/engine[0]/master",0);
  setprop("/controls/engines/engine[1]/master",0);
  setprop("/controls/engines/engine[2]/master",0);
  setprop("/controls/engines/engine[3]/master",0);
  setprop("/controls/engines/engine[0]/thrust-lever",0);
  setprop("/controls/engines/engine[1]/thrust-lever",0);
  setprop("/controls/engines/engine[2]/thrust-lever",0);
  setprop("/controls/engines/engine[3]/thrust-lever",0);
  setprop("/environment/turbulence/use-cloud-turbulence","true");
  setprop("/sim/current-view/field-of-view",60.0);
  setprop("/controls/gear/brake-parking",1.0);
  setprop("/controls/engines/ign-start",0);        # the IGN start switch on the OH
  setprop("/controls/APU/run",0);                  # what should we do with the APU (engine[4])
  setprop("/systems/electrical/apu-test",0);
  setprop("/instrumentation/annunciator/master-caution",0.0);
  setprop("/instrumentation/switches/seat-belt-sign",0.0);
  setprop("/surface-positions/speedbrake-pos-norm",0.0);
  setprop("/instrumentation/wxradar/display-mode",2);   #is 'arc'
  setprop("/velocities/vls-factor", 1.23);

  #payload - Crew, PAX, Cargo
  setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[0]",350);
  setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[1]",48420);
  setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[2]",28350);
  setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[3]",21000);
  setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[4]",14328);
  setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[5]",1200);

  setprop("/systems/electrical/apu-test",0);
}
# UPDATE ENGINES
update_engines = func {

  ### APU stuff  
  var apuN1 = getprop("/engines/engine[4]/n1");
  var hz = apuN1*20;
  setprop("/engines/engine[4]/gena-hz", hz);
  setprop("/engines/engine[4]/genb-hz", hz);
  # update APU status and start/stop APU  
  apu_state = getprop("/engines/engine[4]/off-start-run");
  if (apu_state == 1) {
    start_apu();
  }
  if (apu_state == 2 and getprop("/engines/engine[4]/cutoff") == 1 and getprop("/engines/engine[4]/n2") < 50) {
    setprop("/engines/engine[4]/off-start-run",0);
  }
  var apuN2 = getprop("/engines/engine[4]/n2");
  if (apuN2 == nil) {
    apuN2 = 0.0;
  }
  if (apuN2 > 50) {
    if (getprop("/controls/pneumatic/APU-bleed") == 0) {
      setprop("/controls/pneumatic/APU-bleed",1);
    }
  } else {
    if (getprop("/controls/pneumatic/APU-bleed") == 1) {
      setprop("/controls/pneumatic/APU-bleed",0);
    }
  }
  var apu_egtF = getprop("/engines/engine[4]/egt-degf");
  apu_egtC = (5/9)*(apu_egtF-32);
  setprop("/engines/engine[4]/egt_degc",apu_egtC);

  # Set APU Start Indicator Light property
  if(apu_state == 0) { # OFF
  	setprop("/controls/APU/start-indicator", 0);
  } elsif (apu_state == 1) { # STARTING
  	setprop("/controls/APU/start-indicator", 1);
  } else { # AVAIL
  	if(getprop("/controls/APU/start") == 1) {
  		setprop("/controls/APU/start-indicator", 2);
  	} else {
  		setprop("/controls/APU/start-indicator", 3);
  	}
  }

  # update status of WOW so we only get 1 event in the listener
  wow = getprop("/instrumentation/gear/wow");
  wow1 = getprop("/gear/gear[1]/wow");
  wow2 = getprop("/gear/gear[2]/wow");
  if ((wow1 != wow) or (wow2 != wow)) {
    if (wow1 != wow) {
      setprop("/instrumentation/gear/wow",wow1);
    } else {
      setprop("/instrumentation/gear/wow",wow2);
    }
  }

  settimer(update_engines, 0.60);  
}

setlistener("instrumentation/altimeter/indicated-altitude-ft", func(n) {
	var alt = n.getValue();
	if(alt != nil) {
		setprop("flight-management/fcu-values/alt-100", alt/100);
	} 
});

start_apu = func {
  n2 = getprop("/engines/engine[4]/n2");
  if (n2 > 25 and n2 < 27 and getprop("/controls/engines/engine[4]/cutoff") == 1) {
    setprop("/controls/engines/engine[4]/cutoff",0);
  }
  if (n2 > 25 and n2 < 50) {
    setprop("/controls/engines/engine[4]/ignition",1);
    #setprop("/controls/engines/engine[4]/starter",0);
    #setprop("/controls/engines/engine[4]/bleed",1);
  }
  if (n2 > 50) {
    setprop("/controls/engines/engine[4]/ignition",0);
    ##setprop("/controls/engines/engine[4]/starter",0);
    setprop("/engines/engine[4]/off-start-run",2);
    setprop("/controls/electric/engine[4]/generator", 1);
    setprop("/controls/electric/engine[4]/bus-tie", 1);
    setprop("/controls/electric/APU-generator", 1);
  }

}


# TOGGLE REVERSER
togglereverser = func {
  r1 = "/controls/engines/engine[1]"; 
  r2 = "/controls/engines/engine[2]"; 
  rv1 = "/surface-positions/reverser-pos-norm"; 

  val = getprop(rv1);
  if (val == 0 or val == nil) {
    interpolate(rv1, 1.0, 1.4);  
    setprop(r1,"reverser","true");
    setprop(r2,"reverser", "true");
  } else {
    if (val == 1.0){
      interpolate(rv1, 0.0, 1.4);  
      setprop(r1,"reverser",0);
      setprop(r2,"reverser",0);
    }
  }
}

## FDM init
setlistener("/sim/signals/fdm-initialized", func {
 update_engines();
 print("General Aircraft Systems Initialized");
});

setlistener("/controls/engines/ign-start", func(n) {
	if(getprop("/systems/electric/outputs/eng-starter") == 1) {
		setprop("/controls/engines/engine[0]/starter",1);
		setprop("/controls/engines/engine[1]/starter",1);
		setprop("/controls/engines/engine[2]/starter",1);
		setprop("/controls/engines/engine[3]/starter",1);
	}
});

# once we have engine bleed, open air valve
setlistener("/controls/pneumatic/engine[0]/bleed", func(n) {
  bleed = n.getValue();
  if (bleed == 1) {
    setprop("/controls/pressurization/apu/bleed-on",0);
    setprop("/controls/pressurization/engine[0]/bleed-on",1);
  } else {
    setprop("/controls/pressurization/engine[0]/bleed-on",0);
    setprop("/controls/pressurization/pack[0]/pack-on", 0);
  }
});

# once we have engine bleed open air valve
setlistener("/controls/pneumatic/engine[1]/bleed", func(n) {
  bleed = n.getValue();
  if (bleed == 1) {
    setprop("/controls/pressurization/apu/bleed-on",0);
    setprop("/controls/pressurization/engine[1]/bleed-on",1);
  } else {
    setprop("/controls/pressurization/engine[1]/bleed-on",0);
    setprop("/controls/pressurization/pack[0]/pack-on", 0);
  }
});

# once we have engine bleed open air valve
setlistener("/controls/pneumatic/engine[2]/bleed", func(n) {
  bleed = n.getValue();
  if (bleed == 1) {
    setprop("/controls/pressurization/apu/bleed-on",0);
    setprop("/controls/pressurization/engine[2]/bleed-on",1);
  } else {
    setprop("/controls/pressurization/engine[2]/bleed-on",0);
    setprop("/controls/pressurization/pack[1]/pack-on", 0);
  }
});

# once we have engine bleed open air valve
setlistener("/controls/pneumatic/engine[3]/bleed", func(n) {
  bleed = n.getValue();
  if (bleed == 1) {
    setprop("/controls/pressurization/apu/bleed-on",0);
    setprop("/controls/pressurization/engine[3]/bleed-on",1);
  } else {
    setprop("/controls/pressurization/engine[3]/bleed-on",0);
    setprop("/controls/pressurization/pack[1]/pack-on", 0);
  }
});


# control APU bleed air to pressurisation
setlistener("/controls/pneumatic/APU-bleed", func(n) {
  bleed = n.getValue();
  if (bleed == 1) {
    setprop("/controls/pressurization/apu/bleed-on",1);
  } else {
    setprop("/controls/pressurization/apu/bleed-on",0);
  }
});


# control HOT-AIR valves from AIR PACKS
setlistener("/controls/pressurization/pack[0]/pack-on", func(n) {
   var pack = n.getValue();
   if (pack == 1) {
     settimer(open_hotair, 1);
     var currBleed = getprop("fdm/jsbsim/propulsion/engine[0]/bleed-factor");
     setprop("fdm/jsbsim/propulsion/engine[0]/bleed-factor", currBleed+0.1);
     currBleed = getprop("fdm/jsbsim/propulsion/engine[1]/bleed-factor");
     setprop("fdm/jsbsim/propulsion/engine[1]/bleed-factor", currBleed+0.1);
   } else {
     setprop("/controls/pressurization/pack[0]/hotair-on",0);
     var currBleed = getprop("fdm/jsbsim/propulsion/engine[0]/bleed-factor");
     if (currBleed > 0) {
       setprop("fdm/jsbsim/propulsion/engine[0]/bleed-factor", currBleed-0.1);
     }
     currBleed = getprop("fdm/jsbsim/propulsion/engine[1]/bleed-factor");
     if (currBleed > 0) {
       setprop("fdm/jsbsim/propulsion/engine[1]/bleed-factor", currBleed-0.1);
     }
   }
});


setlistener("/controls/pressurization/pack[1]/pack-on", func(n) {
   var pack = n.getValue();
   if (pack == 1) {
     settimer(open_hotair, 1);
     var currBleed = getprop("fdm/jsbsim/propulsion/engine[2]/bleed-factor");
     setprop("fdm/jsbsim/propulsion/engine[2]/bleed-factor", currBleed+0.1);
     currBleed = getprop("fdm/jsbsim/propulsion/engine[3]/bleed-factor");
     setprop("fdm/jsbsim/propulsion/engine[3]/bleed-factor", currBleed+0.1);
   } else {
     setprop("/controls/pressurization/pack[1]/hotair-on",0);
     var currBleed = getprop("fdm/jsbsim/propulsion/engine[2]/bleed-factor");
     if (currBleed > 0) {
       setprop("fdm/jsbsim/propulsion/engine[2]/bleed-factor", currBleed-0.1);
     }
     currBleed = getprop("fdm/jsbsim/propulsion/engine[3]/bleed-factor");
     if (currBleed > 0) {
       setprop("fdm/jsbsim/propulsion/engine[3]/bleed-factor", currBleed-0.1);
     }
   }
});

open_hotair = func() {
  if (getprop("/controls/pressurization/pack[0]/pack-on") == 1) {
    setprop("/controls/pressurization/pack[0]/hotair-on",1);
  }
  if (getprop("/controls/pressurization/pack[1]/pack-on") == 1) {
    setprop("/controls/pressurization/pack[1]/hotair-on",1);
  }
}

# APU Controller

setlistener("/controls/APU/master-switch", func(n) {
	apu_master = n.getValue();
	if(apu_master == 0) {
		setprop("/controls/engines/engine[4]/cutoff",1);
	        setprop("/controls/pneumatic/APU-bleed",0);
	        setprop("/engines/engine[4]/off-start-run", 0);
	        setprop("/controls/APU/start", 0);
	}
	apu_start = getprop("/controls/APU/start");
	apu_mode = getprop("/engines/engine[4]/off-start-run");
	if(apu_mode == 0) {
		# OFF
		if(apu_master == 1 and apu_start == 1) {
			setprop("/engines/engine[4]/off-start-run", 1);
		}
	} elsif (apu_mode == 1) {
		# START
		if(apu_start == 0) {
			setprop("/engines/engine[4]/off-start-run", 0);
		}
	}	
});

setlistener("/controls/APU/start", func(n) {
	setprop("/controls/engines/engine[4]/starter",n.getValue());
	setprop("/controls/engines/engine[4]/ignition",n.getValue());
	apu_master = getprop("/controls/APU/master-switch");
	if(apu_master == 0) {
		setprop("/controls/engines/engine[4]/cutoff",1);
	        setprop("/controls/pneumatic/APU-bleed",0);
	        setprop("/engines/engine[4]/off-start-run", 0);
	        setprop("/controls/APU/start", 0);
	}
	apu_start = n.getValue();
	apu_mode = getprop("/engines/engine[4]/off-start-run");
	if(apu_mode == 0) {
		# OFF
		if(apu_master == 1 and apu_start == 1) {
			setprop("/engines/engine[4]/off-start-run", 1);
		}
	} elsif (apu_mode == 1) {
		# START
		if(apu_start == 0) {
			setprop("/engines/engine[4]/off-start-run", 0);
		}
	}
});

setlistener("/controls/switches/seat-belt", func(n) {
  seat = n.getValue();
  ## seat belt switch to off
  if (seat == 0) {
    setprop("/instrumentation/switches/seatbelt-sign",0);
  }
  ## seat belt switch set to auto
  if (seat == 1) {
    if (getprop("/instrumentation/altimeter/indicated-altitude-ft") <10000 ) {
      setprop("/instrumentation/switches/seatbelt-sign",1);
    }
  }
  ## seat belt switch set to on
  if (seat == 2) {
    setprop("/instrumentation/switches/seatbelt-sign",1);
  }
});

setlistener("/controls/anti-ice/engine[0]/inlet-heat", func(n) {
   var anti = 0;
   var currBleed = getprop("fdm/jsbsim/propulsion/engine[0]/bleed-factor");
   var heat = n.getValue();
   if (heat == 0) {
     anti = -0.12;
     if (currBleed == 0) {
       anti = 0.0;
     }
   } else {
     anti = 0.12;
   }
   setprop("fdm/jsbsim/propulsion/engine[0]/bleed-factor", currBleed+anti);
});

setlistener("/controls/anti-ice/engine[1]/inlet-heat", func(n) {
   var anti = 0;
   var currBleed = getprop("fdm/jsbsim/propulsion/engine[1]/bleed-factor");
   if (n.getValue() == 0) {
     anti = -0.12;
     if (currBleed == 0) {
       anti = 0.0;
     }
   } else {
     anti = 0.12;
   }
   setprop("fdm/jsbsim/propulsion/engine[1]/bleed-factor", currBleed+anti);
});

setlistener("/controls/anti-ice/engine[2]/inlet-heat", func(n) {
   var anti = 0;
   var currBleed = getprop("fdm/jsbsim/propulsion/engine[2]/bleed-factor");
   if (n.getValue() == 0) {
     anti = -0.12;
     if (currBleed == 0) {
       anti = 0.0;
     }
   } else {
     anti = 0.12;
   }
   setprop("fdm/jsbsim/propulsion/engine[2]/bleed-factor", currBleed+anti);
});

setlistener("/controls/anti-ice/engine[3]/inlet-heat", func(n) {
   var anti = 0;
   var currBleed = getprop("fdm/jsbsim/propulsion/engine[3]/bleed-factor");
   if (n.getValue() == 0) {
     anti = -0.12;
     if (currBleed == 0) {
       anti = 0.0;
     }
   } else {
     anti = 0.12;
   }
   setprop("fdm/jsbsim/propulsion/engine[3]/bleed-factor", currBleed+anti);
});

# Gear Animation Helpers
var compr = func(n) {
	var cmpr = getprop("/fdm/jsbsim/gear/unit["~n~"]/compression-ft");
	if(cmpr > 5) {
		return 5;
	} else {
		return cmpr;
	}
}

var WOW = func(n) {
	return getprop("/fdm/jsbsim/gear/unit["~n~"]/WOW");
}

var getZ = func(n) {
	# var zPos = 
	return getprop("fdm/jsbsim/gear/unit["~n~"]/z-position");
	# if(zPos != nil) {
	# 	return zPos;
	# } else {
	# 	return -365;
	# }
}

var setZ = func(n, z) {
	setprop("fdm/jsbsim/gear/unit["~n~"]/z-position", z);
}

var gear_helpers = {
	zero: func() {
			setprop("/gear/mlg_fl/c_bar", 0);
			setprop("/gear/mlg_fr/c_bar", 0);
			setprop("/gear/mlg_rl/c_bar", 0);
			setprop("/gear/mlg_rr/c_bar", 0);
	},
	mlg_tilt: func(name, fwd, aft, zFwd, zBar, zAft, rodLength, relax) {
		# Calculate c_bar (net compression)
		if(WOW(aft) and !WOW(fwd)) { # Only Aft wheels in contact with ground
			setprop("/gear/"~name~"/c_bar", 0);
			if(getZ(fwd) > zFwd) {
				if(compr(aft)<2) {
					setZ(aft,getZ(aft)+compr(aft));
					setZ(fwd,getZ(fwd)-compr(aft));
				} else {
					setZ(aft,getZ(aft)+2);
					setZ(fwd,getZ(fwd)-2);
				}
			}
		} elsif(!WOW(aft) and WOW(fwd)) { # Only the forward wheels are in contact
			setprop("/gear/"~name~"/c_bar", 0);
			if(getZ(aft) > zAft) {
				if(compr(fwd)<2) {
					setZ(aft,getZ(aft)-compr(fwd));
					setZ(fwd,getZ(fwd)+compr(fwd));
				} else {
					setZ(aft,getZ(aft)-2);
					setZ(fwd,getZ(fwd)+2);
				}
			}
		} elsif(WOW(aft) and WOW(fwd)) { # Both wheels in contact with ground
			var c_bar = (compr(fwd)+compr(aft))/2;
			setprop("/gear/"~name~"/c_bar", c_bar);
			setZ(aft,(compr(aft)-c_bar)+zBar);
			setZ(fwd,(compr(fwd)-c_bar)+zBar);
		} else { # No contact with ground
			setprop("/gear/"~name~"/c_bar", 0);
			if(relax == "pitch-down") {
				if(getZ(fwd) > zFwd) {
					setZ(aft,getZ(aft)+1);
					setZ(fwd,getZ(fwd)-1);
				}
			} else {
				if(getZ(aft) > zAft) {
					setZ(aft,getZ(aft)-1);
					setZ(fwd,getZ(fwd)+1);
				}
			}
		}
		# Calculate tilt angle
		var coeff = (getZ(aft)-getZ(fwd))/(2*rodLength);
		if(coeff > 1) { # Limit to one for arcsin function
			coeff = 1;
		} elsif(coeff < -1) {
			coeff = -1
		}
		setprop("/gear/"~name~"/tilt_deg", math.asin(coeff)*R2D);
	}
};

var comp_tilt = {
       init : func {
            me.UPDATE_INTERVAL = 0.03;
            me.loopid = 0;
            
            me.reset();
    },
    	update : func {
    	
    	if ((getprop("/sim/replay/time") == 0) or (getprop("/sim/replay/time") == nil)) {
			gear_helpers.mlg_tilt("mlg_fl",5,1,-376,-372,-382, 31, "pitch-up");
			gear_helpers.mlg_tilt("mlg_fr",6,2,-376,-372,-382, 31, "pitch-up");
			gear_helpers.mlg_tilt("mlg_rl",3,7,-366,-351,-359, 61, "pitch-down");
			gear_helpers.mlg_tilt("mlg_rr",4,8,-366,-351,-359, 61, "pitch-down");
		}
    	
	},

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

var loop_timer = maketimer(0.03, func {
	for(var n=0; n<5; n=n+1) {
		setprop("/engines/engine["~n~"]/fuel-used-kg", getprop("/engines/engine["~n~"]/fuel-used-kg") + (getprop("/sim/time/delta-sec")*((getprop("/engines/engine["~n~"]/fuel-flow_pph")*LB2KG)/3600)));
	}
});

setlistener("sim/signals/fdm-initialized", func {
	setprop("/controls/electric/contact/engine_1", 0);
	setprop("/controls/electric/contact/engine_2", 0);
	setprop("/controls/electric/contact/engine_3", 0);
	setprop("/controls/electric/contact/engine_4", 0);
	setprop("/controls/electric/contact/apu_gen-a", 0);
	setprop("/controls/electric/contact/apu_gen-b", 0);
	setprop("/controls/electric/contact/batt_1", 0);
	setprop("/controls/electric/contact/batt_2", 0);
	setprop("/controls/electric/contact/bus_tie", 0);
	comp_tilt.init();
	loop_timer.start();
	setprop("/consumables/fuel/tank/selected",1);
	setprop("/consumables/fuel/tank[1]/selected",1);
	setprop("/consumables/fuel/tank[2]/selected",1);
	setprop("/consumables/fuel/tank[3]/selected",1);
	setprop("/controls/fuel/l-outer-tk/pump",0);
	setprop("/controls/fuel/l-mid-tk/pump-aft",0);
	setprop("/controls/fuel/l-mid-tk/pump-fwd",0);
	setprop("/controls/fuel/l-inr-tk/pump-aft",0);
	setprop("/controls/fuel/l-inr-tk/pump-fwd",0);
	setprop("/controls/fuel/r-outer-tk/pump",0);
	setprop("/controls/fuel/r-mid-tk/pump-aft",0);
	setprop("/controls/fuel/r-mid-tk/pump-fwd",0);
	setprop("/controls/fuel/r-inr-tk/pump-aft",0);
	setprop("/controls/fuel/r-inr-tk/pump-fwd",0);
	setprop("/controls/fuel/trim-tk/pump-l",0);
	setprop("/controls/fuel/trim-tk/pump-r",0);
});

#FIXME - Remove when canvas ND is ready

setlistener("/instrumentation/efis[0]/mfd/airbus-display-mode", func(n) {
	setprop("/instrumentation/efis[0]/nd/airbus-display-mode", n.getValue());
});

setlistener("/instrumentation/efis[1]/mfd/airbus-display-mode", func(n) {
	setprop("/instrumentation/efis[1]/nd/airbus-display-mode", n.getValue());
});

setlistener("/instrumentation/efis[0]/inputs/range-nm", func(n) {
	setprop("/instrumentation/efis[0]/nd/display-range", n.getValue());
});

setlistener("/instrumentation/efis[1]/inputs/range-nm", func(n) {
	setprop("/instrumentation/efis[1]/nd/display-range", n.getValue());
});

settimer(init_controls, 0);
