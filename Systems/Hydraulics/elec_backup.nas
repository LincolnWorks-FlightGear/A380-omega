var hyd_elec_backup = {

	# Powered through the emergency DC buses (from RAT)
	power: func() {
		var emer_bus_pwr = getprop("/systems/electric/elec-buses/emer-bus/watts");
		var ac_bus2_pwr = getprop("/systems/electric/elec-buses/ac-bus-2/watts");
		var pressure_psi = (emer_bus_pwr+ac_bus2_pwr)*28;
		if(pressure_psi < 2500) {
			hydraulics.elec_backup_psi = pressure_psi;
		} else {
			hydraulics.elec_backup_psi = 2500;
		}
	}

};
