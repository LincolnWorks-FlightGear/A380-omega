########################################
## AIRBUS A380 FLIGHT CONTROL SYSTEM  ##
########################################
## Written by Narendran Muraleedharan ##
########################################

# This also controls how the hydraulic and electrical backup systems affect the ailerons

# Control Surface	- Hydraulics System(s)
#----------------------------------------------
# ALRN-LOB,ROB		- GREEN   YELLOW
# ALRN-LMD,RMD		- 	  YELLOW   ELEC
# ALRN-LIB,RIB		- GREEN            ELEC
# LSP1,3,7,RSP1,3,7	-         YELLOW
# LSP2,4,8,RSP2,4,8	- GREEN
# LSP5,RSP5		-         YELLOW   ELEC
# LSP6,RSP6		- GREEN            ELEC
# ELEV-LOB,LIB		- GREEN		   ELEC
# ELEV-ROB,RIB		-         YELLOW   ELEC
# HSTAB			- GREEN   YELLOW   ELEC
# RUDD-LOWER		- GREEN   YELLOW   ELEC
# RUDD-UPPER		- GREEN   YELLOW   ELEC
# FLAPS			- GREEN   YELLOW
# SLATS			- GREEN
# RUDDER [BOTH] - GREEN   YELLOW

# CONSTANTS

var RAD2DEG = 57.2957795;
var DEG2RAD = 0.0174532925;

# PATHS

var fcs_tree = "/fdm/jsbsim/fcs/";
var input = "/controls/flight/";

setprop("/fdm/jsbsim/fcs/aileron-ob-droop",0);
setprop("/fdm/jsbsim/fcs/aileron-md-droop",0);
setprop("/fdm/jsbsim/fcs/aileron-ib-droop",0);

var fcs = {
	
	init : func { 
		me.UPDATE_INTERVAL = 0.001; 
		me.loopid = 0;
		
		setprop("/fbw/yaw-damper", 1); # Enable Yaw Damper
		
		## Create Control Surfaces
		# PITCH CONTROL SURFACES
		me.hstb = control_surface.new("hstb-fbw-output", 0, 0.002, ["yellow", "green", "elec-backup"]);
		me.elev_lob = control_surface.new("elev-lob-output", 1, 0.35, ["green", "elec-backup"]);
		me.elev_rob = control_surface.new("elev-rob-output", 1, 0.35, ["yellow", "elec-backup"]);
		me.elev_lib = control_surface.new("elev-lib-output", 1, 0.35, ["green", "elec-backup"]);
		me.elev_rib = control_surface.new("elev-rib-output", 1, 0.35, ["yellow", "elec-backup"]);
		# ROLL CONTROL SURFACES
		me.alrn_lob = control_surface.new("alrn-lob-fbw-output", 1, 0.25, ["green", "yellow"]);
		me.alrn_lmd = control_surface.new("alrn-lmd-fbw-output", 1, 0.25, ["yellow", "elec-backup"]);
		me.alrn_lib = control_surface.new("alrn-lib-fbw-output", 1, 0.25, ["green", "elec-backup"]);
		me.alrn_rob = control_surface.new("alrn-rob-fbw-output", -1, 0.25, ["green", "yellow"]);
		me.alrn_rmd = control_surface.new("alrn-rmd-fbw-output", -1, 0.25, ["yellow", "elec-backup"]);
		me.alrn_rib = control_surface.new("alrn-rib-fbw-output", -1, 0.25, ["green", "elec-backup"]);		
		# SPOILERS
		me.lsp1 = control_surface.new("lsp1-fbw-output", 0, 0.025, ["yellow"]);
		me.lsp2 = control_surface.new("lsp2-fbw-output", 0, 0.025, ["green"]);
		me.lsp3 = control_surface.new("lsp3-fbw-output", 0, 0.025, ["yellow"]);
		me.lsp4 = control_surface.new("lsp4-fbw-output", 0, 0.025, ["green"]);
		me.lsp5 = control_surface.new("lsp5-fbw-output", 0, 0.025, ["yellow", "elec-backup"]);
		me.lsp6 = control_surface.new("lsp6-fbw-output", 0, 0.025, ["green", "elec-backup"]);
		me.lsp7 = control_surface.new("lsp7-fbw-output", 0, 0.025, ["yellow"]);
		me.lsp8 = control_surface.new("lsp8-fbw-output", 0, 0.025, ["green"]);
		me.rsp1 = control_surface.new("rsp1-fbw-output", 0, 0.025, ["yellow"]);
		me.rsp2 = control_surface.new("rsp2-fbw-output", 0, 0.025, ["green"]);
		me.rsp3 = control_surface.new("rsp3-fbw-output", 0, 0.025, ["yellow"]);
		me.rsp4 = control_surface.new("rsp4-fbw-output", 0, 0.025, ["green"]);
		me.rsp5 = control_surface.new("rsp5-fbw-output", 0, 0.025, ["yellow", "elec-backup"]);
		me.rsp6 = control_surface.new("rsp6-fbw-output", 0, 0.025, ["green", "elec-backup"]);
		me.rsp7 = control_surface.new("rsp7-fbw-output", 0, 0.025, ["yellow"]);
		me.rsp8 = control_surface.new("rsp8-fbw-output", 0, 0.025, ["green"]);
		me.rudder = control_surface.new("rudder-fbw-output", 0, 0.1, ["green", "yellow"]);	

		me.phase = 0; # Ground Mode
		
		me.reset(); 
	},
	approach_target: func(val, tgt, step) {
		if(tgt > val + step) {
			return val + step;
		} elsif(tgt < val - step) {
			return val - step;
		} else {
			return tgt;
		}
	},
	get_state : func{
		me.pitch = getprop("/orientation/pitch-deg");
		me.bank = getprop("/orientation/roll-deg");
		me.agl = getprop("/position/altitude-agl-ft");
		me.aspd = getprop("/velocities/airspeed-kt");
		if(me.aspd == nil) {
			me.aspd = 0;
		}
		
		me.alpha = getprop("/orientation/alpha-deg");
		if(me.alpha == nil) {
			me.alpha = 0;
		}
		me.pitch_rate = getprop("/orientation/pitch-rate-degps");
		if(me.pitch_rate == nil) {
			me.pitch_rate = 0;
		}
		me.roll_rate = getprop("/orientation/roll-rate-degps");
		if(me.roll_rate == nil) {
			me.roll_rate = 0;
		}
		me.yaw_rate = getprop("/orientation/yaw-rate-degps");
		if(me.yaw_rate == nil) {
			me.yaw_rate = 0;
		}
		me.gforce = getprop("/accelerations/pilot-gdamped");
		
		# Side stick pitch axis commands pitch rate under 210 KIAS and gforce above
		
		me.stick_pitch = getprop(input~ "elevator");
		me.stick_roll = getprop(input~ "aileron");
		me.pitch_trim = getprop(input~ "elevator-trim");
		me.stick_yaw = getprop(input~ "rudder");
		
		me.dead_band = 0.02;

	},
	airbus_law : func {
		
		if(me.phase == 0) {
			me.law = "DIRECT LAW";
		} elsif(me.phase == 1) {
			me.law = "NORMAL LAW";
		}
		setprop("/fbw/active-law", me.law);

	},
	flight_phase : func {		
		
		# 0 - Ground Mode
		# 1 - Flight Mode
		# 3 - Flare Mode
		
		# if (me.agl > 35) {
		#	setprop("/fbw/flight-phase", "Flight Mode");
		#	me.phase = 1;	
		# }
			
		# if(getprop("/gear/gear[1]/wow")) {
		
		var gspd = getprop("/velocities/groundspeed-kt");
		if(gspd == nil) {
			gspd = 0;
		}
		
		if(gspd < 125) {
			setprop("/fbw/flight-phase", "Ground Mode");
			me.phase = 0;
		} else {
			me.phase = 1;
		}

	},
	speedbrakes : func {
		var spd_brk = getprop("surface-positions/speedbrake-pos-norm");
		
		if(me.aspd > 250) {
			spd_brk = 0.3*spd_brk;
		} elsif(me.aspd > 150) {
			spd_brk = (1 - ((0.3/100)*(me.aspd-150)))*spd_brk;
		}
		
		me.lsp1.move_pos(spd_brk);
		me.lsp2.move_pos(spd_brk);
		me.lsp3.move_pos(spd_brk);
		me.lsp4.move_pos(spd_brk);
		me.lsp5.move_pos(spd_brk);
		me.lsp6.move_pos(spd_brk);
		me.lsp7.move_pos(spd_brk);
		me.lsp8.move_pos(spd_brk);
		me.rsp1.move_pos(spd_brk);
		me.rsp2.move_pos(spd_brk);
		me.rsp3.move_pos(spd_brk);
		me.rsp4.move_pos(spd_brk);
		me.rsp5.move_pos(spd_brk);
		me.rsp6.move_pos(spd_brk);
		me.rsp7.move_pos(spd_brk);
		me.rsp8.move_pos(spd_brk);
	},
	law_normal : func {
		# NORMAL LAW - Commands pitch/roll rate
		
		setprop("/fbw/cmd-roll-rate", 20*me.stick_roll);
		setprop("/fbw/cmd-pitch-rate", -10*me.stick_pitch);
		
		# Only activate roll stabilizer if pilot leaves the stick alone
		if((abs(me.stick_roll) <= me.dead_band) and (abs(me.roll_rate) <= 1)) {
			setprop("/fbw/alrn-ob-enable", 0); # Disable Outboard Ailerons Stabilizer and move to 0 position to minimize drag
			setprop("/fbw/outputs/alrn-ob", 0);
		} else {
			setprop("/fbw/bank-hold", me.bank);
			setprop("/fbw/alrn-ob-enable", 1);
			setprop("/fbw/alrn-md-enable", 1);
		}
		me.alrn_lob.move_pos(getprop("/fbw/outputs/alrn-ob"));
		me.alrn_rob.move_pos(getprop("/fbw/outputs/alrn-ob"));
		me.alrn_lmd.move_pos(getprop("/fbw/outputs/alrn-md"));
		me.alrn_rmd.move_pos(getprop("/fbw/outputs/alrn-md"));
		
		# Inboard Ailerons work the same as in DIRECT LAW
		me.alrn_lib.move_pos(me.stick_roll);
		me.alrn_rib.move_pos(me.stick_roll);
		
		# Yaw Controller - Side-slip Hold
		setprop("/fbw/cmd-yaw-rate", 3*me.stick_yaw + me.bank/12); # Co-ordinate turns
		me.rudder.move_pos(getprop("/fbw/outputs/rudder"));
		# me.rudder.move_pos(-getprop("/controls/flight/rudder"));
		# setprop("/fbw/cmd-side-slip-deg", 25*me.stick_yaw + me.bank/10); # Co-ordinate turns
		# me.rudder.move_pos(getprop("/fbw/outputs/rudder"));
		
		# Roll control spoilers work the same way they do in DIRECT LAW
		# Use Spoiler Assist for Hard Banks
		if(me.stick_roll < -0.5) {
			me.lsp8.add(0.5*(-me.stick_roll - 0.5));
			me.lsp7.add(0.7*(-me.stick_roll - 0.5));
		} else {
			me.lsp8.add(0);
			me.lsp7.add(0);
		}
		if(me.stick_roll > 0.5) {
			me.rsp8.add(0.5*(me.stick_roll - 0.5));
			me.rsp7.add(0.7*(me.stick_roll - 0.5));
		} else {
			me.rsp8.add(0);
			me.rsp7.add(0);
		}
		
		if((abs(me.stick_pitch) <= me.dead_band) and (abs(me.pitch_rate) <= 4)) {
			setprop("/fbw/elev-ob-stable", 1);
			setprop("/fbw/elev-ob-enable", 0);
			setprop("/fbw/elev-ib-enable", 0);
			setprop("/fbw/outputs/elev-ib", me.approach_target(getprop("/fbw/outputs/elev-ib"),0,0.01));
		} else {
			setprop("/fbw/elev-ob-enable", 1);
			setprop("/fbw/elev-ob-stable", 0);
			setprop("/fbw/elev-ib-enable", 1);
			setprop("/fbw/pitch-hold", me.pitch);
		}
		
		# Outboard Elevators work to achieve commanded pitch rate [G-Force above 210 KIAS]
		me.elev_lob.move_pos(getprop("/fbw/outputs/elev-ob"));
		me.elev_rob.move_pos(getprop("/fbw/outputs/elev-ob"));
		me.elev_lib.move_pos(getprop("/fbw/outputs/elev-ob"));
		me.elev_rib.move_pos(getprop("/fbw/outputs/elev-ob"));
		
		me.hstb.move_pos(me.pitch_trim); # FBW Output for HSTAB is the pitch trim property
		
		# Control Yaw Damper
		if(getprop("/flight-management/control/ap1-master") == "eng" or getprop("/flight-management/control/ap2-master") == "eng") {
			setprop("/fbw/yaw-damper", 0);
		} else {
			setprop("/fbw/yaw-damper", 1);
		}
	},
	law_direct : func {
		# DIRECT LAW - Apply Inputs from Side Stick straight to control surfaces without modifications or stabilization
		
		# ROLL CONTROL
		me.alrn_lob.move_pos(me.stick_roll);
		me.alrn_lmd.move_pos(me.stick_roll);
		me.alrn_lib.move_pos(me.stick_roll);
		me.alrn_rob.move_pos(me.stick_roll);
		me.alrn_rmd.move_pos(me.stick_roll);
		me.alrn_rib.move_pos(me.stick_roll);
		# Use Spoiler Assist for Hard Banks
		if(me.stick_roll < -0.5) {
			me.lsp8.add(0.5*(-me.stick_roll - 0.5));
			me.lsp7.add(0.7*(-me.stick_roll - 0.5));
		} else {
			me.lsp8.add(0);
			me.lsp7.add(0);
		}
		if(me.stick_roll > 0.5) {
			me.rsp8.add(0.5*(me.stick_roll - 0.5));
			me.rsp7.add(0.7*(me.stick_roll - 0.5));
		} else {
			me.rsp8.add(0);
			me.rsp7.add(0);
		}
		
		# PITCH CONTROL
		me.hstb.move_pos(me.pitch_trim);
		me.elev_lob.move_pos(me.stick_pitch);
		me.elev_rob.move_pos(me.stick_pitch);
		me.elev_lib.move_pos(me.stick_pitch);
		me.elev_rib.move_pos(me.stick_pitch);
		me.rudder.move_pos(-me.stick_yaw);

	},
	update : func {

		# Update vars from property tree
		me.get_state();
		
		# Find out the current flight phase (Ground/Flight/Flare)
		me.flight_phase();

		# Decide which law to use according to system condition
		me.airbus_law();

		if(me.law == "NORMAL LAW") {
			me.law_normal();
		} elsif(me.law == "DIRECT LAW") {
			me.law_direct();
		}
		
		# Set FDM Helper Properties
		
		# Differential Aileron Position
		setprop(fcs_tree~"alrn-ob-diff-norm", (me.alrn_lob.get_norm()+me.alrn_rob.get_norm())/2);
		setprop(fcs_tree~"alrn-md-diff-norm", (me.alrn_lmd.get_norm()+me.alrn_rmd.get_norm())/2);
		setprop(fcs_tree~"alrn-ib-diff-norm", (me.alrn_lib.get_norm()+me.alrn_rib.get_norm())/2);
		
		# Absolute Aileron Position
		setprop(fcs_tree~"alrn-lob-fbw-output-abs", abs(me.alrn_lob.get_norm()));
		setprop(fcs_tree~"alrn-lmd-fbw-output-abs", abs(me.alrn_lmd.get_norm()));
		setprop(fcs_tree~"alrn-lib-fbw-output-abs", abs(me.alrn_lib.get_norm()));
		setprop(fcs_tree~"alrn-rob-fbw-output-abs", abs(me.alrn_rob.get_norm()));
		setprop(fcs_tree~"alrn-rmd-fbw-output-abs", abs(me.alrn_rmd.get_norm()));
		setprop(fcs_tree~"alrn-rib-fbw-output-abs", abs(me.alrn_rib.get_norm()));
		
		# Calculate Aileron Droop
		setprop(fcs_tree~"alrn-ob-droop", (me.alrn_lob.get_norm()-me.alrn_rob.get_norm())/2);
		setprop(fcs_tree~"alrn-md-droop", (me.alrn_lmd.get_norm()-me.alrn_rmd.get_norm())/2);
		setprop(fcs_tree~"alrn-ib-droop", (me.alrn_lib.get_norm()-me.alrn_rib.get_norm())/2);
		
		# Set Speedbrakes position
		me.speedbrakes();
		
		# Control Aileron Droop
		var flaps = getprop("/fdm/jsbsim/fcs/flap-pos-deg");
		if(flaps > 16) {
			var droop = (flaps - 16)*0.01745;
			if(getprop("/gear/gear[1]/wow") and (getprop("/velocities/groundspeed-kt") > 45) and (flaps > 24)) {
				droop = (16 - flaps)*0.03;
				setprop("/controls/flight/speedbrake",1);
			}
			var newDroopPos = me.approach_target(getprop("/fdm/jsbsim/fcs/aileron-ob-droop"), droop, 0.025);
			setprop("/fdm/jsbsim/fcs/aileron-ob-droop", newDroopPos);
			setprop("/fdm/jsbsim/fcs/aileron-md-droop", newDroopPos);
			setprop("/fdm/jsbsim/fcs/aileron-ib-droop", newDroopPos);
		}
		
		# Pressurize Control Surface Actuators
		me.hstb.pressurize();
		me.elev_lib.pressurize();
		me.elev_lob.pressurize();
		me.elev_rib.pressurize();
		me.elev_rob.pressurize();
		me.alrn_lob.pressurize();
		me.alrn_lmd.pressurize();
		me.alrn_lib.pressurize();
		me.alrn_rob.pressurize();
		me.alrn_rmd.pressurize();
		me.alrn_rib.pressurize();
		me.lsp1.pressurize();
		me.lsp2.pressurize();
		me.lsp3.pressurize();
		me.lsp4.pressurize();
		me.lsp5.pressurize();
		me.lsp6.pressurize();
		me.lsp7.pressurize();
		me.lsp8.pressurize();
		me.rsp1.pressurize();
		me.rsp2.pressurize();
		me.rsp3.pressurize();
		me.rsp4.pressurize();
		me.rsp5.pressurize();
		me.rsp6.pressurize();
		me.rsp7.pressurize();
		me.rsp8.pressurize();
		
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
# END fcs_loop var
###

fcs.init();
print("Flight Control System Initialized");
