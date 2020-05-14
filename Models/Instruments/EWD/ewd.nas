# (Airbus A380) E/WD - Engine and Warnings Display
# Narendran M (c) 2014

var placement = "ewd";

var ewd_pages = {};

ewd_pages["start"] = {
	path: "/Aircraft/A380-omega/Models/Instruments/EWD/ecam_ewd.svg",
	svg: {},
	objects: ["eng1_off", "eng2_off", "eng3_off", "eng4_off", "eng1_fwd", "eng2_fwd", "eng3_fwd", "eng4_fwd", "eng1_rev", "eng2_rev", "eng3_rev", "eng4_rev", "egt1", "egt2", "egt3", "egt4", "egt1_text", "egt2_text", "egt3_text", "egt4_text", "egt1_off", "egt2_off", "egt3_off", "egt4_off", "egt1_needle", "egt2_needle", "egt3_needle", "egt4_needle", "eng1_thrlever", "eng2_thrlever", "eng3_thrlever", "eng4_thrlever", "eng1_thrneedle", "eng2_thrneedle", "eng3_thrneedle", "eng4_thrneedle", "eng1_thrtext", "eng2_thrtext", "eng3_thrtext", "eng4_thrtext", "packs_nai", "packs_nai", "title_left", "title_center", "item_1", "item_2", "item_3", "item_4", "item_5", "item_6", "item_7", "item_8", "item_9", "item_10", "item_11", "item_12", "item_13", "item_14", "resp_1", "resp_2", "resp_3", "resp_4", "resp_5", "resp_6", "resp_7", "resp_8", "resp_9", "resp_10", "resp_11", "resp_12", "resp_13", "resp_14", "checkbox_1", "checkbox_2", "checkbox_3", "checkbox_4", "checkbox_5", "checkbox_6", "checkbox_7", "checkbox_8", "checkbox_9", "checkbox_10", "checkbox_11", "checkbox_12", "checkbox_13", "checkbox_14", "check_1", "check_2", "check_3", "check_4", "check_5", "check_6", "check_7", "check_8", "check_9", "check_10", "check_11", "check_12", "check_13", "check_14", "box_1", "box_2", "box_3", "box_4", "box_5", "box_6", "box_7", "box_8", "box_9", "box_10", "box_11", "box_12", "box_13", "box_14", "limit1", "limit2", "limit3", "limit4", "limit5", "limit6", "memo1", "memo2", "memo3", "memo4", "memo5", "memo6", "divider", "dots_1", "dots_2", "dots_3", "dots_4", "dots_5", "dots_6", "dots_7", "dots_8", "dots_9", "dots_10", "dots_11", "dots_12", "dots_13", "dots_14"],
	eng_x: [0, 93, 271, 525, 703],
	egt_x: [0, 100, 278, 532, 710],
	load: func {
		print("[ECAM] Loaded E/WD page");
		# Nothing much here
	},
	update: func {
		
####### Engine Status ##########################################################

		for(var n=1; n<=4; n=n+1) {
			var n1 = getprop("/engines/engine["~(n-1)~"]/n1");
			var n2 = getprop("/engines/engine["~(n-1)~"]/n2");
			var egt = (getprop("/engines/engine["~(n-1)~"]/egt-degf")-32)*(5/9);
			var reversed = getprop("/engines/engine["~(n-1)~"]/reversed");
			var lvr = getprop("/controls/engines/engine["~(n-1)~"]/throttle");
			var thr = (n2-58)*(100/42);
			if(thr < 0) {
				thr = 0;
			}
			
			if(n2 > 25) { # Engine Started
				if(reversed) { # Reverse Thrust Engaged
					me.svg["eng"~n~"_off"].hide();
					me.svg["eng"~n~"_rev"].show();
					me.svg["eng"~n~"_fwd"].hide();
					me.svg["egt"~n~"_off"].hide();
					me.svg["egt"~n].show();
					me.svg["eng"~n~"_thrlever"].show().setCenter(me.eng_x[n], 1050-890).setRotation(-lvr*110*D2R);
					me.svg["eng"~n~"_thrneedle"].show().setCenter(me.eng_x[n], 1050-890).setRotation(-thr*1.1*D2R);
					me.svg["eng"~n~"_thrtext"].hide();
					me.svg["egt"~n~"_needle"].show().setCenter(me.egt_x[n], 1050-697).setRotation(egt*(180/870)*D2R);
					me.svg["egt"~n~"_text"].show().setText(sprintf("%4.0f", egt));
				} else { # Reverse Thrust Disengaged
					me.svg["eng"~n~"_off"].hide();
					me.svg["eng"~n~"_rev"].hide();
					me.svg["eng"~n~"_fwd"].show();
					me.svg["egt"~n~"_off"].hide();
					me.svg["egt"~n].show();
					me.svg["eng"~n~"_thrlever"].show().setCenter(me.eng_x[n], 1050-890).setRotation(lvr*210*D2R);
					me.svg["eng"~n~"_thrneedle"].show().setCenter(me.eng_x[n], 1050-890).setRotation(thr*2.1*D2R);
					me.svg["eng"~n~"_thrtext"].show().setText(sprintf("%3.1f", thr));
					me.svg["egt"~n~"_needle"].show().setCenter(me.egt_x[n], 1050-697).setRotation(egt*(180/870)*D2R);
					me.svg["egt"~n~"_text"].show().setText(sprintf("%4.0f", egt));
				}
			} else { # Engine turned off
				me.svg["eng"~n~"_off"].show();
				me.svg["eng"~n~"_rev"].hide();
				me.svg["eng"~n~"_fwd"].hide();
				me.svg["egt"~n~"_off"].show();
				me.svg["egt"~n].hide();
				me.svg["eng"~n~"_thrlever"].hide();
				me.svg["eng"~n~"_thrneedle"].hide();
				me.svg["eng"~n~"_thrtext"].hide();
				me.svg["egt"~n~"_needle"].hide();
				me.svg["egt"~n~"_text"].hide();
			}
		}

####### Warnings Display #######################################################

		alerts.update();

		if(alerts.mode == 'CHECKLIST_MENU') {
			
			me.svg["title_center"].hide();
			me.svg["divider"].hide();
			for(var n=1; n<=6; n=n+1) {
				me.svg["limit"~n].hide();
				me.svg["memo"~n].hide();
			}
			me.svg["title_left"].setText("CHECKLISTS").setColor(alerts.colors['white']).show();
			
			var nbr = size(alerts.items);
			
			for(var n=0; n<nbr; n=n+1) {
				me.svg["item_"~(n+1)].show().setText(alerts.items[n].desc).setColor(alerts.colors[alerts.items[n].color]);
				me.svg["resp_"~(n+1)].hide();
				me.svg["checkbox_"~(n+1)].hide();
				me.svg["check_"~(n+1)].hide();
				if(n == alerts.active_item) {
					me.svg["box_"~(n+1)].show();
				} else {
					me.svg["box_"~(n+1)].hide();
				}
				me.svg["dots_"~(n+1)].hide();
			}
			
			for(var n=nbr; n<14; n=n+1) {
				me.svg["item_"~(n+1)].hide();
				me.svg["resp_"~(n+1)].hide();
				me.svg["checkbox_"~(n+1)].hide();
				me.svg["check_"~(n+1)].hide();
				if(n == alerts.active_item) {
					me.svg["box_"~(n+1)].show();
				} else {
					me.svg["box_"~(n+1)].hide();
				}
				me.svg["dots_"~(n+1)].hide();
			}
			
		} elsif(alerts.mode == 'CHECKLIST') {
			
			me.svg["title_center"].hide();
			me.svg["divider"].hide();
			for(var n=1; n<=6; n=n+1) {
				me.svg["limit"~n].hide();
				me.svg["memo"~n].hide();
			}
			me.svg["title_left"].setText(checklists[alerts.checklist].title).setColor(alerts.colors['white']).show();
			
			var nbr = size(alerts.items);
			
			for(var n=0; n<14; n=n+1) {
				if(n<nbr) {
					me.svg["item_"~(n+1)].show().setColorFill([0,0,0,1]).setDrawMode(me.svg["item_"~(n+1)].TEXT + me.svg["item_"~(n+1)].FILLEDBOUNDINGBOX).setText(alerts.items[n].desc).setColor(alerts.colors[alerts.items[n].color]).setPadding(8);
					me.svg["resp_"~(n+1)].show().setColorFill([0,0,0,1]).setDrawMode(me.svg["resp_"~(n+1)].TEXT + me.svg["resp_"~(n+1)].FILLEDBOUNDINGBOX).setText(alerts.items[n].resp).setColor(alerts.colors[alerts.items[n].color]).setPadding(8);
					if(alerts.items[n].checkbox == 1) {
						me.svg["checkbox_"~(n+1)].show().setColor(alerts.colors[alerts.items[n].color]);
						if(alerts.items[n].checked == 1) {
							me.svg["check_"~(n+1)].show().setColor(alerts.colors[alerts.items[n].color]);
						} else {
							me.svg["check_"~(n+1)].hide();
						}
					} else {
						me.svg["checkbox_"~(n+1)].hide();
						me.svg["check_"~(n+1)].hide();
					}
					me.svg["dots_"~(n+1)].show().setColor(alerts.colors[alerts.items[n].color]);
				
				} else {
					me.svg["item_"~(n+1)].hide();
					me.svg["resp_"~(n+1)].hide();
					me.svg["checkbox_"~(n+1)].hide();
					me.svg["check_"~(n+1)].hide();
					me.svg["dots_"~(n+1)].hide();
				}
				
				if(n == alerts.active_item) {
					me.svg["box_"~(n+1)].show();
				} else {
					me.svg["box_"~(n+1)].hide();
				}
			}
			
		} else { # DEFAULT MODE - LIMIT
			
			for(var n=0; n<14; n=n+1) {
				me.svg["item_"~(n+1)].hide();
				me.svg["resp_"~(n+1)].hide();
				me.svg["checkbox_"~(n+1)].hide();
				me.svg["check_"~(n+1)].hide();
				if(n == alerts.active_item) {
					me.svg["box_"~(n+1)].show();
				} else {
					me.svg["box_"~(n+1)].hide();
				}
				me.svg["dots_"~(n+1)].hide();
			}
			
			me.svg["title_left"].hide();
			me.svg["divider"].show();
			me.svg["title_center"].show().setText("LIMITATIONS");
			
			var limits_nbr = size(alerts.limits);
			var memos_nbr = size(alerts.memos);
			
			for(var n=0; n<6; n=n+1) {
				if(n<limits_nbr) {
					me.svg["limit"~(n+1)].show().setColor(alerts.colors[alerts.limits[n].color]).setText(alerts.limits[n].desc);
				} else {
					me.svg["limit"~(n+1)].hide();
				}
				
				if(n<memos_nbr) {
					me.svg["memo"~(n+1)].show().setColor(alerts.colors[alerts.memos[n].color]).setText(alerts.memos[n].desc);
				} else {
					me.svg["memo"~(n+1)].hide();
				}
			}
			
		}
		
	}
};

var ewd = ecam.new(ewd_pages, placement);

ewd.load("start");

setlistener("sim/signals/fdm-initialized", func {
	ewd.init();
	print("Engine and Warnings Display Initialized");
});
