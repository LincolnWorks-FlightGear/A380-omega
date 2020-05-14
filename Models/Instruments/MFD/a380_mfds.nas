setprop("/flight-management/fuel/taxi", "0.6");
setprop("/flight-management/fuel/zfw", "---.-");
setprop("/flight-management/fuel/rte-rsv", "0.0");
setprop("/flight-management/transition-altitude-ft", "18000");
setprop("/flight-management/crz_fl", "320");

var capt_mfd = mfd.new("mfd.l", "Aircraft/A380-omega/Models/Instruments/MFD/display.svg");
var fo_mfd = mfd.new("mfd.r", "Aircraft/A380-omega/Models/Instruments/MFD/display.svg");

capt_mfd.loadPage("menu_fms", "fms_active_init");
fo_mfd.loadPage("menu_fms", "fms_active_perf");

print("Airbus Multi-Function Displays Initialized");
