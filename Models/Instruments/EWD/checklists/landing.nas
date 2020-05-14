checklists["landing"] = {		title: 'LANDING',
								items: [checklist_item.new(desc: 'CABIN CREW',
										resp: 'ADVISED',
										manual: 1),
										
										checklist_item.new(desc: 'A/THR',
										resp: 'SPEED/OFF',
										manual: 1),
										
										checklist_item.new(desc: 'ECAM MEMO',
										resp: 'LDG NO BLUE',
										manual: 0,
										prop: '/flight-management/ecam/no-blue',
										value: 1)
]};
