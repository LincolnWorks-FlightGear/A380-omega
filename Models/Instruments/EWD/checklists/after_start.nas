checklists["after_start"] = {	title: 'AFTER START',
								items: [checklist_item.new(desc: 'ANTI ICE',
										resp: 'AS RQRD',
										manual: 1),
										
										checklist_item.new(desc: 'ECAM STATUS',
										resp: 'CHECKED',
										manual: 1),
										
										checklist_item.new(desc: 'PITCH TRIM',
										resp: 'SET FOR T/O',
										manual: 1),
										
										checklist_item.new(desc: 'RUDDER TRIM',
										resp: 'ZERO',
										manual: 0,
										prop: '/controls/flight/rudder-trim',
										value: 0)
]};
