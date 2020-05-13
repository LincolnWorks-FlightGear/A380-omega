var fmgc = "/flight-management/control/";
var settings = "/flight-management/settings/";
var fcu = "/flight-management/fcu-values/";
var fmgc_val = "/flight-management/fmgc-values/";
var servo = "/servo-control/";

var new_flight = func() {

	################################## FMGC ####################################

	setprop("/flight-management/current-wp", 0);
	
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
    
    # AUTOPILOT (MASTER)
    
    setprop(fmgc~ "ap1-master", "off");
    setprop(fmgc~ "ap2-master", "off");
    setprop(fmgc~ "a-thrust", "off");
    
    # Rate/Load Factor Configuration
    
    setprop(settings~ "pitch-norm", 0.1);
    setprop(settings~ "roll-norm", 0.2);
    
    # Terminal Procedure
    
    setprop("/flight-management/procedures/active", "off"); # AVAIL MODES : off sid star iap
    
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
};
