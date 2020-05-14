checklists["approach"] = {		title: 'APPROACH',
								items: [checklist_item.new(desc: 'BRIEFING',
										resp: 'CONFIRMED',
										manual: 1),
										
										checklist_item.new(desc: 'ECAM STATUS',
										resp: 'CHECKED',
										manual: 1),
										
										checklist_item.new(desc: 'SEATBELT SIGN',
										resp: 'ON',
										manual: 0,
										prop: '/controls/signs/seatbelt',
										value: 1),
										
										checklist_item.new(desc: 'BARO REF',
										resp: 'SET',
										manual: 1),
										
										checklist_item.new(desc: 'MDA / DH',
										resp: 'SET (BOTH)',
										manual: 1),
										
										checklist_item.new(desc: 'ENG MODE SEL',
										resp: 'AS RQRD',
										manual: 1)
]};
