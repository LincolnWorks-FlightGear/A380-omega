# (Airbus A380) Heads Up Display
# Narendran M (c) 2014

var placement = "hud.l";
var svgPath = "/Aircraft/A380-omega/Models/Instruments/HUD/hud.svg";

# Define properties for interface
var myProps = [
	{name:	'pitch',		path:	"/orientation/pitch-deg"									},
	{name:	'roll',			path:	"/orientation/roll-deg"										},
	{name:	'heading',		path:	"/instrumentation/heading-indicator/indicated-heading-deg"	},
	{name:	'airspeed',		path:	"/instrumentation/airspeed-indicator/indicated-speed-kt"	},
	{name:	'mach',			path:	"/velocities/mach"											},
	{name:	'altitude',		path:	"/instrumentation/altimeter/indicated-altitude-ft"			},
	{name:	'qnh',			path:	"/instrumentation/altimeter/setting-inhg"					},
	{name:	'alpha',		path:	"/orientation/alpha-deg"									},
	{name:	'sideslip',		path:	"/orientation/side-slip-deg"								},
	{name:	'rollrate',		path:	"/orientation/roll-rate-degps"								},
	{name:	'ap_alt',		path:	"/flight-management/fcu-values/alt"							},
	{name:	'ap_spd',		path:	"/flight-management/fcu-values/ias"							},
	{name:	'vertspd',		path:	"/velocities/vertical-speed-fps"							},
	{name:	'radaralt',		path:	"/instrumentation/radar-altimeter/radar-altitude-ft"		},
	{name:	'winddir',		path:	"/environment/wind-from-heading-deg"						},
	{name:	'windspd',		path:	"/environment/wind-speed-kt"								}];

# Adjust stall speed and maximum flap retraction speeds
var myParams = {
	stall: 125,
	flaps: {
		prop:	"/controls/flight/flaps",
		speeds:	[
			{setting: 	0.0000,		speed:	340},
			{setting:	0.2424,		speed:	263},
			{setting:	0.5151,		speed:	220},
			{setting:	0.7878,		speed:	196},
			{setting:	1.0000,		speed:	182}
		]
	}
};

var hud = {
	new: func(obj_name, interface_props, svg_path, flight_params) {
		var t = {parents:[hud]};
		
		t.display = canvas.new({
			"name": "HUD",
			"size": [1024, 740],
			"view": [1024, 740],
			"mipmapping": 1
		});
		
		var font_mapper = func(family, weight)
		{
			if( family == "Liberation Sans" and weight == "normal" )
				return "LiberationFonts/LiberationSans-Regular.ttf";
		};
		
		t.props = interface_props;
		t.params = flight_params;
		t.display.addPlacement({"node": obj_name});
		t.symbols = t.display.createGroup();
		
		canvas.parsesvg(t.symbols, svg_path, {'font-mapper': font_mapper});
		t.display.setColorBackground(0.36, 1, 0.3, 0.02);
		
		# t.symbols.getElementById("wind_arrow").updateCenter();
		
		# Set Clips
		## Central Horizon box
		t.symbols.getElementById("horizon_heading").set("clip", "rect(115,819,660,170)");
		t.symbols.getElementById("horizon_lines").set("clip", "rect(115,819,660,170)");
		t.symbols.getElementById("traj_marker").set("clip", "rect(115,819,660,170)");
		t.symbols.getElementById("traj_zeroroll").set("clip", "rect(115,819,660,170)");
		## Speed Tape box - horizontal clipping is not important anymore
		t.symbols.getElementById("spd_tape").set("clip", "rect(200,1024,520,0)");
		t.symbols.getElementById("ap_spd").set("clip", "rect(200,1024,520,0)");
		t.symbols.getElementById("stall_tape").set("clip", "rect(200,1024,520,0)");
		t.symbols.getElementById("flaps_tape").set("clip", "rect(200,1024,520,0)");
		## Altitude Tape box
		## Altitude Marker Tape boxes
		t.symbols.getElementById("alt_tape_top").set("clip", "rect(380,1024,520,0)");
		t.symbols.getElementById("alt_tape_bottom").set("clip", "rect(200,1024,340,0)");
		t.symbols.getElementById("ap_alt").set("clip", "rect(200,1024,520,0)");
		## Alitude 100s Tape box
		t.symbols.getElementById("alt_tape_100s").set("clip", "rect(325,1024,390,0)");
		## Vertical Speed Indicator box
		t.symbols.getElementById("vs_pointer").set("clip", "rect(230,1010,490,977)");
		
		t.timer = maketimer(0.05, t, t.update);
		
		return t;
	},
	update: func() {
	
		foreach(var data_prop; me.props) {
			me.data[data_prop.name] = getprop(data_prop.path);
			if(me.data[data_prop.name] == nil) {
				me.data[data_prop.name] = 0;
			}
		}
		
		if(me.data.airspeed<20) {
			me.data.airspeed=20;
		}
		
		# Translate for pitch
		me.elements["horizon_lines"].setTranslation(0,39.3*me.data.pitch);
		me.elements["hdg_pointer"].setTranslation(0,39.3*me.data.pitch);
		me.elements["horizon_heading"].setTranslation(-(10137/360)*(me.data.heading-180),39.3*me.data.pitch);
		
		# Rotate for roll
		me.elements["horizon_heading"].setCenter(512+(10137/360)*(me.data.heading-180),740).setRotation(-me.data.roll*D2R);
		me.elements["horizon_lines"].setCenter(512,740).setRotation(-me.data.roll*D2R);
		me.elements["roll_horizon"].setCenter(512,740).setRotation(-me.data.roll*D2R);
		me.elements["hdg_pointer"].setCenter(512,740).setRotation(-me.data.roll*D2R);
		
		# Rotate trajectory marker according to roll rate
		me.elements["traj_marker"].setCenter(512,740).setRotation(me.data.rollrate*D2R);
		
		# Move trajectory marker and zero-roll to <alpha, side-slip>
		me.elements["traj_marker"].setTranslation(28.2*me.data.sideslip,39.3*me.data.alpha);
		me.elements["traj_zeroroll"].setTranslation(28.2*me.data.sideslip,39.3*me.data.alpha);
		
		# Speed tape
		me.elements["spd_tape"].setTranslation(0,3*me.data.airspeed);
		me.elements["ap_spd"].setTranslation(0,3*me.data.ap_spd);
		
		
		# Altitude tape
		me.elements["alt_tape_top"].setTranslation(0,0.2*me.data.altitude);
		me.elements["alt_tape_bottom"].setTranslation(0,0.2*me.data.altitude);
		me.elements["ap_alt"].setTranslation(0,0.2*me.data.ap_alt);
		
		me.altitude1 = int(me.data.altitude/100);
		me.altitude2 = int(me.data.altitude - (me.altitude1*100));
		
		me.elements["alt_tape_100s"].setTranslation(0,me.altitude2);
		
		# Wind Direction Arrow
		me.elements["wind_arrow"].setRotation((me.data.winddir-me.data.heading)*D2R);
		
		# Set Text Values
		me.elements["radar_alt"].setText(sprintf("%4.0f", me.data.radaralt));
		me.elements["mach_spd"].setText(sprintf("%0.2fM", me.data.mach));
		me.elements["vs_text"].setText(sprintf("%2.0f", me.data.vertspd*0.6));
		me.elements["qnhVal"].setText(sprintf("%2.2f", me.data.qnh));
		me.elements["ap_spd_text"].setText(sprintf("%3.0f", me.data.ap_spd));
		me.elements["ap_alt_text"].setText(sprintf("%5.0f", me.data.ap_alt));
		me.elements["altitude_text"].setText(sprintf("%3.0f", me.altitude1));
		me.elements["wind_dir_spd"].setText(sprintf("%3.0f/%2.0f", me.data.winddir, me.data.windspd));
		if(me.data.radaralt == nil) {
			me.elements["radar_alt"].hide();
		} else {
			if(me.data.radaralt>3000) {
				me.elements["radar_alt"].hide();
			} else {
				me.elements["radar_alt"].show();
			}
		}
		
		# Manage VS Pointer
		me.elements["vs_pointer"].setCenter(1200, 740).setRotation(me.data.vertspd/200);
		
		# Manage flaps and stall tapes
		me.elements["stall_tape"].setTranslation(0,3*(me.data.airspeed-me.params.stall));
		
		var flaps = getprop(me.params.flaps.prop);
		foreach(var flap_set; me.params.flaps.speeds) {
			if(flaps >= flap_set.setting) {
				me.flapsTape = flap_set.speed
			} else {
				break;
			}
		}
		me.elements["flaps_tape"].setTranslation(0,3*(me.data.airspeed-me.flapsTape));		
		
		# Manage speed trent tape
		
		
	},
	init: func {
		me.loopid = 0;
		
		me.elements = {};
		me.data = {};
		foreach(var ename; ["horizon_heading", "horizon_lines", "hdg_pointer", "roll_horizon", "traj_marker", "traj_zeroroll", "spd_tape", "ap_spd", "alt_tape_top", "alt_tape_bottom", "ap_alt", "alt_tape_100s", "radar_alt", "mach_spd", "vs_text", "qnhVal", "ap_spd_text", "ap_alt_text", "altitude_text", "vs_pointer", "stall_tape", "flaps_tape", "wind_dir_spd", "wind_arrow"])
			me.elements[ename] = me.symbols.getElementById(ename);
			
		me.timer.start();
	}
	
};

var a380_hud = hud.new(placement, myProps, svgPath, myParams);

setlistener("sim/signals/fdm-initialized", func {
	a380_hud.init();
	print("Heads Up Displays Initialized");
});
