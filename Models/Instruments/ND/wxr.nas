# Live Weather Radar from WunderMaps
# Narendran M (c) 2014

var root = getprop("/sim/aircraft-dir");

###################################  WXR CLASS ##################################

var wxr = {
	new: func(id, group) {
		var t = {parents:[wxr]};

		t.props = props;
		t.id = id;
		
		# Initialize Instrumentation Properties
		setprop("/instrumentation/wxr["~id~"]/last-request-time", -210); # Just to reload in 30 sec to make sure the image is visible
		setprop("/instrumentation/wxr["~id~"]/update-interval-sec", 240); # 3 min
		io.read_properties(root ~ "/Models/Instruments/ND/api_key.xml", "/instrumentation/wxr["~id~"]");
		setprop("/instrumentation/wxr["~id~"]/center/latitude-deg", getprop("/position/latitude-deg"));
		setprop("/instrumentation/wxr["~id~"]/center/longitude-deg", getprop("/position/longitude-deg"));
		setprop("/instrumentation/wxr["~id~"]/mode", "radar");
		setprop("/instrumentation/wxr["~id~"]/resolution", 2048);
		
		t.api_key = getprop("/instrumentation/wxr["~id~"]/api-key");
		t.res = getprop("/instrumentation/wxr["~id~"]/resolution");
		t.mode = getprop("/instrumentation/wxr["~id~"]/mode");
		t.lat = getprop("/instrumentation/wxr["~id~"]/center/latitude-deg");
		t.lon = getprop("/instrumentation/wxr["~id~"]/center/longitude-deg");
		
		t.layer = group.createChild("image").set("z-index", -100);
		
		# Grab image from wunderMap
		if(t.mode == "radar") {
			t.layer.setFile("http://api.wunderground.com/api/"~t.api_key~"/radar/image.png?centerlat="~t.lat~"&centerlon="~t.lon~"&radius=200&width="~t.res~"&height="~t.res~"&smooth=1");
			
			print("WXR Layer: "~"http://api.wunderground.com/api/"~t.api_key~"/radar/image.png?centerlat="~t.lat~"&centerlon="~t.lon~"&radius=200&width="~t.res~"&height="~t.res~"&smooth=1");
		}
		
		t.timer = maketimer(0.05, t, t.update);

		return t;
	},
	init: func {
		me.timer.start();
	},
	update: func {
		
		if(getprop("/instrumentation/efis["~me.id~"]/inputs/wx") == 1 and getprop("/instrumentation/efis["~me.id~"]/mfd/airbus-display-mode") == "ARC") {
			me.layer.show();
			me.lat = getprop("/position/latitude-deg");
			me.lon = getprop("/position/longitude-deg");
			me.range = getprop("/instrumentation/efis["~me.id~"]/inputs/range-nm");
			me.clat = getprop("/instrumentation/wxr["~me.id~"]/center/latitude-deg");
			me.clon = getprop("/instrumentation/wxr["~me.id~"]/center/longitude-deg");

			var r_scaled = (200*670)/me.range;
			me.layer.setSize(2*r_scaled, 2*r_scaled);
			me.layer.setTranslation(512 - r_scaled - ((me.lon-me.clon)*60)*(670/me.range), 824  - r_scaled + ((me.lat-me.clat)*60)*(670/me.range))
					.setCenter(r_scaled + ((me.lon-me.clon)*60)*(670/me.range), r_scaled - ((me.lat-me.clat)*60)*(670/me.range))
					.setRotation(-getprop("/orientation/heading-deg")*D2R);
			
			# Update data
			if(getprop("/sim/time/elapsed-sec") - getprop("/instrumentation/wxr["~me.id~"]/last-request-time") > getprop("/instrumentation/wxr["~me.id~"]/update-interval-sec")) {
				setprop("/instrumentation/wxr["~me.id~"]/center/latitude-deg", me.lat);
				setprop("/instrumentation/wxr["~me.id~"]/center/longitude-deg", me.lon);
				me.api_key = getprop("/instrumentation/wxr["~me.id~"]/api-key");
				me.res = getprop("/instrumentation/wxr["~me.id~"]/resolution");
				me.mode = getprop("/instrumentation/wxr["~me.id~"]/mode");
				
				me.layer.setFile("http://api.wunderground.com/api/"~me.api_key~"/radar/image.png?centerlat="~me.lat~"&centerlon="~me.lon~"&radius=200&width="~me.res~"&height="~me.res~"&smooth=1");
			
				print("WXR Layer: "~"http://api.wunderground.com/api/"~me.api_key~"/radar/image.png?centerlat="~me.lat~"&centerlon="~me.lon~"&radius=200&width="~me.res~"&height="~me.res~"&smooth=1");
				setprop("/instrumentation/wxr["~me.id~"]/last-request-time", getprop("/sim/time/elapsed-sec"));
			}
			
		} else {
			me.layer.hide();
		}
		
	}
	
};
