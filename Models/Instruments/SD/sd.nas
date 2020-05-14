# (Airbus A380) SD - Systems Display
# Narendran M (c) 2014
# Please refer to the A380 Briefieng for Pilots Document for more information on aircraft systems, a list of page numbers for ECAM SD display documentation is available on the -set.xml file

var placement = "sd";

var sd = ecam.new(sd_pages, placement, "pdz");

setlistener("sim/signals/fdm-initialized", func {
	sd.init();
	print("Systems Display Initialized");
});
