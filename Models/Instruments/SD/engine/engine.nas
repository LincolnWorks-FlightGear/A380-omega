# ECAM Systems Display - ENGINE Page
# Narendran M (c) 2014

sd.pages["engine"] = {
	path: "/Aircraft/A380-omega/Models/Instruments/SD/engine/engine.svg",
	svg: {},
	objects: ["eng1_n2", "eng2_n2", "eng3_n2", "eng4_n2", "eng1_ff", "eng2_ff", "eng3_ff", "eng4_ff", "eng1_oil_temp", "eng2_oil_temp", "eng3_oil_temp", "eng4_oil_temp", "eng1_oil_psi", "eng2_oil_psi", "eng3_oil_psi", "eng4_oil_psi", "eng1_vib_n1", "eng1_vib_n2", "eng2_vib_n1", "eng2_vib_n2", "eng3_vib_n1", "eng3_vib_n2", "eng4_vib_n1", "eng4_vib_n2", "eng1_oil_psi_needle", "eng1_nac", "eng2_oil_psi_needle", "eng2_nac", "eng3_oil_psi_needle", "eng3_nac", "eng4_oil_psi_needle", "eng4_nac"],
	load: func {
		print("[ECAM] Loaded ENGINE page on SD");
	},
	needle_x: [73, 239, 563, 729],
	update: func {
		for(var n=1; n<=4; n=n+1) {
			
			var tree = "/engines/engine["~(n-1)~"]/";
			
			var n2 = getprop(tree~"n2");
			var ff = getprop(tree~"fuel-flow_pph")*LB2KG;
			var oil_psi = getprop(tree~"oil-pressure-psi");
			
			var epr = getprop(tree~"epr");
			
			var oil_temp = getprop("/environment/temperature-degc") + (0.5*oil_psi);
			
			# Simulate Vibrations (just for display)
			var vib_n1 = getprop(tree~"n1")*0.01*(epr-1);
			var vib_n2 = getprop(tree~"n2")*0.015*(epr-1);
			
			var nac = getprop(tree~"egt-degf")*0.35; # Not sure what this is, really
			
			me.svg["eng"~n~"_n2"].setText(sprintf("%2.1f", n2));
			me.svg["eng"~n~"_ff"].setText(sprintf("%5.0f", ff));
			
			me.svg["eng"~n~"_oil_temp"].setText(sprintf("%3.0f", oil_temp));
			
			me.svg["eng"~n~"_oil_psi"].setText(sprintf("%3.0f", oil_psi));
			
			me.svg["eng"~n~"_vib_n1"].setText(sprintf("%2.1f", vib_n1));
			me.svg["eng"~n~"_vib_n2"].setText(sprintf("%2.1f", vib_n2));
			
			# Indicator Needles
			me.svg["eng"~n~"_oil_psi_needle"].setCenter(me.needle_x[(n-1)], 1048-620).setRotation(oil_psi*2*D2R);
			me.svg["eng"~n~"_nac"].setCenter(me.needle_x[(n-1)], 1048-410).setRotation(nac*(180/520)*D2R);
			
		}
	}
};
