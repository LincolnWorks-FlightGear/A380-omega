checklists["before_takeoff"] = {
								title: 'BEFORE TAKEOFF',
								items: [checklist_item.new(desc: 'FLIGHT CONTROLS',
										resp: 'CHECKED',
										manual: 1),
										
										checklist_item.new(desc: 'FLIGHT INSTRUMENTS',
										resp: 'CHECKED',
										manual: 1),
										
										checklist_item.new(desc: 'BRIEFING',
										resp: 'CONFIRMED',
										manual: 1),
										
										checklist_item.new(desc: 'FLAP SETTING',
										resp: 'CONF',
										manual: 1),
										
										checklist_item.new(desc: 'ATC CONNECT',
										resp: 'SET',
										manual: 1),
										
										checklist_item.new(desc: 'ECAM MEMO',
										resp: 'T/O NO BLUE',
										manual: 0,
										prop: '/flight-management/ecam/no-blue',
										value: 1),
										
										checklist_item.new(desc: 'CABIN CREW',
										resp: 'ADVISED',
										manual: 1),
										
										checklist_item.new(desc: 'AIR COND PACKS',
										resp: 'AS RQRD',
										manual: 1)
]};
