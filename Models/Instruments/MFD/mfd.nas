# (Airbus A380) Multi-Function Display for Flight Programming/Management
# Narendran Muraleedharan (c) 2014

# Object Types --> click, textbox, label

var font_mapper = func(family, weight)
{
	if( family == "Liberation Sans" and weight == "normal" )
		return "LiberationFonts/LiberationSans-Regular.ttf";
};

var colors = {
	gray1:  [0.314, 0.314, 0.314],
	gray2:  [0.627, 0.627, 0.627],
	blue1:  [0.000, 0.706, 1.000],
	active: [0.100, 0.100, 0.100]
};

var genUpdateFunc = func(t, widget) {
	return func {
		var value = getprop(widget.property);
		if(value != nil) {
			widget.text = value;
			t.svgCache[widget.text_obj].setText(sprintf(widget.format,value));
		}
	}
}

var setVisibility = func(t, widget) {
	return func {
		var enabled = getprop(widget.enabled);
		if(enabled != nil) {
			if(enabled == 1) {
				t.svgCache[widget.text_obj].show();
			} else {
				t.svgCache[widget.text_obj].hide();
			}
		}
	}
}

var fuel_tree = "/flight-management/fuel/";

var getTimeString = func(hrs) {
	if(hrs > 0) {
		var hour = math.floor(hrs);
		if(hour >= 24) {
			hour = hour - 24;
		} elsif(hour < 10) {
			hour = "0"~hour;
		}
		var min = math.floor((hrs - hour)*60);
		if(min < 10) {
			min = "0"~min;
		}
		return hour ~ ":" ~ min;
	} else {
		return "INVALID"
	}
}

var updateFpln = func(t) {
	var first = t.fpln_first;
	var utc = getprop("/sim/time/utc/hour") + (getprop("/sim/time/utc/minute"))/60;
	for(var i=1; i<10; i=i+1) {
		foreach(var listener; t.fpln_listeners) {
			removelistener(listener);
		}
		if(first == 0 and i == 1) {
			foreach(var element; ["wpt", "utc", "spd", "alt"]) {
				t.svgCache[element~i].show();
			}
			foreach(var element; ["box", "via", "flyto", "trk", "dist"]) {
				t.svgCache[element~i].hide();
			}
			t.svgCache["wpt"~i].setText(sprintf("%s", fms.fms1.depICAO ~ fms.fms1.depRwy));
			t.svgCache["utc"~i].setText(sprintf("%s", getTimeString(utc)));
			t.svgCache["spd"~i].setText(sprintf("%3.0f", 150));
			t.svgCache["alt"~i].setText(sprintf("%5.0f", fms.getArptElev(fms.fms1.depICAO)));
		} else {
			var j = i - 1;
			if(first == 0) {
				j = i - 2;
			}
			if(first + j < size(fms.fms1.wpts)) {
				var wpt = fms.fms1.wpts[first + j];
				foreach(var element; ["wpt", "utc", "spd", "alt", "trk", "dist", "flyto"]) {
					t.svgCache[element~i].show();
				}
				t.svgCache["wpt"~i].setText(sprintf("%s", wpt.ident));
				t.svgCache["utc"~i].setText(sprintf("%s", getTimeString(utc)));
				if(wpt.speed < 1) {
					t.svgCache["spd"~i].setText(sprintf("%s", "M."~int(wpt.speed*100)));
				} else {
					t.svgCache["spd"~i].setText(sprintf("%3.0f", wpt.speed));
				}
				if(wpt.altitude > getprop("/flight-management/transition-altitude-ft")) {
					t.svgCache["alt"~i].setText(sprintf("%s", "FL"~int(wpt.altitude/100)));
				} else {
					t.svgCache["alt"~i].setText(sprintf("%5.0f", wpt.altitude));
				}
			} else {
				foreach(var element; ["box", "wpt", "via", "utc", "spd", "alt", "flyto", "trk", "dist", "active"]) {
					t.svgCache[element~i].hide();				
				}
			}
		}
	}
}

var calcFuelLoad = func() {
	var blocks = getprop(fuel_tree~"blocks");
	if(blocks != nil) {	
		if(blocks > 0) {
			var rsv = getprop(fuel_tree~"rte-rsv");
	
			if(rsv == nil) {
				setprop(fuel_tree~"rte-rsv", 0);
				rsv = 0;
			}
	
			var final_fuel = getprop(fuel_tree~"final-fuel");
	
			if(final_fuel == nil) {
				setprop(fuel_tree~"final-fuel", "0.0");
				final_fuel = 0;
			}
	
			var final_time = getprop(fuel_tree~"final-time");
			var taxi = getprop(fuel_tree~"taxi");
	
			var zfw = getprop("/flight-management/fuel/zfw");
			var gw = getprop("/flight-management/fuel/gw");
	
			var utc = getprop("/sim/time/utc/hour") + (getprop("/sim/time/utc/minute"))/60;
	
			# Get Trip Fuel and Time
			var trip_fuel = fms.fms1.getRouteDistance();
			setprop("/flight-management/fuel/trip-fuel", trip_fuel);
			setprop("/flight-management/fuel/trip-time", getTimeString(trip_fuel/11)); # 11t/hr
	
			# Convert RSV to percent
			setprop("/flight-management/fuel/rsv-percent", rsv/2.67);
	
			# Calculate Alternate Fuel and Time
			var altn_fuel = 0;
			setprop("/flight-management/fuel/altn-fuel", altn_fuel);
			setprop("/flight-management/fuel/altn-time", getTimeString(altn_fuel/11)); # 11t/hr
	
			# Calculate Extra Fuel and Time
			var total_fuel = taxi + trip_fuel + rsv + altn_fuel + final_fuel;
			var extra_fuel = blocks - total_fuel;
			setprop("/flight-management/fuel/extra-fuel", extra_fuel);
			setprop("/flight-management/fuel/extra-time", getTimeString(extra_fuel/12)); # 12t/hr
	
			# Calculate Take Off Weight
			if(zfw == "---.-") {
				setprop("/flight-management/fuel/tow", gw - taxi);
			} else {
				setprop("/flight-management/fuel/tow", zfw + blocks - taxi);
			}
	
			# Calculate Landing Weight
			if(zfw == "---.-") {
				setprop("/flight-management/fuel/lw", gw - taxi - trip_fuel - final_fuel);
			} else {
				setprop("/flight-management/fuel/lw", zfw + blocks - taxi - trip_fuel - final_fuel);
			}
	
			# Calculate Destination UTC and Fuel
			var dest_fuel = blocks - taxi - trip_fuel - final_fuel;
			setprop("/flight-management/fuel/dest_fuel", dest_fuel);
			setprop("/flight-management/fuel/dest_utc", getTimeString(utc + (blocks - dest_fuel)/11));
	
			# Calculate Alternate UTC and Fuel
			var altn_fuel = blocks - taxi - trip_fuel - altn_fuel - final_fuel;
			setprop("/flight-management/fuel/altn_fuel", altn_fuel);
			setprop("/flight-management/fuel/altn_utc", getTimeString(utc + (blocks - altn_fuel)/11));
		}
	}
}

var genTextBox = func(t, n, widget) {
	return func {
		forindex(var i; t.widgets) {
			if((i != n) and (t.widgets[i].type == 'textbox')) {
				if(t.widgets[i].listener != nil) {
					removelistener(t.widgets[i].listener);
					t.widgets[i].listener = nil;
				}
				t.widgets[i].active = 0;
				t.svgCache[t.widgets[i].field].setColorFill([0,0,0]); # Inactive Color
			}
		}
		if(widget.active == 1) {
			widget.active = 0;
			t.active_textbox = -1;
			t.svgCache[widget.field].setColorFill([0,0,0]); # Inactive Color
			setprop(widget.property, widget.text);
			widget.enter();
			if(widget.listener != nil) {
				removelistener(widget.listener);
				widget.listener = nil;
			}
		} else {
			widget.active = 1;
			t.active_textbox = n;
			t.svgCache[widget.field].setColorFill(colors.active);
			widget.listener = setlistener("/devices/status/keyboard/event", func(event) {
				if (!event.getNode("pressed").getValue())
					return;
				var key = event.getNode("key");
				var shift = event.getNode("modifier/shift").getValue();
				var char = key.getValue();
				if(char == 8) {
					# Backspace
					widget.text = substr(widget.text, 0, size(widget.text) - 1);
					t.svgCache[widget.text_obj].setText(sprintf(widget.format,widget.text));
				} elsif(char == 10 or char == 13) {
					# Enter
					widget.active = 0;
					t.active_textbox = -1;
					t.svgCache[widget.field].setColorFill([0,0,0]); # Inactive Color
					setprop(widget.property, widget.text);
					widget.enter();
					if(widget.listener != nil) {
						removelistener(widget.listener);
						widget.listener = nil;
					}
				} else {
					# Add Character
					widget.text ~= chr(char);
					t.svgCache[widget.text_obj].setText(sprintf(widget.format,widget.text));
				}
				key.setValue(-1);
			});
		 }
	}
}

var mfd = {
	new: func(placement, svg_path) {
		var t = {parents:[mfd]};
		t.display = canvas.new({
			"name":			"MFD Display",
			"size":			[800, 1024],
			"view":			[800, 1024],
			"mipmapping":	1
		});
		
		t.svgCache = {};
		
		t.fpln_first = 0;
		t.fpln_listeners = [];
		
		t.display.addPlacement({"node": placement, "capture-events": 1});
		t.svgGroup = t.display.createGroup();	# SVG Objects for pages
		canvas.parsesvg(t.svgGroup, svg_path, {'font-mapper':font_mapper});		
		
		foreach(var element; ["dropdown", "fms1_click", "fms2_click", "atc_com_click", "surv_click", "fcu_bkup_click", "fms1_text", "fms2_text", "atc_com_text", "surv_text", "fcu_bkup_text", "fms_mode_text", "fms_mode_box", "fms_mode_static", "active_box", 
"position_box", "active_dropdown", "position_dropdown", "active_current", "position_current", "active_fpln_box", "active_perf_box", "active_fuel_box", "active_wind_box", "active_init_box", "position_navaids_box", "position_navaids_text", "page_title", "connect_current", "request_current", "report_current", "msg_record_current", "status_current", "controls_current", "autoflight_current", "efis_current", "active_fpln_text", "active_perf_text", "active_fuel_text", "active_wind_text", "active_init_text", "active_text", "position_text", "connect_text", "request_text", "report_text", "msg_record_text", "controls_text", "status_text", "autoflight_text", "efis_text", "textbox_fltnum", "text_fltnum", "textbox_from", "text_from", "textbox_to", "text_to", "textbox_altn", "text_altn", "textbox_crzfl", "text_crzfl", "textbox_ci", "text_ci", "textbox_tropo", "text_tropo", "textbox_crztemp", "text_crztemp", "textbox_cpnyrte", "text_cpnyrte", "textbox_altnrte", "text_altnrte", "flightnum", "fuel_return", "gw", "cg", "fob", "tb_zfw", "t_zfw", "tb_zfwcg", "t_zfwcg", "tb_block", "t_block", "tb_pax", "t_pax", "trip_fuel", "trip_time", "tb_rsv", "t_rsv", "rsv_percent", "tb_ci", "t_ci", "altn_fuel", "altn_time", "tb_final_fuel", "t_final_fuel", "tb_final_time", "t_final_time", "extra_fuel", "extra_time", "tow", "lw", "fuel_dest", "fuel_altn", "fuel_dest_utc", "fuel_altn_utc", "fuel_dest_efob", "fuel_altn_efob", "tb_min", "t_min", "tb_taxi", "t_taxi", "fpln_menu"]) {
			t.svgCache[element] = t.svgGroup.getElementById(element);
		}
		# ACTIVE / F-PLN Page SVG Elements
		for(var i=1; i<10; i=i+1) {
			foreach(var element; ["box", "wpt", "via", "utc", "spd", "alt", "flyto", "trk", "dist", "active"]) {
				t.svgCache[element~i] = t.svgGroup.getElementById(element~i);
				t.svgCache[element~i].hide();
			}
		}
		t.svgCache["fpln_menu"].hide();
		
		t.activePage = "";
		t.activeMenu = "";
		t.menus = {
			'menu_surv': {
				load: func() {
					
				}
			},
			'menu_fms': {
				load: func() {
					
				},
				pages: {
					'fms_active_init': {
						load: func() {
							# Nothing here
						}
					},
					'fms_active_fpln': {
						load: func() {
							t.fpln_first = 0;
						}
					},
					'fms_active_fuel': {
						load: func() {
							calcFuelLoad();
						}
					},
					'fms_active_perf': {
						load: func() {
							
						}
					}
				}
			},
			'menu_fcu_bkup': {
				load: func() {
					
				}
			},
			'menu_atc_com': {
				load: func() {
					
				}
			}
		};
		t.menuLayers = ['menu_surv', 'menu_fms', 'menu_fcu_bkup', 'menu_atc_com'];
		t.pageLayers = ['fms_active_init', 'fms_active_fpln', 'fms_active_fuel', 'fms_active_perf'];
		
		foreach(var layer; t.menuLayers) {
			t.svgCache[layer] = t.svgGroup.getElementById(layer);
		}
		foreach(var layer; t.pageLayers) {
			t.svgCache[layer] = t.svgGroup.getElementById(layer);
		}
		
		t.svgCache["position_dropdown"].hide();
		t.svgCache["active_dropdown"].hide();
		t.svgCache["position_dropdown"].hide();
		t.svgCache["dropdown"].hide();
		
		t.svgCache["active_current"].show();
		t.svgCache["position_current"].hide();
		
		t.svgCache["connect_current"].show();
		t.svgCache["request_current"].hide();
		t.svgCache["report_current"].hide();
		t.svgCache["msg_record_current"].hide();
		
		t.svgCache["controls_current"].show();
		t.svgCache["status_current"].hide();
		
		t.svgCache["autoflight_current"].show();
		t.svgCache["efis_current"].hide();
		
		t.svgCache["page_title"].setText("ACTIVE / INIT");
		
		t.active_textbox = -1;
		
		t.widgets = [
			# ACTIVE / INIT
			{
				type: 'click',
				objects: ["fms_mode_text", "fms_mode_box", "fms_mode_static"],
				function: func() {
					t.svgCache["position_dropdown"].hide();
					t.svgCache["active_dropdown"].hide();
					if(t.svgCache["dropdown"].getVisible()) {
						t.svgCache["dropdown"].hide();
						t.svgCache["fms_mode_box"].setColorFill(colors.gray1);
					} else {
						t.svgCache["dropdown"].show();
						t.svgCache["fms_mode_box"].setColorFill(colors.gray2);
					}
				}
			},
			{
				type: 'click',
				objects: ["fms1_click", "fms1_text"],
				function: func() {
					t.svgCache["fms1_click"].setColor(colors.blue1);
					settimer(func {
						t.svgCache["dropdown"].hide();
						t.svgCache["fms1_click"].setColor(colors.gray1);
						t.svgCache["fms_mode_box"].setColorFill(colors.gray1);
						t.svgCache["fms_mode_text"].setText("FMS1");
						t.loadPage("menu_fms", "fms_active_init");
						t.svgCache["position_current"].hide();
						t.svgCache["active_current"].show();
						t.svgCache["active_current"].show();
						t.svgCache["position_current"].hide();
						t.svgCache["page_title"].setText("ACTIVE / INIT");
						t.active_textbox = -1;
					}, 0.1);
				}
			},
			{
				type: 'click',
				objects: ["atc_com_click", "atc_com_text"],
				function: func() {
					t.svgCache["atc_com_click"].setColor(colors.blue1);
					settimer(func {
						t.svgCache["dropdown"].hide();
						t.svgCache["atc_com_click"].setColor(colors.gray1);
						t.svgCache["fms_mode_box"].setColorFill(colors.gray1);
						t.svgCache["fms_mode_text"].setText("ATC COM");
						t.loadPage("menu_atc_com", "atc_com_connect");
						t.svgCache["report_current"].hide();
						t.svgCache["request_current"].hide();
						t.svgCache["msg_record_current"].hide();
						t.svgCache["connect_current"].show();
						t.svgCache["page_title"].setText("ATC COM / CONNECT");
						t.active_textbox = -1;
					}, 0.1);
				}
			},
			{
				type: 'click',
				objects: ["surv_click", "surv_text"],
				function: func() {
					t.svgCache["surv_click"].setColor(colors.blue1);
					settimer(func {
						t.svgCache["dropdown"].hide();
						t.svgCache["surv_click"].setColor(colors.gray1);
						t.svgCache["fms_mode_box"].setColorFill(colors.gray1);
						t.svgCache["fms_mode_text"].setText("SURV");
						t.loadPage("menu_surv", "surv_controls");
						t.svgCache["status_current"].hide();
						t.svgCache["controls_current"].show();
						t.svgCache["page_title"].setText("SURV / CONTROLS");
						t.active_textbox = -1;
					}, 0.1);
				}
			},
			{
				type: 'click',
				objects: ["fcu_bkup_click", "fcu_bkup_text"],
				function: func() {
					t.svgCache["fcu_bkup_click"].setColor(colors.blue1);
					settimer(func {
						t.svgCache["dropdown"].hide();
						t.svgCache["fcu_bkup_click"].setColor(colors.gray1);
						t.svgCache["fms_mode_box"].setColorFill(colors.gray1);
						t.svgCache["fms_mode_text"].setText("FCU BKUP");
						t.loadPage("menu_fcu_bkup", "fcu_bkup_autoflight");
						t.svgCache["efis_current"].hide();
						t.svgCache["autoflight_current"].show();
						t.svgCache["page_title"].setText("FCU BKUP / AUTOFLIGHT");
						t.active_textbox = -1;
					}, 0.1);
				}
			},
			{
				type: 'click',
				objects: ["active_box", "active_current", "active_text"],
				function: func() {
					t.svgCache["dropdown"].hide();
					t.svgCache["position_dropdown"].hide();
					t.svgCache["position_box"].setColorFill(colors.gray1);
					if(t.svgCache["active_dropdown"].getVisible()) {
						t.svgCache["active_dropdown"].hide();
						t.svgCache["active_box"].setColorFill(colors.gray1);
					} else {
						t.svgCache["active_dropdown"].show();
						t.svgCache["active_box"].setColorFill(colors.gray2);
					}
				}
			},
			{
				type: 'click',
				objects: ["position_box", "position_current", "position_text"],
				function: func() {
					t.svgCache["dropdown"].hide();
					t.svgCache["active_dropdown"].hide();
					t.svgCache["active_box"].setColorFill(colors.gray1);
					if(t.svgCache["position_dropdown"].getVisible()) {
						t.svgCache["position_dropdown"].hide();
						t.svgCache["position_box"].setColorFill(colors.gray1);
					} else {
						t.svgCache["position_dropdown"].show();
						t.svgCache["position_box"].setColorFill(colors.gray2);
					}
				}
			},
			{
				type: 'click',
				objects: ["active_fpln_box", "active_fpln_text"],
				function: func() {
					t.svgCache["active_fpln_box"].setColor(colors.blue1);
					settimer(func {
						t.svgCache["active_dropdown"].hide();
						t.svgCache["active_box"].setColorFill(colors.gray1);
						t.svgCache["active_fpln_box"].setColor(colors.gray1);
						t.svgCache["page_title"].setText("ACTIVE / F-PLN");
						t.loadPage("menu_fms", "fms_active_fpln");
						t.svgCache["position_current"].hide();
						t.svgCache["active_current"].show();
						t.active_textbox = -1;
					}, 0.1);
				}
			},
			{
				type: 'click',
				objects: ["active_perf_box", "active_perf_text"],
				function: func() {
					t.svgCache["active_perf_box"].setColor(colors.blue1);
					settimer(func {
						t.svgCache["active_dropdown"].hide();
						t.svgCache["active_box"].setColorFill(colors.gray1);
						t.svgCache["active_perf_box"].setColor(colors.gray1);
						t.svgCache["page_title"].setText("ACTIVE / PERF");
						t.loadPage("menu_fms", "fms_active_perf");
						t.svgCache["position_current"].hide();
						t.svgCache["active_current"].show();
						t.active_textbox = -1;
					}, 0.1);
				}
			},
			{
				type: 'click',
				objects: ["active_fuel_box", "active_fuel_text"],
				function: func() {
					t.svgCache["active_fuel_box"].setColor(colors.blue1);
					settimer(func {
						t.svgCache["active_dropdown"].hide();
						t.svgCache["active_box"].setColorFill(colors.gray1);
						t.svgCache["active_fuel_box"].setColor(colors.gray1);
						t.svgCache["page_title"].setText("ACTIVE / FUEL & LOAD");
						t.loadPage("menu_fms", "fms_active_fuel");
						t.svgCache["position_current"].hide();
						t.svgCache["active_current"].show();
						t.active_textbox = -1;
					}, 0.1);
				}
			},
			{
				type: 'click',
				objects: ["active_init_box", "active_init_text"],
				function: func() {
					t.svgCache["active_init_box"].setColor(colors.blue1);
					settimer(func {
						t.svgCache["active_dropdown"].hide();
						t.svgCache["active_box"].setColorFill(colors.gray1);
						t.svgCache["active_init_box"].setColor(colors.gray1);
						t.svgCache["page_title"].setText("ACTIVE / INIT");
						t.loadPage("menu_fms", "fms_active_init");
						t.svgCache["position_current"].hide();
						t.svgCache["active_current"].show();
						t.active_textbox = -1;
					}, 0.1);
				}
			},
			{
				type: 'textbox',
				field: 'textbox_fltnum',
				text_obj: 'text_fltnum',
				active: 0,
				listener: nil,
				text: '',
				format: "%s",
				enter: func {
					# Initialize in A380 FMS
					fms.fms1.flt_nbr = getprop("/flight-management/flt_nbr");
				},
				property: "/flight-management/flt_nbr"
			},
			{
				type: 'textbox',
				field: 'textbox_from',
				text_obj: 'text_from',
				active: 0,
				listener: nil,
				text: '',
				format: "%s",
				enter: func {
					# Purely for ND Display purposes
					setprop("/autopilot/route-manager/departure/airport", getprop("/flight-management/arpt_from"));
					
					# Initialize in A380 FMS
					fms.fms1.depICAO = getprop("/flight-management/arpt_from");
				},
				property: "/flight-management/arpt_from"
			},
			{
				type: 'textbox',
				field: 'textbox_to',
				text_obj: 'text_to',
				active: 0,
				listener: nil,
				text: '',
				format: "%s",
				enter: func {
					# Purely for ND Display purposes
					setprop("/autopilot/route-manager/destination/airport", getprop("/flight-management/arpt_to"));
					
					# Initialize in A380 FMS
					fms.fms1.arrICAO = getprop("/flight-management/arpt_to");
				},
				property: "/flight-management/arpt_to"
			},
			{
				type: 'textbox',
				field: 'textbox_altn',
				text_obj: 'text_altn',
				active: 0,
				listener: nil,
				text: '',
				format: "%s",
				enter: func {
					# Initialize in A380 FMS
					fms.fms1.alternate = getprop("/flight-management/arpt_altn");
				},
				property: "/flight-management/arpt_altn"
			},
			{
				type: 'textbox',
				field: 'textbox_crzfl',
				text_obj: 'text_crzfl',
				active: 0,
				listener: nil,
				text: '',
				format: "%3.0f",
				enter: func {
					# Use US Standard Atmosphere Linear Interpolation + Sea Level Temperature to estimate cruise temperature
					var fl = getprop("/flight-management/crz_fl");
					if(fl != nil) {
					
						if(fl > 430) {
							fl = 430;
							setprop("/flight-management/crz_fl", "430");
						}					
						var temp = 0;
						if(fl <= 360) {		# Troposphere Range
							temp = getprop("/environment/temperature-sea-level-degc") - 15 - (fl*29.35)/300;
						} else {			# Tropopause Range
							temp = getprop("/environment/temperature-sea-level-degc") - 50.22;
						}
						setprop("/flight-management/crz_temp", int(temp));
						# The tropopause goes up to about 60,000 ft which is well above the aircraft's service ceiling so I'm not including equations for those altitudes.
					
						# Initialize in A380 FMS
						fms.fms1.crz_FL = getprop("/flight-management/crz_fl");
					
					}
				},
				property: "/flight-management/crz_fl"
			},
			{
				type: 'textbox',
				field: 'textbox_cpnyrte',
				text_obj: 'text_cpnyrte',
				active: 0,
				listener: nil,
				text: 'NONE',
				format: "%s",
				enter: func {
					# FIXME
					setprop("/flight-management/cpny_rte", "NONE");
				},
				property: "/flight-management/cpny_rte"
			},
			{
				type: 'textbox',
				field: 'textbox_altnrte',
				text_obj: 'text_altnrte',
				active: 0,
				listener: nil,
				text: 'NONE',
				format: "%s",
				enter: func {
					# FIXME
					setprop("/flight-management/altn_rte", "NONE");
				},
				property: "/flight-management/altn_rte"
			},
			{
				type: 'textbox',
				field: 'textbox_crztemp',
				text_obj: 'text_crztemp',
				active: 0,
				listener: nil,
				text: '-50',
				format: "%2.0f",
				enter: func {
					# Nothing to do
				},
				property: "/flight-management/crz_temp"
			},
			{
				type: 'textbox',
				field: 'textbox_ci',
				text_obj: 'text_ci',
				active: 0,
				listener: nil,
				text: '30',
				format: "%3.0f",
				enter: func {
					# Nothing to do
				},
				property: "/flight-management/cost_index"
			},
			{
				type: 'textbox',
				field: 'textbox_tropo',
				text_obj: 'text_tropo',
				active: 0,
				listener: nil,
				text: '36090',
				format: "%5.0f",
				enter: func {
					# Nothing to do
				},
				property: "/flight-management/tropo"
			},
			{
				type: 'label',
				enabled:1,
				text_obj: 'flightnum',
				listener: nil,
				text: '',
				format: "%s",
				property: "/flight-management/flt_nbr"
			},
			# ACTIVE / FUEL & LOAD
			{
				type: 'click',
				objects: ["fuel_return"],
				function: func() {
					t.svgCache["active_init_box"].setColor(colors.blue1);
					settimer(func {
						t.svgCache["active_dropdown"].hide();
						t.svgCache["active_box"].setColorFill(colors.gray1);
						t.svgCache["active_init_box"].setColor(colors.gray1);
						t.svgCache["page_title"].setText("ACTIVE / INIT");
						t.loadPage("menu_fms", "fms_active_init");
						t.svgCache["position_current"].hide();
						t.svgCache["active_current"].show();
						t.active_textbox = -1;
					}, 0.1);
				}
			},
			{
				type: 'label',
				enabled:1,
				text_obj: 'gw',
				listener: nil,
				text: '',
				format: "%3.1f",
				property: "/flight-management/fuel/gw"
			},
			{
				type: 'label',
				enabled:1,
				text_obj: 'cg',
				listener: nil,
				text: '',
				format: "%2.1f",
				property: "/flight-management/fuel/cg"
			},
			{
				type: 'label',
				enabled:1,
				text_obj: 'fob',
				listener: nil,
				text: '',
				format: "%3.1f",
				property: "/flight-management/fuel/fob"
			},
			{
				type: 'label',
				enabled:1,
				text_obj: 'trip_fuel',
				listener: nil,
				text: '',
				format: "%3.1f",
				property: "/flight-management/fuel/trip-fuel"
			},
			{
				type: 'label',
				enabled:1,
				text_obj: 'trip_time',
				listener: nil,
				text: '',
				format: "%s",
				property: "/flight-management/fuel/trip-time"
			},
			{
				type: 'label',
				enabled:1,
				text_obj: 'rsv_percent',
				listener: nil,
				text: '',
				format: "%2.1f",
				property: "/flight-management/fuel/rsv-percent"
			},
			{
				type: 'label',
				enabled:1,
				text_obj: 'altn_fuel',
				listener: nil,
				text: '',
				format: "%3.1f",
				property: "/flight-management/fuel/altn-fuel"
			},
			{
				type: 'label',
				enabled:1,
				text_obj: 'altn_time',
				listener: nil,
				text: '',
				format: "%s",
				property: "/flight-management/fuel/altn-time"
			},
			{
				type: 'label',
				enabled:1,
				text_obj: 'extra_fuel',
				listener: nil,
				text: '',
				format: "%3.1f",
				property: "/flight-management/fuel/extra-fuel"
			},
			{
				type: 'label',
				enabled:1,
				text_obj: 'extra_time',
				listener: nil,
				text: '',
				format: "%s",
				property: "/flight-management/fuel/extra-time"
			},
			{
				type: 'label',
				enabled:1,
				text_obj: 'tow',
				listener: nil,
				text: '',
				format: "%3.1f",
				property: "/flight-management/fuel/tow"
			},
			{
				type: 'label',
				enabled:1,
				text_obj: 'lw',
				listener: nil,
				text: '',
				format: "%3.1f",
				property: "/flight-management/fuel/lw"
			},
			{
				type: 'label',
				enabled:1,
				text_obj: 'fuel_dest',
				listener: nil,
				text: '',
				format: "%s",
				property: "/flight-management/arpt_to"
			},
			{
				type: 'label',
				enabled:1,
				text_obj: 'fuel_dest_utc',
				listener: nil,
				text: '',
				format: "%s",
				property: "/flight-management/fuel/dest_utc"
			},
			{
				type: 'label',
				enabled:1,
				text_obj: 'fuel_dest_efob',
				listener: nil,
				text: '',
				format: "%3.1f",
				property: "/flight-management/fuel/dest_fuel"
			},
			{
				type: 'label',
				enabled:1,
				text_obj: 'fuel_altn',
				listener: nil,
				text: '',
				format: "%s",
				property: "/flight-management/arpt_altn"
			},
			{
				type: 'label',
				enabled:1,
				text_obj: 'fuel_altn_utc',
				listener: nil,
				text: '',
				format: "%s",
				property: "/flight-management/fuel/altn_utc"
			},
			{
				type: 'label',
				enabled:1,
				text_obj: 'fuel_altn_efob',
				listener: nil,
				text: '',
				format: "%3.1f",
				property: "/flight-management/fuel/altn_fuel"
			},
			{
				type: 'textbox',
				field: 'tb_zfw',
				text_obj: 't_zfw',
				active: 0,
				listener: nil,
				text: '---.-',
				format: "%s",
				enter: func {
					calcFuelLoad();
				},
				property: "/flight-management/fuel/zfw"
			},
			{
				type: 'textbox',
				field: 'tb_zfwcg',
				text_obj: 't_zfwcg',
				active: 0,
				listener: nil,
				text: '--.-',
				format: "%s",
				enter: func {
					calcFuelLoad();
				},
				property: "/flight-management/fuel/zfwcg"
			},
			{
				type: 'textbox',
				field: 'tb_block',
				text_obj: 't_block',
				active: 0,
				listener: nil,
				text: '',
				format: "%s",
				enter: func {
					calcFuelLoad();
				},
				property: "/flight-management/fuel/blocks"
			},
			{
				type: 'textbox',
				field: 'tb_pax',
				text_obj: 't_pax',
				active: 0,
				listener: nil,
				text: '',
				format: "%s",
				enter: func {
					# calcFuelLoad();
				},
				property: "/flight-management/fuel/pax"
			},
			{
				type: 'textbox',
				field: 'tb_rsv',
				text_obj: 't_rsv',
				active: 0,
				listener: nil,
				text: '0.0',
				format: "%s",
				enter: func {
					calcFuelLoad();
				},
				property: "/flight-management/fuel/rte-rsv"
			},
			{
				type: 'textbox',
				field: 'tb_ci',
				text_obj: 't_ci',
				active: 0,
				listener: nil,
				text: '30',
				format: "%s",
				enter: func {
					# calcFuelLoad();
				},
				property: "/flight-management/fuel/ci"
			},
			{
				type: 'textbox',
				field: 'tb_min',
				text_obj: 't_min',
				active: 0,
				listener: nil,
				text: '---.-',
				format: "%s",
				enter: func {
					# calcFuelLoad();
				},
				property: "/flight-management/fuel/min-fuel"
			},
			{
				type: 'textbox',
				field: 'tb_final_fuel',
				text_obj: 't_final_fuel',
				active: 0,
				listener: nil,
				text: '0.0',
				format: "%s",
				enter: func {
					calcFuelLoad();
					setprop("/flight-management/fuel/final-time", getTimeString(getprop("/flight-management/fuel/final-fuel")/16)); # 16t/hr
				},
				property: "/flight-management/fuel/final-fuel"
			},
			{
				type: 'textbox',
				field: 'tb_final_time',
				text_obj: 't_final_time',
				active: 0,
				listener: nil,
				text: '00:00',
				format: "%s",
				enter: func {
					calcFuelLoad();
				},
				property: "/flight-management/fuel/final-time"
			},
			{
				type: 'textbox',
				field: 'tb_taxi',
				text_obj: 't_taxi',
				active: 0,
				listener: nil,
				text: '0.6',
				format: "%s",
				enter: func {
					calcFuelLoad();
				},
				property: "/flight-management/fuel/taxi"
			}
		];
		
		forindex(var n; t.widgets) {
			var widget = t.widgets[n];
			
			if(widget.type == 'click') {
				foreach(var obj; widget.objects) {
					t.active_textbox = -1;
					t.svgCache[obj].addEventListener("click", widget.function);
				}
			} elsif(widget.type == 'textbox') {
				t.svgCache[widget.text_obj].setText(widget.text);
				setlistener(widget.property, genUpdateFunc(t, widget));
				
				foreach(var obj; [widget.field, widget.text_obj])
				t.svgCache[obj].addEventListener("click", genTextBox(t, n, widget));
			} elsif(widget.type == 'label') {
				t.svgCache[widget.text_obj].setText(widget.text);
				setlistener(widget.property, genUpdateFunc(t, widget));
				if(widget.enabled != 1) {
					setlistener(widget.enabled, setVisibility(t, widget));
				}
			}
		}
		
		return t;
	},
	loadPage: func(menu, page) {
		if(page != me.activePage) {
			# Clear all other page layers and show active page layer
			if(menu != me.activeMenu) {
				foreach(var layer; me.menuLayers) {
					me.svgCache[layer].hide();
				}
				me.svgCache[menu].show();
				# Run page load function
				me.menus[menu].load();
			}
			foreach(var layer; me.pageLayers) {
				me.svgCache[layer].hide();
			}
			me.svgCache[page].show();
			# Run page load function
			me.menus[menu].pages[page].load();
		}
	},
	showDlg: func {
		if(getprop("sim/instrument-options/canvas-popup-enable")) {
		    var dlg = canvas.Window.new([400, 512], "dialog");
		    dlg.setCanvas(me.display);
		}
	}
};
