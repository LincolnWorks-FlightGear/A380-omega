var hyd_green = {

	# Control Surfaces are pressurized through the FCS script
	
	eng1_pump_a : func() {
	
		var pressure = 0;
		var epr = getprop("/engines/engine/epr");
		
		if (epr > 1)
			pressure = epr * 1400;
		
		if (pressure > 2800)
			hydraulics.green_psi += 2800; # Filter
		else
			hydraulics.green_psi += pressure;
	
	},
	eng1_pump_b : func() {
	
		var pressure = 0;
		var epr = getprop("/engines/engine/epr");
		
		if (epr > 1)
			pressure = epr * 1400;
		
		if (pressure > 2800)
			hydraulics.green_psi += 2800; # Filter
		else
			hydraulics.green_psi += pressure;
	
	},
	eng2_pump_a : func() {
	
		var pressure = 0;
		var epr = getprop("/engines/engine[1]/epr");
		
		if (epr > 1)
			pressure = epr * 1400;
		
		if (pressure > 2800)
			hydraulics.green_psi += 2800; # Filter
		else
			hydraulics.green_psi += pressure;
	
	},
	eng2_pump_b : func() {
	
		var pressure = 0;
		var epr = getprop("/engines/engine[1]/epr");
		
		if (epr > 1)
			pressure = epr * 1400;
		
		if (pressure > 2800)
			hydraulics.green_psi += 2800; # Filter
		else
			hydraulics.green_psi += pressure;
	
	},
	power: func() {
		hydraulics.green_psi = 0;
		var pump1a = getprop("/controls/hydraulics/engine/pump-a");
		var pump1b = getprop("/controls/hydraulics/engine/pump-b");
		var pump2a = getprop("/controls/hydraulics/engine[1]/pump-a");
		var pump2b = getprop("/controls/hydraulics/engine[1]/pump-b");
		if(pump1a) {
			me.eng1_pump_a();
		}
		if(pump1b) {
			me.eng1_pump_b();
		}
		if(pump2a) {
			me.eng2_pump_a();
		}
		if(pump2b) {
			me.eng2_pump_b();
		}
		if(hydraulics.green_psi >= 5000) { # Limit maximum hydraulic pressure
			hydraulics.green_psi = 5000;
		}
	}
	
	
	# The priority value has been removed as it's only used for the FCS and the FCS script managed amount of power output.

};
