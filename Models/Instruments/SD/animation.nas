# ECAM (well, canvas in general) Animation Helper Functions
# Narendran M (c) 2014

var animation = {
	toggle_equals: func(prop, value, element) {
		if(getprop(prop) == value) {
			element.show();
		} else {
			element.hide();
		}
	},
	toggle_not_equals: func(prop, value, element) {
		if(getprop(prop) != value) {
			element.show();
		} else {
			element.hide();
		}
	},
	toggle_gte: func(prop, value, element) {
		if(getprop(prop) >= value) {
			element.show();
		} else {
			element.hide();
		}
	},
	toggle_lte: func(prop, value, element) {
		if(getprop(prop) <= value) {
			element.show();
		} else {
			element.hide();
		}
	},
	rotary_switch: func(prop, value, angle, element) {
		if(getprop(prop) == value) {
			element.setRotation(angle*D2R);
		} else {
			element.setRotation(0);
		}
	},
	color_rotary_switch: func(prop, value, angle, element, onColor, offColor) {
		if(getprop(prop) == value) {
			element.setRotation(angle*D2R).setColor(onColor);
		} else {
			element.setRotation(0).setColor(offColor);
		}
	},
	surface_position: func(prop, pos, thick, factor, orient, element, parent, color) {
		# prop - 	interface property
		# pos - 	[x,y] - top/left position on canvas
		# thick - 	thickness in pixels of slider
		# max_val -	maximum value of property corresponding to full slider length
		# max_len -	maximum scaling value of slider in canvas
		# orient -	'h' or 'v' corresponding to horizonal and vertical respectively
		
		# The element must be instantiated on page load before this animation can be used!
		element.reset().setColorFill(color)
					   .moveTo(pos[0], pos[1]);
		
		var value = getprop(prop);
		
		if(orient == 'h') {	# Horizontal Slider
		
			element.lineTo(pos[0] + (value*factor), pos[1])
				   .lineTo(pos[0] + (value*factor), pos[1] + thick)
				   .lineTo(pos[0], pos[1] + thick);
		
		} else { # Vertical Slider
			
			element.lineTo(pos[0], pos[1] + (value*factor))
				   .lineTo(pos[0] + thick, pos[1] + (value*factor))
				   .lineTo(pos[0] + thick, pos[1]);
			
		}
		
	}
};
