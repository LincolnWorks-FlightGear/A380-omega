## Electrical Bus
var bus = {

	name: "",
	type: "",
	suppliers: [],
	get_volts: func() {
	
		var volts = 0;
	
		foreach(var bus_supplier; me.suppliers) {
		
			foreach(var supplier; suppliers) {
			
				if (bus_supplier == supplier.name) {
				
					if(supplier.supply() != 0) {
					
						if (supplier.volts > volts) {
						
							volts = supplier.volts;
						
						}
					
					}
				
				}
			
			}
		
		}
		
		return volts;
	
	},
	get_amps: func() {
	
		var amps = 0;
	
		foreach(var bus_supplier; me.suppliers) {
		
			foreach(var supplier; suppliers) {
			
				if (bus_supplier == supplier.name) {
				
					amps += supplier.supply();
				
				}
			
			}
		
		}
		
		return amps;
	
	},
	new: func(name, type, suppliers) {
	
		var t = {parents:[bus]};
		
		t.name = name;
		t.type = type;
		t.suppliers = suppliers;
		
		return t;
	
	}

};
