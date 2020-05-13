# FUEL TANK INTERFACE
# Copyright Narendran Muraleedharan 2014

var tank = {
	id: 0,
	name: "",
	tree: "",
	capacity_gal: func() {
		return getprop(me.tree~"capacity-gal_us");
	},
	level_gal: func() {
		return getprop(me.tree~"level-gal_us");
	},
	level_norm: func() {
		return getprop(me.tree~"level-norm");
	},
	isEmpty: func() {
		return getprop(me.tree~"empty");
	},
	add_gal: func(gal) {
		if(me.level_gal() + gal < me.capacity_gal()) {
			setprop(me.tree~"level-gal_us", me.level_gal() + gal);
		}
	},
	rm_gal: func(gal) {
		if(me.level_gal() - gal >= 0) {
			setprop(me.tree~"level-gal_us", me.level_gal() - gal);
		}
	},
	isFull: func() {
		if(getprop(me.tree~"level-norm") == 1) {
			return 1;
		} else {
			return 0;
		}
	},
	new: func(id, name) {
		var t = {parents:[tank]};
		t.id = id;
		t.name = name;
		t.tree = "/consumables/fuel/tank[" ~ id ~ "]/";
		return t;
	}
};
