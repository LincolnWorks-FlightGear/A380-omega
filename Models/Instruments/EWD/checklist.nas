# (Airbus A380) ECAM E/WD Checklist
# Narendran Muraleedharan (c) 2014

var checklist_item = {
	desc: "",
	resp: "",
	manual: 0,
	prop: "",
	value: 0,
	new: func(desc, resp, manual, prop="", value=0) {
		var t = {parents:[checklist_item]};
		t.desc = desc;
		t.resp = resp;
		t.manual = manual;
		t.prop = prop;
		t.value = value;
		return t;
	}
};

var checklists = {};

# Map checklists in menu to checklists hash
var checklists_menu = ["before_start", "after_start", "before_takeoff", "after_takeoff", "approach", "landing", "after_landing", "parking", "securing_the_aircraft"];
