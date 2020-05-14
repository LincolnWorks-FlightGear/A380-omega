# ECAM Systems Display - F/CTL Page
# Narendran M (c) 2014

sd.pages["fuel"] = {
	path: "/Aircraft/A380-omega/Models/Instruments/SD/fuel/fuel.svg",
	svg: {},
	objects: ["lvl_feed_tk_1", "lvl_feed_tk_2", "lvl_feed_tk_3", "lvl_feed_tk_4", "lvl_l_outer_tk", "lvl_l_mid_tk", "lvl_l_inner_tk", "lvl_r_outer_tk", "lvl_r_mid_tk", "lvl_r_inner_tk", "lvl_trim_tk", "feed_tk_1", "feed_tk_2", "feed_tk_3", "feed_tk_4", "eng1_master", "eng2_master", "eng3_master", "eng4_master", "eng1_crossfeed", "eng2_crossfeed", "eng3_crossfeed", "eng4_crossfeed", "eng1_crossfeed", "l_outer_tk", "l_mid_tk", "l_inner_tk", "r_outer_tk", "r_mid_tk", "r_inner_tk", "fu_eng1", "fu_eng2", "fu_eng3", "fu_eng4", "fu_total", "fuel_rate", "trim_l", "trim_r"],
	load: func {
		print("[ECAM] Loaded FUEL page on SD");
		
		sd.objects.createChild("image")
				  .setFile("Models/Instruments/SD/fuel/engine_l.png")
				  .setSize(100, 200)
				  .setTranslation(68, 68)
				  .set("z-index", -1);
				  
		sd.objects.createChild("image")
				  .setFile("Models/Instruments/SD/fuel/engine_l.png")
				  .setSize(100, 200)
				  .setTranslation(234, 46)
				  .set("z-index", -1);
		
		sd.objects.createChild("image")
				  .setFile("Models/Instruments/SD/fuel/engine_r.png")
				  .setSize(100, 200)
				  .setTranslation(465, 46)
				  .set("z-index", -1);
		
		sd.objects.createChild("image")
				  .setFile("Models/Instruments/SD/fuel/engine_r.png")
				  .setSize(100, 200)
				  .setTranslation(631, 68)
				  .set("z-index", -1);
				  
	},
	update: func {
	
		# FUEL USED
	
		var fu_eng1 = getprop("/engines/engine/fuel-used-kg");
		var fu_eng2 = getprop("/engines/engine[1]/fuel-used-kg");
		var fu_eng3 = getprop("/engines/engine[2]/fuel-used-kg");
		var fu_eng4 = getprop("/engines/engine[3]/fuel-used-kg");
		
		var fu_total = fu_eng1 + fu_eng2 + fu_eng3 + fu_eng4;
	
		me.svg["fu_eng1"].setText(sprintf("%5.0f", fu_eng1));
		me.svg["fu_eng2"].setText(sprintf("%5.0f", fu_eng2));
		me.svg["fu_eng3"].setText(sprintf("%5.0f", fu_eng3));
		me.svg["fu_eng4"].setText(sprintf("%5.0f", fu_eng4));
		
		me.svg["fu_total"].setText(sprintf("%5.0f", fu_total));
		
		# FUEL TK QUANTITIES
		
		me.svg["lvl_feed_tk_1"].setText(sprintf("%5.0f", getprop("/consumables/fuel/tank[0]/level-kg")));
		me.svg["lvl_feed_tk_2"].setText(sprintf("%5.0f", getprop("/consumables/fuel/tank[1]/level-kg")));
		me.svg["lvl_feed_tk_3"].setText(sprintf("%5.0f", getprop("/consumables/fuel/tank[2]/level-kg")));
		me.svg["lvl_feed_tk_4"].setText(sprintf("%5.0f", getprop("/consumables/fuel/tank[3]/level-kg")));
		me.svg["lvl_l_outer_tk"].setText(sprintf("%5.0f", getprop("/consumables/fuel/tank[8]/level-kg")));
		me.svg["lvl_l_mid_tk"].setText(sprintf("%5.0f", getprop("/consumables/fuel/tank[6]/level-kg")));
		me.svg["lvl_l_inner_tk"].setText(sprintf("%5.0f", getprop("/consumables/fuel/tank[4]/level-kg")));
		me.svg["lvl_r_outer_tk"].setText(sprintf("%5.0f", getprop("/consumables/fuel/tank[9]/level-kg")));
		me.svg["lvl_r_mid_tk"].setText(sprintf("%5.0f", getprop("/consumables/fuel/tank[7]/level-kg")));
		me.svg["lvl_r_inner_tk"].setText(sprintf("%5.0f", getprop("/consumables/fuel/tank[5]/level-kg")));
		me.svg["lvl_trim_tk"].setText(sprintf("%5.0f", getprop("/consumables/fuel/tank[10]/level-kg")));
		
		# TOTAL FUEL FLOW RATE
		
		var ff = 0;
		for(var n=0; n<4; n=n+1) {
			ff = ff + getprop("/engines/engine/fuel-flow_pph")*LB2KG;
		}
		me.svg["fuel_rate"].setText(sprintf("%6.0f", ff));
		
		# FUEL PUMP SWITCHES
		
		for(var n=0; n<4; n=n+1) {
			animation.rotary_switch("/controls/engines/engine["~n~"]/cutoff", 1, 90, me.svg["eng"~(n+1)~"_master"]);
			animation.rotary_switch("/controls/fuel/crossfeed/pump-"~(n+1), 1, 90, me.svg["eng"~(n+1)~"_crossfeed"]);
			animation.rotary_switch("/consumables/fuel/tank["~n~"]/selected", 0, 90, me.svg["feed_tk_"~(n+1)]);
		}
		
		animation.rotary_switch("/controls/fuel/l-outer-tk/pump", 0, 90, me.svg["l_outer_tk"]);
		animation.rotary_switch("/controls/fuel/r-outer-tk/pump", 0, 90, me.svg["r_outer_tk"]);
		animation.rotary_switch("/controls/fuel/l-mid-tk/pump-fwd", 0, 90, me.svg["l_mid_tk"]);
		animation.rotary_switch("/controls/fuel/r-mid-tk/pump-fwd", 0, 90, me.svg["r_mid_tk"]);
		animation.rotary_switch("/controls/fuel/l-inr-tk/pump-fwd", 0, 90, me.svg["l_inner_tk"]);
		animation.rotary_switch("/controls/fuel/r-inr-tk/pump-fwd", 0, 90, me.svg["r_inner_tk"]);
		animation.rotary_switch("/controls/fuel/trim-tk/pump-l", 0, 90, me.svg["trim_l"]);
		animation.rotary_switch("/controls/fuel/trim-tk/pump-r", 0, 90, me.svg["trim_r"]);
		
	}
};
