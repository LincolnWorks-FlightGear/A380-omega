## Electrical Outputs
var output = {

	name: "",
	min_volt: "",
	run_amps: 0,
	bus: [],
	serviceableVolts: 0,
	serviceable: func() {
	
		var serviceable = 0;
	
		foreach(var out_bus; me.bus) {
	
			foreach(var bus; buses) {
		
				if (out_bus == bus.name) {
			
					if ((bus.get_volts() >= me.min_volt) and (bus.get_amps() >= me.run_amps)) {
				
						serviceable = 1;
						
						if (me.serviceableVolts < bus.get_volts())
						{
							me.serviceableVolts = bus.get_volts();
						}
					}
			
				}
		
			}
			
		}
		
		if (serviceable == 1) {
		
			setprop("/systems/electric/outputs/" ~ me.name, 1);
			setprop("/systems/electrical/outputs/" ~ me.name, me.serviceableVolts);
		
		} else {
		
			setprop("/systems/electric/outputs/" ~ me.name, 0);
			setprop("/systems/electrical/outputs/" ~ me.name, me.serviceableVolts);		
		}
	
	},
	new: func(name, min_volt, run_amps, bus) {
	
		var t = {parents:[output]};
		
		t.name = name;
		t.min_volt = min_volt;
		t.run_amps = run_amps;
		t.bus = bus;
		
		return t;
	
	}

};
