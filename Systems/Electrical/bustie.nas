var bustie = {
	name: "",
	buses: [],
	switch: "",
	tie: func() {
		if(getprop(me.switch) == 1) {
			var volts = 0;
			var power = 0; # P = V*i
			var num_buses = 0;
			foreach(var bus; me.buses) {
				var bus_current = getprop("/systems/electric/elec-buses/"~bus~"/amps");
				var bus_voltage = getprop("/systems/electric/elec-buses/"~bus~"/volts");
				power += bus_voltage*bus_current;
				if(bus_voltage > volts) {
					volts = bus_voltage; # Set Bus Voltage to the highest available
				}
				num_buses += 1;
			}
			# Distribute the power and apply equal amounts to each bus
			if(volts > 0 and num_buses > 0) {
				var current = power/volts;
				foreach(var bus; me.buses) {
					setprop("/systems/electric/elec-buses/"~bus~"/amps", current/num_buses);
					setprop("/systems/electric/elec-buses/"~bus~"/volts", volts);
				}
			}
		}
	},
	new: func(name, buses, switch) {
		var t = {parents:[bustie]};
		t.name = name;
		t.buses = buses;
		t.switch = switch;
		return t;
	}
}
