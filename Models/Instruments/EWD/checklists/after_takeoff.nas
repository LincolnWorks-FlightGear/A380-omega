checklists["after_takeoff"] = {	title: 'AFTER TAKEOFF / CLIMB',
								items: [checklist_item.new(desc: 'LDG GEAR',
										resp: 'UP',
										manual: 0,
										prop: '/controls/gear/gear-down',
										value: 0),
										
										checklist_item.new(desc: 'FLAPS',
										resp: 'RETRACTED',
										manual: 0,
										prop: '/controls/flight/flaps',
										value: 0),
										
										checklist_item.new(desc: 'AIR COND PACKS',
										resp: 'ON',
										manual: 0,
										props: '/controls/pressurization/pack[1]/pack-on',
										value: 1),
										
										checklist_item.new(desc: 'BARO REF',
										resp: 'SET',
										manual: 1)
]};
