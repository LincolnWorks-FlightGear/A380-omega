# Initialize empty SD pages hash - call this first and THEN each nasal file with the pages. And finally, the sd.nas file to instantiate the ECAM display.
var sd_pages = {};

# REFERENCE FILES AND PAGE NUMBERS ON PILOT BRIEFING #######################################
# <file>Aircraft/A380-omega/Models/Instruments/SD/fctl/fctl.nas</file>			 <!-- pg 141 -->
# <file>Aircraft/A380-omega/Models/Instruments/SD/fuel/fuel.nas</file>			 <!-- pg 164 -->
# <file>Aircraft/A380-omega/Models/Instruments/SD/cond/cond.nas</file>			 <!-- pg 047 -->
# <file>Aircraft/A380-omega/Models/Instruments/SD/bleed/bleed.nas</file>			 <!-- pg 048 -->
# <file>Aircraft/A380-omega/Models/Instruments/SD/cruise/cruise.nas</file>		 <!-- pg 057 -->
# <file>Aircraft/A380-omega/Models/Instruments/SD/cab_press/cab_press.nas</file> 	 <!-- pg 057 -->
# <file>Aircraft/A380-omega/Models/Instruments/SD/elec_ac/elec_ac.nas</file>		 <!-- pg 108 -->
# <file>Aircraft/A380-omega/Models/Instruments/SD/elec_dc/elec_dc.nas</file>		 <!-- pg 108 -->
# <file>Aircraft/A380-omega/Models/Instruments/SD/hyd/hyd.nas</file>				 <!-- pg 169 -->
# <file>Aircraft/A380-omega/Models/Instruments/SD/wheel/wheel.nas</file>			 <!-- pg 232 -->
# <file>Aircraft/A380-omega/Models/Instruments/SD/door/door.nas</file>			 <!-- pg 255 -->
# <file>Aircraft/A380-omega/Models/Instruments/SD/engine/engine.nas</file>		 <!-- pg 294 -->
# <file>Aircraft/A380-omega/Models/Instruments/SD/apu/apu.nas</file>				 <!-- pg 283 -->
############################################################################################
