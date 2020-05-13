# A380 Electrical system
# Derived from my Electrical Framework for the ATR72-500(C)
# Narendran Muraleedharan (c) 2014

# Main Electrical Loop

var electrical = {
       init : func {
            me.UPDATE_INTERVAL = 1;
            me.loopid = 0;
            
			# Create Electrical Systems (using suppliers, buses and outputs)
			
			# Create Suppliers
			
			suppliers = [supplier.new("eng1-gen", "AC", 115, 250, 1, "/engines/engine/n2", 100, 5, "/controls/electric/contact/engine_1"),
						supplier.new("eng2-gen", "AC", 115, 250, 1, "/engines/engine[1]/n2", 100, 5, "/controls/electric/contact/engine_2"),
						supplier.new("eng3-gen", "AC", 115, 250, 1, "/engines/engine[2]/n2", 100, 5, "/controls/electric/contact/engine_3"),
						supplier.new("eng4-gen", "AC", 115, 250, 1, "/engines/engine[3]/n2", 100, 5, "/controls/electric/contact/engine_4"),
						supplier.new("bat-1", "DC", 29, 16, 0, "", 0, 0, "/controls/electric/contact/batt_1"),
						supplier.new("bat-2", "DC", 29, 16, 0, "", 0, 0, "/controls/electric/contact/batt_2"),
						supplier.new("bat-ess", "DC", 24, 40, 0, "", 0, 0, "/controls/electric/contact/ess_bat"),
						supplier.new("bat-apu", "DC", 12, 16, 0, "", 0, 0, "/controls/electric/contact/apu_bat"),
						supplier.new("ext-pwr-1", "AC", 115, 160, 0, "", 0, 0, "/controls/electric/contact/external_1"),
						supplier.new("ext-pwr-2", "AC", 115, 160, 0, "", 0, 0, "/controls/electric/contact/external_2"),
						supplier.new("ext-pwr-3", "AC", 115, 160, 0, "", 0, 0, "/controls/electric/contact/external_3"),
						supplier.new("ext-pwr-4", "AC", 115, 160, 0, "", 0, 0, "/controls/electric/contact/external_4"),
						supplier.new("apu-gen-a", "AC", 115, 60, 1, "/engines/engine[4]/n2", 100, 5, "/controls/electric/contact/apu_gen-a"),
						supplier.new("apu-gen-b", "AC", 115, 60, 1, "/engines/engine[4]/n2", 100, 5, "/controls/electric/contact/apu_gen-b"),
						supplier.new("ram-air-turbine", "DC", 29, 18, 1, "/velocities/airspeed-kt", 300, 110, "/controls/electric/emer/rat-down")];
			
			# Suppliers in a bus must supply similar voltages
			buses = [bus.new("ac-bus-1", "AC", ["eng1-gen", "ext-pwr-1"]),
					bus.new("ac-bus-2", "AC", ["eng2-gen", "ext-pwr-2", "apu-gen-a"]),
					bus.new("ac-bus-3", "AC", ["eng3-gen", "ext-pwr-3", "apu-gen-b"]),
					bus.new("ac-bus-4", "AC", ["eng4-gen", "ext-pwr-4"]),
					bus.new("dc-bus", "DC", ["bat-1", "bat-2", "bat-ess", "bat-apu"]),
					bus.new("emer-bus", "DC", ["ram-air-turbine"])];
								
			outputs = [output.new("avionics", 12, 4, ["dc-bus", "emer-bus", "ac-bus-3"]), 
				output.new("comm0", 12, 8, ["dc-bus", "ac-bus-3"]),
				output.new("efis", 18, 8, ["dc-bus", "ac-bus-3"]),
				output.new("comm1", 12, 8, ["dc-bus", "ac-bus-4"]),
				output.new("anti-icing", 24, 2, ["ac-bus-1", "ac-bus-4"]), 
				output.new("ext-lts", 24, 12, ["ac-bus-2", "ac-bus-3"]), 
				output.new("nav0", 16, 8, ["dc-bus", "ac-bus-3"]),
				output.new("nav1", 16, 8, ["dc-bus", "ac-bus-4"]),
				output.new("adf", 12, 6, ["dc-bus", "ac-bus-3"]),
				output.new("dme", 12, 6, ["dc-bus", "ac-bus-3"]),
				output.new("eng-starter", 110, 20, ["ac-bus-2", "ac-bus-3"]),
				output.new("integ-lts", 12, 1, ["dc-bus", "ac-bus-1"])];
				
			busties = [bustie.new("ac-bus-tie", ["ac-bus-1","ac-bus-2","ac-bus-3","ac-bus-4"], "/controls/electric/contact/bus_tie")];
            
            setprop("/systems/electric/util-volts", 0);
            
            setprop("/controls/elec_panel/dc-btc", 0);
            
            setprop("/controls/elec_panel/ac-btc", 0);
            
            me.reset();
    },
    	update : func {
    	
    	# Tie Objects to Properties
    	
    	foreach(var supply; suppliers) {
    	
    		var amps = supply.supply();
    		var volts = 0;
    		
    		if (amps != 0) {
    		
    			volts = supply.volts;
    		
    		}
    		
    		setprop("/systems/electric/suppliers/" ~ supply.name ~ "/volts", volts);
    		setprop("/systems/electric/suppliers/" ~ supply.name ~ "/amps", amps);
    	
    	}
    	
    	foreach(var bus; buses) {
    	
    		setprop("/systems/electric/elec-buses/" ~ bus.name ~ "/volts", bus.get_volts());
    		setprop("/systems/electric/elec-buses/" ~ bus.name ~ "/amps", bus.get_amps());
    		setprop("/systems/electric/elec-buses/" ~ bus.name ~ "/watts", bus.get_amps()*bus.get_volts()); # P = V*i
    	
    	}

    	foreach(var output; outputs) {
    	
    		output.serviceable();
    	
    	}
    	
    	foreach(var bustie; busties) {
    	
    		bustie.tie();
    	
    	}
    	
    	# Communication and Navigation Systems
    	
    	if (getprop("/systems/electric/outputs/comm0") == 1) {
    	
    		setprop("/instrumentation/comm/serviceable", 1);
    	
    	} else {
    	
    		setprop("/instrumentation/comm/serviceable", 0);
    	
    	}
    	
    	if (getprop("/systems/electric/outputs/comm1") == 1) {
    	
    		setprop("/instrumentation/comm[1]/serviceable", 1);
    	
    	} else {
    	
    		setprop("/instrumentation/comm[1]/serviceable", 0);
    	
    	}
    	
    	if (getprop("/systems/electric/outputs/nav0") == 1) {
    	
    		setprop("/instrumentation/nav/serviceable", 1);
    	
    	} else {
    	
    		setprop("/instrumentation/nav/serviceable", 0);
    	
    	}
    	
    	if (getprop("/systems/electric/outputs/nav1") == 1) {
    	
    		setprop("/instrumentation/nav[1]/serviceable", 1);
    	
    	} else {
    	
    		setprop("/instrumentation/nav[1]/serviceable", 0);
    	
    	}
    	
    	# External Power Availablility
    	# FIXME - NEEDS TO BE MOVED TO GROUND SERVICE LATER
    	var gspeed = getprop("/velocities/groundspeed-kt");
    	for(var i=1; i<=4; i=i+1) {
    		if(gspeed < 1) {
    			setprop("/controls/electric/ground/external_"~i, 1);
    		} else {
    			setprop("/controls/electric/ground/external_"~i, 0);
    			setprop("/controls/electric/contact/external_"~i, 0);
    		}
    	}
    	
    	# The rest of the individual pump/equipment serviceability is managed in the individual system files.

	},

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

setlistener("sim/signals/fdm-initialized", func
 {
 electrical.init();
 print("A380 Electrical System Initialized");
 });
