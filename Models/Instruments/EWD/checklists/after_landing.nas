checklists["after_landing"] = {
								title: 'AFTER LANDING',
								items: [checklist_item.new(desc: 'FLAPS',
										resp: 'RETRACTED',
										manual: 0,
										prop: '/controls/flight/flaps',
										value: 0),
										
										checklist_item.new(desc: 'SPOILERS',
										resp: 'DISARMED',
										manual: 0,
										prop: '/controls/flight/speedbrake',
										value: 0),
										
										checklist_item.new(desc: 'APU',
										resp: 'STARTED',
										manual: 0,
										prop: '/engines/engine[4]/running',
										value: 1),
										
										checklist_item.new(desc: 'RADAR',
										resp: 'OFF/STBY',
										manual: 1),
										
										checklist_item.new(desc: 'PREDICTIVE WINDSHEAR SYS',
										resp: 'OFF',
										manual: 1)
]};
