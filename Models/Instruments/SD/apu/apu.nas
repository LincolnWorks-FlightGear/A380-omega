# ECAM Systems Display - APU Page
# Narendran M (c) 2014

var INHG2PSI = 0.49109778;

sd.pages["apu"] = {
	path: "/Aircraft/A380-omega/Models/Instruments/SD/apu/apu.svg",
	svg: {},
	objects: ["apu_gena_percent", "apu_genb_percent", "apu_gena_v", "apu_genb_v", "apu_gena_hz", "apu_genb_hz", "apu_bleed_switch", "bleed_psi", "apu_avail", "apu_fused", "apu_n1", "apu_n2", "apu_egt", "apu_n1_needle", "apu_egt_needle", "apu_flap_open", "apu_oil_lvl_lo"],
	load: func {
		print("[ECAM] Loaded APU page on SD");
		# Nothing else here
	},
	update: func {
		animation.toggle_equals("/engines/engine[4]/running", 1, me.svg["apu_avail"]);
		animation.toggle_lte("/engines/engine[4]/oil-pressure-psi", 34, me.svg["apu_oil_lvl_lo"]);
		animation.toggle_lte("/engines/engine[4]/nozzle-pos-norm", 1, me.svg["apu_flap_open"]);
		me.svg["apu_n1"].setText(sprintf("%3.0f",getprop("/engines/engine[4]/n1")));
		me.svg["apu_n2"].setText(sprintf("%3.0f",getprop("/engines/engine[4]/n2")));
		me.svg["apu_egt"].setText(sprintf("%4.0f",getprop("/engines/engine[4]/egt_degc")));
		
		me.svg["apu_fused"].setText(sprintf("%5.0f",getprop("/engines/engine[4]/fuel-used-kg")));
		me.svg["bleed_psi"].setText(sprintf("%2.0f",getprop("/engines/engine[4]/epr")*getprop("/environment/pressure-inhg")*INHG2PSI));
		
		animation.rotary_switch("/controls/pressurization/apu/bleed-on", 0, 90, me.svg["apu_bleed_switch"]);
		
		# Indicator Needles
		me.svg["apu_n1_needle"].setCenter(174, 1048-665).setRotation(getprop("/engines/engine[4]/n1")*1.7*D2R);
		me.svg["apu_egt_needle"].setCenter(174, 1048-449).setRotation(getprop("/engines/engine[4]/egt_degc")*(180/1000)*D2R);
		
		# APU Generators
		me.svg["apu_gena_percent"].setText(sprintf("%3.0f",getprop("/systems/electric/suppliers/apu-gen-a/amps")/0.6));
		me.svg["apu_gena_v"].setText(sprintf("%3.0f",getprop("/systems/electric/suppliers/apu-gen-a/volts")));
		me.svg["apu_gena_hz"].setText(sprintf("%4.0f",getprop("/engines/engine[4]/gena-hz")));
		me.svg["apu_genb_percent"].setText(sprintf("%3.0f",getprop("/systems/electric/suppliers/apu-gen-b/amps")/0.6));
		me.svg["apu_genb_v"].setText(sprintf("%3.0f",getprop("/systems/electric/suppliers/apu-gen-b/volts")));
		me.svg["apu_genb_hz"].setText(sprintf("%4.0f",getprop("/engines/engine[4]/genb-hz")));
	}
};
