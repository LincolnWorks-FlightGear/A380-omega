var stepTo = func(tgt, val, step) {
	if(val < tgt - step) {
		return val + step;
	} elsif(val > tgt + step) {
		return val - step;
	} else {
		return tgt;
	}
}

setprop("/systems/hydraulics/yellow/pressure-psi",0);
setprop("/systems/hydraulics/green/pressure-psi",0);
setprop("/systems/hydraulics/elec-backup/pressure-psi",0);

var hydraulics = {
	yellow_psi: 0,
	green_psi: 0,
	elec_backup_psi: 0,
	update_props: func() {
		setprop("/systems/hydraulics/yellow/pressure-psi", stepTo(me.yellow_psi,getprop("/systems/hydraulics/yellow/pressure-psi"),40));
		setprop("/systems/hydraulics/green/pressure-psi", stepTo(me.green_psi,getprop("/systems/hydraulics/green/pressure-psi"),40));
		setprop("/systems/hydraulics/elec-backup/pressure-psi", stepTo(me.elec_backup_psi,getprop("/systems/hydraulics/elec-backup/pressure-psi"),40));
	}
}
