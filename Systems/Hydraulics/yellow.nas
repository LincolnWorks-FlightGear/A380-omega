var hyd_yellow = {

	# Control Surfaces are pressurized through the FCS script
	eng3_pump_a : func() {
	
		var pressure = 0;
		var epr = getprop("/engines/engine[2]/epr");
		
		if (epr > 1)
			pressure = epr * 1400;
		
		if (pressure > 2800)
			hydraulics.yellow_psi += 2800; # Filter
		else
			hydraulics.yellow_psi += pressure;
	
	},
	eng3_pump_b : func() {
	
		var pressure = 0;
		var epr = getprop("/engines/engine[2]/epr");
		
		if (epr > 1)
			pressure = epr * 1400;
		
		if (pressure > 2800)
			hydraulics.yellow_psi += 2800; # Filter
		else
			hydraulics.yellow_psi += pressure;
	
	},
	eng4_pump_a : func() {
	
		var pressure = 0;
		var epr = getprop("/engines/engine[3]/epr");
		
		if (epr > 1)
			pressure = epr * 1400;
		
		if (pressure > 2800)
			hydraulics.yellow_psi += 2800; # Filter
		else
			hydraulics.yellow_psi += pressure;
	
	},
	eng4_pump_b : func() {
	
		var pressure = 0;
		var epr = getprop("/engines/engine[3]/epr");
		
		if (epr > 1)
			pressure = epr * 1400;
		
		if (pressure > 2800)
			hydraulics.yellow_psi += 2800; # Filter
		else
			hydraulics.yellow_psi += pressure;
	
	},
	power: func() {
		hydraulics.yellow_psi = 0;
		var pump3a = getprop("/controls/hydraulics/engine[2]/pump-a");
		var pump3b = getprop("/controls/hydraulics/engine[2]/pump-b");
		var pump4a = getprop("/controls/hydraulics/engine[3]/pump-a");
		var pump4b = getprop("/controls/hydraulics/engine[3]/pump-b");
		if(pump3a) {
			me.eng3_pump_a();
		}
		if(pump3b) {
			me.eng3_pump_b();
		}
		if(pump4a) {
			me.eng4_pump_a();
		}
		if(pump4b) {
			me.eng4_pump_b();
		}
		if(hydraulics.yellow_psi >= 5000) { # Limit maximum hydraulic pressure
			hydraulics.yellow_psi = 5000;
		}
	}
	
	# The priority value has been removed as it's only used for the FCS and the FCS script managed amount of power output.

};
