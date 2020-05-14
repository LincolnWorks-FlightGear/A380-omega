# ECAM Systems Display - F/CTL Page
# Narendran M (c) 2014

sd.pages["fctl"] = {
	path: "/Aircraft/A380-omega/Models/Instruments/SD/fctl/fctl.svg",
	svg: {},
	objects: ["pitch_trim", "pitch_trim_text", "hyd_green", "hyd_yellow", "hyd_elec_backup"],
	load: func {
		print("[ECAM] Loaded F/CTL page on SD");
		# Load Raster Image
		sd.objects.createChild("image")
				  .setFile("Models/Instruments/SD/fctl/background.png")
				  .setSize(800, 800)
				  .set("z-index", -1);
				  
		me.elev_lob = sd.objects.createChild("path").set("z-index", 1);
		me.elev_lib = sd.objects.createChild("path").set("z-index", 1);
		me.elev_rib = sd.objects.createChild("path").set("z-index", 1);
		me.elev_rob = sd.objects.createChild("path").set("z-index", 1);
		
		me.rudd_upper = sd.objects.createChild("path").set("z-index", 1);
		me.rudd_lower = sd.objects.createChild("path").set("z-index", 1);
		
		me.alrn_lob = sd.objects.createChild("path").set("z-index", 1);
		me.alrn_lmd = sd.objects.createChild("path").set("z-index", 1);
		me.alrn_lib = sd.objects.createChild("path").set("z-index", 1);
		me.alrn_rob = sd.objects.createChild("path").set("z-index", 1);
		me.alrn_rmd = sd.objects.createChild("path").set("z-index", 1);
		me.alrn_rib = sd.objects.createChild("path").set("z-index", 1);
		
		me.lsp1 = sd.objects.createChild("path").set("z-index", 1);
		me.lsp2 = sd.objects.createChild("path").set("z-index", 1);
		me.lsp3 = sd.objects.createChild("path").set("z-index", 1);
		me.lsp4 = sd.objects.createChild("path").set("z-index", 1);
		me.lsp5 = sd.objects.createChild("path").set("z-index", 1);
		me.lsp6 = sd.objects.createChild("path").set("z-index", 1);
		me.lsp7 = sd.objects.createChild("path").set("z-index", 1);
		me.lsp8 = sd.objects.createChild("path").set("z-index", 1);
		
		me.rsp1 = sd.objects.createChild("path").set("z-index", 1);
		me.rsp2 = sd.objects.createChild("path").set("z-index", 1);
		me.rsp3 = sd.objects.createChild("path").set("z-index", 1);
		me.rsp4 = sd.objects.createChild("path").set("z-index", 1);
		me.rsp5 = sd.objects.createChild("path").set("z-index", 1);
		me.rsp6 = sd.objects.createChild("path").set("z-index", 1);
		me.rsp7 = sd.objects.createChild("path").set("z-index", 1);
		me.rsp8 = sd.objects.createChild("path").set("z-index", 1);
	},
	update: func {
		animation.toggle_gte("/systems/hydraulics/green/pressure-psi", 1400, me.svg["hyd_green"]);
		animation.toggle_gte("/systems/hydraulics/yellow/pressure-psi", 1400, me.svg["hyd_yellow"]);
		animation.toggle_gte("/systems/hydraulics/elec-backup/pressure-psi", 800, me.svg["hyd_elec_backup"]);
		
		var pitch_trim = getprop("/controls/flight/elevator-trim");
		me.svg["pitch_trim"].setTranslation(0,-63*pitch_trim);
		if(pitch_trim > 0) {
			me.svg["pitch_trim_text"].setText(sprintf("%1.1f DN", pitch_trim*6));
		} elsif(pitch_trim < 0) {
			me.svg["pitch_trim_text"].setText(sprintf("%2.1f UP", -pitch_trim*15));
		} else {
			me.svg["pitch_trim_text"].setText("0.0");
		}
		
		# Control Surface Positions
		animation.surface_position("/fdm/jsbsim/fcs/rudder-fbw-output", [401, 1024-910], 16, -61, 'h', me.rudd_upper, sd.objects, [0, 0.95, 0]);
		animation.surface_position("/fdm/jsbsim/fcs/rudder-fbw-output", [401, 1024-876], 16, -61, 'h', me.rudd_lower, sd.objects, [0, 0.95, 0]);
		
		animation.surface_position("/fdm/jsbsim/fcs/elev-lob-output", [204, 1024-741], 16, 61, 'v', me.elev_lob, sd.objects, [0, 0.95, 0]);
		animation.surface_position("/fdm/jsbsim/fcs/elev-lib-output", [226, 1024-741], 16, 61, 'v', me.elev_lib, sd.objects, [0, 0.95, 0]);
		animation.surface_position("/fdm/jsbsim/fcs/elev-rib-output", [558, 1024-741], 16, 61, 'v', me.elev_rib, sd.objects, [0, 0.95, 0]);
		animation.surface_position("/fdm/jsbsim/fcs/elev-rob-output", [580, 1024-741], 16, 61, 'v', me.elev_rob, sd.objects, [0, 0.95, 0]);
		
		animation.surface_position("/fdm/jsbsim/fcs/alrn-lob-fbw-output", [44, 1024-466], 16, 61, 'v', me.alrn_lob, sd.objects, [0, 0.95, 0]);
		animation.surface_position("/fdm/jsbsim/fcs/alrn-lmd-fbw-output", [68, 1024-466], 16, 61, 'v', me.alrn_lmd, sd.objects, [0, 0.95, 0]);
		animation.surface_position("/fdm/jsbsim/fcs/alrn-lib-fbw-output", [92, 1024-466], 16, 61, 'v', me.alrn_lib, sd.objects, [0, 0.95, 0]);
		animation.surface_position("/fdm/jsbsim/fcs/alrn-rob-fbw-output", [742, 1024-466], 16, -61, 'v', me.alrn_rob, sd.objects, [0, 0.95, 0]);
		animation.surface_position("/fdm/jsbsim/fcs/alrn-rmd-fbw-output", [718, 1024-466], 16, -61, 'v', me.alrn_rmd, sd.objects, [0, 0.95, 0]);
		animation.surface_position("/fdm/jsbsim/fcs/alrn-rib-fbw-output", [694, 1024-466], 16, -61, 'v', me.alrn_rib, sd.objects, [0, 0.95, 0]);
		
		animation.surface_position("/fdm/jsbsim/fcs/lsp8-fbw-output", [154, 1024-465], 16, -37, 'v', me.lsp8, sd.objects, [0, 0.95, 0]);
		animation.surface_position("/fdm/jsbsim/fcs/lsp7-fbw-output", [180, 1024-465], 16, -37, 'v', me.lsp7, sd.objects, [0, 0.95, 0]);
		animation.surface_position("/fdm/jsbsim/fcs/lsp6-fbw-output", [208, 1024-463], 16, -37, 'v', me.lsp6, sd.objects, [0, 0.95, 0]);
		animation.surface_position("/fdm/jsbsim/fcs/lsp5-fbw-output", [234, 1024-463], 16, -37, 'v', me.lsp5, sd.objects, [0, 0.95, 0]);
		animation.surface_position("/fdm/jsbsim/fcs/lsp4-fbw-output", [262, 1024-461], 16, -37, 'v', me.lsp4, sd.objects, [0, 0.95, 0]);
		animation.surface_position("/fdm/jsbsim/fcs/lsp3-fbw-output", [288, 1024-460], 16, -37, 'v', me.lsp3, sd.objects, [0, 0.95, 0]);
		animation.surface_position("/fdm/jsbsim/fcs/lsp2-fbw-output", [314, 1024-457], 16, -37, 'v', me.lsp2, sd.objects, [0, 0.95, 0]);
		animation.surface_position("/fdm/jsbsim/fcs/lsp1-fbw-output", [342, 1024-454], 16, -37, 'v', me.lsp1, sd.objects, [0, 0.95, 0]);
		
		animation.surface_position("/fdm/jsbsim/fcs/rsp8-fbw-output", [632, 1024-465], 16, -37, 'v', me.rsp8, sd.objects, [0, 0.95, 0]);
		animation.surface_position("/fdm/jsbsim/fcs/rsp7-fbw-output", [606, 1024-465], 16, -37, 'v', me.rsp7, sd.objects, [0, 0.95, 0]);
		animation.surface_position("/fdm/jsbsim/fcs/rsp6-fbw-output", [578, 1024-463], 16, -37, 'v', me.rsp6, sd.objects, [0, 0.95, 0]);
		animation.surface_position("/fdm/jsbsim/fcs/rsp5-fbw-output", [552, 1024-463], 16, -37, 'v', me.rsp5, sd.objects, [0, 0.95, 0]);
		animation.surface_position("/fdm/jsbsim/fcs/rsp4-fbw-output", [524, 1024-461], 16, -37, 'v', me.rsp4, sd.objects, [0, 0.95, 0]);
		animation.surface_position("/fdm/jsbsim/fcs/rsp3-fbw-output", [498, 1024-460], 16, -37, 'v', me.rsp3, sd.objects, [0, 0.95, 0]);
		animation.surface_position("/fdm/jsbsim/fcs/rsp2-fbw-output", [472, 1024-457], 16, -37, 'v', me.rsp2, sd.objects, [0, 0.95, 0]);
		animation.surface_position("/fdm/jsbsim/fcs/rsp1-fbw-output", [444, 1024-454], 16, -37, 'v', me.rsp1, sd.objects, [0, 0.95, 0]);
	}
};
