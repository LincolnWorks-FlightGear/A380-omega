## Electrical Power Supplier
var supplier = {

	name: "",
	type: "",
	volts: 0,
	amps: 0,
	dep: 0,
	dep_prop: "",
	dep_max: 0,
	dep_req: 0,
	sw_prop: "",
	supply: func() {
	
		var amps = 0;
	
		if (getprop(me.sw_prop) != 0) {
	
			if (me.dep == 1) {
		
				var dep_val = getprop(me.dep_prop);
			
				if (dep_val > me.dep_req) {
			
					amps = (dep_val / me.dep_max) * me.amps;
			
				} 
		
			} else {
		
				amps = me.amps;
		
			}
			
		}
		
		return amps;
	
	},
	new: func(name, type, volts, amps, dep, dep_prop, dep_max, dep_req, sw_prop) {
	
		var t = {parents:[supplier]};
		
		t.name = name;
		t.type = type;
		t.volts = volts;
		t.amps = amps;
		t.dep = dep;
		t.dep_prop = dep_prop;
		t.dep_max = dep_max;
		t.dep_req = dep_req;
		t.sw_prop = sw_prop;
		
		return t;
	
	}

};
