# ECAM Systems Display - HYD Page
# Narendran M (c) 2014

sd.pages["hyd"] = {
	path: "/Aircraft/A380-omega/Models/Instruments/SD/hyd/hyd.svg",
	svg: {},
	objects: ["hyd_green_psi", "hyd_yellow_psi", "eng1_hyd_pump_a", "eng1_hyd_pump_b", "eng2_hyd_pump_a", "eng2_hyd_pump_b", "eng3_hyd_pump_a", "eng3_hyd_pump_b", "eng4_hyd_pump_a", "eng4_hyd_pump_b"],
	green: [0, 0.86, 0],
	orange: [1, 0.55, 0],
	load: func {
		print("[ECAM] Loaded HYD page on SD");
		sd.objects.createChild("image")
				  .setFile("Models/Instruments/SD/hyd/engine.png")
				  .setSize(168, 336)
				  .setTranslation(-1, 178)
				  .set("z-index", -1);
		sd.objects.createChild("image")
				  .setFile("Models/Instruments/SD/hyd/engine.png")
				  .setSize(168, 336)
				  .setTranslation(158, 134)
				  .set("z-index", -1);
		sd.objects.createChild("image")
				  .setFile("Models/Instruments/SD/hyd/engine.png")
				  .setSize(168, 336)
				  .setTranslation(465, 134)
				  .set("z-index", -1);
		sd.objects.createChild("image")
				  .setFile("Models/Instruments/SD/hyd/engine.png")
				  .setSize(168, 336)
				  .setTranslation(625, 178)
				  .set("z-index", -1);
	},
	update: func {
		me.svg["hyd_green_psi"].setText(sprintf("%4.0f", getprop("/systems/hydraulics/green/pressure-psi")));
		me.svg["hyd_yellow_psi"].setText(sprintf("%4.0f", getprop("/systems/hydraulics/yellow/pressure-psi")));
		
		for(var n=0; n<4; n=n+1) {
			animation.color_rotary_switch("/controls/hydraulics/engine["~n~"]/pump-a", 0, 90, me.svg["eng"~(n+1)~"_hyd_pump_a"], me.orange, me.green);
			animation.color_rotary_switch("/controls/hydraulics/engine["~n~"]/pump-b", 0, 90, me.svg["eng"~(n+1)~"_hyd_pump_b"], me.orange, me.green);
		}
	}
};
