var alerts = {
	colors: {
		'red':		[0.85,	0,		0],		# Failures requiring immediate action
		'amber':	[1,		0.55,	0],		# Failures requiring awareness but not immediate action
		'green':	[0,		0.85,	0],		# Memo, Checked in a normal checklist
		'white':	[0.85,	0.85,	0.85],	# Conditional Items, completed actions in procedure
		'cyan':		[0,		0.85,	1],	# Limitations, unchecked items in a checklist
		'magenta':	[0.85,	0,		0.85],	# Specific Memo (TO, LDG etc.)
		'gray':		[0.55,	0.55,	0.55]	# Invalid items
	},
	mode: 'LIMIT', # CHECKLIST_MENU, CHECKLIST, PROC, LIMIT, ABN PROC
	active_item: -1,
	checklist: 'before_start', # Default checklist
	checklist_id: 0,
	items: [], # ITEM - Checklist/Procedure items
	limits: [],	# LIMIT - Limitations (displayed in white/cyan)
	memos: [],	# STRING - Memos (displayed in green)
	select_checklist: func() {
		me.checklist = checklists_menu[me.active_item];
		me.checklist_id = me.active_item;
		me.active_item = 0;
		me.mode = 'CHECKLIST';
	},
	check_item: func() {
		if(me.mode == 'CHECKLIST_MENU') {
			me.select_checklist();
		} else {
			if(me.active_item == (size(me.items)-1)) {
				me.mode = 'CHECKLIST_MENU'; # Go to checklist menu
				me.active_item = me.checklist_id+1;
			} else {
				me.active_item = me.active_item + 1;
			}
		}
	},
	scroll_up: func() {
		if(me.active_item > 0) {
			me.active_item = me.active_item - 1;
		}
	},
	scroll_down: func() {
		if(me.active_item < (size(me.items)-1)) {
			me.active_item = me.active_item + 1;
		}
	},
	update: func {
		if(me.mode == 'CHECKLIST_MENU') { # IF CL CLICKED
			if(me.active_item < 0) {
				me.active_item = 0;
			}
			me.items = [];
			foreach(var menu_item; checklists_menu) {
				append(me.items, {
					desc: checklists[menu_item].title,
					color: 'cyan',
					checkbox: 0,
					checked: 0,
					resp: ''
				});
			}
			if(me.active_item >= size(me.items)) {
				me.active_item = 0;
			}
		} elsif(me.mode == 'CHECKLIST') {
			if(me.active_item < 0) {
				me.active_item = 0;
			}
			me.items = [];
			forindex(var n; checklists[me.checklist].items) {
				var item = checklists[me.checklist].items[n];
				if(item.manual == 1) {			# SHOW CHECKBOX
					if(n < me.active_item) {	# SHOW CHECKED, COLOR GREEN
						append(me.items, {
							desc: item.desc,
							color: 'green',
							checkbox: 1,
							checked: 1,
							resp: item.resp
						});
					} else {					# HIDE CHECKED, COLOR CYAN
						append(me.items, {
							desc: item.desc,
							color: 'cyan',
							checkbox: 1,
							checked: 0,
							resp: item.resp
						});
					}
				} else {						# HIDE CHECKBOX, HIDE CHECKED
					if(getprop(item.prop) == item.value) {	# COLOR GREEN
						append(me.items, {
							desc: item.desc,
							color: 'green',
							checkbox: 0,
							checked: 0,
							resp: item.resp
						});
						if(me.active_item == n) {
							me.active_item = me.active_item + 1;
						}
					} else {								# COLOR CYAN
						append(me.items, {
							desc: item.desc,
							color: 'cyan',
							checkbox: 0,
							checked: 0,
							resp: item.resp
						});
					}
				}
			}
			if(me.active_item >= size(me.items)) {
				me.active_item = me.checklist_id+1;
				me.mode = 'CHECKLIST_MENU';
			}
		} elsif(me.mode == 'PROC') {
			#FIXME - Figure this part out
		} elsif(me.mode == 'LIMIT') { # DEFAULT MODE
			
			me.active_item = -1;
			
			me.limits = [];
			me.memos = [];
			
			var noblue = 1;
			foreach(var memo; memos) {
				if(memo.visible()) {
					if(memo.check()) {
						append(me.memos, {
							desc: memo.desc,
							color: 'green'
						});
					} else {
						append(me.memos, {
							desc: memo.desc,
							#color: memo.def_color
							color: 'cyan'
						});
						noblue = 0;
					}
				}
			}
			setprop("/flight-management/ecam/no-blue", noblue);
		} elsif(me.mode == 'ABN PROC') { # IF ABN PROC CLICKED
			#FIXME - Figure this part out
		}
	},
};

