var hyd_loop = {
		init : func {
            me.UPDATE_INTERVAL = 0.02;
            me.loopid = 0;
            
            me.reset();
	},
    	update : func {
    	
    	hyd_green.power();
    	hyd_yellow.power();
    	hyd_elec_backup.power();
    	
    	hydraulics.update_props();
    	
    	# Flaps Serviceability
    	if(hydraulics.green_psi + hydraulics.yellow_psi > 2500) {
    		setprop("/sim/failure-manager/controls/flight/flaps/serviceable", 1);
    	} else {
    		setprop("/sim/failure-manager/controls/flight/flaps/serviceable", 0);
    	}
		
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
 hyd_loop.init();
 print("A380 Hydraulics System Initialized");
 });
