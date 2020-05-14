# (Airbus A380) ECAM E/WD MEMOS
# Narendran Muraleedharan (c) 2014

var memos = [];

# LIMIT FORMAT {desc, def_color, visible(), check()}

append(memos, {desc: 'AUTO BRK RTO',
				def_color: 'magenta',
				visible: func {
					if(getprop("/flight-management/phase") == 'T/O') {
						return 1;
					} else {
						return 0;
					}
				},
				check: func {
					if(getprop("/hydraulics/brakes/autobrake-rto") > 0) {
						return 1;
					} else {
						return 0;
					}
				}
});

append(memos, {desc: 'SIGNS ON',
				def_color: 'cyan',
				visible: func {
					return 1;
				},
				check: func {
					if(getprop("/controls/signs/seatbelt") == 1 and getprop("/controls/signs/no-smoking") == 1) {
						return 1;
					} else {
						return 0;
					}
				}
});

append(memos, {desc: 'FLAPS T/O',
				def_color: 'cyan',
				visible: func {
					if(getprop("/flight-management/phase") == 'T/O') {
						return 1;
					} else {
						return 0;
					}
				},
				check: func {
					if(getprop("/controls/flight/flaps") > 0) {
						return 1;
					} else {
						return 0;
					}
				}
});

append(memos, {desc: 'T/O CONFIG NORM',
				def_color: 'cyan',
				visible: func {
					if(getprop("/flight-management/phase") == 'T/O') {
						return 1;
					} else {
						return 0;
					}
				},
				check: func {
					if(getprop("/controls/gear/brake-parking") == 0) {
						return 1;
					} else {
						return 0;
					}
				}
});

append(memos, {desc: 'LDG GEAR DN',
				def_color: 'cyan',
				visible: func {
					if(getprop("/flight-management/phase") == 'APP') {
						return 1;
					} else {
						return 0;
					}
				},
				check: func {
					if(getprop("/controls/gear/gear-down") == 1) {
						return 1;
					} else {
						return 0;
					}
				}
});

append(memos, {desc: 'FLAPS SET',
				def_color: 'cyan',
				visible: func {
					if(getprop("/flight-management/phase") == 'APP') {
						return 1;
					} else {
						return 0;
					}
				},
				check: func {
					if(getprop("/controls/flight/flaps") == 1) {
						return 1;
					} else {
						return 0;
					}
				}
});

append(memos, {desc: 'AUTO BRK SET',
				def_color: 'magenta',
				visible: func {
					if(getprop("/flight-management/phase") == 'APP') {
						return 1;
					} else {
						return 0;
					}
				},
				check: func {
					if(getprop("/hydraulics/brakes/autobrake-setting") > 0) {
						return 1;
					} else {
						return 0;
					}
				}
});

append(memos, {desc: 'SPD BRK OUT',
				def_color: 'green',
				visible: func {
					if(getprop("/controls/flight/speedbrake") > 0) {
						return 1;
					} else {
						return 0;
					}
				},
				check: func {
					return 0;
				}
});
