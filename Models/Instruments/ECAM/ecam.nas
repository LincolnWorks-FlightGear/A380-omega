# (Airbus A380) Electronic Centralized Aircraft Monitor Display Framework
# Narendran M (c) 2014

var ecam = {
	active: "",
	pages: {},
	new: func(pages, placement, perm="nil") {
		var t = {parents:[ecam]};
		t.pages = pages;
		
		t.display = canvas.new({
			"name":			"ECAM Display",
			"size":			[800, 1024],
			"view":			[800, 1024],
			"mipmapping":	1
		});
		
		t.display.addPlacement({"node": placement});
		t.objects = t.display.createGroup();
		t.timer = maketimer(0.05, t, t.update);
		t.perm = perm;
		return t;
	},
	load: func(page) {
		me.objects.removeAllChildren();
		var font_mapper = func(family, weight)
		{
			if( family == "Liberation Sans" and weight == "normal" )
				return "LiberationFonts/LiberationSans-Regular.ttf";
		};
		if(me.perm != "nil") {
			# Permanent Area Exists, load it
			canvas.parsesvg(me.objects, me.pages[me.perm].path, {'font-mapper': font_mapper});
			foreach(var svg_object; me.pages[me.perm].objects) {
				me.pages[me.perm].svg[svg_object] = me.objects.getElementById(svg_object);
			}
		}
		canvas.parsesvg(me.objects, me.pages[page].path, {'font-mapper': font_mapper});
		# Cache SVG Objects for animation
		foreach(var svg_object; me.pages[page].objects) {
			me.pages[page].svg[svg_object] = me.objects.getElementById(svg_object);
		}
		me.active = page;
		me.pages[page].load(); # Run page load script
	},
	update: func() {
		if(me.active != "") {
			me.pages[me.active].update();
		}
		if(me.perm != "nil") {
			me.pages[me.perm].update();
		}
	},
	init: func() {
		me.timer.start();
	},
	showDlg: func {
		if(getprop("sim/instrument-options/canvas-popup-enable")) {
		    var dlg = canvas.Window.new([400, 512], "dialog");
		    dlg.setCanvas(me.display);
		}
	}
};
